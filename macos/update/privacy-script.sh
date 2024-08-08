#!/usr/bin/env bash
# https://privacy.sexy — v0.13.5 — Thu, 08 Aug 2024 04:13:40 GMT
if [ "$EUID" -ne 0 ]; then
    script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
    sudo "$script_path" || (
        echo 'Administrator privileges are required.'
        exit 1
    )
    exit 0
fi


# ----------------------------------------------------------
# ---------------Clear CUPS printer job cache---------------
# ----------------------------------------------------------
echo '--- Clear CUPS printer job cache'
sudo rm -rfv /var/spool/cups/c0*
sudo rm -rfv /var/spool/cups/tmp/*
sudo rm -rfv /var/spool/cups/cache/job.cache*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Empty trash on all volumes----------------
# ----------------------------------------------------------
echo '--- Empty trash on all volumes'
# on all mounted volumes
sudo rm -rfv /Volumes/*/.Trashes/* &>/dev/null
# on main HDD
sudo rm -rfv ~/.Trash/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear system cache--------------------
# ----------------------------------------------------------
echo '--- Clear system cache'
sudo rm -rfv /Library/Caches/* &>/dev/null
sudo rm -rfv /System/Library/Caches/* &>/dev/null
sudo rm -rfv ~/Library/Caches/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Clear Xcode's derived data and archives----------
# ----------------------------------------------------------
echo '--- Clear Xcode'\''s derived data and archives'
rm -rfv ~/Library/Developer/Xcode/DerivedData/* &>/dev/null
rm -rfv ~/Library/Developer/Xcode/Archives/* &>/dev/null
rm -rfv ~/Library/Developer/Xcode/iOS Device Logs/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------------Clear DNS cache----------------------
# ----------------------------------------------------------
echo '--- Clear DNS cache'
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear inactive memory-------------------
# ----------------------------------------------------------
echo '--- Clear inactive memory'
sudo purge
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Disable Firefox telemetry-----------------
# ----------------------------------------------------------
echo '--- Disable Firefox telemetry'
# Enable Firefox policies so the telemetry can be configured.
sudo defaults write /Library/Preferences/org.mozilla.firefox EnterprisePoliciesEnabled -bool TRUE
# Disable sending usage data
sudo defaults write /Library/Preferences/org.mozilla.firefox DisableTelemetry -bool TRUE
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable Microsoft Office telemetry------------
# ----------------------------------------------------------
echo '--- Disable Microsoft Office telemetry'
defaults write com.microsoft.office DiagnosticDataTypePreference -string ZeroDiagnosticData
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Remove Google Software Update service-----------
# ----------------------------------------------------------
echo '--- Remove Google Software Update service'
googleUpdateFile=~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall
if [ -f "$googleUpdateFile" ]; then
    $googleUpdateFile --nuke
    echo 'Uninstalled Google update'
else
    echo 'Google update file does not exist'
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Disable Homebrew user behavior analytics---------
# ----------------------------------------------------------
echo '--- Disable Homebrew user behavior analytics'
command='export HOMEBREW_NO_ANALYTICS=1'
declare -a profile_files=("$HOME/.bash_profile" "$HOME/.zprofile")
for profile_file in "${profile_files[@]}"
do
    touch "$profile_file"
    if ! grep -q "$command" "${profile_file}"; then
        echo "$command" >> "$profile_file"
        echo "[$profile_file] Configured"
    else
        echo "[$profile_file] No need for any action, already configured"
    fi
done
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Disable NET Core CLI telemetry--------------
# ----------------------------------------------------------
echo '--- Disable NET Core CLI telemetry'
command='export DOTNET_CLI_TELEMETRY_OPTOUT=1'
declare -a profile_files=("$HOME/.bash_profile" "$HOME/.zprofile")
for profile_file in "${profile_files[@]}"
do
    touch "$profile_file"
    if ! grep -q "$command" "${profile_file}"; then
        echo "$command" >> "$profile_file"
        echo "[$profile_file] Configured"
    else
        echo "[$profile_file] No need for any action, already configured"
    fi
done
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable PowerShell Core telemetry-------------
# ----------------------------------------------------------
echo '--- Disable PowerShell Core telemetry'
command='export POWERSHELL_TELEMETRY_OPTOUT=1'
declare -a profile_files=("$HOME/.bash_profile" "$HOME/.zprofile")
for profile_file in "${profile_files[@]}"
do
    touch "$profile_file"
    if ! grep -q "$command" "${profile_file}"; then
        echo "$command" >> "$profile_file"
        echo "[$profile_file] Configured"
    else
        echo "[$profile_file] No need for any action, already configured"
    fi
done
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Disable remote Apple events----------------
# ----------------------------------------------------------
echo '--- Disable remote Apple events'
sudo systemsetup -setremoteappleevents off
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable automatic storage of documents in iCloud Drive--
# ----------------------------------------------------------
echo '--- Disable automatic storage of documents in iCloud Drive'
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# ----------------------------------------------------------


# Disable personalized advertisements and identifier tracking
echo '--- Disable personalized advertisements and identifier tracking'
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib forceLimitAdTracking -bool true
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable captive portal detection-------------
# ----------------------------------------------------------
echo '--- Disable captive portal detection'
sudo defaults write '/Library/Preferences/SystemConfiguration/com.apple.captive.control.plist' Active -bool false
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear bash history--------------------
# ----------------------------------------------------------
echo '--- Clear bash history'
rm -f ~/.bash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear zsh history---------------------
# ----------------------------------------------------------
echo '--- Clear zsh history'
rm -f ~/.zsh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Apple System Logs (ASL)---------------
# ----------------------------------------------------------
echo '--- Clear Apple System Logs (ASL)'
# Clear directory contents: "/private/var/log/asl"
glob_pattern="/private/var/log/asl/*"
sudo rm -rfv $glob_pattern
# Delete files matching pattern: "/private/var/log/asl.log"
glob_pattern="/private/var/log/asl.log"
sudo rm -fv $glob_pattern
# Delete files matching pattern: "/private/var/log/asl.db"
glob_pattern="/private/var/log/asl.db"
sudo rm -fv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear installation logs------------------
# ----------------------------------------------------------
echo '--- Clear installation logs'
# Delete files matching pattern: "/private/var/log/install.log"
glob_pattern="/private/var/log/install.log"
sudo rm -fv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear all system logs-------------------
# ----------------------------------------------------------
echo '--- Clear all system logs'
# Clear directory contents: "/private/var/log"
glob_pattern="/private/var/log/*"
sudo rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear system application logs---------------
# ----------------------------------------------------------
echo '--- Clear system application logs'
# Clear directory contents: "/Library/Logs"
glob_pattern="/Library/Logs/*"
sudo rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear user application logs----------------
# ----------------------------------------------------------
echo '--- Clear user application logs'
# Clear directory contents: "$HOME/Library/Logs"
glob_pattern="$HOME/Library/Logs/*"
 rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Mail app logs--------------------
# ----------------------------------------------------------
echo '--- Clear Mail app logs'
# Clear directory contents: "$HOME/Library/Containers/com.apple.mail/Data/Library/Logs/Mail"
glob_pattern="$HOME/Library/Containers/com.apple.mail/Data/Library/Logs/Mail/*"
 rm -rfv $glob_pattern
# ----------------------------------------------------------


# Clear user activity audit logs (login, logout, authentication, etc.)
echo '--- Clear user activity audit logs (login, logout, authentication, etc.)'
# Clear directory contents: "/private/var/audit"
glob_pattern="/private/var/audit/*"
sudo rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear system maintenance logs---------------
# ----------------------------------------------------------
echo '--- Clear system maintenance logs'
# Delete files matching pattern: "/private/var/log/daily.out"
glob_pattern="/private/var/log/daily.out"
sudo rm -fv $glob_pattern
# Delete files matching pattern: "/private/var/log/weekly.out"
glob_pattern="/private/var/log/weekly.out"
sudo rm -fv $glob_pattern
# Delete files matching pattern: "/private/var/log/monthly.out"
glob_pattern="/private/var/log/monthly.out"
sudo rm -fv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear app installation logs----------------
# ----------------------------------------------------------
echo '--- Clear app installation logs'
# Clear directory contents: "/private/var/db/receipts"
glob_pattern="/private/var/db/receipts/*"
sudo rm -rfv $glob_pattern
# Delete files matching pattern: "/Library/Receipts/InstallHistory.plist"
glob_pattern="/Library/Receipts/InstallHistory.plist"
 rm -fv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Adobe cache---------------------
# ----------------------------------------------------------
echo '--- Clear Adobe cache'
sudo rm -rfv ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Gradle cache--------------------
# ----------------------------------------------------------
echo '--- Clear Gradle cache'
if [ -d "~/.gradle/caches" ]; then
    rm -rfv ~/.gradle/caches/ &> /dev/null
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Dropbox cache--------------------
# ----------------------------------------------------------
echo '--- Clear Dropbox cache'
if [ -d "~/Dropbox/.dropbox.cache" ]; then
    sudo rm -rfv ~/Dropbox/.dropbox.cache/* &>/dev/null
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Clear Google Drive File Stream cache-----------
# ----------------------------------------------------------
echo '--- Clear Google Drive File Stream cache'
killall "Google Drive File Stream"
rm -rfv ~/Library/Application\ Support/Google/DriveFS/[0-9a-zA-Z]*/content_cache &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Composer cache-------------------
# ----------------------------------------------------------
echo '--- Clear Composer cache'
if type "composer" &> /dev/null; then
    composer clearcache &> /dev/null
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Homebrew cache-------------------
# ----------------------------------------------------------
echo '--- Clear Homebrew cache'
if type "brew" &>/dev/null; then
    brew cleanup -s &>/dev/null
    rm -rfv $(brew --cache) &>/dev/null
    brew tap --repair &>/dev/null
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear old Ruby gem versions----------------
# ----------------------------------------------------------
echo '--- Clear old Ruby gem versions'
if type "gem" &> /dev/null; then
    gem cleanup &>/dev/null
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear unused Docker data-----------------
# ----------------------------------------------------------
echo '--- Clear unused Docker data'
if type "docker" &> /dev/null; then
    docker system prune -af
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Pyenv-Virtualenv cache---------------
# ----------------------------------------------------------
echo '--- Clear Pyenv-Virtualenv cache'
if [ "$PYENV_VIRTUALENV_CACHE_PATH" ]; then
    rm -rfv $PYENV_VIRTUALENV_CACHE_PATH &>/dev/null
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------------Clear NPM cache----------------------
# ----------------------------------------------------------
echo '--- Clear NPM cache'
if type "npm" &> /dev/null; then
    npm cache clean --force
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------------Clear Yarn cache---------------------
# ----------------------------------------------------------
echo '--- Clear Yarn cache'
if type "yarn" &> /dev/null; then
    echo 'Cleanup Yarn Cache...'
    yarn cache clean --force
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear iOS app copies from iTunes-------------
# ----------------------------------------------------------
echo '--- Clear iOS app copies from iTunes'
rm -rfv ~/Music/iTunes/iTunes\ Media/Mobile\ Applications/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear iOS photo cache-------------------
# ----------------------------------------------------------
echo '--- Clear iOS photo cache'
rm -rf ~/Pictures/iPhoto\ Library/iPod\ Photo\ Cache/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear iOS Device Backups-----------------
# ----------------------------------------------------------
echo '--- Clear iOS Device Backups'
rm -rfv ~/Library/Application\ Support/MobileSync/Backup/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear iOS simulators-------------------
# ----------------------------------------------------------
echo '--- Clear iOS simulators'
if type "xcrun" &>/dev/null; then
    osascript -e 'tell application "com.apple.CoreSimulator.CoreSimulatorService" to quit'
    osascript -e 'tell application "iOS Simulator" to quit'
    osascript -e 'tell application "Simulator" to quit'
    xcrun simctl shutdown all
    xcrun simctl erase all
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Clear list of connected iOS devices------------
# ----------------------------------------------------------
echo '--- Clear list of connected iOS devices'
sudo defaults delete /Users/$USER/Library/Preferences/com.apple.iPod.plist "conn:128:Last Connect"
sudo defaults delete /Users/$USER/Library/Preferences/com.apple.iPod.plist Devices
sudo defaults delete /Library/Preferences/com.apple.iPod.plist "conn:128:Last Connect"
sudo defaults delete /Library/Preferences/com.apple.iPod.plist Devices
sudo rm -rfv /var/db/lockdown/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Clear "Speech Recognition" permissions----------
# ----------------------------------------------------------
echo '--- Clear "Speech Recognition" permissions'
if ! command -v 'tccutil' &> /dev/null; then
    echo 'Skipping because "tccutil" is not found.'
else
    declare serviceId='SpeechRecognition'
declare reset_output reset_exit_code
{
    reset_output=$(tccutil reset "$serviceId" 2>&1)
    reset_exit_code=$?
}
if [ $reset_exit_code -eq 0 ]; then
    echo "Successfully reset permissions for \"${serviceId}\"."
elif [ $reset_exit_code -eq 70 ]; then
    echo "Skipping, service ID \"${serviceId}\" is not supported on your operating system version."
elif [ $reset_exit_code -ne 0 ]; then
    >&2 echo "Failed to reset permissions for \"${serviceId}\". Exit code: $reset_exit_code."
    if [ -n "$reset_output" ]; then
        echo "Output from \`tccutil\`: $reset_output."
    fi
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear diagnostic logs-------------------
# ----------------------------------------------------------
echo '--- Clear diagnostic logs'
# Clear directory contents: "/private/var/db/diagnostics"
glob_pattern="/private/var/db/diagnostics/*"
sudo rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear diagnostic log details---------------
# ----------------------------------------------------------
echo '--- Clear diagnostic log details'
# Clear directory contents: "/private/var/db/uuidtext"
glob_pattern="/private/var/db/uuidtext/*"
sudo rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable remote management service-------------
# ----------------------------------------------------------
echo '--- Disable remote management service'
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Remove Apple Remote Desktop Settings-----------
# ----------------------------------------------------------
echo '--- Remove Apple Remote Desktop Settings'
sudo rm -rf /var/db/RemoteManagement
sudo defaults delete /Library/Preferences/com.apple.RemoteDesktop.plist
defaults delete ~/Library/Preferences/com.apple.RemoteDesktop.plist
sudo rm -rf /Library/Application\ Support/Apple/Remote\ Desktop/
rm -r ~/Library/Application\ Support/Remote\ Desktop/
rm -r ~/Library/Containers/com.apple.RemoteDesktop
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Enable application firewall----------------
# ----------------------------------------------------------
echo '--- Enable application firewall'
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo defaults write /Library/Preferences/com.apple.alf globalstate -bool true
defaults write com.apple.security.firewall EnableFirewall -bool true
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Enable firewall logging------------------
# ----------------------------------------------------------
echo '--- Enable firewall logging'
/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Enable stealth mode--------------------
# ----------------------------------------------------------
echo '--- Enable stealth mode'
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true
defaults write com.apple.security.firewall EnableStealthMode -bool true
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Disable incoming SSH and SFTP remote logins--------
# ----------------------------------------------------------
echo '--- Disable incoming SSH and SFTP remote logins'
echo 'yes' | sudo systemsetup -setremotelogin off
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable the insecure TFTP service-------------
# ----------------------------------------------------------
echo '--- Disable the insecure TFTP service'
sudo launchctl disable 'system/com.apple.tftpd'
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Disable Bonjour multicast advertising-----------
# ----------------------------------------------------------
echo '--- Disable Bonjour multicast advertising'
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable insecure telnet protocol-------------
# ----------------------------------------------------------
echo '--- Disable insecure telnet protocol'
sudo launchctl disable system/com.apple.telnetd
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----Disable local printer sharing with other computers----
# ----------------------------------------------------------
echo '--- Disable local printer sharing with other computers'
cupsctl --no-share-printers
# ----------------------------------------------------------


# Disable printing from external addresses, including the internet
echo '--- Disable printing from external addresses, including the internet'
cupsctl --no-remote-any
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Disable remote printer administration-----------
# ----------------------------------------------------------
echo '--- Disable remote printer administration'
cupsctl --no-remote-admin
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable automatic incoming connections for signed apps--
# ----------------------------------------------------------
echo '--- Disable automatic incoming connections for signed apps'
sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool false
# ----------------------------------------------------------


# Disable automatic incoming connections for downloaded signed apps
echo '--- Disable automatic incoming connections for downloaded signed apps'
sudo defaults write /Library/Preferences/com.apple.alf allowdownloadsignedenabled -bool false
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Clear logs of all downloaded files from File Quarantine--
# ----------------------------------------------------------
echo '--- Clear logs of all downloaded files from File Quarantine'
db_file=~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
db_query='delete from LSQuarantineEvent'
if [ -f "$db_file" ]; then
    echo "Database exists at \"$db_file\""
    if ls -lO "$db_file" | grep --silent 'schg'; then
        sudo chflags noschg "$db_file"
        echo "Found and removed system immutable flag"
        has_system_immutable_flag=true
    fi
    if ls -lO "$db_file" | grep --silent 'uchg'; then
        sudo chflags nouchg "$db_file"
        echo "Found and removed user immutable flag"
        has_user_immutable_flag=true
    fi
    sqlite3 "$db_file" "$db_query"
    echo "Executed the query \"$db_query\""
    if [ "$has_system_immutable_flag" = true ] ; then
        sudo chflags schg "$db_file"
        echo "Added system immutable flag back"
    fi
    if [ "$has_user_immutable_flag" = true ] ; then
        sudo chflags uchg "$db_file"
        echo "Added user immutable flag back"
    fi
else
    echo "No action needed, database does not exist at \"$db_file\""
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Disable downloaded file logging in quarantine-------
# ----------------------------------------------------------
echo '--- Disable downloaded file logging in quarantine'
file_to_lock=~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
if [ -f "$file_to_lock" ]; then
    sudo chflags schg "$file_to_lock"
    echo "Made file immutable at \"$file_to_lock\""
else
    echo "No action is needed, file does not exist at \"$file_to_lock\""
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Chrome browsing history---------------
# ----------------------------------------------------------
echo '--- Clear Chrome browsing history'
rm -rfv ~/Library/Application\ Support/Google/Chrome/Default/History &>/dev/null
rm -rfv ~/Library/Application\ Support/Google/Chrome/Default/History-journal &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Chrome cache--------------------
# ----------------------------------------------------------
echo '--- Clear Chrome cache'
sudo rm -rfv ~/Library/Application\ Support/Google/Chrome/Default/Application\ Cache/* &>/dev/null
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Clear Safari cached blobs, URLs and timestamps------
# ----------------------------------------------------------
echo '--- Clear Safari cached blobs, URLs and timestamps'
rm -f ~/Library/Caches/com.apple.Safari/Cache.db
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Clear Safari URL bar web page icons------------
# ----------------------------------------------------------
echo '--- Clear Safari URL bar web page icons'
rm -f ~/Library/Safari/WebpageIcons.db
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------Clear Safari webpage previews (thumbnails)--------
# ----------------------------------------------------------
echo '--- Clear Safari webpage previews (thumbnails)'
rm -rfv ~/Library/Caches/com.apple.Safari/Webpage\ Previews
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Safari browsing history---------------
# ----------------------------------------------------------
echo '--- Clear Safari browsing history'
rm -f ~/Library/Safari/History.db
rm -f ~/Library/Safari/History.db-lock
rm -f ~/Library/Safari/History.db-shm
rm -f ~/Library/Safari/History.db-wal
# For older versions of Safari
rm -f ~/Library/Safari/History.plist # URL, visit count, webpage title, last visited timestamp, redirected URL, autocomplete
rm -f ~/Library/Safari/HistoryIndex.sk # History index
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Safari downloads history--------------
# ----------------------------------------------------------
echo '--- Clear Safari downloads history'
rm -f ~/Library/Safari/Downloads.plist
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Clear Safari frequently visited sites-----------
# ----------------------------------------------------------
echo '--- Clear Safari frequently visited sites'
rm -f ~/Library/Safari/TopSites.plist
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Clear Safari last session (open tabs) history-------
# ----------------------------------------------------------
echo '--- Clear Safari last session (open tabs) history'
rm -f ~/Library/Safari/LastSession.plist
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Clear Safari history copy-----------------
# ----------------------------------------------------------
echo '--- Clear Safari history copy'
rm -rfv ~/Library/Caches/Metadata/Safari/History
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Clear search term history embedded in Safari preferences-
# ----------------------------------------------------------
echo '--- Clear search term history embedded in Safari preferences'
defaults write ~/Library/Preferences/com.apple.Safari RecentSearchStrings '( )'
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Safari cookies-------------------
# ----------------------------------------------------------
echo '--- Clear Safari cookies'
rm -f ~/Library/Cookies/Cookies.binarycookies
# Used before Safari 5.1
rm -f ~/Library/Cookies/Cookies.plist
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Clear Safari zoom level preferences per site-------
# ----------------------------------------------------------
echo '--- Clear Safari zoom level preferences per site'
rm -f ~/Library/Safari/PerSiteZoomPreferences.plist
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Clear allowed URLs for Safari notifications--------
# ----------------------------------------------------------
echo '--- Clear allowed URLs for Safari notifications'
rm -f ~/Library/Safari/UserNotificationPreferences.plist
# ----------------------------------------------------------


# Clear Safari preferences for downloads, geolocation, pop-ups, and autoplay per site
echo '--- Clear Safari preferences for downloads, geolocation, pop-ups, and autoplay per site'
rm -f ~/Library/Safari/PerSitePreferences.db
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear Firefox cache--------------------
# ----------------------------------------------------------
echo '--- Clear Firefox cache'
sudo rm -rf ~/Library/Caches/Mozilla/
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/netpredictions.sqlite
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Clear Firefox form history----------------
# ----------------------------------------------------------
echo '--- Clear Firefox form history'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/formhistory.sqlite
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/formhistory.dat
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear Firefox site preferences--------------
# ----------------------------------------------------------
echo '--- Clear Firefox site preferences'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/content-prefs.sqlite
# ----------------------------------------------------------


# Clear Firefox session restore data (loads after the browser closes or crashes)
echo '--- Clear Firefox session restore data (loads after the browser closes or crashes)'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionCheckpoints.json
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore*.js*
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore.bak*
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore-backups/previous.js*
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore-backups/recovery.js*
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore-backups/recovery.bak*
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore-backups/previous.bak*
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/sessionstore-backups/upgrade.js*-20*
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Clear Firefox passwords------------------
# ----------------------------------------------------------
echo '--- Clear Firefox passwords'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/signons.txt
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/signons2.txt
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/signons3.txt
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/signons.sqlite
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/logins.json
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Firefox HTML5 cookies----------------
# ----------------------------------------------------------
echo '--- Clear Firefox HTML5 cookies'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/webappsstore.sqlite
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Clear Firefox crash reports----------------
# ----------------------------------------------------------
echo '--- Clear Firefox crash reports'
rm -rfv ~/Library/Application\ Support/Firefox/Crash\ Reports/
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/minidumps/*.dmp
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Clear Firefox backup files----------------
# ----------------------------------------------------------
echo '--- Clear Firefox backup files'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/bookmarkbackups/*.json
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/bookmarkbackups/*.jsonlz4
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Clear Firefox cookies-------------------
# ----------------------------------------------------------
echo '--- Clear Firefox cookies'
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/cookies.txt
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/cookies.sqlite
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/cookies.sqlite-shm
rm -fv ~/Library/Application\ Support/Firefox/Profiles/*/cookies.sqlite-wal
rm -rfv ~/Library/Application\ Support/Firefox/Profiles/*/storage/default/http*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear privacy.sexy script history-------------
# ----------------------------------------------------------
echo '--- Clear privacy.sexy script history'
# Clear directory contents: "$HOME/Library/Application Support/privacy.sexy/runs"
glob_pattern="$HOME/Library/Application Support/privacy.sexy/runs/*"
 rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear privacy.sexy activity logs-------------
# ----------------------------------------------------------
echo '--- Clear privacy.sexy activity logs'
# Clear directory contents: "$HOME/Library/Logs/privacy.sexy"
glob_pattern="$HOME/Library/Logs/privacy.sexy/*"
 rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Disable Parallels Desktop advertisements---------
# ----------------------------------------------------------
echo '--- Disable Parallels Desktop advertisements'
defaults write 'com.parallels.Parallels Desktop' 'ProductPromo.ForcePromoOff' -bool yes
defaults write 'com.parallels.Parallels Desktop' 'WelcomeScreenPromo.PromoOff' -bool yes
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Disable "Ask Siri"--------------------
# ----------------------------------------------------------
echo '--- Disable "Ask Siri"'
defaults write com.apple.assistant.support 'Assistant Enabled' -bool false
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Disable Siri voice feedback----------------
# ----------------------------------------------------------
echo '--- Disable Siri voice feedback'
defaults write com.apple.assistant.backedup 'Use device speaker for TTS' -int 3
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Disable Siri services (Siri and assistantd)--------
# ----------------------------------------------------------
echo '--- Disable Siri services (Siri and assistantd)'
launchctl disable "user/$UID/com.apple.assistantd"
launchctl disable "gui/$UID/com.apple.assistantd"
sudo launchctl disable 'system/com.apple.assistantd'
launchctl disable "user/$UID/com.apple.Siri.agent"
launchctl disable "gui/$UID/com.apple.Siri.agent"
sudo launchctl disable 'system/com.apple.Siri.agent'
if [ $(/usr/bin/csrutil status | awk '/status/ {print $5}' | sed 's/\.$//') = "enabled" ]; then
    >&2 echo 'This script requires SIP to be disabled. Read more: https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection'
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Disable "Do you want to enable Siri?" pop-up-------
# ----------------------------------------------------------
echo '--- Disable "Do you want to enable Siri?" pop-up'
defaults write com.apple.SetupAssistant 'DidSeeSiriSetup' -bool True
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove Siri from menu bar-----------------
# ----------------------------------------------------------
echo '--- Remove Siri from menu bar'
defaults write com.apple.systemuiserver 'NSStatusItem Visible Siri' 0
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------------Remove Siri from status menu---------------
# ----------------------------------------------------------
echo '--- Remove Siri from status menu'
defaults write com.apple.Siri 'StatusMenuVisible' -bool false
defaults write com.apple.Siri 'UserHasDeclinedEnable' -bool true
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Disable participation in Siri data collection-------
# ----------------------------------------------------------
echo '--- Disable participation in Siri data collection'
defaults write com.apple.assistant.support 'Siri Data Sharing Opt-In Status' -int 2
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------Disable display of recent applications on Dock------
# ----------------------------------------------------------
echo '--- Disable display of recent applications on Dock'
defaults write com.apple.dock show-recents -bool false
# ----------------------------------------------------------


echo 'Your privacy and security is now hardened 🎉💪'
echo 'Press any key to exit.'
read -n 1 -s