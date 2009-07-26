AC_DEFUN([GST_WINE_IF],
[AC_REQUIRE([GST_WINE])
AS_IF([test "x$gst_cv_wine" = xyes], $@)])

AC_DEFUN([GST_WINE],
[AC_CACHE_CHECK([whether cross-compiling under Wine], [gst_cv_wine],
[case $host:$build in
  *mingw*:*mingw* | *mingw*:*cygwin* ) gst_cv_wine=no ;;
  *mingw*:*) gst_cv_wine=yes ;;
  *) gst_cv_wine=no ;;
esac])])
