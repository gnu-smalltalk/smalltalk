/////////////////////////////// -*- C++ -*- ///////////////////////////
//
//	Program to extract superoperators from a GNU Smalltalk image.
//	Observer pattern.
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

#include "observer-list.h"

void observer_list::with_fixed_arg_1 (int new_bc, int bc1, int arg, int bc2)
{
  for (iterator i = begin (); i != end (); i++)
    (*i)->with_fixed_arg_1 (new_bc, bc1, arg, bc2);
}

void observer_list::with_fixed_arg_2 (int new_bc, int bc1, int bc2, int arg)
{
  for (iterator i = begin (); i != end (); i++)
    (*i)->with_fixed_arg_2 (new_bc, bc1, bc2, arg);
}
