dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_HAVE_GMP], [

AC_ARG_WITH(gmp, 
	[  --with-gmp=path         set path to the GMP library
  --without-gmp           don't try to detect and use GMP])


if test "$with_gmp" != no; then
  AC_CACHE_CHECK(how to link with GMP, gst_cv_gmp_libs, [
    if test "$with_gmp" && test -d "$with_gmp"; then
      gst_cv_gmp_libs="-L$with_gmp -lgmp"
      CPPFLAGS="$CPPFLAGS -I$with_gmp/../include"
    else
      gst_cv_gmp_libs="-lgmp"
    fi
    
    ac_save_LIBS="$LIBS"
    LIBS="$ac_save_LIBS $gst_cv_gmp_libs"

    AC_LINK_IFELSE([AC_LANG_PROGRAM([[
	#include <stdio.h>
	#include <gmp.h>
      ]], [[
        #if __GNU_MP_VERSION < 4
          you lose
        #endif
        mpz_t z;
        mp_limb_t n[10];
        mpn_tdiv_qr (n, n, 10, n, 10, n, 10);
        mpz_init_set_str (z, "123456", 0);
      ]])],[],[gst_cv_gmp_libs="not found"])
    LIBS="$ac_save_LIBS"
  ])

  if test "$gst_cv_gmp_libs" != "not found"; then
    LIBGMP="$gst_cv_gmp_libs"
    AC_SUBST(LIBGMP)
    AC_DEFINE(HAVE_GMP, 1,
          [Define if your system has the GNU MP library.])
    AC_CHECK_SIZEOF(mp_limb_t, , [
	#include <gmp.h>
	#include <stdio.h> ])
  fi
fi

])dnl
