"======================================================================
|
|   Bezier surface example using OpenGL (including lighting)
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

    controlPoints [
	<category: 'test'>
	^#(-1.5 -1.5 4.0 -0.5 -1.5 2.0 0.5 -1.5 -1.0 1.5 -1.5 2.0 -1.5 -0.5 1.0 -0.5 -0.5 3.0 0.5 -0.5 0.0 1.5 -0.5 -1.0 -1.5 0.5 4.0 -0.5 0.5 0.0 0.5 0.5 3.0 1.5 0.5 4.0 -1.5 1.5 -2.0 -0.5 1.5 -2.0 0.5 1.5 0.0 1.5 1.5 -1.0)
    ]

    init [
	"Define the position of the eye"

	<category: 'test'>
	eyePosition := Vertex 
		    x: 0.0
		    y: 0.0
		    z: 5.0.
	axeX := false.
	axeY := false.
	axeZ := false.

	"Create the window and initialize callbacks"
	aWindow isNil 
	    ifTrue: 
		[aWindow := Glut new.
		aWindow glutInit: 'une surface smalltalkienne'.
		aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutSingle) 
			    bitOr: Glut glutDepth).
		aWindow glutInitWindowSize: (Point x: 500 y: 500).
		aWindow glutInitWindowPosition: (Point x: 100 y: 100).
		windowNumber := aWindow glutCreateWindow: 'Une surface de Bezier...'.

		"Init window color and shading model"
		aWindow glClearColor: Color black.

		"self controlPoints inspect."
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
		    points: self controlPoints.
		aWindow glEnable: OpenGLInterface glMap2Vertex3.
		aWindow glEnable: OpenGLInterface glAutoNormal.
		aWindow glEnable: OpenGLInterface glNormalize.
		aWindow 
		    glMapGrid2f: 20
		    u1: 0.0
		    u2: 1.0
		    nv: 20
		    v1: 0.0
		    v2: 1.0.
                "Init window color and shading model"
                aWindow glClearColor: Color black.
                aWindow glShadeModel: OpenGLInterface glSmooth.
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
		    callback: Glut displayFuncEvent
		    to: [self display].
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
	aWindow glColor: Color white.
	aWindow glPushMatrix.
	aWindow 
	    glRotatef: 85.0
	    x: 1.0
	    y: 1.0
	    z: 1.0.
	aWindow glEvalMesh2: OpenGLInterface glFill
            i1: 0
            i2: 20
            j1: 0
            j2: 20.
	"(0 to: 8) do: 
		[:j | 
		aWindow glBegin: OpenGLInterface glLineStrip.
		(0 to: 30) do: [:i | aWindow glEvalCoord2f: i / 30.0 y: j / 8.0].
		aWindow glEnd.
		aWindow glBegin: OpenGLInterface glLineStrip.
		(0 to: 30) do: [:i | aWindow glEvalCoord2f: j / 8.0 y: i / 30.0].
		aWindow glEnd]."
	aWindow glPopMatrix.
	aWindow glFlush
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Point x: 0 y: 0) extend: (Point x: w y: h).
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
	aWindow glLoadIdentity
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

