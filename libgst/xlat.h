/******************************** -*- C -*- ****************************
 *
 *	Translator to native code declarations.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002 Free Software Foundation, Inc.
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

#ifndef GST_XLAT_H
#define GST_XLAT_H


#ifdef USE_JIT_TRANSLATION

struct inline_cache;
struct ip_map;
typedef struct method_entry
{
  struct method_entry *next;
  OOP methodOOP;
  OOP receiverClass;
  struct inline_cache *inlineCaches;
  struct ip_map *ipMap;
  int nativeCode[1];		/* type chosen randomly */
}
method_entry;

extern void _gst_reset_inline_caches ();

extern PTR _gst_get_native_code (OOP methodOOP, OOP receiverClass);

extern PTR _gst_map_virtual_ip (OOP methodOOP, OOP receiverClass, int ip);

extern void _gst_free_released_native_code (void);
extern void _gst_release_native_code (OOP methodOOP);
extern void _gst_discard_native_code (OOP methodOOP);
extern void _gst_init_translator (void);

extern PTR (*_gst_run_native_code) ();

extern PTR (*_gst_return_from_native_code) ();

#define GET_METHOD_ENTRY(nativeCodeStart) ((method_entry *) (		\
  ((char *) nativeCodeStart) - (sizeof(method_entry) - sizeof(int))  ))

#define IS_VALID_IP(nativeCodeStart) 					\
  (GET_METHOD_ENTRY(nativeCodeStart)->receiverClass)

#endif /* USE_JIT_TRANSLATION */

#endif /* GST_XLAT_H */
