##  -*- Mode: Makefile -*- 
## ---------------------------------------------------------------------
## Makefile.am -- process this file with automake to produce Makefile.in
## Copyright (C) 1998, 1999, 2000, 2001 Gary V. Vaughan
## Originally by Gary V. Vaughan <gvv@techie.com>, 1998
## This file is part of Snprintfv.
##
## Snprintfv is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 2 of the
## License, or (at your option) any later version.
##
## Snprintfv is distributed in the hope that it will be useful,
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

AUTOMAKE_OPTIONS	= gnits

EXTRA_DIST		= defs boilerplate-test $(noinst_SCRIPTS)
MAINTAINERCLEANFILES	= Makefile.in
SUFFIXES 		= .c .h .o .def

AM_CPPFLAGS		= -I$(top_srcdir)/snprintfv -I$(top_srcdir) \
			  -I$(top_builddir)/snprintfv -I$(top_builddir)
LDADD			= $(top_builddir)/snprintfv/libsnprintfv.la

TESTS_ENVIRONMENT 	= top_builddir=$(top_builddir)

noinst_SCRIPTS		= 		\
			ascii-test	\
			asprintf-test	\
			char-test	\
			count-test	\
			custom-test	\
			decimal-test	\
			dollar-test	\
			dprintf-test	\
			escape-test	\
			exponent-test	\
			extend-test	\
			float-test	\
			fprintf-test	\
			gfloat-test	\
			hex-test	\
			index-test	\
			integer-test	\
			limit-test	\
			native-test	\
			octal-test	\
			percent-test	\
			sprintf-test	\
			star-test	\
			string-test	\
			unsigned-test	\
			width-test	\
			test-clean

TESTS			= filament-test stream-test regress-test \
		  	  $(noinst_SCRIPTS)

noinst_PROGRAMS		= filament-test stream-test snprintfv-test \
			regress-test

noinst_LTLIBRARIES	= piglatin.la
piglatin_la_SOURCES	= piglatin.c
piglatin_la_LDFLAGS	= -no-undefined -module -rpath `pwd` -L$(top_builddir)/snprintfv -lsnprintfv
piglatin_la_DEPENDENCIES= $(top_builddir)/snprintfv/libsnprintfv.la

filament_test_SOURCES	= filament-test.c
regress_test_SOURCES	= regress-test.c
stream_test_SOURCES	= stream-test.c
snprintfv_test_SOURCES	= snprintfv-test.c
snprintfv_test_LDFLAGS	= -dlpreopen piglatin.la

# Makefile.am ends here
