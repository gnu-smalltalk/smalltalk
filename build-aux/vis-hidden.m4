dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_C_HIDDEN_VISIBILITY],
[AC_CACHE_CHECK([for hidden visibility], gst_cv_c_visibility_hidden,
[gst_cv_c_visibility_hidden=no
save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS -Werror"
AC_COMPILE_IFELSE([AC_LANG_SOURCE([char *c __attribute__ ((visibility ("hidden")));])],
                  [gst_cv_c_visibility_hidden=yes; break])
CFLAGS="$save_CFLAGS"
])
if test $gst_cv_c_visibility_hidden = yes; then
  AC_DEFINE(HAVE_VISIBILITY_HIDDEN,,
           [Define if the C compiler support the ELF hidden visibility])
fi
])# GST_C_HIDDEN_VISIBILITY
