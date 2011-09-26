dnl Check whether the host supports synchronization builtins.

AC_DEFUN([GST_C_SYNC_BUILTINS], [
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_CACHE_CHECK([whether the host supports __sync_fetch_and_add],
                 gst_cv_have_sync_fetch_and_add, [
    save_CFLAGS="$CFLAGS"
    case $host in
      i?86-apple-darwin*) ;;
      i?86-*-*) CFLAGS="$CFLAGS -march=i486" ;;
    esac
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[int foovar = 0;]], [[
if (foovar <= 0) return __sync_fetch_and_add (&foovar, 1);
if (foovar > 10) return __sync_add_and_fetch (&foovar, -1);]])],
		   [gst_cv_have_sync_fetch_and_add=yes],
		   [gst_cv_have_sync_fetch_and_add=no])
    CFLAGS="$save_CFLAGS"
  ])
  if test $gst_cv_have_sync_fetch_and_add = yes; then
    AC_DEFINE(HAVE_SYNC_BUILTINS, 1,
              [Define to 1 if the host supports __sync_* builtins])

    AC_CACHE_CHECK([whether the host is i386],
                   gst_cv_cc_arch_i386, [
      AC_LINK_IFELSE([AC_LANG_PROGRAM([[int foovar = 0;]], [[
if (foovar <= 0) return __sync_fetch_and_add (&foovar, 1);
if (foovar > 10) return __sync_add_and_fetch (&foovar, -1);]])],
		   [gst_cv_cc_arch_i386=no],
		   [gst_cv_cc_arch_i386=yes])
    ])
    if test $gst_cv_cc_arch_i386 = yes; then
      AC_MSG_WARN([$PACKAGE_NAME will be compiled for i486])
      SYNC_CFLAGS="-march=i486"
    else
      SYNC_CFLAGS=
    fi
  fi
  AC_SUBST([SYNC_CFLAGS])
])
