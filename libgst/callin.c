/******************************** -*- C -*- ****************************
 *
 *	C Callin facilities
 *
 *	This module provides many routines to allow C code to invoke 
 *	Smalltalk messages on objects, most of which are based on
 *	low-level facilities exposed by interp.c and dict.c.
 *
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008,2009
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

#include "gstpriv.h"
#include "gstpub.h"

#ifndef NAN
#define NAN (0.0 / 0.0)
#endif

typedef struct oop_registry
{
  rb_node_t rb;
  OOP oop;
  int usage;
}
oop_registry;

typedef struct oop_array_registry
{
  rb_node_t rb;
  OOP **first;
  OOP **last;
  int usage;
}
oop_array_registry;


/* The registry of OOPs which have been passed to C code.  Implemented
   as a red-black tree.  The registry is examined at GC time to ensure
   that OOPs that C code knows about don't go away.  */
static oop_registry *oop_registry_root;
static oop_array_registry *oop_array_registry_root;

OOP
_gst_va_msg_send (OOP receiver,
		  OOP selector,
		  va_list ap)
{
  va_list save;
  OOP *args, anArg;
  int numArgs;

  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

#ifdef __va_copy
  __va_copy (save, ap);
#else
  save = ap;
#endif

  for (numArgs = 0; va_arg (ap, OOP) != NULL; numArgs++)
    ;

  if (numArgs != _gst_selector_num_args (selector))
    return (_gst_nil_oop);
  else
    {
      args = (OOP *) alloca (sizeof (OOP) * numArgs);
      for (numArgs = 0; (anArg = va_arg (save, OOP)) != NULL; numArgs++)
	args[numArgs] = anArg;

      return _gst_nvmsg_send (receiver, selector, args, numArgs);
    }
}

OOP
_gst_msg_send (OOP receiver,
	       OOP selector,
	       ...)
{
  va_list ap;

  va_start (ap, selector);
  return _gst_va_msg_send (receiver, selector, ap);
}

OOP
_gst_vmsg_send (OOP receiver,
		OOP selector,
		OOP * args)
{
  int numArgs;

  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  for (numArgs = 0; args[numArgs]; numArgs++);

  if (numArgs != _gst_selector_num_args (selector))
    return (_gst_nil_oop);
  else
    return _gst_nvmsg_send (receiver, selector, args, numArgs);
}

OOP
_gst_str_msg_send (OOP receiver, 
		   const char *sel,
		   ...)
{
  va_list ap; 
  OOP selector = _gst_symbol_to_oop (sel);
  va_start (ap, sel);
  return _gst_va_msg_send (receiver, selector, ap);
}

/* Use like printf */
void
_gst_va_msg_sendf (PTR resultPtr, 
		   const char *fmt, 
		   va_list ap)
{
  OOP selector, *args, result;
  int i, numArgs;
  const char *fp;
  char *s, selectorBuf[256];
  inc_ptr incPtr;
  mst_Boolean receiver_is_block = false;

  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  incPtr = INC_SAVE_POINTER ();

  numArgs = 0;
  for (s = selectorBuf, fp = &fmt[2]; *fp; fp++)
    {
      if (*fp == '%')
	{
	  fp++;
	  numArgs++;
	  if (*fp == '%')
	    {
	      *s++ = '%';
	      numArgs--;
	    }
	  else if (*fp == 'B')
	    receiver_is_block = true;
	}
      else if (*fp != ' ' && *fp != '\t')
	*s++ = *fp;
    }

  *s = '\0';

  if (receiver_is_block)
    selector = NULL;
  else
    selector = _gst_intern_string (selectorBuf);

  if (numArgs != 1 + _gst_selector_num_args (selector))
    return;

  args = (OOP *) alloca (sizeof (OOP) * numArgs);
  for (i = -1, fp = &fmt[2]; *fp; fp++)
    {
      if (*fp != '%')
	continue;

      fp++;
      switch (*fp)
        {
        case 'i':
          args[++i] = FROM_C_INT (va_arg (ap, long));
	  INC_ADD_OOP (args[i]);
          break;

        case 'f':
          args[++i] = floatd_new (va_arg (ap, double));
	  INC_ADD_OOP (args[i]);
          break;

        case 'F':
          args[++i] = floatq_new (va_arg (ap, long double));
	  INC_ADD_OOP (args[i]);
          break;

        case 'b':
          args[++i] = va_arg (ap, int) ? _gst_true_oop : _gst_false_oop;
	  INC_ADD_OOP (args[i]);
          break;

        case 'c':
          args[++i] = CHAR_OOP_AT ((char) va_arg (ap, int));
	  INC_ADD_OOP (args[i]);
          break;

        case 'C':
          args[++i] = COBJECT_NEW (va_arg (ap, PTR), _gst_nil_oop,
				   _gst_c_object_class);
	  INC_ADD_OOP (args[i]);
          break;

        case 's':
          args[++i] = _gst_string_new (va_arg (ap, const char *));
	  INC_ADD_OOP (args[i]);
          break;

        case 'S':
          args[++i] = _gst_intern_string (va_arg (ap, const char *));
	  INC_ADD_OOP (args[i]);
          break;

        case 'B':
        case 'o':
          args[++i] = va_arg (ap, OOP);
	  INC_ADD_OOP (args[i]);
          break;

        case 't':		/* type string, followed by a void * */
          {
	    OOP ctype;
	    ctype = _gst_type_name_to_oop (va_arg (ap, const char *));
	    INC_ADD_OOP (ctype);

	    args[++i] = COBJECT_NEW (va_arg (ap, PTR), ctype, _gst_nil_oop);

	    INC_ADD_OOP (args[i]);
          }
          break;


        case 'T':		/* existing type instance, and a void * */
          {
    	    OOP ctype;
    	    ctype = va_arg (ap, OOP);
    	    args[++i] = COBJECT_NEW (va_arg (ap, PTR), ctype, _gst_nil_oop);

	    INC_ADD_OOP (args[i]);
          }
          break;

        case 'w':
#if SIZEOF_WCHAR_T <= SIZEOF_INT
          args[++i] = char_new ((wchar_t) va_arg (ap, int));
#else
          args[++i] = char_new ((wchar_t) va_arg (ap, wchar_t));
#endif
	  INC_ADD_OOP (args[i]);
          break;

        case 'W':
          args[++i] = _gst_unicode_string_new (va_arg (ap, const wchar_t *));
	  INC_ADD_OOP (args[i]);
          break;
	}
    }

  result = _gst_nvmsg_send (args[0], selector, args + 1, numArgs - 1);

  if (resultPtr)
    {
      switch (fmt[1])
	{
	case 'i':
	  *(int *) resultPtr = IS_NIL (result) ? 0 : TO_C_INT (result);
	  break;

	case 'c':
	  *(char *) resultPtr =
	    IS_NIL (result) ? 0 : CHAR_OOP_VALUE (result);
	  break;

	case 'C':
	  *(PTR *) resultPtr =
	    IS_NIL (result) ? NULL : cobject_value (result);
	  break;

	case 's':
	  *(char **) resultPtr =
	    IS_NIL (result) ? NULL : (char *) _gst_to_cstring (result);
	  break;

	case 'b':
	  *(int *) resultPtr =
	    IS_NIL (result) ? false : (result == _gst_true_oop);
	  break;

	case 'f':
	  *(double *) resultPtr =
	    IS_NIL (result) ? 0.0 : _gst_oop_to_float (result);
	  break;

	case 'F':
	  *(long double *) resultPtr =
	    IS_NIL (result) ? 0.0 : _gst_oop_to_long_double (result);
	  break;

	case 'v':		/* don't care about the result */
	  break;		/* "v" for "void" */

	case '?':
	  *(long *) resultPtr = _gst_oop_to_c (result);
	  break;

	case 'w':
	  *(wchar_t *) resultPtr =
	    IS_NIL (result) ? 0 : CHAR_OOP_VALUE (result);
	  break;

	case 'W':
	  *(wchar_t **) resultPtr =
	    IS_NIL (result) ? NULL : _gst_to_wide_cstring (result);
	  break;

	case 'o':
	default:
	  *(OOP *) resultPtr = result;
	  break;
	}
    }

  INC_RESTORE_POINTER (incPtr);
}


void
_gst_msg_sendf (PTR resultPtr, 
		const char *fmt, 
		...)
{
  va_list ap;
  va_start (ap, fmt);
  _gst_va_msg_sendf (resultPtr, fmt, ap);
}

OOP
_gst_type_name_to_oop (const char *name)
{
  OOP result;
  char buf[300];

  sprintf (buf, "^%s!", name);

  result = _gst_eval_expr (buf);
  return (result);
}


void
_gst_eval_code (const char *str)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  _gst_push_cstring (str);
  _gst_parse_stream (NULL);
  _gst_pop_stream (true);
}


OOP
_gst_eval_expr (const char *str)
{
  OOP result;

  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  _gst_push_cstring (str);
  _gst_parse_stream (NULL);
  _gst_pop_stream (true);
  result = _gst_last_returned_value;
  INC_ADD_OOP (result);

  return (result);
}

OOP
_gst_object_alloc (OOP class_oop,
		   int size)
{
  OOP oop;

  if (CLASS_IS_INDEXABLE (class_oop))
    instantiate_with (class_oop, size, &oop);
  else
    instantiate (class_oop, &oop);

  INC_ADD_OOP (oop);
  return oop;
}

int
_gst_basic_size (OOP oop)
{
  return (NUM_INDEXABLE_FIELDS (oop));
}


/***********************************************************************
 *
 *	Conversion *to* Smalltalk datatypes routines
 *
 ***********************************************************************/

OOP
_gst_class_name_to_oop (const char *name)
{
  OOP result, key;
  char *s, *p, *prev_p;

  if (!name || !*name)
    return NULL;

  s = strdup (name);
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  result = _gst_smalltalk_dictionary;
  for (p = s; (prev_p = strsep (&p, ".")) != NULL; )
    {
      key = _gst_intern_string (prev_p);
      result = dictionary_at (result, key);
      if (IS_NIL (result))
	return NULL;
    }

  free (s);
  return (result);
}


OOP
_gst_uint_to_oop (unsigned long int i)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (FROM_C_ULONG (i));
}

OOP
_gst_int_to_oop (long int i)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (FROM_C_LONG (i));
}

OOP
_gst_id_to_oop (long int i)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (OOP_AT (i));
}

OOP
_gst_long_double_to_oop (long double f)
{
  return (INC_ADD_OOP (floatq_new (f)));
}

OOP
_gst_float_to_oop (double f)
{
  return (INC_ADD_OOP (floatd_new (f)));
}

OOP
_gst_bool_to_oop (int b)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (b)
    return (_gst_true_oop);
  else
    return (_gst_false_oop);
}


OOP
_gst_char_to_oop (char c)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (CHAR_OOP_AT (c));
}

OOP
_gst_wchar_to_oop (wchar_t wc)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (char_new (wc));
}


/* !!! Add in byteArray support sometime soon */

OOP
_gst_string_to_oop (const char *str)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (str == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (_gst_string_new (str)));
}

OOP
_gst_wstring_to_oop (const wchar_t *str)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (str == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (_gst_unicode_string_new (str)));
}

OOP
_gst_byte_array_to_oop (const char *str,
			int n)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (str == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (_gst_byte_array_new (str, n)));
}

OOP
_gst_symbol_to_oop (const char *str)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (str == NULL)
    return (_gst_nil_oop);
  else
    /* Symbols don't get freed, so the new OOP doesn't need to be
       registered */
    return (_gst_intern_string (str));
}

OOP
_gst_c_object_to_oop (PTR co)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (co == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (COBJECT_NEW (co, _gst_nil_oop, _gst_c_object_class)));
}

void
_gst_set_c_object (OOP oop, PTR co)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  set_cobject_value (oop, co);
}


/***********************************************************************
 *
 *	Conversion *from* Smalltalk datatypes routines
 *
 ***********************************************************************/

/* ### need a type inquiry routine */

long
_gst_oop_to_c (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_C_LONG (oop) || IS_C_ULONG (oop))
    return (TO_C_LONG (oop));

  else if (OOP_CLASS (oop) == _gst_true_class
	   || OOP_CLASS (oop) == _gst_false_class)
    return (oop == _gst_true_oop);

  else if (OOP_CLASS (oop) == _gst_char_class
           || OOP_CLASS (oop) == _gst_unicode_character_class)
    return (CHAR_OOP_VALUE (oop));

  else if (IS_NIL (oop))
    return (0);

  else if (is_a_kind_of (OOP_CLASS (oop), _gst_c_object_class))
    return ((long) cobject_value (oop));

  else
    return (0);
}

long
_gst_oop_to_int (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (TO_C_LONG (oop));
}

long
_gst_oop_to_id (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (OOP_INDEX (oop));
}

double
_gst_oop_to_float (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_INT (oop))
    return (TO_INT (oop));
  else if (IS_CLASS (oop, _gst_floatd_class))
    return (FLOATD_OOP_VALUE (oop));
  else if (IS_CLASS (oop, _gst_floate_class))
    return (FLOATE_OOP_VALUE (oop));
  else if (IS_CLASS (oop, _gst_floatq_class))
    return (FLOATQ_OOP_VALUE (oop));
  else
    return 0.0 / 0.0;
}

long double
_gst_oop_to_long_double (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_INT (oop))
    return (TO_INT (oop));
  else if (IS_CLASS (oop, _gst_floatd_class))
    return (FLOATD_OOP_VALUE (oop));
  else if (IS_CLASS (oop, _gst_floate_class))
    return (FLOATE_OOP_VALUE (oop));
  else if (IS_CLASS (oop, _gst_floatq_class))
    return (FLOATQ_OOP_VALUE (oop));
  else
    return 0.0 / 0.0;
}

int
_gst_oop_to_bool (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (oop == _gst_true_oop);
}

char
_gst_oop_to_char (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (CHAR_OOP_VALUE (oop));
}

wchar_t
_gst_oop_to_wchar (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return (CHAR_OOP_VALUE (oop));
}

char *
_gst_oop_to_string (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_NIL (oop))
    return (NULL);
  else
    return ((char *) _gst_to_cstring (oop));
}

wchar_t *
_gst_oop_to_wstring (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_NIL (oop))
    return (NULL);
  else
    return ((wchar_t *) _gst_to_wide_cstring (oop));
}

char *
_gst_oop_to_byte_array (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_NIL (oop))
    return (NULL);
  else
    return ((char *) _gst_to_byte_array (oop));
}

PTR
_gst_oop_to_c_object (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_NIL (oop))
    return (NULL);
  else
    return (cobject_value (oop));
}

OOP
_gst_get_object_class (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return OOP_INT_CLASS (oop);
}

OOP
_gst_get_superclass (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  /* Quick tests for "class-ness".  */
  assert (IS_OOP (oop));
  assert (OOP_CLASS (oop) == _gst_behavior_class
	  || OOP_CLASS (OOP_CLASS (oop)) == _gst_metaclass_class);

  return SUPERCLASS (oop);
}

mst_Boolean
_gst_class_is_kind_of (OOP candidate, OOP superclass)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  /* Quick tests for "class-ness".  */
  assert (IS_OOP (candidate) && IS_OOP (superclass));
  assert (OOP_CLASS (candidate) == _gst_behavior_class
	  || OOP_CLASS (OOP_CLASS (candidate)) == _gst_metaclass_class);

  if (superclass == _gst_nil_oop || candidate == superclass)
    return true;

  assert (OOP_CLASS (superclass) == _gst_behavior_class
	  || OOP_CLASS (OOP_CLASS (superclass)) == _gst_metaclass_class);

  return is_a_kind_of (candidate, superclass);
}


mst_Boolean
_gst_object_is_kind_of (OOP candidate, OOP superclass)
{
  OOP its_class;
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  if (IS_INT (candidate))
    {
      its_class = _gst_small_integer_class;
      if (superclass == _gst_small_integer_class
	  || superclass == _gst_object_class)
	return true;
    }
  else
    its_class = OOP_CLASS (candidate);

  if (superclass == _gst_nil_oop || its_class == superclass)
    return true;

  /* Quick tests for "class-ness".  */
  assert (IS_OOP (superclass));
  assert (OOP_CLASS (superclass) == _gst_behavior_class
	  || OOP_CLASS (OOP_CLASS (superclass)) == _gst_metaclass_class);

  return is_a_kind_of (its_class, superclass);
}

OOP
_gst_perform (OOP receiver, OOP selector)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return _gst_nvmsg_send (receiver, selector, NULL, 0);
}

OOP
_gst_perform_with (OOP receiver, OOP selector, OOP arg)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return _gst_nvmsg_send (receiver, selector, &arg, 1);
}

mst_Boolean
_gst_class_implements_selector (OOP classOOP, OOP selector)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  assert (IS_OOP (classOOP));
  assert (OOP_CLASS (classOOP) == _gst_behavior_class
          || OOP_CLASS (OOP_CLASS (classOOP)) == _gst_metaclass_class);

  return _gst_find_class_method (classOOP, selector) != _gst_nil_oop;
}

mst_Boolean
_gst_class_can_understand (OOP classOOP, OOP selector)
{
  method_cache_entry dummy;
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  /* Quick test for "class-ness".  */
  assert (IS_OOP (classOOP));
  assert (OOP_CLASS (classOOP) == _gst_behavior_class
          || OOP_CLASS (OOP_CLASS (classOOP)) == _gst_metaclass_class);

  return _gst_find_method (classOOP, selector, &dummy);
}

mst_Boolean
_gst_responds_to (OOP oop, OOP selector)
{
  method_cache_entry dummy;
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return _gst_find_method (OOP_INT_CLASS (oop), selector, &dummy);
}

size_t
_gst_oop_size (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return NUM_INDEXABLE_FIELDS (oop);
}

OOP
_gst_oop_at (OOP oop, size_t index)
{
  OOP result;
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  result = index_oop (oop, index + 1);
  assert (result);
  return result;
}

OOP
_gst_oop_at_put (OOP oop, size_t index, OOP new)
{
  OOP old;
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  old = index_oop (oop, index + 1);
  assert (old);
  index_oop_put (oop, index + 1, new);
  return old;
}

void *
_gst_oop_indexed_base (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return &OOP_TO_OBJ (oop)->data[OOP_FIXED_FIELDS (oop)];
}

enum gst_indexed_kind
_gst_oop_indexed_kind (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    _gst_initialize (NULL, NULL, GST_NO_TTY);

  return OOP_INSTANCE_SPEC (oop) & ISP_INDEXEDVARS;
}



/***********************************************************************
 *
 *	Registry bookkeeping routines
 *
 ***********************************************************************/

OOP
_gst_register_oop (OOP oop)
{
  rb_node_t **p = (rb_node_t **) &oop_registry_root;
  oop_registry *node;
  oop_registry *entry = NULL;

  if (!oop || IS_NIL (oop))
    return (oop);

  while (*p)
    {
      entry = (oop_registry *) *p;

      if (oop < entry->oop)
	p = &(*p)->rb_left;
      else if (oop > entry->oop)
	p = &(*p)->rb_right;
      else
	{
	  entry->usage++;
	  return (oop);
	}
    }

  node = (oop_registry *) xmalloc(sizeof(oop_registry));
  node->rb.rb_parent = (rb_node_t *) entry;
  node->rb.rb_left = node->rb.rb_right = NULL;
  node->usage = 1;
  node->oop = oop;
  *p = &(node->rb);

  rb_rebalance(&node->rb, (rb_node_t **) &oop_registry_root);
  return (oop);
}

void
_gst_unregister_oop (OOP oop)
{
  oop_registry *entry = oop_registry_root;

  /* Speed things up, this will never be in the registry (but we allow
     it to simplify client code).  */
  if (!oop || IS_NIL (oop))
    return;

  while (entry)
    {
      if (entry->oop == oop) 
	{
	  if (!--entry->usage)
	    {
	      rb_erase (&entry->rb, (rb_node_t **) &oop_registry_root);
	      xfree (entry);
	    }
	  break;
	}
      
      entry = (oop_registry *) 
	(oop < entry->oop ? entry->rb.rb_left : entry->rb.rb_right);
    }
}


void
_gst_register_oop_array (OOP **first, OOP **last)
{
  rb_node_t **p = (rb_node_t **) &oop_array_registry_root;
  oop_array_registry *node;
  oop_array_registry *entry = NULL;

  while (*p)
    {
      entry = (oop_array_registry *) *p;

      if (first < entry->first)
	p = &(*p)->rb_left;
      else if (first > entry->first)
	p = &(*p)->rb_right;
      else
	entry->usage++;
    }

  node = (oop_array_registry *) xmalloc(sizeof(oop_array_registry));
  node->rb.rb_parent = (rb_node_t *) entry;
  node->rb.rb_left = node->rb.rb_right = NULL;
  node->usage = 1;
  node->first = first;
  node->last = last;
  *p = &(node->rb);

  rb_rebalance(&node->rb, (rb_node_t **) &oop_array_registry_root);
}

void
_gst_unregister_oop_array (OOP **first)
{
  oop_array_registry *entry = oop_array_registry_root;

  while (entry)
    {
      if (entry->first == first) 
	{
	  if (!--entry->usage)
	    {
	      rb_erase (&entry->rb, (rb_node_t **) &oop_array_registry_root);
	      xfree (entry);
	    }
	  break;
	}
      
      entry = (oop_array_registry *) 
	(first < entry->first ? entry->rb.rb_left : entry->rb.rb_right);
    }
}


void
_gst_copy_registered_oops (void)
{
  rb_node_t *node;
  rb_traverse_t t;

  /* Walk the OOP registry...  */
  for (node = rb_first(&(oop_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_registry *k = (oop_registry *) node;
      MAYBE_COPY_OOP (k->oop);
    }

  /* ...and then the OOP-array registry.  */
  for (node = rb_first(&(oop_array_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_array_registry *k = (oop_array_registry *) node;

      /* Dereference the pointers in the tree to obtain where the array
	 lies.  */
      OOP *first = *(k->first);
      OOP *last = *(k->last);
      _gst_copy_oop_range (first, last);
    }
}

void
_gst_mark_registered_oops (void)
{
  rb_node_t *node;
  rb_traverse_t t;

  /* Walk the OOP registry...  */
  for (node = rb_first(&(oop_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_registry *k = (oop_registry *) node;
      MAYBE_MARK_OOP (k->oop);
    }

  /* ...and then the OOP-array registry.  */
  for (node = rb_first(&(oop_array_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_array_registry *k = (oop_array_registry *) node;

      /* Dereference the pointers in the tree to obtain where the array
	 lies.  */
      OOP *first = *(k->first);
      OOP *last = *(k->last);
      _gst_mark_oop_range (first, last);
    }
}

void
_gst_init_vmproxy (void)
{
  gst_interpreter_proxy.nilOOP = _gst_nil_oop;
  gst_interpreter_proxy.trueOOP = _gst_true_oop;
  gst_interpreter_proxy.falseOOP = _gst_false_oop;

  gst_interpreter_proxy.objectClass = _gst_object_class;
  gst_interpreter_proxy.arrayClass = _gst_array_class;
  gst_interpreter_proxy.stringClass = _gst_string_class;
  gst_interpreter_proxy.characterClass = _gst_char_class;
  gst_interpreter_proxy.smallIntegerClass = _gst_small_integer_class;
  gst_interpreter_proxy.floatDClass = _gst_floatd_class;
  gst_interpreter_proxy.floatEClass = _gst_floate_class;
  gst_interpreter_proxy.byteArrayClass = _gst_byte_array_class;
  gst_interpreter_proxy.objectMemoryClass = _gst_object_memory_class;
  gst_interpreter_proxy.classClass = _gst_class_class;
  gst_interpreter_proxy.behaviorClass = _gst_behavior_class;
  gst_interpreter_proxy.blockClosureClass = _gst_block_closure_class;
  gst_interpreter_proxy.contextPartClass = _gst_context_part_class;
  gst_interpreter_proxy.blockContextClass = _gst_block_context_class;
  gst_interpreter_proxy.methodContextClass = _gst_method_context_class;
  gst_interpreter_proxy.compiledMethodClass = _gst_compiled_method_class;
  gst_interpreter_proxy.compiledBlockClass = _gst_compiled_block_class;
  gst_interpreter_proxy.fileDescriptorClass = _gst_file_descriptor_class;
  gst_interpreter_proxy.fileStreamClass = _gst_file_stream_class;
  gst_interpreter_proxy.processClass = _gst_process_class;
  gst_interpreter_proxy.semaphoreClass = _gst_semaphore_class;
  gst_interpreter_proxy.cObjectClass = _gst_c_object_class;

  /* And system objects.  */
  gst_interpreter_proxy.processorOOP = _gst_processor_oop;
}

struct VMProxy *
_gst_get_vmproxy (void)
{
  struct VMProxy *result;

  result = xmalloc (sizeof (struct VMProxy));
  memcpy (result, &gst_interpreter_proxy, sizeof (struct VMProxy));
  return result;
}
