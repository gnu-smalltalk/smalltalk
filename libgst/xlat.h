/******************************** -*- C -*- ****************************
 *
 *	Translator to native code declarations.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2006 Free Software Foundation, Inc.
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

#ifndef GST_XLAT_H
#define GST_XLAT_H


#ifdef ENABLE_JIT_TRANSLATION

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

extern void _gst_reset_inline_caches ()
  ATTRIBUTE_HIDDEN;

extern PTR _gst_get_native_code (OOP methodOOP,
				 OOP receiverClass) 
  ATTRIBUTE_HIDDEN;

extern PTR _gst_map_virtual_ip (OOP methodOOP,
				OOP receiverClass,
				int ip)
  ATTRIBUTE_HIDDEN;

extern void _gst_free_released_native_code (void)
  ATTRIBUTE_HIDDEN;
extern void _gst_release_native_code (OOP methodOOP)
  ATTRIBUTE_HIDDEN;
extern void _gst_discard_native_code (OOP methodOOP)
  ATTRIBUTE_HIDDEN;
extern void _gst_init_translator (void)
  ATTRIBUTE_HIDDEN;

extern PTR (*_gst_run_native_code) ()
  ATTRIBUTE_HIDDEN;

extern PTR (*_gst_return_from_native_code) ()
  ATTRIBUTE_HIDDEN;

#define GET_METHOD_ENTRY(nativeCodeStart) ((method_entry *) (		\
  ((char *) nativeCodeStart) - (sizeof(method_entry) - sizeof(int))  ))

#define IS_VALID_IP(nativeCodeStart) 					\
  ((nativeCodeStart) && GET_METHOD_ENTRY((nativeCodeStart))->receiverClass)

#endif /* ENABLE_JIT_TRANSLATION */

#endif /* GST_XLAT_H */
