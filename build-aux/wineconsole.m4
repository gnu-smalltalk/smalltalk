AC_DEFUN([GST_PROG_WINECONSOLE],
[AC_MSG_CHECKING([for wineconsole])
case $host:$build in
  *mingw*:*mingw* | *mingw*:*cygwin* )
    WINECONSOLE=
    ;;
  *mingw*:*)
    exec AS_MESSAGE_FD([])>/dev/null
    AC_PATH_PROG(WINECONSOLE, wineconsole, [no])
    test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
    if test $WINECONSOLE = no; then
      AC_MSG_ERROR([wineconsole needed to cross-compile GNU Smalltalk to Windows])
    fi
    set x $WINECONSOLE
    test $[]# = 2 && WINECONSOLE="$WINECONSOLE --backend=curses"
    ;;
  *)
    WINECONSOLE=
    ;;
esac
AC_MSG_RESULT([${WINECONSOLE:-no}])
AC_SUBST([WINECONSOLE])])
