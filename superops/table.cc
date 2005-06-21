/////////////////////////////// -*- C++ -*- ///////////////////////////
//
//	Program to extract superoperators from a GNU Smalltalk image.
//	Table creation routines for CompildCode.st.
//
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//
// Copyright 2003 Free Software Foundation, Inc.
// Written by Paolo Bonzini.
//
// This file is part of GNU Smalltalk.
//
// GNU Smalltalk is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2, or (at your option) any later
// version.
//
// GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
// Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//
///////////////////////////////////////////////////////////////////////

#if defined __GNUC__ && __GNUC__ < 3
#error Sorry, you need a recent C++ compiler to compile this program.
#endif

#include "table.h"
#include <iostream>
#include <fstream>

superop_table_builder::superop_table_builder () : fs ("table.st")
{
  fs << "\"Automatically generated by superops.  Do not modify this definition!\"" << std::endl;
  table[54*4+3] = 128;
}

superop_table_builder::~superop_table_builder ()
{
  std::cout << "Smalltalk description (for CompildCode.st) written to table.st." << std::endl;

  fs << "#[";
  for (int i = 0; i < 1024; i++)
    fs << (i & 31 ? " " : "\n       ") << table[i];

  fs << " ]";
}

void superop_table_builder::with_fixed_arg_1 (int new_bc,
				       int bc1, int arg, int bc2)
{
  table[new_bc*4] = bc1;
  table[new_bc*4+1] = bc2;
  table[new_bc*4+2] = arg;
  table[new_bc*4+3] = ((table[bc1*4+3] | table[bc2*4+3]) & 128);
}

void superop_table_builder::with_fixed_arg_2 (int new_bc,
				       int bc1, int bc2, int arg)
{
  table[new_bc*4] = bc1;
  table[new_bc*4+1] = bc2;
  table[new_bc*4+2] = arg;
  table[new_bc*4+3] = ((table[bc1*4+3] | table[bc2*4+3]) & 128) + 1;
}
