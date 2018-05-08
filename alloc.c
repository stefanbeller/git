/*
 * alloc.c  - specialized allocator for internal objects
 *
 * Copyright (C) 2006 Linus Torvalds
 *
 * The standard malloc/free wastes too much space for objects, partly because
 * it maintains all the allocation infrastructure, but even more because it ends
 * up with maximal alignment because it doesn't know what the object alignment
 * for the new allocation is.
 */
#include "cache.h"
#include "object.h"
#include "blob.h"
#include "tree.h"
#include "commit.h"
#include "tag.h"
#include "alloc.h"

#define BLOCKING 1024

union any_object {
	struct object object;
	struct blob blob;
	struct tree tree;
	struct commit commit;
	struct tag tag;
};

/* what about OBJ_BAD ? */
unsigned node_size[] = {sizeof(union any_object),
			sizeof(struct commit),
			sizeof(struct tree),
			sizeof(struct blob),
			sizeof(struct tag),
			sizeof(union any_object)};

/*
 * Each slab
 *  - contains only structs of the same object type, hence no alignment issues
 *  - contains a fixed number of structs.
 *    The number is the same regardless of object type.
 *
 */
struct object_allocs {
	int slab_idx[1<<TYPE_BITS]; /* index in slabs of latest slab */
	int nr[1<<TYPE_BITS];       /* number of nodes left in current allocation */

	void **slabs;
	int slab_nr, slab_alloc;

	int commit_count;
};

void *allocate_object_allocs(void)
{
	return xcalloc(1, sizeof(struct object_allocs));
}

void clear_object_allocs(struct object_allocs *s)
{
	while (s->slab_nr > 0) {
		s->slab_nr--;
		free(s->slabs[s->slab_nr]);
	}

	FREE_AND_NULL(s->slabs);
}

void allocate_memory(struct object_allocs *s, unsigned type, struct object **mem)
{
	unsigned ns = node_size[type];
	struct object *obj;
	unsigned node_idx, slab_idx;

	if (!s->nr[type]) {
		ALLOC_GROW(s->slabs, s->slab_nr + 1, s->slab_alloc);

		s->slabs[s->slab_nr] = xcalloc(BLOCKING, ns);
		s->slab_idx[type] = s->slab_nr;

		s->nr[type] = BLOCKING;
		s->slab_nr++;
	}

	node_idx = BLOCKING - s->nr[type];
	s->nr[type]--;

	slab_idx = s->slab_idx[type];

	obj = (struct object*) & ((char*) s->slabs[slab_idx]) [node_idx * node_size[type]];

	obj->type = type;
	if (type == OBJ_COMMIT)
		((struct commit *)obj)->index = alloc_commit_index(s);

	*mem = obj;
}

unsigned int alloc_commit_index(struct object_allocs *s)
{
	return s->commit_count++;
}
