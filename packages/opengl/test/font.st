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


"  font.st "
"  This program is a modification of the earlier font.c "
"  program. "
"  Draws some text in a bitmapped font.  Uses glBitmap "
"  and other pixel routines.  Also demonstrates use of "
"  display lists. "



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: Font [
    | aWindow windowNumber fontOffset |
    
    <category: 'OpenGL'>
    <comment: nil>

	fontOffset [
	<category: 'accessing'>
		^ fontOffset
	]

	fontOffset: anInt [
	<category: 'accessing'>
		fontOffset := anInt.
	]

	makeRasterFont [
	| space letters |
	"Initializes the fonts ."
	<category: 'test'>

	space := #(0 0 0 0 0 0 0 0 0 0 0 0 0).
	letters := #(
		#[16r00 16r00 16rC3 16rC3 16rC3 16rC3 16rFF 16rC3 16rC3 16rC3 16r66 16r3C 16r18]
		#[16r00 16r00 16rFE 16rC7 16rC3 16rC3 16rC7 16rFE 16rC7 16rC3 16rC3 16rC7 16rFE]
		#[16r00 16r00 16r7E 16rE7 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rE7 16r7E]
		#[16r00 16r00 16rFC 16rCE 16rC7 16rC3 16rC3 16rC3 16rC3 16rC3 16rC7 16rCE 16rFC]
		#[16r00 16r00 16rFF 16rC0 16rC0 16rC0 16rC0 16rFC 16rC0 16rC0 16rC0 16rC0 16rFF]
		#[16r00 16r00 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rFC 16rC0 16rC0 16rC0 16rFF]
		#[16r00 16r00 16r7E 16rE7 16rC3 16rC3 16rCF 16rC0 16rC0 16rC0 16rC0 16rE7 16r7E]
		#[16r00 16r00 16rC3 16rC3 16rC3 16rC3 16rC3 16rFF 16rC3 16rC3 16rC3 16rC3 16rC3]
		#[16r00 16r00 16r7E 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16r7E]
		#[16r00 16r00 16r7C 16rEE 16rC6 16r06 16r06 16r06 16r06 16r06 16r06 16r06 16r06]
		#[16r00 16r00 16rC3 16rC6 16rCC 16rD8 16rF0 16rE0 16rF0 16rD8 16rCC 16rC6 16rC3]
		#[16r00 16r00 16rFF 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0 16rC0]
		#[16r00 16r00 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3 16rDB 16rFF 16rFF 16rE7 16rC3]
		#[16r00 16r00 16rC7 16rC7 16rCF 16rCF 16rDF 16rDB 16rFB 16rF3 16rF3 16rE3 16rE3]
		#[16r00 16r00 16r7E 16rE7 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3 16rE7 16r7E]
		#[16r00 16r00 16rC0 16rC0 16rC0 16rC0 16rC0 16rFE 16rC7 16rC3 16rC3 16rC7 16rFE]
		#[16r00 16r00 16r3F 16r6E 16rDF 16rDB 16rC3 16rC3 16rC3 16rC3 16rC3 16r66 16r3C]
		#[16r00 16r00 16rC3 16rC6 16rCC 16rD8 16rF0 16rFE 16rC7 16rC3 16rC3 16rC7 16rFE]
		#[16r00 16r00 16r7E 16rE7 16r03 16r03 16r07 16r7E 16rE0 16rC0 16rC0 16rE7 16r7E]
		#[16r00 16r00 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16r18 16rFF]
		#[16r00 16r00 16r7E 16rE7 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3]
		#[16r00 16r00 16r18 16r3C 16r3C 16r66 16r66 16rC3 16rC3 16rC3 16rC3 16rC3 16rC3]
		#[16r00 16r00 16rC3 16rE7 16rFF 16rFF 16rDB 16rDB 16rC3 16rC3 16rC3 16rC3 16rC3]
		#[16r00 16r00 16rC3 16r66 16r66 16r3C 16r3C 16r18 16r3C 16r3C 16r66 16r66 16rC3]
		#[16r00 16r00 16r18 16r18 16r18 16r18 16r18 16r18 16r3C 16r3C 16r66 16r66 16rC3]
		#[16r00 16r00 16rFF 16rC0 16rC0 16r60 16r30 16r18 16r0C 16r06 16r03 16r03 16rFF]
	).	 

		aWindow glPixelStorei: OpenGLInterface glUnpackAlignment value: 1.
		self fontOffset: (aWindow glGenLists: 128).

		letters inject: (self fontOffset + $A asInteger) into: [:listNumber :aLetter | 

			aWindow glNewList: listNumber mode: OpenGLInterface glCompile.
			aWindow glBitmap: 8 height: 13 x: 0.0  y: 2.0 moveX: 10.0 moveY: 0.0 pixels: aLetter .
			aWindow glEndList.
			listNumber + 1
			].
		aWindow glNewList: (self fontOffset + $  asInteger) mode: OpenGLInterface glCompile.
		aWindow glBitmap: 8 height: 13 x: 0.0  y: 2.0 moveX: 10.0 moveY: 0.0 pixels: space.
		aWindow glEndList.
	]

    init [
	"Initialize material property and depth buffer."

	<category: 'test'>

	aWindow := Glut new.
	aWindow glutInit: 'font'.
	aWindow glutInitDisplayMode: (Glut glutRgb bitOr: Glut glutSingle).
	aWindow glutInitWindowSize: (Point x: 300 y: 100).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Font'.
	
	"Init window color and shading model"
	aWindow glShadeModel: OpenGLInterface glFlat.

	"Initialize font and build display lists"
	self makeRasterFont.

	aWindow 
	    callback: Glut displayFuncEvent
	    to: [self display].
	aWindow 
	    callback: Glut reshapeFuncEvent
	    to: [:w :h | self reshape: w height: h].


    ]

    mainIteration [
	aWindow mainIteration
    ]

	printString: aString [
	<category: 'test'>

	aWindow glPushAttrib: OpenGLInterface glListBit.
	aWindow glListBase: self fontOffset.
	aWindow glCallLists: aString.
	aWindow glPopAttrib.
	]

    display [
	<category: 'test'>
	aWindow glClear: OpenGLInterface glColorBufferBit.
	aWindow glColor: Color white.

	aWindow glRasterPos2i: 20 y: 60.
	self printString: 'THE QUICK BROWN FOX JUMPS'.
	aWindow glRasterPos2i: 20 y: 40.
	self printString: 'OVER A LAZY DOG'.
	aWindow glFlush.
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Point x: 0 y: 0) extend: (Point x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	aWindow 
		    glOrtho: 0.0
		    right: 0.0 + w
		    bottom: 0.0
		    top: 0.0 + h
		    near: -1.0
		    far: 1.0.
	aWindow glMatrixMode: OpenGLInterface glModelview.
    ]

]

]



Namespace current: OpenGL [
    Font new init; mainIteration.
    Processor activeProcess suspend

]

