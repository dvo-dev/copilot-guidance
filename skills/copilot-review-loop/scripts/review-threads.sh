#!/usr/bin/env bash
# List unresolved GitHub Copilot code review threads on a pull request.
#
# Usage: review-threads.sh OWNER/REPO PR_NUMBER [--all]
#
# Prints a JSON array with one item per thread whose first comment came from
# Copilot code review:
#   {"thread_id", "comment_id", "review_id", "path", "line", "start_line",
#    "is_outdated", "is_resolved", "url", "created_at", "agent_replied",
#    "agent_replies", "body"}
# comment_id is the first comment's numeric ID, which the REST replies endpoint
# needs. agent_replied is true when a later comment in the thread carries a
# copilot-review-loop reply marker. agent_replies lists those markers' contents,
# such as "run=20261109T211200Z id=C1.1", so that a run can tell its own replies
# from an earlier run's. --all includes resolved threads.
#
# Exit codes: 0 ok, 2 usage or unexpected error.
set -euo pipefail

die() {
  printf '%s\n' "$*" >&2
  exit 2
}

[ $# -ge 2 ] || die "usage: $0 OWNER/REPO PR_NUMBER [--all]"
command -v gh >/dev/null 2>&1 || die "gh is required"
repo=$1
pr=$2
include_resolved=false
if [ $# -ge 3 ]; then
  [ "$3" = --all ] || die "unknown argument: $3"
  include_resolved=true
fi
case $repo in */*) ;; *) die "OWNER/REPO expected, got: $repo" ;; esac
case $pr in '' | *[!0-9]*) die "PR_NUMBER must be numeric, got: $pr" ;; esac
owner=${repo%%/*}
name=${repo#*/}

query='query($o: String!, $r: String!, $n: Int!, $endCursor: String) {
  repository(owner: $o, name: $r) {
    pullRequest(number: $n) {
      reviewThreads(first: 50, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line startLine
          comments(first: 50) {
            nodes {
              fullDatabaseId isCopilotCodeReview author { login } body url createdAt
              pullRequestReview { fullDatabaseId }
            }
          }
        }
      }
    }
  }
}'

# Keep threads started by Copilot code review; emit one compact JSON object per line.
filter='.data.repository.pullRequest.reviewThreads.nodes[]
  | select('"$include_resolved"' or (.isResolved | not))
  | .comments.nodes as $c
  | select(($c[0].isCopilotCodeReview == true)
      or ($c[0].isCopilotCodeReview == null
        and $c[0].author.login == "copilot-pull-request-reviewer"))
  | {thread_id: .id, comment_id: $c[0].fullDatabaseId,
     review_id: $c[0].pullRequestReview.fullDatabaseId,
     path, line, start_line: .startLine, is_outdated: .isOutdated,
     is_resolved: .isResolved, url: $c[0].url, created_at: $c[0].createdAt,
     agent_replied: any($c[1:][]; .body | contains("<!-- copilot-review-loop:reply")),
     agent_replies: [$c[1:][] | .body
       | scan("<!-- copilot-review-loop:reply ([^<>]*?) ?-->") | .[0]],
     body: $c[0].body}
  | tojson'

lines=$(gh api graphql --paginate -F n="$pr" -f o="$owner" -f r="$name" \
  -f query="$query" --jq "$filter") || die "could not read review threads for $repo#$pr"

# Join the per-thread lines into one JSON array.
if [ -z "$lines" ]; then
  printf '[]\n'
else
  printf '[%s]\n' "$(printf '%s\n' "$lines" | paste -s -d, -)"
fi
