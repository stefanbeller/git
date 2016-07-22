#!/bin/sh

test_description='gc in submodules keep superprojects pointers in mind'

. ./test-lib.sh

test_expect_success 'setup' '
	test_commit initial &&
	git clone . sub &&
	git clone . super &&
	git -C super submodule add ../sub &&
	git -C super commit -m "add submodule"
'


test_expect_failure 'test gc for commits' '
	test_when_finished "rm -rf super_under_test" &&
	git clone --recursive super super_under_test &&
	(
		cd super_under_test &&
		>sub/newfile &&
		git -C sub add newfile &&
		git -C sub commit -a -m "new file" &&
		git add sub &&
		git commit -a -m "submodule added a file"
	) &&
	(
		cd sub &&
		test_commit upstream_produces_some_history
	) &&
	(
		cd super_under_test &&
		git fetch --recurse-submodules &&
		git -C sub rebase origin/master &&
		git -C sub gc --prune=all

		git submodule summary >actual &&
		test_i18ngrep "Warn: sub doesn${q}t contain commit" actual
	)
'

test_done
