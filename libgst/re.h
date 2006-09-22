/***********************************************************************
 *
 *	Regular expression interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002 Free Software Foundation, Inc.
 * Written by Paolo Bonzini and Dragomir Milevojevic.
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

/* Functions exported to Smalltalk */
OOP _gst_re_make_cacheable (OOP patternOOP)
  ATTRIBUTE_HIDDEN;

struct pre_registers *_gst_re_search (OOP srcOOP, OOP patternOOP,
				      int from, int to)
  ATTRIBUTE_HIDDEN;

int _gst_re_match (OOP srcOOP, OOP patternOOP,
		   int from, int to)
  ATTRIBUTE_HIDDEN;

void _gst_re_free_registers(struct pre_registers *regs)
  ATTRIBUTE_HIDDEN;
