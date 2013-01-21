"=====================================================================
|
|    Point Class Definitions
|
|
 ====================================================================="

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2006
| Free Software Foundation, Inc.
| Written by Doug McCallum.
| Additions by Steve Byrne and Paolo Bonzini
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



Number extend [

    @ y [
	"Answer a new point whose x is the receiver and whose y is y"

	<category: 'point creation'>
	^Point x: self y: y
    ]

    asPoint [
	"Answer a new point, self @ self"

	<category: 'point creation'>
	^Point x: self y: self
    ]

]

