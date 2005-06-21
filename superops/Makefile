# Makefile for gperf/src

# Copyright (C) 1989,1992,1993,1998,2000,2002 Free Software Foundation, Inc.
# Written by Douglas C. Schmidt <schmidt@ics.uci.edu>
# and Bruno Haible <bruno@clisp.org>.
#
# This file is part of GNU GPERF.
#
# GNU GPERF is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# GNU GPERF is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.
# If not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#### Start of system configuration section. ####

srcdir = .
VPATH = $(srcdir)
CXX = g++
CXXFLAGS = -O2 -g

OBJECTS  = bool-array.o hash-table.o keyword-list.o keyword.o \
	options.o positions.o search.o superops.o \
	byte_def.o vm_def.o hash.o observer-list.o table.o

LIBS     = -lm
CPPFLAGS = -I.
TARGETPROG = superops

all : $(TARGETPROG)

$(TARGETPROG): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGETPROG) $(OBJECTS) $(LIBS)

# Dependencies.
POSITIONS_H = positions.h positions.icc
OPTIONS_H = options.h options.icc $(POSITIONS_H)
KEYWORD_H = keyword.h keyword.icc
KEYWORD_LIST_H = keyword-list.h keyword-list.icc $(KEYWORD_H)
INPUT_H = input.h $(KEYWORD_LIST_H)
BOOL_ARRAY_H = bool-array.h bool-array.icc $(OPTIONS_H)
HASH_TABLE_H = hash-table.h $(KEYWORD_H)
SEARCH_H = search.h $(KEYWORD_LIST_H) $(POSITIONS_H) $(BOOL_ARRAY_H)

positions.o : positions.cc $(POSITIONS_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/positions.cc
options.o : options.cc $(OPTIONS_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/options.cc
keyword.o : keyword.cc $(KEYWORD_H) $(POSITIONS_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/keyword.cc
keyword-list.o : keyword-list.cc $(KEYWORD_LIST_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/keyword-list.cc
input.o : input.cc $(INPUT_H) $(OPTIONS_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/input.cc
bool-array.o : bool-array.cc $(BOOL_ARRAY_H) $(OPTIONS_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/bool-array.cc
hash-table.o : hash-table.cc $(HASH_TABLE_H) $(OPTIONS_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/hash-table.cc
search.o : search.cc $(SEARCH_H) $(OPTIONS_H) $(HASH_TABLE_H)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/search.cc
superops.o : superops.cc $(OPTIONS_H) $(KEYWORD_H) $(SEARCH_H) $(OUTPUT_H) \
	$(KEYWORD_LIST_H) hash.h byte_def.h vm_def.h observer-list.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/superops.cc
observer-list.o : observer-list.cc observer-list.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/observer-list.cc
table.o : table.cc table.h observer-list.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/table.cc
hash.o : hash.cc hash.h observer-list.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/hash.cc
byte_def.o : byte_def.cc byte_def.h observer-list.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/byte_def.cc
vm_def.o : vm_def.cc vm_def.h observer-list.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(srcdir)/vm_def.cc


mostlyclean : clean

clean : 
	$(RM) *~ *.s *.o *.a $(TARGETPROG) core

distclean : clean

maintainer-clean : distclean

.PHONY : all mostlyclean clean distclean maintainer-clean
