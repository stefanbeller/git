#!/bin/sh

test_description='stash apply can handle submodules'

. ./test-lib.sh
. "$TEST_DIRECTORY"/lib-submodule-update.sh


test_expect_success 'test reported regression' '
	mkdir test &&
	(
		cd test &&
		git init &&
		echo 1 >file &&
		git add file &&
		git commit file -m "message" &&
		git submodule add ./ mysubmod &&
		git commit -m "Add submodule" &&
		echo 2 >mysubmod/file &&
		git checkout -b mybranch &&
		git rebase -i --autosquash master
	)
'

git_stash () {
	git status -su >expect &&
	ls -1pR * >>expect &&
	git read-tree -u -m "$1" &&
	git stash &&
	git status -su >actual &&
	ls -1pR * >>actual &&
	test_cmp expect actual &&
	git stash apply
}

KNOWN_FAILURE_STASH_DOES_IGNORE_SUBMODULE_CHANGES=1
KNOWN_FAILURE_CHERRY_PICK_SEES_EMPTY_COMMIT=1
KNOWN_FAILURE_NOFF_MERGE_DOESNT_CREATE_EMPTY_SUBMODULE_DIR=1
test_submodule_switch "git_stash"

test_done
