tcpdir = $(pkgdatadir)/tcp


dist_noinst_DATA = stamp-classes

stamp-classes: \
SocketAddress.st       Datagram.st      AbstractSocketImpl.st\
IPSocketImpl.st        Sockets.st       Tests.st\
init.st                cfuncs.st        TCP.st\
Buffers.st
	@echo Updating $@
	@sed -n "s/.*'\([^']*\.st\)'.*/\1/p" $(srcdir)/TCP.st>$@

EXTRA_LTLIBRARIES = tcp.la
pkglib_LTLIBRARIES = @MODULES_TCP@

gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

tcp_la_SOURCES = tcp.c
tcp_la_LDFLAGS = $(gst_module_ldflags)

INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
