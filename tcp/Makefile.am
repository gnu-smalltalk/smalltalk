pkglib_LTLIBRARIES = @MODULES_TCP@
EXTRA_LTLIBRARIES = tcp.la

gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

tcp_la_SOURCES = tcp.c
tcp_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
