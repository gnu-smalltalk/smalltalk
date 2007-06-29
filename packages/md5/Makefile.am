gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

pkglib_LTLIBRARIES = md5.la
md5_la_SOURCES = md5.c
md5_la_LIBADD = ../../lib-src/library.la
md5_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src 
