"======================================================================
|
|   Sphere and lighting example using OpenGL
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
    | aWindow windowNumber axeX axeY axeZ saveX |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	"Define the position of the eye"

	<category: 'test'>
	axeX := false.
	axeY := false.
	axeZ := false.
	"Create the window and initialize callbacks"
	aWindow isNil 
	    ifTrue: 
		[aWindow := Glut new.
		aWindow glutInit: 'une sphere smalltalkienne'.
		aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
			    bitOr: Glut glutDepth).
		aWindow glutInitWindowSize: (Vertex x: 500 y: 500).
		aWindow glutInitWindowPosition: (Vertex x: 100 y: 100).
		windowNumber := aWindow glutCreateWindow: 'Une sphere...'.

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
	aWindow 
	    gluSphere: 1.0
	    slices: 50
	    stacks: 16.
	aWindow glutSwapBuffers
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	w <= h 
	    ifTrue: 
		[aWindow 
		    glOrtho: -1.5
		    right: 1.5
		    bottom: -1.5 * h / w
		    top: 1.5 * h / w
		    near: -10.0
		    far: 10.0]
	    ifFalse: 
		[aWindow 
		    glOrtho: -1.5 * w / h
		    right: 1.5 * w / h
		    bottom: -1.5
		    top: 1.5
		    near: -10.0
		    far: 10.0].
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

