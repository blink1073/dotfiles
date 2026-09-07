---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or verifying a skill works before use
---

# Writing Skills

## Attribution

Adapted from [obra/superpowers](https://github.com/obra/superpowers) (MIT
License); tooling and cross-references adapted to this setup.

## Overview

Writing a skill is test-driven development applied to process
documentation. Write test cases (pressure scenarios), watch them fail
against agent baseline behavior, write the skill, watch agents comply,
then refactor to close loopholes.

**Core principle:** if you did not watch an agent fail without the
skill, you do not know whether the skill teaches the right thing.
Understand `test-driven-development` first; this skill adapts that cycle
to documentation.

## What a skill is

A skill is a reference guide for a proven technique, pattern, or tool.
It helps future agents find and apply effective approaches. It is not a
narrative about how you solved a problem once.

## TDD mapping for skills

| TDD concept | Skill creation |
|---|---|
| Test case | Pressure scenario with a sub-agent |
| Production code | Skill document (SKILL.md) |
| Test fails (RED) | The agent violates the rule without the skill |
| Test passes (GREEN) | The agent complies with the skill present |
| Refactor | Close loopholes while keeping compliance |

## When to create a skill

Create one when the technique was not intuitively obvious, you would
reference it across projects, the pattern applies broadly, or others
would benefit. Do not create one for a one-off solution, a
well-documented standard practice, or a project-specific convention
(that belongs in an instructions file). If a rule is enforceable by
regex or validation, automate it instead and save documentation for
judgment calls.

## Skill types

- **Technique:** a concrete method with steps (condition-based-waiting).
- **Pattern:** a way of thinking about a problem (test-invariants).
- **Reference:** API docs, syntax guides, tool documentation.

## Directory structure

```
skills/
  skill-name/
    SKILL.md              # required
    supporting-file.*     # only when needed
```

Everything lives in one flat namespace. Keep a heavy reference
(100+ lines) or a reusable tool in its own file; keep principles, code
patterns under 50 lines, and the rest inline.

## The description field (skill discovery)

The `description` tells future agents whether to load the skill. Make it
answer "should I read this right now?".

- Start with "Use when...".
- Describe **when to use only**, never **what the skill does**.
- Do not summarize the skill's process or workflow. An agent may follow
  a workflow-summarizing description and skip the skill body.

```yaml
# BAD: summarizes workflow, agents may follow it instead of reading the skill
description: Use when executing plans - dispatches a sub-agent per task with review

# GOOD: triggering conditions only
description: Use when executing an implementation plan with independent tasks
```

Keep triggers technology-agnostic unless the skill is technology
specific, and when it is, say so. Write in third person. Use concrete
trigger words and symptoms an agent would search for; keep it under 500
characters where possible.

## Skill body structure

- **Overview:** what it is, core principle in one or two sentences.
- **When to use:** a small flowchart only if the decision is not obvious;
  bullet lists for symptoms and cases, plus when not to use it.
- **Core pattern** (for techniques and patterns): before and after code
  comparison.
- **Quick reference:** a table or bullets for common operations.
- **Implementation:** inline code for simple patterns; a file link for
  heavy reference or reusable tools.
- **Common mistakes:** what goes wrong and the fix.

## Match the form to the failure

Before writing guidance, classify the baseline failure; the form that
fixes one type backfires on another.

| Baseline failure | Right form | Wrong form |
|---|---|---|
| Skips a rule under pressure (knows better, does it anyway) | Prohibition + rationalization table + red flags | Soft guidance ("prefer...", "consider...") |
| Output has the wrong shape (bloated prompt, buried verdict) | A positive recipe: state what the output is, its parts in order | A prohibition list |
| Omits a required element it already produces elsewhere | A REQUIRED field or slot in the template | Prose reminders near the template |
| Behavior should depend on a condition | A conditional keyed to an observable predicate | An unconditional rule with exemptions |

No nuance clauses: "don't X unless it matters" reopens the negotiation.
Express a real exception as its own conditional on an observable
predicate.

## Bulletproofing against rationalization

For discipline skills, forbid the specific workarounds, not just the
rule:

```markdown
Write code before the test? Delete it and start over.
**No exceptions:** do not keep it as "reference"; do not adapt it while
writing tests; delete means delete.
```

Add the foundational principle early ("Violating the letter of the rules
is violating the spirit of the rules.") to cut off "I'm following the
spirit" arguments. Capture every excuse agents actually use in a
rationalization table, and add a red flags list so agents can self-check.

## Red-green-refactor for writing skills

1. **RED:** run a pressure scenario without the skill. Document the
   baseline behavior and the exact rationalizations.
2. **GREEN:** write the minimal skill that addresses those specific
   violations, then run the same scenario again and confirm compliance.
3. **REFACTOR:** add an explicit counter for any new rationalization and
   re-test until it holds.

## Verification

The iron law applies to new skills and edits: no skill without a failing
test first. Test discipline-enforcing skills with pressure scenarios and
academic questions; technique skills with application and variation
scenarios; reference skills with retrieval and gap tests. Do not deploy
an untested skill.

## Common rationalizations to reject

| Excuse | Reality |
|---|---|
| "The skill is obviously clear" | Clear to you is not clear to other agents; test it |
| "Testing is overkill" | Untested skills have issues; a short test saves hours |
| "I'll test if problems emerge" | Problems mean agents cannot use the skill; test before |
| "I'm confident it's good" | Overconfidence guarantees issues; test anyway |
| "Academic review is enough" | Reading is not using; test application scenarios |
