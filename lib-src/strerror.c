/******************************** -*- C -*- ****************************
 *
 *	strerror.c -- implementation of strerror
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdio.h>

#ifndef HAVE_STRERROR

extern int sys_nerr;
extern const char *const sys_errlist[];

const char *
strerror(int e)
{
  static char buffer[30];
  if (!e) {
    buffer[0] = 0;
  } else if (e > 0 && e < sys_nerr) {
    return (sys_errlist[e]);
  } else {
    sprintf (buffer, "Unknown error %d", e);
  }
  return (buffer);
}

#endif

