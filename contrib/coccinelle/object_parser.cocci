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
