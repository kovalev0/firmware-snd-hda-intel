#!/bin/bash

cd "$(dirname $(readlink -e $0))"

FW_DIR="quirks"
TARGET_FW="/lib/firmware/firmware-snd-hda-intel.fw"

# Initialize variables
MATCH_FOUND=0

# Read each codec block and extract Vendor Id and Subsystem Id
while IFS= read -r line; do
    if [[ $line =~ ^Codec:\ .* ]]; then
        # New codec block starts
        VENDOR_ID=""
        SUBSYSTEM_ID=""
    elif [[ $line =~ ^Vendor\ Id:\ ([^[:space:]]+) ]]; then
        VENDOR_ID="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^Subsystem\ Id:\ ([^[:space:]]+) ]]; then
        SUBSYSTEM_ID="${BASH_REMATCH[1]}"
    fi

    # If both IDs are set, attempt matching
    if [[ -n "$VENDOR_ID" && -n "$SUBSYSTEM_ID" ]]; then
        for fw_file in "$FW_DIR"/*.fw; do
            FW_VENDOR_ID=$(grep '^\[codec\]' -A 1 "$fw_file" | tail -n 1 | awk '{print $1}')
            FW_SUBSYSTEM_ID=$(grep '^\[codec\]' -A 1 "$fw_file" | tail -n 1 | awk '{print $2}')

            if [[ "$VENDOR_ID" == "$FW_VENDOR_ID" && "$SUBSYSTEM_ID" == "$FW_SUBSYSTEM_ID" ]]; then
                cp "$fw_file" "$TARGET_FW"
                echo "Matched firmware file: $fw_file"
                MATCH_FOUND=1
                break 2  # Stop processing once a match is found
            fi
        done

        # Reset IDs for the next codec block
        VENDOR_ID=""
        SUBSYSTEM_ID=""
    fi
done < <(cat /proc/asound/card*/codec#*)

# If no match was found, leave the target file empty
if [[ $MATCH_FOUND -eq 0 ]]; then
    echo "No matching firmware file found. Leaving firmware file empty."
    > "$TARGET_FW"
fi
