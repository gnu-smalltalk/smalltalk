dist_noinst_DATA = valgrind.supp prims.def

if HAVE_INSTALLED_LIGHTNING
INCLIGHTNING = 
else
INCLIGHTNING = -I$(top_srcdir)/lightning -I$(top_builddir)/lightning
endif

if HAVE_SIGSEGV
INCSIGSEGV = -I$(top_srcdir)/sigsegv/src -I$(top_builddir)/sigsegv/src
LIBSIGSEGV = $(top_builddir)/sigsegv/src/libsigsegv.la
else
INCSIGSEGV = 
LIBSIGSEGV =
endif

# This switch is not included in libtool 1.4, but it is included in
# libtool 1.5; I have plugged it back in libtool 1.4, so that it is
# upwards compatible.
LIBTOOL = @LIBTOOL@ --tag disable-shared

LEX_OUTPUT_ROOT = lex.yy
## CFLAGS=-O0 -g
AM_LFLAGS = -Cfe -o$(LEX_OUTPUT_ROOT).c
AM_YFLAGS = -vy
AM_CPPFLAGS = -DKERNEL_PATH=\"$(pkgdatadir)/kernel\" -Wall \
  -DIMAGE_PATH=\"$(pkgdatadir)\" -DMODULE_PATH=\"$(pkglibdir)\"

INCLUDES = -I$(top_srcdir)/lib-src $(INCLIGHTNING) \
	@INCLTDL@ @INCSNPRINTFV@ $(INCSIGSEGV)

include_HEADERS = gstpub.h gst.h
noinst_PROGRAMS = genprims
lib_LTLIBRARIES = libgst.la

# definitions for libgst.la

libgst_la_LIBADD=$(top_builddir)/lib-src/library.la $(LIBSIGSEGV) \
	@LIBLTDL@ @LIBSNPRINTFV@ @LIBREADLINE@ @LIBGMP@

libgst_la_LDFLAGS = -version-info $(VERSION_INFO)
libgst_la_DEPENDENCIES=$(top_builddir)/lib-src/library.la $(LIBSIGSEGV) \
	@LIBLTDL@ @LIBSNPRINTFV@

libgst_la_SOURCES = \
       interp.c    lib.c         gst-parse.y    lex.c        \
       str.c       tree.c        byte.c         comp.c       \
       sym.c       dict.c        oop.c  	opt.c        \
       save.c      cint.c    	 heap.c	        input.c      \
       sysdep.c    callin.c      xlat.c         events.c     \
       mpz.c       print.c	 alloc.c

# definitions for genprims

genprims_SOURCES = \
       genpr-parse.y genpr-scan.l

genprims_LDADD = @LIBSNPRINTFV@

# other definitions

gst-parse.h: gst-parse.c
	@:

genpr-parse.h: genpr-parse.c
	@:

BUILT_SOURCES = prims.inl

nodist_noinst_HEADERS = \
	prims.inl

noinst_HEADERS = \
       gstpriv.h lib.h lex.h str.h \
       tree.h byte.h interp.h comp.h memzero.h \
       sym.h dict.h oop.h save.h cint.h xlat.h \
       sysdep.h callin.h gstpub.h opt.h mpz.h \
       md-config.h heap.h jitpriv.h oop.inl \
       dict.inl interp.inl interp-bc.inl \
       interp-jit.inl comp.inl input.h events.h \
       print.h alloc.h genprims.h gst-parse.h \
       genpr-parse.h

# rules for invoking genprims
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of prims.inl

CLEANFILES = prims.inl prims.stamp

prims.inl: prims.stamp
	@:

prims.stamp: $(srcdir)/prims.def genprims$(EXEEXT)
	./genprims < $(srcdir)/prims.def > _prims.inl
	@if cmp _prims.inl prims.inl > /dev/null 2>&1; then \
	  echo prims.inl is unchanged; \
	  rm _prims.inl; \
	else \
	  mv _prims.inl prims.inl; \
	fi
	@echo timestamp > prims.stamp

