/***********************************************************************
 *
 *	GDBM interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006
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
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
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


#include "config.h"
#include "gstpub.h"
#include <gdbm.h>
#include <stdlib.h>

/*
     GDBM_FILE gdbm_open(name, block_size, flags, mode, fatal_func);
     void gdbm_close(dbf);
     int gdbm_store(dbf, key, content, flag);
     datum gdbm_fetch(dbf, key);
     int gdbm_delete(dbf, key);
     datum gdbm_firstkey(dbf);
     datum gdbm_nextkey(dbf, key);
     int gdbm_reorganize(dbf);
     void gdbm_sync(dbf); -- new
     int gdbm_exists(dbf, key); not present
     char *gdbm_strerror(errno); -- new 
     int gdbm_setopt(dbf, option, value, size) -- new
*/

static int wrapped_gdbm_store (GDBM_FILE dbf, datum * key, datum * content, int flag);
static datum * wrapped_gdbm_fetch (GDBM_FILE dbf, datum * key);
static int wrapped_gdbm_delete (GDBM_FILE dbf, datum * key);
static datum * wrapped_gdbm_nextkey (GDBM_FILE dbf, datum * key);
static datum * wrapped_gdbm_firstkey (GDBM_FILE dbf);

int
wrapped_gdbm_store (GDBM_FILE dbf, datum * key, datum * content, int flag)
{
  return gdbm_store (dbf, *key, *content, flag);
}

datum *
wrapped_gdbm_fetch (GDBM_FILE dbf, datum * key)
{
  datum *result;
  /* 
     printf("key is %d\n", key->dsize);
     printf("key value is %s\n", key->dptr);
   */
  result = (datum *) malloc (sizeof (datum));
  *result = gdbm_fetch (dbf, *key);
  /*
     printf("result length is %d ptr is %x\n", result->dsize, result->dptr);
   */
  return result;
}

int
wrapped_gdbm_delete (GDBM_FILE dbf, datum * key)
{
  return gdbm_delete (dbf, *key);
}

datum *
wrapped_gdbm_firstkey (GDBM_FILE dbf)
{
  datum *result;
  result = (datum *) malloc (sizeof (datum));
  *result = gdbm_firstkey (dbf);
  return result;
}

datum *
wrapped_gdbm_nextkey (GDBM_FILE dbf, datum * key)
{
  datum *result;
  result = (datum *) malloc (sizeof (datum));
  *result = gdbm_nextkey (dbf, *key);
  return result;
}

/*
int
wrapped_gdbm_exists(dbf, key)
     GDBM_FILE dbf;
     datum* key;
{
  return gdbm_exists(dbf, *key);
}
*/

void
gst_initModule (VMProxy * vmProxy)
{
  /* the use of the wrapped_ functions is an artifact of the limitation of C
     that you cannot reliably and portably synthesize a function call where
     some of the parameters are by-value structs.  Other than the use of
     pointers to datums instead of by-value datum structures, the signatures
     are identical to the normal gdbm functions */
  vmProxy->defineCFunc ("gdbm_open", gdbm_open);
  vmProxy->defineCFunc ("gdbm_close", gdbm_close);
  vmProxy->defineCFunc ("gdbm_store", wrapped_gdbm_store);
  vmProxy->defineCFunc ("gdbm_fetch", wrapped_gdbm_fetch);
  vmProxy->defineCFunc ("gdbm_delete", wrapped_gdbm_delete);
  vmProxy->defineCFunc ("gdbm_firstkey", wrapped_gdbm_firstkey);
  vmProxy->defineCFunc ("gdbm_nextkey", wrapped_gdbm_nextkey);
  vmProxy->defineCFunc ("gdbm_reorganize", gdbm_reorganize);
/*  vmProxy->defineCFunc("gdbm_sync", gdbm_sync); not universal */
/*  vmProxy->defineCFunc("gdbm_exists", wrapped_gdbm_exists); not universal */
/*  vmProxy->defineCFunc("gdbm_strerror", gdbm_strerror); not universal */
/*  vmProxy->defineCFunc("gdbm_setopt", gdbm_setopt); not universal */
}
