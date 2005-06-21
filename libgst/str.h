/******************************** -*- C -*- ****************************
 *
 *	Simple string support
 *
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
 * Free Software Foundation, Inc.
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


#ifndef GST_STR_H
#define GST_STR_H

/* Returns the currently accumulated string, as a C string, and resets
   the pointer to start with a new string.  The string returned is
   unique.  */
extern char *_gst_cur_str_buf (void)
  ATTRIBUTE_HIDDEN;

/* Returns the currently accumulated string, as a C string, and resets
   the pointer to start with a new string.  The string returned is
   unique and is allocated in the obstack H.  */
extern char *_gst_obstack_cur_str_buf (struct obstack *h)
  ATTRIBUTE_HIDDEN;

/* Returns the currently accumulated buffer, and resets the pointer
   to start with a new string.  Instead of allocating fresh memory for
   the data, it is moved to the location pointed by WHERE. WHERE is
   returned */
extern PTR _gst_copy_buffer (PTR where)
  ATTRIBUTE_HIDDEN;

/* Answer the current size of the buffer.  */
extern size_t _gst_buffer_size (void)
  ATTRIBUTE_HIDDEN;

/* Adds a character C to the string being accumulated.  The character
   can be any valid ASCII character.  */
extern void _gst_add_str_buf_char (char c)
  ATTRIBUTE_HIDDEN;

/* Resets the pointer to start with a new string.  */
extern void _gst_reset_buffer (void)
  ATTRIBUTE_HIDDEN;

/* Adds a pointer PTR to the buffer being built.  */
extern void _gst_add_buf_pointer (PTR ptr)
  ATTRIBUTE_HIDDEN;

/* Adds N bytes of data starting from PTR to the string being
   accumulated.  */
extern void _gst_add_buf_data (PTR ptr,
			       int n)
  ATTRIBUTE_HIDDEN;

#endif /* GST_STR_H */
