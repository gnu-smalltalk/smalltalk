AC_DEFUN([GST_LIBC_SO_NAME],
[AC_CACHE_CHECK([how to dlopen the C library], gst_cv_libc_so_name, [
  for i in /shlib/libc.so /System/Library/Frameworks/System.framework/Versions/*/System \
	   /lib*/libc.so* /usr/lib/libSystem.dylib /usr/lib/libc.so.* /usr/lib/libc.sl \
	   /lib/libc-*.so; do
    if test -f $i; then
      gst_cv_libc_so_name=$i
      break
    fi
  done])
LIBC_SO_NAME=`basename $gst_cv_libc_so_name`
LIBC_SO_DIR=`dirname $gst_cv_libc_so_name`
AC_SUBST(LIBC_SO_NAME)
AC_SUBST(LIBC_SO_DIR)
])
