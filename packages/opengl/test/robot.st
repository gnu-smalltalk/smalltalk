"======================================================================
|
|   OpenGL hierarchical model example
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

Object subclass: Robot [
    | aWindow windowNumber shoulder elbow |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	<category: 'initializing'>
	shoulder := 0.0.
	elbow := 0.0.
	aWindow := Glut new.
	aWindow glutInit: 'une surface smalltalkienne'.
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 500 y: 500).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Une surface nurbs'.

	"Init window color and shading model"
	aWindow glClearColor: Color black.
	aWindow glShadeModel: OpenGLInterface glFlat.
	aWindow 
	    callback: Glut displayFuncEvent
	    to: [self display].
	aWindow 
	    callback: Glut keyboardFuncEvent
	    to: [:k :x :y | self keyboard: k x: x y: y].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [:w :h | self reshape: w height: h ]
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'initializing'>
	aWindow glClear: OpenGLInterface glColorBufferBit.
	aWindow glPushMatrix.
	aWindow 
	    glTranslatef: -1.0
	    y: 0.0
	    z: 0.0.
	aWindow glRotate: shoulder
	    direction: (Vertex 
		    x: 0.0
		    y: 0.0
		    z: 1.0).
	aWindow 
	    glTranslatef: 1.0
	    y: 0.0
	    z: 0.0.
	aWindow glPushMatrix.
	aWindow 
	    glScalef: 2.0
	    y: 0.4
	    z: 1.0.
	aWindow glutWireCube: 1.0.
	aWindow glPopMatrix.
	aWindow 
	    glTranslatef: 1.0
	    y: 0.0
	    z: 0.0.
	aWindow glRotate: elbow
	    direction: (Vertex 
		    x: 0.0
		    y: 0.0
		    z: 1.0).
	aWindow 
	    glTranslatef: 1.0
	    y: 0.0
	    z: 0.0.
	aWindow glPushMatrix.
	aWindow 
	    glScalef: 2.0
	    y: 0.4
	    z: 1.0.
	aWindow glutWireCube: 1.0.
	aWindow glPopMatrix.
	aWindow glPopMatrix.
	aWindow glutSwapBuffers
    ]

    reshape: w height: h [
	<category: 'initializing'>
	aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	aWindow 
	    gluPerspective: 65.0
	    aspect: 1.0 * w / h
	    near: 1.0
	    far: 20.0.
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity.
	aWindow 
	    glTranslatef: 0.0
	    y: 0.0
	    z: -5.0
    ]

    keyboard: aKey x: aX y: aY [
	<category: 'initializing'>
	aKey = $s 
	    ifTrue: 
		[shoulder := (shoulder + 5) \\ 360.
		aWindow glutPostRedisplay].
	aKey = $S 
	    ifTrue: 
		[shoulder := (shoulder - 5) \\ 360.
		aWindow glutPostRedisplay].
	aKey = $e 
	    ifTrue: 
		[elbow := (elbow + 5) \\ 360.
		aWindow glutPostRedisplay].
	aKey = $E 
	    ifTrue: 
		[elbow := (elbow - 5) \\ 360.
		aWindow glutPostRedisplay]
    ]
]

]



Namespace current: OpenGL [
    Robot new init; mainIteration.
    Processor activeProcess suspend

]

