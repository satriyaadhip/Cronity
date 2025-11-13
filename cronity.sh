#!/bin/bash

# Cronity - GUI for managing cron jobs using Zenity
# Dependency: zenity, cron

VERSION="1.0.0"
TEMP_CRON="/tmp/crontab_temp.txt"
BACKUP_DIR="$HOME/.config/cronity/backups"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check dependencies
check_dependencies() {
    local missing=""

    if ! command -v zenity &> /dev/null; then
        missing="zenity"
    fi

    if ! command -v crontab &> /dev/null; then
        missing="$missing cron"
    fi

    if [ -n "$missing" ]; then
        echo -e "${RED}Error: Missing dependencies:${NC} $missing"
        echo "Install with: sudo apt install $missing"
        exit 1
    fi
}

# Function to backup crontab
backup_crontab() {
    local backup_file="$BACKUP_DIR/crontab_$(date +%Y%m%d_%H%M%S).txt"
    crontab -l > "$backup_file" 2>/dev/null
    echo "$backup_file"
}

# Function to load cron jobs
load_cron_jobs() {
    crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$"
}

# Function to display human readable time
human_readable_time() {
    local min=$1 hour=$2 day=$3 month=$4 weekday=$5

    if [[ "$min" != "*" && "$hour" != "*" ]]; then
        echo "Every day at ${hour}:${min}"
    elif [[ "$hour" != "*" ]]; then
        echo "Every day at ${hour}:00"
    elif [[ "$min" != "*" ]]; then
        echo "Every hour at minute ${min}"
    else
        echo "Custom schedule: $min $hour $day $month $weekday"
    fi
}

# Function to display cron jobs list
show_cron_list() {
    local jobs=$(load_cron_jobs)

    if [ -z "$jobs" ]; then
        zenity --info \
            --title="Cronity" \
            --text="No cron jobs found." \
            --width=300
        return
    fi

    # Format for zenity list
    local list_data=""
    local i=1

    while IFS= read -r line; do
        # Parse cron expression
        local min=$(echo "$line" | awk '{print $1}')
        local hour=$(echo "$line" | awk '{print $2}')
        local day=$(echo "$line" | awk '{print $3}')
        local month=$(echo "$line" | awk '{print $4}')
        local weekday=$(echo "$line" | awk '{print $5}')
        local command=$(echo "$line" | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}')

        local schedule="$min $hour $day $month $weekday"
        local human=$(human_readable_time "$min" "$hour" "$day" "$month" "$weekday")

        list_data+="$i\n$schedule\n$human\n$command\n"
        ((i++))
    done <<< "$jobs"

    # Display with zenity
    local selection=$(echo -e "$list_data" | zenity --list \
        --title="Cronity - Cron Jobs List" \
        --text="Select a cron job to edit/delete:" \
        --column="No" \
        --column="Schedule" \
        --column="Time" \
        --column="Command" \
        --width=900 \
        --height=400 \
        --print-column=1)

    if [ -n "$selection" ]; then
        manage_job "$selection" "$jobs"
    fi
}

# Function to manage job (edit/delete)
manage_job() {
    local job_num=$1
    local jobs=$2
    local selected_job=$(echo "$jobs" | sed -n "${job_num}p")

    local action=$(zenity --list \
        --title="Manage Cron Job" \
        --text="Job: $selected_job\n\nSelect action:" \
        --column="Action" \
        "Delete" "Disable (comment)" "Back" \
        --width=400 \
        --height=250)

    case $action in
        "Delete")
            delete_job "$job_num"
            ;;
        "Disable (comment)")
            disable_job "$job_num"
            ;;
        *)
            return
            ;;
    esac
}

# Function to delete job
delete_job() {
    local job_num=$1

    if zenity --question \
        --title="Confirm Delete" \
        --text="Are you sure you want to delete this cron job?" \
        --width=300; then

        backup_crontab
        crontab -l | sed "${job_num}d" | crontab -

        zenity --info \
            --title="Success" \
            --text="Cron job successfully deleted!" \
            --width=300
    fi
}

# Function to disable job
disable_job() {
    local job_num=$1

    backup_crontab
    crontab -l > "$TEMP_CRON"
    sed -i "${job_num}s/^/# /" "$TEMP_CRON"
    crontab "$TEMP_CRON"
    rm -f "$TEMP_CRON"

    zenity --info \
        --title="Success" \
        --text="Cron job successfully disabled (commented)!" \
        --width=300
}

# Function to add new cron job
add_cron_job() {
    # Input schedule with form
    local schedule=$(zenity --forms \
        --title="Add Cron Job - Schedule" \
        --text="Enter schedule (use * for any):" \
        --add-entry="Minute (0-59 or *):" \
        --add-entry="Hour (0-23 or *):" \
        --add-entry="Day (1-31 or *):" \
        --add-entry="Month (1-12 or *):" \
        --add-entry="Weekday (0-7 or *, 0=Sunday):" \
        --separator="|" \
        --width=400)

    if [ -z "$schedule" ]; then
        return
    fi

    # Parse input
    IFS='|' read -r min hour day month weekday <<< "$schedule"

    # Basic input validation
    if [[ -z "$min" || -z "$hour" ]]; then
        zenity --error \
            --title="Error" \
            --text="Minute and Hour cannot be empty!" \
            --width=300
        return
    fi

    # Input command
    local command=$(zenity --entry \
        --title="Add Cron Job - Command" \
        --text="Enter the command to execute:" \
        --width=500)

    if [ -z "$command" ]; then
        return
    fi

    # Preview and confirm
    local cron_line="$min $hour $day $month $weekday $command"
    local human=$(human_readable_time "$min" "$hour" "$day" "$month" "$weekday")

    if zenity --question \
        --title="Confirmation" \
        --text="Cron job to be added:\n\n<b>Schedule:</b> $cron_line\n<b>Time:</b> $human\n\nAdd this job?" \
        --width=500; then

        backup_crontab
        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -

        zenity --info \
            --title="Success" \
            --text="Cron job successfully added!" \
            --width=300
    fi
}

# Function for quick add (presets)
quick_add() {
    local preset=$(zenity --list \
        --title="Quick Add - Select Preset" \
        --text="Choose a cron job template:" \
        --column="Template" \
        --column="Description" \
        "every_hour" "Every hour" \
        "every_day_midnight" "Every day at 00:00" \
        "every_day_morning" "Every day at 07:00" \
        "every_day_evening" "Every day at 17:00" \
        "every_monday" "Every Monday at 09:00" \
        "every_month" "Every 1st of month at 00:00" \
        --width=500 \
        --height=400 \
        --print-column=1)

    case $preset in
        "every_hour")
            local cron="0 * * * *"
            ;;
        "every_day_midnight")
            local cron="0 0 * * *"
            ;;
        "every_day_morning")
            local cron="0 7 * * *"
            ;;
        "every_day_evening")
            local cron="0 17 * * *"
            ;;
        "every_monday")
            local cron="0 9 * * 1"
            ;;
        "every_month")
            local cron="0 0 1 * *"
            ;;
        *)
            return
            ;;
    esac

    local command=$(zenity --entry \
        --title="Quick Add - Command" \
        --text="Template: $preset\nSchedule: $cron\n\nEnter command:" \
        --width=500)

    if [ -n "$command" ]; then
        backup_crontab
        (crontab -l 2>/dev/null; echo "$cron $command") | crontab -

        zenity --info \
            --title="Success" \
            --text="Cron job successfully added!" \
            --width=300
    fi
}

# Function to restore backup
restore_backup() {
    local backups=$(ls -t "$BACKUP_DIR"/*.txt 2>/dev/null)

    if [ -z "$backups" ]; then
        zenity --info \
            --title="Restore Backup" \
            --text="No backups found." \
            --width=300
        return
    fi

    local backup_list=""
    while IFS= read -r file; do
        local filename=$(basename "$file")
        backup_list+="$file|$filename\n"
    done <<< "$backups"

    local selected=$(echo -e "$backup_list" | zenity --list \
        --title="Restore Backup" \
        --text="Select a backup to restore:" \
        --column="Path" \
        --column="Filename" \
        --hide-column=1 \
        --width=500 \
        --height=400 \
        --print-column=1)

    if [ -n "$selected" ]; then
        if zenity --question \
            --title="Confirm Restore" \
            --text="Are you sure you want to restore this backup?\nCurrent crontab will be overwritten!" \
            --width=400; then

            backup_crontab  # Backup current before restore
            crontab "$selected"

            zenity --info \
                --title="Success" \
                --text="Backup successfully restored!" \
                --width=300
        fi
    fi
}

# Function to view raw crontab
view_raw() {
    local content=$(crontab -l 2>/dev/null)

    if [ -z "$content" ]; then
        content="# No cron jobs"
    fi

    zenity --text-info \
        --title="Raw Crontab" \
        --filename=<(echo "$content") \
        --width=700 \
        --height=500
}

# Function for about
show_about() {
    zenity --info \
        --title="About Cronity" \
        --text="<b>Cronity v${VERSION}</b>\n\nGUI for managing cron jobs in Linux\n\nBuilt with Bash + Zenity\n\nBackup location: $BACKUP_DIR" \
        --width=400
}

# Main menu loop
main_menu() {
    while true; do
        local choice=$(zenity --list \
            --title="Cronity v${VERSION}" \
            --text="Select an action:" \
            --column="Action" \
            "📋 View Cron Jobs" \
            "➕ Add Cron Job" \
            "⚡ Quick Add (Presets)" \
            "📄 View Raw Crontab" \
            "💾 Restore Backup" \
            "ℹ️ About" \
            "🚪 Exit" \
            --width=400 \
            --height=400)

        case $choice in
            "📋 View Cron Jobs")
                show_cron_list
                ;;
            "➕ Add Cron Job")
                add_cron_job
                ;;
            "⚡ Quick Add (Presets)")
                quick_add
                ;;
            "📄 View Raw Crontab")
                view_raw
                ;;
            "💾 Restore Backup")
                restore_backup
                ;;
            "ℹ️ About")
                show_about
                ;;
            *)
                exit 0
                ;;
        esac
    done
}

# Check dependencies before running
check_dependencies

# Run main menu
main_menu
