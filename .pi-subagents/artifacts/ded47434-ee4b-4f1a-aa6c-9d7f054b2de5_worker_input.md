# Task for worker

You are implementing a bug fix in a Rails + Hotwire/Turbo + Tailwind app. Work on the current branch `fabrica/1` (already checked out). Do NOT create a new branch. Do NOT push to main.

## The bug (GitHub issue #1)
When switching between assistants in the sidebar, Turbo morph (`turbo_refreshes_with method: :morph, scroll: :preserve`) re-renders the `<nav>` sidebar and for a single frame the `nav-closed:hidden` rule can win before the `md:!flex` override reasserts. Because the sidebar width is only protected by `min-w-[260px]` plus `flex` (no `flex-shrink-0`, no hard `w-[260px]`), it collapses toward 0 and snaps back — a visible flash on every assistant switch.

## Files to change
- Primary: `app/views/layouts/application.html.erb` — the `<nav>` element (~lines 15-22). Currently has `min-w-[260px]` and `flex nav-closed:hidden <%= !Current.user.preferences[:nav_closed] && "md:!flex" %>`.
- Tests: add a rendered-layout regression assertion. There is an existing test in `test/controllers/messages_controller_test.rb` (see the test at the end that does `get conversation_messages_url(@conversation, version: 1)` and uses `assert_select`). Add a test alongside it that asserts the `<nav>` carries `flex-shrink-0`. Use `assert_select "nav.flex-shrink-0"`.

## Validation contract (you MUST meet this)
- Intended behavior: During Turbo morph navigation between assistants, the desktop sidebar `<nav>` width stays constant (260px); it must not collapse toward 0 and snap back.
- Proving checks: (a) a rendered-layout assertion that the `<nav>` carries `flex-shrink-0`; (b) `devloop test hostedgpt` full suite green.

## Implementation
1. In `app/views/layouts/application.html.erb`, on the `<nav>` class list, add `flex-shrink-0` (next to `min-w-[260px]`). This prevents the flex item from shrinking below its content/width during morph reconciliation.
2. Add the regression test to `test/controllers/messages_controller_test.rb` asserting `assert_select "nav.flex-shrink-0"` after a `get conversation_messages_url(@conversation, version: 1)`.

Keep the change minimal and focused. Do NOT add `data-turbo-permanent` (out of scope — changes navigation architecture). Do NOT touch the assistant row icon container. Scope is strictly the nav width hardening.

## Verify (use devloop, JSON output, token-efficient)
Run: `devloop test hostedgpt`
If devloop is unavailable or errors, fall back to: `bin/rails test test/controllers/messages_controller_test.rb`
Never block on a tooling failure — if the full suite is too slow, at minimum run the messages controller test.

IMPORTANT: devloop/test runs take 60-120s and produce no output while running. This is normal — let it finish. Do not run sleep loops or process checks.

## Return
Report: files changed, exact diff/lines changed, what's done, what's left, exact commands run with exit codes, and evidence (test output excerpts). Do NOT push to git — the coordinator handles commits/push. Do NOT spawn subagents.

## Acceptance Contract
Acceptance level: reviewed
Completion is not accepted from prose alone. End with a structured acceptance report.

Criteria:
- criterion-1: Implement the requested change without widening scope
- criterion-2: Return evidence sufficient for an independent acceptance review

Required evidence: changed-files, tests-added, commands-run, validation-output, residual-risks, no-staged-files

Review gate: required by reviewer.

Finish with a fenced JSON block tagged `acceptance-report` in this shape:
Use empty arrays when no items apply; array fields contain strings unless object entries are shown.
```acceptance-report
{
  "criteriaSatisfied": [
    {
      "id": "criterion-1",
      "status": "satisfied",
      "evidence": "specific proof"
    }
  ],
  "changedFiles": [
    "src/file.ts"
  ],
  "testsAddedOrUpdated": [
    "test/file.test.ts"
  ],
  "commandsRun": [
    {
      "command": "command",
      "result": "passed",
      "summary": "short result"
    }
  ],
  "validationOutput": [
    "validation output or concise summary"
  ],
  "residualRisks": [
    "none"
  ],
  "noStagedFiles": true,
  "diffSummary": "short description of the diff",
  "reviewFindings": [
    "blocker: file.ts:12 - issue found, or no blockers"
  ],
  "manualNotes": "anything else the parent should know"
}
```