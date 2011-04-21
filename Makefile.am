# Copyright 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009
# Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

# Automake requirements
AUTOMAKE_OPTIONS = gnu 1.11 dist-xz
ACLOCAL_AMFLAGS = -I build-aux

PACKAGE=smalltalk
gstdatadir=$(pkgdatadir)

DIST_SUBDIRS = lib-src snprintfv lightning opcode libgst \
	. $(ALL_PACKAGES) tests doc

SUBDIRS = lib-src lightning $(subdirs)
if ENABLE_DISASSEMBLER
SUBDIRS += opcode
endif
SUBDIRS += libgst . $(BUILT_PACKAGES) doc tests

# Running gst inside the build directory...

GST_OPTS = --kernel-dir "@srcdir@/kernel" --image gst.im
GST = $(WINEWRAPPER) ./gst$(EXEEXT) --no-user-files $(GST_OPTS)
GST_PACKAGE = XZIP="$(XZIP)" $(WINEWRAPPER) ./gst-tool$(EXEEXT) gst-package $(GST_OPTS)


###########################################################
#
#        Rules for configuration files
#
###########################################################

aclocaldir = $(datadir)/aclocal
dist_aclocal_DATA = build-aux/gst.m4 build-aux/gst-package.m4
dist_noinst_DATA = Doxyfile
dist_noinst_SCRIPTS = build-aux/texi2dvi build-aux/texi2html \
	build-aux/help2man build-aux/config.rpath 

###########################################################
#
#        Rules for scripts and data files
#
###########################################################

pkgconfigdir = $(libdir)/pkgconfig
nodist_pkgconfig_DATA = gnu-smalltalk.pc

if NEED_LIBC_LA
module_DATA = libc.la
endif

noinst_DATA = gst.im
dist_noinst_DATA += smalltalk-mode-init.el.in gst-mode.el.in \
	.gdbinit scripts/Finish.st gsticon.ico packages/xml/ChangeLog \
	packages/seaside/PORTING

bin_SCRIPTS = gst-config
DISTCLEANFILES = termbold termnorm pkgrules.tmp
CLEANFILES = gst.im $(nodist_lisp_LISP) $(nodist_lispstart_LISP)

if WITH_EMACS
dist_lisp_LISP = smalltalk-mode.el
nodist_lispstart_LISP = smalltalk-mode-init.el
if WITH_EMACS_COMINT
nodist_lisp_LISP = gst-mode.el
endif
endif

if WITH_EMACS_COMINT
LISP_WITH_EMACS_COMINT =
else
LISP_WITH_EMACS_COMINT = ;
endif

smalltalk-mode-init.el: smalltalk-mode-init.el.in
	$(SED) -e "s,@\(lispdir\)@,$(lispdir)," \
	  -e "s/@\(WITH_EMACS_COMINT_TRUE\)@/$(LISP_WITH_EMACS_COMINT)/" \
	  $(srcdir)/smalltalk-mode-init.el.in > smalltalk-mode-init.el

gst-mode.el: gst-mode.el.in
	$(SED) -e "s,@\(bindir\)@,$(bindir)," $(srcdir)/gst-mode.el.in \
	  > gst-mode.el

###########################################################
#
#        Rules for building the VM
#
###########################################################

AM_CPPFLAGS = -I$(top_srcdir)/libgst		\
	-I$(top_srcdir)/lib-src			\
	-DCMD_XZIP="\"$(XZIP)\""			\
	-DCMD_INSTALL="\"$(INSTALL)\""		\
	-DCMD_LN_S="\"$(LN_S)\""		\
	$(RELOC_CPPFLAGS)

bin_PROGRAMS = gst

gst_SOURCES = main.c
gst_LDADD = libgst/libgst.la lib-src/library.la @ICON@
gst_DEPENDENCIES = libgst/libgst.la lib-src/library.la @ICON@
gst_LDFLAGS = -export-dynamic $(RELOC_LDFLAGS) $(LIBFFI_EXECUTABLE_LDFLAGS)

if ENABLE_DISASSEMBLER
gst_LDADD += opcode/libdisass.la
gst_DEPENDENCIES += opcode/libdisass.la
AM_CPPFLAGS += -I$(top_srcdir)/opcode
endif

# The single gst-tool executable is installed with multiple names, hence
# we use noinst here.
noinst_PROGRAMS = gst-tool
gst_tool_SOURCES = gst-tool.c
gst_tool_LDADD = libgst/libgst.la lib-src/library.la @ICON@
gst_tool_DEPENDENCIES = libgst/libgst.la lib-src/library.la @ICON@
gst_tool_LDFLAGS = -export-dynamic $(RELOC_LDFLAGS) $(LIBFFI_EXECUTABLE_LDFLAGS)

# Used to call the Unix zip from Wine
EXTRA_PROGRAMS = winewrapper
winewrapper_SOURCES = winewrapper.c

GST_EXTRA_TOOLS = gst-reload gst-sunit gst-blox gst-package gst-convert \
	gst-doc gst-remote gst-profile gst-browser

uninstall-local::
	@for i in gst-load $(GST_EXTRA_TOOLS); do \
	  echo rm -f "$(DESTDIR)$(bindir)/$$i$(EXEEXT)"; \
	  rm -f "$(DESTDIR)$(bindir)/$$i$(EXEEXT)"; \
	done

install-exec-hook::
	$(INSTALL_PROGRAM_ENV) $(LIBTOOL) --mode=install $(INSTALL) gst-tool$(EXEEXT) "$(DESTDIR)$(bindir)/gst-load$(EXEEXT)"
	@for i in $(GST_EXTRA_TOOLS); do \
	  echo $(LN) -f "$(DESTDIR)$(bindir)/gst-load$(EXEEXT)" "$(DESTDIR)$(bindir)/$$i$(EXEEXT)"; \
	  $(LN) -f "$(DESTDIR)$(bindir)/gst-load$(EXEEXT)" "$(DESTDIR)$(bindir)/$$i$(EXEEXT)"; \
	done

nodist_noinst_HEADERS = config.h
DISTCLEANFILES += config.h

# These two lines add a beatiful icon to the Win32 executable
gsticon.o: gsticon.ico
	cd $(srcdir) && echo ProgramIcon ICON `$(CYGPATH_W) gsticon.ico` | \
		$(WINDRES) -o $(abs_builddir)/gsticon.o

gst.im: $(bin_PROGRAMS) $(srcdir)/kernel/stamp-classes $(WINEWRAPPERDEP)
	$(GST) -iQ /dev/null


###########################################################
#
#        Rules for distributing the superops program
#
###########################################################

dist_noinst_DATA += \
	superops/ChangeLog superops/Makefile superops/README \
	superops/bool-array.cc superops/bool-array.h superops/bool-array.icc \
	superops/byte_def.cc superops/byte_def.h superops/hash-table.cc \
	superops/hash-table.h superops/hash.cc superops/hash.h \
	superops/keyword-list.cc superops/keyword-list.h superops/keyword-list.icc \
	superops/keyword.cc superops/keyword.h superops/keyword.icc \
	superops/observer-list.cc superops/observer-list.h superops/options.cc \
	superops/options.h superops/options.icc superops/positions.cc \
	superops/positions.h superops/positions.icc superops/search.cc \
	superops/search.h superops/superops.cc superops/table.cc superops/table.h \
	superops/vm_def.cc superops/vm_def.h

###########################################################
#
#        Rules for installing and distributing
#
#	 More rules are created by the GST_PACKAGE macros,
#	 including the stamp files used for building the
#	 documentation.  Here we mimic those rules for the
#	 kernel, whose file list lives in packages.xml
#
###########################################################

-include $(srcdir)/kernel/Makefile.frag
all-local: $(srcdir)/kernel/stamp-classes

# The slow rule for building the stamp-classes files uses gst-package, and
# depends on packages.xml in order to run when the list of files in the
# package might have changed.  The fast rule just touches the file.  We
# could actually do without double-colon rules by using another stamp file
# which depends on packages.xml and rebuilds all the stamp-classes files.

$(srcdir)/kernel/Makefile.frag: $(srcdir)/packages.xml $(WINEWRAPPERDEP)
	(echo '$$(srcdir)/kernel/stamp-classes: \'; \
	  $(GST_PACKAGE) --list-files Kernel --vpath --srcdir="$(srcdir)" $(srcdir)/packages.xml | \
	    tr -d \\r | tr \\n ' '; \
	echo; \
	echo '	touch $$(srcdir)/kernel/stamp-classes') \
	  > $(srcdir)/kernel/Makefile.frag

all-local:
clean-local::

dist-hook::
	$(GST_PACKAGE) --dist \
	  --distdir="$(distdir)" --srcdir="$(srcdir)" \
	  $(srcdir)/packages.xml
	cp -p $(srcdir)/kernel/stamp-classes $(distdir)/kernel/stamp-classes
	cp -p $(srcdir)/kernel/Makefile.frag $(distdir)/kernel/Makefile.frag

# Build an image after installing the data; install-data runs after
# install-exec, so the gst executable is already in bindir.
# To install the kernel files, we use gst-package in --dist mode.
install-data-hook::
	$(GST_PACKAGE) --dist --copy --all-files \
	  --destdir="$(DESTDIR)" --target-dir="$(pkgdatadir)" \
	  --srcdir "$(srcdir)" $(srcdir)/packages.xml
	$(mkdir_p) $(DESTDIR)$(imagedir)
	cd $(DESTDIR)$(imagedir) && \
	  $(WINEWRAPPER) "$(abs_top_builddir)/gst$(EXEEXT)" --no-user-files -iS \
	    --kernel-dir "$(DESTDIR)$(pkgdatadir)/kernel" \
	    --image "$(DESTDIR)$(imagedir)/gst.im" \
	    -f "@abs_top_srcdir@/scripts/Finish.st" \
	    "$(imagedir)" $(MODULES)

uninstall-local:: gst-tool$(EXEEXT)
	$(WINEWRAPPER) $(GST_PACKAGE) \
	  --uninstall --destdir="$(DESTDIR)" --target-dir "$(pkgdatadir)" \
	  --srcdir $(srcdir) $(DESTDIR)$(pkgdatadir)/packages.xml
	-rm -f $(DESTDIR)$(imagedir)/gst.im

@PACKAGE_RULES@
GTK.star: GLib.star
