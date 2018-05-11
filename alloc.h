#ifndef ALLOC_H
#define ALLOC_H

void *allocate_object_allocs(void);
void clear_object_allocs(struct object_allocs *s);

unsigned int alloc_commit_index(struct object_allocs *s);
void allocate_memory(struct object_allocs *s, unsigned type, unsigned *obj_i, struct object **mem);

void *get_mem(struct object_allocs *s, unsigned obj_i);

#endif
