# Example 1: Blueprint Approval Invocation

When the Main Agent / Planner finishes drafting an architectural blueprint or JIT Wave plan, it dispatches directly to the `advisor` subagent:

### Task Tool Invocation:
```json
{
  "description": "Gatekeep architectural blueprint",
  "prompt": "Evaluate this blueprint for architectural integrity and security risks:\n\n# BLUEPRINT: SOT-Graph Session Persistence Optimization\n\n## Objective & Scope\n- Goal: Add atomic WAL-checkpointing to avoid database lock contention during concurrent subagent queries.\n- Non-goals: Modifying AST parser schema or indexing pipeline.\n\n## Architecture & Interfaces\n- Input: `runSot(['checkpoint', '--mode', 'truncate'])`.\n- Invariant: Zero write-lock retention beyond 50ms.\n\n## Wave DAG & File Ownership\n- Wave 1: `src/storage/wal_manager.py` (Worker 1)\n- Wave 2: `tests/test_wal_checkpoint.py` (Worker 2)\n\n## Acceptance Criteria\n- `pytest tests/test_wal_checkpoint.py` passes 100%.\n- Zero disk drift reported by `sot_verify_drift`.",
  "subagent_type": "advisor"
}
```
