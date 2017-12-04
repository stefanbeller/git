#ifndef SUBMODULE_MOVE_HEAD_H
#define SUBMODULE_MOVE_HEAD_H

struct unpack_trees_options;

/* NEEDSWORK: document */
struct submodule_move_head_options {
	int force;
	const char *old_ref;
	const char *new_ref;
	const char *target_ref;
};

/*
 * For use as unpack_trees_options.move_head. Parameters should be a
 * struct submodule_move_head_options * in unpack_trees_options.unpack_data.
 */
extern int unpack_trees_move_head(const struct unpack_trees_options *opt, const char *path, const char *old, const char *new, unsigned flags);

extern void create_symref_in_submodule(const char *path, const char *symref, const char *target, const char *logmsg);

#endif /* SUBMODULE_MOVE_HEAD_H */
