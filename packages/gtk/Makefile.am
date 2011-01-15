CLEANFILES = $(nodist_noinst_SCRIPTS) $(nodist_noinst_HEADERS) \
	$(BUILT_SOURCES) $(nodist_noinst_DATA) order

LC_UNSET = LANG=C; export LANG; \
	LC_COLLATE=C; export LC_COLLATE; \
	LC_CTYPE=C; export LC_CTYPE; \
	LC_MESSAGES=C; export LC_MESSAGES; \
	LC_MONETARY=C; export LC_MONETARY; \
	LC_NUMERIC=C; export LC_NUMERIC; \
	LC_TIME=C; export LC_TIME

EXTRA_DIST = cpp.awk structs.awk funcs.awk mk_enums.awk mk_sizeof.awk mkorder.awk

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

ALL_LIBS = $(GLIB_LIBS) $(GTK_LIBS) $(PANGO_LIBS) $(ATK_LIBS) $(GTHREAD_LIBS) \
	$(CAIRO_LIBS)

moduleexec_LTLIBRARIES = gst-gtk.la
gst_gtk_la_LDFLAGS = $(gst_module_ldflags)
gst_gtk_la_LIBADD = $(ALL_LIBS) ../glib/libgst-gobject.la
dist_gst_gtk_la_SOURCES = gst-gtk.c placer.c
nodist_gst_gtk_la_SOURCES = libs.def
BUILT_SOURCES = libs.def
dist_noinst_HEADERS = placer.h

EXTRA_PROGRAMS = testplacer sizeof enums
testplacer_SOURCES = testplacer.c
testplacer_LDADD = $(GLIB_LIBS) $(GTK_LIBS)


INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src -I$(top_srcdir)/libltdl -I$(top_srcdir)/packages/glib

AM_CFLAGS = $(GLIB_CFLAGS) $(GTK_CFLAGS) $(PANGO_CFLAGS) $(ATK_CFLAGS)

GTK_FILES = \
	  glib-object.h gdk/gdk.h \
	  gdk-pixbuf/gdk-pixbuf.h gtk/gtk.h atk/atk.h pango/pango.h

LOCAL_FILES = $(srcdir)/placer.h

nodist_noinst_DATA = Structs.st Funcs.st Enums.st
nodist_noinst_SCRIPTS = cpp structs funcs mk_sizeof mk_enums

noinst_PROGRAMS = enums sizeof
nodist_enums_SOURCES = enums.c
nodist_sizeof_SOURCES = sizeof.c
BUILT_SOURCES += enums.c sizeof.c

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
	echo "$(SED) -e \"1s,@AWK\@,$$AWK,\" < $< > $@"; \
	$(SED) -e "1s,@AWK\@,$$AWK," < $< > $@
	chmod +x $@

cpp: $(srcdir)/cpp.awk
structs: $(srcdir)/structs.awk
funcs: $(srcdir)/funcs.awk
mk_enums: $(srcdir)/mk_enums.awk
mk_sizeof: $(srcdir)/mk_sizeof.awk

# -------------------------------------

libs.def: Makefile
	for i in $(ALL_LIBS); do \
	  case $$i in \
	    -L*) \
	      j=`echo $$i | sed 's,^-L,,'` ; \
	      echo "_gtk_vm_proxy->dlAddSearchDir(\"$$j\");" ;; \
	    -lG*|-lg*|-lATK*|-latk*|-lPango*|-lpango*) \
	      j=`echo $$i | sed 's,^-l,lib,'` ; \
	      echo "_gtk_vm_proxy->dlOpen(\"$$j\", false);" ;; \
	    *) ;; \
	  esac; \
	done | sort -u > libs.def

Structs.st: structs sizeof$(EXEEXT) cpp order
	$(LC_UNSET); xargs ./cpp < order | ./structs > Structs.st
	$(LC_UNSET); ./sizeof$(EXEEXT) >> Structs.st

Enums.st: enums$(EXEEXT)
	$(LC_UNSET); ./enums$(EXEEXT) > Enums.st

Funcs.st: funcs cpp order
	$(LC_UNSET); xargs ./cpp < order | ./funcs > Funcs.st

sizeof.c: mk_sizeof cpp order
	$(LC_UNSET); xargs ./cpp < order | ./mk_sizeof > sizeof.c

enums.c: mk_enums cpp order
	$(LC_UNSET); xargs ./cpp < order | ./mk_enums > enums.c

order: mkorder.awk Makefile $(LOCAL_FILES)
	$(AWK) \
	  -vPKG_CONFIG='$(PKG_CONFIG)' \
	  -v_prefixes='g atk pango' \
	  -v_libs="gobject-2.0 gdk-2.0 gdk-pixbuf-2.0 pango gtk+-2.0 atk" \
	  -v_files="$(GTK_FILES) $(LOCAL_FILES)" -f $(srcdir)/mkorder.awk \
	  | while read i; do \
	    case "$$i" in \
	      error:*) \
	        echo "$$i" >&2; exit 1;; \
	      */gobject/*) \
	        echo "$$i" ;; \
	      */glib/*) \
		;; \
	      *) \
		echo "$$i" ;; \
	    esac; \
	  done > order
