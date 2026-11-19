Write explanations with approximately 80% adherence to ASD-STE100 Simplified Technical English.

## First implementation plans

Apply this before you write the first implementation plan for a code change that adds or changes an API, service, job, or data path. Also apply it when you write a kickoff that asks another session for such a plan. Skip it for documentation-only or trivial changes.

- Do this also when the issue, the kickoff, or I name a design. A named design is an input, not a decision.
- Search for existing entry points, operator or admin paths, and engine functions that already do part of the job. Record each relevant one with `file:line`, its known callers, and its contract. Do not write that no reusable path exists unless you also record the searches that you ran.
- Put each real option in one of these classes:
  - **Reuse, same requirements:** it meets all stated requirements.
  - **Reuse, changed requirements:** it is materially simpler, but it drops or weakens one or more stated requirements. List each change.
  - **New implementation:** state the requirement or risk that no existing path can meet.
- Classify with care:
  - A requirement limits behavior, not code. A change to shared code that keeps the protected behavior is a risk to test, not a requirement change.
  - A gap that a small change can close, such as a branch, a flag check, or a guard, is part of the reuse option. It is not a reason to reject the option.
  - Do not add an option only to reject it.
- Reject an option yourself only when it cannot do the core job, or when it breaks a mandatory safety, authorization, or isolation control. Give the concrete failure and its evidence. If the only cost of an option is weaker stated requirements, put it under "Decision needed" with its list of changes, also when you recommend a different option.
- For the recommended option and each reuse option, check real callers, automatic retries, authorization, impact, reversibility, and recovery. A different ingress can change the risk, but it does not remove mandatory safety, authorization, or isolation controls.
- Put an "Alternatives" section before the task list. Show only real options; do not add options to reach a number. If the recommendation needs a requirement change, ask me before implementation.
- In a kickoff, quote my request and do not prescribe an architecture that I did not ask for. Tell the planning session to do these steps.

```markdown
## Alternatives
Searched: <queries and paths>
| Option | Class | Evidence (`file:line`) | Requirement changes | Callers, retries, auth, recovery | Cost |
Recommendation: <option>, because <reason>.
Decision needed: <each "reuse, changed requirements" option and its changes, or none>.
```

## Pull request descriptions

- When you write a pull request description, use `/visual-explanations` to make it clear and easy for people to read.
