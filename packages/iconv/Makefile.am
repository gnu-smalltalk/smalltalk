moduleexec_LTLIBRARIES = iconv.la

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

iconv_la_LDFLAGS = $(gst_module_ldflags)
iconv_la_LIBADD = $(LTLIBICONV)
iconv_la_SOURCES = iconv.c

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src
