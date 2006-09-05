dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_FUNC_STRTOUL], [

# Check for strtoul.  Under some versions of AIX, strtoul returns
# an incorrect terminator pointer for the string "0".
AC_CACHE_CHECK(for working strtoul, gst_cv_working_strtoul, [
  exec AS_MESSAGE_FD([])>/dev/null
  AC_CHECK_FUNC(strtoul, gst_cv_working_strtoul=yes, gst_cv_working_strtoul=no)
  if test $gst_cv_working_strtoul = yes; then
    AC_RUN_IFELSE([AC_LANG_SOURCE([[
      extern int strtoul();
      int main()
      {
	char *string = "0";
	char *term;
	int value;
	value = strtoul(string, &term, 0);
	exit((value != 0) || (term != (string+1)));
      }]])],[],[gst_cv_working_strtoul=no],[gst_cv_working_strtoul=no])
  fi
  test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
])

test "$gst_cv_working_strtoul" != yes && AC_LIBOBJ(strtoul)

])dnl
