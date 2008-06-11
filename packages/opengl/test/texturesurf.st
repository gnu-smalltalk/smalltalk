"======================================================================
|
|   Textured Bezier surface example using OpenGL
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Olivier Blanc.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: TextureSurface [
    | aWindow windowNumber aNurb showPoints image imageWidth imageHeight |
    
    <category: 'OpenGL'>
    <comment: nil>

    ctrlPoints [
	<category: 'init'>
	^#(-1.5 -1.5 4.0 -0.5 -1.5 2.0 0.5 -1.5 -1.0 1.5 -1.5 2.0 -1.5 -0.5 1.0 -0.5 -0.5 3.0 0.5 -0.5 0.0 1.5 -0.5 -1.0 -1.5 0.5 4.0 -0.5 0.5 0.0 0.5 0.5 3.0 1.5 0.5 4.0 -1.5 1.5 -2.0 -0.5 1.5 -2.0 0.5 1.5 0.0 1.5 1.5 -1.0)
    ]

    texpts [
	<category: 'init'>
	^#(0.0 0.0 0.0 1.0 1.0 0.0 1.0 1.0)
    ]

    makeImage [
	<category: 'init'>
	| ti tj aStream |
	imageWidth := 64.
	imageHeight := 64.
	image := ByteArray new: 3 * imageWidth * imageHeight.
	aStream := WriteStream on: image.
	(0 to: imageHeight - 1) do: 
		[:i | 
		ti := 2.0 * Float pi * i / imageHeight.
		(0 to: imageWidth - 1) do: 
			[:j | 
			tj := 2.0 * Float pi * j / imageWidth.
			aStream nextPut: (127 * (1.0 + ti sin)) asInteger.
			aStream nextPut: (127 * (1.0 + (2.0 * tj) cos)) asInteger.
			aStream nextPut: (127 * (1.0 + (ti + tj) cos)) asInteger]]
    ]

    init [
	<category: 'init'>
	aWindow := Glut new.
	aWindow glutInit: 'une surface smalltalkienne'.
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutSingle) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 500 y: 500).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Une surface nurbs'.
	aWindow 
	    glMap2: OpenGLInterface glMap2Vertex3
	    u1: 0.0
	    u2: 1.0
	    ustride: 3
	    uorder: 4
	    v1: 0.0
	    v2: 1.0
	    vstride: 12
	    vorder: 4
	    points: self ctrlPoints.
	aWindow 
	    glMap2: OpenGLInterface glMap2TextureCoord2
	    u1: 0.0
	    u2: 1.0
	    ustride: 2
	    uorder: 2
	    v1: 0.0
	    v2: 1.0
	    vstride: 4
	    vorder: 2
	    points: self texpts.
	aWindow glEnable: OpenGLInterface glMap2TextureCoord2.
	aWindow glEnable: OpenGLInterface glMap2Vertex3.
	aWindow 
	    glMapGrid2f: 20
	    u1: 0.0
	    u2: 1.0
	    nv: 20
	    v1: 0.0
	    v2: 1.0.
	aWindow 
	    glTexEnvi: OpenGLInterface glTextureEnv
	    property: OpenGLInterface glTextureEnvMode
	    value: OpenGLInterface glDecal.
	aWindow 
	    glTexParameteri: OpenGLInterface glTexture2d
	    property: OpenGLInterface glTextureWrapS
	    value: OpenGLInterface glRepeat.
	aWindow 
	    glTexParameteri: OpenGLInterface glTexture2d
	    property: OpenGLInterface glTextureWrapT
	    value: OpenGLInterface glRepeat.
	aWindow 
	    glTexParameteri: OpenGLInterface glTexture2d
	    property: OpenGLInterface glTextureMagFilter
	    value: OpenGLInterface glNearest.
	aWindow 
	    glTexParameteri: OpenGLInterface glTexture2d
	    property: OpenGLInterface glTextureMinFilter
	    value: OpenGLInterface glNearest.
	self makeImage.
	aWindow 
	    glTexImage2D: OpenGLInterface glTexture2d
	    level: 0
	    internalFormat: OpenGLInterface glRgb
	    width: imageWidth
	    height: imageHeight
	    border: 0
	    format: OpenGLInterface glRgb
	    type: OpenGLInterface glUnsignedByte
	    pixels: image.
	aWindow glEnable: OpenGLInterface glTexture2d.
	aWindow glEnable: OpenGLInterface glDepthTest.
	aWindow glShadeModel: OpenGLInterface glSmooth.
	aWindow 
	    callback: Glut displayFuncEvent
	    to: [self display].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [:w :h | self reshape: w height: h]
    ]

    reshape: w height: h [
	<category: 'init'>
	aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	w <= h 
	    ifTrue: 
		[aWindow 
		    glOrtho: -4.0
		    right: 4.0
		    bottom: -4.0 * h / w
		    top: 4.0 * h / w
		    near: -4.0
		    far: 4.0]
	    ifFalse: 
		[aWindow 
		    glOrtho: -4.0 * w / h
		    right: 4.0 * w / h
		    bottom: -4.0
		    top: 4.0
		    near: -4.0
		    far: 4.0].
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity.
	aWindow glRotate: 85.0
	    direction: (Vertex 
		    x: 1.0
		    y: 1.0
		    z: 1.0)
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'init'>
	aWindow glClear: (OpenGLInterface glColorBufferBit bitOr: OpenGLInterface glDepthBufferBit).
	aWindow glColor: Color white.
	aWindow 
	    glEvalMesh2: OpenGLInterface glFill
	    i1: 0
	    i2: 20
	    j1: 0
	    j2: 20.
	aWindow glFlush
    ]
]

]



Namespace current: OpenGL [
    TextureSurface new init; mainIteration.
    Processor activeProcess suspend

]

