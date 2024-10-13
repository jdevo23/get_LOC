#!/usr/bin/bash

# FILE PATH
json_file="$HOME/Documents/projects/commit_log.json"

# TARGETS
year_target=100000 # 100,000
target_date="2025-10-11"
readable_target_date=$(date -d $target_date +"%A, %B %d, %Y")
long_term_target=1000000

# sum insertions
insertions=$(jq '[.[] | .insertions] | add' $json_file)

# sum insertions as a percentage of target
year_percentage=$(echo "scale=5; ($insertions / $year_target) * 100" | bc)
year_percentage=$(echo $year_percentage | sed 's/0*$//;s/\.$//')
if (( $(echo "$year_percentage < 1" | bc -l) )); then
    year_percentage="0$year_percentage"
fi

lt_percentage=$(echo "scale=6; ($insertions / $long_term_target) * 100" | bc)
lt_percentage=$(echo $lt_percentage | sed 's/0*$//;s/\.$//')
if (( $(echo "$lt_percentage < 1" | bc -l) )); then
    lt_percentage="0$lt_percentage"
fi

# sum progress against schedule
current_date=$(date +%Y-%m-%d)
days_remaining=$(( ( $(date -d $target_date +%s) - $(date -d $current_date +%s) ) / 86400 ))

expected_daily_output=$(echo "($year_target / 365)" | bc)
days_elapsed=$(echo "(365 - $days_remaining)" | bc)
expected_by_today=$(echo "($expected_daily_output * $days_elapsed)" | bc)

# PRINT STATEMENTS
echo "------------------------------------------------------------"
echo "End date: $readable_target_date"
echo "Days remaining until end date: $days_remaining"

echo ""

echo "Total lines of code added/changed: $insertions"
echo "Expected by today: $expected_by_today"
echo "Progress toward year goal ($(printf "%'d" $year_target)): $year_percentage%"
echo "Progress toward long term goal ($(printf "%'d" $long_term_target)): $lt_percentage%"

echo ""

if (( insertions > expected_by_today )); then
    echo "You are ahead of schedule!"
elif (( insertions == expected_by_today )); then
    echo "You are on track!"
else
    echo "You are behind schedule!"
fi

echo "------------------------------------------------------------"
