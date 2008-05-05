"======================================================================
|
|   CairoSdlSurface class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones
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


CairoSurface subclass: CairoSdlSurface [
    <category: 'LibSDL-Cairo'>
    <comment: 'I am a Cairo surface that can be used to write on
an SdlDisplay.  Do not forget to lock the display while using
the surface.'>

    | display |

    CairoSdlSurface class >> on: aDisplay [
	<category: 'instance creation'>
	"Create a surface on the given SdlDisplay."
	^self new display: aDisplay
    ]

    display [
	"Return the SdlDisplay attached to this surface."
	<category: 'accessing'>
	^display
    ]

    display: aDisplay [
	<category: 'private-initialization'>
	self finalize.
	display := aDisplay.
	display addDependent: self.
    ]

    extent [
	^display extent
    ]

    buildSurface [
	<category: 'private'>
	| s |
	s := display sdlSurface.
	^ Cairo imageSurfaceCreateForData: s pixels value
		format: 1
		width: s w value
		height: s h value
		stride: s pitch value.
    ]

    finalize [
	<category: 'private'>
	super finalize.
	display ifNil: [ ^self ].
	display removeDependent: self.
	display := nil.
    ]

    withContextDo: aBlock [
	<category: 'accessing'>
	display critical: [ super withContextDo: aBlock ].
	display flip
    ]
].

