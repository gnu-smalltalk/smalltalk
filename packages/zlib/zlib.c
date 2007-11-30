/***********************************************************************
 *
 *	Zlib interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2007 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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



#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdlib.h>
#include <zlib.h>

#include "gstpub.h"

static VMProxy *vmProxy;

typedef struct zlib_stream {
  OBJ_HEADER;
  OOP inBytes;
  OOP outBytes;
  OOP zlibObject;
  OOP stream;
} *zlib_stream;



/* Wrappers around deflateInit/inflateInit.  Additionally, we allow specifying
   the window size to support raw and gzip encoding.  */

void
gst_deflateInit (OOP oop, int factor, int winSize)
{
  z_stream *zlib_obj = calloc (1, sizeof (z_stream));

  OOP zlibObjOOP = vmProxy->cObjectToOOP (zlib_obj);
  zlib_stream zs = (zlib_stream) OOP_TO_OBJ (oop);
  zs->zlibObject = zlibObjOOP;
  deflateInit2 (zlib_obj, factor, Z_DEFLATED, winSize, 8, Z_DEFAULT_STRATEGY);
}


void
gst_inflateInit (OOP oop, int winSize)
{
  z_stream *zlib_obj = calloc (1, sizeof (z_stream));

  OOP zlibObjOOP = vmProxy->cObjectToOOP (zlib_obj);
  zlib_stream zs = (zlib_stream) OOP_TO_OBJ (oop);
  zs->zlibObject = zlibObjOOP;
  inflateInit2 (zlib_obj, winSize);
}


/* Wrappers around deflateEnd/inflateEnd.  Nothing interesting goes on here.  */

void
gst_deflateEnd (OOP oop)
{
  zlib_stream zs = (zlib_stream) OOP_TO_OBJ (oop);
  z_stream *zlib_obj = vmProxy->OOPToCObject (zs->zlibObject);

  deflateEnd (zlib_obj);
  zs->zlibObject = vmProxy->nilOOP;
  free (zlib_obj);
}


void
gst_inflateEnd (OOP oop)
{
  zlib_stream zs = (zlib_stream) OOP_TO_OBJ (oop);
  z_stream *zlib_obj = vmProxy->OOPToCObject (zs->zlibObject);

  inflateEnd (zlib_obj);
  zs->zlibObject = vmProxy->nilOOP;
  free (zlib_obj);
}


/* Common function to wrap deflate/inflate.  Takes care of setting up the
   zlib buffers so that they point into the Smalltalk buffers.  */

static int
zlib_wrapper (OOP oop, int flush, int inSize, int (*func) (z_stream *, int))
{
  zlib_stream zs = (zlib_stream) OOP_TO_OBJ (oop);
  z_stream *zlib_obj = vmProxy->OOPToCObject (zs->zlibObject);
  OOP inBytesOOP = zs->inBytes;
  OOP outBytesOOP = zs->outBytes;
  char *inBytes = &STRING_OOP_AT (OOP_TO_OBJ (inBytesOOP), 1);
  char *outBytes = &STRING_OOP_AT (OOP_TO_OBJ (outBytesOOP), 1);
  size_t outSize = vmProxy->OOPSize (outBytesOOP);
  int ret;

  if (!zlib_obj)
    return -1;

  /* If the buffer has leftover data, relocate next_in because the Smalltalk
     object might have moved.  Otherwise initialize it from inBytesOOP.  */
  if (zlib_obj->opaque)
    zlib_obj->next_in = inBytes + (ptrdiff_t) zlib_obj->opaque; 
  else
    {
      zlib_obj->next_in = inBytes;
      zlib_obj->avail_in = inSize;
    }

  /* Call the function we are wrapping.  */
  zlib_obj->next_out = outBytes;
  zlib_obj->avail_out = outSize;
  ret = func (zlib_obj, flush);
  if (ret == Z_BUF_ERROR)
    {
      zlib_obj->msg = NULL;
      ret = Z_OK;
    }

  /* If the buffer has leftover data, clear the inBytes field of the object.
     Otherwise store how many bytes were consumed in zs->opaque.  */
  if (zlib_obj->avail_in == 0)
    {
      zs->inBytes = vmProxy->nilOOP;
      zlib_obj->opaque = NULL;
    }
  else
    zlib_obj->opaque = (PTR) ((char *) zlib_obj->next_in - (char *) inBytes);

  /* Return the number of bytes written to the output buffer, or -1 if the
     output is finished.  */
  if (ret < 0)
    return -1;
  else if (flush == Z_FINISH && inSize == 0 && outSize == zlib_obj->avail_out)
    return -1;
  else
    return outSize - zlib_obj->avail_out;
}


int
gst_deflate (OOP oop, int flush, int inSize)
{
  return zlib_wrapper (oop, flush, inSize, deflate);
}



int
gst_inflate (OOP oop, int flush, int inSize)
{
  return zlib_wrapper (oop, flush, inSize, inflate);
}


/* Retrieves the error message from the z_stream object.  */

char *
gst_zlibError (OOP oop)
{
  zlib_stream zs = (zlib_stream) OOP_TO_OBJ (oop);
  z_stream *zlib_obj = vmProxy->OOPToCObject (zs->zlibObject);
  char *result = NULL;

  if (zlib_obj)
    {
      result = zlib_obj->msg;
      zlib_obj->msg = NULL;
    }

  return result;
}


/* Module initialization function.  */

void
gst_initModule (VMProxy * proxy)
{
  vmProxy = proxy;
  vmProxy->defineCFunc ("gst_deflateInit", gst_deflateInit);
  vmProxy->defineCFunc ("gst_deflateEnd", gst_deflateEnd);
  vmProxy->defineCFunc ("gst_deflate", gst_deflate);
  vmProxy->defineCFunc ("gst_inflateInit", gst_inflateInit);
  vmProxy->defineCFunc ("gst_inflateEnd", gst_inflateEnd);
  vmProxy->defineCFunc ("gst_inflate", gst_inflate);
  vmProxy->defineCFunc ("gst_zlibError", gst_zlibError);
}
