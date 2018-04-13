# git-pwsh module
# vi: ts=2 sw=2

. $PSScriptRoot/git-completion.ps1
. $PSScriptRoot/git-prompt.ps1

# Backup original TabExpansion2 on first run
if ($(Test-Path function:/TabExpansion2) -and ! $(Test-Path function:/NotGitTabExpansion2)) {
	Rename-Item function:/TabExpansion2 NotGitTabExpansion2
}

# Backup original Prompt on first run
if ($(Test-Path function:/Prompt) -and ! $(Test-Path function:/NotGitPrompt)) {
	Rename-Item function:/Prompt NotGitPrompt
}

# FIXME improve or replace this
function GetCursorCommandLine
{
	[CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
	Param (
		[Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
		[string] $inputScript,

		[Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 1)]
		[int] $cursorColumn,

		[Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
		[Management.Automation.Language.Ast] $ast,

		[Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
		[Management.Automation.Language.Token[]] $tokens,

		[Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
		[Management.Automation.Language.IScriptPosition] $positionOfCursor,

		[Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
		[Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
		[hashtable] $options = $null,

		[Parameter(ParameterSetName = 'ScriptInputSet', Position = 3)]
		[Parameter(ParameterSetName = 'AstInputSet', Position = 4)]
		[hashtable] $parsed
	)

	if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet') {
		$parsedInput = [Management.Automation.CommandCompletion]::MapStringInputToParsedInput(
			$inputScript,
			$cursorColumn)
		$ast = $parsedInput.Item1
		$tokens = $parsedInput.Item2
		$positionOfCursor = $parsedInput.Item3
	}

	if ($parsed) {
		$parsed.ast = $ast
		$parsed.tokens = $tokens
		$parsed.positionOfCursor = $positionOfCursor
	}

	$cmdline = @{
		exec = $null
		words = $null
		prev = $null
		curr = $null
		cursor = $positionOfCursor
	}

	$stacks = [Collections.Generic.Stack[Collections.Generic.Stack[Management.Automation.Language.Token]]]::new()
	$stacks.Push([Collections.Generic.Stack[Management.Automation.Language.Token]]::new())
	$cursorStack = $stacks.Count

	for ($idx = $tokens.Count - 1; $idx -ge 0; $idx--) {
		$token = $tokens[$idx]
		# skip eol
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::EndOfInput -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::NewLine) {
			continue
		}
		# find first token before cursor
		if (! $cmdline.prev -and
		    $positionOfCursor.Offset -gt $token.Extent.EndOffset) {
			# abort if previous token is syntax
			if ($token.Kind -eq [Management.Automation.Language.TokenKind]::Semi -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::Pipe -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::Equals -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::Redirection -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::LCurly -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::AtCurly -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::LParen -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::AtParen -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::DollarParen) {
				return
			}
			$cmdline.prev = $token
			$cursorStack = $stacks.Count
		}
		# find token at cursor
		if ($positionOfCursor.Offset -ge $token.Extent.StartOffset -and
		    $positionOfCursor.Offset -le $token.Extent.EndOffset) {
			# if current token is nested, explore it
			if ($token.Kind -eq [Management.Automation.Language.TokenKind]::StringExpandable -and
			    $token.NestedTokens) {
				return GetCursorCommandLine $ast $token.NestedTokens $positionOfCursor
			}
			# abort if current token is syntax
			if ($token.Kind -eq [Management.Automation.Language.TokenKind]::Variable -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::SplattedVariable -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::Equals -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::Redirection -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::LCurly -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::AtCurly -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::LParen -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::AtParen -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::DollarParen) {
				return
			}
			# abort if cursor is not at the beginning of syntax
			if ($token.Kind -eq [Management.Automation.Language.TokenKind]::Semi -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::Pipe -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::RCurly -or
			    $token.Kind -eq [Management.Automation.Language.TokenKind]::RParen) {
				if ($positionOfCursor.Offset -ne $token.Extent.StartOffset) {
					return
				}
			} else {
				$cmdline.curr = $token
				$cursorStack = $stacks.Count
			}
		}
		# clear current stack at separator
		if (
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::Semi -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::Pipe -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::Equals) {
			$stacks.Peek().Clear()
			continue
		}
		# add maybe useful token to the command stack
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::LCurly -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::AtCurly -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::LParen -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::AtParen -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::DollarParen) {
			[void] $stacks.Pop()
		}
		$stacks.Peek().Push($token)
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::RCurly -or
		    $token.Kind -eq [Management.Automation.Language.TokenKind]::RParen) {
			$stacks.Push([Collections.Generic.Stack[Management.Automation.Language.Token]]::new())
		}
		# find command token
		if ($token.TokenFlags -band [Management.Automation.Language.TokenFlags]::CommandName) {
			if ($cursorStack -eq $stacks.Count) {
				# abort if the command is not complete
				if ($token -eq $cmdline.curr) {
					return
				}
				# current command, we are finished here
				if ($positionOfCursor.Offset -gt $token.Extent.EndOffset) {
					break
				}
			}
		}
	}

	if ($stacks.Count) {
		$cursorcmd = $stacks.Pop()
		if ($cursorcmd.Count) {
			$cmdline.exec = $cursorcmd.Pop()
			$cmdline.words = $cursorcmd.ToArray()
		}
	}

	return $cmdline
}

function GetParamCommandLine
{
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string] $inputScript,

		[Parameter(Mandatory = $true, Position = 1)]
		[string] $paramName,

		[Parameter(Position = 2)]
		[int] $paramIndex = -1
	)

	$parsedInput = [Management.Automation.CommandCompletion]::MapStringInputToParsedInput(
		$inputScript,
		$inputScript.Length)
	$ast = $parsedInput.Item1
	$tokens = $parsedInput.Item2
	$positionOfCursor = $parsedInput.Item3

	if (! $tokens.Count) {
		return
	}

	if ($tokens[0] -like '!*sh') {
		for ($idx = 1; $idx -lt $tokens.Count; $idx++) {
			switch -wildcard ($tokens[$idx]) {
				'-c*' {
					if (++$idx -lt $tokens.Count) {
						# XXX assume token is Kind.String*
						return GetParamCommandLine $tokens[$idx].Value $paramName $paramIndex
					}
				}
			}
		}
	}

	$tokens = for ($idx = 0; $idx -lt $tokens.Count; $idx++) {
		$token = $tokens[$idx]
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::SplattedVariable -and
		    $token.Name -eq $paramName) {
			$positionOfCursor = $token.Extent.StartScriptPosition
			break
		}
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::Variable -and
		    $token.Name -eq $paramName) {
			$nxt = $idx + 1
			if ($nxt -lt $tokens.Count -and
			    $tokens[$nxt].Extent.StartOffset -eq $token.Extent.EndOffset) {
				if ($tokens[$nxt] -in '[') {
					# $var[...]
					$range = for ($nxt = $nxt + 1; $nxt -lt $tokens.Count; $nxt++) {
						if ($tokens[$nxt] -in ']') {
							break
						}
						$tokens[$nxt]
					}
					if ($range.Count -ge 3) {
						# XXX for $var[0..$var.Count], always assume index < $var.Count
						if (($range[0].Kind -eq [Management.Automation.Language.TokenKind]::Number -and
						     $range[0].Value -le $paramIndex) -and
						    ($range[2].Kind -ne [Management.Automation.Language.TokenKind]::Number -or
						     $range[2].Value -ge $paramIndex)) {
							$positionOfCursor = $token.Extent.StartScriptPosition
							break
						}
					} elseif ($range.Count -eq 1) {
						if ($range[0].Kind -eq [Management.Automation.Language.TokenKind]::Number -and
						    $range[0].Value -eq $paramIndex) {
							$positionOfCursor = $token.Extent.StartScriptPosition
							break
						}
					}
				}
			} else {
				# $var without anything following it
				$positionOfCursor = $token.Extent.StartScriptPosition
				break
			}
		}
		$token
	}

	return GetCursorCommandLine $ast $tokens $positionOfCursor
}

<# Options include:
     RelativeFilePaths - [bool]
         Always resolve file paths using Resolve-Path -Relative.
         The default is to use some heuristics to guess if relative or absolute is better.

   To customize your own custom options, pass a hashtable to CompleteInput, e.g.
         return [System.Management.Automation.CommandCompletion]::CompleteInput($inputScript, $cursorColumn,
             @{ RelativeFilePaths=$false }
#>
function TabExpansion2
{
	[CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
	Param (
		[Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
		[string] $inputScript,

		[Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 1)]
		[int] $cursorColumn,

		[Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
		[Management.Automation.Language.Ast] $ast,

		[Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
		[Management.Automation.Language.Token[]] $tokens,

		[Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
		[Management.Automation.Language.IScriptPosition] $positionOfCursor,

		[Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
		[Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
		[hashtable] $options = $null
	)
	$parsed = @{options = $options}
	$cmdline = GetCursorCommandLine @PSBoundParameters -parsed $parsed
	if ($cmdline.exec -in 'git','git.exe') {
		$expand = @{}
		$results = __git_complete $cmdline $expand
	}
	if (! $results -and $expand.inputScript) {
		$aliased = GetParamCommandLine @expand
		$cmdline.words = @(
			if ($aliased.exec -notin 'git','git.exe') {
				$aliased.exec
			}
			$aliased.words
			$cmdline.words[1..$cmdline.words.Count]
		)
		$results = __git_complete $cmdline
	}
	if (! $results -and $(Test-Path function:/NotGitTabExpansion2)) {
		return NotGitTabExpansion2 @parsed
	}
	return $results
}

function Prompt
{
	$ps_git = __git_prompt
	if (! $ps_git -and $(Test-Path function:/NotGitPrompt)) {
		return NotGitPrompt
	}
	if (! $PromptPrefix) {
		$PromptPrefix = {
			"PS $([Environment]::UserName)@$([Environment]::MachineName) $($PWD.Path.Replace($HOME, '~'))"
		}
	}
	if (! $PromptSuffix) {
		$PromptSuffix = {
			"`n$NestedPromptLevel> "
		}
	}
	"$($PromptPrefix.Invoke())$ps_git$($PromptSuffix.Invoke())"
}

$pubConf = @(
	'GIT_COMPLETION'
	'GIT_PS1'
)

$pubFunc = @(
	'GetCursorCommandLine' # for debug
	'GetParamCommandLine'  # for debug
	'TabExpansion2'
	'Prompt'
)

Export-ModuleMember -Variable $pubConf -Function $pubFunc
