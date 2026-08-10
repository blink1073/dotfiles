---
name: prose
description: Use when writing or reviewing any prose for a human reader — docstrings, PR descriptions, comments, README text, commit messages, error messages — before or while drafting the text.
---

# Prose

## Overview

Default LLM prose habits — hedging, restating the obvious, decorative
punctuation, marketing adjectives — make writing harder to read, not
easier. This skill is a checklist of concrete, checkable rules that other
writing skills (docstrings, pr-description, ...) build on. Invoke it
first, then apply whatever format-specific rules the calling skill adds.

## Checklist

Apply every item below to any prose you write. Read the draft back
against this list before finishing.

- **Lead with the point.** State the conclusion or the point of the
  paragraph in its first sentence. Don't wind up to it.
- **Cut restatement.** Delete any sentence whose only job is to describe
  what the reader can already see (the code, the diff, the filename, the
  obvious context).
- **Active voice, concrete verbs.** "The parser rejects malformed input,"
  not "malformed input is rejected by the parser" or "may not be handled
  correctly."
- **One idea per sentence.** Split sentences joined by "and" or "which"
  when they carry two separate claims.
- **No filler transitions.** Delete "It's worth noting that," "In order
  to," "It should be mentioned that" — say the thing directly.
- **No marketing adjectives.** "Powerful," "seamless," "robust," "simply,"
  "just" describe a feeling, not a fact. State what the thing does
  instead.
- **No em dashes, "--", "via", or arrow characters ("->", "→").** Spell
  out the connecting logic in words: "through," "using," "results in,"
  "then," "so."
- **Match the register to the reader.** A docstring reader wants
  mechanics; a PR reviewer wants judgment and risk; end-user docs want
  plain language. Don't write all three the same way.

## Common Mistakes

| Habit | Instead |
|---|---|
| "This function will iterate through the list and, for each item, check if it matches — then it will return the result." | "It returns the first matching item." |
| "It's important to note that this may cause issues in some cases." | Name the actual case, or cut the sentence. |
| "This powerful utility seamlessly handles..." | "This handles..." |
| "Data flows from the parser -> validator -> writer." | "The parser hands data to the validator, which hands it to the writer." |
