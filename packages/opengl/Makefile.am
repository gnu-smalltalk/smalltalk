gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION)  -module \
	-no-undefined -export-symbols-regex gst_initModule

moduleexec_LTLIBRARIES = gstopengl.la
gstopengl_la_SOURCES = gstopengl.c gstGl.c gstGlu.c gstGluNurbs.c gstGluTess.c
noinst_HEADERS = gstopengl.h

gstopengl_la_LIBADD = $(LIBOPENGL) -lm
gstopengl_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
