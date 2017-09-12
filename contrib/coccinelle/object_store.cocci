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
