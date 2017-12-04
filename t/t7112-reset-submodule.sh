#!/bin/sh

test_description='reset can handle submodules'

. ./test-lib.sh
. "$TEST_DIRECTORY"/lib-submodule-update.sh

KNOWN_FAILURE_SUBMODULE_RECURSIVE_NESTED=1
KNOWN_FAILURE_DIRECTORY_SUBMODULE_CONFLICTS=1
KNOWN_FAILURE_SUBMODULE_OVERWRITE_IGNORED_UNTRACKED=1
KNOWN_DIFFERENCE_SUBMODULE_REFS_NOT_UPDATED="reset"

KNOWN_FAILURE_SUBMODULE_REFS_NOT_UPDATED=1
test_submodule_switch_recursing_with_args "reset --keep"

unset KNOWN_FAILURE_SUBMODULE_REFS_NOT_UPDATED
test_submodule_forced_switch_recursing_with_args "reset --hard"

KNOWN_FAILURE_SUBMODULE_REFS_NOT_UPDATED=1
test_submodule_switch "git reset --keep"

unset KNOWN_FAILURE_SUBMODULE_REFS_NOT_UPDATED
test_submodule_switch "git reset --merge"

test_submodule_forced_switch "git reset --hard"

test_done
