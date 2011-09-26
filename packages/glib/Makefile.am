CLEANFILES = $(BUILT_SOURCES)

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

ALL_LIBS = $(GLIB_LIBS) $(GTHREAD_LIBS)

include_HEADERS = gst-gobject.h
lib_LTLIBRARIES = libgst-gobject.la
libgst_gobject_la_SOURCES = gst-gobject.c
libgst_gobject_la_LDFLAGS = -version-info 1:0:0 -no-undefined -bindir $(bindir)
libgst_gobject_la_LIBADD = $(ALL_LIBS) ../../libgst/libgst.la

moduleexec_LTLIBRARIES = gst-glib.la
gst_glib_la_LDFLAGS = $(gst_module_ldflags)
gst_glib_la_LIBADD = $(ALL_LIBS) libgst-gobject.la ../../lib-src/library.la 
gst_glib_la_DEPENDENCIES = libgst-gobject.la
dist_gst_glib_la_SOURCES = gst-glib.c
nodist_gst_glib_la_SOURCES = libs.def
BUILT_SOURCES = libs.def

# Work around bug in Automake (or is it Libtool?)  The gst-glib library is
# installed before libgst-gobject has been relinked.
.NOTPARALLEL:

INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src -I$(top_srcdir)/libltdl

AM_CFLAGS = $(GLIB_CFLAGS) $(GTHREAD_CFLAGS)

# -------------------------------------

libs.def: Makefile
	for i in $(ALL_LIBS); do \
	  case $$i in \
	    -L*) \
	      j=`echo $$i | sed 's,^-L,,'` ; \
	      echo "_glib_vm_proxy->dlAddSearchDir(\"$$j\");" ;; \
	    -lG*|-lg*) \
	      j=`echo $$i | sed 's,^-l,lib,'` ; \
	      echo "_glib_vm_proxy->dlOpen(\"$$j\", false);" ;; \
	    *) ;; \
	  esac; \
	done | sort -u > libs.def
