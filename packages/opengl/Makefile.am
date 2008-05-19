gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION)  -module \
	-no-undefined -export-symbols-regex gst_initModule

pkglib_LTLIBRARIES = gstopengl.la
gstopengl_la_SOURCES = gstopengl.c gstGl.c gstGlu.c

gstopengl_la_LIBADD = $(LIBOPENGL) -lm
gstopengl_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
