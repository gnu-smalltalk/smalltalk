"======================================================================
|
|   OpenGL gluTess Example
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

Object subclass: ColoredVertex [
    | color vertex |

    ColoredVertex class >> color: c vertex: v [
	^self new color: c; vertex: v; yourself
    ]

    + aColoredVertex [
	^self class
	    color: color + aColoredVertex color
	    vertex: vertex + aColoredVertex vertex
    ]

    * coeff [
	^self class color: color * coeff vertex: vertex * coeff
    ]

    color [ ^color ]
    color: aColor [ color := aColor ]
    vertex [ ^vertex ]
    vertex: aVertex [ vertex := aVertex ]

    x [ ^vertex x ]
    y [ ^vertex y ]
    z [ ^vertex z ]
    x: x [ vertex x: x ]
    y: y [ vertex y: y ]
    z: z [ vertex z: z ]
    w: w [ vertex w: w ]
]

Object subclass: OpenGLTest [
    | aWindow windowNumber tess1 tess2 tess3 |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	"Create the window and initialize callbacks"

	<category: 'test'>
	"An array to store the image"
	aWindow := Glut new.
	aWindow glutInit: 'une surface smalltalkienne'.
	aWindow glutInitDisplayMode: Glut glutRgb.
	aWindow glutInitWindowSize: (Point x: 300 y: 200).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Tesselation'.

	"Init window color."
	aWindow glClearColor: Color black.
	aWindow 
	    callback: Glut displayFuncEvent
	    to: [ self display ].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [ :w :h | self reshape: w height: h ]
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'test'>
	| i j |
	aWindow glClear: OpenGLInterface glColorBufferBit.
	self displayArrow: -10@0.
	self displayHollowRectangle: 0@0.
	self displayStar: 10@0.
	aWindow glPushMatrix.
	aWindow glPopMatrix.
	aWindow glutSwapBuffers
    ]

    colorAt: point [
	| ang dist r g b t |
	ang := point y arcTan: point x.
	dist := 0@0 dist: point.
	r := ang sin / 2 + 0.5.
	g := ang cos / 2 + 0.5.
	b := 1 - r - g max: 0.
	t := (r max: g) max: b.

	r := r / t.
	g := g / t.
	b := b / t.

	^Color
	    red: r + ((1 - r) * (1 - dist))
	    green: g + ((1 - g) * (1 - dist))
	    blue: b + ((1 - b) * (1 - dist))
	   
    ]

    displayStar [
	tess3 isNil ifTrue: [
	    tess3 := Tesselator new.
	    tess3
		gluTessProperty: OpenGLInterface gluTessWindingRule
		value: OpenGLInterface gluTessWindingNonzero.
	    tess3
		callback: OpenGLInterface gluTessVertex
		to: [ :v | aWindow glColor: v color; glVertex: v vertex ] ].

	tess3
	    gluTessBeginPolygon;
	    gluTessBeginContour.

	90 to: 810 by: 144 do: [ :deg || x y |
	    y := deg degreesToRadians sin.
	    x := deg degreesToRadians cos.
	    tess3 gluTessVertex: (ColoredVertex
		color: (self colorAt: x@y)
		vertex: (Vertex x: x y: y) * 4) ].

	tess3
	    gluTessEndContour;
	    gluTessEndPolygon
    ]

    displayHollowRectangle [
	tess2 isNil ifTrue: [ tess2 := Tesselator new ].
	aWindow glColor: Color white.

	tess2
	    gluTessBeginPolygon;
	    gluTessBeginContour;
	    gluTessVertex: -3 y: -2;
	    gluTessVertex: -3 y: 2;
	    gluTessVertex: 3 y: 2;
	    gluTessVertex: 3 y: -2;
	    gluTessEndContour;
	    gluTessBeginContour;
	    gluTessVertex: 2 y: -1;
	    gluTessVertex: 2 y: 1;
	    gluTessVertex: -2 y: 1;
	    gluTessVertex: -2 y: -1;
	    gluTessEndContour;
	    gluTessEndPolygon
    ]

    displayArrow [
	| size |
	tess1 isNil ifTrue: [
	    tess1 := Tesselator new.
	    tess1
		callback: OpenGLInterface gluTessVertex
		to: [ :v | aWindow glColor: (self colorAt: v * 0.25); glVertex: v ] ].
	size := 8 sqrt negated.
	tess1
	    gluTessBeginPolygon;
	    gluTessBeginContour;
	    gluTessVertex: size negated y: size;
	    gluTessVertex: 0 y: 4;
	    gluTessVertex: size y: size;
	    gluTessVertex: 0 y: 0;
	    gluTessEndContour;
	    gluTessEndPolygon
    ]

    displayStar: pos [
	aWindow glPushMatrix.
	aWindow glTranslatef: pos x y: pos y z: 0.
	self displayStar.
	aWindow glPopMatrix
    ]

    displayHollowRectangle: pos [
	aWindow glPushMatrix.
	aWindow glTranslatef: pos x y: pos y z: 0.
	self displayHollowRectangle.
	aWindow glPopMatrix
    ]

    displayArrow: pos [
	aWindow glPushMatrix.
	aWindow glTranslatef: pos x y: pos y z: 0.
	self displayArrow.
	aWindow glPopMatrix
    ]

    reshape: w height: h [
	<category: 'test'>
        aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
        aWindow glMatrixMode: OpenGLInterface glProjection.
        aWindow glLoadIdentity.
        w * 2 / 3 <= h
            ifTrue:
                [aWindow
                    gluOrtho2D: -15.0
                    right: 15.0
                    bottom: -15.0 * h / w
                    top: 15.0 * h / w]
            ifFalse:
                [aWindow
                    gluOrtho2D: -10.0 * w / h
                    right: 10.0 * w / h
                    bottom: -10.0
                    top: 10.0].
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

