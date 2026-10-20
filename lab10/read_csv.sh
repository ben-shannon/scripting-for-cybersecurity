#!/bin/bash

FIRST_LINE=1

while IFS=',' read -r USERNAME ROLE STATUS DEPT; do
    if [ "$FIRST_LINE" -eq 1 ]; then
        FIRST_LINE=0
        continue
    fi
    DEPT=${DEPT%$'\r'}
    echo "User: $USERNAME | role: $ROLE | status: $STATUS | dept: [$DEPT]"
done < intel/users.csv
