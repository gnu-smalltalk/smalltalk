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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/

#include "gstpriv.h"

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
   that OOPs that C code knows about don't go away. */
static oop_registry *oop_registry_root;
static oop_array_registry *oop_array_registry_root;

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
  _gst_oop_to_string, _gst_oop_to_byte_array, _gst_oop_to_cobject,

/* Smalltalk process support */
  _gst_async_signal, _gst_sync_wait, _gst_async_signal_and_unregister,

  _gst_register_oop_array, _gst_unregister_oop_array
};

OOP
_gst_msg_send (OOP receiver,
	       OOP selector,
	       ...)
{
  va_list ap, save;
  OOP *args, anArg;
  int numArgs;

  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  va_start (ap, selector);

#ifdef __va_copy
  __va_copy (save, ap);
#else
  save = ap;
#endif

  for (numArgs = 0; (anArg = va_arg (ap, OOP)) != NULL; numArgs++);

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
_gst_vmsg_send (OOP receiver,
		OOP selector,
		OOP * args)
{
  int numArgs;

  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

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
  va_list ap, save;
  OOP *args, anArg;
  int numArgs;
  OOP selector;

  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  va_start (ap, sel);
  selector = _gst_intern_string (sel);

#ifdef __va_copy
  __va_copy (save, ap);
#else
  save = ap;
#endif

  for (numArgs = 0; (anArg = va_arg (ap, OOP)) != NULL; numArgs++);

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

/* Use like printf */
void
_gst_msg_sendf (PTR resultPtr, 
		const char *fmt, 
		...)
{
  va_list ap;
  OOP selector, *args, result;
  int i, numArgs;
  const char *fp;
  char *s, selectorBuf[256];
  inc_ptr incPtr;

  va_start (ap, fmt);

  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

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
	}
      else if (*fp != ' ' && *fp != '\t')
	*s++ = *fp;
    }

  *s = '\0';

  selector = _gst_intern_string (selectorBuf);

  if (numArgs != 1 + _gst_selector_num_args (selector))
    return;

  args = (OOP *) alloca (sizeof (OOP) * numArgs);
  for (i = -1, s = selectorBuf, fp = &fmt[2]; *fp; fp++)
    {
      if (*fp != '%')
	continue;

      fp++;
      switch (*fp)
        {
        case 'i':
          args[++i] = FROM_INT (va_arg (ap, long));
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
          args[++i] = COBJECT_NEW (va_arg (ap, PTR));
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

        case 'o':
          args[++i] = va_arg (ap, OOP);
	  INC_ADD_OOP (args[i]);
          break;

        case 't':		/* type string, followed by a void * */
          {
	    OOP ctype;
	    ctype = _gst_type_name_to_oop (va_arg (ap, const char *));
	    INC_ADD_OOP (ctype);

	    args[++i] =
	      _gst_c_object_new_typed (va_arg (ap, PTR), ctype);

	    INC_ADD_OOP (args[i]);
          }
          break;


        case 'T':		/* existing type instance, and a void * */
          {
    	    OOP ctype;
    	    ctype = va_arg (ap, OOP);
    	    args[++i] =
    	      _gst_c_object_new_typed (va_arg (ap, PTR), ctype);

	    INC_ADD_OOP (args[i]);
          }
          break;
	}
    }

  result = _gst_nvmsg_send (args[0], selector, args + 1, numArgs - 1);

  if (resultPtr)
    {
      switch (fmt[1])
	{
	case 'i':
	  *(int *) resultPtr = IS_NIL (result) ? 0 : TO_INT (result);
	  break;

	case 'c':
	  *(char *) resultPtr =
	    IS_NIL (result) ? 0 : CHAR_OOP_VALUE (result);
	  break;

	case 'C':
	  /* !!! Fix this -- it is ugly, but OS/2 compilers don't like
	     it without */
	  *(PTR *) resultPtr =
	    IS_NIL (result) ? NULL : COBJECT_VALUE (result);
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

	case 'v':		/* don't care about the result */
	  break;		/* "v" for "void" */

	case '?':
	  *(long *) resultPtr = _gst_oop_to_c (result);
	  break;

	case 'o':
	default:
	  *(OOP *) resultPtr = result;
	  break;
	}
    }

  INC_RESTORE_POINTER (incPtr);
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
    gst_init_smalltalk ();

  _gst_compile_code = true;
  _gst_push_cstring (str);
  _gst_parse_stream ();
  _gst_pop_stream (true);
}


OOP
_gst_eval_expr (const char *str)
{
  OOP result;

  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  _gst_compile_code = false;
  _gst_push_cstring (str);
  _gst_parse_stream ();
  _gst_pop_stream (true);
  result = _gst_last_returned_value;

  return (result);
}

OOP
_gst_object_alloc (OOP class_oop,
		   int size)
{
  OOP oop;

  if (CLASS_IS_INDEXABLE (class_oop))
    instantiate_with (class_oop, (unsigned long) size, &oop);
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

  key = _gst_symbol_to_oop (name);	/* this inits Smalltalk */
  result = dictionary_at (_gst_smalltalk_dictionary, key);
  return (result);
}


OOP
_gst_int_to_oop (long int i)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  return (FROM_INT (i));
}

OOP
_gst_id_to_oop (long int i)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  return (OOP_AT (i));
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
    gst_init_smalltalk ();

  if (b)
    return (_gst_true_oop);
  else
    return (_gst_false_oop);
}


OOP
_gst_char_to_oop (char c)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  return (CHAR_OOP_AT (c));
}


/* !!! Add in byteArray support sometime soon */

OOP
_gst_string_to_oop (const char *str)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (str == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (_gst_string_new (str)));
}

OOP
_gst_byte_array_to_oop (const char *str,
			int n)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (str == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (_gst_byte_array_new (str, n)));
}

OOP
_gst_symbol_to_oop (const char *str)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

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
    gst_init_smalltalk ();

  if (co == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (COBJECT_NEW (co)));
}

void
_gst_set_c_object (OOP oop, PTR co)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  SET_COBJECT_VALUE(oop, co);
}

OOP
_gst_c_object_to_typed_oop (PTR co,
			    OOP typeOOP)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (co == NULL)
    return (_gst_nil_oop);
  else
    return (INC_ADD_OOP (_gst_c_object_new_typed (co, typeOOP)));
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
    gst_init_smalltalk ();

  if (IS_INT (oop))
    return (TO_INT (oop));

  else if (OOP_CLASS (oop) == _gst_true_class
	   || OOP_CLASS (oop) == _gst_false_class)
    return (oop == _gst_true_oop);

  else if (OOP_CLASS (oop) == _gst_char_class)
    return (CHAR_OOP_VALUE (oop));

  else if (IS_NIL (oop))
    return (0);

  else if (is_a_kind_of (OOP_CLASS (oop), _gst_c_object_class))
    return ((long) COBJECT_VALUE (oop));

  else
    return (0);
}

long
_gst_oop_to_int (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  return (TO_INT (oop));
}

long
_gst_oop_to_id (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  return (OOP_INDEX (oop));
}

double
_gst_oop_to_float (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (IS_CLASS (oop, _gst_floatd_class))
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
    gst_init_smalltalk ();

  return (oop == _gst_true_oop);
}

char
_gst_oop_to_char (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  return (CHAR_OOP_VALUE (oop));
}

char *
_gst_oop_to_string (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (IS_NIL (oop))
    return (NULL);
  else
    return ((char *) _gst_to_cstring (oop));
}

char *
_gst_oop_to_byte_array (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (IS_NIL (oop))
    return (NULL);
  else
    return ((char *) _gst_to_byte_array (oop));
}

PTR
_gst_oop_to_cobject (OOP oop)
{
  if (!_gst_smalltalk_initialized)
    gst_init_smalltalk ();

  if (IS_NIL (oop))
    return (NULL);
  else
    return (COBJECT_VALUE (oop));
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

  if (!oop)
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
     it to simplify client code). */
  if (!oop)
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

  /* Walk the OOP registry... */
  for (node = rb_first(&(oop_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_registry *k = (oop_registry *) node;
      MAYBE_COPY_OOP (k->oop);
    }

  /* ...and then the OOP-array registry. */
  for (node = rb_first(&(oop_array_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_array_registry *k = (oop_array_registry *) node;

      /* Dereference the pointers in the tree to obtain where the array
	 lies. */
      OOP *first = *(k->first);
      OOP *last = *(k->last);
      COPY_OOP_RANGE (first, last);
    }
}

void
_gst_mark_registered_oops (void)
{
  rb_node_t *node;
  rb_traverse_t t;

  /* Walk the OOP registry... */
  for (node = rb_first(&(oop_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_registry *k = (oop_registry *) node;
      MAYBE_MARK_OOP (k->oop);
    }

  /* ...and then the OOP-array registry. */
  for (node = rb_first(&(oop_array_registry_root->rb), &t); 
       node; node = rb_next(&t))
    {
      oop_array_registry *k = (oop_array_registry *) node;

      /* Dereference the pointers in the tree to obtain where the array
	 lies. */
      OOP *first = *(k->first);
      OOP *last = *(k->last);
      MARK_OOP_RANGE (first, last);
    }
}

void
_gst_init_vmproxy (void)
{
  gst_interpreter_proxy.nilOOP = _gst_nil_oop;
  gst_interpreter_proxy.trueOOP = _gst_true_oop;
  gst_interpreter_proxy.falseOOP = _gst_false_oop;
}
