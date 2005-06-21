/******************************** -*- C -*- ****************************
 *
 *	strdup.c -- return a newly allocated copy of a string
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
 * Free Software Foundation, Inc.
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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "alloc.h"

#ifdef STDC_HEADERS
#include <string.h>
#endif

/* Return a newly allocated copy of STR,
   or 0 if out of memory. */

#ifndef HAVE_STRDUP
char *
strdup (const char *str)
{
  int  length = strlen (str) + 1;
  char *newstr = (char *) xmalloc (length);
  memcpy(newstr, str, length);
  return (newstr);
}
#endif

