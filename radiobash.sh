#!/bin/bash

# Online radio player

# Function to get the directory of the current script
function get_script_dir() {
    local script_path="${BASH_SOURCE[0]}"
    while [ -h "$script_path" ]; do
        script_dir="$( cd -P "$( dirname "$script_path" )" >/dev/null 2>&1 && pwd )"
        script_path="$(readlink "$script_path")"
        [[ $script_path != /* ]] && script_path="$script_dir/$script_path"
    done
    script_dir="$( cd -P "$( dirname "$script_path" )" >/dev/null 2>&1 && pwd )"
    echo "$script_dir"
}

# Get the directory of the current script
SCRIPT_DIR=$(get_script_dir)

# Path to the radio stations list file
RADIO_LIST="$SCRIPT_DIR/radio_stations.txt"

# Function to display the list of radio stations
function list_stations() {
    echo "Available radio stations:"
    awk -F'|' '{print NR ". " $1 " (" $3 ", " $4 ", " $5 ")"}' "$RADIO_LIST"
}

# Function to play a selected station
function play_station() {
    local station_number=$1
    local url=$(awk -F'|' -v num="$station_number" 'NR == num {print $2}' "$RADIO_LIST")
    if [ -n "$url" ]; then
        echo "Playing station: $url"
        mpv "$url"
    else
        echo "Invalid station number"
    fi
}

# Main menu
while true; do
    echo "Radio Station Player"
    echo "1. Play a station"
    echo "2. List stations"
    echo "3. Exit"
    echo -n "Choose an option: "
    read -r choice

    case $choice in
        1)
            list_stations
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number"
            ;;
        2) list_stations ;;
        3) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
