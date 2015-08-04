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

## bin
Bin files are automatically added to the path if you're using the [`.bashrc` file](./bashrc#L61-L63) in this repo.

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

*Note: `anacron` may be a better option for stuff like this: write the output to a file and cat the results on login.*

### [`backup`](./bin/backup)
A script I use to backup key files to AWS s3. To use, just set the `$BACKUP_LIST` environment variable to contain a list of files and directories to backup.

Example on Mac OSX:
```
  [Ptolemy:/~]: export BACKUP_LIST="$HOME/.bash_profile"
  [Ptolemy:/~]: backup
  upload: .backup/.bash_profile to s3://my-backups/Ptolemy/.bash_profile
  upload: .backup/latest.txt to s3://my-backups/Ptolemy/latest.txt
  upload: .backup/brewlist.txt to s3://my-backups/Ptolemy/brewlist.txt
```

*Note: `$HOME/ssh/config` is automatically backed up by this script; a list of brew packages is also stored on Mac OSX.*

### AWS scripts
#### [`cfn`](./bin/cfn)
* View stack status:
```
  $: cfn my-app
  my-app     UPDATE_COMPLETE
```
* Retrieve a stack output or parameter:
```
  $: cfn -o ELBDNS my-app
  my-app-XXXXXXXXX.us-east-1.elb.amazonaws.com

  $: cfn -p Stage my-app
  production
```
* validate a cloudformation template:
```
  $: cfn -t cfn-template.json

  A client error (ValidationError) occurred when calling the ValidateTemplate operation: Template format error: JSON not well-formed. (line 1, column 3)
```
* Run `cfn -h` for more options.

#### [`ec2`](./bin/ec2)
* Return ec2 public dns by `Tag` (verbose instance information with `-v`):
```
  $: ec2 my-app
  ec2-XX-XX-XXX-XXX.compute-1.amazonaws.com
```
* Return ec2 public dns by `instance-id` (verbose instance information with `-v`):
```
  $: ec2 -i i-bc9af510
  ec2-XX-XX-XXX-XXX.compute-1.amazonaws.com
```
* If [`jump`](./bin/jump) is available, you can jump to the server through a jump host in one command:
```
  $: ec2 -j my-app
  ..ssh session..
```
* Alternatively, you can ssh directly:
```
  $: ssh $(ec2 my-app | head -n 1)
```
* Run `ec2 -h` for more options.

#### `asg`
TODO

#### `elb`
TODO


## Credits
* [georgeflanagin](https://github.com/georgeflanagin): my cli sensei
* [vrivellino](https://github.com/vrivellino)
