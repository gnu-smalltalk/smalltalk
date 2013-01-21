"========================================================================
|
|   Rectangle Class
|
|
 ========================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2008
| Free Software Foundation, Inc.
| Written by Doug McCallum.
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

    asRectangle [
	"Answer an empty rectangle whose origin is (self asPoint)"

	<category: 'converting'>
	^Rectangle 
	    left: self
	    top: self
	    right: self
	    bottom: self
    ]

]



Point extend [

    asRectangle [
	"Answer an empty rectangle whose origin is self"

	<category: 'converting'>
	^Rectangle origin: self corner: self copy
    ]

    corner: aPoint [
	"Answer a Rectangle whose origin is the receiver and whose corner
	 is aPoint"

	<category: 'converting'>
	^Rectangle origin: self corner: aPoint
    ]

    extent: aPoint [
	"Answer a Rectangle whose origin is the receiver and whose extent
	 is aPoint"

	<category: 'converting'>
	^Rectangle origin: self extent: aPoint
    ]

]

