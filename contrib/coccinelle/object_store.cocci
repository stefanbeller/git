@@
expression E;
expression F;
@@
 sha1_object_info(
+the_repository,
 E, F)

@@
expression E;
expression F;
expression G;
expression H;
@@
 check_sha1_signature(
+the_repository,
 E, F, G, H)

@@
expression E;
expression F;
expression G;
expression H;
@@
 read_sha1_file_extended(
+the_repository,
 E, F, G, H)

@@
expression E;
expression F;
expression G;
@@
 read_sha1_file(
+the_repository,
 E, F, G)

@@
expression E;
expression F;
expression G;
expression H;
@@
open_istream(
+ the_repository,
 E, F, G, H)

@@
expression E;
expression F;
@@
 parse_commit_gently(
+ the_repository,
  E, F)

@@
expression E;
@@
 parse_commit(
+ the_repository,
 E)

@@
expression E;
expression F;
@@
 unuse_commit_buffer(
+the_repository,
 E, F)
