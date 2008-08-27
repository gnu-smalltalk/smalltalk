"======================================================================
|
|   OpenGL gluTrim Example
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


"======================================================================
|
|   trim.st
|   This program draws a NURBS surface in the shape of a 
|   symmetrical hill, using both a NURBS curve and pwl
|   (piecewise linear) curve to trim part of the surface.
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

    initSurface [
	<category: 'test'>
	"Initializes the control points of the surface to a small hill."
	"The control points range from -3 to +3 in x, y, and z"
	| u v |
	ctlPoints := Array new: 48.
	(0 to: 3) do: 
		[:u | 
		(0 to: 3) do: 
			[:v | 
			ctlPoints at: u * 12 + (v * 3) + 1 put: 2.0 * (u - 1.5).
			ctlPoints at: u * 12 + (v * 3) + 2 put: 2.0 * (v - 1.5).
			((u = 1 or: [u = 2]) and: [v = 1 or: [v = 2]]) 
			    ifTrue: [ctlPoints at: u * 12 + (v * 3) + 3 put: 3.0]
			    ifFalse: [ctlPoints at: u * 12 + (v * 3) + 3 put: -3.0]]]
    ]

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
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutSingle) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 500 y: 500).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Trim Surface'.

	"Init window color and shading model"
	aWindow glClearColor: Color black.
	aWindow 
	    glMaterialv: OpenGLInterface glFront
	    mode: OpenGLInterface glDiffuse
	    value: (Array 
		    with: 0.7
		    with: 0.7
		    with: 0.7
		    with: 1.0).
	aWindow 
	    glMaterialv: OpenGLInterface glFront
	    mode: OpenGLInterface glSpecular
	    value: (Array 
		    with: 1.0
		    with: 1.0
		    with: 1.0
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

	aNurb callback: OpenGLInterface gluNurbsError
		to: [:e | Transcript show: 'Nurb error : ' , (aWindow gluErrorString: e) ; cr].

	aWindow 
	    callback: Glut keyboardFuncEvent
	    to: [:key :x :y | self keyboard: key x: x y: y].
	aWindow 
	    callback: Glut displayFuncEvent
	    to: [self display].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [:w :h | self reshape: w height: h]
    ]


    mainIteration [
	aWindow mainIteration
    ]

    display [
		<category: 'test'>
		| knots edgePt curvePt curveKnots pwlPt i j |
		knots := #(0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0).

	    edgePt := #(0.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 0.0).

		curvePt := #(0.25 0.5 0.25 0.75 0.75 0.75 0.75 0.5).
		curveKnots := #(0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0).

		pwlPt := #(0.75 0.5 0.5 0.25 0.25 0.5).

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
	    control: ctlPoints
	    sOrder: 4
	    tOrder: 4
	    type: OpenGLInterface glMap2Vertex3.

   aNurb gluBeginTrim.
     aNurb gluPwlCurve: 5 edge: edgePt stride: 2 type: OpenGLInterface gluMap1Trim2.
   aNurb gluEndTrim.

   aNurb gluBeginTrim.
     aNurb gluNurbsCurve: 8
	   knots: curveKnots
	   stride: 2
	   control: curvePt
	   order: 4
	   type: OpenGLInterface gluMap1Trim2.

      aNurb gluPwlCurve: 3 edge: pwlPt stride: 2 type: OpenGLInterface gluMap1Trim2.
    aNurb gluEndTrim.

	aNurb gluEndSurface.

	aWindow glPopMatrix.
	aWindow glFlush.
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

