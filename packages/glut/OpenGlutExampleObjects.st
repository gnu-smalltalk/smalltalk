"======================================================================
|
|   Glut Method Definitions for quadrics and other example 3D objects
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
    glutWireCube: aScale [
	<category: 'GLUT'>
	<cCall: 'glutWireCube' returning: #void args: #( #double )>
	
    ]

    glutSolidCube: aScale [
	<category: 'GLUT'>
	<cCall: 'glutSolidCube' returning: #void args: #( #double )>
	
    ]

    glutWireSphere: radius slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutWireSphere' returning: #void args: #( #double #int #int )>
	
    ]

    glutSolidSphere: radius slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutSolidSphere' returning: #void args: #( #double #int #int )>
	
    ]

    glutWireCone: base height: height slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutWireCone' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutSolidCone: base height: height slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutSolidCone' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutWireTorus: innerRadius outerRadius: outerRadius sides: sides stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutWireCone' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutSolidTorus: innerRadius outerRadius: outerRadius sides: sides stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutSolidTorus' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutWireDodecahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireDodecahedron' returning: #void args: #( )>
	
    ]

    glutSolidDodecahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidDodecahedron' returning: #void args: #( )>
	
    ]

    glutWireOctahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireOctahedron' returning: #void args: #( )>
	
    ]

    glutSolidOctahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidOctahedron' returning: #void args: #( )>
	
    ]

    glutWireTetrahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireTetrahedron' returning: #void args: #( )>
	
    ]

    glutSolidTetrahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidTetrahedron' returning: #void args: #( )>
	
    ]

    glutWireIcosahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireIcosahedron' returning: #void args: #( )>
	
    ]

    glutSolidIcosahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidIcosahedron' returning: #void args: #( )>
	
    ]

    glutWireTeapot: aScale [
	<category: 'GLUT'>
	<cCall: 'glutWireTeapot' returning: #void args: #( #double )>
	
    ]

    glutSolidTeapot: aScale [
	<category: 'GLUT'>
	<cCall: 'glutSolidTeapot' returning: #void args: #( #double )>
	
    ]
]
