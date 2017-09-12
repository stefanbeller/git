@@
expression E;
@@
 parse_object(
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
