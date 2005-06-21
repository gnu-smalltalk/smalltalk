/******************************** -*- C -*- ****************************
 *
 *	Security-related routine definitions.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


#ifndef GST_SECURITY_H
#define GST_SECURITY_H

typedef struct gst_permission
{
  OBJ_HEADER;
  OOP name;
  OOP actions;
  OOP target;
  OOP positive;
} *gst_permission;

typedef struct gst_security_policy
{
  OBJ_HEADER;
  OOP dictionary;
  OOP owner;
} *gst_security_policy;

mst_Boolean _gst_check_permission (OOP contextOOP,
				   OOP nameOOP,
				   OOP targetOOP,
				   OOP actionOOP)
  ATTRIBUTE_HIDDEN;

#endif /* GST_SECURITY_H */
