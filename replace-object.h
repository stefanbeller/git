#ifndef REPLACE_OBJECT_H
#define REPLACE_OBJECT_H

struct replace_objects {
	/*
	 * An array of replacements.  The array is kept sorted by the original
	 * sha1.
	 */
	struct replace_object **items;

	int alloc, nr;
};
#define REPLACE_OBJECTS_INIT { NULL, 0, 0 }

struct replace_object {
	unsigned char original[20];
	unsigned char replacement[20];
};

#endif /* REPLACE_OBJECT_H */
