/***********************************************************************
 *
 *	MD5 interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002 Free Software Foundation, Inc.
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

#include "md5.h"

#include "gstpub.h"

static VMProxy *vmProxy;
static OOP MD5AllocOOP (void);

OOP
MD5AllocOOP (void)
{
  struct md5_ctx ctx;
  md5_init_ctx (&ctx);
  return vmProxy->byteArrayToOOP ((char *) &ctx, sizeof (ctx));
}

void
gst_initModule (VMProxy * proxy)
{
  vmProxy = proxy;
  vmProxy->defineCFunc ("MD5AllocOOP", MD5AllocOOP);
  vmProxy->defineCFunc ("MD5Update", md5_process_bytes);
  vmProxy->defineCFunc ("MD5Final", md5_finish_ctx);
}
