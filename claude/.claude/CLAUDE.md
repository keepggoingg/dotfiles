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

## Plugin kits (load only when needed)

- `mobile-kit` (flutter-sim-testing, ios-simulator-skill, ios-upload) and `dart-flutter` are enabled only in
  Flutter projects (local scope). In a Flutter worktree that lacks them, run
  `claude plugin install mobile-kit@claude-kits --scope local` and the same for `dart-flutter@dart-flutter`.
- `design-kit` (logo-designer, web-asset-generator, imagen) is off. When a task needs a logo, favicons/OG
  images or generated images, tell the user to run `/plugin enable design-kit@claude-kits` (or do it with
  their OK).

@~/.claude/CLAUDE.private.md
