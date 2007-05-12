## Makefile for libsigsegv/tests.
## Copyright (C) 2002-2003 Bruno Haible <bruno@clisp.org>
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

TESTS = sigsegv1 sigsegv2 stackoverflow1 stackoverflow2

EXTRA_DIST = mmaputil.h

INCLUDES = -I../src
DEFS = @DEFS@
LDADD = ../src/libsigsegv.la
noinst_PROGRAMS = sigsegv1 sigsegv2 stackoverflow1 stackoverflow2

# The following rule is necessary to avoid a toplevel "make -n" failure.
../src/libsigsegv.la :
	cd ../src && $(MAKE) libsigsegv.la
