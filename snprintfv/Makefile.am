##  -*- Mode: Makefile -*- 
## ---------------------------------------------------------------------
## Makefile.am -- process this file with automake to produce Makefile.in
## Copyright (C) 1998, 1999, 2000, 2002 Gary V. Vaughan
## Originally by Gary V. Vaughan, 1998
## This file is part of Snprintfv
##
## Snprintfv is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 2 of the
## License, or (at your option) any later version.
##
## Snprintfv program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
##
## As a special exception to the GNU General Public License, if you
## distribute this file as part of a program that also links with and
## uses the libopts library from AutoGen, you may include it under
## the same distribution terms used by the libopts library.

## Code:

ACLOCAL_AMFLAGS		= -I ../build-aux
AUTOMAKE_OPTIONS	= gnits

## BEGIN GNU SMALLTALK LOCAL
dist-hook:
	rm -rf $(distdir)/doc $(distdir)/tests

SUBDIRS			= snprintfv
## SUBDIRS              = snprintfv doc tests
## END GNU SMALLTALK LOCAL

DIST_SUBDIRS		= $(SUBDIRS)

MAINTAINERCLEANFILES	= Makefile.in aclocal.m4 configure config.h.in \
			  stamp-h.in

nodist_noinst_HEADERS   = config.h

aclocaldir              = $(datadir)/aclocal
dist_noinst_DATA        = snprintfv.m4

dist_noinst_SCRIPTS     = gendoc.awk genproto commit

# Makefile.am ends here

