#!/bin/sh
#
# git-submodule.sh: add, init, update or list git submodules
#
# Copyright (c) 2007 Lars Hjemli

dashless=$(basename "$0" | sed -e 's/-/ /')
USAGE="[--quiet] add [-b <branch>] [-f|--force] [--name <name>] [--reference <repository>] [--] <repository> [<path>]
   or: $dashless [--quiet] status [--cached] [--recursive] [--] [<path>...]
   or: $dashless [--quiet] init [--] [<path>...]
   or: $dashless [--quiet] deinit [-f|--force] (--all| [--] <path>...)
   or: $dashless [--quiet] update [--init] [--remote] [-N|--no-fetch] [-f|--force] [--checkout|--merge|--rebase] [--[no-]recommend-shallow] [--reference <repository>] [--recursive] [--] [<path>...]
   or: $dashless [--quiet] summary [--cached|--files] [--summary-limit <n>] [commit] [--] [<path>...]
   or: $dashless [--quiet] foreach [--recursive] <command>
   or: $dashless [--quiet] sync [--recursive] [--] [<path>...]
   or: $dashless [--quiet] absorbgitdirs [--] [<path>...]"
OPTIONS_SPEC=
SUBDIRECTORY_OK=Yes
. git-sh-setup
. git-parse-remote
require_work_tree
wt_prefix=$(git rev-parse --show-prefix)
cd_to_toplevel

# Tell the rest of git that any URLs we get don't come
# directly from the user, so it can apply policy as appropriate.
GIT_PROTOCOL_FROM_USER=0
export GIT_PROTOCOL_FROM_USER

command=
branch=
force=
reference=
cached=
recursive=
init=
files=
remote=
nofetch=
update=
prefix=
custom_name=
depth=
progress=

die_if_unmatched ()
{
	if test "$1" = "#unmatched"
	then
		exit ${2:-1}
	fi
}

isnumber()
{
	n=$(($1 + 0)) 2>/dev/null && test "$n" = "$1"
}

# Sanitize the local git environment for use within a submodule. We
# can't simply use clear_local_git_env since we want to preserve some
# of the settings from GIT_CONFIG_PARAMETERS.
sanitize_submodule_env()
{
	save_config=$GIT_CONFIG_PARAMETERS
	clear_local_git_env
	GIT_CONFIG_PARAMETERS=$save_config
	export GIT_CONFIG_PARAMETERS
}

#
# Add a new submodule to the working tree, .gitmodules and the index
#
# $@ = repo path
#
# optional branch is stored in global branch variable
#
cmd_add()
{
	# parse $args after "submodule ... add".
	reference_path=
	while test $# -ne 0
	do
		case "$1" in
		-b | --branch)
			case "$2" in '') usage ;; esac
			branch=$2
			shift
			;;
		-f | --force)
			force=$1
			;;
		-q|--quiet)
			GIT_QUIET=1
			;;
		--reference)
			case "$2" in '') usage ;; esac
			reference_path=$2
			shift
			;;
		--reference=*)
			reference_path="${1#--reference=}"
			;;
		--name)
			case "$2" in '') usage ;; esac
			custom_name=$2
			shift
			;;
		--depth)
			case "$2" in '') usage ;; esac
			depth="--depth=$2"
			shift
			;;
		--depth=*)
			depth=$1
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	git ${wt_prefix:+-C "$wt_prefix"} ${prefix:+--super-prefix "$prefix"} submodule--helper add ${force:+--force} ${GIT_QUIET:+--quiet} ${branch:+--branch "$branch"} ${reference_path:+--reference "$reference_path"} ${custom_name:+--name "$custom_name"} ${depth:+"$depth"} "$@"
}

#
# Execute an arbitrary command sequence in each checked out
# submodule
#
# $@ = command to execute
#
cmd_foreach()
{
	# parse $args after "submodule ... foreach".
	while test $# -ne 0
	do
		case "$1" in
		-q|--quiet)
			GIT_QUIET=1
			;;
		--recursive)
			recursive=1
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	git ${wt_prefix:+-C "$wt_prefix"} ${prefix:+--super-prefix "$prefix"} submodule--helper foreach ${GIT_QUIET:+--quiet} ${recursive:+--recursive} "$@"
}

#
# Register submodules in .git/config
#
# $@ = requested paths (default to all)
#
cmd_init()
{
	# parse $args after "submodule ... init".
	while test $# -ne 0
	do
		case "$1" in
		-q|--quiet)
			GIT_QUIET=1
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	git ${wt_prefix:+-C "$wt_prefix"} ${prefix:+--super-prefix "$prefix"} submodule--helper init ${GIT_QUIET:+--quiet}  "$@"
}

#
# Unregister submodules from .git/config and remove their work tree
#
cmd_deinit()
{
	# parse $args after "submodule ... deinit".
	deinit_all=
	while test $# -ne 0
	do
		case "$1" in
		-f|--force)
			force=$1
			;;
		-q|--quiet)
			GIT_QUIET=1
			;;
		--all)
			deinit_all=t
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	git ${wt_prefix:+-C "$wt_prefix"} submodule--helper deinit ${GIT_QUIET:+--quiet} ${prefix:+--prefix "$prefix"} ${force:+--force} ${deinit_all:+--all} "$@"
}

#
# Update each submodule path to correct revision, using clone and checkout as needed
#
# $@ = requested paths (default to all)
#
cmd_update()
{
	# parse $args after "submodule ... update".
	while test $# -ne 0
	do
		case "$1" in
		-q|--quiet)
			GIT_QUIET=1
			;;
		--progress)
			progress="--progress"
			;;
		-i|--init)
			init=1
			;;
		--remote)
			remote=1
			;;
		-N|--no-fetch)
			nofetch=1
			;;
		-f|--force)
			force=$1
			;;
		-r|--rebase)
			update="rebase"
			;;
		--reference)
			case "$2" in '') usage ;; esac
			reference="--reference=$2"
			shift
			;;
		--reference=*)
			reference="$1"
			;;
		-m|--merge)
			update="merge"
			;;
		--recursive)
			recursive=1
			;;
		--checkout)
			update="checkout"
			;;
		--recommend-shallow)
			recommend_shallow="--recommend-shallow"
			;;
		--no-recommend-shallow)
			recommend_shallow="--no-recommend-shallow"
			;;
		--depth)
			case "$2" in '') usage ;; esac
			depth="--depth=$2"
			shift
			;;
		--depth=*)
			depth=$1
			;;
		-j|--jobs)
			case "$2" in '') usage ;; esac
			jobs="--jobs=$2"
			shift
			;;
		--jobs=*)
			jobs=$1
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	if test -n "$init"
	then
		cmd_init "--" "$@" || return
	fi

	{
	git submodule--helper update-clone ${GIT_QUIET:+--quiet} \
		${progress:+"$progress"} \
		${wt_prefix:+--prefix "$wt_prefix"} \
		${prefix:+--recursive-prefix "$prefix"} \
		${update:+--update "$update"} \
		${reference:+"$reference"} \
		${depth:+--depth "$depth"} \
		${recommend_shallow:+"$recommend_shallow"} \
		${jobs:+$jobs} \
		"$@" || echo "#unmatched" $?
	} | {
	err=
	while read -r mode sha1 stage just_cloned sm_path
	do
		die_if_unmatched "$mode" "$sha1"

		name=$(git submodule--helper name "$sm_path") || exit
		if ! test -z "$update"
		then
			update_module=$update
		else
			update_module=$(git config submodule."$name".update)
			if test -z "$update_module"
			then
				update_module="checkout"
			fi
		fi

		displaypath=$(git submodule--helper relative-path "$prefix$sm_path" "$wt_prefix")

		if test $just_cloned -eq 1
		then
			subsha1=
			case "$update_module" in
			merge | rebase | none)
				update_module=checkout ;;
			esac
		else
			subsha1=$(sanitize_submodule_env; cd "$sm_path" &&
				git rev-parse --verify HEAD) ||
			die "$(eval_gettext "Unable to find current revision in submodule path '\$displaypath'")"
		fi

		if test -n "$remote"
		then
			branch=$(git submodule--helper remote-branch "$sm_path")
			if test -z "$nofetch"
			then
				# Fetch remote before determining tracking $sha1
				git submodule--helper fetch-in-submodule "$sm_path" $depth ||
				die "$(eval_gettext "Unable to fetch in submodule path '\$sm_path'")"
			fi
			remote_name=$(sanitize_submodule_env; cd "$sm_path" && get_default_remote)
			sha1=$(sanitize_submodule_env; cd "$sm_path" &&
				git rev-parse --verify "${remote_name}/${branch}") ||
			die "$(eval_gettext "Unable to find current \${remote_name}/\${branch} revision in submodule path '\$sm_path'")"
		fi

		if test "$subsha1" != "$sha1" || test -n "$force"
		then
			subforce=$force
			# If we don't already have a -f flag and the submodule has never been checked out
			if test -z "$subsha1" && test -z "$force"
			then
				subforce="-f"
			fi

			if test -z "$nofetch"
			then
				# Run fetch only if $sha1 isn't present or it
				# is not reachable from a ref.
				git submodule--helper is-tip-reachable "$sm_path" "$sha1" ||
				git submodule--helper fetch-in-submodule "$sm_path" $depth ||
				die "$(eval_gettext "Unable to fetch in submodule path '\$displaypath'")"

				# Now we tried the usual fetch, but $sha1 may
				# not be reachable from any of the refs
				git submodule--helper is-tip-reachable "$sm_path" "$sha1" ||
				git submodule--helper fetch-in-submodule "$sm_path" $depth "$sha1" ||
				die "$(eval_gettext "Fetched in submodule path '\$displaypath', but it did not contain \$sha1. Direct fetching of that commit failed.")"
			fi

			must_die_on_failure=
			case "$update_module" in
			checkout)
				command="git checkout $subforce -q"
				die_msg="$(eval_gettext "Unable to checkout '\$sha1' in submodule path '\$displaypath'")"
				say_msg="$(eval_gettext "Submodule path '\$displaypath': checked out '\$sha1'")"
				;;
			rebase)
				command="git rebase"
				die_msg="$(eval_gettext "Unable to rebase '\$sha1' in submodule path '\$displaypath'")"
				say_msg="$(eval_gettext "Submodule path '\$displaypath': rebased into '\$sha1'")"
				must_die_on_failure=yes
				;;
			merge)
				command="git merge"
				die_msg="$(eval_gettext "Unable to merge '\$sha1' in submodule path '\$displaypath'")"
				say_msg="$(eval_gettext "Submodule path '\$displaypath': merged in '\$sha1'")"
				must_die_on_failure=yes
				;;
			!*)
				command="${update_module#!}"
				die_msg="$(eval_gettext "Execution of '\$command \$sha1' failed in submodule path '\$displaypath'")"
				say_msg="$(eval_gettext "Submodule path '\$displaypath': '\$command \$sha1'")"
				must_die_on_failure=yes
				;;
			*)
				die "$(eval_gettext "Invalid update mode '$update_module' for submodule '$name'")"
			esac

			if (sanitize_submodule_env; cd "$sm_path" && $command "$sha1")
			then
				say "$say_msg"
			elif test -n "$must_die_on_failure"
			then
				die_with_status 2 "$die_msg"
			else
				err="${err};$die_msg"
				continue
			fi
		fi

		if test -n "$recursive"
		then
			(
				prefix=$(git submodule--helper relative-path "$prefix$sm_path/" "$wt_prefix")
				wt_prefix=
				sanitize_submodule_env
				cd "$sm_path" &&
				eval cmd_update
			)
			res=$?
			if test $res -gt 0
			then
				die_msg="$(eval_gettext "Failed to recurse into submodule path '\$displaypath'")"
				if test $res -ne 2
				then
					err="${err};$die_msg"
					continue
				else
					die_with_status $res "$die_msg"
				fi
			fi
		fi
	done

	if test -n "$err"
	then
		OIFS=$IFS
		IFS=';'
		for e in $err
		do
			if test -n "$e"
			then
				echo >&2 "$e"
			fi
		done
		IFS=$OIFS
		exit 1
	fi
	}
}

#
# Show commit summary for submodules in index or working tree
#
# If '--cached' is given, show summary between index and given commit,
# or between working tree and given commit
#
# $@ = [commit (default 'HEAD'),] requested paths (default all)
#
cmd_summary() {
	summary_limit=-1
	for_status=
	diff_cmd=diff-index

	# parse $args after "submodule ... summary".
	while test $# -ne 0
	do
		case "$1" in
		--cached)
			cached="$1"
			;;
		--files)
			files="$1"
			;;
		--for-status)
			for_status="$1"
			;;
		-n|--summary-limit)
			summary_limit="$2"
			isnumber "$summary_limit" || usage
			shift
			;;
		--summary-limit=*)
			summary_limit="${1#--summary-limit=}"
			isnumber "$summary_limit" || usage
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	git ${wt_prefix:+-C "$wt_prefix"} submodule--helper summary ${GIT_QUIET:+--quiet} ${prefix:+--prefix "$prefix"} ${for_status:+--for-status} ${files:+--files} ${cached:+--cached} ${summary_limit:+-n $summary_limit} "$@"
}
#
# List all submodules, prefixed with:
#  - submodule not initialized
#  + different revision checked out
#
# If --cached was specified the revision in the index will be printed
# instead of the currently checked out revision.
#
# $@ = requested paths (default to all)
#
cmd_status()
{
	# parse $args after "submodule ... status".
	while test $# -ne 0
	do
		case "$1" in
		-q|--quiet)
			GIT_QUIET=1
			;;
		--cached)
			cached=1
			;;
		--recursive)
			recursive=1
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
		shift
	done

	git ${wt_prefix:+-C "$wt_prefix"} ${prefix:+--super-prefix "$prefix"} submodule--helper status ${GIT_QUIET:+--quiet} ${cached:+--cached} ${recursive:+--recursive} "$@"
}
#
# Sync remote urls for submodules
# This makes the value for remote.$remote.url match the value
# specified in .gitmodules.
#
cmd_sync()
{
	while test $# -ne 0
	do
		case "$1" in
		-q|--quiet)
			GIT_QUIET=1
			shift
			;;
		--recursive)
			recursive=1
			shift
			;;
		--)
			shift
			break
			;;
		-*)
			usage
			;;
		*)
			break
			;;
		esac
	done

	git ${wt_prefix:+-C "$wt_prefix"} ${prefix:+--super-prefix "$prefix"} submodule--helper sync ${GIT_QUIET:+--quiet} ${recursive:+--recursive} "$@"
}

cmd_absorbgitdirs()
{
	git submodule--helper absorb-git-dirs --prefix "$wt_prefix" "$@"
}

# This loop parses the command line arguments to find the
# subcommand name to dispatch.  Parsing of the subcommand specific
# options are primarily done by the subcommand implementations.
# Subcommand specific options such as --branch and --cached are
# parsed here as well, for backward compatibility.

while test $# != 0 && test -z "$command"
do
	case "$1" in
	add | foreach | init | deinit | update | status | summary | sync | absorbgitdirs)
		command=$1
		;;
	-q|--quiet)
		GIT_QUIET=1
		;;
	-b|--branch)
		case "$2" in
		'')
			usage
			;;
		esac
		branch="$2"; shift
		;;
	--cached)
		cached="$1"
		;;
	--)
		break
		;;
	-*)
		usage
		;;
	*)
		break
		;;
	esac
	shift
done

# No command word defaults to "status"
if test -z "$command"
then
    if test $# = 0
    then
	command=status
    else
	usage
    fi
fi

# "-b branch" is accepted only by "add"
if test -n "$branch" && test "$command" != add
then
	usage
fi

# "--cached" is accepted only by "status" and "summary"
if test -n "$cached" && test "$command" != status && test "$command" != summary
then
	usage
fi

"cmd_$command" "$@"
