@@
expression E;
@@
 lookup_blob(
+the_repository,
 E)

@@
expression E;
@@
 lookup_tree(
+the_repository,
 E)

@@
expression E;
@@
 parse_tree_indirect(
+the_repository,
 E)

@@
expression E;
@@
 lookup_tag(
+the_repository,
 E)

@@
expression E;
expression F;
expression G;
@@
 parse_tag_buffer(
+the_repository,
 E, F, G)

@@
expression E;
expression F;
expression G;
@@
 deref_tag(
+the_repository,
 E, F, G)

@@
expression E;
@@
 deref_tag_noverify(
+the_repository,
 E)

@@
expression E;
expression F;
expression G;
@@
 gpg_verify_tag(
+the_repository,
 E, F, G)

@@
expression E;
@@
 parse_object(
+ the_repository,
 E)

@@
expression E;
@@
 get_merge_parent(
+ the_repository,
 E)

@@
expression E;
expression F;
@@
 clear_commit_marks_for_object_array(
+ the_repository,
 E, F)

@@
expression E;
expression F;
expression G;
@@
 parse_commit_buffer(
+the_repository,
 E, F, G)

@@
expression E;
@@
 unregister_shallow(
+ the_repository,
 E)

@@
expression E;
expression F;
@@
 parse_object_or_die(
+ the_repository,
 E, F)

@@
expression E;
expression F;
@@
 create_object(
+ the_repository,
 E, F)

@@ @@
 get_max_object_index(
+the_repository
 )

@@
expression E;
@@
 get_indexed_object(
+the_repository,
 E)

@@
expression E;
@@
 lookup_object(
+the_repository,
 E)

@@
expression E;
expression F;
@@
 lookup_commit_reference_gently(
+the_repository,
 E, F)

@@
expression E;
@@
 lookup_commit_reference(
+the_repository,
 E)

@@
expression E;
expression F;
@@
 lookup_commit_or_die(
+the_repository,
 E, F)

@@
expression E;
@@
 lookup_commit(
+the_repository,
 E)

@@
expression E;
@@
 lookup_commit_reference_by_name(
+the_repository,
 E)

@@
expression E;
expression F;
@@
 register_commit_graft(
+the_repository,
 E, F)

@@
expression E;
@@
 lookup_commit_graft(
+the_repository,
 E)

@@
expression E;
expression F;
@@
 for_each_commit_graft(
+the_repository,
 E, F)

@@
expression E;
@@
 lookup_unknown_object(
+the_repository,
 E)
