#!/bin/bash

read -p "Enter username: " USERNAME

# Check for empty username
if [ -z "$USERNAME" ]; then
    echo "Error: username cannot be empty." >&2
    exit 1
fi

CURRENT_FILE="intel/users.csv"
LEGACY_FILE="case/backups/users.old"
AUTH_LOG="case/logs/auth.log"
PASSWORD_FILE="case/evidence/passwords.txt"

# Determine account source
if grep -q "^$USERNAME," "$CURRENT_FILE"; then
    SOURCE="CURRENT"

    USER_INFO=$(grep "^$USERNAME," "$CURRENT_FILE")
    ROLE=$(echo "$USER_INFO" | cut -d',' -f2)
    STATUS=$(echo "$USER_INFO" | cut -d',' -f3)

    echo "Account Source: CURRENT"
    echo "Role: $ROLE"
    echo "Status: $STATUS"

elif grep -q "^$USERNAME$" "$LEGACY_FILE"; then
    SOURCE="LEGACY"

    echo "Account Source: LEGACY"

else
    SOURCE="UNKNOWN"

    echo "Account Source: UNKNOWN"
fi

# Count login attempts
FAILED=$(grep -c "Failed password for $USERNAME " "$AUTH_LOG")
ACCEPTED=$(grep -c "Accepted password for $USERNAME " "$AUTH_LOG")

echo "Failed Logins: $FAILED"
echo "Accepted Logins: $ACCEPTED"

# Risk classification (same thresholds as risk_level.sh)
if [ "$FAILED" -eq 0 ]; then
    RISK="LOW"
elif [ "$FAILED" -le 5 ]; then
    RISK="MEDIUM"
else
    RISK="HIGH"
fi

echo "Risk Level: $RISK"

# Warnings

# Disabled current account has successful login(s)
if [ "$SOURCE" = "CURRENT" ] && [ "$STATUS" = "disabled" ] && [ "$ACCEPTED" -gt 0 ]; then
    echo "WARNING: Disabled account has accepted login(s)."
fi

# Legacy or unknown account targeted by failed logins
if { [ "$SOURCE" = "LEGACY" ] || [ "$SOURCE" = "UNKNOWN" ]; } && [ "$FAILED" -gt 0 ]; then
    echo "WARNING: Failed login attempts against legacy/unknown account."
fi

# Current account has accepted logins and appears in passwords.txt
if [ "$SOURCE" = "CURRENT" ] && [ "$ACCEPTED" -gt 0 ]; then
    if grep -q "^$USERNAME:" "$PASSWORD_FILE"; then
        echo "WARNING: Current account has successful logins and appears in passwords.txt."
    fi
fi

# Exit codes
case "$SOURCE" in
    CURRENT) exit 0 ;;
    LEGACY)  exit 2 ;;
    UNKNOWN) exit 3 ;;
esac
