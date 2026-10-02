diff -q case/config-old.txt case/config-new.txt ; echo "Exit code: $?"
diff -q case/config-old.txt case/config-old.txt ; echo "Exit code: $?"
diff -q case/config-old.txt case/nothing.txt ; echo "Exit code: $?"
if [ $# -ne 2 ]; then
    echo "Usage: $0 <baseline_config> <current_config>" >&2
    exit 2
fi
diff -u "$1" "$2"
STATUS=$?
echo ""
echo "diff exit code: $STATUS (0 = identical, 1 = drift, 2 = error)"
exit $STATUS
