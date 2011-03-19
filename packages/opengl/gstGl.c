/******************************** -*- C -*- ****************************
 *
 *	OpenGL bindings.
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
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define nil  vm_proxy->nilOOP


static int
gst_opengl_glClearColorv (OOP colorOOP)
{
  GLfloat color[4];
  GLfloat *p;

  color[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (color, colorOOP, 3, 4);
  gst_opengl_scale_array (p, colorOOP);
  if (!p)
    return GL_INVALID_VALUE;

  glClearColor (p[0], p[1], p[2], p[3]);
  return 0;
}

static int
gst_opengl_glColorv (OOP colorOOP)
{
  GLfloat color[4];
  GLfloat *p;

  color[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (color, colorOOP, 3, 4);
  gst_opengl_scale_array (p, colorOOP);
  if (!p)
    return GL_INVALID_VALUE;

  glColor4fv (p);
  return 0;
}

static int
gst_opengl_glRotatev (GLfloat angle, OOP axisOOP)
{
  GLfloat axis[3];
  GLfloat *p;

  p = gst_opengl_oop_to_array (axis, axisOOP, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glRotatef (angle, p[0], p[1], p[2]);
  return 0;
}

static int
gst_opengl_glTranslatev (OOP distOOP)
{
  GLfloat dist[3];
  GLfloat *p;

  dist[2] = 0.0;
  p = gst_opengl_oop_to_array_2 (dist, distOOP, 2, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glTranslatef (p[0], p[1], p[2]);
  return 0;
}

static int
gst_opengl_glScalev (OOP scaleOOP)
{
  GLfloat scale[3];
  GLfloat *p;

  scale[2] = 1.0;
  p = gst_opengl_oop_to_array_2 (scale, scaleOOP, 2, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glScalef (p[0], p[1], p[2]);
  return 0;
}

static int
gst_opengl_glNormalv (OOP normalOOP)
{
  GLfloat normal[3];
  GLfloat *p;

  p = gst_opengl_oop_to_array (normal, normalOOP, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glNormal3fv (p);
  return 0;
}

int
gst_opengl_glVertexv (OOP vertexOOP)
{
  GLfloat vertex[4];
  GLfloat *p;

  vertex[2] = 0.0;
  vertex[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (vertex, vertexOOP, 2, 4);
  if (!p)
    return GL_INVALID_VALUE;

  glVertex4fv (p);
  return 0;
}

static int
gst_opengl_glTexCoordv (OOP vertexOOP)
{
  GLfloat vertex[4];
  GLfloat *p;

  vertex[2] = 0.0;
  vertex[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (vertex, vertexOOP, 2, 4);
  if (!p)
    return GL_INVALID_VALUE;

  glTexCoord4fv (p);
  return 0;
}

static int
gst_opengl_glRasterPosv (OOP vertexOOP)
{
  GLfloat vertex[4];
  GLfloat *p;

  vertex[2] = 0.0;
  vertex[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (vertex, vertexOOP, 2, 4);
  if (!p)
    return GL_INVALID_VALUE;

  glRasterPos4fv (p);
  return 0;
}

static int
gst_opengl_glMultMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

  glMultMatrixf (p);
  return 0;
}

static int
gst_opengl_glMultTransposeMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

#ifdef GL_ARB_transpose_matrix
  glMultTransposeMatrixf (p);
#else
  {
    GLfloat mt[16];
    mt[0] = p[0]; mt[1] = p[4]; mt[2] = p[8]; mt[3] = p[12];
    mt[4] = p[1]; mt[5] = p[5]; mt[6] = p[9]; mt[7] = p[13];
    mt[8] = p[2]; mt[9] = p[6]; mt[10] = p[10]; mt[11] = p[14];
    mt[12] = p[3]; mt[13] = p[7]; mt[14] = p[11]; mt[15] = p[15];
    glMultMatrixf (mt);
  }
#endif
 
  return 0;
}

int
gst_opengl_glMap_size (GLenum target)
{
  switch (target)
    {
    case GL_MAP1_TEXTURE_COORD_1:
    case GL_MAP2_TEXTURE_COORD_1:
    case GL_MAP1_INDEX:
    case GL_MAP2_INDEX:
      return 1;

    case GL_MAP1_TEXTURE_COORD_2:
    case GL_MAP2_TEXTURE_COORD_2:
    case GLU_MAP1_TRIM_2:
      return 2;

    case GL_MAP1_TEXTURE_COORD_3:
    case GL_MAP2_TEXTURE_COORD_3:
    case GL_MAP1_VERTEX_3:
    case GL_MAP2_VERTEX_3:
    case GL_MAP1_NORMAL:
    case GL_MAP2_NORMAL:
    case GLU_MAP1_TRIM_3:
      return 3;

    case GL_MAP1_TEXTURE_COORD_4:
    case GL_MAP2_TEXTURE_COORD_4:
    case GL_MAP1_VERTEX_4:
    case GL_MAP2_VERTEX_4:
    case GL_MAP1_COLOR_4:
    case GL_MAP2_COLOR_4:
      return 4;

    default:
      return 0;
    }
}


static int
gst_opengl_glMap1v (GLenum target, GLdouble u1, GLdouble u2, GLint stride,
		    GLint order, OOP pointsOOP)
{
  int npoints, size;
  GLfloat *points, *p;

  size = gst_opengl_glMap_size (target);
  if (!size)
    return GL_INVALID_ENUM;

  npoints = (order - 1) * stride + size;
  points = (GLfloat *) alloca (sizeof (GLfloat) * npoints);
  p = gst_opengl_oop_to_array (points, pointsOOP, npoints);
  if (!p)
    return GL_INVALID_VALUE;

  glMap1f (target, u1, u2, stride, order, p);
  return 0;
}

static int
gst_opengl_glMap2v (GLenum target, GLfloat u1, GLfloat u2, GLint ustride,
		    GLint uorder, GLfloat v1, GLfloat v2, GLint vstride,
		    GLint vorder, OOP pointsOOP)
{
  int npoints, size;
  GLfloat *points, *p;

  size = gst_opengl_glMap_size (target);
  if (!size)
    return GL_INVALID_ENUM;

  npoints = (uorder - 1) * ustride + (vorder - 1) * vstride + size;
  points = (GLfloat *) alloca (sizeof (GLfloat) * npoints);
  p = gst_opengl_oop_to_array (points, pointsOOP, npoints);
  if (!p)
    return GL_INVALID_VALUE;

  glMap2f (target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, p);
  return 0;
}

static int
gst_opengl_glLoadMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

  glLoadMatrixf (p);
  return 0;
}

static int
gst_opengl_glLoadTransposeMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

#ifdef GL_ARB_transpose_matrix
  glLoadTransposeMatrixf (p);
#else
  {
    GLfloat mt[16];
    mt[0] = p[0]; mt[1] = p[4]; mt[2] = p[8]; mt[3] = p[12];
    mt[4] = p[1]; mt[5] = p[5]; mt[6] = p[9]; mt[7] = p[13];
    mt[8] = p[2]; mt[9] = p[6]; mt[10] = p[10]; mt[11] = p[14];
    mt[12] = p[3]; mt[13] = p[7]; mt[14] = p[11]; mt[15] = p[15];
    glLoadMatrixf (mt);
  }
#endif
  return 0;
}

static int
gst_opengl_glFogv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_FOG_COLOR:
      return 4;

    case GL_FOG_MODE:
    case GL_FOG_DENSITY:
    case GL_FOG_START:
    case GL_FOG_END:
    case GL_FOG_INDEX:
      return 1;

    default:
      return 0;
    }
}

static int
gst_opengl_glFogv (GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glFogv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glFogfv (pname, params);
  return 0;
}

static int
gst_opengl_glLightv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_AMBIENT:
    case GL_DIFFUSE:
    case GL_SPECULAR:
    case GL_POSITION:
      return 4;

    case GL_SPOT_DIRECTION:
      return 3;

    case GL_SPOT_EXPONENT:
    case GL_SPOT_CUTOFF:
    case GL_CONSTANT_ATTENUATION:
    case GL_LINEAR_ATTENUATION:
    case GL_QUADRATIC_ATTENUATION:
      return 1;

    default:
      return 0;
    }
}

static int
gst_opengl_glLightv (GLenum face, GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glLightv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glLightfv (face, pname, params);
  return 0;
}


static int
gst_opengl_glTexParameterv_size (GLenum pname)
{
  switch (pname)
    {
#ifdef GL_EXT_texture_object
    case GL_TEXTURE_PRIORITY_EXT:
    case GL_TEXTURE_RESIDENT_EXT:
      return 1;
#endif

#ifdef GL_VERSION_1_2
    case GL_TEXTURE_WRAP_R:
    case GL_TEXTURE_DEPTH:
      return 1;

    case GL_TEXTURE_MIN_LOD:
    case GL_TEXTURE_MAX_LOD:
    case GL_TEXTURE_BASE_LEVEL:
    case GL_TEXTURE_MAX_LEVEL:
      return 1;
#endif

    case GL_TEXTURE_MAG_FILTER:
    case GL_TEXTURE_MIN_FILTER:
    case GL_TEXTURE_WRAP_S:
    case GL_TEXTURE_WRAP_T:
#ifndef GL_EXT_texture_object
    case GL_TEXTURE_PRIORITY:
    case GL_TEXTURE_RESIDENT:
#endif
      return 1;
    case GL_TEXTURE_BORDER_COLOR:
      return 4;
    default:
      return 0;
    }
}

static int
gst_opengl_glTexParameterv (GLenum face, GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glTexParameterv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glTexParameterfv (face, pname, params);
  return 0;
}

static int
gst_opengl_glLightModelv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_LIGHT_MODEL_AMBIENT:
      return 4;

    case GL_LIGHT_MODEL_LOCAL_VIEWER:
    case GL_LIGHT_MODEL_TWO_SIDE:
      return 1;

    default:
      return 0;
    }
}

static int
gst_opengl_glLightModelv (GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glLightModelv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glLightModelfv (pname, params);
  return 0;
}

static int
gst_opengl_glTexEnvv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_TEXTURE_ENV_COLOR:
      return 4;

    case GL_TEXTURE_ENV_MODE:
      return 1;

    default:
      return 0;
    }
}

static int
gst_opengl_glTexEnvv (GLenum face, GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glTexEnvv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glTexEnvfv (face, pname, params);
  return 0;
}


static int
gst_opengl_glMaterialv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_AMBIENT_AND_DIFFUSE:
    case GL_AMBIENT:
    case GL_DIFFUSE:
    case GL_SPECULAR:
    case GL_EMISSION:
      return 4;

    case GL_COLOR_INDEXES:
      return 3;

    case GL_SHININESS:
      return 1;

    default:
      return 0;
    }
}


static int
gst_opengl_glMaterialv (GLenum face, GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glMaterialv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glMaterialfv (face, pname, params);
  return 0;
}

static int
gst_opengl_glGetv_size (GLenum pname)
{
  switch (pname)
    {
#ifdef GL_EXT_polygon_offset
    case GL_POLYGON_OFFSET_EXT:
    case GL_POLYGON_OFFSET_FACTOR_EXT:
    case GL_POLYGON_OFFSET_BIAS_EXT:
      return 1;
#endif

#ifdef GL_VERSION_1_2
    case GL_TEXTURE_3D:
    case GL_UNPACK_SKIP_IMAGES:
    case GL_UNPACK_IMAGE_HEIGHT:
    case GL_PACK_SKIP_IMAGES:
    case GL_PACK_IMAGE_HEIGHT:
    case GL_MAX_3D_TEXTURE_SIZE:
      return 1;

    case GL_RESCALE_NORMAL:
      return 1;

    case GL_LIGHT_MODEL_COLOR_CONTROL:
      return 1;

    case GL_MAX_ELEMENTS_VERTICES:
    case GL_MAX_ELEMENTS_INDICES:
      return 1;
#endif

#ifdef GL_VERSION_1_1
#ifndef GL_EXT_vertex_array
    case GL_TEXTURE_COORD_ARRAY:
    case GL_TEXTURE_COORD_ARRAY_SIZE:
    case GL_TEXTURE_COORD_ARRAY_STRIDE:
    case GL_TEXTURE_COORD_ARRAY_TYPE:
    case GL_VERTEX_ARRAY:
    case GL_VERTEX_ARRAY_SIZE:
    case GL_VERTEX_ARRAY_STRIDE:
    case GL_VERTEX_ARRAY_TYPE:
#endif
#ifndef GL_EXT_polygon_offset
    case GL_POLYGON_OFFSET_FACTOR:
    case GL_POLYGON_OFFSET_FILL:
#endif
    case GL_POLYGON_OFFSET_UNITS:
    case GL_POLYGON_OFFSET_LINE:
    case GL_POLYGON_OFFSET_POINT:
#ifndef GL_EXT_vertex_array
    case GL_NORMAL_ARRAY:
    case GL_NORMAL_ARRAY_STRIDE:
    case GL_NORMAL_ARRAY_TYPE:
#endif
    case GL_INDEX_LOGIC_OP:
#ifndef GL_EXT_vertex_array
    case GL_INDEX_ARRAY:
    case GL_INDEX_ARRAY_STRIDE:
    case GL_INDEX_ARRAY_TYPE:
    case GL_EDGE_FLAG_ARRAY:
    case GL_EDGE_FLAG_ARRAY_STRIDE:
    case GL_COLOR_ARRAY:
    case GL_COLOR_ARRAY_SIZE:
    case GL_COLOR_ARRAY_STRIDE:
    case GL_COLOR_ARRAY_TYPE:
#endif
    case GL_COLOR_LOGIC_OP:
      return 1;
#endif

#ifdef GL_EXT_cmyka
    case GL_PACK_CMYK_HINT_EXT:
    case GL_UNPACK_CMYK_HINT_EXT:
      return 1;
#endif

#ifdef GL_EXT_vertex_array
    case GL_VERTEX_ARRAY_EXT:
    case GL_VERTEX_ARRAY_SIZE_EXT:
    case GL_VERTEX_ARRAY_STRIDE_EXT:
    case GL_VERTEX_ARRAY_TYPE_EXT:
    case GL_VERTEX_ARRAY_COUNT_EXT:
    case GL_NORMAL_ARRAY_EXT:
    case GL_NORMAL_ARRAY_STRIDE_EXT:
    case GL_NORMAL_ARRAY_TYPE_EXT:
    case GL_NORMAL_ARRAY_COUNT_EXT:
    case GL_COLOR_ARRAY_EXT:
    case GL_COLOR_ARRAY_SIZE_EXT:
    case GL_COLOR_ARRAY_STRIDE_EXT:
    case GL_COLOR_ARRAY_TYPE_EXT:
    case GL_COLOR_ARRAY_COUNT_EXT:
    case GL_INDEX_ARRAY_EXT:
    case GL_INDEX_ARRAY_STRIDE_EXT:
    case GL_INDEX_ARRAY_TYPE_EXT:
    case GL_INDEX_ARRAY_COUNT_EXT:
    case GL_TEXTURE_COORD_ARRAY_EXT:
    case GL_TEXTURE_COORD_ARRAY_SIZE_EXT:
    case GL_TEXTURE_COORD_ARRAY_STRIDE_EXT:
    case GL_TEXTURE_COORD_ARRAY_TYPE_EXT:
    case GL_TEXTURE_COORD_ARRAY_COUNT_EXT:
    case GL_EDGE_FLAG_ARRAY_EXT:
    case GL_EDGE_FLAG_ARRAY_STRIDE_EXT:
    case GL_EDGE_FLAG_ARRAY_COUNT_EXT:
      return 1;
#endif

#if defined GL_EXT_clip_volume_hint && defined GL_VOLUME_CLIPPING_HINT_EXT
    case GL_VOLUME_CLIPPING_HINT_EXT:
      return 1;
#endif

    case GL_ACCUM_ALPHA_BITS:
    case GL_ACCUM_RED_BITS:
    case GL_ACCUM_BLUE_BITS:
    case GL_ACCUM_GREEN_BITS:
    case GL_ALPHA_BIAS:
    case GL_ALPHA_BITS:
    case GL_ALPHA_SCALE:
    case GL_ALPHA_TEST:
    case GL_ALPHA_TEST_FUNC:
    case GL_ALPHA_TEST_REF:
    case GL_ATTRIB_STACK_DEPTH:
    case GL_AUTO_NORMAL:
    case GL_AUX_BUFFERS:
    case GL_BLEND:
    case GL_BLEND_DST:
#if GL_EXT_blend_minmax
    case GL_BLEND_EQUATION_EXT:
#endif
    case GL_BLEND_SRC:
    case GL_BLUE_BIAS:
    case GL_BLUE_BITS:
    case GL_BLUE_SCALE:
    case GL_CLIENT_ATTRIB_STACK_DEPTH:
    case GL_COLOR_MATERIAL:
    case GL_COLOR_MATERIAL_FACE:
    case GL_COLOR_MATERIAL_PARAMETER:
    case GL_CULL_FACE:
    case GL_CULL_FACE_MODE:
    case GL_CURRENT_INDEX:
    case GL_CURRENT_RASTER_DISTANCE:
    case GL_CURRENT_RASTER_INDEX:
    case GL_CURRENT_RASTER_POSITION_VALID:
    case GL_DEPTH_BIAS:
    case GL_DEPTH_BITS:
    case GL_DEPTH_CLEAR_VALUE:
    case GL_DEPTH_FUNC:
    case GL_DEPTH_SCALE:
    case GL_DEPTH_TEST:
    case GL_DEPTH_WRITEMASK:
    case GL_DITHER:
    case GL_DOUBLEBUFFER:
    case GL_DRAW_BUFFER:
    case GL_EDGE_FLAG:
    case GL_FOG_DENSITY:
    case GL_FOG_END:
    case GL_FOG_HINT:
    case GL_FOG_INDEX:
    case GL_FOG_MODE:
    case GL_FOG_START:
    case GL_FRONT_FACE:
    case GL_GREEN_BIAS:
    case GL_GREEN_BITS:
    case GL_GREEN_SCALE:
    case GL_INDEX_BITS:
    case GL_INDEX_CLEAR_VALUE:
    case GL_INDEX_MODE:
    case GL_INDEX_OFFSET:
    case GL_INDEX_SHIFT:
    case GL_INDEX_WRITEMASK:
    case GL_LIGHTING:
    case GL_LIGHT_MODEL_LOCAL_VIEWER:
    case GL_LIGHT_MODEL_TWO_SIDE:
    case GL_LINE_SMOOTH:
    case GL_LINE_SMOOTH_HINT:
    case GL_LINE_STIPPLE:
    case GL_LINE_STIPPLE_PATTERN:
    case GL_LINE_STIPPLE_REPEAT:
    case GL_LINE_WIDTH:
    case GL_LINE_WIDTH_GRANULARITY:
    case GL_LIST_BASE:
    case GL_LIST_INDEX:
    case GL_LIST_MODE:
    case GL_LOGIC_OP_MODE:
    case GL_MAP1_COLOR_4:
    case GL_MAP1_GRID_SEGMENTS:
    case GL_MAP1_INDEX:
    case GL_MAP1_NORMAL:
    case GL_MAP1_TEXTURE_COORD_1:
    case GL_MAP1_TEXTURE_COORD_2:
    case GL_MAP1_TEXTURE_COORD_3:
    case GL_MAP1_TEXTURE_COORD_4:
    case GL_MAP1_VERTEX_3:
    case GL_MAP1_VERTEX_4:
    case GL_MAP2_INDEX:
    case GL_MAP2_NORMAL:
    case GL_MAP2_TEXTURE_COORD_1:
    case GL_MAP2_TEXTURE_COORD_2:
    case GL_MAP2_TEXTURE_COORD_3:
    case GL_MAP2_TEXTURE_COORD_4:
    case GL_MAP2_VERTEX_3:
    case GL_MAP2_VERTEX_4:
    case GL_MAP_COLOR:
    case GL_MAP_STENCIL:
    case GL_MATRIX_MODE:
    case GL_MAX_CLIENT_ATTRIB_STACK_DEPTH:
    case GL_MAX_ATTRIB_STACK_DEPTH:
    case GL_MAX_CLIP_PLANES:
    case GL_MAX_EVAL_ORDER:
    case GL_MAX_LIGHTS:
    case GL_MAX_LIST_NESTING:
    case GL_MAX_MODELVIEW_STACK_DEPTH:
    case GL_MAX_NAME_STACK_DEPTH:
    case GL_MAX_PIXEL_MAP_TABLE:
    case GL_MAX_PROJECTION_STACK_DEPTH:
    case GL_MAX_TEXTURE_SIZE:
    case GL_MAX_TEXTURE_STACK_DEPTH:
    case GL_MODELVIEW_STACK_DEPTH:
    case GL_NAME_STACK_DEPTH:
    case GL_NORMALIZE:
    case GL_PACK_ALIGNMENT:
    case GL_PACK_LSB_FIRST:
    case GL_PACK_ROW_LENGTH:
    case GL_PACK_SKIP_PIXELS:
    case GL_PACK_SKIP_ROWS:
    case GL_PACK_SWAP_BYTES:
    case GL_PERSPECTIVE_CORRECTION_HINT:
    case GL_PIXEL_MAP_A_TO_A_SIZE:
    case GL_PIXEL_MAP_B_TO_B_SIZE:
    case GL_PIXEL_MAP_G_TO_G_SIZE:
    case GL_PIXEL_MAP_I_TO_A_SIZE:
    case GL_PIXEL_MAP_I_TO_B_SIZE:
    case GL_PIXEL_MAP_I_TO_G_SIZE:
    case GL_PIXEL_MAP_I_TO_I_SIZE:
    case GL_PIXEL_MAP_I_TO_R_SIZE:
    case GL_PIXEL_MAP_R_TO_R_SIZE:
    case GL_PIXEL_MAP_S_TO_S_SIZE:
    case GL_POINT_SIZE:
    case GL_POINT_SIZE_GRANULARITY:
    case GL_POINT_SIZE_RANGE:
    case GL_POINT_SMOOTH:
    case GL_POINT_SMOOTH_HINT:
    case GL_POLYGON_SMOOTH:
    case GL_POLYGON_SMOOTH_HINT:
    case GL_POLYGON_STIPPLE:
    case GL_PROJECTION_STACK_DEPTH:
    case GL_READ_BUFFER:
    case GL_RED_BIAS:
    case GL_RED_BITS:
    case GL_RED_SCALE:
    case GL_RENDER_MODE:
    case GL_RGBA_MODE:
    case GL_SCISSOR_TEST:
    case GL_SHADE_MODEL:
    case GL_STENCIL_BITS:
    case GL_STENCIL_CLEAR_VALUE:
    case GL_STENCIL_FAIL:
    case GL_STENCIL_FUNC:
    case GL_STENCIL_PASS_DEPTH_FAIL:
    case GL_STENCIL_PASS_DEPTH_PASS:
    case GL_STENCIL_REF:
    case GL_STENCIL_TEST:
    case GL_STENCIL_VALUE_MASK:
    case GL_STENCIL_WRITEMASK:
    case GL_STEREO:
    case GL_SUBPIXEL_BITS:
    case GL_TEXTURE_1D:
    case GL_TEXTURE_BINDING_1D:
    case GL_TEXTURE_2D:
    case GL_TEXTURE_BINDING_2D:
    case GL_TEXTURE_GEN_Q:
    case GL_TEXTURE_GEN_R:
    case GL_TEXTURE_GEN_S:
    case GL_TEXTURE_GEN_T:
    case GL_TEXTURE_STACK_DEPTH:
    case GL_UNPACK_ALIGNMENT:
    case GL_UNPACK_LSB_FIRST:
    case GL_UNPACK_ROW_LENGTH:
    case GL_UNPACK_SKIP_PIXELS:
    case GL_UNPACK_SKIP_ROWS:
    case GL_UNPACK_SWAP_BYTES:
    case GL_ZOOM_X:
    case GL_ZOOM_Y:
      return 1;

    case GL_DEPTH_RANGE:
    case GL_LINE_WIDTH_RANGE:
    case GL_MAP1_GRID_DOMAIN:
    case GL_MAP2_GRID_SEGMENTS:
    case GL_MAX_VIEWPORT_DIMS:
    case GL_POLYGON_MODE:
      return 2;

    case GL_CURRENT_NORMAL:
      return 3;

    case GL_ACCUM_CLEAR_VALUE:
#if GL_EXT_blend_color
    case GL_BLEND_COLOR_EXT:
#endif
    case GL_COLOR_CLEAR_VALUE:
    case GL_COLOR_WRITEMASK:
    case GL_CURRENT_COLOR:
    case GL_CURRENT_RASTER_COLOR:
    case GL_CURRENT_RASTER_POSITION:
    case GL_CURRENT_RASTER_TEXTURE_COORDS:
    case GL_CURRENT_TEXTURE_COORDS:
    case GL_FOG_COLOR:
    case GL_LIGHT_MODEL_AMBIENT:
    case GL_MAP2_GRID_DOMAIN:
    case GL_SCISSOR_BOX:
    case GL_VIEWPORT:
      return 4;
    case GL_MODELVIEW_MATRIX:
    case GL_PROJECTION_MATRIX:
    case GL_TEXTURE_MATRIX:
      return 16;

    default:
      {
	static GLint max_lights = 0;
	static GLint max_clip_planes = 0;
	if (!max_lights)
	  {
	    glGetIntegerv (GL_MAX_LIGHTS, &max_lights);
	    glGetIntegerv (GL_MAX_CLIP_PLANES, &max_clip_planes);
	  }

	/* GL_LIGHTi = 1 */
	if (pname > GL_LIGHT0 && pname <= GL_LIGHT0 + max_lights)
	  return 1;

	/* GL_CLIP_PLANEi = 1 */
	if (pname > GL_CLIP_PLANE0 && pname <= GL_CLIP_PLANE0 + max_clip_planes)
	  return 1;

	return 0;
      }
    }
}


static OOP
gst_opengl_glGetDoublev ( GLenum pname )
{
  GLdouble *params;
  int i, size;
  OOP anArray = nil;

  size = gst_opengl_glGetv_size (pname);
  if (size > 0)
    {
      /* Allocating an Array object */
      anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);

      /* retreiving datas from OpenGL */
      params = (GLdouble *) alloca (sizeof (GLdouble) * size);
      glGetDoublev (pname, params);

      /* Converting datas to Smalltalk Float object */
      for (i = 0; i < size; ++i)
	vm_proxy->OOPAtPut (anArray, i, vm_proxy->floatToOOP (params[i]));
    }
  return anArray;
}

static OOP
gst_opengl_glGetFloatv ( GLenum pname )
{
  GLfloat *params;
  int i, size;
  OOP anArray = nil;

  size = gst_opengl_glGetv_size (pname);
  if (size > 0)
    {
      /* Allocating an Array object */
      anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);

      /* retreiving datas from OpenGL */
      params = (GLfloat *) alloca (sizeof (GLfloat) * size);
      glGetFloatv (pname, params);

      /* Converting datas to Smalltalk Float object */
      for (i = 0; i < size; ++i)
	vm_proxy->OOPAtPut (anArray, i, vm_proxy->floatToOOP (params[i]));
    }
  return anArray;
}

static OOP
gst_opengl_glGetIntegerv ( GLenum pname )
{
  GLint *params;
  int i, size;
  OOP anArray = nil;

  size = gst_opengl_glGetv_size (pname);
  if (size > 0)
    {
      /* Allocating an Array object */
      anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);

      /* retrieving datas from OpenGL */
      params = (GLint *) alloca (sizeof (GLint) * size);
      glGetIntegerv (pname, params);

      /* Converting datas to Smalltalk int object */
      for (i = 0; i < size; ++i)
	vm_proxy->OOPAtPut (anArray, i, vm_proxy->intToOOP (params[i]));
    }
  return anArray;
}

static OOP
gst_opengl_glGenTextures ( GLsizei size )
{
  GLint *textures;
  int i;
  OOP anArray;

  /* Allocating an Array object */
  anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);

  /* retrieving datas from OpenGL */
  textures = (GLint *) alloca (sizeof (GLint) * size);
  glGenTextures (size, textures);

  /* Converting datas to Smalltalk int object */
  for (i = 0; i < size; ++i)
    vm_proxy->OOPAtPut (anArray, i, vm_proxy->intToOOP (textures[i]));

  return anArray;
}

static void
gst_opengl_glDeleteTextures ( OOP texturesOOP )
{
  /* Allocating an Array object */
  GLsizei size = vm_proxy->basicSize (texturesOOP);
  GLint *textures;

  /* retrieving datas from OpenGL */
  textures = (GLint *) alloca (sizeof (GLint) * size);
  textures = gst_opengl_oop_to_int_array (textures, texturesOOP, size);
  if (!textures)
    return;

  /* Converting datas to Smalltalk int object */
  glDeleteTextures (size, textures);
}

static void 
gst_opengl_glBitmap( GLsizei width, GLsizei height,
					 GLfloat xorig, GLfloat yorig,
					 GLfloat xmove, GLfloat ymove,
					 OOP bitmap )
{
  int size = (width >> 3) * height;
  GLubyte* openglBitmap = (GLubyte *) alloca (sizeof(GLubyte) * size);
  openglBitmap = gst_opengl_oop_to_ubyte_array (openglBitmap, bitmap, size);
  if (!openglBitmap)
    return;

  glBitmap(width, height, xorig, yorig, xmove, ymove, openglBitmap);
}


static void 
gst_opengl_glCallLists( GLsizei first, GLsizei last, OOP listsOOP )
{
  GLenum type = gst_opengl_get_gl_type (listsOOP);
  GLsizei size = vm_proxy->basicSize (listsOOP);
  GLsizei elt_size;
  GLubyte *lists;
  if (first < 1 || last > size || last < first)
    return;

  if (type == -1)
    {
      type = GL_INT;
      lists = alloca (sizeof (GLint) * size);
      lists = (GLubyte *)
	gst_opengl_oop_to_int_array ((GLint *) lists, listsOOP, size);
      if(!lists)
	return;
    }
  else
    lists = vm_proxy->OOPIndexedBase (listsOOP);

  elt_size = gst_opengl_get_type_size (type);
  glCallLists (last - first + 1, type, lists + (first - 1) * elt_size);
}

void gst_initModule_gl()
{
  vm_proxy->defineCFunc ("glAccum", glAccum);
#if 0
  vm_proxy->defineCFunc ("glActiveTexture", glActiveTexture);
#endif
  vm_proxy->defineCFunc ("glAlphaFunc", glAlphaFunc);
  vm_proxy->defineCFunc ("glArrayElement", glArrayElement);
  vm_proxy->defineCFunc ("glBegin", glBegin);
  vm_proxy->defineCFunc ("glBindTexture", glBindTexture);
  vm_proxy->defineCFunc ("glBitmap", gst_opengl_glBitmap);
#if 0
  vm_proxy->defineCFunc ("glBlendEquation", glBlendEquation);
#endif
  vm_proxy->defineCFunc ("glBlendFunc", glBlendFunc);
  vm_proxy->defineCFunc ("glCallList", glCallList); 
  vm_proxy->defineCFunc ("glCallLists", gst_opengl_glCallLists); 
  vm_proxy->defineCFunc ("glClear", glClear); 
  vm_proxy->defineCFunc ("glClearAccum", glClearAccum);
  vm_proxy->defineCFunc ("glClearColor", glClearColor);
  vm_proxy->defineCFunc ("glClearColorv", gst_opengl_glClearColorv);
  vm_proxy->defineCFunc ("glClearDepth", glClearDepth);
  vm_proxy->defineCFunc ("glClearIndex", glClearIndex);
  vm_proxy->defineCFunc ("glClearStencil", glClearStencil);
#if 0
  vm_proxy->defineCFunc ("glClientActiveTexture", glClientActiveTexture);
#endif
  vm_proxy->defineCFunc ("glClipPlane", glClipPlane);
  vm_proxy->defineCFunc ("glColor3b", glColor3b);
  vm_proxy->defineCFunc ("glColor3bv", glColor3bv);
  vm_proxy->defineCFunc ("glColor3d", glColor3d);
  vm_proxy->defineCFunc ("glColor3dv", glColor3dv);
  vm_proxy->defineCFunc ("glColor3f", glColor3f);
  vm_proxy->defineCFunc ("glColor3fv", glColor3fv);
  vm_proxy->defineCFunc ("glColor3i", glColor3i);
  vm_proxy->defineCFunc ("glColor3iv", glColor3iv);
  vm_proxy->defineCFunc ("glColor3s", glColor3s);
  vm_proxy->defineCFunc ("glColor3sv", glColor3sv);
  vm_proxy->defineCFunc ("glColor3ub", glColor3ub);
  vm_proxy->defineCFunc ("glColor3ubv", glColor3ubv);
  vm_proxy->defineCFunc ("glColor3ui", glColor3ui);
  vm_proxy->defineCFunc ("glColor3uiv", glColor3uiv);
  vm_proxy->defineCFunc ("glColor3us", glColor3us);
  vm_proxy->defineCFunc ("glColor3usv", glColor3usv);
  vm_proxy->defineCFunc ("glColor4bv", glColor4bv);
  vm_proxy->defineCFunc ("glColor4dv", glColor4dv);
  vm_proxy->defineCFunc ("glColor4fv", glColor4fv);
  vm_proxy->defineCFunc ("glColor4iv", glColor4iv);
  vm_proxy->defineCFunc ("glColor4sv", glColor4sv);
  vm_proxy->defineCFunc ("glColor4ubv", glColor4ubv);
  vm_proxy->defineCFunc ("glColor4uiv", glColor4uiv);
  vm_proxy->defineCFunc ("glColor4usv", glColor4usv);
  vm_proxy->defineCFunc ("glColorv", gst_opengl_glColorv);
  vm_proxy->defineCFunc ("glColorMask", glColorMask);
  vm_proxy->defineCFunc ("glColorMaterial", glColorMaterial);
#if 0
  vm_proxy->defineCFunc ("glCompressedTexImage1D", glCompressedTexImage1D);
  vm_proxy->defineCFunc ("glCompressedTexImage2D", glCompressedTexImage2D);
  vm_proxy->defineCFunc ("glCompressedTexImage3D", glCompressedTexImage3D);
  vm_proxy->defineCFunc ("glCompressedTexSubImage1D", glCompressedTexSubImage1D);
  vm_proxy->defineCFunc ("glCompressedTexSubImage2D", glCompressedTexSubImage2D);
  vm_proxy->defineCFunc ("glCompressedTexSubImage3D", glCompressedTexSubImage3D);
#endif
  vm_proxy->defineCFunc ("glCullFace", glCullFace);
  vm_proxy->defineCFunc ("glDeleteLists", glDeleteLists);
  vm_proxy->defineCFunc ("glDeleteTextures", gst_opengl_glDeleteTextures);
  vm_proxy->defineCFunc ("glDepthFunc", glDepthFunc);
  vm_proxy->defineCFunc ("glDepthMask", glDepthMask);
  vm_proxy->defineCFunc ("glDepthRange", glDepthRange);
  vm_proxy->defineCFunc ("glDisable", glDisable);
  vm_proxy->defineCFunc ("glDisableClientState", glDisableClientState);
  vm_proxy->defineCFunc ("glDrawArrays", glDrawArrays);
  vm_proxy->defineCFunc ("glDrawBuffer", glDrawBuffer);
  vm_proxy->defineCFunc ("glEdgeFlag", glEdgeFlag);
  vm_proxy->defineCFunc ("glEdgeFlagPointer", glEdgeFlagPointer);
  vm_proxy->defineCFunc ("glEdgeFlagv", glEdgeFlagv);
  vm_proxy->defineCFunc ("glEnable", glEnable);
  vm_proxy->defineCFunc ("glEnableClientState", glEnableClientState);
  vm_proxy->defineCFunc ("glEnd", glEnd); 
  vm_proxy->defineCFunc ("glEndList", glEndList);
  vm_proxy->defineCFunc ("glEvalCoord1d", glEvalCoord1d);
  vm_proxy->defineCFunc ("glEvalCoord1dv", glEvalCoord1dv);
  vm_proxy->defineCFunc ("glEvalCoord1f", glEvalCoord1f);
  vm_proxy->defineCFunc ("glEvalCoord1fv", glEvalCoord1fv);
  vm_proxy->defineCFunc ("glEvalCoord2d", glEvalCoord2d);
  vm_proxy->defineCFunc ("glEvalCoord2dv", glEvalCoord2dv);
  vm_proxy->defineCFunc ("glEvalCoord2f", glEvalCoord2f);
  vm_proxy->defineCFunc ("glEvalCoord2fv", glEvalCoord2fv);
  vm_proxy->defineCFunc ("glEvalMesh1", glEvalMesh1);
  vm_proxy->defineCFunc ("glEvalMesh2", glEvalMesh2);
  vm_proxy->defineCFunc ("glEvalPoint1", glEvalPoint1);
  vm_proxy->defineCFunc ("glEvalPoint2", glEvalPoint2);
  vm_proxy->defineCFunc ("glFeedbackBuffer", glFeedbackBuffer);
  vm_proxy->defineCFunc ("glFinish", glFinish);
  vm_proxy->defineCFunc ("glFlush", glFlush); 
  vm_proxy->defineCFunc ("glFogf", glFogf);
  vm_proxy->defineCFunc ("glFogfv", glFogfv);
  vm_proxy->defineCFunc ("glFogi", glFogi);
  vm_proxy->defineCFunc ("glFogiv", glFogiv);
  vm_proxy->defineCFunc ("glFogv", gst_opengl_glFogv);
  vm_proxy->defineCFunc ("glFrontFace", glFrontFace);
  vm_proxy->defineCFunc ("glFrustum", glFrustum);
  vm_proxy->defineCFunc ("glGenLists", glGenLists);
  vm_proxy->defineCFunc ("glGenTextures", gst_opengl_glGenTextures);
  // vm_proxy->defineCFunc ("glGetBooleanv", glGetBooleanv);
  vm_proxy->defineCFunc ("glGetClipPlane", glGetClipPlane);
#if 0
  vm_proxy->defineCFunc ("glGetCompressedTexImage", glGetCompressedTexImage);
#endif
  vm_proxy->defineCFunc ("glGetDoublev", gst_opengl_glGetDoublev); 
  vm_proxy->defineCFunc ("glGetError", glGetError);
  vm_proxy->defineCFunc ("glGetFloatv", gst_opengl_glGetFloatv);
  vm_proxy->defineCFunc ("glGetIntegerv", gst_opengl_glGetIntegerv);
  vm_proxy->defineCFunc ("glGetLightfv", glGetLightfv);
  vm_proxy->defineCFunc ("glGetLightiv", glGetLightiv);
  vm_proxy->defineCFunc ("glGetMapdv", glGetMapdv);
  vm_proxy->defineCFunc ("glGetMapfv", glGetMapfv);
  vm_proxy->defineCFunc ("glGetMapiv", glGetMapiv);
  vm_proxy->defineCFunc ("glGetMaterialfv", glGetMaterialfv);
  vm_proxy->defineCFunc ("glGetMaterialiv", glGetMaterialiv);
  vm_proxy->defineCFunc ("glGetPixelMapfv", glGetPixelMapfv);
  vm_proxy->defineCFunc ("glGetPixelMapuiv", glGetPixelMapuiv);
  vm_proxy->defineCFunc ("glGetPixelMapusv", glGetPixelMapusv);
  vm_proxy->defineCFunc ("glGetPointerv", glGetPointerv);
  vm_proxy->defineCFunc ("glGetPolygonStipple", glGetPolygonStipple);
  vm_proxy->defineCFunc ("glGetString", glGetString);
  vm_proxy->defineCFunc ("glGetTexEnvfv", glGetTexEnvfv);
  vm_proxy->defineCFunc ("glGetTexEnviv", glGetTexEnviv);
  vm_proxy->defineCFunc ("glGetTexGendv", glGetTexGendv);
  vm_proxy->defineCFunc ("glGetTexGenfv", glGetTexGenfv);
  vm_proxy->defineCFunc ("glGetTexGeniv", glGetTexGeniv);
  vm_proxy->defineCFunc ("glGetTexImage", glGetTexImage);
  vm_proxy->defineCFunc ("glGetTexLevelParameterfv", glGetTexLevelParameterfv);
  vm_proxy->defineCFunc ("glGetTexLevelParameteriv", glGetTexLevelParameteriv);
  vm_proxy->defineCFunc ("glGetTexParameterfv", glGetTexParameterfv);
  vm_proxy->defineCFunc ("glGetTexParameteriv", glGetTexParameteriv);
  vm_proxy->defineCFunc ("glHint", glHint);
  vm_proxy->defineCFunc ("glIndexMask", glIndexMask);
  vm_proxy->defineCFunc ("glIndexd", glIndexd);
  vm_proxy->defineCFunc ("glIndexdv", glIndexdv);
  vm_proxy->defineCFunc ("glIndexf", glIndexf);
  vm_proxy->defineCFunc ("glIndexfv", glIndexfv);
  vm_proxy->defineCFunc ("glIndexi", glIndexi);
  vm_proxy->defineCFunc ("glIndexiv", glIndexiv);
  vm_proxy->defineCFunc ("glIndexs", glIndexs);
  vm_proxy->defineCFunc ("glIndexsv", glIndexsv);
  vm_proxy->defineCFunc ("glIndexub", glIndexub);
  vm_proxy->defineCFunc ("glIndexubv", glIndexubv);
  vm_proxy->defineCFunc ("glInitNames", glInitNames);
  vm_proxy->defineCFunc ("glIsEnabled", glIsEnabled);
  vm_proxy->defineCFunc ("glIsList", glIsList);
  vm_proxy->defineCFunc ("glIsTexture", glIsTexture);
  vm_proxy->defineCFunc ("glLightModelf", glLightModelf);
  vm_proxy->defineCFunc ("glLightModelfv", glLightModelfv);
  vm_proxy->defineCFunc ("glLightModeli", glLightModeli);
  vm_proxy->defineCFunc ("glLightModeliv", glLightModeliv);
  vm_proxy->defineCFunc ("glLightModelv", gst_opengl_glLightModelv);
  vm_proxy->defineCFunc ("glLightf", glLightf);
  vm_proxy->defineCFunc ("glLightfv", glLightfv);
  vm_proxy->defineCFunc ("glLighti", glLighti);
  vm_proxy->defineCFunc ("glLightiv", glLightiv);
  vm_proxy->defineCFunc ("glLightv", gst_opengl_glLightv);
  vm_proxy->defineCFunc ("glLineStipple", glLineStipple);
  vm_proxy->defineCFunc ("glLineWidth", glLineWidth);
  vm_proxy->defineCFunc ("glListBase", glListBase); 
  vm_proxy->defineCFunc ("glLoadIdentity", glLoadIdentity);
  vm_proxy->defineCFunc ("glLoadMatrixd", glLoadMatrixd);
  vm_proxy->defineCFunc ("glLoadMatrixf", glLoadMatrixf);
  vm_proxy->defineCFunc ("glLoadMatrixv", gst_opengl_glLoadMatrixv);
  vm_proxy->defineCFunc ("glLoadName", glLoadName);
#if 0
  vm_proxy->defineCFunc ("glLoadTransposeMatrixd", glLoadTransposeMatrixd);
  vm_proxy->defineCFunc ("glLoadTransposeMatrixf", glLoadTransposeMatrixf);
#endif
  vm_proxy->defineCFunc ("glLoadTransposeMatrixv", gst_opengl_glLoadTransposeMatrixv);
  vm_proxy->defineCFunc ("glLogicOp", glLogicOp);
  vm_proxy->defineCFunc ("glMapGrid1d", glMapGrid1d); 
  vm_proxy->defineCFunc ("glMapGrid1f", glMapGrid1f); 
  vm_proxy->defineCFunc ("glMapGrid2d", glMapGrid2d); 
  vm_proxy->defineCFunc ("glMapGrid2f", glMapGrid2f); 
  vm_proxy->defineCFunc ("glMaterialf", glMaterialf);
  vm_proxy->defineCFunc ("glMaterialfv", glMaterialfv);
  vm_proxy->defineCFunc ("glMateriali", glMateriali);
  vm_proxy->defineCFunc ("glMaterialiv", glMaterialiv);
  vm_proxy->defineCFunc ("glMaterialv", gst_opengl_glMaterialv);
  vm_proxy->defineCFunc ("glMatrixMode", glMatrixMode);
  vm_proxy->defineCFunc ("glMultMatrixd", glMultMatrixd);
  vm_proxy->defineCFunc ("glMultMatrixf", glMultMatrixf);
  vm_proxy->defineCFunc ("glMultMatrixv", gst_opengl_glMultMatrixv);
#if 0
  vm_proxy->defineCFunc ("glMultTransposeMatrixd", glMultTransposeMatrixd);
  vm_proxy->defineCFunc ("glMultTransposeMatrixf", glMultTransposeMatrixf);
#endif
  vm_proxy->defineCFunc ("glMultTransposeMatrixv", gst_opengl_glMultTransposeMatrixv);
#if 0
  vm_proxy->defineCFunc ("glMultiTexCoord1d", glMultiTexCoord1d);
  vm_proxy->defineCFunc ("glMultiTexCoord1dv", glMultiTexCoord1dv);
  vm_proxy->defineCFunc ("glMultiTexCoord1f", glMultiTexCoord1f);
  vm_proxy->defineCFunc ("glMultiTexCoord1fv", glMultiTexCoord1fv);
  vm_proxy->defineCFunc ("glMultiTexCoord1i", glMultiTexCoord1i);
  vm_proxy->defineCFunc ("glMultiTexCoord1iv", glMultiTexCoord1iv);
  vm_proxy->defineCFunc ("glMultiTexCoord1s", glMultiTexCoord1s);
  vm_proxy->defineCFunc ("glMultiTexCoord1sv", glMultiTexCoord1sv);
  vm_proxy->defineCFunc ("glMultiTexCoord2d", glMultiTexCoord2d);
  vm_proxy->defineCFunc ("glMultiTexCoord2dv", glMultiTexCoord2dv);
  vm_proxy->defineCFunc ("glMultiTexCoord2f", glMultiTexCoord2f);
  vm_proxy->defineCFunc ("glMultiTexCoord2fv", glMultiTexCoord2fv);
  vm_proxy->defineCFunc ("glMultiTexCoord2i", glMultiTexCoord2i);
  vm_proxy->defineCFunc ("glMultiTexCoord2iv", glMultiTexCoord2iv);
  vm_proxy->defineCFunc ("glMultiTexCoord2s", glMultiTexCoord2s);
  vm_proxy->defineCFunc ("glMultiTexCoord2sv", glMultiTexCoord2sv);
  vm_proxy->defineCFunc ("glMultiTexCoord3d", glMultiTexCoord3d);
  vm_proxy->defineCFunc ("glMultiTexCoord3dv", glMultiTexCoord3dv);
  vm_proxy->defineCFunc ("glMultiTexCoord3f", glMultiTexCoord3f);
  vm_proxy->defineCFunc ("glMultiTexCoord3fv", glMultiTexCoord3fv);
  vm_proxy->defineCFunc ("glMultiTexCoord3i", glMultiTexCoord3i);
  vm_proxy->defineCFunc ("glMultiTexCoord3iv", glMultiTexCoord3iv);
  vm_proxy->defineCFunc ("glMultiTexCoord3s", glMultiTexCoord3s);
  vm_proxy->defineCFunc ("glMultiTexCoord3sv", glMultiTexCoord3sv);
  vm_proxy->defineCFunc ("glMultiTexCoord4d", glMultiTexCoord4d);
  vm_proxy->defineCFunc ("glMultiTexCoord4dv", glMultiTexCoord4dv);
  vm_proxy->defineCFunc ("glMultiTexCoord4f", glMultiTexCoord4f);
  vm_proxy->defineCFunc ("glMultiTexCoord4fv", glMultiTexCoord4fv);
  vm_proxy->defineCFunc ("glMultiTexCoord4i", glMultiTexCoord4i);
  vm_proxy->defineCFunc ("glMultiTexCoord4iv", glMultiTexCoord4iv);
  vm_proxy->defineCFunc ("glMultiTexCoord4s", glMultiTexCoord4s);
  vm_proxy->defineCFunc ("glMultiTexCoord4sv", glMultiTexCoord4sv);
#endif
  vm_proxy->defineCFunc ("glNewList", glNewList);
  vm_proxy->defineCFunc ("glNormal3b", glNormal3b);
  vm_proxy->defineCFunc ("glNormal3bv", glNormal3bv);
  vm_proxy->defineCFunc ("glNormal3d", glNormal3d);
  vm_proxy->defineCFunc ("glNormal3dv", glNormal3dv);
  vm_proxy->defineCFunc ("glNormal3f", glNormal3f);
  vm_proxy->defineCFunc ("glNormal3fv", glNormal3fv);
  vm_proxy->defineCFunc ("glNormal3i", glNormal3i);
  vm_proxy->defineCFunc ("glNormal3iv", glNormal3iv);
  vm_proxy->defineCFunc ("glNormal3s", glNormal3s);
  vm_proxy->defineCFunc ("glNormal3sv", glNormal3sv);
  vm_proxy->defineCFunc ("glNormalv", gst_opengl_glNormalv);
  vm_proxy->defineCFunc ("glOrtho", glOrtho);
  vm_proxy->defineCFunc ("glPassThrough", glPassThrough);
  vm_proxy->defineCFunc ("glPixelStoref", glPixelStoref); 
  vm_proxy->defineCFunc ("glPixelStorei", glPixelStorei);
  vm_proxy->defineCFunc ("glPixelTransferf", glPixelTransferf);
  vm_proxy->defineCFunc ("glPixelTransferi", glPixelTransferi);
  vm_proxy->defineCFunc ("glPixelZoom", glPixelZoom);
  vm_proxy->defineCFunc ("glPointSize", glPointSize);
  vm_proxy->defineCFunc ("glPolygonMode", glPolygonMode);
  vm_proxy->defineCFunc ("glPolygonOffset", glPolygonOffset);
  vm_proxy->defineCFunc ("glPolygonStipple", glPolygonStipple);
  vm_proxy->defineCFunc ("glPopAttrib", glPopAttrib);
  vm_proxy->defineCFunc ("glPopClientAttrib", glPopClientAttrib);
  vm_proxy->defineCFunc ("glPopMatrix", glPopMatrix);
  vm_proxy->defineCFunc ("glPopName", glPopName);
  vm_proxy->defineCFunc ("glPushAttrib", glPushAttrib);
  vm_proxy->defineCFunc ("glPushClientAttrib", glPushClientAttrib);
  vm_proxy->defineCFunc ("glPushMatrix", glPushMatrix); 
  vm_proxy->defineCFunc ("glPushName", glPushName);
  vm_proxy->defineCFunc ("glRasterPos2d", glRasterPos2d);
  vm_proxy->defineCFunc ("glRasterPos2dv", glRasterPos2dv);
  vm_proxy->defineCFunc ("glRasterPos2f", glRasterPos2f);
  vm_proxy->defineCFunc ("glRasterPos2fv", glRasterPos2fv);
  vm_proxy->defineCFunc ("glRasterPos2i", glRasterPos2i);
  vm_proxy->defineCFunc ("glRasterPos2iv", glRasterPos2iv);
  vm_proxy->defineCFunc ("glRasterPos2s", glRasterPos2s);
  vm_proxy->defineCFunc ("glRasterPos2sv", glRasterPos2sv);
  vm_proxy->defineCFunc ("glRasterPos3d", glRasterPos3d);
  vm_proxy->defineCFunc ("glRasterPos3dv", glRasterPos3dv);
  vm_proxy->defineCFunc ("glRasterPos3f", glRasterPos3f);
  vm_proxy->defineCFunc ("glRasterPos3fv", glRasterPos3fv);
  vm_proxy->defineCFunc ("glRasterPos3i", glRasterPos3i);
  vm_proxy->defineCFunc ("glRasterPos3iv", glRasterPos3iv);
  vm_proxy->defineCFunc ("glRasterPos3s", glRasterPos3s);
  vm_proxy->defineCFunc ("glRasterPos3sv", glRasterPos3sv);
  vm_proxy->defineCFunc ("glRasterPos4d", glRasterPos4d);
  vm_proxy->defineCFunc ("glRasterPos4dv", glRasterPos4dv);
  vm_proxy->defineCFunc ("glRasterPos4f", glRasterPos4f);
  vm_proxy->defineCFunc ("glRasterPos4fv", glRasterPos4fv);
  vm_proxy->defineCFunc ("glRasterPos4i", glRasterPos4i);
  vm_proxy->defineCFunc ("glRasterPos4iv", glRasterPos4iv);
  vm_proxy->defineCFunc ("glRasterPos4s", glRasterPos4s);
  vm_proxy->defineCFunc ("glRasterPos4sv", glRasterPos4sv);
  vm_proxy->defineCFunc ("glRasterPosv", gst_opengl_glRasterPosv);
  vm_proxy->defineCFunc ("glReadBuffer", glReadBuffer);
  vm_proxy->defineCFunc ("glRectd", glRectd);
  vm_proxy->defineCFunc ("glRectdv", glRectdv);
  vm_proxy->defineCFunc ("glRectf", glRectf);
  vm_proxy->defineCFunc ("glRectfv", glRectfv);
  vm_proxy->defineCFunc ("glRecti", glRecti);
  vm_proxy->defineCFunc ("glRectiv", glRectiv);
  vm_proxy->defineCFunc ("glRects", glRects);
  vm_proxy->defineCFunc ("glRectsv", glRectsv);
  vm_proxy->defineCFunc ("glRenderMode", glRenderMode);
#if 0
  vm_proxy->defineCFunc ("glResetHistogram", glResetHistogram);
  vm_proxy->defineCFunc ("glResetMinmax", glResetMinmax);
#endif
  vm_proxy->defineCFunc ("glRotatev", gst_opengl_glRotatev);
  vm_proxy->defineCFunc ("glRotated", glRotated);
  vm_proxy->defineCFunc ("glRotatef", glRotatef);
#if 0
  vm_proxy->defineCFunc ("glSampleCoverage", glSampleCoverage);
#endif
  vm_proxy->defineCFunc ("glScalev", gst_opengl_glScalev);
  vm_proxy->defineCFunc ("glScaled", glScaled);
  vm_proxy->defineCFunc ("glScalef", glScalef);
  vm_proxy->defineCFunc ("glScissor", glScissor);
  vm_proxy->defineCFunc ("glSelectBuffer", glSelectBuffer);
  vm_proxy->defineCFunc ("glShadeModel", glShadeModel);
  vm_proxy->defineCFunc ("glStencilFunc", glStencilFunc);
  vm_proxy->defineCFunc ("glStencilMask", glStencilMask);
  vm_proxy->defineCFunc ("glStencilOp", glStencilOp);
  vm_proxy->defineCFunc ("glTexCoord1d", glTexCoord1d);
  vm_proxy->defineCFunc ("glTexCoord1dv", glTexCoord1dv);
  vm_proxy->defineCFunc ("glTexCoord1f", glTexCoord1f);
  vm_proxy->defineCFunc ("glTexCoord1fv", glTexCoord1fv);
  vm_proxy->defineCFunc ("glTexCoord1i", glTexCoord1i);
  vm_proxy->defineCFunc ("glTexCoord1iv", glTexCoord1iv);
  vm_proxy->defineCFunc ("glTexCoord1s", glTexCoord1s);
  vm_proxy->defineCFunc ("glTexCoord1sv", glTexCoord1sv);
  vm_proxy->defineCFunc ("glTexCoord2d", glTexCoord2d);
  vm_proxy->defineCFunc ("glTexCoord2dv", glTexCoord2dv);
  vm_proxy->defineCFunc ("glTexCoord2f", glTexCoord2f);
  vm_proxy->defineCFunc ("glTexCoord2fv", glTexCoord2fv);
  vm_proxy->defineCFunc ("glTexCoord2i", glTexCoord2i);
  vm_proxy->defineCFunc ("glTexCoord2iv", glTexCoord2iv);
  vm_proxy->defineCFunc ("glTexCoord2s", glTexCoord2s);
  vm_proxy->defineCFunc ("glTexCoord2sv", glTexCoord2sv);
  vm_proxy->defineCFunc ("glTexCoord3d", glTexCoord3d);
  vm_proxy->defineCFunc ("glTexCoord3dv", glTexCoord3dv);
  vm_proxy->defineCFunc ("glTexCoord3f", glTexCoord3f);
  vm_proxy->defineCFunc ("glTexCoord3fv", glTexCoord3fv);
  vm_proxy->defineCFunc ("glTexCoord3i", glTexCoord3i);
  vm_proxy->defineCFunc ("glTexCoord3iv", glTexCoord3iv);
  vm_proxy->defineCFunc ("glTexCoord3s", glTexCoord3s);
  vm_proxy->defineCFunc ("glTexCoord3sv", glTexCoord3sv);
  vm_proxy->defineCFunc ("glTexCoord4d", glTexCoord4d);
  vm_proxy->defineCFunc ("glTexCoord4dv", glTexCoord4dv);
  vm_proxy->defineCFunc ("glTexCoord4f", glTexCoord4f);
  vm_proxy->defineCFunc ("glTexCoord4fv", glTexCoord4fv);
  vm_proxy->defineCFunc ("glTexCoord4i", glTexCoord4i);
  vm_proxy->defineCFunc ("glTexCoord4iv", glTexCoord4iv);
  vm_proxy->defineCFunc ("glTexCoord4s", glTexCoord4s);
  vm_proxy->defineCFunc ("glTexCoord4sv", glTexCoord4sv);
  vm_proxy->defineCFunc ("glTexCoordv", gst_opengl_glTexCoordv);
  vm_proxy->defineCFunc ("glTexEnvf", glTexEnvf);
  vm_proxy->defineCFunc ("glTexEnvfv", glTexEnvfv);
  vm_proxy->defineCFunc ("glTexEnvi", glTexEnvi);
  vm_proxy->defineCFunc ("glTexEnviv", glTexEnviv);
  vm_proxy->defineCFunc ("glTexEnvv", gst_opengl_glTexEnvv);
  vm_proxy->defineCFunc ("glTexGend", glTexGend);
  vm_proxy->defineCFunc ("glTexGendv", glTexGendv);
  vm_proxy->defineCFunc ("glTexGenf", glTexGenf);
  vm_proxy->defineCFunc ("glTexGenfv", glTexGenfv);
  vm_proxy->defineCFunc ("glTexGeni", glTexGeni);
  vm_proxy->defineCFunc ("glTexGeniv", glTexGeniv);
  vm_proxy->defineCFunc ("glTexImage1D", glTexImage1D);
  vm_proxy->defineCFunc ("glTexImage2D", glTexImage2D);
  vm_proxy->defineCFunc ("glTexParameterf", glTexParameterf);
  vm_proxy->defineCFunc ("glTexParameterfv", glTexParameterfv);
  vm_proxy->defineCFunc ("glTexParameteri", glTexParameteri);
  vm_proxy->defineCFunc ("glTexParameteriv", glTexParameteriv);
  vm_proxy->defineCFunc ("glTexParameterv", gst_opengl_glTexParameterv);
  vm_proxy->defineCFunc ("glTranslatev", gst_opengl_glTranslatev);
  vm_proxy->defineCFunc ("glTranslated", glTranslated);
  vm_proxy->defineCFunc ("glTranslatef", glTranslatef);
  vm_proxy->defineCFunc ("glVertex2d", glVertex2d);
  vm_proxy->defineCFunc ("glVertex2dv", glVertex2dv);
  vm_proxy->defineCFunc ("glVertex2f", glVertex2f);
  vm_proxy->defineCFunc ("glVertex2fv", glVertex2fv);
  vm_proxy->defineCFunc ("glVertex2i", glVertex2i);
  vm_proxy->defineCFunc ("glVertex2iv", glVertex2iv);
  vm_proxy->defineCFunc ("glVertex2s", glVertex2s);
  vm_proxy->defineCFunc ("glVertex2sv", glVertex2sv);
  vm_proxy->defineCFunc ("glVertex3d", glVertex3d);
  vm_proxy->defineCFunc ("glVertex3dv", glVertex3dv);
  vm_proxy->defineCFunc ("glVertex3f", glVertex3f);
  vm_proxy->defineCFunc ("glVertex3fv", glVertex3fv);
  vm_proxy->defineCFunc ("glVertex3i", glVertex3i);
  vm_proxy->defineCFunc ("glVertex3iv", glVertex3iv);
  vm_proxy->defineCFunc ("glVertex3s", glVertex3s);
  vm_proxy->defineCFunc ("glVertex3sv", glVertex3sv);
  vm_proxy->defineCFunc ("glVertex4d", glVertex4d);
  vm_proxy->defineCFunc ("glVertex4dv", glVertex4dv);
  vm_proxy->defineCFunc ("glVertex4f", glVertex4f);
  vm_proxy->defineCFunc ("glVertex4fv", glVertex4fv);
  vm_proxy->defineCFunc ("glVertex4i", glVertex4i);
  vm_proxy->defineCFunc ("glVertex4iv", glVertex4iv);
  vm_proxy->defineCFunc ("glVertex4s", glVertex4s);
  vm_proxy->defineCFunc ("glVertex4sv", glVertex4sv);
  vm_proxy->defineCFunc ("glVertexv", gst_opengl_glVertexv);
  vm_proxy->defineCFunc ("glViewport", glViewport);
  vm_proxy->defineCFunc("glCopyTexImage1D", glCopyTexImage1D);
  vm_proxy->defineCFunc("glCopyTexImage2D", glCopyTexImage2D);
  vm_proxy->defineCFunc("glCopyTexSubImage1D", glCopyTexSubImage1D);
  vm_proxy->defineCFunc("glCopyTexSubImage2D", glCopyTexSubImage2D);
  vm_proxy->defineCFunc("glMap1d", glMap1d);
  vm_proxy->defineCFunc("glMap1f", glMap1f);
  vm_proxy->defineCFunc("glMap1v", gst_opengl_glMap1v);
  vm_proxy->defineCFunc("glMap2d", glMap2d);
  vm_proxy->defineCFunc("glMap2f", glMap2f);
  vm_proxy->defineCFunc("glMap2v", gst_opengl_glMap2v);
  vm_proxy->defineCFunc("glTexSubImage1D", glTexSubImage1D);
  vm_proxy->defineCFunc("glTexSubImage2D", glTexSubImage2D);
  
#if 0
  vm_proxy->defineCFunc ("glTextureRangeAPPLE", glTextureRangeAPPLE);
  vm_proxy->defineCFunc ("glFinishObjectAPPLE", glFinishObjectAPPLE);
#endif

#if 0
  vm_proxy->defineCFunc ("glActiveTextureARB", glActiveTextureARB);
  vm_proxy->defineCFunc ("glClientActiveTextureARB", glClientActiveTextureARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1dARB", glMultiTexCoord1dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1dvARB", glMultiTexCoord1dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1fARB", glMultiTexCoord1fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1fvARB", glMultiTexCoord1fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1iARB", glMultiTexCoord1iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1ivARB", glMultiTexCoord1ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1sARB", glMultiTexCoord1sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1svARB", glMultiTexCoord1svARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2dARB", glMultiTexCoord2dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2dvARB", glMultiTexCoord2dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2fARB", glMultiTexCoord2fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2fvARB", glMultiTexCoord2fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2iARB", glMultiTexCoord2iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2ivARB", glMultiTexCoord2ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2sARB", glMultiTexCoord2sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2svARB", glMultiTexCoord2svARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3dARB", glMultiTexCoord3dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3dvARB", glMultiTexCoord3dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3fARB", glMultiTexCoord3fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3fvARB", glMultiTexCoord3fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3iARB", glMultiTexCoord3iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3ivARB", glMultiTexCoord3ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3sARB", glMultiTexCoord3sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3svARB", glMultiTexCoord3svARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4dARB", glMultiTexCoord4dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4dvARB", glMultiTexCoord4dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4fARB", glMultiTexCoord4fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4fvARB", glMultiTexCoord4fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4iARB", glMultiTexCoord4iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4ivARB", glMultiTexCoord4ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4sARB", glMultiTexCoord4sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4svARB", glMultiTexCoord4svARB);
  
#endif
  
#if 0
  vm_proxy->defineCFunc ("glDisableTraceMESA", glDisableTraceMESA);
  vm_proxy->defineCFunc ("glEnableTraceMESA", glEnableTraceMESA);
  vm_proxy->defineCFunc ("glEndTraceMESA", glEndTraceMESA);
  vm_proxy->defineCFunc ("glGetProgramRegisterfvMESA", glGetProgramRegisterfvMESA);
  vm_proxy->defineCFunc ("glProgramCallbackMESA", glProgramCallbackMESA);
  vm_proxy->defineCFunc ("glTraceAssertAttribMESA", glTraceAssertAttribMESA);
#endif
  
#if 0
  vm_proxy->defineCFunc ("glBlendEquationSeparateATI", glBlendEquationSeparateATI);
#endif
}
