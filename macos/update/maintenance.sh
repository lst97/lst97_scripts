#!/bin/bash
# macOS Developer Maintenance Script
# Version 3.1.0 | Enhanced for Safety, Configuration, and UX

# -------------------------------
# Configuration Section
# -------------------------------

# --- Logging Configuration ---
LOG_DIR="${HOME}/Desktop"
LOG_FILE="${LOG_DIR}/maintenance_$(date +%Y%m%d_%H%M%S).log"

# --- System Requirements ---
MIN_DISK_SPACE_GB=10
MIN_MACOS_VERSION="10.15"  # Catalina and later

# --- File Paths (make these configurable) ---
PRIVACY_SCRIPT_PATH="${PRIVACY_SCRIPT_PATH:-./privacy-script.sh}"
CONFIG_FILE="${HOME}/.maintenance_config"

# --- Action Flags (can be overridden by command-line options) ---
DRY_RUN=false
AUTO_YES=false # If true, skips all confirmation prompts.
VERBOSE=false
SKIP_SYSTEM_UPDATES=false
SKIP_HOMEBREW=false
SKIP_NODE=false
SKIP_PYTHON=false
SKIP_CACHES=false
SKIP_DATABASES=false

# --- Timeout Settings ---
COMMAND_TIMEOUT=300  # 5 minutes default timeout for commands

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# -------------------------------
# Global State
# -------------------------------
declare -a SKIPPED_TASKS
declare -a FAILED_TASKS
declare -a COMPLETED_TASKS
SCRIPT_START_TIME=$(date +%s)
SPINNER_PID="" # To store the PID of the spinner process

# -------------------------------
# Configuration Loading
# -------------------------------
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        print_info "Loading configuration from $CONFIG_FILE"
        # Source the config file safely
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ $key =~ ^[[:space:]]*# ]] && continue
            [[ -z $key ]] && continue
            
            # Set the variable if it's a known configuration option
            case $key in
                MIN_DISK_SPACE_GB|COMMAND_TIMEOUT|PRIVACY_SCRIPT_PATH)
                    declare -g "$key=$value"
                    ;;
                SKIP_*)
                    declare -g "$key=$value"
                    ;;
            esac
        done < "$CONFIG_FILE"
    fi
}

# -------------------------------
# Core Functions
# -------------------------------
print_section() { echo -e "${GREEN}\n==> $1${NC}"; }
print_subsection() { echo -e "${YELLOW}  -> $1${NC}"; }
print_info() { echo -e "${BLUE}     INFO:${NC} $1"; }
print_warning() { echo -e "${YELLOW}     WARN:${NC} $1"; }
print_error() { echo -e "${RED}     ERROR:${NC} $1"; }
print_success() { echo -e "${GREEN}     SUCCESS:${NC} $1"; }
print_debug() { [ "$VERBOSE" = true ] && echo -e "${PURPLE}     DEBUG:${NC} $1"; }

# Function to start a loading spinner
start_spinner() {
    if [ "$DRY_RUN" = true ] || [ "$VERBOSE" = true ]; then
        return
    fi
    local i=1
    local spin_chars="/-\|"
    echo -n "  "
    while true; do
        i=$(( (i + 1) % 4 ))
        printf "\b\b%s " "${spin_chars:$i:1}"
        sleep 0.1
    done &
    SPINNER_PID=$!
    # Disown the process so it doesn't get killed when the parent exits
    disown
}

# Function to stop the loading spinner
stop_spinner() {
    if [ -n "$SPINNER_PID" ]; then
        kill "$SPINNER_PID" &>/dev/null
        # Clear the spinner character
        printf "\b\b  \b\b"
        SPINNER_PID=""
    fi
}

confirm_action() {
    local prompt="$1"
    local default="${2:-N}"  # Default to No if not specified
    
    if [ "$AUTO_YES" = true ]; then
        print_info "Confirmation for '$prompt' skipped due to --yes flag."
        return 0
    fi

    local prompt_suffix="(y/N)"
    [ "$default" = "Y" ] && prompt_suffix="(Y/n)"
    
    # Temporarily stop spinner before reading input
    stop_spinner
    read -p "$(echo -e "${YELLOW}CONFIRM:${NC} $prompt $prompt_suffix: ")" -n 1 -r
    echo "" # Move to a new line
    
    if [[ $REPLY =~ ^[Yy]$ ]] || ([[ -z $REPLY ]] && [[ "$default" = "Y" ]]); then
        return 0 # Success (yes)
    else
        return 1 # Failure (no)
    fi
}

run_command() {
    local cmd="$*"
    local task_name="${cmd%% *}"  # Extract first word as task name
    
    # Truncate long commands for cleaner display
    local cmd_shortened="${cmd}"
    if [ ${#cmd_shortened} -gt 100 ]; then
        cmd_shortened="${cmd_shortened:0:97}..."
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}     [DRY RUN] Would execute:${NC} $cmd_shortened"
        return 0
    fi

    echo -e "${BLUE}       Executing:${NC} $cmd_shortened"
    print_debug "Full command: $cmd"
    
    # Execute the command with timeout, capturing output and exit code
    local output
    local exit_code
    
    local spinner_active=false
    # Do not start spinner for commands that might prompt for password
    if [[ ! "$cmd" =~ ^sudo ]] && [[ ! "$cmd" =~ "brew update" ]] && [[ ! "$cmd" =~ "softwareupdate" ]]; then
        start_spinner # Start spinner before command execution
        spinner_active=true
    else
        print_info "Skipping spinner for command likely to prompt for input."
    fi

    if command -v timeout &>/dev/null; then
        output=$(timeout "$COMMAND_TIMEOUT" bash -c "$cmd" 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 124 ]; then
            print_error "Command timed out after ${COMMAND_TIMEOUT} seconds: $cmd_shortened"
            FAILED_TASKS+=("Timeout: $task_name")
            if [ "$spinner_active" = true ]; then stop_spinner; fi # Stop spinner on timeout if it was active
            return 1
        fi
    else
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
    fi
    
    if [ "$spinner_active" = true ]; then stop_spinner; fi # Stop spinner after command execution if it was active

    # Log output regardless of success or failure
    {
        echo "=== Command: $cmd ==="
        echo "Exit Code: $exit_code"
        echo "Output:"
        echo "$output"
        echo "========================"
        echo ""
    } >> "$LOG_FILE"

    if [ $exit_code -ne 0 ]; then
        print_error "Command failed with exit code $exit_code: $cmd_shortened"
        print_error "See log file for full output: $LOG_FILE"
        FAILED_TASKS+=("Failed: $task_name")
        return 1
    else
        COMPLETED_TASKS+=("$task_name")
        print_debug "Command completed successfully"
    fi
    return 0
}

check_dependency() {
    local dep="$1"
    local optional="${2:-false}"
    
    if ! command -v "$dep" &>/dev/null; then
        if [ "$optional" = true ]; then
            print_info "$dep not found (optional). Skipping related tasks."
        else
            print_warning "$dep not found. Skipping related tasks."
        fi
        SKIPPED_TASKS+=("Dependency not found: $dep")
        return 1
    fi
    print_debug "$dep found at $(command -v "$dep")"
    return 0
}

check_macos_version() {
    local current_version
    current_version=$(sw_vers -productVersion)
    local required_version="$MIN_MACOS_VERSION"
    
    if [ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -n1)" != "$required_version" ]; then
        print_error "macOS version $current_version is below minimum required version $required_version"
        return 1
    fi
    print_info "macOS version check passed: $current_version"
    return 0
}

check_disk_space() {
    local free_space_gb
    # More robust disk space check that works on different macOS versions
    if command -v df &>/dev/null; then
        # Try different df formats
        free_space_gb=$(df -h / | awk 'NR==2 {gsub(/[^0-9.]/, "", $4); print int($4)}' 2>/dev/null)
        
        # Fallback to different approach if the above fails
        if [ -z "$free_space_gb" ] || [ "$free_space_gb" -eq 0 ]; then
            free_space_gb=$(df / | awk 'NR==2 {print int($4/1024/1024)}' 2>/dev/null)
        fi
    fi
    
    # Final fallback using diskutil
    if [ -z "$free_space_gb" ] || [ "$free_space_gb" -eq 0 ]; then
        free_space_gb=$(diskutil info / | grep "Volume Free Space" | awk '{print int($4)}' 2>/dev/null)
    fi
    
    if [ -z "$free_space_gb" ] || [ "$free_space_gb" -eq 0 ]; then
        print_warning "Could not determine free disk space. Proceeding with caution."
        return 0
    fi
    
    if [ "$free_space_gb" -lt "$MIN_DISK_SPACE_GB" ]; then
        print_error "Insufficient disk space. Required: ${MIN_DISK_SPACE_GB}GB, Available: ${free_space_gb}GB"
        return 1
    fi
    
    print_info "Disk space check passed. Available: ${free_space_gb}GB"
    return 0
}

create_backup_point() {
    local backup_name="maintenance_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_dir="${HOME}/.maintenance_backups"
    
    if confirm_action "Create a backup point before starting maintenance?" "Y"; then
        mkdir -p "$backup_dir"
        # Create a simple backup manifest
        {
            echo "Backup created: $(date)"
            echo "System info: $(sw_vers -productVersion)"
            echo "Homebrew packages:"
            command -v brew &>/dev/null && brew list --formula 2>/dev/null || echo "Homebrew not installed"
            echo "Global npm packages:"
            command -v npm &>/dev/null && npm list -g --depth=0 2>/dev/null || echo "npm not installed"
        } > "$backup_dir/$backup_name.txt"
        print_success "Backup manifest created at $backup_dir/$backup_name.txt"
        COMPLETED_TASKS+=("Backup creation")
    else
        SKIPPED_TASKS+=("Backup creation")
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -y, --yes           Skip all confirmation prompts (auto-yes)
    -d, --dry-run       Show what would be done without executing
    -v, --verbose       Enable verbose output
    -h, --help          Show this help message
    
    --skip-system       Skip system updates
    --skip-homebrew     Skip Homebrew maintenance
    --skip-node         Skip Node.js maintenance
    --skip-python       Skip Python maintenance
    --skip-caches       Skip cache cleanup
    --skip-databases    Skip database maintenance
    
    --config FILE       Use custom configuration file
    --log-dir DIR       Set custom log directory

EXAMPLES:
    $0                  # Interactive mode
    $0 -y               # Auto-yes mode
    $0 -d               # Dry run mode
    $0 -y --skip-system # Skip system updates, auto-confirm others

CONFIGURATION:
    Create ~/.maintenance_config to customize default settings.
    
EOF
}

main() {
    # Load configuration
    load_config
    
    # Initial log entry
    {
        echo "macOS Developer Maintenance Script - V3.1.0"
        echo "Log started at $(date)"
        echo "Script arguments: $*"
        echo "Configuration loaded from: ${CONFIG_FILE}"
        echo "----------------------------------------"
    } | tee -a "$LOG_FILE"
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE ENABLED. No commands will be executed."
    fi
    if [ "$AUTO_YES" = true ]; then
        print_warning "AUTO-YES MODE ENABLED. All confirmations will be automatically accepted."
    fi
    if [ "$VERBOSE" = true ]; then
        print_info "VERBOSE MODE ENABLED."
    fi

    # -------------------------------
    # System Checks
    # -------------------------------
    print_section "Initial System Checks"
    
    # macOS Compatibility
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_info "macOS detected: $(sw_vers -productName) $(sw_vers -productVersion)"

    # Version check
    if ! check_macos_version; then
        exit 1
    fi

    # Disk space check
    if ! check_disk_space; then
        if ! confirm_action "Continue with insufficient disk space? This may cause issues."; then
            exit 1
        fi
    fi

    # Create backup point
    create_backup_point

    # -------------------------------
    # Maintenance Tasks
    # -------------------------------
    if [ "$SKIP_SYSTEM_UPDATES" != true ]; then
        print_section "System Updates & Package Management"

        print_subsection "macOS System Updates"
        if confirm_action "Install macOS system updates? This may require a restart." "Y"; then
            run_command "sudo softwareupdate -i -a --agree-to-license"
        else
            SKIPPED_TASKS+=("macOS system updates")
        fi
    fi

    # Homebrew
    if [ "$SKIP_HOMEBREW" != true ] && check_dependency "brew"; then
        print_subsection "Homebrew Maintenance"
        run_command "brew update"
        run_command "brew upgrade"
        run_command "brew autoremove"
        
        if confirm_action "Run 'brew cleanup -s' to remove all cached downloads?"; then
            run_command "brew cleanup -s"
        else
            SKIPPED_TASKS+=("Homebrew deep cleanup")
        fi
        
        run_command "brew doctor"
    fi

    # Node.js maintenance
    if [ "$SKIP_NODE" != true ]; then
        # npm
        if check_dependency "npm"; then
            print_subsection "Node.js (npm) Maintenance"
            run_command "npm update -g"
            run_command "npm cache clean --force"
        fi
        
        # pnpm
        if check_dependency "pnpm"; then
            print_subsection "pnpm Maintenance"
            run_command "pnpm self-update"
            run_command "pnpm store prune"
        fi
    fi

    # -------------------------------
    # Development Environment
    # -------------------------------
    print_section "Development Environment & Caches"
    
    # Version Managers (nvm, pyenv, rbenv)
    if [ "$SKIP_NODE" != true ]; then
        local NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            print_subsection "Node Version Manager (nvm)"
            source "$NVM_DIR/nvm.sh"
            if command -v nvm &>/dev/null; then
                run_command "nvm install --lts --latest-npm"
                if confirm_action "Set latest Node.js LTS as default?"; then
                    run_command "nvm alias default lts/*"
                    run_command "nvm use default"
                else
                    SKIPPED_TASKS+=("NVM set default alias")
                fi
                run_command "nvm cache clear"
            fi
        fi
    fi

    if [ "$SKIP_PYTHON" != true ] && check_dependency "pyenv"; then
        print_subsection "Python Version Manager (pyenv)"
        run_command "pyenv update"
        LATEST_PYTHON=$(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | sort -V | tail -1 | xargs)
        if [ -n "$LATEST_PYTHON" ]; then
            run_command "pyenv install --skip-existing $LATEST_PYTHON"
            if confirm_action "Set Python $LATEST_PYTHON as global version?"; then
                run_command "pyenv global $LATEST_PYTHON"
            else
                SKIPPED_TASKS+=("pyenv set global")
            fi
        fi
    fi

    # Cache Cleanup
    if [ "$SKIP_CACHES" != true ]; then
        print_subsection "Development Cache Cleanup"
        if confirm_action "Clean development tool caches (Gradle, CocoaPods, etc.)?"; then
            declare -a caches_to_clean=(
                "$HOME/.gradle/caches"
                "$HOME/Library/Caches/CocoaPods"
                "$HOME/.cache"
                "$HOME/Library/Caches/Homebrew"
                "$HOME/Library/Caches/pip"
                "$HOME/.npm/_cacache"
            )
            for cache_dir in "${caches_to_clean[@]}"; do
                if [ -d "$cache_dir" ]; then
                    print_info "Cleaning cache: $cache_dir"
                    run_command "rm -rf '$cache_dir'"
                fi
            done
        else
            SKIPPED_TASKS+=("Dev cache cleanup")
        fi
    fi

    # IDE Maintenance (VS Code)
    if check_dependency "code" true; then
        print_subsection "VS Code Maintenance"
        if confirm_action "Update all VS Code extensions?"; then
            print_info "Updating extensions. This may take a while..."
            # Better approach: update extensions without reinstalling
            run_command "code --list-extensions | xargs -I {} code --install-extension {} --force"
        else
            SKIPPED_TASKS+=("VS Code extension update")
        fi
    fi
    
    # -------------------------------
    # Database & Security
    # -------------------------------
    if [ "$SKIP_DATABASES" != true ]; then
        print_section "Database & Security"
        
        # Redis
        if check_dependency "redis-cli" true; then
            print_subsection "Redis Maintenance"
            if redis-cli PING &>/dev/null; then
                print_warning "Redis is running and contains data."
                if confirm_action "FLUSHALL Redis? THIS IS DESTRUCTIVE AND WILL DELETE ALL DATA."; then
                    run_command "redis-cli FLUSHALL"
                else
                    SKIPPED_TASKS+=("Redis FLUSHALL")
                fi
            else
                print_info "Redis server not responding to PING. Skipping."
                SKIPPED_TASKS+=("Redis maintenance (server not running)")
            fi
        fi
    fi

    # -------------------------------
    # System Maintenance
    # -------------------------------
    print_section "Final System Maintenance"
    
    # System Caches & Services
    print_subsection "System Services & Cache Flush"
    run_command "sudo dscacheutil -flushcache"
    run_command "sudo killall -HUP mDNSResponder"

    # Empty Trash
    if confirm_action "Empty user Trash?"; then
        if [ -d "$HOME/.Trash" ] && [ -n "$(ls -A "$HOME/.Trash" 2>/dev/null)" ]; then
            run_command "rm -rf '$HOME/.Trash/'*"
        else
            print_info "User Trash is already empty or does not exist."
        fi
    else
        SKIPPED_TASKS+=("Empty user Trash")
    fi

    # Run Custom Privacy Script (only once, fixed duplicate execution)
    if [ -f "$PRIVACY_SCRIPT_PATH" ]; then
        print_subsection "Executing Custom Privacy Script"
        if confirm_action "Run custom privacy script from '$PRIVACY_SCRIPT_PATH'?"; then
            run_command "bash '$PRIVACY_SCRIPT_PATH'"
        else
            SKIPPED_TASKS+=("Custom privacy script execution")
        fi
    else
        print_info "Custom privacy script not found at '$PRIVACY_SCRIPT_PATH', skipping."
        SKIPPED_TASKS+=("Custom privacy script (not found)")
    fi

    # -------------------------------
    # Finalization
    # -------------------------------
    print_section "Maintenance Complete"
    
    local script_end_time=$(date +%s)
    local script_duration=$((script_end_time - SCRIPT_START_TIME))
    local duration_formatted=$(printf "%02d:%02d:%02d" $((script_duration/3600)) $((script_duration%3600/60)) $((script_duration%60)))
    
    echo -e "\n${CYAN}=== EXECUTION SUMMARY ===${NC}"
    echo -e "${GREEN}✓ Completed Tasks (${#COMPLETED_TASKS[@]}):${NC}"
    for task in "${COMPLETED_TASKS[@]}"; do
        echo -e "  ✓ $task"
    done
    
    if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
        echo -e "\n${RED}✗ Failed Tasks (${#FAILED_TASKS[@]}):${NC}"
        for task in "${FAILED_TASKS[@]}"; do
            echo -e "  ✗ $task"
        done
    fi

    if [ ${#SKIPPED_TASKS[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}⊘ Skipped Tasks (${#SKIPPED_TASKS[@]}):${NC}"
        for task in "${SKIPPED_TASKS[@]}"; do
            echo -e "  ⊘ $task"
        done
    fi

    echo -e "\n${BLUE}📊 Statistics:${NC}"
    echo -e "  • Total execution time: $duration_formatted"
    echo -e "  • Completed: ${#COMPLETED_TASKS[@]} tasks"
    echo -e "  • Failed: ${#FAILED_TASKS[@]} tasks"
    echo -e "  • Skipped: ${#SKIPPED_TASKS[@]} tasks"
    echo -e "  • Log file: ${LOG_FILE}"
    
    # Final status
    if [ ${#FAILED_TASKS[@]} -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All maintenance tasks completed successfully!${NC}"
        exit_code=0
    else
        echo -e "\n${YELLOW}⚠️  Maintenance completed with some failures. Check the log for details.${NC}"
        exit_code=1
    fi
    
    # macOS notification
    if command -v osascript &>/dev/null; then
        local notification_text="Maintenance completed. ${#COMPLETED_TASKS[@]} tasks done"
        [ ${#FAILED_TASKS[@]} -gt 0 ] && notification_text+=", ${#FAILED_TASKS[@]} failed"
        osascript -e "display notification \"$notification_text\" with title \"macOS Maintenance Script\""
    fi
    
    echo -e "\n${GREEN}All operations finished.${NC}"
    exit $exit_code
}

# -------------------------------
# Script Execution Start
# -------------------------------

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        --skip-system)
            SKIP_SYSTEM_UPDATES=true
            shift
            ;;
        --skip-homebrew)
            SKIP_HOMEBREW=true
            shift
            ;;
        --skip-node)
            SKIP_NODE=true
            shift
            ;;
        --skip-python)
            SKIP_PYTHON=true
            shift
            ;;
        --skip-caches)
            SKIP_CACHES=true
            shift
            ;;
        --skip-databases)
            SKIP_DATABASES=true
            shift
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --log-dir)
            LOG_DIR="$2"
            LOG_FILE="${LOG_DIR}/maintenance_$(date +%Y%m%d_%H%M%S).log"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_usage
            exit 1
            ;;
    esac
done

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Redirect all output to log file and console
exec > >(tee -a "$LOG_FILE") 2>&1

# Call the main function to run the script
main "$@"