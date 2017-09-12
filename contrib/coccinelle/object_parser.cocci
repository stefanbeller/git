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
 parse_object(
+ the_repository,
 E)

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
expression F;
@@
 create_object(
+ the_repository,
 E, F)

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
@@
 lookup_commit(
+the_repository,
 E)

@@
expression E;
expression F;
@@
 register_commit_graft(
+the_repository,
 E, F)
