#ifndef OBJECT_STORE_H
#define OBJECT_STORE_H

#include "cache.h"
#include "mru.h"

struct raw_object_store {
	/*
	 * Path to the repository's object store.
	 * Cannot be NULL after initialization.
	 */
	char *objectdir;

	struct packed_git *packed_git;
	/*
	 * A most-recently-used ordered version of the packed_git list, which can
	 * be iterated instead of packed_git (and marked via mru_mark).
	 */
	struct mru packed_git_mru;

	struct alternate_object_database *alt_odb_list;
	struct alternate_object_database **alt_odb_tail;

	/*
	 * A fast, rough count of the number of objects in the repository.
	 * These two fields are not meant for direct access. Use
	 * approximate_object_count() instead.
	 */
	unsigned long approximate_object_count;
	unsigned approximate_object_count_valid : 1;

	/*
	 * Whether packed_git has already been populated with this repository's
	 * packs.
	 */
	unsigned packed_git_initialized : 1;
};
#define RAW_OBJECT_STORE_INIT { NULL, NULL, MRU_INIT, NULL, NULL, 0, 0, 0 }

void raw_object_store_clear(struct raw_object_store *o);

struct packed_git {
	struct packed_git *next;
	struct pack_window *windows;
	off_t pack_size;
	const void *index_data;
	size_t index_size;
	uint32_t num_objects;
	uint32_t num_bad_objects;
	unsigned char *bad_object_sha1;
	int index_version;
	time_t mtime;
	int pack_fd;
	unsigned pack_local:1,
		 pack_keep:1,
		 freshened:1,
		 do_not_close:1;
	unsigned char sha1[20];
	struct revindex_entry *revindex;
	/* something like ".git/objects/pack/xxxxx.pack" */
	char pack_name[FLEX_ARRAY]; /* more */
};

void prepare_alt_odb(struct repository *r);

#endif /* OBJECT_STORE_H */
