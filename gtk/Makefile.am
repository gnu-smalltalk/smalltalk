CLEANFILES = $(nodist_noinst_SCRIPTS) $(nodist_noinst_HEADERS) \
	$(BUILT_SOURCES) $(nodist_noinst_DATA) .order

EXTRA_DIST = cpp.awk structs.awk funcs.awk mk_enums.awk mk_sizeof.awk order.st

gst_module_ldflags = -rpath $(pkglibdir) -release $(VERSION) -module \
	-no-undefined # -export-symbols-regex gst_initModule

ALL_LIBS = $(GLIB_LIBS) $(GTK_LIBS) $(PANGO_LIBS) $(ATK_LIBS)

EXTRA_LTLIBRARIES = gst-gtk.la
pkglib_LTLIBRARIES = @MODULES_GTK@
gst_gtk_la_LDFLAGS = $(gst_module_ldflags)
gst_gtk_la_LIBADD = $(ALL_LIBS)
dist_gst_gtk_la_SOURCES = gst-gtk.c placer.c
dist_noinst_HEADERS = gst-gtk.h placer.h

EXTRA_PROGRAMS = testplacer sizeof enums
testplacer_SOURCES = testplacer.c
testplacer_LDADD = $(GLIB_LIBS) $(GTK_LIBS)


INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src -I$(top_srcdir)/libltdl

AM_CFLAGS = $(GLIB_CFLAGS) $(GTK_CFLAGS) $(PANGO_CFLAGS) $(ATK_CFLAGS)

GTK_FILES = \
	  glib-object.h gdk/gdk.h \
	  gdk-pixbuf/gdk-pixbuf.h gtk/gtk.h atk/atk.h pango/pango.h

LOCAL_FILES = $(srcdir)/placer.h

if HAVE_GTK

nodist_noinst_DATA = Structs.st Funcs.st Enums.st Libs.st
nodist_noinst_SCRIPTS = cpp structs funcs mk_sizeof mk_enums

noinst_PROGRAMS = enums sizeof
nodist_enums_SOURCES = enums.c
nodist_sizeof_SOURCES = sizeof.c
BUILT_SOURCES = enums.c sizeof.c

# Rules to build the bindings from the GTK+ header files follow...

%: %.awk
	@case "$(AWK)" in \
	  */*) AWK="$(AWK)" ;; \
	  *) \
	    IFS=":"; \
	    for i in $$PATH; do \
	      test -f $$i/$(AWK) && AWK="$$i/$(AWK)" && break; \
	    done ;; \
	esac; \
	echo "sed -e \"1s,@AWK\@,$$AWK,\" < $< > $@"; \
	sed -e "1s,@AWK\@,$$AWK," < $< > $@
	chmod +x $@

cpp: $(srcdir)/cpp.awk
structs: $(srcdir)/structs.awk
funcs: $(srcdir)/funcs.awk
mk_enums: $(srcdir)/mk_enums.awk
mk_sizeof: $(srcdir)/mk_sizeof.awk

# -------------------------------------

Libs.st: Makefile
	echo '"Automatically generated file, do not edit!"' > Libs.st; \
	for i in $(ALL_LIBS); do \
	  case $$i in \
	    -lg*|-latk*|-lpango*) echo "DLD addLibrary: 'lib$$i'!" | sed 's/-l//' >> Libs.st ;; \
	    *) ;; \
	  esac; \
	done

Structs.st: structs sizeof$(EXEEXT) cpp .order
	xargs ./cpp < .order | ./structs > Structs.st
	./sizeof >> Structs.st

Enums.st: enums$(EXEEXT)
	./enums > Enums.st

Funcs.st: funcs cpp .order
	xargs ./cpp < .order | ./funcs > Funcs.st

sizeof.c: mk_sizeof cpp .order
	xargs ./cpp < .order | ./mk_sizeof > sizeof.c

enums.c: mk_enums cpp .order
	xargs ./cpp < .order | ./mk_enums > enums.c

.order: order.st Makefile $(LOCAL_FILES)
	PKG_CONFIG='$(PKG_CONFIG)' ../gst \
	  -I ../gst.im $(srcdir)/order.st -a \
	  `$(PKG_CONFIG) --cflags-only-I gobject-2.0` \
	  `$(PKG_CONFIG) --cflags-only-I gdk-2.0` \
	  `$(PKG_CONFIG) --cflags-only-I gdk-pixbuf-2.0` \
	  `$(PKG_CONFIG) --cflags-only-I pango` \
	  `$(PKG_CONFIG) --cflags-only-I gtk+-2.0` \
	  `$(PKG_CONFIG) --cflags-only-I atk` \
	  $(GTK_FILES) \
	  $(LOCAL_FILES) | sed -e '/gobject/b' -e '/glib/d' > .order
endif   # HAVE_GTK

dist-hook:
	for i in $(CLEANFILES); do rm -f $(distdir)/$$i; done
