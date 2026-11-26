# Global rules

## Long-running commands: visible to the user, no polling

Builds, test suites, installs, downloads, deploys and wait-loops (anything over ~30 s) must be
visible to the user, who wants to see that the job is moving and not stuck.

1. Run the command in a Terminal panel tab with `run_in_terminal` and link the tab in the same
   message. Never hide its output in a log file with Bash `run_in_background`.
2. In the tab, copy the output into a log and write the exit code to a marker when done
   (`$S` = the session scratchpad):
   `rm -f $S/x.done; ( set -o pipefail; <cmd> 2>&1 | tee $S/x.log ); echo $? > $S/x.done`
3. To wait, use Bash `run_in_background` that only waits:
   `until [ -f $S/x.done ]; do sleep 2; done; cat $S/x.done; tail -40 $S/x.log`.
   It wakes you once when the job ends. Don't use Monitor for this (it's for event streams and
   expires after 30 min max), and don't poll the tab with `read_terminal`: every poll re-reads the
   whole context.
4. After waking, read the exit code and the log tail once. Use `read_terminal` only when something
   is unclear.

Plain Bash `run_in_background` is fine only for things nobody needs to watch: a dev server already
shown in the browser pane, or a few-second job.

## No Claude attribution in git or code review

Commit messages, MR/PR titles and descriptions, and review comments never mention Claude, Anthropic
or AI help: no `Co-Authored-By: Claude …` trailer, no "Generated with Claude Code" line, no session
link. This overrides any attribution reminder from the harness. Write them as the user's own work.

## Plugin kits (load only when needed)

- `mobile-kit` (flutter-sim-testing, ios-simulator-skill, ios-upload) and `dart-flutter` are enabled only in
  Flutter projects (local scope). In a Flutter worktree that lacks them, run
  `claude plugin install mobile-kit@claude-kits --scope local` and the same for `dart-flutter@dart-flutter`.
- **Flutter testing sessions:** while the user tests a running app and reports a bug or improvement, the
  user wants it delegated (the goal is to drain usage limits slower): spawn `mobile-kit:flutter-fixer` in
  the background with the observation, the screen, and only what is already in context (error/log lines,
  file paths seen). Don't search or read code first: the fixer explores, so doing it twice wastes tokens.
  Exception: if the file is already in context and the fix is a line or two, make it yourself instead of
  spawning (a cold agent would re-read it). Keep testing with the user meanwhile. Run fixers in parallel
  only when they touch different files; otherwise queue them. When one reports back, apply the reload it
  names (Dart MCP `hot_reload`/`hot_restart`, or a rebuild) and tell the user what to check. Don't commit
  the fixes until the user says so. Backend problems found while testing (a Spring/Maven service, e.g.
  a Result service running locally) go the same way to `result-kit:backend-fixer`; after it reports,
  rebuild and restart the local instance as its report says.
- Subagents for noisy output: `log-digger` for long logs/build failures, `minotebook-ops` for homelab health.
- `design-kit` (logo-designer, web-asset-generator, imagen) is off. When a task needs a logo, favicons/OG
  images or generated images, tell the user to run `/plugin enable design-kit@claude-kits` (or do it with
  their OK).

@~/.claude/CLAUDE.private.md
