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

# Function to display the list of radio stations with optional filtering
function list_stations() {
    local country_filter="$1"
    local language_filter="$2"
    local genre_filter="$3"

    echo "Available radio stations:"

    awk -F'|' -v country="$country_filter" -v language="$language_filter" -v genre="$genre_filter" '
    BEGIN {
        count = 0;
    }
    {
        if ((country == "" || $3 == country) &&
            (language == "" || $4 == language) &&
            (genre == "" || $5 == genre)) {
            count++;
            print count ". " $1 " (" $3 ", " $4 ", " $5 ")";
        }
    }' "$RADIO_LIST"
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

# Function to list unique options for a field
function list_unique_options() {
    local field=$1
    awk -F'|' -v field="$field" '{print $field}' "$RADIO_LIST" | sort | uniq
}

# Main menu
while true; do
    echo "Radio Station Player"
    echo "1. Play a station"
    echo "2. Filter stations by country"
    echo "3. Filter stations by language"
    echo "4. Filter stations by genre"
    echo "5. Exit"
    echo -n "Choose an option: "
    read -r choice

    case $choice in
        1)
            list_stations
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number"
            ;;
        2)
            echo "Available countries:"
            list_unique_options 3
            echo -n "Enter country to filter by: "
            read -r country
            list_stations "$country" "" ""
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number"
            ;;
        3)
            echo "Available languages:"
            list_unique_options 4
            echo -n "Enter language to filter by: "
            read -r language
            list_stations "" "$language" ""
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number"
            ;;
        4)
            echo "Available genres:"
            list_unique_options 5
            echo -n "Enter genre to filter by: "
            read -r genre
            list_stations "" "" "$genre"
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number"
            ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
