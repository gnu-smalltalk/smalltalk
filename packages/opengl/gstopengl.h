/******************************** -*- C -*- ****************************
 *
 *	OpenGL bindings header file
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

#ifndef GSTOPENGL_H
#define GSTOPENGL_H 1

#include "config.h"
#include "gstpub.h"

#include GL_GL_H
#include GL_GLU_H

/* Internal convenience typedefs, same as _GLUfuncptr which is
   not provided by Apple's glu.h. */
#ifdef __cplusplus
typedef GLvoid (*GLUfuncptr)();
#else
typedef GLvoid (*GLUfuncptr)(GLvoid);
#endif 

extern VMProxy *vm_proxy;

extern void gst_initModule_gluNurbs (void);
extern void gst_initModule_gluTess (void);
extern void gst_initModule_glu (void);
extern void gst_initModule_gl (void);

extern int gst_opengl_glMap_size (GLenum target);
extern int gst_opengl_glVertexv (OOP);

extern void gst_opengl_scale_array (GLfloat *, OOP);
extern GLfloat *gst_opengl_oop_to_array_2 (GLfloat *, OOP, int, int);
extern GLfloat *gst_opengl_oop_to_array (GLfloat *, OOP, int);
extern GLint *gst_opengl_oop_to_int_array (GLint *, OOP, int);
extern GLdouble *gst_opengl_oop_to_dbl_array (GLdouble *, OOP, int);
extern GLubyte *gst_opengl_oop_to_ubyte_array (GLubyte *, OOP, int);
extern size_t gst_opengl_get_type_size (GLenum type);
extern GLenum gst_opengl_get_gl_type (OOP sourceOOP);

#endif
