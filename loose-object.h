#ifndef LOOSE_OBJECT_H
#define LOOSE_OBJECT_H

#include "cache.h"
#include "strbuf.h"
#include "repository.h"

/*
 * Open the loose object at path, check its sha1, and return the contents,
 * type, and size. If the object is a blob, then "contents" may return NULL,
 * to allow streaming of large blobs.
 *
 * Returns 0 on success, negative on error (details may be written to stderr).
 */
int read_loose_object(const char *path,
		      const unsigned char *expected_sha1,
		      enum object_type *type,
		      unsigned long *size,
		      void **contents);

/*
 * Return true iff an alternate object database has a loose object
 * with the specified name.  This function does not respect replace
 * references.
 */
#define has_loose_object_nonlocal(r, s) has_loose_object_nonlocal_##r(s)
extern int has_loose_object_nonlocal_the_repository(const unsigned char *sha1);

/*
 * Iterate over the files in the loose-object parts of the object
 * directory "path", triggering the following callbacks:
 *
 *  - loose_object is called for each loose object we find.
 *
 *  - loose_cruft is called for any files that do not appear to be
 *    loose objects. Note that we only look in the loose object
 *    directories "objects/[0-9a-f]{2}/", so we will not report
 *    "objects/foobar" as cruft.
 *
 *  - loose_subdir is called for each top-level hashed subdirectory
 *    of the object directory (e.g., "$OBJDIR/f0"). It is called
 *    after the objects in the directory are processed.
 *
 * Any callback that is NULL will be ignored. Callbacks returning non-zero
 * will end the iteration.
 *
 * In the "buf" variant, "path" is a strbuf which will also be used as a
 * scratch buffer, but restored to its original contents before
 * the function returns.
 */
typedef int each_loose_object_fn(const struct object_id *oid,
				 const char *path,
				 void *data);
typedef int each_loose_cruft_fn(const char *basename,
				const char *path,
				void *data);
typedef int each_loose_subdir_fn(unsigned int nr,
				 const char *path,
				 void *data);
int for_each_file_in_obj_subdir(unsigned int subdir_nr,
				struct strbuf *path,
				each_loose_object_fn obj_cb,
				each_loose_cruft_fn cruft_cb,
				each_loose_subdir_fn subdir_cb,
				void *data);
int for_each_loose_file_in_objdir(const char *path,
				  each_loose_object_fn obj_cb,
				  each_loose_cruft_fn cruft_cb,
				  each_loose_subdir_fn subdir_cb,
				  void *data);
int for_each_loose_file_in_objdir_buf(struct strbuf *path,
				      each_loose_object_fn obj_cb,
				      each_loose_cruft_fn cruft_cb,
				      each_loose_subdir_fn subdir_cb,
				      void *data);

/*
 * Iterate over loose objects in both the local
 * repository and any alternates repositories (unless the
 * FOR_EACH_OBJECT_LOCAL_ONLY flag, defined in cache.h, is set).
 */
extern int for_each_loose_object(each_loose_object_fn, void *, unsigned flags);

/*
 * Return the name of the file in a repository's local object database
 * that would be used to store a loose object with the specified sha1.
 * The return value is a pointer to a statically allocated buffer that
 * is overwritten each time the function is called.
 */
extern const char *sha1_file_name(struct repository *r, const unsigned char *sha1);

#endif
