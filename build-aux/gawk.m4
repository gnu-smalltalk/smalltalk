AC_DEFUN([GST_PROG_GAWK],
[AC_BEFORE([$0], [AC_PROG_AWK])dnl
AC_CHECK_PROGS(AWK, gawk awk, )
case $AWK in
  *gawk) ;;
  *) case `"$AWK" --version 2>&1` in
       *GNU*) ;;
       *) AC_MSG_ERROR([Building GNU Smalltalk requires GNU awk.]) ;;
     esac ;;
esac])
