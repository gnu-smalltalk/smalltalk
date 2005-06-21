/******************************** -*- C -*- ****************************
 *
 *	Simple String Functions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003
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


#include "gstpriv.h"

#define	STRING_BASE_SIZE	128

/* This variable holds the base of the buffer maintained by this
   module. */
static char *buf_base = NULL;

/* This variable holds the size of the currently filled part of the
   buffer. */
static long cur_len = 0;

/* This variable holds the current size of the buffer. */
static long max_buf_len = 0;

char *
_gst_cur_str_buf (void)
{
  char *result;

  result = (char *) xmalloc (cur_len + 1);
  result[cur_len] = '\0';
  return (_gst_copy_buffer (result));
}

char *
_gst_obstack_cur_str_buf (struct obstack *h)
{
  char *result;

  result = (char *) obstack_alloc (h, cur_len + 1);
  result[cur_len] = '\0';
  return (_gst_copy_buffer (result));
}

void
_gst_add_str_buf_char (char c)
{
  if (cur_len >= max_buf_len)
    {
      if (max_buf_len)
	{
	  max_buf_len += (max_buf_len / 2);
	  buf_base = (char *) xrealloc (buf_base, max_buf_len);
	}
      else
	{
	  max_buf_len = STRING_BASE_SIZE;
	  buf_base = (char *) xmalloc (max_buf_len);
	}
    }

  buf_base[cur_len++] = c;
}

void
_gst_add_buf_pointer (PTR ptr)
{
  if (cur_len > max_buf_len - SIZEOF_CHAR_P)
    {
      if (max_buf_len)
	{
	  max_buf_len += (max_buf_len / 2) + SIZEOF_CHAR_P;
	  buf_base = (char *) xrealloc (buf_base, max_buf_len);
	}
      else
	{
	  max_buf_len = STRING_BASE_SIZE;
	  buf_base = (char *) xmalloc (max_buf_len);
	}
    }

  *((PTR *) (buf_base + cur_len)) = ptr;
  cur_len += SIZEOF_CHAR_P;
}

void
_gst_add_buf_data (PTR ptr,
		   int n)
{
  if (cur_len > max_buf_len - n)
    {
      if (max_buf_len)
	{
	  max_buf_len += (max_buf_len / 2) + n;
	  buf_base = (char *) xrealloc (buf_base, max_buf_len);
	}
      else
	{
	  max_buf_len = STRING_BASE_SIZE + n;
	  buf_base = (char *) xmalloc (max_buf_len);
	}
    }

  memcpy ((PTR *) (buf_base + cur_len), ptr, n);
  cur_len += n;
}

PTR
_gst_copy_buffer (PTR where)
{
  memcpy (where, buf_base, cur_len);
  cur_len = 0;

  return (where);
}

void
_gst_reset_buffer (void)
{
  cur_len = 0;
}

long
_gst_buffer_size (void)
{
  return (cur_len);
}
