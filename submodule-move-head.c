#include "cache.h"
#include "submodule-move-head.h"
#include "repository.h"
#include "submodule.h"
#include "refs.h"
#include "unpack-trees.h"
#include "run-command.h"

void create_symref_in_submodule(const char *path, const char *symref, const char *target, const char *logmsg)
{
	struct child_process cp = CHILD_PROCESS_INIT;

	/* NEEDSWORK: What about sub-submodules? */
	prepare_submodule_repo_env(&cp.env_array);
	cp.git_cmd = 1;
	cp.dir = path;
	argv_array_pushl(&cp.args, "symbolic-ref", "-m", logmsg, symref, target, NULL);

	if (run_command(&cp))
		die("process for submodule '%s' failed", path);
}

static void create_ref_in_submodule(const char *path, const char *ref, const char *value)
{
	struct child_process cp = CHILD_PROCESS_INIT;

	/* NEEDSWORK: set a reasonable reflog message. */
	prepare_submodule_repo_env(&cp.env_array);
	cp.git_cmd = 1;
	cp.dir = path;
	argv_array_pushl(&cp.args, "update-ref", ref, value, sha1_to_hex(null_sha1), NULL);

	if (run_command(&cp))
		die("process for submodule '%s' failed", path);
}

static int ref_exists_in_submodule(const char *submodule_path, const char *refname)
{
	struct ref_store *refs = get_submodule_ref_store(submodule_path);
	if (!refs)
		return 0;
	return refs_resolve_ref_unsafe(refs, refname, RESOLVE_REF_READING, NULL, NULL) != NULL;
}

int unpack_trees_move_head(const struct unpack_trees_options *opt, const char *path, const char *old, const char *new, unsigned flags)
{
	struct submodule_move_head_options *o = opt->unpack_data;
	const char *new_ref = o->new_ref;
	const char *target_ref = o->target_ref;
	const char *old_commit = old;
	const char *new_commit = new;

	/*
	 * NEEDSWORK:
	 * - set log message
	 * - what about sub-submodules?
	 */

	if (!is_submodule_active(the_repository, path))
		return 0;

	if (old) {
		if (o->force)
			old_commit = "HEAD";
		else if (o->old_ref && ref_exists_in_submodule(path, o->old_ref))
			old_commit = o->old_ref;
	}
	if (new_ref && new && ref_exists_in_submodule(path, new_ref))
		new_commit = new_ref;

	if (target_ref)
		flags |= SUBMODULE_MOVE_HEAD_SKIP_REF_UPDATE;
	if (submodule_move_head(path, old_commit, new_commit, flags) < 0)
		return -1;
	if (new && target_ref && !(flags & SUBMODULE_MOVE_HEAD_DRY_RUN)) {
		if (!ref_exists_in_submodule(path, target_ref))
			create_ref_in_submodule(path, target_ref, new);
		create_symref_in_submodule(path, "HEAD", target_ref, "msg");
	}
	return 0;
}
