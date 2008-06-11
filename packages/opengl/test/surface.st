"======================================================================
|
|   OpenGL gluNurbs Example
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Olivier Blanc.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"





Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: OpenGLTest [
    | aWindow windowNumber aNurb showPoints ctlPoints translate image surface |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	"Create the window and initialize callbacks"

	<category: 'test'>
	showPoints := false.
	translate := Vertex 
		    x: 0.0
		    y: 0.0
		    z: -5.0.
	"An array to store the image"
	image := Array new: 64 * 64 * 3.
	aWindow := Glut new.
	aWindow glutInit: 'une surface smalltalkienne'.
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 500 y: 500).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Une surface nurbs'.

	"Init window color and shading model"
	aWindow glClearColor: Color black.
	aWindow 
	    glMaterialv: OpenGLInterface glFront
	    mode: OpenGLInterface glDiffuse
	    value: (Array 
		    with: 0.5
		    with: 0.5
		    with: 0.5
		    with: 1.0).
	aWindow 
	    glMaterialv: OpenGLInterface glFront
	    mode: OpenGLInterface glSpecular
	    value: (Array 
		    with: 0.5
		    with: 0.5
		    with: 0.5
		    with: 1.0).
	aWindow 
	    glMaterialf: OpenGLInterface glFront
	    mode: OpenGLInterface glShininess
	    value: 100.0.
	aWindow glEnable: OpenGLInterface glLighting.
	aWindow glEnable: OpenGLInterface glLight0.
	aWindow glEnable: OpenGLInterface glDepthTest.
	aWindow glEnable: OpenGLInterface glAutoNormal.
	aWindow glEnable: OpenGLInterface glNormalize.
	self initSurface.
	aNurb := Nurbs new.
	aNurb gluNurbsProperty: OpenGLInterface gluSamplingTolerance value: 25.0.
	aNurb gluNurbsProperty: OpenGLInterface gluDisplayMode value: OpenGLInterface gluFill.
	aWindow 
	    callback: Glut keyboardFuncEvent
	    to: [:k :x :y | self keyboard: k x: x y: y].
	aWindow 
	    callback: Glut displayFuncEvent
	    to: [self display].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [:w :h | self reshape: w height: h]
    ]

    makeImage [
	<category: 'test'>
	| ti tj |
	(0 to: 63) do: 
		[:i | 
		ti := 2.0 * 3.14159265 * i / 64.0.
		(0 to: 63) do: 
			[:j | 
			tj := 2.0 * 3.14159265 * j / 64.0.
			image at: 3 * (64 * i + j) put: 127.0 * (1.0 + ti sin).
			image at: 3 * (64 * i + j) + 1 put: 127.0 * (1.0 + (2.0 * tj) sin).
			image at: 3 * (64 * i + j) + 2 put: 127.0 * (1.0 + (ti + tj) cos)]]
    ]

    initSurface [
	<category: 'test'>
	"Initializes the control points of the surface to a small hill."

	"The control points range from -3 to +3 in x, y, and z"

	| u v |
	surface := Array new: 48.
	(0 to: 3) do: 
		[:u | 
		(0 to: 3) do: 
			[:v | 
			surface at: u * 12 + (v * 3) + 1 put: 2.0 * (u - 1.5).
			surface at: u * 12 + (v * 3) + 2 put: 2.0 * (v - 1.5).
			((u = 1 or: [u = 2]) and: [v = 1 or: [v = 2]]) 
			    ifTrue: [surface at: u * 12 + (v * 3) + 3 put: 3.0]
			    ifFalse: [surface at: u * 12 + (v * 3) + 3 put: -3.0]]]
    ]

    error: errorCode [
	<category: 'test'>
	| error |
	error := aWindow gluErrorString: errorCode.
	Transcript
	    show: 'Nurb error : ' , errorCode;
	    cr
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'test'>
	| knots i j |
	knots := #(0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0).
	aWindow glClear: (OpenGLInterface glColorBufferBit bitOr: OpenGLInterface glDepthBufferBit).
	aWindow glPushMatrix.
	aWindow glRotate: 330.0
	    direction: (Vertex 
		    x: 1.0
		    y: 0.0
		    z: 0.0).
	aWindow glScale: (Vertex 
		    x: 0.5
		    y: 0.5
		    z: 0.5).
	aNurb gluBeginSurface.
	aNurb 
	    gluNurbsSurface: 8
	    sKnots: knots
	    tKnotCounts: 8
	    tKnots: knots
	    sStride: 4 * 3
	    tStride: 3
	    control: surface
	    sOrder: 4
	    tOrder: 4
	    type: OpenGLInterface glMap2Vertex3.
	aNurb gluEndSurface.
	showPoints 
	    ifTrue: 
		[aWindow glPointSize: 5.0.
		aWindow glDisable: OpenGLInterface glLighting.
		aWindow glColor: (Color 
			    red: 1.0
			    green: 1.0
			    blue: 0.0).
		aWindow glBegin: OpenGLInterface glPoints.
		(0 to: 3) do: 
			[:i | 
			(0 to: 3) do: 
				[:j | 
				aWindow 
				    glVertex3f: (surface at: i * 12 + (j * 3) + 1)
				    y: (surface at: i * 12 + (j * 3) + 2)
				    z: (surface at: i * 12 + (j * 3) + 3)]].
		aWindow glEnd.
		aWindow glEnable: OpenGLInterface glLighting].
	aWindow glPopMatrix.
	aWindow glutSwapBuffers
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Point x: 0 y: 0) extend: (Point x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	aWindow 
	    gluPerspective: 45.0
	    aspect: 1.0 * w / h
	    near: 3.0
	    far: 8.0.
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity.
	aWindow glTranslate: translate
    ]

    keyboard: aKey x: aX y: aY [
	<category: 'test'>
	aKey = $c 
	    ifTrue: 
		[showPoints := showPoints not.
		aWindow glutPostRedisplay.
		Transcript show: 'Points : ' , showPoints printString].
	aKey = $x ifTrue: [translate x: translate x + 0.5].
	aKey = $X ifTrue: [translate x: translate x - 0.5].
	aKey = $y ifTrue: [translate y: translate y + 0.5].
	aKey = $Y ifTrue: [translate y: translate y - 0.5].
	aKey = $z ifTrue: [translate z: translate z + 0.5].
	aKey = $Z ifTrue: [translate z: translate z - 0.5].
	aWindow glLoadIdentity.
	aWindow glTranslate: translate.
	aWindow glutPostRedisplay
    ]

    window [
	<category: 'access'>
	^aWindow
    ]

    window: a [
	<category: 'access'>
	aWindow := a
    ]
]

]



Namespace current: OpenGL [
    OpenGLTest new init; mainIteration.
    Processor activeProcess suspend

]

