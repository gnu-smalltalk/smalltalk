dnl Check whether the target supports synchronization builtins.

AC_DEFUN([GST_C_SYNC_BUILTINS], [
  AC_CACHE_CHECK([whether the target supports __sync_fetch_and_add],
                 gst_cv_have_sync_fetch_and_add, [
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[int foovar = 0;]], [[
if (foovar <= 0) return __sync_fetch_and_add (&foovar, 1);
if (foovar > 10) return __sync_add_and_fetch (&foovar, -1);]])],
		   [gst_cv_have_sync_fetch_and_add=yes],
		   [gst_cv_have_sync_fetch_and_add=no])
  ])
  if test $gst_cv_have_sync_fetch_and_add = yes; then
    AC_DEFINE(HAVE_SYNC_BUILTINS, 1,
              [Define to 1 if the target supports __sync_* builtins])
  fi
])
  
