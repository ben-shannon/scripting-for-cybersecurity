#!/bin/bash

COUNT=0
while IFS= read -r -d '' LOGFILE; do
    COUNT=$((COUNT + 1))
done < <(find case -type f -name "*.log" -print0)
echo "after the loop: COUNT=$COUNT"
