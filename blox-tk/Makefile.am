
dist_noinst_DATA = stamp-classes

stamp-classes: Blox.st BloxBasic.st BloxCanvas.st BloxExtend.st \
BloxText.st BloxWidgets.st
	@echo Updating $@
	@sed -n "s/.*'\([^']*\.st\)'.*/\1/p" $(srcdir)/Blox.st>$@


pkglib_LTLIBRARIES = @MODULES_TK@
EXTRA_LTLIBRARIES = blox-tk.la

gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

blox_tk_la_SOURCES = BloxTK.c
blox_tk_la_LIBADD = @LIBTCLTK@ $(top_builddir)/lib-src/library.la
blox_tk_la_LDFLAGS = $(gst_module_ldflags)

INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src @INCTCLTK@

noinst_HEADERS = rgbtab.h
