#!/bin/bash
set -euo pipefail

# ---- Counters ----
files_surveyed=0
files_flagged=0
total_ioc_matches=0

# ---- IOC source (only used for .log) ----
IOC_FILE="intel/iocs.txt"

# ---- Helpers ----

# Magic/type mismatch logic: mirrors a typical magic_check.sh approach
# (expected types based on extension), including .sh/.py expectations.
is_extension_type_disagreement() {
  local path="$1"
  local base ext expected_magic actual_magic

  base="$(basename "$path")"
  ext="${base##*.}"

  # Detect type (as used in requirements)
  # Use -b (brief) so it's consistent with "detected type contains ..."
  actual_magic="$(file -b -- "$path")"

  # Expected "contains" patterns based on extension
  # (Adjust if your magic_check.sh uses different exact wording.)
  expected_magic=""

  case "$ext" in
    sh)
      expected_magic="shell script"
      ;;
    py)
      expected_magic="python"
      ;;
    txt)
      expected_magic="ASCII text"
      ;;
    log)
      expected_magic="ASCII text"
      ;;
    json)
      expected_magic="JSON"
      ;;
    *)
      # For unknown extensions we don't flag mismatches
      expected_magic=""
      ;;
  esac

  # If we don't have an expectation, no disagreement to flag
  if [[ -z "$expected_magic" ]]; then
    return 1  # false (no disagreement)
  fi

  # Disagree if expected pattern does NOT appear in detected type
  if [[ "$actual_magic" != *"$expected_magic"* ]]; then
    return 0  # true (disagreement)
  else
    return 1  # false
  fi
}

# Count IOC matches for a log file
count_iocs_in_log() {
  local log_path="$1"
  local matches=0
  local ioc

  # If IOC file missing, treat as 0 matches (safer)
  if [[ ! -f "$IOC_FILE" ]]; then
    echo 0
    return
  fi

  # For each IOC indicator, count if it appears anywhere in the log
  # (One count per IOC indicator, not per occurrence)
  while IFS= read -r ioc; do
    # skip blanks and comments
    [[ -z "$ioc" ]] && continue
    [[ "$ioc" =~ ^[[:space:]]*# ]] && continue

    if grep -q -- "$ioc" "$log_path"; then
      ((matches++))
    fi
  done < "$IOC_FILE"

  echo "$matches"
}

# ---- Main scan ----
for dir in case/evidence case/scripts case/logs; do
  if [[ ! -d "$dir" ]]; then
    continue
  fi

  # Find ALL entries under dir, then process only regular files
  while IFS= read -r -d '' f; do
    [[ -f "$f" ]] || continue

    ((files_surveyed++))

    # Name (full path as discovered)
    echo "FILE: $f"

    # Size bytes
    size_bytes="$(wc -c < "$f")"
    echo "  Size: $size_bytes bytes"

    # Detected type (file -b)
    detected="$(file -b -- "$f")"
    echo "  Type: $detected"

    # Line count if detected type contains "text"
    # (Requirement: "contains text")
    if [[ "$detected" == *text* ]]; then
      line_count="$(wc -l < "$f")"
      echo "  Lines: $line_count"
    fi

    # SHA-256 hash
    sha256="$(sha256sum -- "$f" | awk '{print $1}')"
    echo "  SHA-256: $sha256"

    # Flag mismatch between extension and detected type
    if is_extension_type_disagreement "$f"; then
      echo "  !! Extension/type mismatch"
      ((files_flagged++))
    fi

    # If it's a .log file, count IOC indicators
    if [[ "${f##*.}" == "log" ]]; then
      ioc_matches="$(count_iocs_in_log "$f")"
      echo "  IOC matches (intel/iocs.txt): $ioc_matches"
      ((total_ioc_matches += ioc_matches))
    fi

    echo "-----"
  done < <(find "$dir" -type f -print0)
done

# ---- Summary ----
echo "SUMMARY"
echo "  Files surveyed: $files_surveyed"
echo "  Files flagged: $files_flagged"
echo "  Total IOC matches: $total_ioc_matches"
