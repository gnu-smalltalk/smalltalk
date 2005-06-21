/******************************** -*- C -*- ****************************
 *
 *	OOP printing and debugging module
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
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


#include "gstpriv.h"
#include "snprintfv/mem.h"


/* Print a String OOP to a snprintfv stream, STREAM.  */
static void print_string_to_stream (STREAM *stream,
				    OOP string);

/* Print an Association OOP's key to a snprintfv stream, STREAM.  */
static void print_association_key_to_stream (STREAM *stream,
					     OOP associationOOP);

/* Print a Class OOP's name to a snprintfv stream, STREAM.  */
static void print_class_name_to_stream (STREAM *stream,
					OOP class_oop);

/* Print a brief description of an OOP to a snprintfv stream, STREAM.  */
static void print_oop_constructor_to_stream (STREAM *stream,
					     OOP oop);

/* The main routine to handle the %O modifier to printf.  %#O prints
   Strings and Symbols without the leading # or the enclosing single
   quotes, while %+O expects that an Association is passed and prints
   its key.  */
static void printf_oop (STREAM *stream,
		        struct printf_info *info,
        		const void *const *args);

static int printf_oop_arginfo (struct printf_info *info,
			       size_t n,
                               int *argtypes);



void
_gst_print_object (OOP oop)
{
  printf ("%O", oop);
  fflush (stdout);
}

void
print_string_to_stream (STREAM *stream, OOP string)
{
  int len;

  len = _gst_string_oop_len (string);
  if (!len)
    return;

  stream_printf (stream, "%.*s", len, (char *) (OOP_TO_OBJ (string)->data));
}

void
print_association_key_to_stream (STREAM *stream, OOP associationOOP)
{
  gst_association association;

  if (!IS_OOP (associationOOP)
      || !is_a_kind_of (OOP_CLASS(associationOOP), _gst_association_class))
    {
      stream_printf (stream, "<non-association %O in association context>",
                     associationOOP);
      return;
    }

  association = (gst_association) OOP_TO_OBJ (associationOOP);
  if (OOP_CLASS (association->key) != _gst_symbol_class)
    stream_printf (stream, "<unprintable key type>");
  else
    stream_printf (stream, "%#O", association->key);
}

void
print_class_name_to_stream (STREAM *stream, OOP class_oop)
{
  gst_class class;
  class = (gst_class) OOP_TO_OBJ (class_oop);
  if (IS_A_CLASS (class_oop) && !IS_NIL (class->name))
    print_string_to_stream (stream, class->name);
  else if (IS_A_CLASS (OOP_CLASS (class_oop)))
    {
      stream_printf (stream, "<unnamed ");
      print_class_name_to_stream (stream, OOP_CLASS (class_oop));
      stream_printf (stream, ">");
    }
  else
    stream_printf (stream, "<unnamed class>");
}

void
print_oop_constructor_to_stream (STREAM *stream, OOP oop)
{
  long instanceSpec;
  OOP class_oop;

  class_oop = OOP_CLASS (oop);
  print_class_name_to_stream (stream, class_oop);

  instanceSpec = CLASS_INSTANCE_SPEC (class_oop);
  if (instanceSpec & ISP_ISINDEXABLE)
    stream_printf (stream, " new: %ld ", NUM_INDEXABLE_FIELDS (oop));

  else
    stream_printf (stream, " new ");

  if (_gst_regression_testing)
    stream_printf (stream, "\"<0>\"");
  else
    stream_printf (stream, "\"<%#lx>\"", (unsigned long) oop);
}

void
printf_oop (STREAM *stream,
	    struct printf_info *info,
            const void *const *args)
{
  OOP oop = (OOP) (args[0]);

  if (info->showsign)
    {
      print_association_key_to_stream (stream, oop);
      return;
    }

  if (IS_INT (oop))
    stream_printf (stream, "%ld", TO_INT (oop));

  else if (IS_NIL (oop))
    stream_printf (stream, "nil");

  else if (oop == _gst_true_oop)
    stream_printf (stream, "true");

  else if (oop == _gst_false_oop)
    stream_printf (stream, "false");

  else if (OOP_CLASS (oop) == _gst_char_class)
    stream_printf (stream, "$%c", CHAR_OOP_VALUE (oop));

  else if (OOP_CLASS (oop) == _gst_floatd_class)
    {
      double f = FLOATD_OOP_VALUE (oop);
      char buf[100], *p;
      p = buf + sprintf (buf, "%#.*g",
			 (_gst_regression_testing ? 6 : DBL_DIG), f);
      for (; p >= buf; p--)
        if (*p == 'e')
	  {
	    *p = 'd';
	    break;
	  }

      stream_puts (buf, stream);
    }

  else if (OOP_CLASS (oop) == _gst_floate_class)
    {
      double f = FLOATE_OOP_VALUE (oop);
      stream_printf (stream, "%#.*g",
		     (_gst_regression_testing ? 6 : FLT_DIG), f);
    }

  else if (OOP_CLASS (oop) == _gst_floatq_class)
    {
      long double f = FLOATQ_OOP_VALUE (oop);
      char buf[100], *p;
      p = buf + sprintf (buf, "%#.*Lg",
			 (_gst_regression_testing ? 6 : LDBL_DIG), f);
      for (; p >= buf; p--)
        if (*p == 'e')
	  {
	    *p = 'q';
	    break;
	  }

      stream_puts (buf, stream);
    }

  else if (OOP_CLASS (oop) == _gst_symbol_class)
    {
      if (!info->alt)
	stream_printf (stream, "#");
      print_string_to_stream (stream, oop);
    }

  else if (OOP_CLASS (oop) == _gst_string_class)
    {
      /* ### have to quote embedded quote chars */
      if (!info->alt)
        stream_printf (stream, "'");
      print_string_to_stream (stream, oop);
      if (!info->alt)
        stream_printf (stream, "'");
    }

  else if (IS_A_METACLASS (oop))
    {
      OOP class_oop = _gst_find_an_instance (oop);
      if (IS_NIL (class_oop))
        print_oop_constructor_to_stream (stream, oop);
      else
	{
	  print_class_name_to_stream (stream, class_oop);
	  stream_printf (stream, " class");
	}
    }

  else if (IS_A_CLASS (oop))
    print_class_name_to_stream (stream, oop);

  else
    print_oop_constructor_to_stream (stream, oop);

  fflush (stdout);
}

int
printf_oop_arginfo (struct printf_info *info,
		    size_t n,
		    int *argtypes)
{
  /* We always take exactly one argument and this is a pointer to the
     structure.. */
  if (n > 0)
    argtypes[0] = PA_POINTER;
  return 1;
}


void
_gst_classify_addr (void *addr)
{
  if (IS_INT (addr))
    printf ("Smalltalk SmallInteger %ld\n", TO_INT (addr));

  else if (IS_OOP_ADDR (addr))
    _gst_display_oop (addr);

  else
    _gst_display_object (addr);

  fflush (stdout);
}

void
_gst_display_oop_short (OOP oop)
{
  if (oop->flags & F_FREE)
    printf ("%-10p   Free\n", oop);
  else
    {
      printf ("%-10p   %-10p  %-10s %-10s %-10s\n", oop, oop->object,
            oop->flags & F_CONTEXT ? "Context" :
            oop->flags & F_WEAK ? "Weak" :
            oop->flags & F_EPHEMERON ? "Ephemeron" : "",

            oop->flags & _gst_mem.active_flag ? "To-space" :
            oop->flags & F_FIXED ? "Fixed" :
            oop->flags & F_OLD ? "Old" : "From-space",

	    IS_EDEN_ADDR (oop->object) ? "Eden" :
	    IS_SURVIVOR_ADDR (oop->object, 0) ? "Surv (Even)" :
	    IS_SURVIVOR_ADDR (oop->object, 1) ? "Surv (Odd)" :
            oop->flags & F_POOLED ? "Pooled" :
	    oop->flags & F_REACHABLE ? "Old/marked" : "Old");
    }
}

void
_gst_display_oop (OOP oop)
{
  if (!IS_OOP_ADDR (oop))
    {
      printf ("Parameter %p does not appear to be an OOP!\n", oop);
      return;
    }

  if (oop->flags & F_FREE)
    printf ("%-10p   Free\n", oop);
  else
    {
      printf ("%-10p   %-10p  %-10s %-10s %-10s", oop, oop->object,
            oop->flags & F_CONTEXT ? "Context" :
            oop->flags & F_WEAK ? "Weak" :
            oop->flags & F_EPHEMERON ? "Ephemeron" : "",

            oop->flags & _gst_mem.active_flag ? "To-space" :
            oop->flags & F_FIXED ? "Fixed" :
            oop->flags & F_OLD ? "Old" : "From-space",

	    IS_EDEN_ADDR (oop->object) ? "Eden" :
	    IS_SURVIVOR_ADDR (oop->object, 0) ? "Surv (Even)" :
	    IS_SURVIVOR_ADDR (oop->object, 1) ? "Surv (Odd)" :
            oop->flags & F_POOLED ? "Pooled" :
	    oop->flags & F_REACHABLE ? "Old/marked" : "Old");

      if (IS_OOP_ADDR (oop->object->objClass))
        printf ("   %O (%O)\n", oop->object->objClass, oop->object->objSize);
      else
        printf ("   (invalid class)\n");
    }
}

void
_gst_display_object (mst_Object obj)
{
  if (IS_OOP_ADDR (obj))
    {
      printf ("Parameter %p appears to be an OOP!\n", obj);
      return;
    }

  printf ("Object at %p (%s)",
	  IS_EDEN_ADDR (obj) ? "Eden" :
	  IS_SURVIVOR_ADDR (obj, 0) ? "Even" :
	  IS_SURVIVOR_ADDR (obj, 1) ? "Odd" : "Old");

  if (IS_OOP_ADDR (obj->objClass))
    printf (", size %O (%ld OOPs), class %O\n",
	    obj->objSize, NUM_OOPS (obj), obj->objClass);
  else
    printf (", contains invalid data\n");
}



void _gst_init_snprintfv ()
{
  spec_entry *spec;

  snv_malloc = xmalloc;
  snv_realloc = xrealloc;
  snv_free = xfree;
  spec = register_printf_function ('O', printf_generic,
				   printf_oop_arginfo);

  spec->user = printf_oop;
}

