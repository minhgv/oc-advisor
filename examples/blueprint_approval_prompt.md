# Example 1: Blueprint Approval Invocation

When the Main Agent / Planner finishes drafting an architectural blueprint or JIT Wave plan, it dispatches directly to the `advisor` subagent:

### Task Tool Invocation:
```json
{
  "description": "Gatekeep architectural blueprint",
  "prompt": "Evaluate this blueprint for architectural integrity, user business flows, and edge cases:\n\n# BLUEPRINT: SOT-Graph Session Persistence Optimization\n\n## Objective & Scope\n- Goal: Add atomic WAL-checkpointing to avoid database lock contention during concurrent subagent queries.\n- Non-goals: Modifying AST parser schema or indexing pipeline.\n\n## Architecture & Interfaces\n- Input: `runSot(['checkpoint', '--mode', 'truncate'])`.\n- Invariant: Zero write-lock retention beyond 50ms.\n\n## Wave DAG & File Ownership\n- Wave 1: `src/storage/wal_manager.py` (Worker 1)\n- Wave 2: `tests/test_wal_checkpoint.py` (Worker 2)\n\n## Business Scenarios & Edge Cases (Mandatory Test Matrix)\n1. Epic Story Flow:\n   - User starts concurrent subagent queries -> WAL manager triggers automatic checkpoint -> Read queries proceed without SQLite lock timeout.\n2. Business Edge Cases:\n   - Checkpoint attempted while write-lock is held by an external process (Retry with exponential backoff vs immediate abort).\n   - Process crash mid-truncation (WAL recovery on next startup without corrupted journals).\n   - Monorepo with read-only filesystem (Graceful degradation, return actionable error).\n\n## Acceptance Criteria & Execution Command\n- Command: `pytest tests/test_wal_checkpoint.py -v`\n- Success condition: 8/8 test cases passed including edge case assertions.\n- Zero disk drift reported by `sot_verify_drift`.",
  "subagent_type": "advisor"
}
```
