CASE_DIR="/workspaces/scripting-for-cybersecurity/lab05/case"
REPORT="triage-report-auto.txt"
EVIDENCE_DIR="$CASE_DIR/lab05/case/evidence"

read -p "Analyst name: " ANALYST
read -p "Case reference: " CASE_REF


{
    echo "=============================="
    echo "   DIGITAL FORENSICS TRIAGE REPORT"
    echo "=============================="
    echo "Analyst: $ANALYST"
    echo "Case Reference: $CASE_REF"
    echo "Date: $(date)"
    echo
} > "$REPORT"

PY_COUNT=$(find "$CASE_DIR" -type f -name "*.py" | wc -l)
SH_COUNT=$(find "$CASE_DIR" -type f -name "*.sh" | wc -l)

{
    echo "Total Files: $(find "$CASE_DIR" -type f | wc -l)"
    echo "Total Directories: $(find "$CASE_DIR" -mindepth 1 -type d | wc -l)"
    echo "Python Files: $PY_COUNT"
    echo "Shell Scripts: $SH_COUNT"
    echo "Log Files: $(find "$CASE_DIR" -type f -name "*.log" | wc -l)"
    echo "Configuration Files: $(find "$CASE_DIR" -type f \( -name "*.conf" -o -name "*.cfg" -o -name "*.ini" \) | wc -l)"
    echo "Empty Files: $(find "$CASE_DIR" -type f -empty | wc -l)"
    echo "Archives: $(find "$CASE_DIR" -type f \( -name "*.zip" -o -name "*.tar" -o -name "*.gz" -o -name "*.tgz" \) | wc -l)"
    echo
} >> "$REPORT"

{
    echo "Files containing 'admin':"
    grep -rl "admin" "$CASE_DIR"
    echo
} >> "$REPORT"

{
    echo "Detected file types (evidence folder):"
    file "$EVIDENCE_DIR"/*
    echo
} >> "$REPORT"

echo "Scripts (Python + shell): $(( PY_COUNT + SH_COUNT ))" >> "$REPORT"

echo "Report written to $REPORT"
