"======================================================================
|
|   OpenGL cube map example
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

Object subclass: OpenGLTest [
    | aWindow windowNumber ztrans zrotate imageSize image1 image2 image3 image4 image5 image6 |
    
    <category: 'OpenGL'>
    <comment: nil>

    makeImages [
	<category: 'test'>
	| c |
	image1 := ByteArray new: imageSize * imageSize * 4.
	image2 := ByteArray new: imageSize * imageSize * 4.
	image3 := ByteArray new: imageSize * imageSize * 4.
	image4 := ByteArray new: imageSize * imageSize * 4.
	image5 := ByteArray new: imageSize * imageSize * 4.
	image6 := ByteArray new: imageSize * imageSize * 4.
	(1 to: imageSize) do: 
		[:i | 
		(1 to: imageSize) do: 
			[:j | 
			c := ((i bitAnd: 1) bitXor: (j bitAnd: 1)) * 255.
			image1 at: (i - 1) * 16 + ((j - 1) * 4) + 1 put: c.
			image1 at: (i - 1) * 16 + ((j - 1) * 4) + 2 put: c.
			image1 at: (i - 1) * 16 + ((j - 1) * 4) + 3 put: c.
			image1 at: (i - 1) * 16 + ((j - 1) * 4) + 4 put: 255.
			image2 at: (i - 1) * 16 + ((j - 1) * 4) + 1 put: c.
			image2 at: (i - 1) * 16 + ((j - 1) * 4) + 2 put: c.
			image2 at: (i - 1) * 16 + ((j - 1) * 4) + 3 put: 0.
			image2 at: (i - 1) * 16 + ((j - 1) * 4) + 4 put: 255.
			image3 at: (i - 1) * 16 + ((j - 1) * 4) + 1 put: c.
			image3 at: (i - 1) * 16 + ((j - 1) * 4) + 2 put: 0.
			image3 at: (i - 1) * 16 + ((j - 1) * 4) + 3 put: c.
			image3 at: (i - 1) * 16 + ((j - 1) * 4) + 4 put: 255.
			image4 at: (i - 1) * 16 + ((j - 1) * 4) + 1 put: 0.
			image4 at: (i - 1) * 16 + ((j - 1) * 4) + 2 put: c.
			image4 at: (i - 1) * 16 + ((j - 1) * 4) + 3 put: c.
			image4 at: (i - 1) * 16 + ((j - 1) * 4) + 4 put: 255.
			image5 at: (i - 1) * 16 + ((j - 1) * 4) + 1 put: 255.
			image5 at: (i - 1) * 16 + ((j - 1) * 4) + 2 put: c.
			image5 at: (i - 1) * 16 + ((j - 1) * 4) + 3 put: c.
			image5 at: (i - 1) * 16 + ((j - 1) * 4) + 4 put: 255.
			image6 at: (i - 1) * 16 + ((j - 1) * 4) + 1 put: c.
			image6 at: (i - 1) * 16 + ((j - 1) * 4) + 2 put: c.
			image6 at: (i - 1) * 16 + ((j - 1) * 4) + 3 put: 255.
			image6 at: (i - 1) * 16 + ((j - 1) * 4) + 4 put: 255]]
    ]

    init [
	<category: 'test'>
	imageSize := 4.
	ztrans := -20.0.
	zrotate := 0.0.

	"Create the window and initialize callbacks"
	aWindow isNil 
	    ifTrue: 
		[aWindow := Glut new.
		aWindow glutInit: 'une surface smalltalkienne'.
		aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
			    bitOr: Glut glutDepth).
		aWindow glutInitWindowSize: (Point x: 400 y: 400).
		aWindow glutInitWindowPosition: (Point x: 100 y: 100).
		windowNumber := aWindow glutCreateWindow: 'Un cube map...'.

		"Init window color and shading model"
		OpenGLInterface current glClearColor: Color black.
		aWindow glEnable: OpenGLInterface glDepthTest.
		aWindow glShadeModel: OpenGLInterface glSmooth.
		self makeImages.
		aWindow glPixelStorei: OpenGLInterface glUnpackAlignment value: 1.
		aWindow 
		    glTexParameteri: OpenGLInterface glTextureCubeMapExt
		    property: OpenGLInterface glTextureWrapS
		    value: OpenGLInterface glRepeat.
		aWindow 
		    glTexParameteri: OpenGLInterface glTextureCubeMapExt
		    property: OpenGLInterface glTextureWrapT
		    value: OpenGLInterface glRepeat.
		aWindow 
		    glTexParameteri: OpenGLInterface glTextureCubeMapExt
		    property: OpenGLInterface glTextureWrapR
		    value: OpenGLInterface glRepeat.
		aWindow 
		    glTexParameteri: OpenGLInterface glTextureCubeMapExt
		    property: OpenGLInterface glTextureMagFilter
		    value: OpenGLInterface glNearest.
		aWindow 
		    glTexParameteri: OpenGLInterface glTextureCubeMapExt
		    property: OpenGLInterface glTextureMinFilter
		    value: OpenGLInterface glNearest.
		aWindow 
		    glTexImage2D: OpenGLInterface glTextureCubeMapPositiveXExt
		    level: 0
		    internalFormat: OpenGLInterface glRgba
		    width: imageSize
		    height: imageSize
		    border: 0
		    format: OpenGLInterface glRgba
		    type: OpenGLInterface glUnsignedByte
		    pixels: image1.
		aWindow 
		    glTexImage2D: OpenGLInterface glTextureCubeMapNegativeXExt
		    level: 0
		    internalFormat: OpenGLInterface glRgba
		    width: imageSize
		    height: imageSize
		    border: 0
		    format: OpenGLInterface glRgba
		    type: OpenGLInterface glUnsignedByte
		    pixels: image4.
		aWindow 
		    glTexImage2D: OpenGLInterface glTextureCubeMapPositiveYExt
		    level: 0
		    internalFormat: OpenGLInterface glRgba
		    width: imageSize
		    height: imageSize
		    border: 0
		    format: OpenGLInterface glRgba
		    type: OpenGLInterface glUnsignedByte
		    pixels: image2.
		aWindow 
		    glTexImage2D: OpenGLInterface glTextureCubeMapNegativeYExt
		    level: 0
		    internalFormat: OpenGLInterface glRgba
		    width: imageSize
		    height: imageSize
		    border: 0
		    format: OpenGLInterface glRgba
		    type: OpenGLInterface glUnsignedByte
		    pixels: image5.
		aWindow 
		    glTexImage2D: OpenGLInterface glTextureCubeMapPositiveZExt
		    level: 0
		    internalFormat: OpenGLInterface glRgba
		    width: imageSize
		    height: imageSize
		    border: 0
		    format: OpenGLInterface glRgba
		    type: OpenGLInterface glUnsignedByte
		    pixels: image3.
		aWindow 
		    glTexImage2D: OpenGLInterface glTextureCubeMapNegativeZExt
		    level: 0
		    internalFormat: OpenGLInterface glRgba
		    width: imageSize
		    height: imageSize
		    border: 0
		    format: OpenGLInterface glRgba
		    type: OpenGLInterface glUnsignedByte
		    pixels: image6.
		aWindow 
		    glTexGeni: OpenGLInterface glS
		    property: OpenGLInterface glTextureGenMode
		    value: OpenGLInterface glNormalMapExt.
		aWindow 
		    glTexGeni: OpenGLInterface glT
		    property: OpenGLInterface glTextureGenMode
		    value: OpenGLInterface glNormalMapExt.
		aWindow 
		    glTexGeni: OpenGLInterface glR
		    property: OpenGLInterface glTextureGenMode
		    value: OpenGLInterface glNormalMapExt.
		aWindow glEnable: OpenGLInterface glTextureGenS.
		aWindow glEnable: OpenGLInterface glTextureGenT.
		aWindow glEnable: OpenGLInterface glTextureGenR.
		aWindow 
		    glTexEnvi: OpenGLInterface glTextureEnv
		    property: OpenGLInterface glTextureEnvMode
		    value: OpenGLInterface glModulate.
		aWindow glEnable: OpenGLInterface glTextureCubeMapExt.
		aWindow glEnable: OpenGLInterface glLighting.
		aWindow glEnable: OpenGLInterface glLight0.
		aWindow glEnable: OpenGLInterface glAutoNormal.
		aWindow glEnable: OpenGLInterface glNormalize.
		aWindow 
		    glMaterialv: OpenGLInterface glFront
		    mode: OpenGLInterface glDiffuse
		    value: #(1.0 1.0 1.0 1.0).
		aWindow 
		    callback: Glut displayFuncEvent
		    to: [self display].
		aWindow 
		    callback: Glut keyboardFuncEvent
		    to: [:k :x :y | self keyboard: k x:x y: y].
		aWindow 
		    callback: Glut reshapeFuncEvent
		    to: [:w :h | self reshape: w height: h]
		]
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'test'>
	aWindow glClear: (OpenGLInterface glColorBufferBit bitOr: OpenGLInterface glDepthBufferBit).
	aWindow glPushMatrix.
	aWindow 
	    glTranslatef: 0.0
	    y: 5.0
	    z: ztrans.
	aWindow 
	    glutSolidSphere: 5.0
	    slices: 20
	    stacks: 10.
	aWindow 
	    glTranslatef: 0.0
	    y: -12.0
	    z: 0.0.
	aWindow glRotate: zrotate
	    direction: (Vertex 
		    x: 0.0
		    y: 1.0
		    z: 0.0).
	aWindow 
	    glutSolidTorus: 2.0
	    outerRadius: 4.0
	    sides: 20
	    stacks: 10.
	aWindow glPopMatrix.
	aWindow glutSwapBuffers
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Point x: 0 y: 0) extend: (Point x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	aWindow 
	    gluPerspective: 40.0
	    aspect: 1.0 * w / h
	    near: 1.0
	    far: 300.0.
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity.
	aWindow 
	    glTranslatef: 0.0
	    y: 0.0
	    z: -20.0
    ]

    keyboard: aKey x: aX y: aY [
	<category: 'test'>
	aKey = $f 
	    ifTrue: 
		[ztrans := ztrans - 0.2.
		aWindow glutPostRedisplay].
	aKey = $b 
	    ifTrue: 
		[ztrans := ztrans + 0.2.
		aWindow glutPostRedisplay].
	aKey = $r 
	    ifTrue: 
		[zrotate := (zrotate + 2) \\ 360.
		aWindow glutPostRedisplay].
	aKey = $l 
	    ifTrue: 
		[zrotate := (zrotate - 2) \\ 360.
		aWindow glutPostRedisplay]
    ]
]

]



Namespace current: OpenGL [
    OpenGLTest new init; mainIteration.
    Processor activeProcess suspend

]

