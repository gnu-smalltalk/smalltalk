dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_C_GOTO_VOID_P], [

AC_CACHE_CHECK(for goto void *, gst_cv_c_goto_void_p,
[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[
    void *x = &&label;
    goto *x;
    label: ]])],gst_cv_c_goto_void_p=yes,gst_cv_c_goto_void_p=no)
])
test $gst_cv_c_goto_void_p = yes && \
  AC_DEFINE(HAVE_GOTO_VOID_P, 1, [Define if your CC has the '&&' and 'goto void *' GCC extensions.])

])dnl
