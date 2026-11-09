# Summary format

The format of the final summary comment that
[copilot-review-loop](SKILL.md#4-final-summary) posts on the PR. Keep it to
at most about 40 lines, with a plain voice and no emoji headers.

````markdown
<!-- copilot-review-loop:summary run=<run ID> -->
**Copilot review loop:** <exit reason> · reviews triaged: <k> (<effort of each>) · fix cycles: <n>/<N> · CI: <green | red | none | unknown> · head: <short-sha>
**Settings:** peer reviewers <model A> and <model B> at <reviewer effort> · Copilot review effort <level> · fix cycles <N>

**Needs human judgment**
- <ID>: <the question or blocker> ([thread](<url>))

**Addressed**
- <ID>: <one line> (<short-sha>)

**Not addressed**
- <ID>: <INVALID | WONT_FIX>: <one-line reason>

**Residual risk / not verified**
- <what was not tested or checked>

<sub>Posted by an agent running copilot-review-loop. The PR stays a draft until a human marks it ready.</sub>
````

Always include **Needs human judgment**, writing "None" when it is empty. List
the local loop's unfixed valid findings and its escalations there too, without
a thread link, and any fix that was committed but not pushed, with its local
commit. When step 3.8 requested a final review, list it there as well: its
effort, the head it covers, and that the agent did not triage it, so its
comments need a direct read. If that request returned exit 10, list instead
that no review was requested for the final head, and ask a person to request
one at the configured effort if no review of that head lands. Omit other
sections that would be empty.
