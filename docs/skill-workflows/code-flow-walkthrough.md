# Code flow walkthrough

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/code-flow-walkthrough/SKILL.md)

This skill supports the factory when a person needs to understand the system
before approving a plan or a code decision.

**Use it when:** the user wants to learn one code flow over several turns.

**Result:** one scenario carried from entry point to final state, with a recap.

> [!WARNING]
> Mermaid links in this diagram are pinned to `main` because GitHub cannot
> resolve document-relative node links inside its Mermaid iframe. A new target
> can return 404 before merge; use the relative Markdown links below the
> diagram for same-ref navigation.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Identify entry point,<br/>revision, actor, and scenario") --> B("Trace every function<br/>that this scenario reaches")
    B --> C("Split the path<br/>into major logical segments")
    C --> D("Show overview map,<br/>scenario, and starting state")
    D --> E("Show one segment:<br/>chain, excerpt, state, and sources")
    E --> V{"Focused branch or<br/>outcome comparison?"}
    V -->|Yes| X{{"Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/main/docs/skill-workflows/visual-explanations.md'>visual-explanations</a><br/>for this decision"}}
    X --> F{"User chooses next?"}
    V -->|No| F
    F -->|Next segment| E
    F -->|Go deeper or what-if| G("Stay on the same scenario<br/>and map")
    G --> E
    F -->|Stop or last segment| H(["Show checkpoint table,<br/>full chain, and invariants"])

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef delegated fill:#1f2335,stroke:#bb9af7,stroke-width:1.5px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,B,C,D,E,G stage;
    class X delegated;
    class H outcome;
    class V,F decision;

```

For a focused branch or output comparison, use
[`visual-explanations`](visual-explanations.md) instead of a multi-turn
walkthrough. This page does not redraw the delegated visual flow.

## Synthetic walkthrough segment

<details>
<summary>Open the synthetic billing-ledger walkthrough</summary>

**Synthetic example:** The scenario, functions, source excerpts, and state are
fictional.

**Scenario:** In a billing ledger, account `acct-9` starts with a $100 credit.
The worker receives usage event `usage-731` for a $60 charge. The same event
arrives again after a worker retry.

### 2. `BillingService.post_usage_charge`: post once or return the original

**You are here**

```text
BillingWorker.handle
  -> BillingService.post_usage_charge  ◀ you are here
       -> Ledger.find_by_event_id
       -> Ledger.append_entry
       -> Account.update_balance
```

```python
# In BillingService.post_usage_charge (synthetic)
entry = ledger.find_by_event_id(account_id, usage_event_id)
if entry:
    return entry

entry = ledger.append_entry(
    account_id=account_id,
    usage_event_id=usage_event_id,
    amount=-money(60, 0),
)
return entry
```

For the first delivery, `find_by_event_id` returns no row. The service appends
one `-$60` entry. For the retry, the lookup returns that same entry, so the
write path is not entered.

| State | Before | After first delivery | After retry |
| --- | ---: | ---: | ---: |
| Account balance | $100 | $40 | $40 |
| Ledger entry for `usage-731` | Not present | `entry-204`, debit $60 | Same `entry-204` |
| New writes | - | 1 ledger entry | 0 |

This keeps the account from being charged twice for one usage event. The
next walkthrough segment would examine the concurrent-request conflict path,
where both workers observe the event as missing before either transaction
finishes.

</details>
