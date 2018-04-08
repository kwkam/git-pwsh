# pwsh-git-prompt
Provide status prompt and completion based on [Bash completion from Git](
https://github.com/git/git/tree/master/contrib/completion
)\
Currently does not support completion for `gitk` and `git svn`

## How to use
For example, on Windows, put following lines in profile.ps1:
```powershell
if (Test-Path $PSScriptRoot/git-prompt.ps1) {
	. $PSScriptRoot/git-completion.ps1
	. $PSScriptRoot/git-prompt.ps1
	$GIT_PS1.DESCRIBE_STYLE = 'branch'
	$GIT_PS1.SHOWDIRTYSTATE = $true
	$GIT_PS1.SHOWSTASHSTATE = $true
	$GIT_PS1.SHOWUNTRACKEDFILES = $true
	$GIT_PS1.SHOWUPSTREAM.ENABLE = $true
	$GIT_PS1.SHOWUPSTREAM.VERBOSE = $true
	$GIT_PS1.SHOWCOLORHINTS = $true
}

function Prompt
{
	$ps1_s = "PS `e[0;33m$env:USERNAME@$env:COMPUTERNAME`e[m `e[1;36m$($PWD.Path.Replace($HOME, '~'))`e[m"
	$ps1_e = "`n`e[1;30m$NestedPromptLevel`e[m> "
	if ($GIT_PS1) {
		return __git_ps1 $ps1_s $ps1_e
	}
	return "$ps1_s$ps1e"
}
```
