dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_C_WARN_LONG_DOUBLE],
[AC_CACHE_CHECK([whether -Wno-long-double is needed], gst_cv_c_wno_long_double,
[gst_cv_c_wno_long_double=no
save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS -Werror"
AC_COMPILE_IFELSE([[long double a;]],
                  [gst_cv_c_wno_long_double=no; break],
		  [CFLAGS="$CFLAGS -Wno-long-double"
		   AC_COMPILE_IFELSE([[long double a;]],
		                     [gst_cv_c_wno_long_double=yes; break],
				     [AC_MSG_ERROR([compiler does not have long double])])])
CFLAGS="$save_CFLAGS"
])
if test $gst_cv_c_wno_long_double = yes; then
  CFLAGS="$CFLAGS -Wno-long-double"
fi
])# ACX_C_HIDDEN_VISIBILITY
