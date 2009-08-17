moduleexec_LTLIBRARIES = dbd-sqlite3.la

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

dbd_sqlite3_la_SOURCES = sqlite3.c
dbd_sqlite3_la_LIBADD = -lsqlite3
dbd_sqlite3_la_LDFLAGS = $(gst_module_ldflags)

