if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
    echo "Error: file '$LOGFILE' not found" >&2
    exit 2
fi

read -p "Enter a keyword to search for (or press Enter to skip): " KEYWORD

if [ -n "$KEYWORD" ]; then
    MATCH_COUNT=$(grep -c "$KEYWORD" "$LOGFILE")
    echo "Lines containing '$KEYWORD': $MATCH_COUNT"
fi


LINE_COUNT=$(wc -l < "$LOGFILE")
WORD_COUNT=$(wc -w < "$LOGFILE")
CHAR_COUNT=$(wc -c < "$LOGFILE")
FIRST_LINE=$(head -n 1 "$LOGFILE")
LAST_LINE=$(tail -n 1 "$LOGFILE")

echo "Log file        : $LOGFILE"
echo "Total lines     : $LINE_COUNT"
echo "Total words     : $WORD_COUNT"
echo "Total characters: $CHAR_COUNT"
echo "First line      : $FIRST_LINE"
echo "Last line       : $LAST_LINE"

exit 0
