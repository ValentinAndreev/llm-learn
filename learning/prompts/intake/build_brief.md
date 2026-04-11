---
id: intake_build_brief
purpose: Generate a structured learning brief from a completed intake dialog
expected_output: A formatted learning brief capturing topic, scope, depth level, prior knowledge, and learning goals
required_variables:
  - "{{dialog_history}}"
---

Using the intake dialog below, generate a structured learning brief.

Dialog history:
{{dialog_history}}

Produce the brief in the following format:

---

**Learning Brief**

**Topic**: [The subject or skill to be learned]

**Scope**: [How broad or narrow the focus is]

**Depth level**: [Beginner / Intermediate / Advanced]

**Prior knowledge**: [What the learner already knows about this topic]

**Learning goals**:
- [Goal 1]
- [Goal 2]
- [Goal 3 — add or remove as needed]

**Notes**: [Any additional context, constraints, or preferences mentioned by the user — omit this section if none]

---

Be precise and faithful to what the user said. Do not add assumptions or invent details not present in the dialog.
