/******************************** -*- C -*- ****************************
 *
 *	Byte code compiler inlines
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
 * Written by Steve Byrne.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/



/* Returns the bytecodes of the CompiledMethod or CompiledBlock,
   METHODOOP */
#define GET_METHOD_BYTECODES(methodOOP) \
  ( ((gst_compiled_method)OOP_TO_OBJ(methodOOP))->bytecodes )

/* Returns the literals of the CompiledMethod or CompiledBlock,
   METHODOOP */
#define GET_METHOD_LITERALS(methodOOP) \
  ( OOP_TO_OBJ(((gst_compiled_method)OOP_TO_OBJ(methodOOP))->literals)->data )

/* Returns the header of the CompiledMethod, METHODOOP */
#define GET_METHOD_HEADER(methodOOP) \
  (((gst_compiled_method)OOP_TO_OBJ(methodOOP))->header)

/* Returns the class in which the CompiledMethod or CompiledBlock,
   METHODOOP, was defined */
#define GET_METHOD_CLASS(methodOOP) \
  (get_method_info(methodOOP)->class)

/* Returns the header of the CompiledBlock, BLOCKOOP */
#define GET_BLOCK_HEADER(blockOOP) \
  (((gst_compiled_block)OOP_TO_OBJ(blockOOP))->header)

/* Returns the method descriptor of OOP (either the CompiledMethod's
   descriptor or the descriptor of the home method if a
   CompiledBlock). */
static inline gst_method_info get_method_info (OOP oop);

gst_method_info
get_method_info (OOP oop)
{
  mst_Object obj;
  obj = OOP_TO_OBJ (oop);
  do
    {
      oop = ((gst_compiled_method) obj)->descriptor;
      obj = OOP_TO_OBJ (oop);
    }
  while (obj->objClass != _gst_method_info_class);

  return ((gst_method_info) obj);
}

