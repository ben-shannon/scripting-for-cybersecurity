#!/usr/bin/env bash
# Part 7: Investigation Challenge

# Scan all *.log files in the current directory (via find),
# check IOC indicators in Intel/iocs.txt for each log,
# print a per-file summary, and a total IOC match count.
# Exit 0 if no indicator matched anywhere, else exit 1.

set -u

report_total=0
found_any=0

# 1) Uses find ... -name "*.log" -print0 and while IFS= read -r -d '' loop (process substitution)
while IFS= read -r -d '' log; do
  # Count IOC indicator matches inside this log (2 indicators per line are fine; we just count lines matched)
  match_count=$(
    # 2) inner while loop over Intel/iocs.txt, checking each indicator with grep -qwf
    total_for_log=0
    inner_found=0

    while IFS= read -r indicator; do
      # Skip empty lines
      [[ -z "$indicator" ]] && continue

      # If the indicator appears as a full word in the log, count it (once per indicator)
      if grep -qwf "$indicator" "$log"; then
        total_for_log=$((total_for_log + 1))
        inner_found=1
      fi
    done < "Intel/iocs.txt"

    echo "$total_for_log"
  )

  # 4) per-file summary: filename, total lines, number of IOC matches, note if stopped early or none
  # "break" behavior: we did not break early; indicator scanning continues through all indicators.
  total_lines=$(wc -l < "$log" 2>/dev/null || echo 0)

  # 5) keep running total of IOC matches
  report_total=$((report_total + match_count))

  # Track global found_any for exit code logic
  if [[ "$match_count" -gt 0 ]]; then
    found_any=1
  fi

  # Print per-file summary (includes the note about early stop)
  # Since we didn't use break, it will always be "no" early stop.
  if [[ "$match_count" -gt 0 ]]; then
    echo "File: $log | Lines: $total_lines | IOC matches: $match_count | Early stop: none"
  else
    echo "File: $log | Lines: $total_lines | IOC matches: 0 | Early stop: none"
  fi

done < <(find . -maxdepth 1 -type f -name "*.log" -print0)

# 5) Print total at the end
echo "TOTAL IOC matches across all logs: $report_total"

# 6) Exit code: 0 if no indicator matched anywhere, else 1
exit "$found_any"
