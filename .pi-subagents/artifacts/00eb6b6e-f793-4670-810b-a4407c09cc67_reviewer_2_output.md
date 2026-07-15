I now have all the evidence needed. Here is the full review.

---

## Review

### What the change does
A single CSS class (`flex-shrink-0`) is added to the `<nav>` sidebar element, plus a 4-line regression test asserting its presence.

### Assessment

**Correct: `flex-shrink-0` is the simplest correct fix.**

The `<body>` is a flex container (`app/assets/stylesheets/application.tailwind.css`, line ~139: `@apply … flex`). The `<nav>` and `<main id="main-container">` (which has `flex-1`) are its two flex children. Without `flex-shrink-0`, the `<nav>` defaults to `flex-shrink: 1` and can shrink during layout — including during Turbo morph reconciliation, which momentarily collapses it. The existing `min-w-[260px]` sets a floor, but during morph's DOM frame thrash, the flex shrink can still visually collapse the sidebar before `min-width` reasserts. `flex-shrink-0` prohibits any shrink, period. This is the simplest possible fix: one class, no logic, no side effects.

**Why not also add `w-[260px]`?**

The issue description mentioned both, but `w-[260px]` would pin the sidebar at exactly 260px, preventing it from growing for longer content (e.g., long assistant names in the nav). `min-w-[260px] + flex-shrink-0` preserves flexibility while preventing collapse — a strictly better outcome.

**Test quality: adequate and well-placed.**

- **Location**: `test/controllers/messages_controller_test.rb`, line 227. It's an integration test that renders the full application layout, so the nav is included. This follows the same pattern as nearby tests (e.g., line 215: `"viewing messages in a conversation…"` which also GETs `conversation_messages_url(@conversation, version: 1)`).
- **Name**: `"the nav sidebar carries flex-shrink-0 to prevent width collapse during morph"` — descriptive, matches the sentence-case convention of neighboring tests (lines 187–233).
- **Assertion**: `assert_select "nav.flex-shrink-0"` — tests the exact CSS class the fix depends on. This is a CSS-presence regression test, which is appropriate for a CSS-class fix.
- **Minor note**: The test doesn't exercise the morph behavior itself (that would require a system/JS test), but as a regression guard against accidental class removal, it's fit for purpose. Not a blocker.

**No extraneous changes.** The diff touches exactly two files, 7 insertions and 1 deletion. No scope creep.

**No staged files, no stashes.** `git status` is clean except for `.pi-subagents/` (untracked runtime directory).

**Test suite**: Author reports `devloop test hostedgpt -> 665 tests, 0 failures, 0 errors`. Unable to reproduce in this environment due to missing PostgreSQL, but the commit message documents verification.

### Residual risks
- **none** — the change is a one-class CSS addition with a targeted regression test; no observable risk of regression or side effect.

---