#!/bin/bash

# Website URL to monitor
URL="https://domus.ed.ac.uk/properties/"
OLD_FILE="old_filtered.html"
NEW_FILE="new_filtered.html"
LOG_FILE="changes.log"

# Fetch latest webpage content and clean it
curl -s "$URL" | \
    sed 's/<script.*<\/script>//g' | \
    sed 's/<style.*<\/style>//g' | \
    sed -E 's/id="search-attribute-[0-9]+"/id="search-attribute"/g' | \
    sed -E 's/div id="wpp_shortcode_[0-9]+"/div id="wpp_shortcode"/g' | \
    sed -E 's/for="search-attribute-[0-9]+"/for="search-attribute"/g' | \
    sed -E 's/select id="search-attribute-[0-9]+"/select id="search-attribute"/g' | \
    sed -E 's/input id="search-attribute-[0-9]+"/input id="search-attribute"/g' > "$NEW_FILE"

# Check if old version exists
if [ -f "$OLD_FILE" ]; then
    if diff "$OLD_FILE" "$NEW_FILE" > /dev/null; then
        echo "$(date) - No changes detected." >> "$LOG_FILE"
        echo "No changes detected."
    else
        echo "$(date) - Website updated!" >> "$LOG_FILE"
        diff "$OLD_FILE" "$NEW_FILE" >> "$LOG_FILE"
        echo "Website Updated: $URL has changed!"

        echo "Website Updated: $URL has changed!" | mail -s "domus_monitor" xxx@xxx  ## Change to your email address

        # Rename old file with date
        cp "$NEW_FILE" "$(date +%Y-%m-%d_%H-%M-%S).html"
        cp "$NEW_FILE" "$OLD_FILE"
    fi
else
    echo "First run: Saving initial version."
    cp "$NEW_FILE" "$OLD_FILE"
fi
