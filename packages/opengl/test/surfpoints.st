"======================================================================
|
|   OpenGL gluNurbs Callback Example
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


"  surfpoints.st "
"  This program is a modification of the earlier surface.c "
"  program.  The vertex data are not directly rendered, "
"  but are instead passed to the callback function.   "
"  The values of the tessellated vertices are printed  "
"  out there. "

"  This program draws a NURBS surface in the shape of a  "
"  symmetrical hill.  The 'c' keyboard key allows you to  "
"  toggle the visibility of the control points themselves.   "
"  Note that some of the control points are hidden by the   "
"  surface itself. "



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: SurfPoints [
    | aWindow windowNumber aNurb showPoints translate ctlPoints |
    
    <category: 'OpenGL'>
    <comment: nil>

    initSurface [
	"Initializes the control points of the surface to a small hill."

	"The control points range from -3 to +3 in x, y, and z"

	<category: 'test'>
	ctlPoints := Array new: 4 * 4 * 3.
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
	"Initialize material property and depth buffer."

	<category: 'test'>
	showPoints := false.
	translate := Vertex 
		    x: 0.0
		    y: 0.0
		    z: -5.0.
	aWindow := Glut new.
	aWindow glutInit: 'surfPoints'.
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 500 y: 500).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'surfPoints'.

	"Init window color and shading model"
	aWindow glClearColor: Color black.
	aWindow 
	    glMaterialv: OpenGLInterface glFront
	    mode: OpenGLInterface glDiffuse
	    value: (Array 
		    with: 0.7000000000000001
		    with: 0.7000000000000001
		    with: 0.7000000000000001
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
	aNurb gluNurbsProperty: OpenGLInterface gluNurbsMode value: OpenGLInterface gluNurbsTessellator.
	aNurb gluNurbsProperty: OpenGLInterface gluSamplingTolerance value: 25.0.
	aNurb gluNurbsProperty: OpenGLInterface gluDisplayMode value: OpenGLInterface gluFill.

	aNurb 
	    callback: OpenGLInterface gluNurbsBegin
	    to: [:n | self beginCallback: n].
	aNurb 
	    callback: OpenGLInterface gluNurbsVertex
	    to: [:x :y :z | self vertexCallback: x y: y z: z].
	aNurb 
	    callback: OpenGLInterface gluNurbsNormal
	    to: [:x :y :z | self normalCallback:x y: y z: z].
	aNurb 
	    callback: OpenGLInterface gluNurbsEnd
	    to: [self endCallback].
	"aNurb
	    callback: OpenGLInterface gluNurbsError
	    to: [:error | Transcript show: (aWindow gluErrorString: error); nl]."

	aWindow 
	    callback: Glut keyboardFuncEvent
	    to: [:k :x :y | self keyboard: k x: x y: y].
	aWindow 
	    callback: Glut displayFuncEvent
	    to: [self display].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [:w :h | self reshape:w height: h]

    ]

    beginCallback: whichType [
	"diagnostic message"

	<category: 'test'>
	Transcript show: 'glBegin: '.
	whichType = OpenGLInterface glLines 
	    ifTrue: 
		[Transcript
		    show: 'glLines';
		    cr].
	whichType = OpenGLInterface glLineLoop 
	    ifTrue: 
		[Transcript
		    show: 'glLineLoop';
		    cr].
	whichType = OpenGLInterface glLineStrip 
	    ifTrue: 
		[Transcript
		    show: 'glLineStrip';
		    cr].
	whichType = OpenGLInterface glTriangles 
	    ifTrue: 
		[Transcript
		    show: 'glTriangles';
		    cr].
	whichType = OpenGLInterface glTriangleStrip 
	    ifTrue: 
		[Transcript
		    show: 'glTriangleStrip';
		    cr].
	whichType = OpenGLInterface glTriangleFan 
	    ifTrue: 
		[Transcript
		    show: 'glTriangleFan';
		    cr].
	whichType = OpenGLInterface glQuads 
	    ifTrue: 
		[Transcript
		    show: 'glQuads';
		    cr].
	whichType = OpenGLInterface glQuadStrip 
	    ifTrue: 
		[Transcript
		    show: 'glQuadStrip';
		    cr].
	whichType = OpenGLInterface glPolygon 
	    ifTrue: 
		[Transcript
		    show: 'glPolygon';
		    cr].
	aWindow glBegin: whichType	"resubmit rendering directive"
    ]

    endCallback [
	<category: 'test'>
	aWindow glEnd.	"resubmit rendering directive"
	Transcript
	    show: 'glEnd';
	    cr
    ]

    vertexCallback: x y: y z: z [
	"Transcript show: 'glVertex glVertex3f: ' , x printString , ' ' , y printString , ' ' , z printString ; cr."

	<category: 'test'>
	aWindow 
	    glVertex3f: x
	    y: y
	    z: z	"resubmit rendering directive"
    ]

    normalCallback: x y: y z: z [
	"Transcript show: 'glNormal3f: ' , x printString , ' ' , y printString , ' ' , z printString ; cr."

	<category: 'test'>
	aWindow 
	    glNormal3f: x
	    y: y
	    z: z	"resubmit rendering directive"
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'test'>
	| knots |
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
	    control: ctlPoints
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
				    glVertex3f: (ctlPoints at: i * 12 + (j * 3) + 1)
				    y: (ctlPoints at: i * 12 + (j * 3) + 2)
				    z: (ctlPoints at: i * 12 + (j * 3) + 3)]].
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
		Transcript show: 'Points : ' , showPoints printString; nl].
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
]

]



Namespace current: OpenGL [
    SurfPoints new init; mainIteration.
    Processor activeProcess suspend

]

