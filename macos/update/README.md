# macOS Developer Maintenance Script

This script is a comprehensive Bash script designed to automate common maintenance tasks for macOS developer machines. It focuses on keeping your system clean, updated, and optimized, with a strong emphasis on safety, user experience, and configurability.

## ✨ Features

- **System Updates:** Installs pending macOS system updates.
- **Homebrew Management:** Updates, upgrades, autoremoves, and cleans Homebrew packages.
- **Node.js (npm & pnpm) Maintenance:** Updates global Node.js packages and cleans caches.
- **Python (pyenv) Maintenance:** Updates pyenv and installs/sets the latest Python LTS version.
- **Development Cache Cleanup:** Clears caches for tools like Gradle, CocoaPods, npm, pip, and Homebrew.
- **VS Code Extension Updates:** Updates all installed VS Code extensions.
- **Redis Maintenance:** Offers to FLUSHALL Redis databases (with explicit confirmation).
- **System Cache & Services Flush:** Flushes DNS cache and restarts mDNSResponder.
- **Trash Emptying:** Prompts to empty the user's Trash.
- **Custom Privacy Script Execution:** Integrates and runs an optional custom privacy script.
- **Pre-flight Checks:** Verifies macOS compatibility, minimum OS version, and sufficient disk space.
- **Interactive Prompts:** Confirms destructive actions or significant changes.
- **Dry Run Mode:** Allows you to see what the script would do without making any changes.
- **Auto-Yes Mode:** Bypasses all confirmation prompts for automated execution.
- **Verbose Output:** Provides detailed debug information.
- **Configurable Options:** Customize behavior via command-line flags or a dedicated configuration file.
- **Loading Spinner:** Visual feedback for long-running commands.
- **Comprehensive Logging:** Records all script output, commands, and errors to a dedicated log file.
- **Execution Summary:** Provides a clear overview of completed, failed, and skipped tasks at the end.
- **macOS Notifications:** Notifies on script completion (success or with failures).

## 🚀 Installation

1. **Download the script:**

    ```bash
    cd macos/update/
    # If you haven't already, ensure you have the script in this directory.
    # For example: curl -O https://raw.githubusercontent.com/your-repo/your-script.sh
    ```

2. **Make it executable:**

    ```bash
    chmod +x maintenance.sh
    ```

## 💡 Usage

Run the script from your terminal:

```bash
./maintenance.sh [OPTIONS]
```

### Command-Line Options

| Option                | Description                                                                 |
| :-------------------- | :-------------------------------------------------------------------------- |
| `-y`, `--yes`         | Skip all confirmation prompts (auto-accepts all actions).                   |
| `-d`, `--dry-run`     | Shows what would be done without executing any commands.                    |
| `-v`, `--verbose`     | Enables verbose output for detailed debugging.                              |
| `-h`, `--help`        | Displays the help message and exits.                                        |
| `--skip-system`       | Skips macOS system updates.                                                 |
| `--skip-homebrew`     | Skips Homebrew maintenance tasks.                                           |
| `--skip-node`         | Skips Node.js (npm & pnpm) and NVM maintenance.                             |
| `--skip-python`       | Skips Python (pyenv) maintenance.                                           |
| `--skip-caches`       | Skips development tool cache cleanup.                                       |
| `--skip-databases`    | Skips database (e.g., Redis) maintenance.                                   |
| `--config FILE`       | Specifies a custom configuration file path.                                 |
| `--log-dir DIR`       | Sets a custom directory for log files.                                      |

### Examples

```bash
./maintenance.sh                   # Run interactively
./maintenance.sh -y                # Run with all confirmations automatically accepted
./maintenance.sh -d                # Perform a dry run to see planned actions
./maintenance.sh -y --skip-system  # Skip system updates, auto-confirm other actions
./maintenance.sh --log-dir ~/logs  # Save logs to a specific directory
```

## ⚙️ Configuration File

For persistent configuration, create a file named `.maintenance_config` in your home directory (`~/.maintenance_config`). This file will be loaded automatically if it exists.

Example `~/.maintenance_config`:

```bash
# Minimum disk space required in Gigabytes (default: 10)
MIN_DISK_SPACE_GB=15

# Default timeout for commands in seconds (default: 300 - 5 minutes)
COMMAND_TIMEOUT=600

# Path to your custom privacy script (default: ./privacy-script.sh relative to script)
# PRIVACY_SCRIPT_PATH="/Users/youruser/scripts/my-privacy.sh"

# Set to 'true' to skip specific sections by default
SKIP_SYSTEM_UPDATES=false
SKIP_HOMEBREW=false
SKIP_NODE=false
SKIP_PYTHON=false
SKIP_CACHES=false
SKIP_DATABASES=false
```

## 📄 Logging

All script output, including commands executed and their results, are logged to a file on your Desktop (or specified `--log-dir`). The log file name includes a timestamp (e.g., `~/Desktop/maintenance_YYYYMMDD_HHMMSS.log`).

## 💾 Backup Point

The script offers to create a simple backup manifest at the start of execution (by default, in `~/.maintenance_backups/`). This manifest includes basic system info, Homebrew packages, and global npm packages to provide a snapshot of your system before major changes.

## ⚠️ Important Notes

- **`sudo` prompts:** Some operations (like system updates, Homebrew updates, or flushing system caches) require `sudo` and will prompt you for your password. The spinner is intentionally disabled for these commands.
- **Destructive Actions:** Be cautious with actions like `redis-cli FLUSHALL` or "Empty user Trash". These are explicitly confirmed during interactive runs.
- **Internet Connection:** An active internet connection is required for updates (macOS, Homebrew, Node.js, Python, VS Code extensions).
- **Privacy Script:** Ensure your `privacy-script.sh` is located at the configured `PRIVACY_SCRIPT_PATH` and is executable.

---
**Version:** 3.1.0
