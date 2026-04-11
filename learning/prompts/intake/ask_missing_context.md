---
id: intake_ask_missing_context
purpose: Ask the user targeted questions to fill in information that is still missing from the intake dialog
expected_output: A short set of focused questions addressing the specific missing fields, without repeating already-answered questions
required_variables:
  - missing_fields
  - dialog_summary
---

Based on the conversation so far, here is what we know about the user's learning goal:

{{dialog_summary}}

The following information is still missing:

{{missing_fields}}

Formulate a short set of focused questions — one per missing field — to gather this information from the user. Ask only what is listed above. Do not repeat information already covered in the summary. Do not start teaching.
