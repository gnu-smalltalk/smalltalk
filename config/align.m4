dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_CHECK_ALIGNMENT], [
AS_LITERAL_IF([$1], [],
               [AC_FATAL([$0: requires literal arguments])])dnl

AC_CACHE_CHECK([for $1 alignment], AS_TR_SH([gst_cv_$1_alignment]), [
_AC_COMPUTE_INT_COMPILE([offsetof(struct s, y)],
  [AS_TR_SH([gst_cv_$1_alignment])], [$2
#include <stddef.h>
#ifndef offsetof
#define offsetof(type, field) (((int) ((char *) &((type *) 4)->field)) - 4)
#endif

  struct s {
    char x;
    $1 y;
  };
])])

AC_DEFINE_UNQUOTED(AS_TR_CPP($1_alignment), $AS_TR_SH([gst_cv_$1_alignment]),
                   [The alignment required for a value of type `$1'])

])dnl
