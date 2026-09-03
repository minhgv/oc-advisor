# Sample Advisor Verdicts

## Example A: Approved (Blueprint Gate)

```markdown
### ADVISOR VERDICT: APPROVED
**Executive Summary:** The blueprint defines strict architectural boundaries, complete user business scenarios, and explicit edge case handling for concurrent lock contention and process recovery.

**Verified Invariants & Architecture:**
- Grounded against physical codebase: verified `src/storage/` module structure via `sot_search`.
- Blast radius bounded: no public API signatures altered.

**Verified Business Tests & Edge Cases:**
- **User / Epic Story Flows:** Concurrent reader query flow during active checkpointing is explicitly covered.
- **Business Edge Cases:** Lock contention backoff, mid-truncation crash recovery, and read-only permissions failure modes are all specified.
- **Execution Evidence:** Target command `pytest tests/test_wal_checkpoint.py -v` defined with clear assertions.

**Residual Risks / Blockers:**
- None
```

---

## Example B: Rejected (Blueprint Gate - Missing Business Edge Cases)

```markdown
### ADVISOR VERDICT: REJECTED
**Executive Summary:** The blueprint provides an implementation skeleton but completely lacks business edge cases and user journey verification for unauthorized access and double-submission.

**Verified Invariants & Architecture:**
- Architecture draft is syntactically coherent, but invariants are incomplete.

**Verified Business Tests & Edge Cases:**
- **User / Epic Story Flows:** Only covers simple single-call success path.
- **Business Edge Cases:** Missing crucial edge cases: (1) Expired token during mid-transaction, (2) Duplicate payment request with same Idempotency-Key, (3) Insufficient balance boundary condition.
- **Execution Evidence:** Test specification is absent (no target CLI test command).

**Residual Risks / Blockers:**
- Blocker 1: Plan must add an explicit "Business Scenarios & Edge Cases" section specifying test assertions for concurrent double-clicks and tenant isolation.
- Blocker 2: Specify exact test command and test file location.
```
