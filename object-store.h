#ifndef OBJECT_STORE_H
#define OBJECT_STORE_H

struct raw_object_store {
	/*
	 * Path to the repository's object store.
	 * Cannot be NULL after initialization.
	 */
	char *objectdir;
};
#define RAW_OBJECT_STORE_INIT { NULL }

void raw_object_store_clear(struct raw_object_store *o);

#endif /* OBJECT_STORE_H */
