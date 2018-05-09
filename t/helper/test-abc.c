#include "test-tool.h"
#include "cache.h"
#include "commit.h"
#include "tag.h"
#include "tree.h"
#include "revision.h"
#include "alloc.h"
#include "list-objects.h"

static void show_commit(struct commit *commit, void *data)
{
	parse_commit_gently(commit, 0);
}
static void show_object(struct object *obj, const char *name, void *cb_data)
{
	if (obj->type == OBJ_TREE)
		parse_tree_gently((struct tree *)obj, 0);
	else if (obj->type == OBJ_TAG)
		parse_tag((struct tag *)obj);
}

int cmd__abc(int argc, const char **argv)
{
	struct rev_info revs = {0};
	const char *av[] = {"", "--all", "--objects", "--not", "HEAD~100", NULL };

	setup_git_directory();
	init_revisions(&revs, "");
	setup_revisions(5, av, &revs, NULL);
	if (prepare_revision_walk(&revs))
		die("revision walk setup failed");
	traverse_commit_list(&revs, show_commit, show_object, NULL);

	clear_revisions(&revs);

	repo_clear(the_repository);

	return 0;
}
