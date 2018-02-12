#ifndef OBJECT_STORE_H
#define OBJECT_STORE_H

struct raw_object_store {
	/*
	 * Path to the repository's object store.
	 * Cannot be NULL after initialization.
	 */
	char *objectdir;

	unsigned ignore_env : 1;
};
#define RAW_OBJECT_STORE_INIT { NULL, 0 }

void raw_object_store_clear(struct raw_object_store *o);

#endif /* OBJECT_STORE_H */
