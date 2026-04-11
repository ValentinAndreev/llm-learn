---
id: conspect_self_review
purpose: Review a generated conspect for quality and completeness, then suggest improvements or flag gaps
expected_output: A structured review identifying strengths, missing elements, and recommended changes to the conspect
required_variables:
  - "{{conspect}}"
  - "{{brief}}"
---

Review the learning conspect below against the original learning brief. Assess its quality and completeness, then produce a structured critique with actionable recommendations.

Original learning brief:
{{brief}}

Generated conspect to review:
{{conspect}}

Produce the review in the following format:

---

## Conspect Review

### Overall Assessment
[1–3 sentences summarizing the quality of the conspect and whether it meets the goals stated in the brief]

### What Works Well
- [Strength 1 — specific and concrete]
- [Strength 2]
- [Add or remove as needed]

### Gaps & Missing Elements
List anything required by the brief that the conspect fails to address:

- [Gap 1 — reference the specific brief requirement it misses]
- [Gap 2]
- [Write "None identified" if the conspect is complete]

### Quality Issues
List structural, clarity, or accuracy problems independent of the brief:

- [Issue 1 — e.g. a concept explanation that is vague or incorrect]
- [Issue 2]
- [Write "None identified" if no issues found]

### Recommended Changes
Concrete, prioritized suggestions for improving the conspect:

1. [Change 1 — most important]
2. [Change 2]
3. [Add or remove as needed]

### Verdict
[One of: **Approved** / **Needs minor revision** / **Needs major revision**]
[One sentence justifying the verdict]

---

Guidelines:
- Judge the conspect strictly against the brief — do not penalize for omitting things the brief did not request
- Be specific: vague feedback like "could be better" is not acceptable
- If the conspect is well-formed and complete, say so clearly rather than inventing criticism
- Focus on what matters to the learner: actionability, accuracy, and alignment with stated goals
