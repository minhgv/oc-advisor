# Sample Advisor Verdicts

## Example A: Approved (Blueprint Gate)

```markdown
### ADVISOR VERDICT: APPROVED
**Executive Summary:** The blueprint defines strict boundaries, isolates file ownership cleanly across waves, and establishes an observable verification target without speculative dependencies.
**Verified Invariants:**
- Grounded against physical codebase: verified `src/storage/` module structure via `sot_search`.
- Blast radius bounded: no public API signatures altered.
**Residual Risks / Blockers:**
- None
```

---

## Example B: Needs Revision / Rejected (Delivery Gate with Blocker)

```markdown
### ADVISOR VERDICT: NEEDS_REVISION
**Executive Summary:** Implementation leaves a potential file handle leak in the error path of WAL truncation, and blast radius analysis revealed an unhandled upstream caller in `session_store.py`.
**Verified Invariants:**
- Reverse call graph blast radius check (`sot_diff_impact`) failed: `session_store.py:142` calls `checkpoint()` with obsolete argument arity.
- Invariant breached: Subprocess execution does not release write lock upon timeout.
**Residual Risks / Blockers:**
- Blocker 1: Fix upstream caller signature in `src/storage/session_store.py:142`.
- Blocker 2: Wrap WAL file descriptor in `try...finally` to guarantee resource cleanup.
```
