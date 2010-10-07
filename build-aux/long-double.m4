dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_C_LONG_DOUBLE],
[AC_CACHE_CHECK([whether -Wno-long-double is needed], gst_cv_c_wno_long_double,
[gst_cv_c_wno_long_double=no
save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS -Werror"
AC_COMPILE_IFELSE([AC_LANG_SOURCE([long double a;])],
                  [gst_cv_c_wno_long_double=no; break],
		  [CFLAGS="$CFLAGS -Wno-long-double"
		   AC_COMPILE_IFELSE([AC_LANG_SOURCE([long double a;])],
		                     [gst_cv_c_wno_long_double=yes; break],
				     [AC_MSG_ERROR([compiler does not have long double])])])
CFLAGS="$save_CFLAGS"
])
if test $gst_cv_c_wno_long_double = yes; then
  CFLAGS="$CFLAGS -Wno-long-double"
fi

AC_CACHE_CHECK([the number of mantissa digits in long doubles], gst_cv_ldbl_mant_dig,
[AC_COMPUTE_INT([gst_cv_ldbl_mant_dig], [LDBL_MANT_DIG],
[AC_INCLUDES_DEFAULT
@%:@include <float.h>], [gst_cv_ldbl_mant_dig=unknown])
])


AC_CACHE_CHECK([whether this long double format is supported], gst_cv_long_double_ok,
[if test $gst_cv_ldbl_mant_dig = 106; then
  save_CFLAGS="$CFLAGS"
  CFLAGS="$CFLAGS -mlong-double-64"
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM],
                    [gst_cv_long_double_ok='no, disabling'],
                    [gst_cv_long_double_ok=no])
  CFLAGS="$save_CFLAGS"
else
  gst_cv_long_double_ok=yes
fi])

if test "$gst_cv_long_double_ok" != yes; then
  case $host in
    powerpc*-*-darwin*)
      # Darwin provides both 64-bit and 128-bit long double functions in
      # its libc
      ;;
    *)
      # A glibc installations for a compiler that defaults to -mlong-double-128
      # won't work for -mlong-double-64.  We may instead want to use a switch
      # to use doubles directly instead of -mlong-double-64.
      ac_cv_func_floorl=no
      ac_cv_func_ceill=no
      ac_cv_func_sqrtl=no
      ac_cv_func_frexpl=no
      ac_cv_func_ldexpl=no
      ac_cv_func_asinl=no
      ac_cv_func_acosl=no
      ac_cv_func_atanl=no
      ac_cv_func_logl=no
      ac_cv_func_expl=no
      ac_cv_func_tanl=no
      ac_cv_func_sinl=no
      ac_cv_func_cosl=no
      ac_cv_func_powl=no
      ac_cv_func_truncl=no
      ac_cv_func_lrintl=no
      ;;
  esac
  case $gst_cv_long_double_ok in
    "no, disabling") CFLAGS="$CFLAGS -mlong-double-64" ;;
    no) AC_MSG_WARN([cannot disable IBM extended long doubles, floating-point tests may fail]) ;;
  esac
fi

])# GST_C_LONG_DOUBLE
