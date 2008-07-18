dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_SOCKETS], [

AC_SEARCH_LIBS(listen, socket, [], [
    dnl Check for listen on MinGW. We need to include <winsock2.h>
    dnl to get the correct __stdcall name decoration
    AC_MSG_CHECKING([For listen in -lws2_32])
    OLD_LIBS="$LIBS"
    LIBS="-lws2_32 $LIBS"
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <winsock2.h>]],[[listen(0,0);]])],
                   [ac_cv_lib_ws2_32_listen=yes
                    AC_MSG_RESULT(yes)],
                   [LIBS="$OLD_LIBS"
                    AC_MSG_RESULT(no)])])
AC_SEARCH_LIBS(gethostbyname, nsl)

gst_cv_sockets=yes
AC_CHECK_FUNC(socket, , gst_cv_sockets=no)
AC_CHECK_HEADERS(arpa/inet.h netdb.h netinet/in.h, , gst_cv_sockets=no)
AC_CHECK_DECLS([getaddrinfo, freeaddrinfo, gai_strerror, getnameinfo], [], [],
	       [#include <netdb.h>])
AC_CHECK_MEMBER([struct addrinfo.ai_family],
		[AC_DEFINE(HAVE_STRUCT_ADDRINFO, 1,
			   [Define if your system's netdb.h has struct addrinfo])], [],
	        [#include <netdb.h>])

if test "$ac_cv_lib_ws2_32_listen" = "yes"; then
    gst_cv_sockets=yes
fi
if test $gst_cv_sockets = yes; then
  GST_SOCKET_FAMILIES
  AC_CHECK_FUNCS(getipnodebyaddr)
  AC_REPLACE_FUNCS(getaddrinfo inet_ntop)
  AC_DEFINE(HAVE_SOCKETS, 1, [Define if your system has sockets.])
fi

])dnl
