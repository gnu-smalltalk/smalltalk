examplemodulesdir = $(pkgdatadir)/examples/modules

dist_examplemodules_DATA = gdbm.st gdbm-c.st md5.st zlib.st

EXTRA_LTLIBRARIES = gdbm.la zlib.la
pkglib_LTLIBRARIES = @MODULES_EXAMPLE@ md5.la

gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

gdbm_la_SOURCES = gdbm.c
gdbm_la_LIBADD = -lgdbm
gdbm_la_LDFLAGS = $(gst_module_ldflags)

md5_la_SOURCES = md5.c
md5_la_LIBADD = ../lib-src/library.la
md5_la_LDFLAGS = $(gst_module_ldflags)

zlib_la_SOURCES = zlib.c
zlib_la_LIBADD = -lz
zlib_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src @INCSNPRINTFV@
