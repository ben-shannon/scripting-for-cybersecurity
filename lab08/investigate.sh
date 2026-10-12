FIREWALL_LOG="case/logs/firewall.log"
IOC_FILE="intel/iocs.txt"
# Lab 7 risk thresholds (failed password count): CHANGE TO YOUR LAB'S VALUES
MEDIUM_MIN=3
HIGH_MIN=6
CRITICAL_MIN=10
# Lab 7 Part 5 account lists (one username per line): CHANGE PATHS/NAMES
CURRENT_USERS="case/accounts/current_users.txt"
LEGACY_USERS="case/accounts/legacy_users.txt"
# ---------------------------------------------------------------------------

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <logfile> <ip-or-username>" >&2
    exit 2
fi

LOG_FILE="$1"
TERM_ARG="$2"

if [ ! -e "$LOG_FILE" ]; then
    echo "Error: '$LOG_FILE' does not exist." >&2
    exit 3
fi
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: '$LOG_FILE' is not a regular file." >&2
    exit 4
fi
if [ ! -r "$LOG_FILE" ]; then
    echo "Error: '$LOG_FILE' is not readable." >&2
    exit 5
fi
if [ -z "$TERM_ARG" ]; then
    echo "Error: search term is empty." >&2
    exit 6
fi

# grep -c prints 0 but exits 1 when nothing matches; "|| true" keeps that harmless
TOTAL=$(grep -cwF -- "$TERM_ARG" "$LOG_FILE" || true)

echo "=== Investigating '$TERM_ARG' in $LOG_FILE ==="
echo "Occurrences in log: $TOTAL"

if echo "$TERM_ARG" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then
    # ---------- IP address ----------
    FAILED=$(grep -F "Failed password" "$LOG_FILE" | grep -cwF -- "$TERM_ARG" || true)
    echo "Failed password events: $FAILED"

    if   [ "$FAILED" -ge "$CRITICAL_MIN" ]; then RISK="CRITICAL"
    elif [ "$FAILED" -ge "$HIGH_MIN" ];     then RISK="HIGH"
    elif [ "$FAILED" -ge "$MEDIUM_MIN" ];   then RISK="MEDIUM"
    else                                         RISK="LOW"
    fi
    echo "Risk level: $RISK"

    echo "--- Firewall log ($FIREWALL_LOG) ---"
    if [ -r "$FIREWALL_LOG" ]; then
        if grep -wF -- "$TERM_ARG" "$FIREWALL_LOG"; then
            :
        else
            echo "No firewall entries for $TERM_ARG"
        fi
    else
        echo "Firewall log not readable: $FIREWALL_LOG"
    fi

    echo "--- Threat intel ($IOC_FILE) ---"
    if [ -r "$IOC_FILE" ] && grep -qxF -- "$TERM_ARG" "$IOC_FILE"; then
        echo "LISTED in IOC list"
    else
        echo "NOT listed in IOC list"
    fi
else
    # ---------- Username ----------
    FAILED=$(grep -F "Failed password" "$LOG_FILE" | grep -cwF -- "$TERM_ARG" || true)
    ACCEPTED=$(grep -F "Accepted" "$LOG_FILE" | grep -cwF -- "$TERM_ARG" || true)
    echo "Failed logins:   $FAILED"
    echo "Accepted logins: $ACCEPTED"

    if   [ -r "$CURRENT_USERS" ] && grep -qxF -- "$TERM_ARG" "$CURRENT_USERS"; then
        echo "Account status: CURRENT"
    elif [ -r "$LEGACY_USERS" ] && grep -qxF -- "$TERM_ARG" "$LEGACY_USERS"; then
        echo "Account status: LEGACY"
    else
        echo "Account status: UNKNOWN"
    fi
fi

if [ "$TOTAL" -gt 0 ]; then
    exit 0
else
    exit 1
fi
