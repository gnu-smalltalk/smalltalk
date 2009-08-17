gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

moduleexec_LTLIBRARIES = zlib.la
zlib_la_SOURCES = zlib.c
zlib_la_LIBADD = -lz
zlib_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src 
