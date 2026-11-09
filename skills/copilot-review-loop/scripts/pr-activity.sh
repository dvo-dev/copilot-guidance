#!/usr/bin/env bash
# List activity on a pull request from people, since a given time.
#
# Usage: pr-activity.sh OWNER/REPO PR_NUMBER SINCE
#
# SINCE is an ISO 8601 UTC time, such as 2026-11-09T21:12:00Z, usually the
# run's start. Prints a JSON array with one item per review, review comment, or
# pull request comment at or after SINCE that came from a person:
#   {"kind": "review" | "review_comment" | "comment", "author", "created_at",
#    "state", "url", "excerpt"}
# Copilot code review and other bot accounts never count. Neither do posts
# that carry a hidden copilot-review-loop marker, which identifies the loop's
# own posts even when the agent runs under the user's account. A review that
# only holds the loop's marked thread replies is skipped. Approvals, change
# requests, dismissed and pending reviews always count, because the loop never
# creates them. An empty array means no person has reviewed or commented.
#
# Exit codes: 0 ok; 2 usage or unexpected error.
set -euo pipefail

die() {
  printf '%s\n' "$*" >&2
  exit 2
}

[ $# -eq 3 ] || die "usage: $0 OWNER/REPO PR_NUMBER SINCE"
command -v gh >/dev/null 2>&1 || die "gh is required"
repo=$1
pr=$2
since=$3
case $repo in */*) ;; *) die "OWNER/REPO expected, got: $repo" ;; esac
case $pr in '' | *[!0-9]*) die "PR_NUMBER must be numeric, got: $pr" ;; esac
# The filters compare SINCE with GitHub's timestamps as strings, so the format
# must match exactly. The check also makes SINCE safe to put in the filter.
printf '%s' "$since" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' ||
  die "SINCE must look like 2026-11-09T21:12:00Z, got: $since"
owner=${repo%%/*}
name=${repo#*/}

reviews_query='query($o: String!, $r: String!, $n: Int!, $endCursor: String) {
  repository(owner: $o, name: $r) {
    pullRequest(number: $n) {
      reviews(first: 50, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          author { __typename login } isCopilotCodeReview state body url
          submittedAt createdAt
          comments(first: 100) {
            nodes { author { __typename login } isCopilotCodeReview body url createdAt }
          }
        }
      }
    }
  }
}'
comments_query='query($o: String!, $r: String!, $n: Int!, $endCursor: String) {
  repository(owner: $o, name: $r) {
    pullRequest(number: $n) {
      comments(first: 100, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes { author { __typename login } body url createdAt }
      }
    }
  }
}'

# Shared definitions: who counts as a person, and what the loop's marker is.
defs='def marked: (. // "") | contains("<!-- copilot-review-loop");
  def machine: .author == null or .author.__typename == "Bot"
    or .author.login == "copilot-pull-request-reviewer" or .isCopilotCodeReview == true;
  def item($kind; $time): {kind: $kind, author: .author.login, created_at: $time,
    state: (.state // null), url, excerpt: ((.body // "") | gsub("\\s+"; " ") | .[0:120])};'

# One JSON object per line, for reviews and the comments inside them.
reviews_filter="$defs"'
  .data.repository.pullRequest.reviews.nodes[]
  | select(machine | not)
  | (.submittedAt // .createdAt) as $t
  | select($t >= "'"$since"'")
  | [.comments.nodes[] | select((machine | not) and (.body | marked | not))] as $people
  | ( if .state != "COMMENTED" then item("review"; $t)
      elif (.body // "") != "" and (.body | marked | not) then item("review"; $t)
      elif (.body // "") == "" and (.comments.nodes | length) == 0 then item("review"; $t)
      else empty end ),
    ($people[] | item("review_comment"; .createdAt))
  | tojson'
comments_filter="$defs"'
  .data.repository.pullRequest.comments.nodes[]
  | select((machine | not) and (.body | marked | not) and .createdAt >= "'"$since"'")
  | item("comment"; .createdAt)
  | tojson'

review_lines=$(gh api graphql --paginate -F n="$pr" -f o="$owner" -f r="$name" \
  -f query="$reviews_query" --jq "$reviews_filter") || die "could not read reviews for $repo#$pr"
comment_lines=$(gh api graphql --paginate -F n="$pr" -f o="$owner" -f r="$name" \
  -f query="$comments_query" --jq "$comments_filter") || die "could not read comments for $repo#$pr"

# Join the per-item lines into one JSON array.
lines=$(printf '%s\n%s\n' "$review_lines" "$comment_lines" | sed '/^$/d')
if [ -z "$lines" ]; then
  printf '[]\n'
else
  printf '[%s]\n' "$(printf '%s\n' "$lines" | paste -s -d, -)"
fi
