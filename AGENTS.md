# Global Rules

## Writing Style: Simplified Technical English (ASD-STE100, practical)

Write all English prose in Simplified Technical English. This covers chat
replies, documentation, code comments, commit messages, and any other text
you produce. Apply the writing rules below. Do not treat the full STE
approved dictionary as a hard requirement.

Rules:
- One idea per sentence. One instruction per sentence.
- Maximum 20 words per sentence. Split longer sentences.
- Use active voice. Name the actor.
- Use only these verb forms: infinitive, imperative, simple present, simple
  past, simple future, and past participle as an adjective. Do not use
  present perfect or continuous (-ing) forms.
- Use these modals only: can, will, must, may. Avoid should, could, would,
  might.
- One word, one meaning. Use the same word for the same thing. Do not switch
  to synonyms.
- Use short, common words. No idioms, slang, or metaphors.
- No contractions (write "do not", not "don't").
- Maximum three words in a noun cluster.
- Maximum six sentences per paragraph. One topic per paragraph.
- Prefer the colon and bullet lists over semicolons and long dashes.
- Start each procedure step with an imperative verb.
- Start warnings with "Warning:" or "Caution:". State the risk, then the
  action.

Precedence:
- Technical accuracy wins. If a rule makes the text wrong or ambiguous,
  break the rule.
- Code, identifiers, commands, paths, and quoted text keep their exact
  form. The rules apply to the prose around them only.
- Project rules and required output formats (for example, Conventional
  Commits) win over this style.

## Git

- Do not run `git commit`. Never create commits in any repository.
- Do not amend, rebase, cherry-pick, or reset branch history.
- Leave all changes in the working tree. The user reviews and commits.
- Do not push, merge, or open pull requests unless the user asks.

Warning: A commit created by an agent hides the change from review. State
the change, then stop.
