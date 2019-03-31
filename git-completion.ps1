# pwsh completion support for core Git.
# vi: ts=2 sw=2
#
# A clone of git-completion.bash from:
# https://github.com/git/git/tree/master/contrib/completion
#
# The contained completion routines provide support for completing:
#
#    *) local and remote branch names
#    *) local and remote tag names
#    *) .git/remotes file names
#    *) git 'subcommands'
#    *) git email aliases for git-send-email
#    *) tree paths within 'ref:path/to/file' expressions
#    *) file paths within current working directory and index
#    *) common --long-options
#
# To use these routines:
#
#    1) Copy this file to where profile.ps1 is located. e.g.
#        $(Split-Path -Parent $PROFILE)/git-completion.ps1
#    2) Add the following line to your profile.ps1:
#        . $PSScriptRoot/git-completion.ps1
#    3) Consider changing your prompt to also show the current branch,
#       see git-prompt.ps1 for details.
#
# If you use complex aliases of form "!pwsh -c 'function f { ... }; f'",
# the argument @args or $args[a[..b]] will be searched to detect the desired
# completion style. For example,
#   "!pwsh -c 'function f { git commit `@args; ... }; f'"
# will tell the completion to use commit completion.
#
# You can set the following environment variables to influence the behavior of
# the completion routines:
#
#   GIT_COMPLETION.CHECKOUT_NO_GUESS
#
#     When set to "1", do not include "DWIM" suggestions in git-checkout
#     completion (e.g., completing "foo" when "origin/foo" exists).

$GIT_COMPLETION = @{
	CHECKOUT_NO_GUESS = $false
	OPTIONS = @(
		'--paginate','--no-pager','--git-dir'
		'--bare','--version','--exec-path'
		'--html-path','--man-path','--info-path'
		'--work-tree','--namespace'
		'--no-replace-objects','--help'
	)
	SUBOPTIONS = @{
		INPROGRESS = @{
			AM = '--skip','--continue','--resolved','--abort','--quit','--show-current-patch'
			CHERRY_PICK = '--continue','--quit','--abort'
			REBASE = '--continue','--skip','--abort','--quit','--show-current-patch'
			REVERT = '--continue','--quit','--abort'
		}
		DIFF_COMMON = @(
			'--stat','--numstat','--shortstat','--summary'
			'--patch-with-stat','--name-only','--name-status','--color'
			'--no-color','--color-words','--no-renames','--check'
			'--full-index','--binary','--abbrev','--diff-filter='
			'--find-copies-harder','--ignore-cr-at-eol'
			'--text','--ignore-space-at-eol','--ignore-space-change'
			'--ignore-all-space','--ignore-blank-lines','--exit-code'
			'--quiet','--ext-diff','--no-ext-diff'
			'--no-prefix','--src-prefix=','--dst-prefix='
			'--inter-hunk-context='
			'--patience','--histogram','--minimal'
			'--raw','--word-diff','--word-diff-regex='
			'--dirstat','--dirstat=','--dirstat-by-file'
			'--dirstat-by-file=','--cumulative'
			'--diff-algorithm='
			'--submodule','--submodule=','--ignore-submodules'
		)
		MERGETOOL_COMMON = @(
			'diffuse','diffmerge','ecmerge','emerge','kdiff3','meld','opendiff'
			'tkdiff','vimdiff','gvimdiff','xxdiff','araxis','p4merge','bc','codecompare'
		)
		FORMAT_PATCH_EXTRA = @(
			'--full-index','--not','--all','--no-prefix','--src-prefix='
			'--dst-prefix=','--notes'
		)
		LOG_COMMON = @(
			'--not','--all'
			'--branches','--tags','--remotes'
			'--first-parent','--merges','--no-merges'
			'--max-count='
			'--max-age=','--since=','--after='
			'--min-age=','--until=','--before='
			'--min-parents=','--max-parents='
			'--no-min-parents','--no-max-parents'
		)
		LOG_SHORTLOG = @(
			'--author=','--committer=','--grep='
			'--all-match','--invert-grep'
		)
	}
	WHITESPACELIST = 'nowarn','warn','error','error-all','fix'
	UNTRACKED_FILE_MODES = 'all','no','normal'
	DIFF_ALGORITHMS = 'myers','minimal','patience','histogram'
	DIFF_SUBMODULE_FORMATS = 'diff','log','short'
	FETCH_RECURSE_SUBMODULES = 'yes','on-demand','no'
	LOG_PRETTY_FORMATS = 'oneline','short','medium','full','fuller','email','raw','format:'
	LOG_DATE_FORMATS = 'relative','iso8601','rfc2822','short','local','default','raw'
	PUSH_RECURSE_SUBMODULES = 'check','on-demand','only'
	SEND_EMAIL_CONFIRM = 'always','never','auto','cc','compose'
	SEND_EMAIL_SUPPRESSCC = 'author','self','cc','bodycc','sob','cccmd','body','all'
}

function __git_complete
{
	param (
		[parameter(mandatory = $true)]
		[hashtable] $cmdline,
		[hashtable] $expand,
		[hashtable] $opts = $GIT_COMPLETION
	)

	$info = @{}

	# Runs git with all the options given as argument, respecting any
	# '--git-dir=<path>' and '-C <path>' options present on the command line
	function __git
	{
		$params = @(
			if ($info.git_C_args) {
				$info.git_C_args
			}
			if ($info.git_dir) {
				'--git-dir'
				$info.git_dir
			}
		)
		git @params @args
	}

	function __git2
	{
		__git @args 2>&1
	}

	# Discovers the path to the git repository taking any '--git-dir=<path>' and
	# '-C <path>' options into account and stores it in the $__git_repo_path
	# variable.
	function __git_repo_path
	{
		if (! $info.Contains('repo_path')) {
			if ($info.git_C_args) {
				$info.repo_path = __git rev-parse --absolute-git-dir 2> $null
			} elseif ($info.git_dir) {
				if (Test-Path -PathType Container -LiteralPath $info.git_dir) {
					$info.repo_path = $info.git_dir
				}
			} elseif ($env:GIT_DIR) {
				if (Test-Path -PathType Container -LiteralPath $env:GIT_DIR) {
					$info.repo_path = $env:GIT_DIR
				}
			} elseif (Test-Path -PathType Container -LiteralPath .git) {
				$info.repo_path = '.git'
			} else {
				$info.repo_path = __git rev-parse --git-dir 2> $null
			}
		}
		return $info.repo_path
	}

	function __git_dequote_token
	{
		param (
			[parameter(mandatory = $true)]
			[Management.Automation.Language.Token] $token
		)

		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::StringLiteral -or
				$token.Kind -eq [Management.Automation.Language.TokenKind]::StringExpandable) {
			return $token.Value
		}
		return $token.Text
	}

	# Generates completion reply, appending a space to possible completion words,
	# if necessary.
	# It accepts 1 to 4 arguments:
	# 1: List of possible completion words.
	# 2: A prefix to be added to each possible completion word (optional).
	# 3: Generate possible completion matches for this word (optional).
	# 4: A suffix to be appended to each possible completion word (optional).
	# 5. This is text (optional)
	# 6. Extra completion settings (optional)
	function __gitcomp
	{
		param (
			[parameter(mandatory = $true)]
			[hashtable[]] $complete,
			[string] $prefix,
			[string] $word = $info.curr,
			[string] $suffix,
			[switch] $text,
			[hashtable] $compopt = @{}
		)

		if ($word -like '--*=') {
			return
		}

		$conds = @(
			'--no-*'
		) | % {
			if ($word -notlike $_) {
				"`$_ -notlike '$_'"
			}
		}

		$matcher = if ($conds) {
			[scriptblock]::Create($conds -join ' -and ')
		} else {
			{$true}
		}

		$pattern = "$word*"

		# set common parameters
		if (! ($compopt.Contains('replaceIndex') -or $compopt.Contains('replaceLength'))) {
			if ($cmdline.curr) {
				$compopt.replaceIndex = $cmdline.curr.Extent.StartOffset
				$compopt.replaceLength = $cmdline.curr.Extent.EndOffset - $compopt.replaceIndex
			} else {
				$compopt.replaceIndex = $cmdline.cursor.Offset
				$compopt.replaceLength = 0
			}
		}
		if ($cmdline.curr.Text -match '^(?<q>[''"])') {
			$quote = $matches.q
		}

		$results = [Collections.Generic.List[Management.Automation.CompletionResult]]::new()
		$complete.ForEach({
			$suggest = $_.suggest
			$type = $_.type
			if (! $suggest) {
				return
			}
			if (! $type) {
				if ($text) {
					$type = [Management.Automation.CompletionResultType]::Text
				} else {
					$type = [Management.Automation.CompletionResultType]::ParameterName
				}
			}
			$suggest.Where($matcher).ForEach({
				$s = $_
				if ($suffix) {
					$s = "$s$suffix"
				}
				if ($s -notlike $pattern) {
					return
				}
				if ($prefix) {
					$s = "$prefix$s"
				}
				if ($quote -or $s -match '[ `$\][{}]') {
					switch ($quote) {
						'"' {
							$s = $s -replace '[`$]', '`$0'
						}
						default {
							$quote = "'"
							$s = $s -replace "'", "''"
						}
					}
					$s = "$quote$s$quote"
				}
				$results.Add([Management.Automation.CompletionResult]::new($s, $s, $type, $s))
			})
		})
		return [Management.Automation.CommandCompletion]::new($results, -1, $compopt.replaceIndex, $compopt.replaceLength)
	}

	# This function is equivalent to
	#
	#    __gitcomp "$(git xxx --git-completion-helper) ..."
	#
	# except that the output is cached. Accept 1-3 arguments:
	# 1: the git command to execute, this is also the cache key
	# 2: extra options to be added on top (e.g. negative forms)
	# 3: options to be excluded
	function __gitcomp_builtin
	{
		param (
			[parameter(mandatory = $true)]
			[string[]] $cmd,
			[string[]] $incl,
			[string[]] $excl
		)

		# avoid conflicting with object method
		$key = "_$($cmd -join '_')"

		if (! $opts.SUBOPTIONS.Contains($key)) {
			# NOTE depends on exe output
			$list = @(
				$incl
				$(__git @cmd --git-completion-helper) -split ' +'
			)
			if ($list) {
				$opts.SUBOPTIONS.$key = $list.Where({$_ -and $_ -notin $excl})
			}
		}

		return __gitcomp @{suggest = $opts.SUBOPTIONS.$key}
	}

	# Append completion to current word
	# 1. Match result 'k' of /^(?<k>.+)(?<v>.*)/
	# 2. Match result 'v' of /^(?<k>.+)(?<v>.*)/
	# 3. List of possible completion words
	# 4. This is text (optional)
	function __gitcomp_append
	{
		param (
			[string] $key,
			[string] $value,
			[parameter(mandatory = $true)]
			[hashtable[]] $complete,
			[switch] $text
		)

		$params = @{
			complete = $complete
			word = $value
		}
		if ($text) {
			$params.text = $true
		}

		if ($cmdline.curr) {
			$replaceIndex = $cmdline.curr.Extent.StartOffset + $key.Length
			$replaceLength = $cmdline.curr.Extent.EndOffset - $replaceIndex
		} else {
			$replaceIndex = $cmdline.cursor.Offset
			$replaceLength = 0
		}
		return __gitcomp @params -compopt @{
			replaceIndex = $replaceIndex
			replaceLength = $replaceLength
		}
	}

	# TODO reworks these functions
	# Lists branches from the local repository.
	# 1: A prefix to be added to each listed branch (optional).
	# 2: List only branches matching this word (optional; list all branches if
	#    unset or empty).
	# 3: A suffix to be appended to each listed branch (optional).
	function __git_heads
	{
		param (
			[string] $pfx,
			[string] $cur = $info.curr,
			[string] $sfx
		)

		__git for-each-ref --format="$($pfx -replace '%', '%%')%(refname:strip=2)$sfx" `
		                   "refs/heads/$cur*" `
		                   "refs/heads/$cur*/**"
	}

	# TODO reworks these functions
	# Lists tags from the local repository.
	# Accepts the same positional parameters as __git_heads() above.
	function __git_tags
	{
		param (
			[string] $pfx,
			[string] $cur = $info.curr,
			[string] $sfx
		)

		__git for-each-ref --format="$($pfx -replace '%', '%%')%(refname:strip=2)$sfx" `
		                   "refs/tags/$cur*" `
		                   "refs/tags/$cur*/**"
	}

	# TODO reworks these functions
	# Lists refs from the local (by default) or from a remote repository.
	# It accepts 0, 1 or 2 arguments:
	# 1: The remote to list refs from (optional; ignored, if set but empty).
	#    Can be the name of a configured remote, a path, or a URL.
	# 2: In addition to local refs, list unique branches from refs/remotes/ for
	#    'git checkout's tracking DWIMery (optional; ignored, if set but empty).
	# 3: A prefix to be added to each listed ref (optional).
	# 4: List only refs matching this word (optional; list all refs if unset or
	#    empty).
	# 5: A suffix to be appended to each listed ref (optional; ignored, if set
	#    but empty).
	function __git_refs
	{
		param (
			[string] $remote,
			[switch] $track,
			[string] $pfx,
			[string] $cur = $info.curr,
			[string] $sfx
		)

		$fer_pfx = $pfx -replace '%', '%%' # "escape" for-each-ref format specifiers
		$list_refs_from = 'path'

		$dir = __git_repo_path

		if (! $remote) {
			if (! $dir) {
				return
			}
			if ($cur -like '^*') {
				$pfx = "$pfx^"
				$fer_pfx = "$fer_pfx^"
				$cur = $cur -replace '^\^', ''
			}
		} else {
			if ($remote -in $(__git_remotes)) {
				# configured remote takes precedence over a
				# local directory with the same name
				$list_refs_from = 'remote'
			} elseif (Test-Path -PathType Container -LiteralPath $remote/.git) {
				$dir = "$remote/.git"
			} elseif (Test-Path -PathType Container -LiteralPath $remote) {
				$dir = $remote
			} else {
				$list_refs_from = 'url'
			}
		}

		if ($list_refs_from -eq 'path') {
			switch -regex ($cur) {
				'^(?:refs|refs/.*)$' {
					$format = 'refname'
					$refs = "$cur*","$cur*/**"
					continue
				}
				default {
					switch -wildcard ('HEAD','FETCH_HEAD','ORIG_HEAD','MERGE_HEAD','REBASE_HEAD') {
						"$cur*" {
							if (Test-Path -LiteralPath $dir/$_) {
								"$pfx$_$sfx"
							}
						}
					}
					$format = 'refname:strip=2'
					$refs = @('refs/tags','refs/heads','refs/remotes').ForEach({"$_/$cur*","$_/$cur*/**"})
				}
			}
			__git for-each-ref --format="$fer_pfx%($format)$sfx" @refs
			if ($track) {
				# employ the heuristic used by git checkout
				# Try to find a remote branch that matches the completion word
				# but only output if the branch name is unique
				__git for-each-ref --format="$fer_pfx%(refname:strip=3)$sfx" `
				                   --sort="refname:strip=3" `
				                   "refs/remotes/*/$cur*" `
				                   "refs/remotes/*/$cur*/**" | Select-Object -Unique
			}
			return
		}

		switch -regex ($cur) {
			'^(?:refs|refs/.*)$' {
				$pattern = '\t(?<v>.*)'
				$refs = "$cur*"
				continue
			}
			default {
				if ($list_refs_from -eq 'remote') {
					switch -wildcard ('HEAD') {
						"$cur*" {
							"$pfx$_$sfx"
						}
					}
					__git for-each-ref --format="$fer_pfx%(refname:strip=3)$sfx" `
					                   "refs/remotes/$remote/$cur*" `
					                   "refs/remotes/$remote/$cur*/**"
					return
				}
				switch -wildcard ('HEAD') {
					"$cur*" {
						$query_symref = $_
					}
				}
				$pattern = '\trefs/(?:.+/)?(?<v>.*)'
				$refs = "refs/tags/$cur*","refs/heads/$cur*","refs/remotes/$cur*"
			}
		}
		$(__git ls-remote --ref $remote $query_symref @refs).ForEach({
			if ($_ -match $pattern) {
				"$pfx$($matches.v)$sfx"
			} else {
				$hash,$i = $_ -split '\t'
				"$pfx$i$sfx" # symbolic refs
			}
		})
	}

	# TODO reworks these functions
	# __git_refs_remotes requires 1 argument (to pass to ls-remote)
	function __git_refs_remotes
	{
		param (
			[parameter(mandatory = $true)]
			[string] $repo,
			[string] $refspec = $info.curr
		)

		__git for-each-ref --format="%(if:equals=$repo)%(upstream:remotename)%(then)%(refname):%(upstream)%(end)" `
		                   "$refspec*" `
		                   "$refspec*/**" | ? Length
	}

	# Execute 'git ls-files', unless the --committable option is specified, in
	# which case it runs 'git diff-index' to find out the files that can be
	# committed.  It return paths relative to the directory specified in the first
	# argument, and using the options specified in the second argument.
	function __git_ls_files_helper
	{
		param (
			[string[]] $options,
			[string] $root = '.'
		)

		if ($options -eq '--committable') {
			__git -C $root diff-index --name-only --relative HEAD
		} else {
			__git -C $root ls-files --exclude-standard @options
		}
	}

	function __git_remotes
	{
		if (! $info.Contains('remotes')) {
			$info.remotes = @(
				if (Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/remotes") {
					Get-ChildItem -Name -LiteralPath "$(__git_repo_path)/remotes"
				}
				__git remote
			)
		}
		return $info.remotes
	}

	# 'git merge -s help' (and thus detection of the merge strategy
	# list) fails, unfortunately, if run outside of any git working
	# tree.  __git_merge_strategies is set to the empty string in
	# that case, and the detection will be repeated the next time it
	# is needed.
	function __git_merge_strategies
	{
		if (! $opts.Contains('MERGE_STRATEGIES')) {
			# NOTE depends on exe output
			$list = $(__git2 merge -s help).ForEach({
				if ($_ -match '^[^:]+: *(?<v>.+)\.$') {
					$matches.v -split ' +'
				}
			})
			if ($list) {
				$opts.MERGE_STRATEGIES = $list
			}
		}
		return $opts.MERGE_STRATEGIES
	}

	function __git_complete_revlist
	{
		switch -regex ($info.curr) {
			'\.\..+:' {
				return
			}
			'^(?<p>[^:]+:(?:.+[\\/])?)(?<v>.*)' {
				$pre = $matches.p
				$val = $matches.v
				# FIXME workaround for PSReadLine
				$pre = $pre -replace '\\$', ''
				$matches = __git ls-tree $pre | Select-String '^(?:100... blob.*\t(?<f>.+)|120000 blob.*\t(?<f>.+)|040000 tree.*\t(?<d>.+)|.*\t(?<f>.+))' | % Matches
				return __gitcomp -text -prefix $pre -word $val @(
					@{
						suggest = $matches | % {$_.Groups['d'].Captures} | % {"$($_.Value)/"}
						type = [Management.Automation.CompletionResultType]::ProviderContainer
					}
					@{
						suggest = $matches | % {$_.Groups['f'].Captures} | % Value
						type = [Management.Automation.CompletionResultType]::ProviderItem
					}
				)
			}
			'(?<p>.+\.\.\.?)(?<v>.*)' {
				return __gitcomp -text -prefix $matches.p -word $matches.v @{
					suggest = __git_refs -cur $matches.v
				}
			}
		}
		return __gitcomp -text @{suggest = __git_refs}
	}

	function __git_complete_remote_or_refspec
	{
		param (
			[parameter(mandatory = $true)]
			[string] $cmd,
			[string] $remote,
			[string] $word = $info.curr,
			[bool] $lhs = $true,
			[bool] $no_refspec = $false
		)
		if (! $remote) {
			return __gitcomp -text @{suggest = __git_remotes}
		}
		if ($no_refspec) {
			return
		}
		if ($remote -eq '.') {
			$remote = ''
		}
		switch -regex ($word) {
			'^(?<p>[^:]+:)(?<v>.*)' {
				$pre = $matches.p
				$val = $matches.v
				$lhs = $false
				continue
			}
			'^\+(?<v>.*)' {
				$pre = '+'
				$val = $matches.v
				continue
			}
			default {
				$val = $_
			}
		}
		switch ($cmd) {
			'fetch' {
				if ($lhs) {
					return __gitcomp_append -text $pre $val @{
						suggest = $(__git_refs -remote $remote -cur $val).ForEach({"$_`:$_"})
					}
				}
			}
			{$_ -in 'pull','remote'} {
				if ($lhs) {
					return __gitcomp_append -text $pre $val @{
						suggest = __git_refs -remote $remote -cur $val
					}
				}
			}
			'push' {
				if (! $lhs) {
					return __gitcomp_append -text $pre $val @{
						suggest = __git_refs -remote $remote -cur $val
					}
				}
			}
		}
		return __gitcomp_append -text $pre $val @{suggest = __git_refs -cur $val}
	}

	# __git_complete_index_file accepts 1 or 2 arguments:
	# 1: Options to pass to ls-files (required).
	# 2: A directory path (optional).
	#    If provided, only files within the specified directory are listed.
	#    Sub directories are never recursed.  Path must have a trailing
	#    slash.
	function __git_complete_index_file
	{
		param (
			[string[]] $options,
			[string] $word = $info.curr
		)

		switch -regex ($word) {
			'^(?<p>.+[\\/])(?<v>.*)' {
				$pre = $matches.p
				$val = $matches.v
				# FIXME workaround for PSReadLine
				$pre = $pre -replace '\\$', ''
			}
			default {
				$val = $_
			}
		}
		# NOTE this works because git does not list directory itself
		$params = @{options = $options}
		if ($pre) { $params.root = $pre }
		$matches = __git_ls_files_helper @params | Select-String '(?<d>^[^/]+/)|(?<f>^[^/]+$)' | % Matches
		return __gitcomp -text -prefix $pre -word $val @(
			@{
				suggest = $matches | % {$_.Groups['d'].Captures} | Select-Object -Unique | % Value
				type = [Management.Automation.CompletionResultType]::ProviderContainer
			}
			@{
				suggest = $matches | % {$_.Groups['f'].Captures} | % Value
				type = [Management.Automation.CompletionResultType]::ProviderItem
			}
		)
	}

	function __git_complete_strategy
	{
		switch ($info.prev) {
			'-s' {
				$info.result = __gitcomp -text @{suggest = __git_merge_strategies}
				return $info.result
			}
		}
		switch -regex ($info.curr) {
			'^(?<k>--strategy=)(?<v>.*)' {
				$info.result = __gitcomp_append $matches.k $matches.v @{suggest = __git_merge_strategies}
				return $info.result
			}
		}
	}

	function __git_complete_re_message
	{
		switch ($info.prev) {
			{$_ -in '-c','-C'} {
				$info.result = __gitcomp -text @{suggest = __git_refs}
				return $info.result
			}
		}
		switch -regex ($info.curr) {
			'^(?<k>--(?:reuse-message|reedit-message)=)(?<v>.*)' {
				$info.result = __gitcomp_append $matches.k $matches.v @{suggest = __git_refs -cur $matches.v}
				return $info.result
			}
		}
	}

	function __git_all_commands
	{
		if (! $opts.Contains('ALL_COMMANDS')) {
			$list = $(__git --list-cmds='main,others,alias,nohelpers') -split ' +'
			if ($list) {
				$opts.ALL_COMMANDS = $list.Where({$_})
			}
		}
		return $opts.ALL_COMMANDS
	}

	function __git_porcelain_commands
	{
		if (! $opts.Contains('PORCELAIN_COMMANDS')) {
			$list = $(__git --list-cmds='list-mainporcelain,others,nohelpers,alias,list-complete,config') -split ' +'
			if ($list) {
				$opts.PORCELAIN_COMMANDS = $list.Where({$_})
			}
		}
		return $opts.PORCELAIN_COMMANDS
	}

	function __git_help_commands
	{
		if (! $opts.Contains('HELP_COMMANDS')) {
			$list = $(__git --list-cmds='main,nohelpers,alias,list-guide') -split ' +'
			if ($list) {
				$opts.HELP_COMMANDS = $list.Where({$_})
			}
		}
		return $opts.HELP_COMMANDS
	}

	# __git_aliased_command requires 1 argument
	function __git_aliased_command
	{
		param (
			[parameter(mandatory = $true)]
			[string] $command
		)

		__git config --get alias.$command
	}

	# __git_find_on_cmdline requires 1 argument
	function __git_find_on_cmdline
	{
		param (
			[parameter(mandatory = $true)]
			[string[]] $words
		)

		switch ($info.words) {
			{$_ -in $words} {
				return $_
			}
		}
	}

	function __git_all_config_vars
	{
		if (! $opts.Contains('ALL_CONFIG')) {
			$list = __git help --config-for-completion | Sort-Object -Unique
			if ($list) {
				$opts.ALL_CONFIG = $list.Where({$_})
			}
		}
		return $opts.ALL_CONFIG
	}

	# Lists all set config variables starting with the given section prefix,
	# with the prefix removed.
	function __git_get_config_variables
	{
		param (
			[parameter(mandatory = $true)]
			[string] $section
		)

		$(__git config --name-only --get-regexp "^$section\..*" 2> $null) -replace "^$section\.", ''
	}

	function __git_config_get_set_variables
	{
		switch -wildcard ($info.words) {
			{$_ -in '--system','--global','--local'} {
				$config_file = @($_)
				break
			}
			'--file=*' {
				$config_file = @($_)
				break
			}
			{$_ -in '-f','--file'} {
				$config_file = @($_)
				continue
			}
			default {
				if ($config_file) {
					$config_file += $_
					break
				}
			}
		}
		__git config @config_file --name-only --list
	}

	# Complete symbol names from a tag file.
	# Usage: __git_complete_symbol [<option>]...
	# --tags=<file>: The tag file to list symbol names from instead of the
	#                default "tags".
	# --pfx=<prefix>: A prefix to be added to each symbol name.
	# --cur=<word>: The current symbol name to be completed.  Defaults to
	#               the current word to be completed.
	# --sfx=<suffix>: A suffix to be appended to each symbol name instead
	#                 of the default space.
	function __git_complete_symbol
	{
		param (
			[string] $tags = 'tags',
			[string] $pfx,
			[string] $cur = $info.curr,
			[string] $sfx
		)

		if (Test-Path -Type Leaf -LiteralPath $tags) {
			$matches = Select-String "^(?<s>$cur\S*)" $tags | % Matches
			$info.result = __gitcomp_append -text $pfx $cur @{
				suggest = $matches | % {$_.Groups['s'].Captures} | % {"$($_.Value)$sfx"}
			}
			return $info.result
		}
	}

	function __git_support_parseopt_helper
	{
		param (
			[parameter(mandatory = $true)]
			[string] $cmd
		)
		if (! $opts.Contains('PARSEOPT_COMMANDS')) {
			$list = $(__git --list-cmds='parseopt') -split ' +'
			if ($list) {
				$opts.PARSEOPT_COMMANDS = $list.Where({$_})
			}
		}
		return $cmd -in $opts.PARSEOPT_COMMANDS
	}

	function _git_cmd
	{
		param (
			[parameter(mandatory = $true)]
			[string] $command
		)

		switch ($command) {

			'am' {
				if (Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/rebase-apply") {
					return __gitcomp @{suggest = $opts.SUBOPTIONS.INPROGRESS.AM}
				}
				switch -regex ($info.curr) {
					'^(?<k>--whitespace=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.WHITESPACELIST}
					}
					'^--' {
						return __gitcomp_builtin $command -excl $opts.SUBOPTIONS.INPROGRESS.AM
					}
				}
			}

			'apply' {
				switch -regex ($info.curr) {
					'^(?<k>--whitespace=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.WHITESPACELIST}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
			}

			'add' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				$complete_opt = '--modified','--directory','--no-empty-directory','--others'
				if (__git_find_on_cmdline '-u','--update') {
					$complete_opt = '--modified'
				}
				return __git_complete_index_file $complete_opt
			}

			'archive' {
				switch -regex ($info.curr) {
					'^(?<k>--format=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git archive --list}
					}
					'^(?<k>--remote=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git_remotes}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--format=','--list','--verbose',
								'--prefix=','--remote=','--exec','--output'
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'bisect' {
				if ($info.has_doubledash) {
					return
				}
				$subcommands = 'start','bad','good','skip','reset','visualize','replay','log','run'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/BISECT_START") {
						return __gitcomp -text @{suggest = $subcommands}
					}
					return __gitcomp -text @{suggest = 'replay','start'}
				}
				switch ($subcommand) {
					{$_ -in 'bad','good','reset','skip','start'} {
						return __gitcomp -text @{suggest = __git_refs}
					}
				}
			}

			'branch' {
				switch ($info.prev) {
					'-u' {
						return __gitcomp -text @{suggest = __git_refs}
					}
				}
				switch -regex ($info.curr) {
					'^(?<k>--set-upstream-to=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git_refs -cur $matches.v}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				switch ($info.words) {
					{$_ -in '-d','--delete','-m','--move'} {
						$only_local_ref = $true
					}
					{$_ -in '-r','--remotes'} {
						$has_r = $true
					}
				}
				if ($only_local_ref -and ! $has_r) {
					return __gitcomp -text @{suggest = __git_heads}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'bundle' {
				$subcommands = 'create','list-heads','verify','unbundle'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					return __gitcomp -text @{suggest = $subcommands}
				}
				if ($info.prev -in $subcommand) {
					# looking for a file
					return
				}
				switch ($subcommand) {
					'create' {
						return __git_complete_revlist
					}
					{$_ -in 'list-heads','unbundle'} {
						return __gitcomp -text @{suggest = __git_refs}
					}
				}
			}

			'checkout' {
				if ($info.has_doubledash) {
					return
				}
				switch -regex ($info.curr) {
					'^(?<k>--conflict=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'diff3','merge'}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				# check if --track, --no-track, or --no-guess was specified
				# if so, disable DWIM mode
				$track_opt = @{track = $true}
				if ($opts.CHECKOUT_NO_GUESS -or
				    $(__git_find_on_cmdline '--track','--no-track','--no-guess')) {
					$track_opt.track = $false
				}
				return __gitcomp -text @{suggest = __git_refs @track_opt}
			}

			'cherry-pick' {
				if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/CHERRY_PICK_HEAD") {
					return __gitcomp @{suggest = $opts.SUBOPTIONS.INPROGRESS.CHERRY_PICK}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command -excl $opts.SUBOPTIONS.INPROGRESS.CHERRY_PICK
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'clean' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				# XXX should we check for -x option ?
				return __git_complete_index_file '--others','--directory'
			}

			'clone' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
			}

			'commit' {
				if (__git_complete_re_message) {
					return $info.result
				}
				switch -regex ($info.curr) {
					'^(?<k>--cleanup=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = 'default','scissors','strip','verbatim','whitespace'
						}
					}
					'^(?<k>--(?:fixup|squash)=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git_refs -cur $matches.v}
					}
					'^(?<k>--untracked-files=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.UNTRACKED_FILE_MODES}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				__git rev-parse --verify --quiet HEAD > $null
				if ($LASTEXITCODE) {
					# This is the first commit
					return __git_complete_index_file '--cached'
				}
				return __git_complete_index_file '--committable'
			}

			'config' {
				switch -regex ($info.prev) {
					{$_ -like 'branch.*.remote'} {
						return __gitcomp -text @{suggest = __git_remotes}
					}
					{$_ -like 'branch.*.pushremote'} {
						return __gitcomp -text @{suggest = __git_remotes}
					}
					{$_ -like 'branch.*.merge'} {
						return __gitcomp -text @{suggest = __git_refs}
					}
					{$_ -like 'branch.*.rebase'} {
						return __gitcomp -text @{suggest = 'false','true','merges','preserve','interactive'}
					}
					{$_ -in 'remote.pushdefault'} {
						return __gitcomp -text @{suggest = __git_remotes}
					}
					'^remote\.(?<k>.+)\.fetch$' {
						if (! $info.curr) {
							return __gitcomp -text @{suggest = 'refs/heads/'}
						}
						return __gitcomp -text @{suggest = __git_refs_remotes $matches.k}
					}
					'^remote\.(?<k>.+)\.push$' {
						return __gitcomp -text @{
							suggest = __git for-each-ref --format='%(refname):%(refname)' refs/heads
						}
					}
					{$_ -in 'pull.twohead','pull.octopus'} {
						return __gitcomp -text @{suggest = __git_merge_strategies}
					}
					{$_ -in 'color.branch','color.diff','color.interactive',
					        'color.showbranch','color.status','color.ui'} {
						return __gitcomp -text @{suggest = 'always','never','auto'}
					}
					{$_ -in 'color.pager'} {
						return __gitcomp -text @{suggest = 'false','true'}
					}
					{$_ -like 'color.*.*'} {
						return __gitcomp -text @{
							suggest = @(
								'normal','black','red','green','yellow','blue','magenta','cyan','white'
								'bold','dim','ul','blink','reverse'
							)
						}
					}
					{$_ -in 'diff.submodule'} {
						return __gitcomp -text @{suggest = 'log','short'}
					}
					{$_ -in 'help.format'} {
						return __gitcomp -text @{suggest = 'man','info','web','html'}
					}
					{$_ -in 'log.date'} {
						return __gitcomp -text @{suggest = $opts.LOG_DATE_FORMATS}
					}
					{$_ -in 'sendemail.aliasfiletype'} {
						return __gitcomp -text @{suggest = 'mutt','mailrc','pine','elm','gnus'}
					}
					{$_ -in 'sendemail.confirm'} {
						return __gitcomp -text @{suggest = $opts.SEND_EMAIL_CONFIRM}
					}
					{$_ -in 'sendemail.suppresscc'} {
						return __gitcomp -text @{suggest = $opts.SEND_EMAIL_SUPPRESSCC}
					}
					{$_ -in 'sendemail.transferencoding'} {
						return __gitcomp -text @{suggest = '7bit','8bit','quoted-printable','base64'}
					}
					'^--(?:get|unset)(?:-all)?$' {
						return __gitcomp -text @{suggest = __git_config_get_set_variables}
					}
					{$_ -in '-f','--file'} {
						# fallback to pwsh file completion
						return
					}
					'^\w+(?:\.\w+)+$' {
						return
					}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
					'^(?<k>branch\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = 'remote','pushRemote','merge','mergeOptions','rebase'
						}
					}
					'^(?<k>branch\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								__git_heads -cur $matches.v
								'autoSetupMerge','autoSetupRebase'
							)
						}
					}
					'^(?<k>guitool\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								'argPrompt','cmd','confirm','needsFile','noConsole','noRescan'
								'prompt','revPrompt','revUnmerged','title'
							)
						}
					}
					'^(?<k>difftool\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{suggest = 'cmd','path'}
					}
					'^(?<k>man\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{suggest = 'cmd','path'}
					}
					'^(?<k>mergetool\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{suggest = 'cmd','path','trustExitCode'}
					}
					'^(?<k>pager\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{suggest = __git_all_commands}
					}
					'^(?<k>remote\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								'url','proxy','fetch','push','mirror','skipDefaultUpdate'
								'receivepack','uploadpack','tagOpt','pushurl'
							)
						}
					}
					'^(?<k>remote\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								__git_remotes
								'pushDefault'
							)
						}
					}
					'^(?<k>url\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{suggest = 'insteadOf','pushInsteadOf'}
					}
				}
				$matcher = "(\w+(\.\w+){$($info.curr.ToCharArray().Where({$_ -eq '.'}).Count)}).*"
				return __gitcomp -text @{suggest = @(__git_all_config_vars) -replace $matcher,'$1' | Sort-Object -Unique}
			}

			'describe' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'diff' {
				if ($info.has_doubledash) {
					return
				}
				switch -regex ($info.curr) {
					'^(?<k>--diff-algorithm=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.DIFF_ALGORITHMS}
					}
					'^(?<k>--submodule=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.DIFF_SUBMODULE_FORMATS}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--cached','--staged','--pickaxe-all','--pickaxe-regex'
								'--base','--ours','--theirs','--no-index'
								$opts.SUBOPTIONS.DIFF_COMMON
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'difftool' {
				if ($info.has_doubledash) {
					return
				}
				switch -regex ($info.curr) {
					'^(?<k>--tool=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.SUBOPTIONS.MERGETOOL_COMMON}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--base','--cached','--ours','--theirs'
								'--pickaxe-all','--pickaxe-regex'
								'--relative','--staged'
								$opts.SUBOPTIONS.DIFF_COMMON
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'fetch' {
				switch -regex ($info.curr) {
					'^(?<k>--recurse-submodules=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.FETCH_RECURSE_SUBMODULES}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				$params = @{cmd = $command}
				switch -wildcard ($info.words) {
					'--all' {
						return
					}
					{$_ -in '--multiple'} {
						$params.no_refspec = $true
						break
					}
					$info.curr {
						continue
					}
					$command {
						continue
					}
					'-*' {
						continue
					}
					default {
						$params.remote = $_
						break
					}
				}
				return __git_complete_remote_or_refspec @params
			}

			'format-patch' {
				switch -regex ($info.curr) {
					'^(?<k>--thread=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'deep','shallow'}
					}
					'^--' {
						return __gitcomp_builtin $command -incl $opts.SUBOPTIONS.FORMAT_PATCH_EXTRA
					}
				}
				return __git_complete_revlist
			}

			'fsck' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
			}

			'grep' {
				if ($info.has_doubledash) {
					return
				}
				if ($info.words.Count -eq 1 -or $info.prev -like '-*') {
					if (__git_complete_symbol) {
						return $info.result
					}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'help' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_help_commands}
			}

			'init' {
				switch -regex ($info.curr) {
					'^(?<k>--shared=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = 'false','true','umask','group','all','world','everybody'
						}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
			}

			'ls-files' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				# XXX ignore options like --modified and always suggest all cached
				# files.
				return __git_complete_index_file '--cached'
			}

			'ls-remote' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_remotes}
			}

			'ls-tree' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __git_complete_revlist
			}

			'log' {
				if ($info.has_doubledash) {
					return
				}
				if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/MERGE_HEAD") {
					$merge = '--merge'
				}
				switch ($info.prev) {
					'-L' {
						switch -regex ($info.curr) {
							'^:.*:' {
								return # fall back to pwsh filename completion
							}
							'^(?<k>:)(?<v>.*)' {
								return __git_complete_symbol -pfx $matches.k -cur $matches.v -sfx ':'
							}
						}
					}
					{$_ -in '-G','-S'} {
						return __git_complete_symbol
					}
				}
				switch -regex ($info.curr) {
					'^(?<k>--(?:pretty|format)=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = @(
								$opts.LOG_PRETTY_FORMATS
								__git_get_config_variables 'pretty'
							)
						}
					}
					'^(?<k>--date=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.LOG_DATE_FORMATS}
					}
					'^(?<k>--decorate=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'full','short','no'}
					}
					'^(?<k>--diff-algorithm=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.DIFF_ALGORITHMS}
					}
					'^(?<k>--submodule=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.DIFF_SUBMODULE_FORMATS}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								$opts.SUBOPTIONS.LOG_COMMON
								$opts.SUBOPTIONS.LOG_SHORTLOG
								'--root','--topo-order','--date-order','--reverse'
								'--follow','--full-diff'
								'--abbrev-commit','--abbrev='
								'--relative-date','--date='
								'--pretty=','--format=','--oneline'
								'--show-signature'
								'--cherry-mark'
								'--cherry-pick'
								'--graph'
								'--decorate','--decorate='
								'--walk-reflogs'
								'--parents','--children'
								if ($merge) {
									$merge
								}
								'--pickaxe-all','--pickaxe-regex'
								$opts.SUBOPTIONS.DIFF_COMMON
							)
						}
					}
					'^-L:.*:' {
						return # fall back to pwsh filename completion
					}
					'^(?<k>-L:)(?<v>.*)' {
						return __git_complete_symbol -pfx $matches.k -cur $matches.v -sfx ':'
					}
					'^(?<k>-G|-S)(?<v>.*)' {
						return __git_complete_symbol -pfx $matches.k -cur $matches.v
					}
				}
				return __git_complete_revlist
			}

			'merge' {
				if (__git_complete_strategy) {
					return $info.result
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'mergetool' {
				switch -regex ($info.curr) {
					'^(?<k>--tool=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.SUBOPTIONS.MERGETOOL_COMMON}
					}
					'^--' {
						return __gitcomp @{suggest = '--tool=','--prompt','--no-prompt','--gui','--no-gui'}
					}
				}
			}

			'merge-base' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'mv' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				$complete_opt = @(
					'--cached'
					if ($info.argument_count) {
						# We need to show both cached and untracked files (including
						# empty directories) since this may not be the last argument.
						'--directory','--others'
					}
				)
				return __git_complete_index_file $complete_opt
			}

			'notes' {
				$subcommands = 'add','append','copy','edit','get-ref','list','merge','prune','remove','show'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					switch ($info.prev) {
						'--ref' {
							return __gitcomp -text @{suggest = __git_refs}
						}
					}
					switch -regex ($info.curr) {
						'^--' {
							return __gitcomp_builtin $command
						}
					}
					return __gitcomp -text @{
						suggest = @(
							$subcommands
							'--ref'
						)
					}
				}
				switch ($subcommand) {
					{$_ -in 'add','append'} {
						switch ($info.prev) {
							{$_ -in '-m','--message'} {
								return
							}
							{$_ -in '-F','--file'} {
								return
							}
						}
						if (__git_complete_re_message) {
							return $info.result
						}
					}
					'merge' {
						if (__git_complete_strategy) {
							return $info.result
						}
					}
					{$_ -in 'prune','get-ref'} {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp_builtin $command,$subcommand
							}
						}
						# this command does not take a ref, do not complete it
						return
					}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command,$subcommand
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'pull' {
				if (__git_complete_strategy) {
					return $info.result
				}
				switch -regex ($info.curr) {
					'^(?<k>--recurse-submodules=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.FETCH_RECURSE_SUBMODULES}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				$params = @{cmd = $command}
				switch -wildcard ($info.words) {
					{$_ -in '--multiple'} {
						$params.no_refspec = $true
						break
					}
					$info.curr {
						continue
					}
					$command {
						continue
					}
					'-*' {
						continue
					}
					default {
						$params.remote = $_
						break
					}
				}
				return __git_complete_remote_or_refspec @params
			}

			'push' {
				switch -regex ($info.curr) {
					'^(?<k>--repo=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git_remotes}
					}
					'^(?<k>--recurse-submodules=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.PUSH_RECURSE_SUBMODULES}
					}
					'^(?<k>--force-with-lease=(?:[^:]+:)?)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git_refs -cur $matches.v}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				$params = @{cmd = $command}
				switch -wildcard ($info.words) {
					{$_ -in '-d','--delete'} {
						$params.lhs = $false
					}
					{$_ -in '--all','--mirror'} {
						$params.no_refspec = $true
					}
					{$_ -in '--multiple'} {
						$params.no_refspec = $true
						break
					}
					$info.curr {
						continue
					}
					$command {
						continue
					}
					'-*' {
						continue
					}
					default {
						$params.remote = $_
						break
					}
				}
				return __git_complete_remote_or_refspec @params
			}

			'range-diff' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--creation-factor=','--no-dual-color'
								$opts.SUBOPTIONS.DIFF_COMMON
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'rebase' {
				if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/rebase-merge/interactive") {
					return __gitcomp @{
						suggest = @(
							$opts.SUBOPTIONS.INPROGRESS.REBASE
							'--edit-todo'
						)
					}
				}
				if ((Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/rebase-apply") -or
				    (Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/rebase-merge")) {
					return __gitcomp @{suggest = $opts.SUBOPTIONS.INPROGRESS.REBASE}
				}
				if (__git_complete_strategy) {
					return $info.result
				}
				switch -regex ($info.curr) {
					'^(?<k>--whitespace=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.WHITESPACELIST}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--onto','--merge','--strategy=','--interactive'
								'--rebase-merges','--preserve-merges','--stat','--no-stat'
								'--committer-date-is-author-date','--ignore-date'
								'--ignore-whitespace','--whitespace='
								'--autosquash','--no-autosquash'
								'--fork-point','--no-fork-point'
								'--autostash','--no-autostash'
								'--verify','--no-verify'
								'--keep-empty','--root','--force-rebase','--no-ff'
								'--rerere-autoupdate'
								'--exec'
							)
						}
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'reflog' {
				$subcommands = 'show','delete','expire'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					return __gitcomp -text @{suggest = $subcommands}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'send-email' {
				switch ($info.prev) {
					{$_ -in '--to','--cc','--bcc','--from'} {
						return __gitcomp -text @{suggest = __git send-email --dump-aliases}
					}
				}
				switch -regex ($info.curr) {
					'^(?<k>--confirm=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.SEND_EMAIL_CONFIRM}
					}
					'^(?<k>--suppress-cc=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.SEND_EMAIL_SUPPRESSCC}
					}
					'^(?<k>--smtp-encryption=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'ssl','tls'}
					}
					'^(?<k>--thread=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'deep','shallow'}
					}
					'^(?<k>--(?:to|cc|bcc|from)=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git send-email --dump-aliases}
					}
					'^--' {
						return __gitcomp_builtin $command -incl @(
							'--annotate','--bcc','--cc','--cc-cmd','--chain-reply-to'
							'--compose','--confirm=','--dry-run','--envelope-sender'
							'--from','--identity'
							'--in-reply-to','--no-chain-reply-to','--no-signed-off-by-cc'
							'--no-suppress-from','--no-thread','--quiet','--reply-to'
							'--signed-off-by-cc','--smtp-pass','--smtp-server'
							'--smtp-server-port','--smtp-encryption=','--smtp-user'
							'--subject','--suppress-cc=','--suppress-from','--thread','--to'
							'--validate','--no-validate'
							$opts.SUBOPTIONS.FORMAT_PATCH_EXTRA
						)
					}
				}
				return __git_complete_revlist
			}

			'stage' {
				return _git_cmd add
			}

			'status' {
				switch -regex ($info.curr) {
					'^(?<k>--ignore-submodules=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'none','untracked','dirty','all'}
					}
					'^(?<k>--untracked-files=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.UNTRACKED_FILE_MODES}
					}
					'^(?<k>--column=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = 'always','never','auto','column','row','plain','dense','nodense'
						}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				switch -regex ($info.words) {
					'^(?:-u|--untracked-files=)(?<v>.*)' {
						$untracked_state = $matches.v
						continue
					}
					{$_ -in '--ignored'} {
						$ignored = '--ignored','--exclude=*'
						continue
					}
				}
				if (! $untracked_state) {
					# NOTE empty array if no config is found
					$untracked_state = [string] $(__git config 'status.showUntrackedFiles' 2> $null)
				}
				switch ($untracked_state) {
					'no' {
						# --ignored option does not matter
					}
					default {
						$complete_opt = @(
							'--cached','--directory','--no-empty-directory','--others'
							if ($ignored) {
								$ignored
							}
						)
					}
				}
				return __git_complete_index_file $complete_opt
			}

			'remote' {
				$subcommands = @(
					'add','rename','remove','set-head','set-branches'
					'get-url','set-url','show','prune','update'
				)
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					switch -regex ($info.curr) {
						'^--' {
							return __gitcomp_builtin $command
						}
					}
					return __gitcomp -text @{suggest = $subcommands}
				}
				switch ($subcommand) {
					'add' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp_builtin $command,$subcommand
							}
						}
						return
					}
					{$_ -in 'set-head','set-branches'} {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp_builtin $command,$subcommand
							}
						}
						$params = @{cmd = $command}
						switch -wildcard ($info.words) {
							{$_ -in '--multiple'} {
								$params.no_refspec = $true
								break
							}
							$info.curr {
								continue
							}
							$command {
								continue
							}
							$subcommand {
								continue
							}
							'-*' {
								continue
							}
							default {
								$params.remote = $_
								break
							}
						}
						return __git_complete_remote_or_refspec @params
					}
					'update' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp_builtin $command,$subcommand
							}
						}
						return __gitcomp -text @{
							suggest = @(
								__git_remotes
								__git_get_config_variables 'remotes'
							)
						}
					}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command,$subcommand
					}
				}
				return __gitcomp -text @{suggest = __git_remotes}
			}

			'replace' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'rerere' {
				$subcommands = 'clear','forget','diff','remaining','status','gc'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					return __gitcomp -text @{suggest = $subcommands}
				}
			}

			'reset' {
				if ($info.has_doubledash) {
					return
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'revert' {
				if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/REVERT_HEAD") {
					return __gitcomp @{suggest = $opts.SUBOPTIONS.INPROGRESS.REVERT}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command -excl $opts.SUBOPTIONS.INPROGRESS.REVERT
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'rm' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __git_complete_index_file '--cached'
			}

			'shortlog' {
				if ($info.has_doubledash) {
					return
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp @{
							suggest = @(
								$opts.LOG_COMMON
								$opts.LOG_SHORTLOG
								'--numbered','--summary','--email'
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'show' {
				if ($info.has_doubledash) {
					return
				}
				switch -regex ($info.curr) {
					'^(?<k>--(?:pretty|format)=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = @(
								$opts.LOG_PRETTY_FORMATS
								__git_get_config_variables 'pretty'
							)
						}
					}
					'^(?<k>--diff-algorithm=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.DIFF_ALGORITHMS}
					}
					'^(?<k>--submodule=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $opts.DIFF_SUBMODULE_FORMATS}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--pretty=','--format=','--abbrev-commit','--oneline'
								'--show-signature'
								$opts.DIFF_COMMON
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'show-branch' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __git_complete_revlist
			}

			'stash' {
				$save_opts = '--all','--keep-index','--no-keep-index','--quiet','--patch','--include-untracked'
				$subcommands = 'push','list','show','apply','clear','drop','pop','create','branch'
				$subcommandaliases = @{
					'-p' = 'push'
				}
				$subcommand = __git_find_on_cmdline $subcommands,$subcommandaliases.Keys,'save'
				if (! $subcommand) {
					switch -regex ($info.curr) {
						'^--' {
							return __gitcomp @{suggest = $save_opts}
						}
					}
					if (__git_find_on_cmdline $save_opts) {
						if ($info.curr -like 'sa*') {
							return __gitcomp @{suggest = 'save'}
						}
						return
					}
					return __gitcomp -text @{suggest = $subcommands}
				}
				if ($subcommand -in $subcommandaliases.Keys) {
					$subcommand = $subcommandaliases.$subcommand
				}
				switch ($subcommand) {
					'push' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{
									suggest = @(
										$save_opts
										'--message'
									)
								}
							}
						}
						return
					}
					'save' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = $save_opts}
							}
						}
						return
					}
					{$_ -in 'apply','pop'} {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--index','--quiet'}
							}
						}
					}
					'drop' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--quiet'}
							}
						}
					}
					'list' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--name-status','--oneline','--patch-with-stat'}
							}
						}
					}
					'show' {
						switch -regex ($info.curr) {
							'^--' {
								return
							}
						}
					}
					'branch' {
						if ($info.prev -in $subcommand) {
							return __gitcomp -text @{suggest = __git_refs}
						}
						switch -regex ($info.curr) {
							'^--' {
								return
							}
						}
					}
					default {
						return
					}
				}
				return __gitcomp -text @{suggest = __git reflog --format='%gd' refs/stash}
			}

			'submodule' {
				if ($info.has_doubledash) {
					return
				}
				$subcommands = 'add','status','init','deinit','update','summary','foreach','sync','absorbgitdirs'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					switch -regex ($info.curr) {
						'^--' {
							return __gitcomp @{suggest = '--quiet'}
						}
					}
					return __gitcomp -text @{suggest = $subcommands}
				}
				switch ($subcommand) {
					'add' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--branch','--force','--name','--reference','--depth'}
							}
						}
					}
					'status' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--cached','--recursive'}
							}
						}
					}
					'deinit' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--force','--all'}
							}
						}
					}
					'update' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{
									suggest = @(
										'--init','--remote','--no-fetch'
										'--recommend-shallow','--no-recommend-shallow'
										'--force','--rebase','--merge','--reference','--depth','--recursive','--jobs'
									)
								}
							}
						}
					}
					'summary' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--cached','--files','--summary-limit'}
							}
						}
					}
					{$_ -in 'foreach','sync'} {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--recursive'}
							}
						}
					}
				}
			}

			'tag' {
				if ($info.prev -in '-d','--delete','-v','--verify' -or
				    (($info.words.Count -eq 1 -or $info.prev -like '-*') -and
				     $(__git_find_on_cmdline '-f'))) {
					return __gitcomp @{suggest = __git_tags}
				}
				switch ($info.prev) {
					{$_ -in '-m','--message'} {
						return
					}
					{$_ -in '-F','--file'} {
						return
					}
				}
				switch -regex ($info.curr) {
					'^(?<k>--cleanup=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = 'default','scissors','strip','verbatim','whitespace'
						}
					}
					'^(?<k>--column=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = 'always','never','auto','column','row','plain','dense','nodense'
						}
					}
					'^(?<k>--(?:no-)?(?:contains|merged)=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = __git_refs -cur $matches.v}
					}
					'^--' {
						return __gitcomp_builtin $command
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'whatchanged' {
				return _git_cmd log
			}

			'worktree' {
				$subcommands = 'add','list','lock','move','prune','remove','unlock'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					return __gitcomp -text @{suggest = $subcommands}
				}
				switch ($subcommand) {
					{$_ -in 'add','list','lock','prune'} {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp_builtin $command,$subcommand
							}
						}
					}
					'remove' {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp @{suggest = '--force'}
							}
						}
					}
				}
			}

			default {
				# complete builtin common
				if (__git_support_parseopt_helper $command) {
					switch -regex ($info.curr) {
						'^--' {
							return __gitcomp_builtin $command
						}
					}
					return
				}
				# alias expansion
				if ($expand) {
					$expand.inputScript = __git_aliased_command $command
					$expand.paramName = 'args'
					$expand.paramIndex = $info.parameter_curr
				}
			}

		}
	}

	$info.prev = if ($cmdline.prev) { __git_dequote_token $cmdline.prev }
	$info.curr = if ($cmdline.curr) { __git_dequote_token $cmdline.curr }
	$info.words = for ($idx = 0; $idx -lt $cmdline.words.Count; $idx++) {
		switch -regex (__git_dequote_token $cmdline.words[$idx]) {
			'^--git-dir=(?<path>.+)' {
				$info.git_dir = $matches.path
				continue
			}
			{$_ -in '--git-dir'} {
				if (++$idx -lt $cmdline.words.Count) {
					$info.git_dir = __git_dequote_token $cmdline.words[$idx]
				}
				continue
			}
			{$_ -in '--bare'} {
				$info.git_dir = '.'
				continue
			}
			{$_ -in '--help'} {
				$idx = $cmdline.words.Count
				$info.command = 'help'
				continue
			}
			{$_ -in '-c','--work-tree','--namespace'} {
				$idx++
				continue
			}
			{$_ -in '-C'} {
				if (++$idx -lt $cmdline.words.Count) {
					$info.git_C_args = @(
						$_
						__git_dequote_token $cmdline.words[$idx]
					)
				}
				continue
			}
			{$_ -in '--'} {
				if ($_ -ne $info.curr) {
					$info.has_doubledash = $true
					$info.argument_count = 0
				}
				if ($info.command) {
					$info.parameter_count++
					if ($_ -eq $info.prev) {
						$info.parameter_curr = $info.parameter_count
					}
				}
				$_
				continue
			}
			'^-' {
				if ($info.command) {
					$info.parameter_count++
					if ($_ -eq $info.prev) {
						$info.parameter_curr = $info.parameter_count
					}
				}
				$_
				continue
			}
			default {
				if (! $info.command) {
					$info.command = $_
					$info.argument_count = 0
					$info.parameter_count = 0
					$info.parameter_curr = 0
				} else {
					$info.argument_count++
					$info.parameter_count++
					if ($_ -eq $info.prev) {
						$info.parameter_curr = $info.parameter_count
					}
				}
				$_
			}
		}
	}

	if (! $info.command -or $info.command -eq $info.curr) {
		switch ($info.prev) {
			# these need a path argument, let's fall back to
			# pwsh filename completion
			{$_ -in '--git-dir','-C','--work-tree'} {
				return
			}
			# we don't support completing these options' arguments
			{$_ -in '-c','--namespace'} {
				return
			}
		}
		switch -wildcard ($info.curr) {
			'--*' {
				return __gitcomp @{suggest = $opts.OPTIONS}
			}
		}
		return __gitcomp -text @{suggest = __git_porcelain_commands}
	}

	return _git_cmd $info.command
}
