gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION)  -module \
	-no-undefined -export-symbols-regex gst_initModule

moduleexec_LTLIBRARIES = gstglut.la
gstglut_la_SOURCES = gstGlut.c
gstglut_la_LIBADD = $(LIBGLUT) -lm
gstglut_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
