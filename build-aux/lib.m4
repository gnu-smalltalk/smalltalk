dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_HAVE_LIB], [

save_LIBS="$LIBS"
AC_CHECK_LIB($@)
LIBS="$save_LIBS"

])dnl
