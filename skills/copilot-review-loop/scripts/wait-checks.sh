#!/usr/bin/env bash
# Wait for a pull request's checks to register and finish.
#
# Usage: wait-checks.sh OWNER/REPO PR_NUMBER
#          [--grace MINUTES] [--timeout MINUTES] [--interval SECONDS]
#
# Checks can take a while to appear after a push. "No checks" is trusted only
# after the grace period (default 5 minutes), and a result without failures
# only after the grace period or at the timeout. A failure is reported as soon
# as it is seen. Otherwise the script waits until no check is pending, or until
# the timeout (default 60 minutes).
#
# Prints one JSON object:
#   {"result": "pass" | "fail" | "pending" | "skipped", "total", "skipped",
#    "failing": [...]}
#   {"result": "none", "total": 0, "failing": [], "workflows_present": true|false}
# failing lists {name, workflow, state, link} for failed or cancelled checks.
# skipped counts checks in the "skipping" bucket. "skipped" means that no check
# passed or failed because every check was skipped, for example by a job that
# does not run on draft pull requests; treat CI as unknown, not green.
# For "none", workflows_present tells whether the head commit has GitHub
# Actions workflow files; if true, treat CI as unknown, not green. If that
# lookup fails for any reason other than a 404, the script exits 2.
#
# Exit codes:
#   0   no check pending, none failed
#   30  no check pending, at least one failed or was cancelled
#   31  no checks reported after the grace period
#   32  timed out with checks still pending
#   33  every check was skipped
#   2   usage or unexpected error
set -euo pipefail

die() {
  printf '%s\n' "$*" >&2
  exit 2
}
usage="usage: $0 OWNER/REPO PR_NUMBER [--grace MINUTES] [--timeout MINUTES] [--interval SECONDS]"

[ $# -ge 2 ] || die "$usage"
command -v gh >/dev/null 2>&1 || die "gh is required"
repo=$1
pr=$2
shift 2
grace_min=5
timeout_min=60
interval=30
while [ $# -gt 0 ]; do
  case $1 in
    --grace | --timeout | --interval) [ $# -ge 2 ] || die "$1 needs a value" ;;
    *) die "unknown argument: $1" ;;
  esac
  case $1 in
    --grace) grace_min=$2 ;;
    --timeout) timeout_min=$2 ;;
    --interval) interval=$2 ;;
  esac
  shift 2
done
case $repo in */*) ;; *) die "OWNER/REPO expected, got: $repo" ;; esac
for value in "$pr" "$grace_min" "$timeout_min" "$interval"; do
  case $value in '' | *[!0-9]*) die "numeric value expected, got: $value" ;; esac
done

# Summarize the checks as two lines: the result word, then the JSON object.
# "pending" wins over "fail" so that every check finishes before reporting.
# A result is "pass" only if at least one check passed; otherwise every check
# was skipped and CI did not run.
summary='{
    result: (if any(.[]; .bucket == "pending") then "pending"
      elif any(.[]; .bucket == "fail" or .bucket == "cancel") then "fail"
      elif any(.[]; .bucket == "pass") then "pass"
      else "skipped" end),
    total: length,
    skipped: ([.[] | select(.bucket == "skipping")] | length),
    failing: [.[] | select(.bucket == "fail" or .bucket == "cancel")
      | {name, workflow, state, link}]
  } as $s
  | $s.result, ($s | tojson)'

grace_end=$((SECONDS + grace_min * 60))
deadline=$((SECONDS + timeout_min * 60))
while :; do
  # gh exits 8 while checks are pending and 1 when none are reported.
  out=$(gh pr checks "$pr" -R "$repo" --json name,bucket,state,link,workflow \
    --jq "$summary" 2>&1) || true
  case $out in
    *'no checks reported'*)
      if [ "$SECONDS" -ge "$grace_end" ]; then
        head_sha=$(gh pr view "$pr" -R "$repo" --json headRefOid --jq .headRefOid) ||
          die "could not read pull request $repo#$pr"
        # Only a 404 means there are no workflow files; any other failure is an error.
        if probe=$(gh api "repos/$repo/contents/.github/workflows?ref=$head_sha" \
          --jq 'length' 2>&1); then
          present=true
        else
          case $probe in
            *'HTTP 404'*) present=false ;;
            *) die "could not check workflow files for $repo#$pr: $probe" ;;
          esac
        fi
        printf '{"result":"none","total":0,"failing":[],"workflows_present":%s}\n' "$present"
        exit 31
      fi
      ;;
    pass* | fail* | pending* | skipped*)
      result=$(printf '%s\n' "$out" | head -n 1)
      json=$(printf '%s\n' "$out" | sed -n 2p)
      case $result in
        pass | skipped)
          # Late checks can still register, so trust a result without
          # failures only after the grace period or at the deadline.
          if [ "$SECONDS" -lt "$grace_end" ] && [ "$SECONDS" -lt "$deadline" ]; then
            sleep "$interval"
            continue
          fi
          printf '%s\n' "$json"
          [ "$result" = pass ] && exit 0
          exit 33
          ;;
        fail)
          printf '%s\n' "$json"
          exit 30
          ;;
      esac
      if [ "$SECONDS" -ge "$deadline" ]; then
        printf '%s\n' "$json"
        exit 32
      fi
      ;;
    *) die "could not read checks for $repo#$pr: $out" ;;
  esac
  sleep "$interval"
done
