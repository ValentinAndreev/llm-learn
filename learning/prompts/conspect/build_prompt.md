---
id: conspect_build_prompt
purpose: Generate a full structured learning conspect from a learning brief
expected_output: A well-structured markdown document covering topic overview, key concepts, learning path, and depth-appropriate content
required_variables:
  - brief
---

Using the learning brief below, generate a comprehensive learning conspect for the topic described in the brief.

Learning brief:
{{brief}}

Produce the conspect as a structured markdown document in the following format:

---

## Learning Conspect

### Overview
[2–4 sentences describing what this topic is, why it matters, and what the learner will be able to do after completing this learning path]

### Key Concepts
List the core concepts the learner must understand, grouped by theme if applicable:

1. **[Concept name]** — [Brief explanation]
2. **[Concept name]** — [Brief explanation]
3. [Add or remove entries as needed]

### Learning Path
A step-by-step progression tailored to the learner's depth level and prior knowledge:

**Step 1 — [Stage name]**
- [What to study or do]
- [Expected outcome]

**Step 2 — [Stage name]**
- [What to study or do]
- [Expected outcome]

[Continue for all stages]

### Depth-Appropriate Content
Specific topics, resources, or exercises matched to the learner's level:

- [Item 1]
- [Item 2]
- [Item 3 — add or remove as needed]

### Practice & Validation
Suggested exercises, projects, or checkpoints to confirm understanding:

- [Exercise or project 1]
- [Exercise or project 2]

### Notes
[Any constraints, preferences, or contextual details from the brief that shaped this conspect — omit section if none]

---

Guidelines:
- Stay faithful to the scope, depth level, and goals stated in the brief
- Do not invent prerequisites or goals not mentioned in the brief
- Adjust detail density to match the stated depth level (beginner = more explanation; advanced = more precision)
- Keep the conspect actionable: every section should help the learner know what to do next
