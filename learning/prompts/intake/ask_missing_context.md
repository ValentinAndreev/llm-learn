---
id: intake_ask_missing_context
purpose: Ask the user targeted questions to fill in information that is still missing from the intake dialog
expected_output: A short set of focused questions addressing the specific missing fields, without repeating already-answered questions
required_variables:
  - "{{missing_fields}}"
  - "{{dialog_summary}}"
---

Based on the conversation so far, here is what we know about your learning goal:

{{dialog_summary}}

However, the following information is still needed to build a complete learning brief:

{{missing_fields}}

Please answer the questions above so we can move forward. Feel free to answer in your own words — there are no right or wrong answers.
