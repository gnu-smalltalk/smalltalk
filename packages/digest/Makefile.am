gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

pkglib_LTLIBRARIES = digest.la
digest_la_SOURCES = digest.c
digest_la_LIBADD = ../../lib-src/library.la
digest_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src 
