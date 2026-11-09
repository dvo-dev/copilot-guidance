#!/usr/bin/env bash
# Wait for a new GitHub Copilot code review on a pull request.
#
# Usage: wait-review.sh OWNER/REPO PR_NUMBER BASELINE_REVIEW_ID
#          [--head SHA] [--effort LEVEL] [--any]
#          [--timeout MINUTES] [--interval SECONDS]
#
# Considers only Copilot code reviews newer than BASELINE_REVIEW_ID, the value
# request-review.sh printed. By default the review must be on --head, which
# defaults to the pull request's current head. --any accepts the first new
# Copilot review on any commit; use it to wait out a review that was already
# pending when a request returned HTTP 409.
#
# Prints one JSON object. When a review is found:
#   {"id", "url", "state", "effort", "commit", "submitted_at", "body"}
# where effort is null if GitHub did not record it. On timeout:
#   {"result": "timeout", "copilot_requested": true|false}
#
# Exit codes:
#   0   review found; its effort matches --effort or is unknown
#   20  review found on the head, but at a different effort than --effort
#   21  timed out
#   2   usage or unexpected error
set -euo pipefail

die() {
  printf '%s\n' "$*" >&2
  exit 2
}
usage="usage: $0 OWNER/REPO PR_NUMBER BASELINE_REVIEW_ID [--head SHA] [--effort LEVEL] [--any] [--timeout MINUTES] [--interval SECONDS]"

[ $# -ge 3 ] || die "$usage"
command -v gh >/dev/null 2>&1 || die "gh is required"
repo=$1
pr=$2
baseline=$3
shift 3
head=''
effort=''
any=false
timeout_min=60
interval=60
while [ $# -gt 0 ]; do
  case $1 in
    --any)
      any=true
      shift
      continue
      ;;
    --head | --effort | --timeout | --interval)
      [ $# -ge 2 ] || die "$1 needs a value"
      ;;
    *) die "unknown argument: $1" ;;
  esac
  case $1 in
    --head) head=$2 ;;
    --effort) effort=$(printf '%s' "$2" | tr '[:lower:]' '[:upper:]') ;;
    --timeout) timeout_min=$2 ;;
    --interval) interval=$2 ;;
  esac
  shift 2
done

case $repo in */*) ;; *) die "OWNER/REPO expected, got: $repo" ;; esac
for value in "$pr" "$baseline" "$timeout_min" "$interval"; do
  case $value in '' | *[!0-9]*) die "numeric value expected, got: $value" ;; esac
done
if [ -n "$head" ]; then
  case $head in *[!0-9a-f]*) die "--head must be a lowercase hex SHA" ;; esac
fi
case $effort in '' | LITE | BALANCED | MAX | AUTO) ;; *) die "unknown effort: $effort" ;; esac
owner=${repo%%/*}
name=${repo#*/}

query='query($o: String!, $r: String!, $n: Int!) {
  repository(owner: $o, name: $r) {
    pullRequest(number: $n) {
      headRefOid
      reviewRequests(first: 20) {
        nodes { requestedReviewer { ... on Bot { login } ... on User { login } } }
      }
      reviews(last: 30) {
        nodes {
          fullDatabaseId isCopilotCodeReview copilotCodeReviewEffort
          author { login } state url submittedAt body commit { oid }
        }
      }
    }
  }
}'

# The validated head, baseline, and --any flag are interpolated into the filter.
# It prints "FOUND<TAB>effort<TAB>review JSON" or "WAIT<TAB>copilot_requested".
if [ -n "$head" ]; then head_expr="\"$head\""; else head_expr='$p.headRefOid'; fi
filter='.data.repository.pullRequest as $p
  | ('"$head_expr"') as $h
  | [ $p.reviews.nodes[]
      | select((.isCopilotCodeReview == true)
          or (.isCopilotCodeReview == null and .author.login == "copilot-pull-request-reviewer"))
      | select(((.fullDatabaseId // "0") | tonumber) > '"$baseline"')
      | select('"$any"' or .commit.oid == $h) ] as $new
  | if ($new | length) > 0 then
      $new[0]
      | "FOUND\t\(.copilotCodeReviewEffort // "null")\t\({id: .fullDatabaseId, url, state,
          effort: .copilotCodeReviewEffort, commit: .commit.oid, submitted_at: .submittedAt,
          body} | tojson)"
    else
      "WAIT\t\([$p.reviewRequests.nodes[].requestedReviewer.login // empty
        | test("copilot"; "i")] | any)"
    end'

tab=$(printf '\t')
deadline=$((SECONDS + timeout_min * 60))
while :; do
  line=$(gh api graphql -F n="$pr" -f o="$owner" -f r="$name" -f query="$query" --jq "$filter") ||
    die "could not read reviews for $repo#$pr"
  kind=${line%%"$tab"*}
  rest=${line#*"$tab"}
  if [ "$kind" = FOUND ]; then
    found_effort=${rest%%"$tab"*}
    printf '%s\n' "${rest#*"$tab"}"
    if [ "$any" = false ] && [ -n "$effort" ] && [ "$found_effort" != null ] &&
      [ "$found_effort" != "$effort" ]; then
      exit 20
    fi
    exit 0
  fi
  if [ "$SECONDS" -ge "$deadline" ]; then
    printf '{"result":"timeout","copilot_requested":%s}\n' "${rest:-false}"
    exit 21
  fi
  sleep "$interval"
done
