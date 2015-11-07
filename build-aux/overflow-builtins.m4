dnl Check whether the host supports synchronization builtins.

AC_DEFUN([GST_C_OVERFLOW_BUILTINS], [
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_CACHE_CHECK([whether the host supports __builtin_mul_overflow],
                 gst_cv_have_builtin_mul_overflow, [
    save_CFLAGS="$CFLAGS"
    case $host in
      i?86-apple-darwin*) ;;
      i?86-*-*) CFLAGS="$CFLAGS -march=i486" ;;
    esac
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[int foovar = 0;]], [[
if (__builtin_mul_overflow(44444, 55555, &foovar))
	return 23;]])],
		   [gst_cv_have_builtin_mul_overflow=yes],
		   [gst_cv_have_builtin_mul_overflow=no])
    CFLAGS="$save_CFLAGS"
  ])
  if test $gst_cv_have_builtin_mul_overflow = yes; then
    AC_DEFINE(HAVE_OVERFLOW_BUILTINS, 1,
              [Define to 1 if the host supports __builtin_*_overflow builtins])
  fi
])
