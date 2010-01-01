##  -*- Mode: Makefile -*- 
## ---------------------------------------------------------------------
## Makefile.am -- process this file with automake to produce Makefile.in
## Copyright (C) 1998, 1999, 2000, 2002, 2009 Gary V. Vaughan
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

AUTOMAKE_OPTIONS	= gnits

DISTCLEANFILES          = compat.h compat.stamp
MAINTAINERCLEANFILES	= Makefile.in

AWK			= gawk
GENPROTO		= $(top_srcdir)/genproto
GENPROTO_FLAGS		= $(top_srcdir)/gendoc.awk
GENPROTO_ENVIRONMENT	= FORMAT=SNV_GNUC_PRINTF

AM_CPPFLAGS		= -I$(top_srcdir)

if INSTALL_SNPRINTFV
include_HEADERS           = printf.h
pkginclude_HEADERS        = mem.h filament.h stream.h
nodist_pkginclude_HEADERS = compat.h
else
noinst_HEADERS            = mem.h filament.h stream.h printf.h
nodist_noinst_HEADERS     = compat.h
endif

dist_noinst_DATA          = filament.stamp stream.stamp printf.stamp
CLEANFILES                = $(dist_noinst_DATA)

EXTRA_LTLIBRARIES       = libsnprintfv.la libsnprintfvc.la
noinst_LTLIBRARIES	= $(convenience_libsnprintfv)
lib_LTLIBRARIES		= $(installed_libsnprintfv)

libsnprintfv_la_LDFLAGS	= -no-undefined -rpath $(libdir) -version-info \
			  @SNV_CURRENT@:@SNV_REVISION@:@SNV_AGE@
libsnprintfv_la_LIBADD	= @LTLIBOBJS@ $(LIBADD_DL)
libsnprintfv_la_SOURCES	= 						\
			filament.c					\
			format.c					\
			printf.c					\
			mem.c						\
			stream.c					\
			custom.c

libsnprintfvc_la_CPPFLAGS = $(AM_CPPFLAGS) @LIBSNPRINTFVC_PRINT_FLOATS@
libsnprintfvc_la_LIBADD	= @LTLIBOBJS@
libsnprintfvc_la_SOURCES= 						\
			filament.c					\
			format.c					\
			printf.c					\
			mem.c						\
			stream.c					\
			custom.c


# These files are the raw sources used to generate similarly named
# header files after extracting the prototypes from the sources
#
EXTRA_DIST		=						\
			compat.in					\
			filament.in					\
			printf.in					\
			stream.in

BUILT_SOURCES		= 						\
			compat.h					\
			filament.h					\
			printf.h					\
			stream.h

gen: $(BUILT_SOURCES)

#
# Make sure the prototypes are reextracted if the sources change
#

SUFFIXES		= .stamp .in .h .c

# Create these in the source directory because that is where
# they are when the distribution tarball is unpacked.

$(srcdir)/%.h: %.stamp
	@:

%.stamp: %.in
	@file=`echo $@ | $(SED) 's,\.stamp$$,.h,'`; \
	$(GENPROTO_ENVIRONMENT) $(GENPROTO) $(GENPROTO_FLAGS) $^ > \
	  $${file}T; \
	if cmp -s $(srcdir)/$$file $${file}T; then \
	  echo $$file is unchanged; rm -f $${file}T; \
	else \
	  echo creating $(srcdir)/$$file; mv -f $${file}T $(srcdir)/$$file; \
	fi
	@echo timestamp > $@

printf.h: printf.stamp
filament.h: filament.stamp
stream.h: stream.stamp
printf.stamp: printf.in printf.c format.c custom.c
filament.stamp: filament.in filament.c
stream.stamp: stream.in stream.c

#
# compat.h is generated differently, so we can't use the pattern rule
# above:
#
compat.h: compat.stamp
compat.stamp: $(srcdir)/compat.in $(top_builddir)/config.status
	cd $(top_builddir) \
	  && $(SHELL) ./config.status snprintfv/compat.h
	echo timestamp > $@

# Makefile.am ends here

