examplemodulesdir = $(pkgdatadir)/examples/modules

dist_examplemodules_DATA = gdbm.st gdbm-c.st regex.st md5.st

EXTRA_LTLIBRARIES = gdbm.la regex.la
pkglib_LTLIBRARIES = @MODULES_EXAMPLE@ md5.la

noinst_HEADERS = regex.h

gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

gdbm_la_SOURCES = gdbm.c
gdbm_la_LIBADD = -lgdbm
gdbm_la_LDFLAGS = $(gst_module_ldflags)

regex_la_SOURCES = regex.c re.c
regex_la_LIBADD = ../lib-src/library.la @LIBSNPRINTFV@
regex_la_LDFLAGS = $(gst_module_ldflags)

md5_la_SOURCES = md5.c
md5_la_LIBADD = ../lib-src/library.la
md5_la_LDFLAGS = $(gst_module_ldflags)

INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src @INCSNPRINTFV@
