# Example 2: Delivery & Release Gate Invocation

When code implementation, unit tests, and Tier-1 code review are complete, the Main Agent dispatches to the `advisor` subagent for the definitive release gate verdict:

### Task Tool Invocation:
```json
{
  "description": "Final gatekeeper release verification",
  "prompt": "Evaluate production code readiness for the completed WAL-checkpointing deliverable.\n\nDiff Target: HEAD~1\nAffected files: src/storage/wal_manager.py, tests/test_wal_checkpoint.py\n\n### Mandatory Test Execution Evidence:\nCOMMAND: pytest tests/test_wal_checkpoint.py -v\nEXIT: 0\nRESULT: pass — 8 passed, 0 failed, 0 skipped\nCOVERED SCENARIOS:\n- [Epic Flow] Concurrent 4-worker queries during active WAL truncation (passed).\n- [Edge Case 1] External lock contention backoff and retry under 50ms (passed).\n- [Edge Case 2] Abrupt process termination journal integrity check (passed).\n- [Edge Case 3] Read-only directory permissions error handling (passed).\nDURATION: 0.84s\n\nPlease inspect reverse blast radius with sot_diff_impact / sot_usages, verify invariants and business edge cases, and issue the final gatekeeper verdict.",
  "subagent_type": "advisor"
}
```
