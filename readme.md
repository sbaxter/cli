# cli

Portable bash configuration. POSIX-minded, shellcheck-clean.

## Install

```bash
./install            # create symlinks
./install -b .bak    # backup existing files first
```

**gitconfig** is not installed by the script — copy and edit manually:

```bash
cp gitconfig ~/.gitconfig
# edit name, email, signing key, github user
```

## Structure

| File | Target | Purpose |
|------|--------|---------|
| `bashrc` | `~/.bashrc` | Interactive shell config |
| `inputrc` | `~/.inputrc` | vi mode for readline |
| `gitconfig` | (manual) | Git config template |
| `gitignore` | `~/.gitignore` | Global gitignore |
| `psqlrc` | `~/.psqlrc` | PostgreSQL shell config |
| `hushlogin` | `~/.hushlogin` | Suppress macOS login banner |
| `vi/vimrc` | `~/.vimrc`, `~/.ideavimrc` | Vim configuration |
| `vi/colors/` | `~/.vim/colors/` | Vim color schemes |

## Conventions

- `#!/usr/bin/env bash` + `set -e` + conditional `set -x`
- `test` over `[[ ]]` (except regex). Long flags for readability.
- camelCase locals, UPPERCASE exports, `function name {` syntax
- Section markers: `##` / `##` wrapping logical sections
- shellcheck-clean

## Bash

Single bashrc follows the user everywhere — macOS and Linux compatible.
Machine-specific config belongs in `~/.bash_profile` (private repo).
Secrets go in `~/.bash_private` (not in any repo).

### Prompt

Hand-rolled 2-line prompt with git branch and dirty indicators:

```
[main!+?][hostname(org)://cwd]: 
```

- `!` = unstaged changes
- `+` = staged changes
- `?` = untracked files

### Org / System / Repo

```bash
org shb                    # switch org context
sys myapp                  # set system (repo group)
repo frontend              # cd to ~/git/sbaxter/myapp/frontend
repo myapp/frontend        # inline system/repo (no sys needed)
gclone myrepo              # clone into ~/git/$GH_ORG/[$SYSTEM/]myrepo
gclone homebrew-ctx brew   # clone as different local name
```

Org definitions live in the private repo. The public repo provides only
the switching mechanism (`org` function reads from `ORG_DEFS` array).

### Aliases

Navigation: `..` `..2`–`..5` `back`

Git: `ga` `gc` `gca` `gco` `gd` `gds` `gdr` `gp` `gu` `gr` `gst` `grb`
`groot` `hist` `gpick` `gpr` `gpt` `gpv` `grm` `gt`

Safety: `cp -i` `mv -i` `rm -i`

Other: `ll` `lla` `ngrep` `vi` `blint` `brup` `pc`

## Bin

| Script | Purpose |
|--------|---------|
| `backup` | Backup files to S3 |
| `chash` | Copy commit SHA to pasteboard |
| `connection` | Check network connectivity |
| `daily` | Execute scripts max once per day |
| `diskusage` | Show disk usage with warning |
| `extract` | Extract common archive formats |
| `loop` | Repeat a command at intervals |
| `pg` | Connect to local PostgreSQL |
| `update` | Pull latest on repos from `$UPDATE_LIST` |
| `wifi` | Toggle wifi on/off (macOS) |
