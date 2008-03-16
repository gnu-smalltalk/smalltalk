gst_module_ldflags = -rpath $(moduledir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

module_LTLIBRARIES = gdbm.la
gdbm_la_SOURCES = gdbm.c
gdbm_la_LIBADD = -lgdbm
gdbm_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
