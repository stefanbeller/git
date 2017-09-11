#include "cache.h"
#include "replace-object.h"
#include "sha1-lookup.h"
#include "refs.h"
#include "repository.h"
#include "commit.h"

static const unsigned char *replace_sha1_access(size_t index, void *table)
{
	struct replace_object **replace = table;
	return replace[index]->original;
}

static int replace_object_pos(struct repository *r, const unsigned char *sha1)
{
	return sha1_pos(sha1, r->objects.replacements.items,
			r->objects.replacements.nr,
			replace_sha1_access);
}

static int register_replace_object(struct repository *r,
				   struct replace_object *replace,
				   int ignore_dups)
{
	int pos = replace_object_pos(r, replace->original);

	if (0 <= pos) {
		if (ignore_dups)
			free(replace);
		else {
			free(r->objects.replacements.items[pos]);
			r->objects.replacements.items[pos] = replace;
		}
		return 1;
	}
	pos = -pos - 1;
	ALLOC_GROW(r->objects.replacements.items,
		   r->objects.replacements.nr + 1,
		   r->objects.replacements.alloc);
	r->objects.replacements.nr++;
	if (pos < r->objects.replacements.nr)
		memmove(r->objects.replacements.items + pos + 1,
			r->objects.replacements.items + pos,
			(r->objects.replacements.nr - pos - 1) *
			sizeof(*r->objects.replacements.items));
	r->objects.replacements.items[pos] = replace;
	return 0;
}

static int register_replace_ref(const char *refname,
				const struct object_id *oid,
				int flag, void *cb_data)
{
	struct repository *r = cb_data;

	/* Get sha1 from refname */
	const char *slash = strrchr(refname, '/');
	const char *hash = slash ? slash + 1 : refname;
	struct replace_object *repl_obj = xmalloc(sizeof(*repl_obj));

	if (strlen(hash) != 40 || get_sha1_hex(hash, repl_obj->original)) {
		free(repl_obj);
		warning("bad replace ref name: %s", refname);
		return 0;
	}

	/* Copy sha1 from the read ref */
	hashcpy(repl_obj->replacement, oid->hash);

	/* Register new object */
	if (register_replace_object(r, repl_obj, 1))
		die("duplicate replace ref: %s", refname);

	return 0;
}

static void prepare_replace_object(struct repository *r)
{
	if (r->objects.replacements.prepared)
		return;

	for_each_replace_ref(r, register_replace_ref, r);
	r->objects.replacements.prepared = 1;
}

/* We allow "recursive" replacement. Only within reason, though */
#define MAXREPLACEDEPTH 5

/*
 * If a replacement for object sha1 has been set up, return the
 * replacement object's name (replaced recursively, if necessary).
 * The return value is either sha1 or a pointer to a
 * permanently-allocated value.  This function always respects replace
 * references, regardless of the value of check_replace_refs.
 */
const unsigned char *do_lookup_replace_object(struct repository *r,
					      const unsigned char *sha1)
{
	int pos, depth = MAXREPLACEDEPTH;
	const unsigned char *cur = sha1;

	prepare_replace_object(r);

	/* Try to recursively replace the object */
	do {
		if (--depth < 0)
			die("replace depth too high for object %s",
			    sha1_to_hex(sha1));

		pos = replace_object_pos(r, cur);
		if (0 <= pos)
			cur = r->objects.replacements.items[pos]->replacement;
	} while (0 <= pos);

	return cur;
}
