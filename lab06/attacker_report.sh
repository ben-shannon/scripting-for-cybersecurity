#!/bin/bash

# Check argument supplied
if [ $# -eq 0 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE="$1"

# Check file exists
if [ ! -f "$LOGFILE" ]; then
    echo "Error: File does not exist" >&2
    exit 2
fi

# Total failed password events
FAILED_COUNT=$(grep -c "Failed password" "$LOGFILE" 2>/dev/null)

# Most active attacker IP
TOP_IP=$(grep "Failed password" "$LOGFILE" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

# Three most-targeted usernames
TOP_USERS=$(grep "Failed password" "$LOGFILE" |
    awk '{
        for(i=1;i<=NF;i++) {
            if($i=="for") {
                if($(i+1)=="invalid")
                    print $(i+2)
                else
                    print $(i+1)
            }
        }
    }' |
    sort | uniq -c | sort -nr | head -n 3)

echo "Failed password events: $FAILED_COUNT"
echo "Top attacker IP: ${TOP_IP:-None}"
echo

echo "Top 3 failed-login sources:"
./top3.sh

echo
echo "Top 3 targeted usernames:"
echo "$TOP_USERS"

exit 0
