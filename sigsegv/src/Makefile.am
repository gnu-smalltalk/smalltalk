## Makefile for libsigsegv/src.
## Copyright (C) 2002-2006 Bruno Haible <bruno@clisp.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
## USA.

## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = 1.5 gnits no-dependencies

RM = rm -f

lib_LTLIBRARIES = libsigsegv.la

noinst_HEADERS = \
  fault.h fault-aix3.h fault-aix3-powerpc.h fault-aix5.h fault-aix5-powerpc.h \
  fault-beos.h fault-beos-i386.h \
  fault-bsd.h fault-freebsd-i386.h \
  fault-hpux.h fault-hpux-hppa.h fault-hurd.h fault-irix.h fault-irix-mips.h \
  fault-linux.h fault-linux-alpha.h fault-linux-arm.h fault-linux-cris.h \
  fault-linux-hppa.h fault-linux-i386.h fault-linux-i386-old.h \
  fault-linux-ia64.h fault-linux-m68k.h fault-linux-m68k.c fault-linux-mips.h \
  fault-linux-powerpc.h fault-linux-s390.h fault-linux-sh.h \
  fault-linux-sparc.h fault-linux-x86_64.h \
  fault-macos-i386.h \
  fault-macosdarwin5-powerpc.h fault-macosdarwin5-powerpc.c \
  fault-macosdarwin7-powerpc.h fault-macosdarwin7-powerpc.c \
  fault-netbsd.h fault-netbsd-alpha.h fault-netbsd-alpha.c \
  fault-none.h \
  fault-openbsd.h fault-openbsd-i386.h \
  fault-osf.h fault-osf-alpha.h \
  fault-posix.h fault-solaris.h fault-solaris-i386.h fault-solaris-sparc.h \
  machfault.h machfault-macos-i386.h machfault-macos-powerpc.h \
  signals.h signals-bsd.h signals-hpux.h signals-hurd.h signals-macos.h \
  leave.h \
  stackvma.h

EXTRA_DIST = \
  handler-none.c handler-unix.c handler-macos.c handler-win32.c \
  stackvma-none.c stackvma-simple.c stackvma-linux.c stackvma-freebsd.c \
  stackvma-procfs.c stackvma-beos.c stackvma-mach.c stackvma-mincore.c \
  leave-none.c leave-nop.c leave-sigaltstack.c leave-setcontext.c \
  sigsegv.h.msvc

INCLUDES = -I. -I$(srcdir)
DEFS = @DEFS@

libsigsegv_la_SOURCES = handler.c stackvma.c leave.c dispatcher.c version.c

libsigsegv_la_LDFLAGS = -lc -no-undefined

# Dependencies.
handler.$(OBJEXT) : ../config.h sigsegv.h @CFG_HANDLER@ $(noinst_HEADERS) 
stackvma.$(OBJEXT) : ../config.h @CFG_STACKVMA@ stackvma.h
leave.$(OBJEXT) : ../config.h @CFG_LEAVE@
dispatcher.$(OBJEXT) : sigsegv.h


# Special rules for installing sigsegv.h.

install-data-local:
	$(mkinstalldirs) $(DESTDIR)$(includedir)
	$(INSTALL_DATA) sigsegv.h $(DESTDIR)$(includedir)/sigsegv.h

installdirs-local:
	$(mkinstalldirs) $(DESTDIR)$(includedir)

uninstall-local:
	$(RM) $(DESTDIR)$(includedir)/sigsegv.h


DISTCLEANFILES = sigsegv.h


# Rules for "make dist".

sigsegv.h.msvc : sigsegv.h.in
	sed -e 's/@''FAULT_CONTEXT_INCLUDE''@/#include <windows.h>/' \
	    -e 's/@''FAULT_CONTEXT_INCLUDE2''@//' \
	    -e 's/@''FAULT_CONTEXT''@/CONTEXT/' \
	    -e 's/@''HAVE_SIGSEGV_RECOVERY''@/1/' \
	    -e 's/@''HAVE_STACK_OVERFLOW_RECOVERY''@/1/' \
	    < $(srcdir)/sigsegv.h.in > $@

