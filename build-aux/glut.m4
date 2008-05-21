dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_HAVE_GLUT], [

AC_REQUIRE([AC_PATH_XTRA])
AC_CHECK_HEADERS([GLUT/glut.h GL/glut.h])

AC_CACHE_CHECK([how to link with GLUT], gst_cv_glut_libs, [
  if test $ac_cv_header_GLUT_glut_h = yes || \
     test $ac_cv_header_GL_glut_h = yes; then
    case $host in
      *-*-darwin*) gst_cv_glut_libs='-Wl,-framework,GLUT' ;;
      *) gst_cv_glut_libs='-lglut $(X_LIBS) $(X_PRE_LIBS) -lX11' ;;
    esac
  else
    gst_cv_glut_libs='not found'
  fi
])

if test "$gst_cv_glut_libs" != "not found"; then
  LIBGLUT="$gst_cv_glut_libs"
  AC_DEFINE(HAVE_GLUT, 1, [Define if your system has GLUT installed.])

  if test $ac_cv_header_GLUT_glut_h = yes; then
    gst_cv_glut_header_dir='GLUT'
  else
    gst_cv_glut_header_dir='GL'
  fi
  AC_DEFINE_UNQUOTED(GL_GLUT_H, [<$gst_cv_glut_header_dir/glut.h>], [Define to the #include directive for GLUT.])
fi
AC_SUBST(LIBGLUT)
])dnl
