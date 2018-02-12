#ifndef OBJECT_STORE_H
#define OBJECT_STORE_H

#include "cache.h"

struct raw_object_store {
	/*
	 * Path to the repository's object store.
	 * Cannot be NULL after initialization.
	 */
	char *objectdir;

	struct alternate_object_database *alt_odb_list;
	struct alternate_object_database **alt_odb_tail;
};
#define RAW_OBJECT_STORE_INIT { NULL, NULL, NULL }

void raw_object_store_clear(struct raw_object_store *o);

#endif /* OBJECT_STORE_H */
