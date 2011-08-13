/******************************** -*- C -*- ****************************
 *
 *	Public entry points
 *
 *	This module provides public routines with a "gst_" prefix.
 *	These are exported by the dynamic library.
 *
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
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
 return ***********************************************************************/

#include "gstpriv.h"

/* By not including this file anywhere else, we make sure that _gst functions
   are always called, and don't create unnecessary PLA entries.  */
#include "gstpub.h"

VMProxy gst_interpreter_proxy = {
  NULL, NULL, NULL,

  _gst_msg_send, _gst_vmsg_send, _gst_nvmsg_send, _gst_str_msg_send,
  _gst_msg_sendf,
  _gst_eval_expr, _gst_eval_code,

  _gst_object_alloc, _gst_basic_size,

  _gst_define_cfunc, _gst_register_oop, _gst_unregister_oop,

/* Convert C datatypes to Smalltalk types */

  _gst_id_to_oop, _gst_int_to_oop, _gst_float_to_oop, _gst_bool_to_oop,
  _gst_char_to_oop, _gst_class_name_to_oop,
  _gst_string_to_oop, _gst_byte_array_to_oop, _gst_symbol_to_oop,
  _gst_c_object_to_oop, _gst_type_name_to_oop, _gst_set_c_object,

/* Convert Smalltalk datatypes to C data types */

  _gst_oop_to_c, _gst_oop_to_id, _gst_oop_to_int, _gst_oop_to_float,
  _gst_oop_to_bool, _gst_oop_to_char,
  _gst_oop_to_string, _gst_oop_to_byte_array, _gst_oop_to_c_object,

/* Smalltalk process support */
  _gst_async_signal, _gst_sync_wait, _gst_async_signal_and_unregister,

  _gst_register_oop_array, _gst_unregister_oop_array,

/* Convert Smalltalk datatypes to C data types (2) */
  _gst_oop_to_long_double, _gst_long_double_to_oop,

  _gst_get_object_class, _gst_get_superclass,
  _gst_class_is_kind_of, _gst_object_is_kind_of,
  _gst_perform, _gst_perform_with, _gst_class_implements_selector,
  _gst_class_can_understand, _gst_responds_to,
  _gst_oop_size, _gst_oop_at, _gst_oop_at_put,

  /* System objects.  */
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,

  /* New in 2.3.  */
  _gst_wchar_to_oop, _gst_wstring_to_oop,
  _gst_oop_to_wchar, _gst_oop_to_wstring,

  /* New in 3.0.  */
  _gst_process_stdin,
  _gst_process_file,
  _gst_get_var, _gst_set_var,
  _gst_invoke_hook,

  /* New in 3.1.  */
  _gst_relocate_path,
  _gst_oop_indexed_base,
  _gst_oop_indexed_kind,
  _gst_async_call,
  _gst_sync_signal,
  _gst_show_backtrace,

  /* New in 3.2.  */
  _gst_dlopen,
  _gst_dladdsearchdir,
  _gst_dlpushsearchpath,
  _gst_dlpopsearchpath,
  _gst_wakeup,

  /* New in 3.2.5.  */
  _gst_uint_to_oop,

  /* New in 3.3.  */
  _gst_set_event_loop_handlers
};

/* Functions in comp.h.  */
void
gst_invoke_hook (enum gst_vm_hook hook)
{
  _gst_invoke_hook (hook);
}

void
gst_smalltalk_args (int argc,
		    const char **argv)
{
  _gst_smalltalk_args (argc, argv);
}

int
gst_initialize (const char *kernel_dir,
		const char *image_file,
		int flags)
{
  return _gst_initialize (kernel_dir, image_file, flags);
}

void gst_process_stdin (const char *prompt)
{
  _gst_process_stdin (prompt);
}

mst_Boolean
gst_process_file (const char *fileName, enum gst_file_dir dir)
{
  return _gst_process_file (fileName, dir);
}

int
gst_get_var (enum gst_var_index index)
{
  return _gst_get_var (index);
}

int
gst_set_var (enum gst_var_index index, int value)
{
  return _gst_set_var (index, value);
}

OOP
gst_msg_send (OOP receiver, OOP selector, ...)
{
  va_list ap; 
  va_start (ap, selector);
  return _gst_va_msg_send (receiver, selector, ap);
}

OOP
gst_vmsg_send (OOP receiver, OOP selector, OOP * args)
{
  return _gst_vmsg_send (receiver, selector, args);
}

OOP
gst_nvmsg_send (OOP receiver, OOP selector, OOP * args, int nargs)
{
  return _gst_nvmsg_send (receiver, selector, args, nargs);
}

OOP
gst_str_msg_send (OOP receiver, const char *sel, ...)
{
  va_list ap; 
  OOP selector = _gst_symbol_to_oop (sel);
  va_start (ap, sel);
  return _gst_va_msg_send (receiver, selector, ap);
}

void
gst_msg_sendf (PTR result_ptr, const char *fmt, ...)
{
  va_list ap;
  va_start (ap, fmt);
  _gst_va_msg_sendf (result_ptr, fmt, ap);
}

OOP
gst_eval_expr (const char *str)
{
  return _gst_eval_expr (str);
}

void
gst_eval_code (const char *str)
{
  _gst_eval_code (str);
}

OOP
gst_object_alloc (OOP class_oop, int size)
{
  return _gst_object_alloc (class_oop, size);
}

int
gst_basic_size (OOP oop)
{
  return _gst_basic_size (oop);
}

void
gst_define_cfunc (const char *func_name, PTR func_addr)
{
  _gst_define_cfunc (func_name, func_addr);
}

OOP
gst_register_oop (OOP oop)
{
  return _gst_register_oop (oop);
}

void
gst_unregister_oop (OOP oop)
{
  _gst_unregister_oop (oop);
}

OOP
gst_id_to_oop (long i)
{
  return _gst_id_to_oop (i);
}

OOP
gst_int_to_oop (long i)
{
  return _gst_int_to_oop (i);
}

OOP
gst_uint_to_oop (unsigned long i)
{
  return _gst_uint_to_oop (i);
}

OOP
gst_float_to_oop (double f)
{
  return _gst_float_to_oop (f);
}

OOP
gst_bool_to_oop (int b)
{
  return _gst_bool_to_oop (b);
}

OOP
gst_char_to_oop (char c)
{
  return _gst_char_to_oop (c);
}

OOP
gst_class_name_to_oop (const char *name)
{
  return _gst_class_name_to_oop (name);
}

OOP
gst_string_to_oop (const char *str)
{
  return _gst_string_to_oop (str);
}

OOP
gst_byte_array_to_oop (const char *str, int n)
{
  return _gst_byte_array_to_oop (str, n);
}

OOP
gst_symbol_to_oop (const char *str)
{
  return _gst_symbol_to_oop (str);
}

OOP
gst_c_object_to_oop (PTR co)
{
  return _gst_c_object_to_oop (co);
}

OOP
gst_type_name_to_oop (const char *name)
{
  return _gst_type_name_to_oop (name);
}

void
gst_set_c_object (OOP oop, PTR co)
{
  _gst_set_c_object (oop, co);
}

long
gst_oop_to_c (OOP oop)
{
  return _gst_oop_to_c (oop);
}				/*sometimes answers a PTR */

long
gst_oop_to_id (OOP oop)
{
  return _gst_oop_to_id (oop);
}

long
gst_oop_to_int (OOP oop)
{
  return _gst_oop_to_int (oop);
}

double
gst_oop_to_float (OOP oop)
{
  return _gst_oop_to_float (oop);
}

int
gst_oop_to_bool (OOP oop)
{
  return _gst_oop_to_bool (oop);
}

char
gst_oop_to_char (OOP oop)
{
  return _gst_oop_to_char (oop);
}

char *
gst_oop_to_string (OOP oop)
{
  return _gst_oop_to_string (oop);
}

char *
gst_oop_to_byte_array (OOP oop)
{
  return _gst_oop_to_byte_array (oop);
}

PTR
gst_oop_to_c_object (OOP oop)
{
  return _gst_oop_to_c_object (oop);
}

void
gst_async_signal (OOP semaphore_oop)
{
  _gst_async_signal (semaphore_oop);
}

void
gst_sync_wait (OOP semaphore_oop)
{
  _gst_sync_wait (semaphore_oop);
}

void
gst_async_signal_and_unregister (OOP semaphore_oop)
{
  _gst_async_signal_and_unregister (semaphore_oop);
}

mst_Boolean
gst_sync_signal (OOP semaphore_oop, mst_Boolean incr_if_empty)
{
  return _gst_sync_signal (semaphore_oop, incr_if_empty);
}

void
gst_async_call (void (*func) (OOP), OOP semaphore_oop)
{
  _gst_async_call (func, semaphore_oop);
}

void
gst_show_backtrace (FILE *fp)
{
  _gst_show_backtrace (fp);
}

mst_Boolean
gst_dlopen (const char *filename, mst_Boolean module)
{
  return _gst_dlopen (filename, module);
}

void
gst_dladdsearchdir (const char *dir)
{
  _gst_dladdsearchdir (dir);
}

void
gst_dlpushsearchpath (void)
{
  _gst_dlpushsearchpath ();
}

void
gst_dlpopsearchpath (void)
{
  _gst_dlpopsearchpath ();
}

void
gst_wakeup ()
{
  _gst_wakeup ();
}

void
gst_register_oop_array (OOP **first, OOP **last)
{
  _gst_register_oop_array (first, last);
}

void
gst_unregister_oop_array (OOP **first)
{
  _gst_unregister_oop_array (first);
}

long double
gst_oop_to_long_double (OOP oop)
{
  return _gst_oop_to_long_double (oop);
}

OOP
gst_long_double_to_oop (long double f)
{
  return _gst_long_double_to_oop (f);
}

OOP
gst_wchar_to_oop (wchar_t c)
{
  return _gst_wchar_to_oop (c);
}

OOP
gst_wstring_to_oop (const wchar_t *str)
{
  return _gst_wstring_to_oop (str);
}

wchar_t
gst_oop_to_wchar (OOP oop)
{
  return _gst_oop_to_wchar (oop);
}

wchar_t *
gst_oop_to_wstring (OOP oop)
{
  return _gst_oop_to_wstring (oop);
}

OOP
gst_get_object_class (OOP oop)
{
  return _gst_get_object_class (oop);
}

OOP
gst_get_superclass (OOP oop)
{
  return _gst_get_superclass (oop);
}

mst_Boolean
gst_class_is_kind_of (OOP oop, OOP candidate)
{
  return _gst_class_is_kind_of (oop, candidate);
}

mst_Boolean
gst_object_is_kind_of (OOP oop, OOP candidate)
{
  return _gst_object_is_kind_of (oop, candidate);
}

OOP
gst_perform (OOP oop, OOP selector)
{
  return _gst_perform (oop, selector);
}

OOP
gst_perform_with (OOP oop, OOP selector, OOP arg)
{
  return _gst_perform_with (oop, selector, arg);
}

mst_Boolean
gst_class_implements_selector (OOP class_oop, OOP selector)
{
  return _gst_class_implements_selector (class_oop, selector);
}

mst_Boolean gst_class_can_understand (OOP class_oop, OOP selector)
{
  return _gst_class_can_understand (class_oop, selector);
}

mst_Boolean
gst_responds_to (OOP oop, OOP selector)
{
  return _gst_responds_to (oop, selector);
}

size_t
gst_oop_size (OOP oop)
{
  return _gst_oop_size (oop);
}

OOP
gst_oop_at (OOP oop, size_t index)
{
  return _gst_oop_at (oop, index);
}

OOP
gst_oop_at_put (OOP oop, size_t index, OOP new_oop)
{
  return _gst_oop_at_put (oop, index, new_oop);
}

enum gst_indexed_kind
gst_oop_indexed_kind (OOP oop)
{
  return _gst_oop_indexed_kind (oop);
}

void *
gst_oop_indexed_base (OOP oop)
{
  return _gst_oop_indexed_base (oop);
}


/* Functions in sysdep.h.  */
void
gst_set_executable_path (const char *argv0)
{
  _gst_set_executable_path (argv0);
}

char *
gst_relocate_path (const char *path)
{
  return _gst_relocate_path (path);
}


/* Functions in events.h.  */
mst_Boolean
gst_set_event_loop_handlers(mst_Boolean (*poll) (int ms),
			    void (*dispatch) (void))
{
  return _gst_set_event_loop_handlers(poll, dispatch);
}
