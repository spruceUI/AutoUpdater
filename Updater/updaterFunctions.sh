APP_DIR="/mnt/SDCARD/App"

acknowledge(){
    local messages_file="/var/log/messages"
	echo "ACKNOWLEDGE $(date +%s)" >> "$messages_file"

    while true; do
        last_line=$(tail -n 1 "$messages_file")

        case "$last_line" in
            *"enter_pressed"*|*"key 1 57"*|*"key 1 29"*)
                echo "ACKNOWLEDGED $(date +%s)" >> "$messages_file"
                break
                ;;
        esac

        sleep 0.1
    done
}

boost_processing() {
    /mnt/SDCARD/miyoo/utils/utils "performance" 4 1344 384 1080 1
    echo "CPU Mode set to PERFORMANCE"
    echo 1 >/sys/devices/system/cpu/cpu0/online 2>/dev/null
    echo 1 >/sys/devices/system/cpu/cpu1/online 2>/dev/null
    echo 1 >/sys/devices/system/cpu/cpu2/online 2>/dev/null
    echo 1 >/sys/devices/system/cpu/cpu3/online 2>/dev/null
    chmod a+w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
	echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
    chmod a-w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
}

check_for_update_file() {
    echo "Searching for update file"
    UPDATE_FILE=$(find /mnt/SDCARD/ -maxdepth 1 -name "spruceV*.7z" | awk -F'V' '{print $2, $0}' | sort -n | tail -n1 | cut -d' ' -f2-)
    echo "Found update file: $UPDATE_FILE"

    if [ -z "$UPDATE_FILE" ]; then
        echo "No update file found"
        return 1
    fi
    return 0
}

check_installation_validity() {
    # Check if .tmp_update folder exists
    if [ ! -d "/mnt/SDCARD/.tmp_update" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: .tmp_update folder does not exist"
        return 1
    fi

    # Check if .tmp_update/updater file exists
    if [ ! -f "/mnt/SDCARD/.tmp_update/updater" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: .tmp_update/updater file does not exist"
        return 1
    fi

    # Both files exist, installation is valid
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Installation appears to be valid"
    return 0
}

kill_network_services() {
    killall -9 dropbear
    killall -9 smbd
    killall -9 sftpgo
    killall -9 syncthing
}

OLD_DIR="/mnt/SDCARD/RetroArch/.retroarch/BIOS"
NEW_DIR="/mnt/SDCARD/BIOS"
move_legacy_bios() {
    if [ -d "$OLD_DIR" ]; then
        mkdir -p "$NEW_DIR"

        # Move all contents, including hidden files and subdirectories
        cd "$OLD_DIR" || exit 1
        find . -mindepth 1 -exec sh -c '
        for item do
            if [ -e "$item" ]; then
                dir=$(dirname "$item")
                mkdir -p "'"$NEW_DIR"'/$dir"
                mv "$item" "'"$NEW_DIR"'/$item"
            fi
        done
    ' sh {} +
    fi
}

read_only_check() {
    if [ $(mount | grep SDCARD | cut -d"(" -f 2 | cut -d"," -f1 ) == "ro" ]; then
        mount -o remount,rw /dev/mmcblk0p1 /mnt/SDCARD
    fi
}

verify_7z_content() {
    local archive="$1"
    local required_dirs=".tmp_update App spruce"
    local missing_dirs=""

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Verifying update file contents"

    # List contents of the archive and save to a temporary file
    local temp_list=$(mktemp)
    7zr l "$archive" >"$temp_list"

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Archive contents:"
    cat "$temp_list"

    # Adding a skip for now
    #return 0

    for dir in $required_dirs; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Searching for directory: $dir"
        if grep -q "^.*D.*[[:space:]]$dir$" "$temp_list"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Found directory: $dir"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Directory not found: $dir"
            missing_dirs="$missing_dirs $dir"
        fi
    done

    rm -f "$temp_list"

    if [ -n "$missing_dirs" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Required director(ies)$missing_dirs not found in 7z file"
        return 1
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - All required directories found in 7z file"
    return 0
}

save_app_states() {
    local states_file="${1:-/tmp/app_states.txt}"
    
    # Clear existing states file if it exists
    : > "$states_file"
    
    # Find all config.json files in APP_DIR and process them
    find "$APP_DIR" -name "config.json" -type f | while read -r config_file; do
        # Get the parent directory name (app name)
        app_dir=$(dirname "$config_file")
        app_name=$(basename "$app_dir")
        
        # Skip if app_name starts with '-'
        case "$app_name" in
            -*) continue ;;
        esac
        
        # Check if the app is hidden (#label) or shown (label)
        if grep -q '"#label"' "$config_file"; then
            echo "$app_name:hidden" >> "$states_file"
        else
            echo "$app_name:shown" >> "$states_file"
        fi
    done
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - App states saved to $states_file"
}

restore_app_states() {
    local states_file="${1:-/tmp/app_states.txt}"
    
    if [ ! -f "$states_file" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No app states file found"
        return 1
    fi
    
    while IFS=: read -r app_name state; do
        # Skip if app_name starts with '-'
        case "$app_name" in
            -*) continue ;;
        esac
        
        local config_file="$APP_DIR/$app_name/config.json"
        
        if [ -f "$config_file" ]; then
            if [ "$state" = "hidden" ]; then
                # Hide the app by replacing "label" with "#label"
                sed -i 's/"label"/"#label"/' "$config_file"
            else
                # Show the app by replacing "#label" with "label"
                sed -i 's/"#label"/"label"/' "$config_file"
            fi
        fi
    done < "$states_file"
    
    # Clean up the states file
    rm -f "$states_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - App states restored and temporary file removed"
}
