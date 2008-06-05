/******************************** -*- C -*- ****************************
 *
 *	Smalltalk->C bridge functions for OpenGL bindings.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini and Olivier Blanc.
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/

#include "gstopengl.h"
#include <limits.h>
#include <stdio.h>
#include <string.h>

VMProxy *vm_proxy = NULL;

void
gst_opengl_scale_array (GLfloat *dest, OOP sourceOOP)
{
  enum gst_indexed_kind kind;
  int i, n;

  n = vm_proxy->basicSize (sourceOOP);
  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  switch (kind)
    {

#define SCALE(min, max)							  \
  for (i = 0; i < n; i++)						  \
    if (min == 0)							  \
      dest[i] = (dest[i] - (float)(min)) / ((float)(max) - (float)(min)); \
    else								  \
      dest[i] = (dest[i] - (float)(min)) / ((float)(max) - (float)(min))  \
		* 2.0 - 1.0;						  \
  break;

      case GST_ISP_SCHAR:
	SCALE (SCHAR_MIN, SCHAR_MAX);
      case GST_ISP_UCHAR:
	SCALE (0, UCHAR_MAX);
      case GST_ISP_SHORT:
	SCALE (SHRT_MIN, SHRT_MAX);
      case GST_ISP_USHORT:
	SCALE (0, USHRT_MAX);
      case GST_ISP_INT:
	SCALE (INT_MIN, INT_MAX);
      case GST_ISP_UINT:
	SCALE (0, UINT_MAX);
      default:
	break;
    }
}

GLdouble *
gst_opengl_oop_to_dbl_array (GLdouble *dest, OOP sourceOOP, int n)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, size;

  size = vm_proxy->basicSize (sourceOOP);
  if (size < n)
    return NULL;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
	LOOP (signed char);
      case GST_ISP_UCHAR:
	LOOP (unsigned char);
      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
	LOOP (int);
      case GST_ISP_UINT:
	LOOP (unsigned int);
      case GST_ISP_FLOAT:
	LOOP (float);
      case GST_ISP_DOUBLE:
	return base;

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = vm_proxy->OOPToFloat (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}

GLfloat *
gst_opengl_oop_to_array_2 (GLfloat *dest, OOP sourceOOP, int min, int max)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, n;

  n = vm_proxy->basicSize (sourceOOP);
  if (n < min)
    return NULL;
  if (n > max)
    n = max;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
	LOOP (signed char);
      case GST_ISP_UCHAR:
	LOOP (unsigned char);
      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
	LOOP (int);
      case GST_ISP_UINT:
	LOOP (unsigned int);
      case GST_ISP_FLOAT:
	if (n == max)
	  return base;
	LOOP (float);
      case GST_ISP_DOUBLE:
	LOOP (double);

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = vm_proxy->OOPToFloat (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}

GLfloat *
gst_opengl_oop_to_array (GLfloat *dest, OOP sourceOOP, int n)
{
  return gst_opengl_oop_to_array_2 (dest, sourceOOP, n, n);
}

GLint *
gst_opengl_oop_to_int_array (GLint *dest, OOP sourceOOP, int n)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, size;

  size = vm_proxy->basicSize (sourceOOP);
  if (size < n)
    return NULL;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
	LOOP (signed char);
      case GST_ISP_UCHAR:
	LOOP (unsigned char);
      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
      case GST_ISP_UINT:
	return base;
      case GST_ISP_FLOAT:
	LOOP (float);
      case GST_ISP_DOUBLE:
	LOOP (double);

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = vm_proxy->OOPToC (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}

GLubyte *
gst_opengl_oop_to_ubyte_array (GLubyte *dest, OOP sourceOOP, int n)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, size;

  size = vm_proxy->basicSize (sourceOOP);
  if (size < n)
    return NULL;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
      case GST_ISP_UCHAR:
	return base;

      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
	LOOP (int);
      case GST_ISP_UINT:
 	LOOP (unsigned int);
      case GST_ISP_FLOAT:
	LOOP (float);
      case GST_ISP_DOUBLE:
	LOOP (double);

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = (GLubyte)vm_proxy->OOPToC (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}

size_t
gst_opengl_get_type_size (GLenum type)
{
  switch (type)
    {
    case GL_BYTE:
    case GL_UNSIGNED_BYTE:
      return sizeof (GLubyte);

    case GL_SHORT:
    case GL_UNSIGNED_SHORT:
      return sizeof (GLshort);

    case GL_INT:
    case GL_UNSIGNED_INT:
      return sizeof (GLint);

    case GL_FLOAT:
      return sizeof (GLfloat);

    case GL_DOUBLE:
      return sizeof (GLdouble);

    case GL_2_BYTES:
      /* lists is treated as an array of unsigned bytes.
         Each pair of bytes specifies a single display-list name.
         The value of the pair is computed as 256 times the unsigned value
         of the first byte plus the unsigned value of the second byte. */
      return sizeof (GLubyte);

    case GL_3_BYTES:
      /* lists is treated as an array of unsigned bytes.
         Each triplet of bytes specifies a single display-list name.
         The value of the triplet is computed as 65536 times the unsigned value
         of the first byte, plus 256 times the unsigned value of the second byte,
         plus the unsigned value of the third byte. */
      return sizeof (GLubyte);

    case GL_4_BYTES:
      return sizeof (GLubyte);
    }
  return 0;
}

GLenum
gst_opengl_get_gl_type (OOP sourceOOP)
{
  enum gst_indexed_kind kind;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);

  switch (kind)
    {
    case GST_ISP_SCHAR:
      return GL_BYTE;
      break;
    case GST_ISP_CHARACTER:
    case GST_ISP_UCHAR:
      return GL_UNSIGNED_BYTE;
      break;
    case GST_ISP_SHORT:
      return GL_SHORT;
      break;
    case GST_ISP_USHORT:
      return GL_UNSIGNED_SHORT;
      break;
    case GST_ISP_INT:
      return GL_INT;
      break;
    case GST_ISP_UINT:
      return GL_UNSIGNED_INT;
      break;
    case GST_ISP_FLOAT:
      return GL_FLOAT;
      break;
    case GST_ISP_DOUBLE:
      return GL_DOUBLE;
      break;
    default:
      return -1;
    }
}


void
gst_initModule(VMProxy *proxy)
{
  vm_proxy = proxy;

  gst_initModule_gl ();
  gst_initModule_glu ();
}

