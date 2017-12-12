#ifndef OBJECT_STORE_H
#define OBJECT_STORE_H

#include "strbuf.h"
#include "mru.h"
#include "alternates.h"

/* in packfile.h */
struct pack_window;

/* in cache.h */
enum object_type;
extern int check_replace_refs;

struct raw_object_store {
	struct packed_git *packed_git;

	/*
	 * A most-recently-used ordered version of the packed_git list, which can
	 * be iterated instead of packed_git (and marked via mru_mark).
	 */
	struct mru packed_git_mru;

	/*
	 * Additional object databases to fall back on when an object does not
	 * exist in the current one (see --reference in git-clone(1)).
	 */
	struct alternates alt_odb;

	/*
	 * Objects that should be substituted by other objects
	 * (see git-replace(1)).
	 */
	struct replace_objects {
		/*
		 * An array of replacements.  The array is kept sorted by the original
		 * sha1.
		 */
		struct replace_object **items;

		int alloc, nr;

		unsigned prepared : 1;
	} replacements;

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
#define RAW_OBJECT_STORE_INIT \
	{ NULL, MRU_INIT, ALTERNATES_INIT, { NULL, 0, 0, 0 }, 0, 0, 0 }

extern void raw_object_store_clear(struct raw_object_store *o);

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

extern void *read_sha1_file_extended(struct repository *r,
				     const unsigned char *sha1,
				     enum object_type *type,
				     unsigned long *size, int lookup_replace);

static inline void *read_sha1_file(struct repository *r, const unsigned char *sha1, enum object_type *type, unsigned long *size)
{
	return read_sha1_file_extended(r, sha1, type, size, 1);
}

/* Read and unpack a sha1 file into memory, write memory to a sha1 file */
extern int sha1_object_info(struct repository *r, const unsigned char *sha1, unsigned long *sizep);
extern int hash_sha1_file(const void *buf, unsigned long len, const char *type, unsigned char *sha1);
extern int write_sha1_file(const void *buf, unsigned long len, const char *type, unsigned char *return_sha1);
extern int hash_sha1_file_literally(const void *buf, unsigned long len, const char *type, struct object_id *oid, unsigned flags);
extern int pretend_sha1_file(void *, unsigned long, enum object_type, unsigned char *);
extern int force_object_loose(const unsigned char *sha1, time_t mtime);
extern void *map_sha1_file(struct repository *r, const unsigned char *sha1, unsigned long *size);

/*
 * Rehash an object's data to make sure the object name actually matches
 * "sha1" to detect object corruption.
 *
 * The in-core object data should be in "map". If "map" == NULL, reads the
 * named object using the streaming interface and rehashes it on the fly.
 */
#define check_sha1_signature(r, s, m, sz, t) check_sha1_signature_##r(s, m, sz, t)
extern int check_sha1_signature_the_repository(const unsigned char *sha1, void *buf, unsigned long size, const char *type);

/*
 * Convenience for sha1_object_info_extended() with a NULL struct
 * object_info. OBJECT_INFO_SKIP_CACHED is automatically set; pass
 * nonzero flags to also set other flags.
 */
extern int has_sha1_file_with_flags(const unsigned char *sha1, int flags);
static inline int has_sha1_file(const unsigned char *sha1)
{
	return has_sha1_file_with_flags(sha1, 0);
}

/* Same as the above, except for struct object_id. */
extern int has_object_file(const struct object_id *oid);
extern int has_object_file_with_flags(const struct object_id *oid, int flags);

extern void assert_sha1_type(const unsigned char *sha1, enum object_type expect);

struct object_info {
	/* Request */
	enum object_type *typep;
	unsigned long *sizep;
	off_t *disk_sizep;
	unsigned char *delta_base_sha1;
	struct strbuf *typename;
	void **contentp;

	/* Response */
	enum {
		OI_CACHED,
		OI_LOOSE,
		OI_PACKED,
		OI_DBCACHED
	} whence;
	union {
		/*
		 * struct {
		 * 	... Nothing to expose in this case
		 * } cached;
		 * struct {
		 * 	... Nothing to expose in this case
		 * } loose;
		 */
		struct {
			struct packed_git *pack;
			off_t offset;
			unsigned int is_delta;
		} packed;
	} u;
};

/*
 * Initializer for a "struct object_info" that wants no items. You may
 * also memset() the memory to all-zeroes.
 */
#define OBJECT_INFO_INIT {NULL}

/* Invoke lookup_replace_object() on the given hash */
#define OBJECT_INFO_LOOKUP_REPLACE 1
/* Allow reading from a loose object file of unknown/bogus type */
#define OBJECT_INFO_ALLOW_UNKNOWN_TYPE 2
/* Do not check cached storage */
#define OBJECT_INFO_SKIP_CACHED 4
/* Do not retry packed storage after checking packed and loose storage */
#define OBJECT_INFO_QUICK 8

extern int sha1_object_info_extended(struct repository *r,
				     const unsigned char *sha1,
				     struct object_info *oi,
				     unsigned flags);

#endif /* OBJECT_STORE_H */
