grep "eve" intel/users.csv
echo "Exit code: $?"
grep "mallory" intel/users.csv
echo "Exit code: $?"
if [ -f case/logs/auth.log ]; then
    echo "Found auth.log"
    exit 0
else
echo "auth.log not found"
    exit 1
fi
