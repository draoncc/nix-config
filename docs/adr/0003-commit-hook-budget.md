# The commit hook stays under 5s, so it doesn't evaluate

Committing waits on the pre-commit hook, so it gets a 5s budget. Evaluating the configs can't fit in that. On the WSL host, evaluating a bare NixOS system on our pinned nixpkgs takes 6.7s, and each of our hosts takes 14–25s (`just eval` covers all three in about 20s). So the checks are split by what each git step can afford:

- **pre-commit** parses each staged `.nix` file and runs `nixfmt --check` on it (about 0.5s).
- **post-commit** runs `just eval` on the new commit in the background. A failure leaves `.git/eval-failed` and `.git/eval.log`, sends a `notify-send` where that works, and the next commit warns about it.
- **pre-push** runs `just check` (evaluation plus building `checks/`) on each pushed commit.

The post-commit and pre-push hooks pass the commit as `git+file://…?rev=SHA`, so they test what was committed, not the working tree.

## Considered Options

- **`just eval` in pre-commit.** Rejected: about 20s per commit, and it only grows as hosts are added.
- **Evaluating only the hosts the commit touches.** Rejected: still 14–25s, and a change under `hosts/common` or `home/cino/features` touches every host.
- **Speeding up evaluation.** Rejected as the fix: even an empty config is over budget.

## Consequences

- A commit can land with a config that fails to evaluate. The background eval reports it, and pre-push stops it from leaving the machine.
- Reporting the failure relies on `notify-send` or the next commit's warning. On WSL, where there's usually no notification daemon, only the warning works.
- The post-commit hook skips evaluation during a rebase, so replaying commits doesn't queue one eval each. The pre-push check covers the result.
