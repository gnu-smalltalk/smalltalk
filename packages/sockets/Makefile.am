module_LTLIBRARIES = sockets.la

gst_module_ldflags = -rpath $(moduledir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

sockets_la_SOURCES = sockets.c
sockets_la_LIBADD = ../../lib-src/library.la $(SOCKET_LIBS)
sockets_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
