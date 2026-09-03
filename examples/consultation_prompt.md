# Example 0: Pre-Planning Consultation Invocation (Shift-Left Guidance)

When the Main Agent / Planner wants architectural guidance, file boundaries, or edge case recommendations *before* drafting a plan:

### Task Tool Invocation:
```json
{
  "description": "Consult advisor for plan direction and edge cases",
  "prompt": "I plan to implement Redis caching for the authentication session tokens in this repository.\n\nBefore I draft the blueprint, please provide architectural consultation:\n1. What existing modules or utilities should I reuse?\n2. What are the strict file ownership boundaries to prevent regression?\n3. What critical business invariants and security boundaries must be preserved?\n4. What is the mandatory checklist of business edge cases (token expiration, race conditions, cluster failure) that my blueprint must cover?",
  "subagent_type": "advisor"
}
```

### Expected Output:
Advisor inspects the physical codebase via SOT-Graph, maps callers, and returns structured guidance (without a Gatekeeper `APPROVED/REJECTED` verdict) so the Planner can write a bulletproof blueprint on the first try.
