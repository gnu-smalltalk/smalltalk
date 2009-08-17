moduleexec_LTLIBRARIES = blox-tk.la

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

blox_tk_la_SOURCES = BloxTK.c
blox_tk_la_LIBADD = @LIBTCLTK@ $(top_builddir)/lib-src/library.la
blox_tk_la_LDFLAGS = $(gst_module_ldflags)

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src @INCTCLTK@

noinst_HEADERS = rgbtab.h
