/******************************** -*- C -*- ****************************
 *
 *	OpenGLU gluNurbs bindings.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008, 2009 Free Software Foundation, Inc.
 * Written by Olivier Blanc.
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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef GLU_NURBS_BEGIN

#define nil  vm_proxy->nilOOP

/* Send the callback message to the receiver */
void gst_glu_nurbCallback_sendMessageTo (OOP receiver, GLenum which,
					 OOP* args, int nArgs)
{
  OOP aBlock;			/* Callback's block */

  /* Retreive the callback block */
  vm_proxy->msgSendf (&aBlock, "%o %o getCallback: %i", receiver, which);
  if (aBlock != nil)
    vm_proxy->nvmsgSend(aBlock, NULL, args, nArgs);
}

void gst_glu_nurbCallback_Nurbs_Begin_Data ( GLenum type, void* data )
{
  OOP args[1];
  args[0] = vm_proxy->intToOOP(type);
  gst_glu_nurbCallback_sendMessageTo((OOP)data, GLU_NURBS_BEGIN, args, 1);
}

void gst_glu_nurbCallback_Nurbs_Vertex_Data ( GLfloat* vertex, void* data )
{
  OOP args[3];
  args[0] = vm_proxy->floatToOOP( vertex[0] );
  args[1] = vm_proxy->floatToOOP( vertex[1] );
  args[2] = vm_proxy->floatToOOP( vertex[2] );
  gst_glu_nurbCallback_sendMessageTo((OOP)data, GLU_NURBS_VERTEX, args, 3);
}

void gst_glu_nurbCallback_Nurbs_Normal_Data ( GLfloat* normal, void* data )
{
  OOP args[3];
  args[0] = vm_proxy->floatToOOP( normal[0] );
  args[1] = vm_proxy->floatToOOP( normal[1] );
  args[2] = vm_proxy->floatToOOP( normal[2] );
  gst_glu_nurbCallback_sendMessageTo((OOP)data, GLU_NURBS_NORMAL, args, 3);
}

void gst_glu_nurbCallback_Nurbs_Color_Data ( GLfloat* color, void* data)
{
  OOP args[3];
  args[0] = vm_proxy->floatToOOP( color[0] );
  args[1] = vm_proxy->floatToOOP( color[1] );
  args[2] = vm_proxy->floatToOOP( color[2] );
  gst_glu_nurbCallback_sendMessageTo((OOP)data, GLU_NURBS_COLOR, args, 3);
}

void gst_glu_nurbCallback_Nurbs_Texture_Coord_Data ( GLfloat* tCrd, void* data )
{
  OOP args[3];
  args[0] = vm_proxy->floatToOOP( tCrd[0] );
  args[1] = vm_proxy->floatToOOP( tCrd[1] );
  args[2] = vm_proxy->floatToOOP( tCrd[2] );
  gst_glu_nurbCallback_sendMessageTo((OOP)data, GLU_NURBS_TEXTURE_COORD, args, 3);
}

void gst_glu_nurbCallback_Nurbs_End_Data (void* data )
{
  gst_glu_nurbCallback_sendMessageTo((OOP)data, GLU_NURBS_END, NULL, 0);
}

/* Pointers to the Glu Nurbs callback functions */
struct gst_glu_callback {
  GLenum which;
  GLenum whichData;
  GLUfuncptr func;
};

/* Number of known callbacks */
#define N_GLU_CALLBACKS 6

static struct gst_glu_callback gst_glu_nurbCallbackFuncs[] = {
  { GLU_NURBS_BEGIN, GLU_NURBS_BEGIN_DATA,
    (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Begin_Data },
  { GLU_NURBS_VERTEX, GLU_NURBS_VERTEX_DATA,
    (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Vertex_Data },
  { GLU_NURBS_NORMAL, GLU_NURBS_NORMAL_DATA,
    (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Normal_Data },
  { GLU_NURBS_COLOR, GLU_NURBS_COLOR_DATA,
    (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Color_Data },
  { GLU_NURBS_TEXTURE_COORD, GLU_NURBS_TEXTURE_COORD_DATA,
    (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Texture_Coord_Data },
  { GLU_NURBS_END, GLU_NURBS_END_DATA,
    (GLUfuncptr) gst_glu_nurbCallback_Nurbs_End_Data }
};

/* Retreive the callback index from the Callback contant definition */
struct gst_glu_callback *gst_glu_nurb_getCallbackIndex(GLenum which)
{
  int i;
  for (i = 0; i < N_GLU_CALLBACKS; ++i)
	/* If function is found, return index */
	if (gst_glu_nurbCallbackFuncs[i].which == which)
	  return &gst_glu_nurbCallbackFuncs[i];

  return (struct gst_glu_callback *) NULL;
}


void
gst_opengl_gluNurbsConnectSignal (OOP nurbOOP, GLenum which)
{
  struct gst_glu_callback *cb_data = gst_glu_nurb_getCallbackIndex (which);
  GLUnurbs *nurb = vm_proxy->OOPToCObject (nurbOOP);

  if (!cb_data)
    return;			/* Should fire an interrupt */

  /* Add a pointer to the nurb object to retreive informations during
     the callback */
  gluNurbsCallbackData (nurb, (void *) nurbOOP);
  gluNurbsCallback (nurb, cb_data->whichData, cb_data->func);
}

int gst_opengl_gluNurbsCurve (GLUnurbs *nurb, 
				GLint knotCount, OOP knots, GLint stride,
				OOP control,
				GLint order, GLenum type)
{
  GLfloat* knotsFloat;
  GLfloat* controlFloat;
  size_t nObjs, size;

  size = gst_opengl_glMap_size (type);
  if (!size)
    return GL_INVALID_ENUM;

  /* Retreive knots and put them in an array */
  knotsFloat = alloca (sizeof(GLfloat) * knotCount);
  knotsFloat = gst_opengl_oop_to_array (knotsFloat, knots, knotCount);
  if(!knotsFloat) 
	return GL_INVALID_VALUE;		/* Should fire an interrupt */

  /* Retreive control points and put them in an array */
  nObjs = (order - 1) * stride + size;
  controlFloat = alloca (sizeof(GLfloat) * nObjs);
  controlFloat = gst_opengl_oop_to_array (controlFloat, control, nObjs );
  if(!controlFloat)
	return GL_INVALID_VALUE;		/* Should fire an interrupt */
  
  gluNurbsCurve (nurb, knotCount, knotsFloat, stride, controlFloat, order, type);

  return 0;
}

int gst_opengl_gluNurbsSurface (GLUnurbs *nurb, 
				GLint sKnotCount, OOP sKnots,
				GLint tKnotCount, OOP tKnots,
				GLint sStride, GLint tStride, 
				OOP control,
				GLint sOrder, GLint tOrder, GLenum type)
{
  GLfloat* sKnotsFloat;
  GLfloat* tKnotsFloat;
  GLfloat* controlFloat;
  size_t nObjs, size;

  size = gst_opengl_glMap_size (type);
  if (!size)
    return GL_INVALID_ENUM;

  /* Retreive sKnots and put them in an array */
  sKnotsFloat = alloca (sizeof(GLfloat) * sKnotCount);
  sKnotsFloat = gst_opengl_oop_to_array (sKnotsFloat, sKnots, sKnotCount);
  if(!sKnotsFloat) 
	return GL_INVALID_VALUE;		/* Should fire an interrupt */

  /* Retreive tKnots and put them in an array */
  tKnotsFloat = alloca (sizeof(GLfloat) * tKnotCount);
  tKnotsFloat = gst_opengl_oop_to_array (tKnotsFloat, tKnots, sKnotCount);
  if(!tKnotsFloat) 
	return GL_INVALID_VALUE;		/* Should fire an interrupt */
  
  /* Retreive control points and put them in an array */
  nObjs = (sOrder - 1) * sStride + (tOrder - 1) * tStride + size;
  controlFloat = alloca (sizeof(GLfloat) * nObjs);
  controlFloat = gst_opengl_oop_to_array (controlFloat, control, nObjs );
  if(!controlFloat)
	return GL_INVALID_VALUE;		/* Should fire an interrupt */
  
  gluNurbsSurface (nurb, sKnotCount, sKnotsFloat, tKnotCount,
		   tKnotsFloat, sStride, tStride,
		   controlFloat, sOrder, tOrder, type);

  return 0;
}

void gst_opengl_gluPwlCurve (GLUnurbs* nurb, GLint count, OOP data, GLint stride, GLenum type)
{
  GLfloat* dataFloat, *p ;

  dataFloat = alloca (sizeof (GLfloat) * count * stride);
  p = gst_opengl_oop_to_array (dataFloat, data, count*stride);
  if (!p)
    return;

  gluPwlCurve (nurb, count, p, stride, type) ;
}

void gst_opengl_gluLoadSamplingMatrices (GLUnurbs* nurb, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex)
{
  GLfloat model[16], *pmodel ;
  GLfloat projection[16], *pproj ;
  GLint viewport[4], *pvport ;

  pmodel = gst_opengl_oop_to_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return;					/* Should fire an exception */

  gluLoadSamplingMatrices (nurb, pmodel, pproj, pvport) ;
}


/* Init module */
void gst_initModule_gluNurbs() {
  /* Define C Functions */
  // vm_proxy->defineCFunc ("gluNurbsCallback", gst_opengl_gluNurbsCallback);
  // vm_proxy->defineCFunc ("gluNurbsCallbackData", gluNurbsCallbackData);
  // vm_proxy->defineCFunc ("gluNurbsCallbackDataEXT", gluNurbsCallbackDataEXT);
  vm_proxy->defineCFunc ("gluGetNurbsProperty", gluGetNurbsProperty);
  vm_proxy->defineCFunc ("gluNewNurbsRenderer", gluNewNurbsRenderer);
  vm_proxy->defineCFunc ("gluDeleteNurbsRenderer", gluDeleteNurbsRenderer);
  vm_proxy->defineCFunc ("gluNurbsProperty", gluNurbsProperty);
  vm_proxy->defineCFunc ("gluNurbsCurve", gst_opengl_gluNurbsCurve);
  vm_proxy->defineCFunc ("gluNurbsSurface", gst_opengl_gluNurbsSurface);
  vm_proxy->defineCFunc ("gluPwlCurve", gst_opengl_gluPwlCurve) ;
  vm_proxy->defineCFunc ("gluLoadSamplingMatrices", gst_opengl_gluLoadSamplingMatrices) ;

  vm_proxy->defineCFunc ("gluNurbsConnectSignal", gst_opengl_gluNurbsConnectSignal);
}

#else

/* Init module */
void gst_initModule_gluNurbs() {
}

#endif
