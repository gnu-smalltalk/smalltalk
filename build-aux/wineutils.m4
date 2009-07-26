AC_DEFUN([GST_PROG_WINEUTILS],
[AC_PATH_PROG(WINEPATH, winepath, [no])
AC_MSG_CHECKING([for wineconsole])
GST_WINE_IF(
    [exec AS_MESSAGE_FD([])>/dev/null
    AC_PATH_PROG(WINECONSOLE, wineconsole, [no])
    test "$silent" != yes && exec AS_MESSAGE_FD([])>&1
    if test $WINECONSOLE = no; then
      AC_MSG_ERROR([wineconsole needed to cross-compile GNU Smalltalk to Windows])
    fi
    set x $WINECONSOLE
    test $[]# = 2 && WINECONSOLE="$WINECONSOLE --backend=curses"],
    [WINECONSOLE=])
AC_MSG_RESULT([${WINECONSOLE:-no}])
AC_SUBST([WINECONSOLE])])
