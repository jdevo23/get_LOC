#!/usr/bin/bash

: '
    This script retrieves the date, commit message, and number of insertions
    (excluding markdown files) from the latest git commit in the current repository.
'

json_file="$HOME/Documents/projects/commit_log.json"

# get parameters
date=$(git log -1 --pretty='%ad' --date=iso)
commit_message=$(git log -1 --pretty='%s')
insertions=$(git show --stat -- ':!*.md' | grep -oP '\d+(?=\s+insertions)')

echo "Date: $date"
echo "Commit message: $commit_message"
echo "Number of insertions in last commit: $insertions"

append_to_json() {
    # Extract the data to append
    local date="$1"
    local commit_message="$2"
    local insertions="$3"

    # Check if the JSON file exists
    if [ -f "$json_file" ]; then
        # If file exists, remove the last character `]` to append new data
        # Then append new data and close the JSON array
        sed -i '$ s/.$//' "$json_file"
        echo ",{\"date\": \"$date\", \"commit_message\": \"$commit_message\", \"insertions\": $insertions}]" >> "$json_file"
    else
        # If file doesn't exist, create a new JSON array and add the first entry
        echo "[{\"date\": \"$date\", \"commit_message\": \"$commit_message\", \"insertions\": $insertions}]" > "$json_file"
    fi
}

# Debugging output to check the file path
echo "Using JSON file at: $json_file"

append_to_json "$date" "$commit_message" "$insertions"