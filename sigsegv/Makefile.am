## Makefile for libsigsegv.
## Copyright (C) 2002-2003, 2007 Bruno Haible <bruno@clisp.org>
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

AUTOMAKE_OPTIONS = 1.7h gnu no-dependencies
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src tests

EXTRA_DIST = ChangeLog.1 PORTING README.woe32 Makefile.msvc config.h.msvc

DISTCLEANFILES = termbold termnorm


# Lead the user through the installation, in the hope that he will help us
# by sending his config.log.

TARGETSTACK =
AM_MAKEFLAGS = TARGETSTACK="$(TARGETSTACK) $@"

all-am: all-next
all-next:
	@if echo "$(TARGETSTACK)" | grep check-recursive > /dev/null; then :; else \
	   if echo "$(TARGETSTACK)" | grep install-recursive > /dev/null; then :; else \
	     echo; echo "Now please type '"`cat termbold`"make check"`cat termnorm`"' to run a quick test suite. Hope it works."; echo; \
	   fi; \
	 fi

check-am: check-next
check-next:
	@when="Now"; \
	if grep '^@PLATFORM@ .* @VERSION@$$' $(srcdir)/PORTING > /dev/null; then :; else \
	  case '@PLATFORM@' in \
	    i?86-*-linux* | x86_64-*-linux*) ;; \
	    *) \
	      echo; \
	      echo "Please send the following summary line via email to the author"; \
	      echo "Bruno Haible <bruno@clisp.org> for inclusion into the list of"; \
	      echo "successfully tested platforms (see PORTING file).  Please also"; \
	      echo "send the config.log file; this will help improving portability"; \
	      echo "of the package."; echo; \
	      if test @HAVE_SIGSEGV_RECOVERY@ = 1; then have1=yes; else have1=no; fi; \
	      if test @HAVE_STACK_OVERFLOW_RECOVERY@ = 1; then have2=yes; else have2=no; fi; \
	      echo `cat termbold`"libsigsegv: @PLATFORM@ | $$have1 | $$have2 | @VERSION@"`cat termnorm`; \
	      when="Then"; \
	      ;; \
	  esac; \
	fi; \
	echo; echo "$$when please type '"`cat termbold`"make install"`cat termnorm`"' to install the package."; echo

install-data-hook: install-next
install-next:
	@echo; echo "Now use the package; you can remove it later via '"`cat termbold`"make uninstall"`cat termnorm`"'."; echo


# Rules for "make dist".

$(srcdir)/config.h.msvc : config.h.in
	sed -e 's/#undef CFG_HANDLER/#define CFG_HANDLER "handler-win32.c"/' < $(srcdir)/config.h.in > $@
