moduleexec_LTLIBRARIES = expat.la

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

expat_la_SOURCES = expat.c
expat_la_LIBADD = -lexpat
expat_la_LDFLAGS = $(gst_module_ldflags)

