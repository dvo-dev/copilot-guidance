# Run state

How [plan-to-pr](SKILL.md), [review-fix-loop](../review-fix-loop/SKILL.md),
and [copilot-review-loop](../copilot-review-loop/SKILL.md) record a run, so
that the same session can resume it after an interruption, such as a closed
laptop, a restart, or a stopped turn, without repeating or skipping a step.

## Contents

- Run directory and run identity
- The state file
- The ledger and finding progress
- Recording rules
- Resume

## Run directory and run identity

- A run keeps its records in `dev-loop/<branch>/` in the host's session
  artifact directory, never in the repository: `state.md`, `ledger.md`,
  `packets/`, `reviews/`, and files such as reply and summary bodies.
- The records are private to the session. To continue an interrupted run,
  reopen the same session and ask it to continue, or invoke the same skill
  again. Another session cannot see the records, so it would start a new run.
- A run's ID is its start time in UTC, as `YYYYMMDDTHHMMSSZ`. "Since the run
  began" means since that time.
- When a loop starts, it reads `state.md` and takes the first matching row:

  | `state.md` | Action |
  | --- | --- |
  | Missing | Start a new run. |
  | The other loop is `running` | Stop and ask. |
  | This loop is `not started` | Continue the run, for example copilot-review-loop after review-fix-loop finished in the same run, or a loop that plan-to-pr starts. |
  | This loop is `running` | Resume it, as "Resume" describes. |
  | This loop is `done` | Start a new run. |

- To start a new run while a run directory exists, first rename it to
  `dev-loop/<branch>@<its run ID>/`. A new run numbers its findings from 1
  again. Earlier runs' ledgers still count as evidence when adjudicating, but
  never go to reviewers.

## The state file

`state.md` is a living log in this shape. A loop run on its own leaves out the
`Lock` and `Path` lines, which belong to plan-to-pr.

```markdown
# dev-loop state: <branch>

- Run: <run ID> · started <UTC time> · repository <OWNER/REPO>
- Lock: <lock path>, owner=<session>, phase=<number and name, or done>, updated=<UTC time>
- Path: <full | light> (<reason>)
- Settings: reviewer effort <level>, Copilot review effort <level>, local fix cycles <N>, PR fix cycles <M>
- Base: <branch> @ <sha> · Head: <sha> · PR: <url or none>
- Checks: <commands> · Baseline failures: <list or none>
- Local loop: <not started | running | done: exit reason> · reviews <n> · fix cycles <n>/<N>
- PR loop: <not started | running | done: exit reason> · reviews <n> · fix cycles <n>/<M> · last Copilot review <ID or none>
- Pushed by this run: <short SHAs, or none>
- Final review: <effort and head, or none>
- Summary comment: <ID, or none>
- In flight: <the step under way, or none>

## Progress
## Surprises & Discoveries
## Decision Log
## Outcomes
```

`Head` is the latest commit this run recorded. `In flight` names a step that
must not run twice, from just before it starts until its result is recorded:

- `round L2 launched, packets/L2.md, head <sha>`, then `round L2 saved` once
  both raw outputs are saved. Cleared when the round's ledger rows are
  written.
- `fix cycle 2 for L2.1, L2.3, touching <paths>`. Add each path before
  changing it. Cleared when the cycle's commit is recorded, or for
  copilot-review-loop, its push.
- `Copilot review 2: requesting for <head>`, then
  `Copilot review 2: requested <effort>, baseline <ID>, at <time>`. Cleared
  when the review is found and its ID is recorded.

## The ledger and finding progress

`ledger.md` has one row per finding:

| ID | Round | Source | Sev | Location | Summary | Disposition | State | Evidence | Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

`State` is the last completed step for the finding. A row starts at `open`,
or at `done` when the finding needs no step. The steps depend on the kind of
finding and its disposition, and a finding is finished at its last step:

| Finding | Disposition | Steps after `open` |
| --- | --- | --- |
| Plan review (`P`) | any | `done` |
| Local (`L`) | fix | `committed <sha>` |
| Local | any other | `done` |
| Copilot (`C`) with a thread | fix | `committed <sha>`, `pushed <sha>`, `replied`, `resolved ADDRESSED` |
| Copilot with a thread | reject | `replied`, `resolved INVALID` |
| Copilot with a thread | defer | `replied`, `resolved WONT_FIX` |
| Copilot with a thread | escalate, or valid but not fixed | `replied` |
| Copilot with no thread | fix | `committed <sha>`, `pushed <sha>` |
| Copilot with no thread | any other | `done` |

When a stop condition holds back a push, a committed Copilot fix goes from
`committed <sha>` to `replied`, with the "fixed but not pushed" reply, and
stays unresolved.

## Recording rules

- Record a step right after it succeeds, never before.
- Before a step that must not run twice, set `In flight`; clear it once the
  result is recorded.
- Write a round's ledger rows all at once, after adjudicating every finding.
- A fix-cycle commit lists its finding IDs in the body, as
  `Findings: L1.1, L1.3`, and a Copilot thread reply ends with
  `<!-- copilot-review-loop:reply id=<finding-id> -->`. These identify the
  step in git or on GitHub if the session stops before recording it.
- Set the loop's status to `running` when it starts, and to `done` with the
  exit reason when it reports.

## Resume

1. Read `state.md` and `ledger.md`. Confirm that the current branch is the
   run's branch, and that `HEAD` is the recorded head or follows it only
   through commits this run made, such as a fix-cycle commit or a
   `Fix gate failures` commit. Otherwise stop and ask.
2. Record steps that happened but were not recorded:
   - `committed`: a commit after the recorded head whose body lists the
     finding ID.
   - `pushed`: after `git fetch`, the remote branch contains the commit.
   - `replied`: the thread has the finding's reply marker, shown as
     `agent_replied` by copilot-review-loop's `review-threads.sh`.
   - `resolved`: the thread is resolved.
3. Finish the `In flight` step:
   - A round launched but not saved: run it again with fresh reviewers, using
     the saved packet if `HEAD` still matches its head, and otherwise a new
     packet. A round saved but not adjudicated: adjudicate the saved outputs.
   - A fix cycle: keep its work only if every modified or untracked path is on
     its list, then run the gate and commit as the loop describes. Otherwise
     stop and ask. Never discard work.
   - A Copilot review request: see copilot-review-loop's "Resume".
4. Continue as the loop's "Resume" section describes. Waits get a fresh time
   budget.
