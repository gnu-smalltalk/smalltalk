/******************************** -*- C -*- ****************************
 *
 *	OpenGL GLU bindings.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008, 2009 Free Software Foundation, Inc.
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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define nil  vm_proxy->nilOOP

void gst_opengl_gluLookAtv (OOP eyeOOP, OOP centerOOP, OOP upOOP)
{
  GLfloat eye[3], *peye ;
  GLfloat center[3], *pcenter ;
  GLfloat up[3], *pup ;

  peye = gst_opengl_oop_to_array (eye, eyeOOP, 3);
  pcenter = gst_opengl_oop_to_array (center, centerOOP, 3);
  pup = gst_opengl_oop_to_array (up, upOOP, 3);

  if (!peye || !pcenter || !pup)
    return;					/* Should fire an exception */

  gluLookAt (peye[0], peye[1], peye[2], pcenter[0], pcenter[1], pcenter[2],
	      pup[0], pup[1], pup[2]) ;
}


void gst_opengl_gluPickMatrix (GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, OOP viewportVertex)
{
  GLint viewport[4], *pvport ;
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);
  if (!pvport)
    return;					/* Should fire an exception */

  gluPickMatrix (x, y, delX, delY, pvport) ;
}

OOP gst_opengl_gluProject (GLdouble objX, GLdouble objY, GLdouble objZ, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex) 
{
  GLdouble winX, winY, winZ ;
  GLdouble model[16], *pmodel ;
  GLdouble projection[16], *pproj ;
  GLint viewport[4], *pvport ;
  OOP result = nil ;

  pmodel = gst_opengl_oop_to_dbl_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_dbl_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return result;					/* Should fire an exception */

  if(GL_TRUE == gluProject (objX, objY, objZ, pmodel, pproj, pvport, &winX, &winY, &winZ))
	{
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 3) ; /* Create an array of 3 variables */  
	  vm_proxy->OOPAtPut(result, 0, vm_proxy->floatToOOP(winX)) ;
	  vm_proxy->OOPAtPut(result, 1, vm_proxy->floatToOOP(winY)) ;
	  vm_proxy->OOPAtPut(result, 2, vm_proxy->floatToOOP(winZ)) ;
	}
  return result ;
}

OOP gst_opengl_gluUnProject (GLdouble winX, GLdouble winY, GLdouble winZ, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex)
{
  GLdouble objX, objY, objZ ;
  GLdouble model[16], *pmodel ;
  GLdouble projection[16], *pproj ;
  GLint viewport[4], *pvport ;
  OOP result = nil ;

  pmodel = gst_opengl_oop_to_dbl_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_dbl_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return result;					/* Should fire an exception */

  if(GL_TRUE == gluUnProject (winX, winY, winZ, pmodel, pproj, pvport, &objX, &objY, &objZ)) 
	{
	  /* Create an array of 3 variables */  
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 3) ; 

	  vm_proxy->OOPAtPut(result, 0, vm_proxy->longDoubleToOOP(objX)) ;
	  vm_proxy->OOPAtPut(result, 1, vm_proxy->longDoubleToOOP(objY)) ;
	  vm_proxy->OOPAtPut(result, 2, vm_proxy->longDoubleToOOP(objZ)) ;
	  vm_proxy->registerOOP(result) ;
	}
  return result ;
}

#if 0
OOP gst_opengl_gluUnProject4 (GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW, 
				OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex, 
				GLdouble nearVal, GLdouble farVal)
{
  GLdouble objX, objY, objZ, objW ;
  GLdouble model[16], *pmodel ;
  GLdouble projection[16], *pproj ;
  GLint viewport[4], *pvport ;
  OOP result = nil ;

  pmodel = gst_opengl_oop_to_dbl_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_dbl_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return nil;					/* Should fire an exception */

  if(GL_TRUE == gluUnProject4 (winX, winY, winZ, clipW, model, projection, viewport, nearVal, farVal, &objX, &objY, &objZ, &objW)) 
	{
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 4) ; /* Create an array of 4 variables */  

	  vm_proxy->OOPAtPut(result, 0, vm_proxy->longDoubleToOOP(objX)) ;
	  vm_proxy->OOPAtPut(result, 1, vm_proxy->longDoubleToOOP(objY)) ;
	  vm_proxy->OOPAtPut(result, 2, vm_proxy->longDoubleToOOP(objZ)) ;
	  vm_proxy->OOPAtPut(result, 3, vm_proxy->longDoubleToOOP(objW)) ;
	}
  return result ;
}
#endif


void gst_opengl_gluCylinder (GLenum draw, GLenum normals, GLenum orient,
			    GLboolean texture, GLdouble base, GLdouble top,
			    GLdouble height, GLint slices, GLint stacks)
{
  GLUquadric *q = gluNewQuadric ();
  gluQuadricDrawStyle (q, draw);
  gluQuadricNormals (q, normals);
  gluQuadricOrientation (q, orient);
  gluQuadricTexture (q, texture);
  gluCylinder (q, base, top, height, slices, stacks);
  gluDeleteQuadric (q);
}

void gst_opengl_gluSphere (GLenum draw, GLenum normals, GLenum orient,
			   GLboolean texture, GLdouble radius,
			   GLint slices, GLint stacks)
{
  GLUquadric *q = gluNewQuadric ();
  gluQuadricDrawStyle (q, draw);
  gluQuadricNormals (q, normals);
  gluQuadricOrientation (q, orient);
  gluQuadricTexture (q, texture);
  gluSphere (q, radius, slices, stacks);
  gluDeleteQuadric (q);
}

void gst_opengl_gluDisk (GLenum draw, GLenum normals, GLenum orient,
			 GLboolean texture, GLdouble inner, GLdouble outer,
			 GLint slices, GLint loops)
{
  GLUquadric *q = gluNewQuadric ();
  gluQuadricDrawStyle (q, draw);
  gluQuadricNormals (q, normals);
  gluQuadricOrientation (q, orient);
  gluQuadricTexture (q, texture);
  gluDisk (q, inner, outer, slices, loops);
  gluDeleteQuadric (q);
}

void gst_opengl_gluPartialDisk (GLenum draw, GLenum normals, GLenum orient,
			        GLboolean texture, GLdouble inner, GLdouble outer,
			        GLint slices, GLint loops,
				GLdouble start, GLdouble sweep)
{
  GLUquadric *q = gluNewQuadric ();
  gluQuadricDrawStyle (q, draw);
  gluQuadricNormals (q, normals);
  gluQuadricOrientation (q, orient);
  gluQuadricTexture (q, texture);
  gluPartialDisk (q, inner, outer, slices, loops, start, sweep);
  gluDeleteQuadric (q);
}

/* Not provided on MinGW, but easy enough to provide.  */
GLboolean
glu_check_extension(const char *extName, const char * extString)
{
  const int len = strlen (extName);
  const char *c;

  while (extString && (c = strstr (extString, extName)) != NULL)
    {
      if ((c == extString || c[-1] == ' ') && (c[len] == ' ' || c[len] == 0))
	return GL_TRUE;

      extString = strchr (c + len, ' ');
    }

  return GL_FALSE;
}

/* Init module */
void gst_initModule_glu() {

  /* Define C Functions */
  vm_proxy->defineCFunc ("gluBeginCurve", gluBeginCurve) ;
  vm_proxy->defineCFunc ("gluBeginPolygon", gluBeginPolygon) ;
  vm_proxy->defineCFunc ("gluBeginSurface", gluBeginSurface) ;
  vm_proxy->defineCFunc ("gluBeginTrim", gluBeginTrim) ;
#if 0
  vm_proxy->defineCFunc ("gluBuild1DMipmapLevels", gluBuild1DMipmapLevels) ;
  vm_proxy->defineCFunc ("gluBuild2DMipmapLevels", gluBuild2DMipmapLevels) ;
  vm_proxy->defineCFunc ("gluBuild3DMipmapLevels", gluBuild3DMipmapLevels) ;
#endif
  vm_proxy->defineCFunc ("gluBuild1DMipmaps", gluBuild1DMipmaps) ;
  vm_proxy->defineCFunc ("gluBuild2DMipmaps", gluBuild2DMipmaps) ;
#if 0
  vm_proxy->defineCFunc ("gluBuild3DMipmaps", gluBuild3DMipmaps) ;
#endif
  vm_proxy->defineCFunc ("gluCheckExtension", glu_check_extension) ;
  vm_proxy->defineCFunc ("gluCylinder", gst_opengl_gluCylinder) ;
  vm_proxy->defineCFunc ("gluDeleteTess", gluDeleteTess) ;
  vm_proxy->defineCFunc ("gluDisk", gst_opengl_gluDisk) ;
  vm_proxy->defineCFunc ("gluEndCurve", gluEndCurve) ;
  vm_proxy->defineCFunc ("gluEndPolygon", gluEndPolygon) ;
  vm_proxy->defineCFunc ("gluEndSurface", gluEndSurface) ;
  vm_proxy->defineCFunc ("gluEndTrim", gluEndTrim) ;
  vm_proxy->defineCFunc ("gluGetTessProperty", gluGetTessProperty) ;
  vm_proxy->defineCFunc ("gluLookAt", gluLookAt) ;
  vm_proxy->defineCFunc ("gluLookAtv", gst_opengl_gluLookAtv) ;
  vm_proxy->defineCFunc ("gluNextContour", gluNextContour) ;
  vm_proxy->defineCFunc ("gluOrtho2D", gluOrtho2D) ;
  vm_proxy->defineCFunc ("gluPartialDisk", gst_opengl_gluPartialDisk) ;
  vm_proxy->defineCFunc ("gluPerspective", gluPerspective) ;
  vm_proxy->defineCFunc ("gluPickMatrix", gst_opengl_gluPickMatrix) ;
  vm_proxy->defineCFunc ("gluProject", gst_opengl_gluProject) ;
  vm_proxy->defineCFunc ("gluScaleImage", gluScaleImage) ;
  vm_proxy->defineCFunc ("gluSphere", gst_opengl_gluSphere) ;
  vm_proxy->defineCFunc ("gluUnProject", gst_opengl_gluUnProject) ;
#if 0
  vm_proxy->defineCFunc ("gluUnProject4", gst_opengl_gluUnProject4) ;
#endif

  gst_initModule_gluNurbs ();
  gst_initModule_gluTess ();
}
