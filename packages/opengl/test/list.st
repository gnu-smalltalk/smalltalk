"======================================================================
|
|   OpenGL display list example
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

Object subclass: List [
    | aWindow windowNumber listName |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	<category: 'init'>
	aWindow := Glut new.
	aWindow glutInit: 'une surface smalltalkienne'.
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutSingle) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 650 y: 50).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Call lists'.
	listName := aWindow glGenLists: 1.
	aWindow glNewList: listName mode: OpenGLInterface glCompile.
	aWindow glColor: Color red.
	aWindow glBegin: OpenGLInterface glTriangles.
	aWindow glVertex: (Vertex x: 0.0 y: 0.0).
	aWindow glVertex: (Vertex x: 1.0 y: 0.0).
	aWindow glVertex: (Vertex x: 0.0 y: 1.0).
	aWindow glEnd.
	aWindow glTranslate: (Vertex 
		    x: 1.5
		    y: 0.0
		    z: 0.0).
	aWindow glEndList.
	aWindow glShadeModel: OpenGLInterface glFlat.
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
		    gluOrtho2D: 0.0
		    right: 2.0
		    bottom: -0.5 * h / w
		    top: 1.5 * h / w]
	    ifFalse: 
		[aWindow 
		    gluOrtho2D: 0.0
		    right: 2.0 * w / h
		    bottom: -0.5
		    top: 1.5].
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity
    ]

    drawLine [
	<category: 'init'>
	aWindow glBegin: OpenGLInterface glLines.
	aWindow glVertex: (Vertex x: 0.0 y: 0.5).
	aWindow glVertex: (Vertex x: 15.0 y: 0.5).
	aWindow glEnd
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'init'>
	aWindow glClear: OpenGLInterface glColorBufferBit.
	aWindow glColor: Color green.
	(1 to: 10) do: [:i | aWindow glCallList: listName].
	self drawLine.
	aWindow glFlush
    ]
]

]



Namespace current: OpenGL [
    List new init; mainIteration.
    Processor activeProcess suspend

]

