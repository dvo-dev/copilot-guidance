---
name: plan-walkthrough-quiz
description: >-
  Teach a plan, design, or large change in layers before asking for approval:
  a code-verified big-picture explanation built on one analogy, a per-task
  implementation walkthrough, one-question-at-a-time quizzes, and a recap table
  kept in the plan file. Use when the user asks for an ELI5, walkthrough, or
  quiz on a plan, says they need to understand it first, or declines plan
  approval to understand it rather than to change it.
---

# Plan walkthrough and quiz

Help the user understand a plan well enough to approve it with confidence.
Teach in layers: a plain-language big picture first, then implementation detail,
then short quizzes that check understanding and re-teach what was missed. The
plan file holds the long content and becomes a study sheet for whoever
implements it.

Respect the host repository's instructions, safety rules, and approval gates.
A request to explain or quiz does not authorize code changes or approval.

## Inputs and scope

Identify the plan or design being taught, where it lives, the code revision it
describes, and which tasks or parts the user wants to understand. Build on what
the user has already shown they understand; do not restart from zero after each
layer.

If there is no plan file, write the teaching layers into the host's plan or
session artifact rather than the repository. Ask before adding them to a
tracked file.

A declined approval that says "I need to understand X first" is a request for
teaching, not for a different plan. Change the plan only when the user asks for
a change or verification shows the plan is wrong.

## 1. Ground the plan in code

- Tie every claim about current behavior to the code with a file:line
  reference.
- Label each statement as confirmed in code `[C]`, proposed `[P]`, or decided
  with the user `[D]`, so the user can tell fact from open proposal.
- Before presenting any layer, re-verify its claims against the current code.
  If the plan has drifted, fix the plan first and say what changed. For
  example, a flow the plan describes as six steps may turn out to have five.
- Do not invent behavior, names, or numbers that were not verified. Mark
  anything unverified as unknown.

## 2. Big-picture ELI5 layer

Write this at the top of the plan file, then summarize it briefly in chat.

- **Goal:** the overall initiative in plain words, in two or three sentences.
- **Ladder:** a Mermaid ladder of milestones that shows where this batch sits
  and what comes before and after it. Use ASCII if the host does not render
  Mermaid.
- **One analogy:** pick one concrete physical analogy and reuse it everywhere,
  including in quiz explanations. For example, a jar for a limit and a cup for
  what has been used this period. Do not switch metaphors between layers.
- **Why each piece exists:** a table with the columns Piece, Problem it solves,
  and What breaks without it, with one row per piece.
- **One persona's story:** follow one user or actor chronologically and show
  where each piece touches their story.
- **Non-goals:** say explicitly what this batch does not do.

## 3. Implementation walkthrough per task

For each task, cover:

- what code is added and where: files, new types, and method signatures;
- the step-by-step call flow, following the
  [visual-explanations conventions](../visual-explanations/SKILL.md#visual-conventions)
  when a diagram helps;
- the safety mechanism, such as idempotency keys, ordering guards, optimistic
  concurrency, or feature flags, and exactly what each one protects;
- edge cases and what happens in each;
- why the steps are ordered the way they are.

Keep the chat version compact, a few lines per task, and put the full version
in the plan file. Point to the plan sections where the user can go deeper.

## 4. Quiz one question at a time

- Ask one question per call to the host's question tool, such as `ask_user`.
- Use multiple choice with 3-4 options. Do not add an "Other" option when the
  tool already accepts a freeform answer.
- Prefer scenario questions with concrete numbers, such as "The limit changes
  mid-month with $15 already used. What is left?"
- Make each distractor a real, likely misconception: "replace the whole record"
  versus "patch with a guarded increment", or "the feature flag protects reads
  too". Vary the position of the correct option.
- Test invariants and behaviors, not trivia such as file or function names.
- After each answer, say whether it was right or wrong and why in 2-4
  sentences, tied back to the analogy.
- Run rounds of about four questions and report the score after each round.

## 5. Keep a recap table in the plan file

Add a recap table to the plan file and update it after every round:

| # | Question | Answer |
| --- | --- | --- |
| 3 | An older event arrives after a newer one was applied | Stale: compare the event time to the stored one and make no writes. |

The Answer column holds the concise canonical answer, not the user's choice.
Add a row for every concept quizzed, especially misses, so the plan doubles as
a study sheet for the implementer.

## 6. Re-teach misses

- When the user misses two or more related ideas, tell one worked-example story
  with concrete numbers that ties those ideas together, using the same analogy.
- Then run a mini-quiz of 2-3 questions on just those ideas and add recap rows.
- If a concept is still missed, add a dedicated recap row that restates the
  rule plainly, and offer to go deeper on it.

## 7. Loop until the user is ready

- After each layer or round, offer next steps with the question tool, for
  example "Quiz me on this", "Go deeper on one part", and "Got it, show me the
  plan for approval".
- Request approval, for example by exiting plan mode, only after the user picks
  the ready option.
- If the user declines approval with "I still need to understand X", teach
  another layer on X. Never re-request approval without new teaching in
  between.

## Style

- ELI5 first, then depth.
- Short chat messages; long content goes in the plan file.
- Concrete numbers in examples and questions.
- One name per concept, used consistently across chat, plan, and quiz.
- Gloss new jargon the first time it appears, for example "idempotency key (a
  unique ID that lets a repeat be recognized and skipped)".

## Anti-patterns

- Dumping the whole plan into chat.
- Bundling several questions into one prompt.
- Trick wording, or options that differ only in phrasing.
- Moving on without explaining a wrong answer.
- Assuming the user understands without checking.
- Inventing facts that were not verified in code.

## Boundaries

Teaching is read-only for the repository. Write only to the plan file or the
host's plan artifact. Do not edit code, push, or change shared state while in
this loop unless the user has approved the plan. Do not request or assume
approval on the user's behalf.

## Synthetic example

This example describes no real system. A team keeps a shared snack fund with a
monthly limit, and the plan adds a way to change the limit mid-month.

Big picture, in the plan file: "The fund is a jar that is refilled to its limit
on the first of each month. Every purchase pours from the jar into a cup, which
shows what has been spent this month. Changing the limit swaps in a bigger or
smaller jar; it never empties the cup."

Quiz question, asked on its own:

> The limit is raised from $50 to $80 on the 12th, with $15 already spent. How
> much can the team still spend this month?
>
> A. $80: saving the new limit rewrites the record, so spending starts over.
> B. $65: the limit changes and the $15 already spent stays.
> C. $35: a new limit only applies from next month.

The user picks A. Reply: "Not quite. The update patches only the limit; it
does not touch what has been spent. The jar got bigger, but the $15 is still in
the cup, so $80 minus $15 leaves $65."

Recap row added to the plan file:

| # | Question | Answer |
| --- | --- | --- |
| 1 | Limit raised from $50 to $80 mid-month with $15 spent | $65 left: patch only the limit and keep what was spent. |

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| "ELI5 this plan before I approve it" | Verify claims, write the big-picture layer to the plan file, summarize briefly, and offer next steps. |
| "Quiz me on this" | Ask one scenario question at a time, explain each answer, and report the score after about four. |
| User declines approval: "I still need to understand the retry part" | Teach a layer on retries and quiz it; do not change the plan or re-request approval yet. |
| User misses two questions about ordering and duplicates | Tell one worked story with numbers covering both, run a 2-3 question mini-quiz, and add recap rows. |
| Re-check finds the plan describes a flow incorrectly | Fix the plan and say what changed before teaching from it. |
| User picks "Got it, show me the plan for approval" | Request approval through the host's mechanism. |
