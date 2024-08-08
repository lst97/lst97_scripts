#!/bin/bash

# Function to print section headers
print_header() {
    echo "===== $1 ====="
}

# Function to run a command and check its exit status
run_command() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Error: $1 failed" >&2
        return $status
    fi
    return 0
}

# Update macOS
print_header "UPDATING MACOS"
run_command sudo softwareupdate -i -a

# Update Homebrew and its packages
print_header "UPDATING BREW"
run_command brew update
run_command brew upgrade
run_command brew cleanup
echo "Brew update and cleanup complete"

# Update Node.js packages
print_header "UPDATING NODEJS PACKAGES"
run_command npm update -g

# Clear npm cache
print_header "CLEARING NPM CACHE"
run_command npm cache clean --force
echo "npm update and cache clean complete"

# Update Ruby gems
print_header "UPDATING RUBY GEMS"
run_command gem update --system

#Clear gem cache
print_header "CLEARING GEM CACHE"
run_command gem cleanup
echo "gem update and cleanup complete"

# Update pip packages (global)
print_header "UPDATING PIP PACKAGES [GLOBAL]"
run_command pip install --upgrade pip
run_command pip --disable-pip-version-check list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip install -U

# Update Conda environments
update_conda_env() {
    local env_name=$1
    print_header "UPDATING CONDA ENVIRONMENT [$env_name]"
    run_command conda activate $env_name
    run_command conda update --all -y
    run_command conda update python -y
    run_command pip --disable-pip-version-check list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip install -U
    run_command conda deactivate
}

# Source conda
source ~/miniconda3/etc/profile.d/conda.sh

# Update base conda environment
update_conda_env base

# Update custom conda environment (replace 'myenv' with your environment name)
update_conda_env conda

# Clear conda cache
print_header "CLEARING CONDA CACHE"
run_command conda clean --all -y
run_command pip cache purge
run_command sudo rm -rf ~/.cache/pip

# Update Mac App Store apps
print_header "UPDATING MAC APP STORE APPS"
if command -v mas &> /dev/null; then
    run_command mas upgrade
else
    echo "mas (Mac App Store command line interface) is not installed. Skipping App Store updates."
fi

# Run MacUpdater
print_header "RUNNING MACUPDATER"
if [ -f "/Applications/MacUpdater.app/Contents/Resources/macupdater_client" ]; then
    run_command /Applications/MacUpdater.app/Contents/Resources/macupdater_client scan
    run_command /Applications/MacUpdater.app/Contents/Resources/macupdater_client update --force-quit-running-apps --force-major-version-update --force-replace-mas-with-nonmas-update
else
    echo "MacUpdater not found. Skipping MacUpdater updates."
fi

# Flush DNS cache
print_header "FLUSHING DNS CACHE"
run_command sudo dscacheutil -flushcache
run_command sudo killall -HUP mDNSResponder
echo "All updates and maintenance tasks have been completed."

# Empty trash securely
print_header "EMPTYING TRASH SECURELY"
run_command rm -rfv ~/.Trash/*
echo "Trash has been emptied securely."

print_header "UPDATE COMPLETE"
echo "Press enter to quit"
read
