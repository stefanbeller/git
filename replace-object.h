#ifndef REPLACE_OBJECT_H
#define REPLACE_OBJECT_H

#include "cache.h"
#include "repository.h"

struct replace_object {
	unsigned char original[20];
	unsigned char replacement[20];
};

/*
 * This internal function is only declared here for the benefit of
 * lookup_replace_object().  Please do not call it directly.
 */
#define do_lookup_replace_object(r, s) do_lookup_replace_object_##r(s)
extern const unsigned char *do_lookup_replace_object_the_repository(const unsigned char *sha1);

/*
 * If object sha1 should be replaced, return the replacement object's
 * name (replaced recursively, if necessary).  The return value is
 * either sha1 or a pointer to a permanently-allocated value.  When
 * object replacement is suppressed, always return sha1.
 */
static inline const unsigned char *lookup_replace_object(const unsigned char *sha1)
{
	if (!check_replace_refs)
		return sha1;
	return do_lookup_replace_object(the_repository, sha1);
}

#endif /* REPLACE_OBJECT_H */
