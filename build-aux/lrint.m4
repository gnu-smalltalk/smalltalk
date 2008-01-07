dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_FUNC_LRINT], [

# Check for lrint.  Under ia64-linux, lrint returns
# incorrect values for bit 31.
AC_CACHE_CHECK(for working lrint, gst_cv_working_lrint, [
  exec AS_MESSAGE_FD([])>/dev/null
  AC_CHECK_FUNC(lrint, gst_cv_working_lrint=yes, gst_cv_working_lrint=no)
  if test $gst_cv_working_lrint = yes; then
    AC_RUN_IFELSE([AC_LANG_SOURCE([[
      double d = 14988885582133630.0;
      int main()
      {
	extern long int lrint (double);
	long int l = lrint (d);
	exit(sizeof (l) >= 8 && l != 14988885582133630);
      }]])],[],[gst_cv_working_lrint=no],[gst_cv_working_lrint=no])
  fi
  test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
])

test "$gst_cv_working_lrint" != yes && AC_LIBOBJ(lrint)

])dnl

