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
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Automake requirements
AUTOMAKE_OPTIONS = gnu 1.8
ACLOCAL_AMFLAGS = -I config

PACKAGE=smalltalk

DIST_SUBDIRS = lib-src snprintfv lightning sigsegv \
	libgst i18n config kernel tcp \
	examples gtk blox-tk . doc tests

SUBDIRS = lib-src lightning $(subdirs) \
	libgst i18n config kernel tcp \
	examples gtk blox-tk . doc tests

pkglib_DATA = libc.la
pkgdata_DATA = Load.st Reload.st packages.xml
noinst_DATA = gst.im
dist_noinst_DATA = smalltalk-mode.el.in gst-mode.el.in
bin_PROGRAMS = gst
bin_SCRIPTS = gst-package gst-config

gst_SOURCES = main.c
gst_LDADD = libgst/libgst.la @ICON@
gst_LDFLAGS = -export-dynamic
gst_DEPENDENCIES = libgst/libgst.la @ICON@
INCLUDES = -I$(top_srcdir)/libgst

if WITH_EMACS
lisp_LISP = smalltalk-mode.el gst-mode.el
endif

EXTRA_DIST = Load.st Reload.st Finish.st packages.xml.in gst-config.in \
	gst-package.in gnu-smalltalk.spec.in gnu-smalltalk.spec \
	gsticon.ico COPYING.DOC COPYING.LIB TODO PATCHES

nodist_noinst_HEADERS = config.h
DISTCLEANFILES = config.h termbold termnorm
CLEANFILES = gst.im $(lisp_LISP)

# These two add a beatiful icon to the Win32 executable
gsticon.o: gsticon.ico
	echo ProgramIcon ICON `cygpath -w $(srcdir)/gsticon.ico` | windres -o gsticon.o

gst.im: $(bin_PROGRAMS) kernel/stamp-classes
	SMALLTALK_KERNEL="`cd $(srcdir)/kernel; pwd`" \
	SMALLTALK_IMAGE="`pwd`" \
	  ./gst -iQ dummy_file

gst-mode.el: gst-mode.el.in
	sed "s,@\(bindir\)@,$(bindir)," $(srcdir)/gst-mode.el.in > gst-mode.el
	
smalltalk-mode.el: smalltalk-mode.el.in
	sed "s,@\(lispdir\)@,$(lispdir)," $(srcdir)/smalltalk-mode.el.in > smalltalk-mode.el
	
# We need to provide a basic packages.xml file when a vpath build is in use
# so that the packages are found in subdirectories of the srcdir
# The \( ... \) below protect against substitution in config.status
dist-hook: gst-package
	sed -e "s/@\(I18N_DISABLED\)@/disabled-/" \
	  -e "s/@\(GTK_DISABLED\)@/disabled-/" \
	  -e "s/@\(VERSION\)@/@VERSION@/" \
	  $(srcdir)/packages.xml.in > packages.tmp
	SMALLTALK_IMAGE=$(distdir) \
	  ./gst-package --srcdir="$(srcdir)" --dist packages.tmp
	rm packages.tmp

packages.xml: packages.xml.in config.status
	$(SHELL) ./config.status --file=packages.xml:packages.xml.in

distclean-local:
	test "$(srcdir)" = . || rm packages.xml

# Build an image after installing the data; install-data runs after
# install-exec, so the gst executable is already in bindir.
install-data-hook: gst-package
	./gst-package --srcdir="$(srcdir)" --no-load --destdir="$(DESTDIR)" packages.xml
	srcdir=`cd $(srcdir) && pwd`; \
	cd $(DESTDIR)$(pkgdatadir); \
	SMALLTALK_KERNEL="`pwd`/kernel"; \
	SMALLTALK_IMAGE="`pwd`"; \
	  $(DESTDIR)$(bindir)/gst $$srcdir/Finish.st -VisqS -a "$(DESTDIR)" $(MODULES)

uninstall-local: gst-package
	./gst-package --uninstall --destdir="$(DESTDIR)" packages.xml
	-rm $(DESTDIR)$(pkgdatadir)/packages.xml
	-rm $(DESTDIR)$(pkgdatadir)/gst.im

installcheck:
	if test -n "$(DESTDIR)"; then :; else \
	  echo '[ PackageLoader fileInPackages: #(#MD5 #Regex) ] \
	    ifCurtailed: [ ObjectMemory quit: 1 ]!' | $(bindir)/gst -q; \
	fi

