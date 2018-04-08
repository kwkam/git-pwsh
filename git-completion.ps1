# pwsh completion support for core Git.
# vi: ts=2 sw=2
#
# A clone of git-completion.sh from:
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
#        ~/Documents/PowerShell/git-completion.ps1
#    2) Add the following line to your profile.ps1:
#        . $PSScriptRoot/git-completion.ps1
#    3) Consider changing your prompt to also show the current branch,
#       see git-prompt.ps1 for details.
#
# If you use complex aliases of form "!pwsh -c 'function f { ... }; f'",
# the argument @args or $args[a[..b]] will be searched to detect the desired
# completion style.  For example,
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
		FORMAT_PATCH = @(
			'--stdout','--attach','--no-attach','--thread','--thread=','--no-thread'
			'--numbered','--start-number','--numbered-files','--keep-subject','--signoff'
			'--signature','--no-signature','--in-reply-to=','--cc=','--full-index','--binary'
			'--not','--all','--cover-letter','--no-prefix','--src-prefix=','--dst-prefix='
			'--inline','--suffix=','--ignore-if-in-upstream','--subject-prefix='
			'--output-directory','--reroll-count','--to=','--quiet','--notes'
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
	CONFIGLIST = @(
		'add.ignoreErrors'
		'advice.amWorkDir'
		'advice.commitBeforeMerge'
		'advice.detachedHead'
		'advice.implicitIdentity'
		'advice.pushAlreadyExists'
		'advice.pushFetchFirst'
		'advice.pushNeedsForce'
		'advice.pushNonFFCurrent'
		'advice.pushNonFFMatching'
		'advice.pushUpdateRejected'
		'advice.resolveConflict'
		'advice.rmHints'
		'advice.statusHints'
		'advice.statusUoption'
		'advice.ignoredHook'
		'alias.'
		'am.keepcr'
		'am.threeWay'
		'apply.ignorewhitespace'
		'apply.whitespace'
		'branch.autosetupmerge'
		'branch.autosetuprebase'
		'browser.'
		'clean.requireForce'
		'color.branch'
		'color.branch.current'
		'color.branch.local'
		'color.branch.plain'
		'color.branch.remote'
		'color.decorate.HEAD'
		'color.decorate.branch'
		'color.decorate.remoteBranch'
		'color.decorate.stash'
		'color.decorate.tag'
		'color.diff'
		'color.diff.commit'
		'color.diff.frag'
		'color.diff.func'
		'color.diff.meta'
		'color.diff.new'
		'color.diff.old'
		'color.diff.plain'
		'color.diff.whitespace'
		'color.grep'
		'color.grep.context'
		'color.grep.filename'
		'color.grep.function'
		'color.grep.linenumber'
		'color.grep.match'
		'color.grep.selected'
		'color.grep.separator'
		'color.interactive'
		'color.interactive.error'
		'color.interactive.header'
		'color.interactive.help'
		'color.interactive.prompt'
		'color.pager'
		'color.showbranch'
		'color.status'
		'color.status.added'
		'color.status.changed'
		'color.status.header'
		'color.status.localBranch'
		'color.status.nobranch'
		'color.status.remoteBranch'
		'color.status.unmerged'
		'color.status.untracked'
		'color.status.updated'
		'color.ui'
		'commit.cleanup'
		'commit.gpgSign'
		'commit.status'
		'commit.template'
		'commit.verbose'
		'core.abbrev'
		'core.askpass'
		'core.attributesfile'
		'core.autocrlf'
		'core.bare'
		'core.bigFileThreshold'
		'core.checkStat'
		'core.commentChar'
		'core.compression'
		'core.createObject'
		'core.deltaBaseCacheLimit'
		'core.editor'
		'core.eol'
		'core.excludesfile'
		'core.fileMode'
		'core.fsyncobjectfiles'
		'core.gitProxy'
		'core.hideDotFiles'
		'core.hooksPath'
		'core.ignoreStat'
		'core.ignorecase'
		'core.logAllRefUpdates'
		'core.loosecompression'
		'core.notesRef'
		'core.packedGitLimit'
		'core.packedGitWindowSize'
		'core.packedRefsTimeout'
		'core.pager'
		'core.precomposeUnicode'
		'core.preferSymlinkRefs'
		'core.preloadindex'
		'core.protectHFS'
		'core.protectNTFS'
		'core.quotepath'
		'core.repositoryFormatVersion'
		'core.safecrlf'
		'core.sharedRepository'
		'core.sparseCheckout'
		'core.splitIndex'
		'core.sshCommand'
		'core.symlinks'
		'core.trustctime'
		'core.untrackedCache'
		'core.warnAmbiguousRefs'
		'core.whitespace'
		'core.worktree'
		'credential.helper'
		'credential.useHttpPath'
		'credential.username'
		'credentialCache.ignoreSIGHUP'
		'diff.autorefreshindex'
		'diff.external'
		'diff.ignoreSubmodules'
		'diff.mnemonicprefix'
		'diff.noprefix'
		'diff.renameLimit'
		'diff.renames'
		'diff.statGraphWidth'
		'diff.submodule'
		'diff.suppressBlankEmpty'
		'diff.tool'
		'diff.wordRegex'
		'diff.algorithm'
		'difftool.'
		'difftool.prompt'
		'fetch.recurseSubmodules'
		'fetch.unpackLimit'
		'format.attach'
		'format.cc'
		'format.coverLetter'
		'format.from'
		'format.headers'
		'format.numbered'
		'format.pretty'
		'format.signature'
		'format.signoff'
		'format.subjectprefix'
		'format.suffix'
		'format.thread'
		'format.to'
		'gc.'
		'gc.aggressiveDepth'
		'gc.aggressiveWindow'
		'gc.auto'
		'gc.autoDetach'
		'gc.autopacklimit'
		'gc.logExpiry'
		'gc.packrefs'
		'gc.pruneexpire'
		'gc.reflogexpire'
		'gc.reflogexpireunreachable'
		'gc.rerereresolved'
		'gc.rerereunresolved'
		'gc.worktreePruneExpire'
		'gitcvs.allbinary'
		'gitcvs.commitmsgannotation'
		'gitcvs.dbTableNamePrefix'
		'gitcvs.dbdriver'
		'gitcvs.dbname'
		'gitcvs.dbpass'
		'gitcvs.dbuser'
		'gitcvs.enabled'
		'gitcvs.logfile'
		'gitcvs.usecrlfattr'
		'guitool.'
		'gui.blamehistoryctx'
		'gui.commitmsgwidth'
		'gui.copyblamethreshold'
		'gui.diffcontext'
		'gui.encoding'
		'gui.fastcopyblame'
		'gui.matchtrackingbranch'
		'gui.newbranchtemplate'
		'gui.pruneduringfetch'
		'gui.spellingdictionary'
		'gui.trustmtime'
		'help.autocorrect'
		'help.browser'
		'help.format'
		'http.lowSpeedLimit'
		'http.lowSpeedTime'
		'http.maxRequests'
		'http.minSessions'
		'http.noEPSV'
		'http.postBuffer'
		'http.proxy'
		'http.sslCipherList'
		'http.sslVersion'
		'http.sslCAInfo'
		'http.sslCAPath'
		'http.sslCert'
		'http.sslCertPasswordProtected'
		'http.sslKey'
		'http.sslVerify'
		'http.useragent'
		'i18n.commitEncoding'
		'i18n.logOutputEncoding'
		'imap.authMethod'
		'imap.folder'
		'imap.host'
		'imap.pass'
		'imap.port'
		'imap.preformattedHTML'
		'imap.sslverify'
		'imap.tunnel'
		'imap.user'
		'init.templatedir'
		'instaweb.browser'
		'instaweb.httpd'
		'instaweb.local'
		'instaweb.modulepath'
		'instaweb.port'
		'interactive.singlekey'
		'log.date'
		'log.decorate'
		'log.showroot'
		'mailmap.file'
		'man.'
		'man.viewer'
		'merge.'
		'merge.conflictstyle'
		'merge.log'
		'merge.renameLimit'
		'merge.renormalize'
		'merge.stat'
		'merge.tool'
		'merge.verbosity'
		'mergetool.'
		'mergetool.keepBackup'
		'mergetool.keepTemporaries'
		'mergetool.prompt'
		'notes.displayRef'
		'notes.rewrite.'
		'notes.rewrite.amend'
		'notes.rewrite.rebase'
		'notes.rewriteMode'
		'notes.rewriteRef'
		'pack.compression'
		'pack.deltaCacheLimit'
		'pack.deltaCacheSize'
		'pack.depth'
		'pack.indexVersion'
		'pack.packSizeLimit'
		'pack.threads'
		'pack.window'
		'pack.windowMemory'
		'pager.'
		'pretty.'
		'pull.octopus'
		'pull.twohead'
		'push.default'
		'push.followTags'
		'rebase.autosquash'
		'rebase.stat'
		'receive.autogc'
		'receive.denyCurrentBranch'
		'receive.denyDeleteCurrent'
		'receive.denyDeletes'
		'receive.denyNonFastForwards'
		'receive.fsckObjects'
		'receive.unpackLimit'
		'receive.updateserverinfo'
		'remote.pushdefault'
		'remotes.'
		'repack.usedeltabaseoffset'
		'rerere.autoupdate'
		'rerere.enabled'
		'sendemail.'
		'sendemail.aliasesfile'
		'sendemail.aliasfiletype'
		'sendemail.bcc'
		'sendemail.cc'
		'sendemail.cccmd'
		'sendemail.chainreplyto'
		'sendemail.confirm'
		'sendemail.envelopesender'
		'sendemail.from'
		'sendemail.identity'
		'sendemail.multiedit'
		'sendemail.signedoffbycc'
		'sendemail.smtpdomain'
		'sendemail.smtpencryption'
		'sendemail.smtppass'
		'sendemail.smtpserver'
		'sendemail.smtpserveroption'
		'sendemail.smtpserverport'
		'sendemail.smtpuser'
		'sendemail.suppresscc'
		'sendemail.suppressfrom'
		'sendemail.thread'
		'sendemail.to'
		'sendemail.tocmd'
		'sendemail.validate'
		'sendemail.smtpbatchsize'
		'sendemail.smtprelogindelay'
		'showbranch.default'
		'status.relativePaths'
		'status.showUntrackedFiles'
		'status.submodulesummary'
		'submodule.'
		'tar.umask'
		'transfer.unpackLimit'
		'url.'
		'user.email'
		'user.name'
		'user.signingkey'
		'web.browser'
		'branch.','remote.'
	)
}

function __git_complete
{
	param (
		[parameter(mandatory = $true)]
		[hashtable] $cmdline,
		[switch] $noexpand
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
				$info.repo_path = git rev-parse --git-dir 2> $null
			}
		}
		return $info.repo_path
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
			[hashtable] $opts = @{}
		)

		if ($word -like '--*=') {
			return
		}

		$pattern = "$word*"

		# set common parameters
		if (! ($opts.Contains('replaceIndex') -or $opts.Contains('replaceLength'))) {
			if ($cmdline.curr) {
				$opts.replaceIndex = $cmdline.curr.Extent.StartOffset
				$opts.replaceLength = $cmdline.curr.Extent.EndOffset - $opts.replaceIndex
			} else {
				$opts.replaceIndex = $cmdline.cursor.Offset
				$opts.replaceLength = 0
			}
		}
		if ($cmdline.curr.Text -match '^(?<q>[''"])') {
			$quote = $matches.q
		}

		$result = [Collections.Generic.List[Management.Automation.CompletionResult]]::new()
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
			$suggest.ForEach({
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
				$result.Add([Management.Automation.CompletionResult]::new($s, $s, $type, $s))
			})
		})
		return [Management.Automation.CommandCompletion]::new($result, -1, $opts.replaceIndex, $opts.replaceLength)
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

		if (! $GIT_COMPLETION.SUBOPTIONS.Contains($key)) {
			# NOTE depends on exe output
			$list = @(
				$(__git @cmd --git-completion-helper) -split ' +'
				$incl
			)
			if ($list) {
				$GIT_COMPLETION.SUBOPTIONS.$key = $list.Where({$_ -and $_ -notin $excl})
			}
		}

		return __gitcomp @{suggest = $GIT_COMPLETION.SUBOPTIONS.$key}
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
		return __gitcomp @params -opts @{
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
			[bool] $track,
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
				$hash, $i = $_ -split '\t'
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
			[string] $root
		)

		if (! $root) {
			$root = $PWD.Path
		}
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
		if (! $GIT_COMPLETION.Contains('MERGE_STRATEGIES')) {
			# NOTE depends on exe output
			$list = $(__git2 merge -s help).ForEach({
				if ($_ -match '^[^:]+: *(?<v>.+)\.$') {
					$matches.v -split ' +'
				}
			})
			if ($list) {
				$GIT_COMPLETION.MERGE_STRATEGIES = $list
			}
		}
		return $GIT_COMPLETION.MERGE_STRATEGIES
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
		$matches = __git_ls_files_helper $options $pre | Select-String '(?<d>^[^/]+/)|(?<f>^[^/]+$)' | % Matches
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

	function __git_commands
	{
		# NOTE depends on exe output
		$(git help -a).ForEach({
			if ($_ -match '^  (?<cmds>\w.*)$') {
				$matches.cmds -split ' +'
			}
		}) | Sort-Object
	}

	function __git_all_commands
	{
		if (! $GIT_COMPLETION.Contains('ALL_COMMANDS')) {
			$GIT_COMPLETION.ALL_COMMANDS = switch -wildcard (__git_commands) {
				'*--*' { # helper pattern
					continue
				}
				default {
					$_
				}
			}
		}
		return $GIT_COMPLETION.ALL_COMMANDS
	}

	function __git_porcelain_commands
	{
		if (! $GIT_COMPLETION.Contains('PORCELAIN_COMMANDS')) {
			$GIT_COMPLETION.PORCELAIN_COMMANDS = switch -wildcard (__git_all_commands) {
				'*--*' { # helper pattern
					continue
				}
				'applymbox' { # ask gittus
					continue
				}
				'applypatch' { # ask gittus
					continue
				}
				'archimport' { # import
					continue
				}
				'cat-file' { # plumbing
					continue
				}
				'check-attr' { # plumbing
					continue
				}
				'check-ignore' { # plumbing
					continue
				}
				'check-mailmap' { # plumbing
					continue
				}
				'check-ref-format' { # plumbing
					continue
				}
				'checkout-index' { # plumbing
					continue
				}
				'column' { # internal helper
					continue
				}
				'commit-tree' { # plumbing
					continue
				}
				'count-objects' { # infrequent
					continue
				}
				'credential' { # credentials
					continue
				}
				'credential-*' { # credentials helper
					continue
				}
				'cvsexportcommit' { # export
					continue
				}
				'cvsimport' { # import
					continue
				}
				'cvsserver' { # daemon
					continue
				}
				'daemon' { # daemon
					continue
				}
				'diff-files' { # plumbing
					continue
				}
				'diff-index' { # plumbing
					continue
				}
				'diff-tree' { # plumbing
					continue
				}
				'fast-import' { # import
					continue
				}
				'fast-export' { # export
					continue
				}
				'fsck-objects' { # plumbing
					continue
				}
				'fetch-pack' { # plumbing
					continue
				}
				'fmt-merge-msg' { # plumbing
					continue
				}
				'for-each-ref' { # plumbing
					continue
				}
				'hash-object' { # plumbing
					continue
				}
				'http-*' { # transport
					continue
				}
				'index-pack' { # plumbing
					continue
				}
				'init-db' { # deprecated
					continue
				}
				'local-fetch' { # plumbing
					continue
				}
				'ls-files' { # plumbing
					continue
				}
				'ls-remote' { # plumbing
					continue
				}
				'ls-tree' { # plumbing
					continue
				}
				'mailinfo' { # plumbing
					continue
				}
				'mailsplit' { # plumbing
					continue
				}
				'merge-*' { # plumbing
					continue
				}
				'mktree' { # plumbing
					continue
				}
				'mktag' { # plumbing
					continue
				}
				'pack-objects' { # plumbing
					continue
				}
				'pack-redundant' { # plumbing
					continue
				}
				'pack-refs' { # plumbing
					continue
				}
				'parse-remote' { # plumbing
					continue
				}
				'patch-id' { # plumbing
					continue
				}
				'prune' { # plumbing
					continue
				}
				'prune-packed' { # plumbing
					continue
				}
				'quiltimport' { # import
					continue
				}
				'read-tree' { # plumbing
					continue
				}
				'receive-pack' { # plumbing
					continue
				}
				'remote-*' { # transport
					continue
				}
				'rerere' { # plumbing
					continue
				}
				'rev-list' { # plumbing
					continue
				}
				'rev-parse' { # plumbing
					continue
				}
				'runstatus' { # plumbing
					continue
				}
				'sh-setup' { # internal
					continue
				}
				'shell' { # daemon
					continue
				}
				'show-ref' { # plumbing
					continue
				}
				'send-pack' { # plumbing
					continue
				}
				'show-index' { # plumbing
					continue
				}
				'ssh-*' { # transport
					continue
				}
				'stripspace' { # plumbing
					continue
				}
				'symbolic-ref' { # plumbing
					continue
				}
				'unpack-file' { # plumbing
					continue
				}
				'unpack-objects' { # plumbing
					continue
				}
				'update-index' { # plumbing
					continue
				}
				'update-ref' { # plumbing
					continue
				}
				'update-server-info' { # daemon
					continue
				}
				'upload-archive' { # plumbing
					continue
				}
				'upload-pack' { # plumbing
					continue
				}
				'write-tree' { # plumbing
					continue
				}
				'var' { # infrequent
					continue
				}
				'verify-pack' { # infrequent
					continue
				}
				'verify-tag' { # plumbing
					continue
				}
				default {
					$_
				}
			}
		}
		return $GIT_COMPLETION.PORCELAIN_COMMANDS
	}

	# __git_aliased_command requires 1 argument
	function __git_aliased_command
	{
		param (
			[string] $command
		)

		$aliased = __git config --get alias.$command
		if (! $aliased) {
			return
		}
		$lastcmd = GetArgumentCommandLine $aliased 'args' $info.command_argument_curr

		switch -wildcard ($lastcmd.exec) {
			{$_ -in '!git','!git.exe','git','git.exe'} { # git itself
				continue
			}
			default {
				$_
			}
		}
		$lastcmd.words
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

	function __git_config_get_set_variables {
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

	function _git_cmd
	{
		param (
			[string] $command
		)

		switch ($command) {

			'am' {
				if (Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/rebase-apply") {
					return __gitcomp @{suggest = $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.AM}
				}
				switch -regex ($info.curr) {
					'^(?<k>--whitespace=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.WHITESPACELIST}
					}
					'^--' {
						return __gitcomp_builtin $command '--no-utf8' -excl $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.AM
					}
				}
			}

			'apply' {
				switch -regex ($info.curr) {
					'^(?<k>--whitespace=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.WHITESPACELIST}
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
						return __gitcomp_append $matches.k $matches.v @{suggest = git archive --list}
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
						return __gitcomp_builtin $command '--no-color','--no-abbrev','--no-track','--no-column'
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
						return __gitcomp_builtin $command '--no-track','--no-recurse-submodules'
					}
				}
				# check if --track, --no-track, or --no-guess was specified
				# if so, disable DWIM mode
				$track_opt = @{track = $true}
				if ($GIT_COMPLETION.CHECKOUT_NO_GUESS -or
				    $(__git_find_on_cmdline '--track','--no-track','--no-guess')) {
					$track_opt.track = $false
				}
				return __gitcomp -text @{suggest = __git_refs @track_opt}
			}

			'cherry' {
				return __gitcomp -text @{suggest = __git_refs}
			}

			'cherry-pick' {
				if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/CHERRY_PICK_HEAD") {
					return __gitcomp @{suggest = $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.CHERRY_PICK}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command -excl $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.CHERRY_PICK
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
						return __gitcomp_builtin $command '--no-single-branch'
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.UNTRACKED_FILE_MODES}
					}
					'^--' {
						return __gitcomp_builtin $command '--no-edit','--verify'
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
						return __gitcomp -text @{suggest = 'false','true','preserve','interactive'}
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
						return __gitcomp -text @{suggest = $GIT_COMPLETION.LOG_DATE_FORMATS}
					}
					{$_ -in 'sendemail.aliasesfiletype'} {
						return __gitcomp -text @{suggest = 'mutt','mailrc','pine','elm','gnus'}
					}
					{$_ -in 'sendemail.confirm'} {
						return __gitcomp -text @{suggest = $GIT_COMPLETION.SEND_EMAIL_CONFIRM}
					}
					{$_ -in 'sendemail.suppresscc'} {
						return __gitcomp -text @{suggest = $GIT_COMPLETION.SEND_EMAIL_SUPPRESSCC}
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
							suggest = 'remote','pushremote','merge','mergeoptions','rebase'
						}
					}
					'^(?<k>branch\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								__git_heads -cur $matches.v
								'autosetupmerge','autosetuprebase'
							)
						}
					}
					'^(?<k>guitool\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								'argprompt','cmd','confirm','needsfile','noconsole','norescan'
								'prompt','revprompt','revunmerged','title'
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
								'receivepack','uploadpack','tagopt','pushurl'
							)
						}
					}
					'^(?<k>remote\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{
							suggest = @(
								__git_remotes
								'pushdefault'
							)
						}
					}
					'^(?<k>url\..+\.)(?<v>.*)' {
						return __gitcomp_append -text $matches.k $matches.v @{suggest = 'insteadOf','pushInsteadOf'}
					}
				}
				return __gitcomp -text @{suggest = $GIT_COMPLETION.CONFIGLIST}
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.DIFF_ALGORITHMS}
					}
					'^(?<k>--submodule=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.DIFF_SUBMODULE_FORMATS}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--cached','--staged','--pickaxe-all','--pickaxe-regex'
								'--base','--ours','--theirs','--no-index'
								$GIT_COMPLETION.SUBOPTIONS.DIFF_COMMON
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.SUBOPTIONS.MERGETOOL_COMMON}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--base','--cached','--ours','--theirs'
								'--pickaxe-all','--pickaxe-regex'
								'--relative','--staged'
								$GIT_COMPLETION.SUBOPTIONS.DIFF_COMMON
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'fetch' {
				switch -regex ($info.curr) {
					'^(?<k>--recurse-submodules=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.FETCH_RECURSE_SUBMODULES}
					}
					'^--' {
						return __gitcomp_builtin $command '--no-tags'
					}
				}
				$params = @{cmd = $command}
				switch -wildcard ($info.words) {
					'--all' {
						return
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
						return __gitcomp @{suggest = $GIT_COMPLETION.SUBOPTIONS.FORMAT_PATCH}
					}
				}
				return __git_complete_revlist
			}

			'fsck' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command '--no-reflogs'
					}
				}
			}

			'gc' {
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
				return __gitcomp -text @{
					suggest = @(
						__git_all_commands
						__git_get_config_variables 'alias'
						'attributes','cli','core-tutorial','cvs-migration'
						'diffcore','everyday','gitk','glossary','hooks','ignore','modules'
						'namespaces','repository-layout','revisions','tutorial','tutorial-2'
						'workflows'
					)
				}
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
						return __gitcomp_builtin $command '--no-empty-directory'
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
								$GIT_COMPLETION.LOG_PRETTY_FORMATS
								__git_get_config_variables 'pretty'
							)
						}
					}
					'^(?<k>--date=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.LOG_DATE_FORMATS}
					}
					'^(?<k>--decorate=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = 'full','short','no'}
					}
					'^(?<k>--diff-algorithm=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.DIFF_ALGORITHMS}
					}
					'^(?<k>--submodule=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.DIFF_SUBMODULE_FORMATS}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								$GIT_COMPLETION.SUBOPTIONS.LOG_COMMON
								$GIT_COMPLETION.SUBOPTIONS.LOG_SHORTLOG
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
								$GIT_COMPLETION.SUBOPTIONS.DIFF_COMMON
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
						return __gitcomp_builtin $command @(
							'--no-rerere-autoupdate'
							'--no-commit','--no-edit','--no-ff'
							'--no-log','--no-progress'
							'--no-squash','--no-stat'
							'--no-verify-signatures'
						)
					}
				}
				return __gitcomp -text @{suggest = __git_refs}
			}

			'mergetool' {
				switch -regex ($info.curr) {
					'^(?<k>--tool=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.SUBOPTIONS.MERGETOOL_COMMON}
					}
					'^--' {
						return __gitcomp @{suggest = '--tool=','--prompt','--no-prompt'}
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

			'name-rev' {
				return __gitcomp_builtin $command
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.FETCH_RECURSE_SUBMODULES}
					}
					'^--' {
						return __gitcomp_builtin $command @(
							'--no-autostash','--no-commit','--no-edit'
							'--no-ff','--no-log','--no-progress','--no-rebase'
							'--no-squash','--no-stat','--no-tags'
							'--no-verify-signatures'
						)
					}
				}
				$params = @{cmd = $command}
				switch -wildcard ($info.words) {
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.PUSH_RECURSE_SUBMODULES}
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

			'rebase' {
				if (Test-Path -Type Leaf -LiteralPath "$(__git_repo_path)/rebase-merge/interactive") {
					return __gitcomp @{
						suggest = @(
							$GIT_COMPLETION.SUBOPTIONS.INPROGRESS.REBASE
							'--edit-todo'
						)
					}
				}
				if ((Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/rebase-apply") -or
				    (Test-Path -PathType Container -LiteralPath "$(__git_repo_path)/rebase-merge")) {
					return __gitcomp @{suggest = $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.REBASE}
				}
				if (__git_complete_strategy) {
					return $info.result
				}
				switch -regex ($info.curr) {
					'^(?<k>--whitespace=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.WHITESPACELIST}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--onto','--merge','--strategy=','--interactive'
								'--preserve-merges','--stat','--no-stat'
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.SEND_EMAIL_CONFIRM}
					}
					'^(?<k>--suppress-cc=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.SEND_EMAIL_SUPPRESSCC}
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
						return __gitcomp @{
							suggest = @(
								'--annotate','--bcc','--cc','--cc-cmd','--chain-reply-to'
								'--compose','--confirm=','--dry-run','--envelope-sender'
								'--from','--identity'
								'--in-reply-to','--no-chain-reply-to','--no-signed-off-by-cc'
								'--no-suppress-from','--no-thread','--quiet','--reply-to'
								'--signed-off-by-cc','--smtp-pass','--smtp-server'
								'--smtp-server-port','--smtp-encryption=','--smtp-user'
								'--subject','--suppress-cc=','--suppress-from','--thread','--to'
								'--validate','--no-validate'
								$GIT_COMPLETION.SUBOPTIONS.FORMAT_PATCH
							)
						}
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
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.UNTRACKED_FILE_MODES}
					}
					'^(?<k>--column=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{
							suggest = 'always','never','auto','column','row','plain','dense','nodense'
						}
					}
					'^--' {
						return __gitcomp_builtin $command '--no-column'
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
								return __gitcomp_builtin $command, $subcommand '--no-tags'
							}
						}
						return
					}
					{$_ -in 'set-head','set-branches'} {
						switch -regex ($info.curr) {
							'^--' {
								return __gitcomp_builtin $command, $subcommand
							}
						}
						$params = @{cmd = $command}
						switch -wildcard ($info.words) {
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
								return __gitcomp_builtin $command, $subcommand
							}
						}
						return __gitcomp -text @{suggest = __git_get_config_variables 'remotes'}
					}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command, $subcommand
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
					return __gitcomp @{suggest = $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.REVERT}
				}
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command '--no-edit' -excl $GIT_COMPLETION.SUBOPTIONS.INPROGRESS.REVERT
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
								$GIT_COMPLETION.LOG_COMMON
								$GIT_COMPLETION.LOG_SHORTLOG
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
								$GIT_COMPLETION.LOG_PRETTY_FORMATS
								__git_get_config_variables 'pretty'
							)
						}
					}
					'^(?<k>--diff-algorithm=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.DIFF_ALGORITHMS}
					}
					'^(?<k>--submodule=)(?<v>.*)' {
						return __gitcomp_append $matches.k $matches.v @{suggest = $GIT_COMPLETION.DIFF_SUBMODULE_FORMATS}
					}
					'^--' {
						return __gitcomp @{
							suggest = @(
								'--pretty=','--format=','--abbrev-commit','--oneline'
								'--show-signature'
								$GIT_COMPLETION.DIFF_COMMON
							)
						}
					}
				}
				return __git_complete_revlist
			}

			'show-branch' {
				switch -regex ($info.curr) {
					'^--' {
						return __gitcomp_builtin $command '--no-color'
					}
				}
				return __git_complete_revlist
			}

			'stash' {
				$save_opts = '--all','--keep-index','--no-keep-index','--quiet','--patch','--include-untracked'
				$subcommands = 'push','save','list','show','apply','clear','drop','pop','create','branch'
				$subcommand = __git_find_on_cmdline $subcommands
				if (! $subcommand) {
					switch -regex ($info.curr) {
						'^--' {
							return __gitcomp @{suggest = $save_opts}
						}
					}
					if (__git_find_on_cmdline $save_opts) {
						return
					}
					return __gitcomp -text @{suggest = $subcommands}
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
				$subcommands = 'add','status','init','deinit','update','summary','foreach','sync'
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
				if ($noexpand) {
					# prevents infinite loop
					return
				}
				$lastcmd = __git_aliased_command $command
				if (! $lastcmd) {
					# cannot find alias command
					return
				}
				$cmdline.words = @(
					$lastcmd
					$cmdline.words[1..$cmdline.words.Count]
				)
				return __git_complete -noexpand $cmdline
			}

		}
	}

	$info.prev = ValueOfToken $cmdline.prev
	$info.curr = ValueOfToken $cmdline.curr
	$info.words = for ($idx = 0; $idx -lt $cmdline.words.Count; $idx++) {
		switch -regex (ValueOfToken $cmdline.words[$idx]) {
			'^--git-dir=(?<path>.+)' {
				$info.git_dir = $matches.path
				continue
			}
			{$_ -in '--git-dir'} {
				if (++$idx -lt $cmdline.words.Count) {
					$info.git_dir = ValueOfToken $cmdline.words[$idx]
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
						ValueOfToken $cmdline.words[$idx]
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
					$info.command_argument_count++
					if ($_ -eq $info.prev) {
						$info.command_argument_curr = $info.command_argument_count
					}
				}
				$_
				continue
			}
			'^-' {
				if ($info.command) {
					$info.command_argument_count++
					if ($_ -eq $info.prev) {
						$info.command_argument_curr = $info.command_argument_count
					}
				}
				$_
				continue
			}
			default {
				if (! $info.command) {
					$info.command = $_
					$info.argument_count = 0
					$info.command_argument_count = 0
					$info.command_argument_curr = 0
				} else {
					$info.argument_count++
					$info.command_argument_count++
					if ($_ -eq $info.prev) {
						$info.command_argument_curr = $info.command_argument_count
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
				return __gitcomp @{suggest = $GIT_COMPLETION.OPTIONS}
			}
		}
		return __gitcomp -text @{
			suggest = @(
				__git_porcelain_commands
				__git_get_config_variables 'alias'
			)
		}
	}

	return _git_cmd $info.command
}

function ValueOfToken
{
	param (
		[Management.Automation.Language.Token] $token
	)

	if ($token.Kind -eq [Management.Automation.Language.TokenKind]::StringLiteral -or
	    $token.Kind -eq [Management.Automation.Language.TokenKind]::StringExpandable) {
		return $token.Value
	}
	return $token.Text
}

# TODO improve or replace this
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
			if ($token.Kind -eq [Management.Automation.Language.TokenKind]::StringExpandable) {
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

function GetArgumentCommandLine
{
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string] $inputScript,

		[Parameter(Mandatory = $true, Position = 1)]
		[string] $name,

		[Parameter(Position = 2)]
		[int] $index = -1
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
						return GetArgumentCommandLine $(ValueOfToken $tokens[$idx]) $name $index
					}
				}
			}
		}
	}

	$tokens = for ($idx = 0; $idx -lt $tokens.Count; $idx++) {
		$token = $tokens[$idx]
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::SplattedVariable -and
		    $token.Name -eq $name) {
			$positionOfCursor = $token.Extent.StartScriptPosition
			break
		}
		if ($token.Kind -eq [Management.Automation.Language.TokenKind]::Variable -and
		    $token.Name -eq $name) {
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
						# NOTE for $var[0..$var.Count], always assume index < $var.Count
						if (($range[0].Kind -eq [Management.Automation.Language.TokenKind]::Number -and
						     $range[0].Value -le $index) -and
						    ($range[2].Kind -ne [Management.Automation.Language.TokenKind]::Number -or
						     $range[2].Value -ge $index)) {
							$positionOfCursor = $token.Extent.StartScriptPosition
							break
						}
					} elseif ($range.Count -eq 1) {
						if ($range[0].Kind -eq [Management.Automation.Language.TokenKind]::Number -and
						    $range[0].Value -eq $index) {
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

# Backup original TabExpansion2 on first run
if ($(Test-Path function:/TabExpansion2) -and ! $(Test-Path function:/NotGitTabExpansion2)) {
	Rename-Item function:/TabExpansion2 NotGitTabExpansion2
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
	$parsed = @{}
	$cmdline = GetCursorCommandLine @PSBoundParameters -parsed $parsed
	if ($cmdline.exec -in 'git','git.exe') {
		$result = __git_complete $cmdline
	}
	if (! $result) {
		$result = NotGitTabExpansion2 $parsed.ast $parsed.tokens $parsed.positionOfCursor $options
	}
	return $result
}
