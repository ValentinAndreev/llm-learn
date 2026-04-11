---
id: intake_check_completeness
purpose: Evaluate whether the intake dialog contains enough information to generate a learning brief
expected_output: A structured assessment with status (complete or incomplete), and if incomplete, a list of what is still missing
required_variables:
  - "{{dialog_history}}"
---

Review the following intake dialog and assess whether it contains sufficient information to generate a structured learning brief.

Dialog history:
{{dialog_history}}

Evaluate whether each of the following fields has been clearly established:
- Topic (what the user wants to learn)
- Scope (how broad or narrow the focus is)
- Depth level (beginner / intermediate / advanced)
- Prior knowledge (what the user already knows)
- Learning goals (what the user wants to achieve)

Respond with a structured assessment in the following format:

**Status**: complete | incomplete

**Covered fields**:
- List each field that has been sufficiently addressed

**Missing fields** (if incomplete):
- List each field that is absent or too vague to use

Do not generate the brief yet. Only assess readiness.
