"======================================================================
|
|   Teapot example using OpenGL
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
    | aWindow windowNumber eyePosition axeX axeY axeZ saveX |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	"Define the position of the eye"

	<category: 'test'>
	eyePosition := Vertex 
		    x: 0.0
		    y: 0.0
		    z: 0.0.
	axeX := false.
	axeY := false.
	axeZ := false.
	"Create the window and initialize callbacks"
	aWindow isNil 
	    ifTrue: 
		[aWindow := Glut new.
		aWindow glutInit: 'une theiere smalltalkienne'.
		aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
			    bitOr: Glut glutDepth).
		aWindow glutInitWindowSize: (Point x: 500 y: 500).
		aWindow glutInitWindowPosition: (Point x: 100 y: 100).
		windowNumber := aWindow glutCreateWindow: 'Une sphere...'.

		"Init window color and shading model"
		aWindow glClearColor: Color black.
		aWindow glShadeModel: OpenGLInterface glSmooth.
		aWindow 
		    glMaterialv: OpenGLInterface glFront
		    mode: OpenGLInterface glSpecular
		    value: (Array 
			    with: 1.0
			    with: 0.0
			    with: 0.3
			    with: 0.5).
		aWindow 
		    glMaterialf: OpenGLInterface glFront
		    mode: OpenGLInterface glShininess
		    value: 50.0.
		aWindow 
		    glLightv: OpenGLInterface glLight0
		    property: OpenGLInterface glPosition
		    value: (Array 
			    with: 1.0
			    with: 1.0
			    with: 1.0
			    with: 0.0).
		aWindow glEnable: OpenGLInterface glLighting.
		aWindow glEnable: OpenGLInterface glLight0.
		aWindow glEnable: OpenGLInterface glDepthTest.

		aWindow 
		    callback: Glut idleFuncEvent
		    to: [self idle].
		aWindow 
		    callback: Glut displayFuncEvent
		    to: [self display].
		aWindow 
		    callback: Glut reshapeFuncEvent
		    to: [:w :h | self reshape: w height: h].
		aWindow 
		    callback: Glut mouseFuncEvent
		    to: [:button :state :x :y | self mouse: button state: state x: x y: y].
		aWindow 
		    callback: Glut motionFuncEvent
		    to: [:x :y | self follow: x y: y]
		]
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [

	<category: 'test'>

	aWindow glClear: (OpenGLInterface glColorBufferBit bitOr: OpenGLInterface glDepthBufferBit).
	aWindow glLoadIdentity.
	aWindow 
	    gluLookAt: (Vertex 
		    x: 0.0
		    y: 0.0
		    z: 5.0)
	    center: (Vertex 
		    x: 0.0
		    y: 0.0
		    z: 0.0)
	    up: (Vertex 
		    x: 0.0
		    y: 1.0
		    z: 0.0).
	aWindow glPushMatrix.
	aWindow glTranslate: (Vertex 
		    x: -1.0
		    y: 0.0
		    z: 0.0).
	aWindow 
	    glRotatef: eyePosition x
	    x: 1.0
	    y: 0.0
	    z: 0.0.
	aWindow 
	    glRotatef: eyePosition y
	    x: 0.0
	    y: 1.0
	    z: 0.0.
	aWindow 
	    glRotatef: eyePosition z
	    x: 0.0
	    y: 0.0
	    z: 1.0.
	aWindow glScale: (Vertex 
		    x: 1.0
		    y: 1.2
		    z: 1.0).
	aWindow glutSolidTeapot: 1.0.
	aWindow glPopMatrix.
	aWindow 
	    glColor3f: 0.4
	    green: 0.4
	    blue: 0.7.
	aWindow 
	    glMaterialv: OpenGLInterface glFrontAndBack
	    mode: OpenGLInterface glAmbient
	    value: (Color red: 0.5 green: 0.5 blue: 0.5).
	aWindow glTranslate: (Vertex 
		    x: 1.5
		    y: 0.0
		    z: 0.0).
	aWindow glScale: (Vertex 
		    x: 0.5
		    y: 1.0
		    z: 0.5).
	aWindow 
	    glutSolidSphere: 1.0
	    slices: 20
	    stacks: 16.
	aWindow glLoadIdentity.
	aWindow glutSwapBuffers
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Point x: 0 y: 0) extend: (Point x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	aWindow 
	    glFrustum: -1.0
	    right: 1.0
	    bottom: -1.0
	    top: 1.0
	    near: 1.5
	    far: 20.0.
	"w <= h"
	"ifTrue: ["
	"aWindow glOrtho: -1.5 right: 1.5"
	"bottom: (-1.5*h/w) top: (1.5*h/w)"
	"near: -10.0 far: 10.0."
	"]"
	"ifFalse: ["
	"aWindow glOrtho:(-1.5*w/h) right: (1.5*w/h)"
	"bottom: -1.5 top: 1.5"
	"near: -10.0 far: 10.0."
	"]."
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity
    ]

    follow: aX y: aY [
	<category: 'test'>
	axeX 
	    ifTrue: 
		[eyePosition x: eyePosition x + (saveX - aX).
		eyePosition x > 359 ifTrue: [eyePosition x: eyePosition x - 360].
		eyePosition x < 0 ifTrue: [eyePosition x: 360 + eyePosition x].
		aWindow glutPostRedisplay].
	axeY 
	    ifTrue: 
		[eyePosition y: eyePosition y + (saveX - aX).
		eyePosition y > 359 ifTrue: [eyePosition y: eyePosition y - 360].
		eyePosition y < 0 ifTrue: [eyePosition y: 360 + eyePosition y].
		aWindow glutPostRedisplay].
	axeZ 
	    ifTrue: 
		[eyePosition z: eyePosition z + (saveX - aX).
		eyePosition z > 359 ifTrue: [eyePosition z: eyePosition z - 360].
		eyePosition z < 0 ifTrue: [eyePosition z: 360 + eyePosition z].
		aWindow glutPostRedisplay].
	saveX := aX
    ]

    mouse: aButton state: aState x: aX y: aY [
	"aButton printString printNl."

	<category: 'test'>
	aButton = Glut glutLeftButton ifTrue: [axeX := aState = Glut glutDown].
	aButton > Glut glutRightButton 
	    ifTrue: [axeY := aState = Glut glutDown].
	aButton = Glut glutRightButton 
	    ifTrue: [axeZ := aState = Glut glutDown].
	saveX := aX
    ]

    idle [
	<category: 'test'>
	Processor yield
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

