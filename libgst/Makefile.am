LIBTOOL += --tag LIBGST

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

LEX_OUTPUT_ROOT = lex.yy
## CFLAGS=-O0 -g
AM_LFLAGS = -Cfe -o$(LEX_OUTPUT_ROOT).c
AM_YFLAGS = -vy
AM_CPPFLAGS = -DKERNEL_PATH=\"$(pkgdatadir)/kernel\" \
  -DIMAGE_PATH=\"$(pkgdatadir)\" -DMODULE_PATH=\"$(pkglibdir)\" \
  -I$(top_srcdir)/lib-src -I$(top_srcdir)/libffi/include \
  -I$(top_builddir)/libffi/include $(INCLIGHTNING) \
  @INCSNPRINTFV@ $(INCSIGSEGV) -I$(top_builddir)/lib-src

include_HEADERS = gstpub.h gst.h
noinst_PROGRAMS = genprims genbc genvm
lib_LTLIBRARIES = libgst.la

# definitions for libgst.la

libgst_la_LIBADD=$(top_builddir)/lib-src/library.la \
	$(top_builddir)/libffi/libffi.la $(LIBSIGSEGV) \
	@LIBSNPRINTFV@ @LIBREADLINE@ @LIBGMP@

libgst_la_LDFLAGS = -version-info $(VERSION_INFO) -no-undefined \
	-export-symbols-regex "^gst_.*"

libgst_la_DEPENDENCIES=$(top_builddir)/lib-src/library.la \
	$(top_builddir)/libffi/libffi.la $(LIBSIGSEGV) \
	@LIBLTDL@ @LIBSNPRINTFV@

libgst_la_SOURCES = \
       interp.c    lib.c         gst-parse.y    lex.c        \
       str.c       tree.c        byte.c         comp.c       \
       sym.c       dict.c        oop.c  	opt.c        \
       save.c      cint.c    	 heap.c	        input.c      \
       sysdep.c    callin.c      xlat.c         events.c     \
       mpz.c       print.c	 alloc.c	security.c

# definitions for genprims

genprims_SOURCES = \
       genpr-parse.y genpr-scan.l

genprims_LDADD = @LIBSNPRINTFV@ $(top_builddir)/lib-src/library.la

# definitions for genbc

genbc_SOURCES = \
       genbc-decl.y genbc-impl.y genbc-scan.l genbc.c

genbc_LDADD = @LIBSNPRINTFV@ $(top_builddir)/lib-src/library.la

# definitions for genvm

genvm_SOURCES = \
       genvm-parse.y genvm-scan.l

genvm_LDADD = @LIBSNPRINTFV@ $(top_builddir)/lib-src/library.la

# other definitions

gst-parse.h: gst-parse.c
	@:

genpr-parse.h: genpr-parse.c
	@:

BUILT_SOURCES = prims.inl match.h builtins.inl vm.inl
CLEANFILES = prims.inl prims.stamp match.h match.stamp vm.inl vm.stamp
dist_noinst_DATA = valgrind.supp prims.def byte.def vm.def builtins.gperf

nodist_noinst_HEADERS = \
	prims.inl match.h vm.inl

noinst_HEADERS = \
       gstpriv.h lib.h lex.h str.h \
       tree.h byte.h interp.h comp.h memzero.h \
       sym.h dict.h oop.h save.h cint.h xlat.h \
       sysdep.h callin.h gstpub.h opt.h mpz.h \
       md-config.h heap.h jitpriv.h oop.inl \
       dict.inl interp.inl interp-bc.inl \
       interp-jit.inl comp.inl input.h events.h \
       print.h alloc.h genprims.h gst-parse.h \
       genpr-parse.h genbc.h genbc-decl.h \
       genbc-impl.h genvm-parse.h genvm.h \
       security.h builtins.inl \
       superop1.inl superop2.inl

# rules for invoking genbc
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of match.h

match.h: match.stamp
	@:

match.stamp: byte.def byte.c opt.c xlat.c genbc$(EXEEXT)
	@echo "./genbc $(srcdir)/byte.def $(srcdir)/byte.c $(srcdir)/opt.c $(srcdir)/xlat.c > match.h"; \
	  ./genbc $(srcdir)/byte.def $(srcdir)/byte.c $(srcdir)/opt.c $(srcdir)/xlat.c > _match.h
	@if cmp _match.h match.h > /dev/null 2>&1; then \
	  echo match.h is unchanged; \
	  rm _match.h; \
	else \
	  mv _match.h match.h; \
	fi
	@echo timestamp > match.stamp


# rules for invoking genprims
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of prims.inl

prims.inl: prims.stamp
	@:

prims.stamp: prims.def genprims$(EXEEXT)
	@echo "./genprims < $(srcdir)/prims.def > prims.inl"; \
	  ./genprims < $(srcdir)/prims.def > _prims.inl
	@if cmp _prims.inl prims.inl > /dev/null 2>&1; then \
	  echo prims.inl is unchanged; \
	  rm _prims.inl; \
	else \
	  mv _prims.inl prims.inl; \
	fi
	@echo timestamp > prims.stamp

# rules for invoking genvm
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of vm.inl

vm.inl: vm.stamp
	@:

vm.stamp: vm.def genvm$(EXEEXT)
	@echo "./genvm < $(srcdir)/vm.def | awk '{ /^#/ && gsub(/__oline__/,NR+1); print }' > vm.inl"; \
	  ./genvm < $(srcdir)/vm.def | awk '{ /^#/ && gsub(/__oline__/,NR+1); print }' > _vm.inl
	@if cmp _vm.inl vm.inl > /dev/null 2>&1; then \
	  echo vm.inl is unchanged; \
	  rm _vm.inl; \
	else \
	  mv _vm.inl vm.inl; \
	fi
	@echo timestamp > vm.stamp

# rules for invoking gperf
# not fully idiot-proof but only to be run by maintainers

.gperf.inl:
	@opts="$< `sed -ne /.*gperf/!d -e s///p -e q $< | \
	    sed 's,$$(srcdir),$(srcdir),g'`"; \
	  echo $(GPERF) $$opts " > $@"; \
	  for i in a b c d e f g h j; do \
	    if test $$i = j; then \
	      eval $(GPERF) $$opts > $@ && break; \
	    else \
	      eval $(GPERF) $$opts > $@ 2>/dev/null && break; \
	      echo Retrying...; sleep 1; \
	    fi; \
	  done

builtins.inl: builtins.gperf
