---
name: herdr-worktree
description: Create, open, list or remove a git worktree of the current repo through Herdr's worktree system, so it shows up as a workspace in the Herdr sidebar. Use whenever the user asks for a new worktree, a new branch to work on in parallel, "a worktree so that it appears in herdr", or to open or clean up an existing one. Prefer this over a bare `git worktree add`.
---

# Herdr worktrees

Herdr tracks git worktrees as workspaces: `herdr worktree create` runs the `git worktree add` **and** opens the result as a workspace in the sidebar. A worktree made with plain `git worktree add` does not appear there until it is opened with `herdr worktree open`.

Herdr keeps its worktrees under `~/.herdr/worktrees/<repo>/<branch with / replaced by ->`, e.g. branch `feature/foo` of repo `myrepo` is at `~/.herdr/worktrees/myrepo/feature-foo`. Do not use a repo-local directory (such as `.claude/worktrees/`) for new work unless the user asks or the repo's own instructions say so.

## 0. Check you are inside Herdr

```bash
test "${HERDR_ENV:-}" = 1
```

If it fails, say you are not running inside Herdr and ask the user whether to fall back to a plain `git worktree add`. Do not control a Herdr session from outside.

Learn the current syntax from the binary if in doubt (`herdr worktree` with no subcommand prints help; `herdr worktree create --help` lists the options). Never run bare `herdr`: it launches the TUI.

## 1. Find the repo and its base

Work out these once, from wherever you are (a linked worktree included):

```bash
git worktree list | head -1                                   # first line = the main checkout: REPO
git symbolic-ref --short refs/remotes/origin/HEAD             # e.g. origin/development: BASE (fall back to origin/main, then ask)
```

Use the **main checkout** as `--cwd`, so Herdr resolves the right repo even when you are inside another worktree. Read the repo's `CLAUDE.md` for branch-name or worktree conventions; they win over the defaults below.

## 2. Settle the branch name

- Ask the user when they did not give one. There is no sensible default.
- Follow the repo's existing style (`git branch -a`, `git log --oneline`). Absent one: `feature/<slug>`, `bugfix/<slug>`, `chore/<slug>`, with a few kebab-case words as slug, and a ticket or request id in it when there is one.
- Check it is free: `git branch --list <branch>` and `git ls-remote --heads origin <branch>`. If it exists, ask whether to open it (step 4) instead of creating it.

## 3. Create it

Before branching, bring the parent repo (the main checkout, `<REPO>`) up to the latest commit, so it does not fall behind while the new worktree starts from the fresh remote tip:

```bash
git -C <REPO> pull --ff-only
```

- `--ff-only` never creates a merge commit or rewrites anything. If it fails (diverged history, uncommitted changes that conflict, no upstream, detached HEAD), do not force it: tell the user why and carry on with the `fetch` below, since the worktree branches from `<BASE>` regardless.
- It pulls whatever branch is checked out in `<REPO>`; do not switch branches there just to pull.

```bash
git -C <REPO> fetch origin
herdr worktree create \
  --cwd <REPO> \
  --branch <branch> \
  --base <BASE> \
  --no-focus
```

- `--base <BASE>` branches from the remote tip, not from a stale local branch or whatever is checked out. Use another base only when the user says so (e.g. branching off an unmerged feature).
- `--no-focus` keeps the user's focus in their current workspace; the new workspace still appears in the sidebar. Pass `--focus` only if the user asked to be switched to it.
- `--label <text>` renames the workspace in the sidebar when the directory name is not descriptive enough. Optional.
- `--path <dir>` overrides the location. Do not use it unless the user asks; the default keeps all worktrees in one place.
- Do not pass `--trust-repository` on your own: it exists for the case where Herdr refuses an untrusted repo, and trusting a repo is the user's call. If Herdr refuses, tell the user and ask.

The command returns JSON. Read the new workspace id and the checkout path from the response rather than guessing them (the exact field names were not verified; look at the output), then confirm:

```bash
herdr worktree list
git -C <REPO> worktree list
```

The new branch must be listed with an `open_workspace_id`. Report the branch, the path and the workspace id to the user.

### Bring over the local `.env` files

Right after the worktree is created (and before starting any pane program, so `nvim`/`claude`/dev servers see them), copy the local-development env files from the main checkout into the same relative locations in the new worktree. They are git-ignored, so the fresh checkout does not have them:

```bash
cd <REPO> && find . \( -name node_modules -o -name .git -o -name vendor \) -prune -o \
  -type f \( -name '.env' -o -name '.env.dev' \) -print0 \
  | xargs -0 -r -I{} cp -n --parents {} <checkout path>
```

- Only exactly `.env` and `.env.dev`. Do not copy `.env.local`, `.env.prod*`, `.env.production`, or other variants unless the user asks.
- `-n` never overwrites a file already in the worktree (e.g. a tracked `.env`).
- Copy, do not symlink: the worktree's values may diverge from the main checkout's.
- Never print the contents. Tell the user which files were copied (relative paths only), or that none were found.
- Skip this step for `open` (step 4): an existing worktree already has whatever it had.

### Default layout: 1 pane left, 2 panes right, plus a lazygit tab

A new workspace starts with a single pane. Unless the user asks for a different layout, split it into one pane on the left and two stacked on the right (the layout used in the user's other workspaces), then add a second tab running lazygit:

```bash
herdr pane list --workspace <workspace id>      # expect exactly one pane: ROOT; read its pane_id and tab_id (TAB1)
herdr tab rename TAB1 ide                       # first tab: "ide"
herdr pane split ROOT --direction right --ratio 0.41 --cwd <checkout path> --no-focus   # returns the new right pane: RIGHT
herdr pane split RIGHT --direction down --ratio 0.80 --cwd <checkout path> --no-focus   # returns the new bottom-right pane
herdr pane layout --pane ROOT                   # verify: 3 panes
herdr pane run ROOT 'nvim .'                    # left pane: editor
herdr pane run RIGHT 'claude'                   # top-right pane: Claude Code
herdr tab create --workspace <workspace id> --cwd <checkout path> --label lazygit --no-focus   # second tab; read its pane id: GIT
herdr pane run GIT 'lazygit'                    # second tab: lazygit
```

The bottom-right pane stays a plain shell. Create the lazygit tab last and with `--no-focus`, so the first tab (the 3-pane layout) stays the active one.

- `--ratio` is the share kept by the pane being split (left 41% of the width; top-right 80% of the height, bottom-right 20%).
- Take the new pane ids from each command's JSON response (field names not verified; look at the output).
- Only do this when the workspace has exactly one pane. For `open` (step 4) an existing workspace already has its own layout: leave it alone.
- Skip it if the user says "no layout" or "single pane". Skip only a program (or the lazygit tab) if they say "no nvim", "no claude" or "no lazygit".
- The panes are started with `--cwd <checkout path>`, so `nvim .` and `claude` open in the worktree, not the main checkout. Do not start any other program unless asked.

## 4. Open an existing worktree

For a worktree that exists on disk but is not in the sidebar (made with plain git, or its workspace was closed):

```bash
herdr worktree open --cwd <REPO> --path <checkout path> --no-focus
```

(`--branch <name>` instead of `--path` works when you know the branch.) `herdr worktree list` shows which ones have no `open_workspace_id`.

## 5. Work in the worktree

- Every command and every file edit for the task goes in the worktree: absolute paths under its checkout path, `git -C <path> ...`. Never edit the main checkout's files for this task.
- The worktree is a clean checkout: **git-ignored files are not there** (`.env` and `.env.dev` are copied automatically at creation, see step 3; other `.env*` variants, local config, certificates, downloaded tool binaries; build outputs and dependency folders such as `bin/`, `obj/`, `node_modules/` are rebuilt, not copied). See what exists in the main checkout with `git -C <REPO> status --ignored --short`, and copy only what the task needs. Never print or commit secrets.
- Uncommitted changes in the main checkout are not carried over. If the work was already started there, move it: `git diff` the files, `git apply` in the worktree, and revert them in the main checkout only with the user's agreement.
- Follow the repo's own instructions (`CLAUDE.md`, memory) for building, testing and running; they apply in the worktree too.

## 6. Remove it when the work is merged

Only when the user asks, or after confirming with them. Look first:

```bash
git -C <checkout path> status --short
git -C <checkout path> log <BASE>..HEAD --oneline
```

If there are uncommitted changes or unpushed commits, tell the user and stop. Otherwise:

```bash
herdr worktree remove --workspace <workspace id>
```

It removes the checkout. Do not pass `--force` unless the user explicitly accepts losing what `git status` showed. Delete the branch (`git branch -d <branch>`, and the remote branch) only if asked.
