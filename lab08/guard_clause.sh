FILE=$1

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

if [ -f "$FILE" ] && [ -r "$FILE" ] && [ -s "$FILE" ]; then
    echo "$FILE is a readable, non-empty file — proceeding."
else
    echo "$FILE failed a required check (regular file / readable / non-empty)." >&2
    exit 2
fi
