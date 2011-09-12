LEX_OUTPUT_ROOT = lex.yy
## CFLAGS=-O0 -g
AM_CFLAGS = $(LIBGST_CFLAGS)
AM_LFLAGS = -Cfe -o$(LEX_OUTPUT_ROOT).c
AM_YFLAGS = -vy
AM_CPPFLAGS = $(RELOC_CPPFLAGS) \
  -I$(top_srcdir)/lib-src -I$(top_builddir)/lib-src \
  $(INCFFI) $(INCLIGHTNING) $(INCSNPRINTFV) $(INCSIGSEGV) $(INCLTDL)

if !HAVE_INSTALLED_LIGHTNING
AM_CPPFLAGS += -I$(top_srcdir)/lightning -I$(top_builddir)/lightning \
  -I$(top_srcdir) -I$(top_builddir)
endif

include_HEADERS = gstpub.h gst.h
lib_LTLIBRARIES = libgst.la
EXTRA_PROGRAMS = genprims genbc genvm
CLEANFILES = genprims$(EXEEXT) genbc$(EXEEXT) genvm$(EXEEXT) \
  genbc-decl.stamp genbc-impl.stamp genpr-parse.stamp genvm-parse.stamp

# definitions for libgst.la

libgst_la_LIBADD=$(top_builddir)/lib-src/library.la \
	$(LIBSIGSEGV) $(LIBFFI) $(LIBSNPRINTFV) $(LIBREADLINE) $(LIBLTDL) \
	$(LIBGMP) $(LIBTHREAD)

libgst_la_DEPENDENCIES=$(top_builddir)/lib-src/library.la $(LIBSNPRINTFV)

libgst_la_LDFLAGS = -version-info $(VERSION_INFO) -no-undefined \
	-export-symbols-regex "^gst_.*" -bindir $(bindir)

libgst_la_SOURCES = \
       gstpub.c    files.c       gst-parse.c    lex.c        \
       str.c       tree.c        byte.c         comp.c       \
       sym.c       dict.c        oop.c  	opt.c        \
       save.c      cint.c    	 heap.c	        input.c      \
       sysdep.c    callin.c      xlat.c         mpz.c        \
       print.c	   alloc.c	 security.c     re.c	     \
       interp.c    real.c	 sockets.c	events.c

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

# manually give dependencies involving BUILT_SOURCES.  The input .l/.y files
# change rarely, so do not bother changing the timestamp file only if the
# output changed.

genbc-decl.stamp: genbc-decl.c genbc-decl.y; echo stamp > $@
genbc-impl.stamp: genbc-impl.c genbc-impl.y; echo stamp > $@
genpr-parse.stamp: genpr-parse.c genpr-parse.y; echo stamp > $@
genvm-parse.stamp: genvm-parse.c genvm-parse.y; echo stamp > $@

genbc.o: genbc-decl.stamp genbc-impl.stamp
genbc-scan.o: genbc-decl.stamp genbc-impl.stamp
genbc-decl.o: genbc-decl.stamp genbc-impl.stamp
genbc-impl.o: genbc-decl.stamp genbc-impl.stamp
genpr-scan.o: genpr-parse.stamp
genvm-scan.o: genvm-parse.stamp

BUILT_SOURCES = prims.inl match.h builtins.inl vm.inl \
	genbc-decl.c genbc-impl.c genbc-scan.c genbc-decl.h genbc-impl.h \
	genpr-parse.c genpr-scan.c genpr-parse.h \
	genvm-parse.c genvm-scan.c genvm-parse.h

dist_noinst_DATA = valgrind.supp prims.def byte.def vm.def builtins.gperf
STAMP_FILES = prims.stamp match.stamp vm.stamp

noinst_HEADERS = \
	gstpriv.h files.h lex.h str.h re.h \
	tree.h byte.h interp.h comp.h \
	sym.h dict.h oop.h save.h cint.h xlat.h \
	sysdep.h callin.h gstpub.h opt.h mpz.h \
	md-config.h heap.h real.h jitpriv.h oop.inl \
	dict.inl interp.inl interp-bc.inl interp-jit.inl \
	sockets.h comp.inl input.h events.h \
	print.h alloc.h genprims.h gst-parse.h \
	genpr-parse.h genbc.h genbc-decl.h \
	genbc-impl.h genvm-parse.h genvm.h \
	security.h superop1.inl superop2.inl \
	sysdep/common/files.c sysdep/common/time.c sysdep/cygwin/files.c \
	sysdep/cygwin/findexec.c sysdep/cygwin/mem.c sysdep/cygwin/signals.c \
	sysdep/cygwin/time.c sysdep/cygwin/timer.c sysdep/posix/files.c \
	sysdep/posix/findexec.c sysdep/posix/mem.c sysdep/posix/signals.c \
	sysdep/posix/time.c sysdep/posix/timer.c sysdep/win32/files.c \
	sysdep/win32/findexec.c sysdep/win32/mem.c sysdep/win32/signals.c \
	sysdep/win32/time.c sysdep/win32/timer.c sysdep/posix/events.c \
	sysdep/win32/events.c sysdep/cygwin/events.c \
	$(BUILT_SOURCES)

# rules for invoking genbc
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of match.h

$(srcdir)/match.h: $(srcdir)/match.stamp
	@:

$(srcdir)/match.stamp: byte.def byte.c opt.c xlat.c
	@$(MAKE) genbc$(EXEEXT)
	@echo "./genbc$(EXEEXT) $(srcdir)/byte.def $(srcdir)/byte.c $(srcdir)/opt.c $(srcdir)/xlat.c > match.h"; \
	  ./genbc$(EXEEXT) $(srcdir)/byte.def $(srcdir)/byte.c $(srcdir)/opt.c $(srcdir)/xlat.c > _match.h
	@if cmp _match.h $(srcdir)/match.h > /dev/null 2>&1; then \
	  echo match.h is unchanged; \
	  rm _match.h; \
	else \
	  mv _match.h $(srcdir)/match.h; \
	fi
	@echo timestamp > $(srcdir)/match.stamp


# rules for invoking genprims
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of prims.inl

$(srcdir)/prims.inl: $(srcdir)/prims.stamp
	@:

$(srcdir)/prims.stamp: prims.def
	@$(MAKE) genprims$(EXEEXT)
	@echo "./genprims$(EXEEXT) < $(srcdir)/prims.def > prims.inl"; \
	  ./genprims$(EXEEXT) < $(srcdir)/prims.def > _prims.inl
	@if cmp _prims.inl $(srcdir)/prims.inl > /dev/null 2>&1; then \
	  echo prims.inl is unchanged; \
	  rm _prims.inl; \
	else \
	  mv _prims.inl $(srcdir)/prims.inl; \
	fi
	@echo timestamp > $(srcdir)/prims.stamp

# rules for invoking genvm
# Try to economize in the rebuilds, by avoiding unnecessary
# changes to the timestamp of vm.inl

$(srcdir)/vm.inl: $(srcdir)/vm.stamp
	@:

$(srcdir)/vm.stamp: vm.def
	@$(MAKE) genvm$(EXEEXT)
	@echo "./genvm$(EXEEXT) < $(srcdir)/vm.def | awk '{ /^#/ && gsub(/__oline__/,NR+1); print }' > vm.inl"; \
	  ./genvm$(EXEEXT) < $(srcdir)/vm.def | awk '{ /^#/ && gsub(/__oline__/,NR+1); print }' > _vm.inl
	@if cmp _vm.inl $(srcdir)/vm.inl > /dev/null 2>&1; then \
	  echo vm.inl is unchanged; \
	  rm _vm.inl; \
	else \
	  mv _vm.inl $(srcdir)/vm.inl; \
	fi
	@echo timestamp > $(srcdir)/vm.stamp

# rules for invoking gperf
# not fully idiot-proof but only to be run by maintainers

.gperf.inl:
	@opts="$< `$(SED) -ne /.*gperf/!d -e s///p -e q $< | \
	    $(SED) 's,$$(srcdir),$(srcdir),g'`"; \
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

dist-hook:
	for i in $(STAMP_FILES); do \
	  echo timestamp > $(distdir)/$$i; \
	done

