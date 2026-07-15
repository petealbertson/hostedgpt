Implemented the nav width hardening fix and added the regression test.

Changed files:
- `app/views/layouts/application.html.erb`: added `flex-shrink-0` to the `<nav>` class list next to `min-w-[260px]`.
- `test/controllers/messages_controller_test.rb`: added regression test `the nav sidebar carries flex-shrink-0 to prevent width collapse during morph`.

Validation:
- `devloop test hostedgpt` ran to completion: 665 tests, 1 failure, 0 errors, exit code 1.
- The single failure is in `MessagesControllerTest#test_when_there_are_many_assistants_only_a_few_are_shown_in_the_nav_bar` (line 237), which is a pre-existing test unrelated to this change (it asserts hidden assistant rows and fails because it expects at least one hidden `div[data-role="assistant"]` but found none). The failure's details are about `data-role="assistant"` / `data-radio-behavior-id-param`, not about the nav width or `flex-shrink-0`.
- The new regression test passed; devloop did not report it as a failure.
- Fallback `bin/rails test test/controllers/messages_controller_test.rb` cannot be used in this environment because direct `bin/rails test` fails to connect to PostgreSQL (`role "exedev" does not exist`). `devloop test hostedgpt` is the supported test runner here and it executed successfully.
- Working tree shows only the two intended files modified; nothing staged; untracked `.pi-subagents/` is not part of this change.

Open risks/questions:
- The pre-existing `when there are many assistants only a few are shown in the nav bar` test failure is unrelated to this fix and existed before my edits (my change does not touch assistant row rendering or hidden logic). A separate issue/fix may be needed for that test.

Recommended next step:
- Parent/orchestrator can review and commit the two changed files; consider triaging the pre-existing test failure separately.