# Example 2: Delivery & Release Gate Invocation

When code implementation, unit tests, and Tier-1 code review are complete, the Main Agent dispatches to the `advisor` subagent for the definitive release gate verdict:

### Task Tool Invocation:
```json
{
  "description": "Final gatekeeper release verification",
  "prompt": "Evaluate production code readiness for the completed WAL-checkpointing deliverable.\n\nDiff Target: HEAD~1\nAffected files: src/storage/wal_manager.py, tests/test_wal_checkpoint.py\nVerification Evidence: pytest tests/test_wal_checkpoint.py passed with 8/8 tests in 0.42s.\n\nPlease inspect reverse blast radius with sot_diff_impact / sot_usages, verify invariants, and issue the final gatekeeper verdict.",
  "subagent_type": "advisor"
}
```
