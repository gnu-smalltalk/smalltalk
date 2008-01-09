# Copyright 2000, 2001, 2002
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
AUTOMAKE_OPTIONS = gnu 1.8
ACLOCAL_AMFLAGS = -I build-aux

PACKAGE=smalltalk

DIST_SUBDIRS = lib-src snprintfv lightning sigsegv libffi opcode libgst \
	i18n tcp examples blox-tk . gtk tests doc

SUBDIRS = lib-src lightning $(subdirs)
if ENABLE_DISASSEMBLER
SUBDIRS += opcode
endif
SUBDIRS += libgst i18n tcp examples blox-tk . doc gtk tests


###########################################################
#
#        Rules for configuration files
#
###########################################################

aclocaldir = $(datadir)/aclocal
dist_aclocal_DATA = build-aux/gst.m4
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

pkglib_DATA = libc.la
noinst_DATA = gst.im
dist_noinst_DATA += smalltalk-mode.el.in gst-mode.el.in .gdbinit \
	kernel/stamp-classes blox-tk/stamp-classes tcp/stamp-classes \
	i18n/stamp-classes scripts/Load.st scripts/Reload.st \
	scripts/Test.st scripts/Finish.st scripts/GenLibDoc.st \
	scripts/GenBaseDoc.st gsticon.ico

if WITH_EMACS
nodist_lisp_LISP = smalltalk-mode.el
if WITH_EMACS_COMINT
nodist_lisp_LISP += gst-mode.el
endif
endif

bin_SCRIPTS = gst-package gst-config
DISTCLEANFILES = termbold termnorm smalltalk-mode.el gst-mode.el
CLEANFILES = gst.im $(lisp_LISP)

smalltalk-mode.el: smalltalk-mode.el.in
	$(SED) -e "s,@\(lispdir\)@,$(lispdir)," $(srcdir)/smalltalk-mode.el.in \
	  > smalltalk-mode.el

gst-mode.el: gst-mode.el.in
	$(SED) -e "s,@\(bindir\)@,$(bindir)," $(srcdir)/gst-mode.el.in \
	  > gst-mode.el

install-exec-hook:
	$(SED) -e "s,@\(bindir\)@,$(bindir)," $(srcdir)/scripts/Load.st \
	  > $(DESTDIR)$(bindir)/gst-load
	chmod +x $(DESTDIR)$(bindir)/gst-load
	$(SED) -e "s,@\(bindir\)@,$(bindir)," $(srcdir)/scripts/Reload.st \
	  > $(DESTDIR)$(bindir)/gst-reload
	chmod +x $(DESTDIR)$(bindir)/gst-reload
	$(SED) -e "s,@\(bindir\)@,$(bindir)," $(srcdir)/scripts/Test.st \
	  > $(DESTDIR)$(bindir)/gst-sunit
	chmod +x $(DESTDIR)$(bindir)/gst-sunit

uninstall-local::
	-rm -f $(DESTDIR)$(bindir)/gst-load
	-rm -f $(DESTDIR)$(bindir)/gst-reload
	-rm -f $(DESTDIR)$(bindir)/gst-sunit

###########################################################
#
#        Rules for building the VM
#
###########################################################

bin_PROGRAMS = gst

gst_SOURCES = main.c
gst_LDADD = libgst/libgst.la @ICON@
gst_DEPENDENCIES = libgst/libgst.la @ICON@
AM_CPPFLAGS = -I$(top_srcdir)/libgst

if ENABLE_DISASSEMBLER
gst_LDADD += opcode/libdisass.la
gst_DEPENDENCIES += opcode/libdisass.la
AM_CPPFLAGS += -I$(top_srcdir)/opcode
endif

# By default, we do not build the installed VM as a shared library: it is
# a bit slower, and on x86 we also exchange the PIC register for the frame
# which makes the VM undebuggable except with very recent (3.4) gcc.
gst_LDFLAGS = -export-dynamic -static

nodist_noinst_HEADERS = config.h
DISTCLEANFILES += config.h

# These two lines add a beatiful icon to the Win32 executable
gsticon.o: gsticon.ico
	echo ProgramIcon ICON `cygpath -w gsticon.ico` | windres -o gsticon.o

gst.im: $(bin_PROGRAMS) $(srcdir)/kernel/stamp-classes
	SMALLTALK_KERNEL="`cd $(srcdir)/kernel; pwd`" \
	SMALLTALK_IMAGE="`pwd`" \
	  ./gst -iQ /dev/null

all-local:

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
###########################################################

# We need to provide a basic packages.xml file when a vpath build is in use
# so that the packages are found in subdirectories of the srcdir
# The \( ... \) below protect against substitution in config.status
dist-hook: gst-package
	$(SED) -e "s/@\(I18N_DISABLED\)@/disabled-/" \
	  -e "s/@\(GTK_DISABLED\)@/disabled-/" \
	  -e "s/@\(VERSION\)@/@VERSION@/" \
	  $(srcdir)/packages.xml.in > $(distdir)/packages.xml
	SMALLTALK_IMAGE=$(distdir) \
	  ./gst-package --srcdir="$(srcdir)" --dist $(distdir)/packages.xml

# Build an image after installing the data; install-data runs after
# install-exec, so the gst executable is already in bindir.
install-data-hook: gst-package
	rm -f $(pkgdatadir)/packages.xml
	./gst-package --srcdir="$(srcdir)" --no-load --destdir="$(DESTDIR)" packages.xml
	srcdir=`cd $(srcdir) && pwd`; \
	cd $(DESTDIR)$(pkgdatadir); \
	rm -f gst.im; \
	SMALLTALK_KERNEL="`pwd`/kernel" \
	SMALLTALK_IMAGE="`pwd`" \
	  $(DESTDIR)$(bindir)/gst -f $$srcdir/scripts/Finish.st \
	    "$(DESTDIR)$(pkgdatadir)" "$(pkgdatadir)" $(MODULES)

uninstall-local:: gst-package
	./gst-package --uninstall --destdir="$(DESTDIR)" packages.xml
	-rm -f $(DESTDIR)$(pkgdatadir)/packages.xml
	-rm -f $(DESTDIR)$(pkgdatadir)/gst.im

installcheck-local:
	if test -n "$(DESTDIR)"; then :; else \
	  echo '[ PackageLoader fileInPackages: #(#MD5 #Regex) ] \
	    ifCurtailed: [ ObjectMemory quit: 1 ]!' | $(bindir)/gst -q; \
	fi
