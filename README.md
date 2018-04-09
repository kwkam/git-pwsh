# pwsh-git-prompt
Provide status prompt and completion based on [Bash completion from Git](
https://github.com/git/git/tree/master/contrib/completion
)\
Currently does not support completion for `gitk` and `git svn`

## How to use
1. Copy the files to where profile.ps1 is:
```powershell
Copy-Item git-*.ps1 $(Split-Path -Parent $PROFILE)
```
2. Put following lines in profile.ps1:
```powershell
# load git-prompt.ps1
if (Test-Path $PSScriptRoot/git-prompt.ps1) {
	. $PSScriptRoot/git-completion.ps1
	. $PSScriptRoot/git-prompt.ps1
	# config git-prompt
	$GIT_PS1.DESCRIBE_STYLE = 'branch'
	$GIT_PS1.SHOWDIRTYSTATE = $true
	$GIT_PS1.SHOWSTASHSTATE = $true
	$GIT_PS1.SHOWUNTRACKEDFILES = $true
	$GIT_PS1.SHOWUPSTREAM.ENABLE = $true
	$GIT_PS1.SHOWUPSTREAM.VERBOSE = $true
	$GIT_PS1.SHOWCOLORHINTS = $true
}

# customise prompt string
function Prompt
{
	$u = [Environment]::UserName
	$h = [Environment]::MachineName
	$w = $PWD.Path.Replace($HOME, '~')
	$ps1_s = "PS `e[0;33m$u@$h`e[m `e[0;36m$w`e[m"
	$ps1_e = "`n$NestedPromptLevel> "
	if ($GIT_PS1) {
		return __git_ps1 $ps1_s $ps1_e
	}
	return "$ps1_s$ps1_e"
}
```
