dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_HAVE_TCLTK], [

AC_ARG_WITH(tcl, 
	[  --with-tcl=path         set path to tclConfig.sh [default=ask tclsh]])

AC_ARG_WITH(tk, 
	[  --with-tk=path          set path to tkConfig.sh [default=same as Tcl]])

if test "x$with_tcl" = x || test "$with_tcl" = yes; then
  AC_MSG_CHECKING(for tclsh)
  exec AS_MESSAGE_FD([])>/dev/null
  AC_PATH_PROG(TCLSH, tclsh)

  case $libdir in
    $bindir | $prefix | '${prefix}') libpath=lib ;;
    *) libpath=`echo ${libdir} | sed s:.*/::` ;;
  esac

  dataroot2lib='s,\(.*\)/'`echo ${datarootdir} | sed s:.*/::`,'\1'/$libpath,
  test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
  if test -n "$TCLSH"; then
    for i in ${TCLSH}*; do
      if test -x $i; then
        with_tcl=`echo 'puts $tcl_library' | $i 2> /dev/null`
        if test "x$with_tcl" != x; then
          # Assign the name we found to the TCLSH variable, and try
	  # to remove the last component from the path and to change
	  # /usr/share to /usr/lib
	  TCLSH=$i
          test -f "$with_tcl/../../tclConfig.sh" && with_tcl="$with_tcl/../.." && break
          test -f "$with_tcl/../tclConfig.sh" && with_tcl="$with_tcl/.." && break
          test -f "$with_tcl/tclConfig.sh" && break
          with_tcl=`echo "$with_tcl" | sed $dataroot2lib`
	  # Do not bother testing /usr/lib/tcl8.5/tclConfig.sh if there is one
	  # in /usr/lib.
          if test -f "$with_tcl/../tclConfig.sh"; then :; else
            test -f "$with_tcl/tclConfig.sh" && break
          fi
          with_tcl=`echo "$with_tcl" | sed 's:/[[^/]]*/\{0,1\}$::'`
          if test -f "$with_tcl/../tclConfig.sh"; then :; else
            test -f "$with_tcl/tclConfig.sh" && break
          fi
          with_tcl=`echo "$with_tcl" | sed 's:/[[^/]]*/\{0,1\}$::'`
          test -f "$with_tcl/tclConfig.sh" && break
        fi
	with_tcl=no
	TCLSH=no
      fi
    done
  else
    with_tcl=no
    TCLSH=no
  fi
  AC_MSG_RESULT($TCLSH)
fi
if test "x$with_tk" = x || test "$with_tk" = yes; then
  with_tk=`echo "$with_tcl" | sed -e 's/tcl/tk/g' -e 's/tktk/tcltk/g' -e 's/Tcl/Tk/g'`
  test -f "$with_tk/tkConfig.sh" || with_tk=no
fi
if test "$with_tcl" != no; then
  with_tcl=`cd $with_tcl && pwd`
  test -f "$with_tcl/tclConfig.sh" || with_tcl=no
fi
if test "$with_tk" != no; then
  with_tk=`cd $with_tk && pwd`
  test -f "$with_tk/tkConfig.sh" || with_tk=no
fi

AC_MSG_CHECKING(for Tcl 8.x)
AC_MSG_RESULT($with_tcl)
AC_MSG_CHECKING(for Tk 8.x)
AC_MSG_RESULT($with_tk)

save_cppflags="$CPPFLAGS"
save_libs="$LIBS"

AC_CACHE_CHECK(the include path for Tcl/Tk 8.x, gst_cv_tcltk_includes, [
  exec AS_MESSAGE_FD([])>/dev/null

  gst_cv_tcltk_includes="not found"

  if test "$with_tcl" != no && test "$with_tk" != no; then
    # Get the values we need from the Tcl/Tk configuration files
    . $with_tcl/tclConfig.sh
    . $with_tk/tkConfig.sh

    # search for the header files, because some implementations of tclConfig.sh
    # do not deliver correct header includes
    for trial in 0 1 2 3 4; do
      case $trial in
	0) gst_cv_tcltk_includes="$TK_XINCLUDES $TCL_INCLUDE_SPEC" ;;
        1) gst_cv_tcltk_includes="$TK_XINCLUDES -I$TCL_PREFIX/include"
	   test "$TCL_PREFIX" != "$TCL_EXEC_PREFIX" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TCL_EXEC_PREFIX/include"
	   test "$TCL_PREFIX" != "$TK_PREFIX" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TK_PREFIX/include"
	   test "$TK_PREFIX" != "$TK_EXEC_PREFIX" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TK_EXEC_PREFIX/include" ;;
	2) gst_cv_tcltk_includes="$TK_XINCLUDES -I$TCL_SRC_DIR/.."
	   test "$TCL_SRC_DIR" != "$TK_SRC_DIR" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TK_SRC_DIR/.." ;;
	3) gst_cv_tcltk_includes="$TK_XINCLUDES -I$TCL_SRC_DIR/include"
	   test "$TCL_SRC_DIR" != "$TK_SRC_DIR" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TK_SRC_DIR/include" ;;
	4) gst_cv_tcltk_includes="$TK_XINCLUDES -I$TCL_PREFIX/include/tcl$TCL_VERSION -I$TK_PREFIX/include/tk$TK_VERSION"
	   test "$TCL_PREFIX" != "$TCL_EXEC_PREFIX" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TCL_EXEC_PREFIX/include/tcl$TCL_VERSION"
	   test "$TK_PREFIX" != "$TK_EXEC_PREFIX" &&
	     gst_cv_tcltk_includes="$gst_cv_tcltk_includes -I$TK_EXEC_PREFIX/include/tk$TK_VERSION" ;;
      esac

      CPPFLAGS="$save_cppflags $gst_cv_tcltk_includes"
      AC_EGREP_CPP(everything_fine, [
#include <tcl.h>
#include <tk.h>
#ifdef TCL_MAJOR_VERSION
#ifdef TK_MAJOR_VERSION
#if ((TCL_MAJOR_VERSION == $TCL_MAJOR_VERSION) && (TCL_MINOR_VERSION == $TCL_MINOR_VERSION))
#if ((TK_MAJOR_VERSION == $TK_MAJOR_VERSION) && (TCL_MINOR_VERSION == $TCL_MINOR_VERSION))
    everything_fine
#endif
#endif
#endif
#endif], break)

      gst_cv_tcltk_includes="not found"
    done
  fi
    
  test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
])

AC_CACHE_CHECK(how to link with Tcl/Tk 8.x, gst_cv_tcltk_libs, [
  gst_cv_tcltk_libs="not found"
  exec AS_MESSAGE_FD([])>/dev/null

  if test "$gst_cv_tcltk_includes" != "not found"; then
    # The indirection is required by Tcl/Tk
    gst_cv_tcltk_libs="$TCL_LIBS $TK_XLIBSW $TCL_LIB_SPEC $TK_LIB_SPEC"
    gst_cv_tcltk_libs=`eval echo $gst_cv_tcltk_libs`

    CPPFLAGS="$save_cppflags $gst_cv_tcltk_includes"
    LIBS="$save_libs $gst_cv_tcltk_libs"
    AC_CHECK_FUNC(Tcl_ObjSetVar2, , gst_cv_tcltk_libs="not found")
    AC_CHECK_FUNC(Tk_CreatePhotoImageFormat, , gst_cv_tcltk_libs="not found")
  fi

  test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
])

CPPFLAGS="$save_cppflags"
LIBS="$save_libs"

if test "$gst_cv_tcltk_libs" != "not found"; then
  LIBTCLTK="$gst_cv_tcltk_libs"
  INCTCLTK="$gst_cv_tcltk_includes"
  AC_DEFINE(HAVE_TCLTK, 1,
    [Define if your system has Tcl/Tk, 8.0 or later, installed.])
fi

AC_SUBST(LIBTCLTK)
AC_SUBST(INCTCLTK)
])dnl
