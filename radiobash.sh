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

# Function to play a selected station based on filtered list
function play_station() {
    local station_number=$1
    local country_filter="$2"
    local language_filter="$3"
    local genre_filter="$4"

    local url=$(awk -F'|' -v num="$station_number" -v country="$country_filter" -v language="$language_filter" -v genre="$genre_filter" '
    BEGIN { count = 0; }
    {
        if ((country == "" || $3 == country) &&
            (language == "" || $4 == language) &&
            (genre == "" || $5 == genre)) {
            count++;
            if (count == num) {
                print $2;
                exit;
            }
        }
    }' "$RADIO_LIST")

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

# Function to add a new station
function add_station() {
    echo -n "Enter station name: "
    read -r station_name
    echo -n "Enter station URL: "
    read -r station_url
    echo -n "Enter station country: "
    read -r station_country
    echo -n "Enter station language: "
    read -r station_language
    echo -n "Enter station genre: "
    read -r station_genre

    # Append the new station to the radio list
    echo "$station_name|$station_url|$station_country|$station_language|$station_genre" >> "$RADIO_LIST"

    # Sort the list by Country, Language, Genre, then Station Name
    sort -t'|' -k3,3 -k4,4 -k5,5 -k1,1 "$RADIO_LIST" -o "$RADIO_LIST"

    echo "Station added and list sorted successfully!"
}

# Function to remove a station
function remove_station() {
    list_stations
    echo -n "Enter the station number to remove: "
    read -r station_number

    # Remove the selected station
    sed -i "${station_number}d" "$RADIO_LIST"
    echo "Station removed successfully!"
}

# Main menu
while true; do
    echo "Radio Station Player"
    echo "1. Play a station"
    echo "2. Filter stations by country"
    echo "3. Filter stations by language"
    echo "4. Filter stations by genre"
    echo "5. Add a new station"
    echo "6. Remove an existing station"
    echo "7. Exit"
    echo -n "Choose an option: "
    read -r choice

    case $choice in
        1)
            list_stations
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number" "" "" ""
            ;;
        2)
            echo "Available countries:"
            list_unique_options 3
            echo -n "Enter country to filter by: "
            read -r country
            list_stations "$country" "" ""
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number" "$country" "" ""
            ;;
        3)
            echo "Available languages:"
            list_unique_options 4
            echo -n "Enter language to filter by: "
            read -r language
            list_stations "" "$language" ""
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number" "" "$language" ""
            ;;
        4)
            echo "Available genres:"
            list_unique_options 5
            echo -n "Enter genre to filter by: "
            read -r genre
            list_stations "" "" "$genre"
            echo -n "Enter the station number to play: "
            read -r station_number
            play_station "$station_number" "" "" "$genre"
            ;;
        5)
            add_station
            ;;
        6)
            remove_station
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
