#cli
My base cli setup.

## Installation
Setup symlinks to config files in this repo:
```
$: ./install
```
* Use the `-b <extension>` flag to save a backup of the current config file (if one already exists).
* `gitconfig` will not be installed by the script.

## Bash
My bashrc follows me everywhere; thus I include darwin and linux specific functionality in my `bashrc`. I store machine-specific stuff in `.bash_profile` (not included in this repo) and super secret stuff in a `.bash_private` file.

### Prompt
I have hacked my own prompt, but it is probably smarter to use the prompt in git [contrib](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh).

### VI Mode
I use vi key bindings where possible: the bashrc file will `set -o vi` for editing the command line and the `inputrc` file will activate vi mode for other readline prompts (e.g. psql).

## Bin Files

### [`update`](./bin/update)
A script I use to update key repos regularly. To use, just set the `$UPDATE_LIST` environment variable to contain a list of repos to update.

Example:
```
  $: export UPDATE_LIST="$HOME/repos/cli $HOME/.emacs.d"
  $: update
  Updating /home/sbaxter/repos/cli
  UNABLE TO UPDATE (DIRTY)
  Updating /home/sbaxter/.emacs.d
```

### [`daily`](./bin/daily)
Execute a script on login, but no more than once per day. The `-f` option flag will execute only on the first login of the day.
Example from my `.bash_profile`:
```
  daily -f diskusage
  daily -f update > /dev/null && echo
  daily -f brew update && echo && brew outdated && echo
  daily backup
```

### AWS scripts
TODO

## Credits
* [georgeflanagin](https://github.com/georgeflanagin): my cli sensei
* [vrivellino](https://github.com/vrivellino)
