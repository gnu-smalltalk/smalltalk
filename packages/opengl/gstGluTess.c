/******************************** -*- C -*- ****************************
 *
 *	OpenGLU gluTess bindings.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008, 2009 Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/

/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#include "gstopengl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define nil  vm_proxy->nilOOP


#include "gstopengl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define nil  vm_proxy->nilOOP

/* Send the callback message to the receiver */
static void
gst_glu_tessCallback_sendMessageTo (OOP receiver, GLenum which,
				    OOP* args, int nArgs)
{
  OOP aBlock;			/* Callback's block */

  /* Retreive the callback block */
  vm_proxy->msgSendf (&aBlock, "%o %o getCallback: %i", receiver, which);
  if (aBlock != nil)
    vm_proxy->nvmsgSend(aBlock, NULL, args, nArgs);
}

static void
gst_glu_tessCallback_Tess_Begin_Data ( GLenum type, void* data )
{
  OOP args[1];
  args[0] = vm_proxy->intToOOP(type);
  gst_glu_tessCallback_sendMessageTo((OOP)data, GLU_TESS_BEGIN, args, 1);
}

static void
gst_glu_tessCallback_Tess_Vertex_Data ( OOP vertex, void* data )
{
  gst_glu_tessCallback_sendMessageTo((OOP)data, GLU_TESS_VERTEX, &vertex, 1);
}

static void
gst_glu_tessCallback_Tess_EdgeFlag_Data ( GLenum edge, void* data )
{
  OOP args[1];
  args[0] = vm_proxy->boolToOOP( edge );
  gst_glu_tessCallback_sendMessageTo((OOP)data, GLU_TESS_EDGE_FLAG, args, 1);
}

static void
gst_glu_tessCallback_Tess_End_Data (void* data )
{
  gst_glu_tessCallback_sendMessageTo((OOP)data, GLU_TESS_END, NULL, 0);
}

static void
gst_glu_tessCallback_Tess_Combine_Data (GLdouble* coords, void** vertexData,
					GLfloat* weight, void** outData,
					void* data)
{
  OOP weightArray, vertexDataArray, coordsArray;
  int i;
  OOP *vd = (OOP *) vertexData;
  OOP tessOOP = data;

  /*  Make three arrays from the parameters  */
  coordsArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, 3);
  for (i = 0; i < 3; ++i)
    vm_proxy->OOPAtPut (coordsArray, i, vm_proxy->floatToOOP (coords[i]));

  vertexDataArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, 4);
  for (i = 0; i < 4; ++i)
    vm_proxy->OOPAtPut (vertexDataArray, i, vd[i]);

  weightArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, 4);
  for (i = 0; i < 4; ++i)
    vm_proxy->OOPAtPut (weightArray, i, vm_proxy->floatToOOP (weight[i]));

  /* This callback is mapped in Smalltalk to explicit * and + operations, so we
     send it directly to the tesselator object.  */
  *outData =
    vm_proxy->strMsgSend (tessOOP, "combine:data:weights:", coordsArray,
			  vertexDataArray, weightArray, NULL);
}

/* Pointers to the Glu Tess callback functions */
struct gst_glu_callback {
  GLenum which;
  GLenum whichData;
  GLUfuncptr func;
};

/* Number of known callbacks */
#define N_GLU_CALLBACKS 6

static struct gst_glu_callback gst_glu_tessCallbackFuncs[] = {
  { GLU_TESS_BEGIN, GLU_TESS_BEGIN_DATA,
    (GLUfuncptr) gst_glu_tessCallback_Tess_Begin_Data },
  { GLU_TESS_VERTEX, GLU_TESS_VERTEX_DATA,
    (GLUfuncptr) gst_glu_tessCallback_Tess_Vertex_Data },
  { GLU_TESS_EDGE_FLAG, GLU_TESS_EDGE_FLAG_DATA,
    (GLUfuncptr) gst_glu_tessCallback_Tess_EdgeFlag_Data },
  { GLU_TESS_COMBINE, GLU_TESS_COMBINE_DATA,
    (GLUfuncptr) gst_glu_tessCallback_Tess_Combine_Data },
  { GLU_TESS_END, GLU_TESS_END_DATA,
    (GLUfuncptr) gst_glu_tessCallback_Tess_End_Data }
};

/* Retreive the callback index from the Callback contant definition */
static struct gst_glu_callback *
gst_glu_tess_getCallbackIndex(GLenum which)
{
  int i;
  for (i = 0; i < N_GLU_CALLBACKS; ++i)
	/* If function is found, return index */
	if (gst_glu_tessCallbackFuncs[i].which == which)
	  return &gst_glu_tessCallbackFuncs[i];

  return (struct gst_glu_callback *) NULL;
}


static void
gst_opengl_gluTessConnectSignal (GLUtesselator *tess, GLenum which)
{
  struct gst_glu_callback *cb_data = gst_glu_tess_getCallbackIndex (which);

  if (!cb_data)
    return;			/* Should fire an interrupt */

  /* Add a pointer to the tess object to retreive informations during
     the callback */
  gluTessCallback (tess, cb_data->whichData, cb_data->func);
}


static GLUtesselator *
gst_opengl_gluNewTess (void)
{
  GLUtesselator *tess = gluNewTess ();
  gluTessCallback(tess, GLU_TESS_BEGIN, (GLUfuncptr) glBegin);
  gluTessCallback(tess, GLU_TESS_VERTEX, (GLUfuncptr) gst_opengl_glVertexv);
  gluTessCallback(tess, GLU_TESS_END, glEnd);
  return tess;
}

/* Init module */
void gst_initModule_gluTess() {
  vm_proxy = vm_proxy;

  /* Define C Functions */
  vm_proxy->defineCFunc ("gluNewTess", gst_opengl_gluNewTess);
  vm_proxy->defineCFunc ("gluDeleteTess", gluDeleteTess);
  vm_proxy->defineCFunc ("gluTessBeginContour", gluTessBeginContour);
  vm_proxy->defineCFunc ("gluTessBeginPolygon", gluTessBeginPolygon);
  vm_proxy->defineCFunc ("gluTessEndContour", gluTessEndContour);
  vm_proxy->defineCFunc ("gluTessEndPolygon", gluTessEndPolygon);
  vm_proxy->defineCFunc ("gluTessNormal", gluTessNormal);
  vm_proxy->defineCFunc ("gluTessProperty", gluTessProperty);
  vm_proxy->defineCFunc ("gluTessVertex", gluTessVertex);
  vm_proxy->defineCFunc ("gluTessConnectSignal", gst_opengl_gluTessConnectSignal);
}

