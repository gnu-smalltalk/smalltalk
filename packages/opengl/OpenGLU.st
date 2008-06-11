"======================================================================
|
|   OpenGL GLU Method Definitions
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



OpenGLInterface extend [
    gluCheckExtension: ext in: extList [
	<category: 'GLU'>
	<cCall: 'gluCheckExtension' returning: #boolean args: #( #string #string )>
    ]

    gluLookAt: anEye center: aCenter up: aDirection [
	<category: 'GLU'>
	<cCall: 'gluLookAtv' returning: #int args: #( #smalltalk #smalltalk #smalltalk )>

    ]

    gluLookAt: anEyeX y: anEyeY z: anEyeZ center: aCenterX y: aCenterY z: aCenterZ up: aDirectionX y: aDirectionY z: aDirectionZ [
	<category: 'GLU'>
	<cCall: 'gluLookAt' returning: #void args: #( #double #double #double #double #double #double #double #double #double )>
	
    ]

    gluOrtho2D: left right: right bottom: bottom top: top [
	<category: 'GLU'>
	<cCall: 'gluOrtho2D' returning: #void args: #( #double #double #double #double )>
	
    ]

    gluPerspective: fovy aspect: aspect near: zNear far: zFar [
	<category: 'GLU'>
	<cCall: 'gluPerspective' returning: #void args: #( #double #double #double #double)>
	
    ]

    gluCylinder: base top: top height: height slices: slices stacks: stacks [

	<category: 'GLU'>
        self
	    gluCylinder: OpenGLInterface gluFill
	    normals: OpenGLInterface gluSmooth
	    orient: OpenGLInterface gluOutside
	    texture: true
	    base: base top: top height: height slices: slices stacks: stacks
    ]

    gluDisk: outer slices: slices stacks: stacks [

	<category: 'GLU'>
        self
	    gluDisk: OpenGLInterface gluFill
	    normals: OpenGLInterface gluSmooth
	    orient: OpenGLInterface gluOutside
	    texture: true
	    inner: 0.0 outer: outer slices: slices stacks: stacks
    ]

    gluDisk: inner outer: outer slices: slices stacks: stacks [

	<category: 'GLU'>
        self
	    gluDisk: OpenGLInterface gluFill
	    normals: OpenGLInterface gluSmooth
	    orient: OpenGLInterface gluOutside
	    texture: true
	    inner: inner outer: outer slices: slices stacks: stacks
    ]

    gluPartialDisk: outer slices: slices stacks: stacks
	start: start sweep: sweep [

	<category: 'GLU'>
	self
	    gluPartialDisk: OpenGLInterface gluFill
	    normals: OpenGLInterface gluSmooth
	    orient: OpenGLInterface gluOutside
	    texture: true
	    inner: 0.0 outer: outer slices: slices stacks: stacks
	    start: start sweep: sweep
    ]

    gluPartialDisk: inner outer: outer slices: slices stacks: stacks
	start: start sweep: sweep [

	<category: 'GLU'>
	self
	    gluPartialDisk: OpenGLInterface gluFill
	    normals: OpenGLInterface gluSmooth
	    orient: OpenGLInterface gluOutside
	    texture: true
	    inner: inner outer: outer slices: slices stacks: stacks
	    start: start sweep: sweep
    ]

    gluSphere: radius slices: slices stacks: stacks [

	<category: 'GLU'>
	self
	    gluSphere: OpenGLInterface gluFill
	    normals: OpenGLInterface gluSmooth
	    orient: OpenGLInterface gluOutside
	    texture: true
	    radius: radius slices: slices stacks: stacks
    ]

    gluCylinder: draw normals: normals orient: orient texture: texture
	base: base top: top height: height slices: slices stacks: stacks [

	<category: 'GLU'>
	<cCall: 'gluCylinder' returning: #void args: #( #int #int #int #boolean #double #double #double #int #int)>
	
    ]

    gluDisk: draw normals: normals orient: orient texture: texture
	inner: inner outer: outer slices: slices stacks: stacks [

	<category: 'GLU'>
	<cCall: 'gluDisk' returning: #void args: #( #int #int #int #boolean #double #double #int #int)>
	
    ]

    gluPartialDisk: draw normals: normals orient: orient texture: texture
	inner: inner outer: outer slices: slices stacks: stacks
	start: start sweep: sweep [

	<category: 'GLU'>
	<cCall: 'gluPartialDisk' returning: #void args: #( #int #int #int #boolean #double #double #int #int #double #double)>
	
    ]

    gluSphere: draw normals: normals orient: orient texture: texture
	radius: radius slices: slices stacks: stacks [

	<category: 'GLU'>
	<cCall: 'gluSphere' returning: #void args: #( #int #int #int #boolean #double #int #int)>
	
    ]

    gluUnProject: x y: y z: z modelview: mvMatrix projection: projMatrix viewport: aViewport [
	<category: 'GLU'>
	<cCall: 'gluUnProject' returning: #smalltalk args: #( #double #double #double #smalltalk #smalltalk #smalltalk )>
	
    ]

    gluUnProject: aVertex modelview: mvMatrix projection: projMatrix viewport: aViewport [
	<category: 'GLU'>
	self 
	    gluUnProject: aVertex x
	    y: aVertex y
	    z: aVertex z
	    modelview: mvMatrix
	    projection: projMatrix
	    viewport: aViewport
    ]

    unProject: x y: y z: z modelview: mvMatrix projection: projMatrix viewport: aViewport [
	<category: 'GLU'>
	| anArray |
	anArray := self 
		    gluUnProject: x asFloat
		    y: y asFloat
		    z: z asFloat
		    modelview: mvMatrix
		    projection: projMatrix
		    viewport: aViewport.
	^Vertex fromArray: anArray
    ]

]

