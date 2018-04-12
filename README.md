# git-pwsh
Provide status prompt and completion based on [Bash completion from Git](
https://github.com/git/git/tree/master/contrib/completion
)\
Currently does not support completion for `gitk` and `git svn`

## How to use
1. Clone the repository to the user modules directory:
```powershell
Push-Location "$(Split-Path -Parent $PROFILE)/Modules"
git clone https://github.com/kwkam/git-pwsh.git
Pop-Location
```
2. Put following lines after prompt function in profile.ps1:
```powershell
<# ... #>
# customise prompt string
$PromptPrefix = {
    $u = [Environment]::UserName
    $h = [Environment]::MachineName
    $w = $PWD.Path.Replace($HOME, '~')
    "PS `e[0;33m$u@$h`e[m `e[1;36m$w`e[m"
}
$PromptSuffix = {
    "`n`e[1;30m$NestedPromptLevel`e[m> "
}
function Prompt
{
    "$($PromptPrefix.Invoke())$($PromptSuffix.Invoke())"
}
<# ... #>
# load git-pwsh and config
Import-Module git-pwsh
$GIT_PS1.DESCRIBE_STYLE = 'branch'
$GIT_PS1.SHOWDIRTYSTATE = $true
$GIT_PS1.SHOWSTASHSTATE = $true
$GIT_PS1.SHOWUNTRACKEDFILES = $true
$GIT_PS1.SHOWUPSTREAM.ENABLE = $true
$GIT_PS1.SHOWUPSTREAM.VERBOSE = $true
$GIT_PS1.SHOWCOLORHINTS = $true
```
