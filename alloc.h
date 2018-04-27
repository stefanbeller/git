#ifndef ALLOC_H
#define ALLOC_H

extern void *alloc_blob_node(struct repository *r);
extern void *alloc_tree_node(struct repository *r);
extern void *alloc_commit_node(struct repository *r);
extern void *alloc_tag_node(struct repository *r);
extern void *alloc_object_node(struct repository *r);
extern void alloc_report(struct repository *r);
extern unsigned int alloc_commit_index(struct repository *r);

void *allocate_alloc_state(void);
extern struct alloc_state the_repository_blob_state;
extern struct alloc_state the_repository_tree_state;
extern struct alloc_state the_repository_commit_state;
extern struct alloc_state the_repository_tag_state;
extern struct alloc_state the_repository_object_state;

#endif
