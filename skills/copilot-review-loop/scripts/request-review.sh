#!/usr/bin/env bash
# Request a GitHub Copilot code review at a given effort level.
#
# Usage: request-review.sh OWNER/REPO PR_NUMBER [lite|balanced|max|auto]
#
# Prints one JSON object:
#   {"result", "http_status", "failure_reason", "message", "effort",
#    "requested_at", "head_sha", "baseline_review_id"}
# baseline_review_id is the newest review on the pull request before this
# request. Pass it to wait-review.sh so that older reviews are ignored.
#
# Exit codes:
#   0   requested (HTTP 201)
#   10  another Copilot review is already pending (HTTP 409)
#   11  effort level unavailable (HTTP 422 INVALID_REVIEW_EFFORT); "message"
#       lists the available levels
#   12  denied: not eligible, no quota, forbidden, or not found
#   13  rate limited or unavailable after retries (HTTP 429 or 503)
#   2   usage or unexpected error
set -euo pipefail

die() {
  printf '%s\n' "$*" >&2
  exit 2
}

[ $# -ge 2 ] || die "usage: $0 OWNER/REPO PR_NUMBER [lite|balanced|max|auto]"
command -v gh >/dev/null 2>&1 || die "gh is required"
repo=$1
pr=$2
effort=$(printf '%s' "${3:-max}" | tr '[:upper:]' '[:lower:]')
case $repo in */*) ;; *) die "OWNER/REPO expected, got: $repo" ;; esac
case $pr in '' | *[!0-9]*) die "PR_NUMBER must be numeric, got: $pr" ;; esac
case $effort in lite | balanced | max | auto) ;; *) die "unknown effort: $effort" ;; esac
owner=${repo%%/*}
name=${repo#*/}

# Make a value safe inside a JSON string: drop control characters, then escape.
json_escape() {
  printf '%s' "$1" | tr -d '\000-\010\013\014\016-\037' | tr '\n\r\t' '   ' |
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Read a top-level string field from a JSON document, using jq when available.
json_field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$2" | jq -r --arg k "$1" 'if type == "object" then (.[$k] // "") | tostring else "" end' 2>/dev/null || true
  else
    printf '%s' "$2" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p"
  fi
}

# Snapshot the head commit and the newest review before requesting.
snapshot=$(gh api graphql -F n="$pr" -f o="$owner" -f r="$name" -f query='
  query($o: String!, $r: String!, $n: Int!) {
    repository(owner: $o, name: $r) {
      pullRequest(number: $n) {
        headRefOid
        reviews(last: 1) { nodes { fullDatabaseId } }
      }
    }
  }' --jq '.data.repository.pullRequest | "\(.headRefOid) \(.reviews.nodes[0].fullDatabaseId // 0)"') ||
  die "could not read pull request $repo#$pr"
head_sha=${snapshot%% *}
baseline=${snapshot##* }
case $baseline in '' | *[!0-9]*) baseline=0 ;; esac

# Request the review. Retry twice on rate limiting or service unavailability.
attempt=0
while :; do
  requested_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  response=$(gh api -i -X POST "repos/$repo/pulls/$pr/copilot-code-review" \
    -f review_effort="$effort" 2>/dev/null || true)
  # awk reads the whole response, so a large body can't SIGPIPE printf.
  status=$(printf '%s\n' "$response" | awk 'NR == 1 { print $2 }')
  case $status in [0-9][0-9][0-9]) ;; *) status=0 ;; esac
  if { [ "$status" = 429 ] || [ "$status" = 503 ]; } && [ "$attempt" -lt 2 ]; then
    attempt=$((attempt + 1))
    sleep $((attempt * 60))
    continue
  fi
  break
done

# With -i, the response body follows the first blank line after the headers.
body=$(printf '%s\n' "$response" | awk 'body { print } /^\r?$/ { body = 1 }')
failure_reason=$(json_field failure_reason "$body")
message=$(json_field message "$body")

case $status in
  201) result=requested code=0 ;;
  409) result=pending code=10 ;;
  422)
    if [ "$failure_reason" = INVALID_REVIEW_EFFORT ]; then
      result=invalid_effort code=11
    else
      result=denied code=12
    fi
    ;;
  401 | 403 | 404) result=denied code=12 ;;
  429 | 503) result=unavailable code=13 ;;
  *) result=error code=2 ;;
esac

printf '{"result":"%s","http_status":%s,"failure_reason":"%s","message":"%s","effort":"%s","requested_at":"%s","head_sha":"%s","baseline_review_id":%s}\n' \
  "$result" "$status" "$(json_escape "$failure_reason")" "$(json_escape "$message")" \
  "$effort" "$requested_at" "$head_sha" "$baseline"
exit "$code"
