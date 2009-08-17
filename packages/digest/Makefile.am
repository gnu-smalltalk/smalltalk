gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

moduleexec_LTLIBRARIES = digest.la
noinst_HEADERS = md5.h sha1.h
digest_la_SOURCES = digest.c md5.c sha1.c
digest_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src 
