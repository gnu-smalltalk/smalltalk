dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_INET_SOCKETS], [

AC_CHECK_FUNC(listen, , [
  AC_CHECK_LIB(socket, listen, , [
    AC_CHECK_LIB(wsock32, listen)
  ])
])
AC_CHECK_LIB(nsl, gethostbyname)

gst_cv_inet_sockets=yes
AC_CHECK_FUNC(socket, , gst_cv_inet_sockets=no)
AC_CHECK_HEADER(netinet/in.h, , gst_cv_inet_sockets=no)
AC_CHECK_HEADER(arpa/inet.h, , gst_cv_inet_sockets=no)
if test $gst_cv_inet_sockets = yes || test $ac_cv_lib_wsock32_socket = yes; then
  AC_DEFINE(HAVE_INET_SOCKETS, 1, [Define if your system's sockets provide access to the Internet.])
fi

])dnl
