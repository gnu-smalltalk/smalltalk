dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_HAVE_OPENGL], [

AC_REQUIRE([AC_PATH_XTRA])
AC_CHECK_HEADERS([OpenGL/gl.h OpenGL/glu.h GL/gl.h GL/glu.h])

AC_CACHE_CHECK([how to link with OpenGL libraries], gst_cv_opengl_libs, [
  if test $ac_cv_header_OpenGL_gl_h = no && \
     test $ac_cv_header_GL_gl_h = no; then
    gst_cv_opengl_libs='not found'
  elif test $ac_cv_header_OpenGL_glu_h = no && \
       test $ac_cv_header_GL_glu_h = no; then
    gst_cv_opengl_libs='not found'
  else
    save_LIBS=$LIBS
    case $host in
      *-*-mingw* | *-*-cygwin*) gst_cv_opengl_libs='-lopengl32 -lglu32' ;;
      *-*-beos* | *-*-qnx*) gst_cv_opengl_libs='-lGL' ;;
      *-*-darwin*) gst_cv_opengl_libs='-Wl,-framework,OpenGL' ;;
      *) gst_cv_opengl_libs="-lGL -lGLU $X_LIBS $X_PRE_LIBS -lX11" ;;
    esac

    LIBS="$LIBS $gst_cv_opengl_libs"
    AC_LINK_IFELSE([AC_LANG_PROGRAM([
      #ifdef HAVE_GL_GL_H
      #include <GL/gl.h>
      #else
      #include <OpenGL/gl.h>
      #endif], [glBegin(GL_TRIANGLES)])],
                   [], [gst_cv_opengl_libs='not found'])
    LIBS=$save_LIBS
  fi
])

if test "$gst_cv_opengl_libs" != "not found"; then
  LIBOPENGL="$gst_cv_opengl_libs"
  AC_DEFINE(HAVE_OPENGL, 1, [Define if your system has OpenGL installed.])

  if test $ac_cv_header_OpenGL_gl_h = yes; then
    gst_cv_opengl_header_dir='OpenGL'
  else
    gst_cv_opengl_header_dir='GL'
  fi
  AC_DEFINE_UNQUOTED(GL_GL_H, [<$gst_cv_opengl_header_dir/gl.h>], [Define to the #include directive for OpenGL.])
  AC_DEFINE_UNQUOTED(GL_GLU_H, [<$gst_cv_opengl_header_dir/glu.h>], [Define to the #include directive for OpenGL glu functions.])
fi
AC_SUBST(LIBOPENGL)
])dnl
