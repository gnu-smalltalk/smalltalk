"======================================================================
|
|   OpenGL Tesselator object Definitions
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


CObject subclass: Tesselator [
    | callbacks tessCoord tessData |
    
    <category: 'OpenGL'>
    <comment: nil>

    Tesselator class >> gluNewTess [
	<category: 'private - C interface'>
	<cCall: 'gluNewTess' returning: #{Tesselator} args: #()>
	
    ]

    Tesselator class >> new [
	<category: 'initialize'>
	^self gluNewTess
	    addToBeFinalized;
	    connect: OpenGLInterface gluTessCombine;
	    yourself
    ]

    free [
	<category: 'freeing'>
	self removeToBeFinalized.
	tessCoord size timesRepeat: [ tessCoord removeFirst free ].
	tessData := tessCoord := nil.
	self gluDeleteTess.
	self address: 0
    ]

    gluDeleteTess [
	<category: 'private - C interface'>
	<cCall: 'gluDeleteTess' returning: #void args: #(#self)>
	
    ]

    gluTessProperty: aProp value: avalue [
	<category: 'C interface'>
	<cCall: 'gluTessProperty' returning: #void args: #(#self #int #float)>
	
    ]

    gluTessBeginContour [
	<category: 'C interface'>
	<cCall: 'gluTessBeginContour' returning: #void args: #(#self)>
	
    ]

    gluTessEndContour [
	<category: 'C interface'>
	<cCall: 'gluTessEndContour' returning: #void args: #(#self)>
	
    ]

    gluTessBeginPolygon [
	<category: 'C interface'>
	<cCall: 'gluTessBeginPolygon' returning: #void args: #(#self #selfSmalltalk)>
	
    ]

    gluTessEndPolygon [
	<category: 'C interface'>
	tessCoord size timesRepeat: [ tessCoord removeFirst free ].
	self gluTessEndPolygon1.
    ]

    gluTessEndPolygon1 [
	<category: 'C interface'>
	<cCall: 'gluTessEndPolygon' returning: #void args: #(#self)>
	
    ]

    combine: coords data: d weights: w [
	| result |
	result :=
	    ((d at: 1) * (w at: 1)) + ((d at: 2) * (w at: 2))
	        + ((d at: 3) * (w at: 3)) + ((d at: 4) * (w at: 4)).

	result
	    x: (coords at: 1);
	    y: (coords at: 2);
	    z: (coords at: 3).

	^tessData add: result
    ]

    gluTessVertex: data [
	<category: 'interface'>
	| coords |
	tessCoord isNil ifTrue: [
	    tessData := OrderedCollection new.
	    tessCoord := OrderedCollection new ].
	coords := (CDoubleType arrayType: 3) new.
	coords
	    at: 0 put: data x;
	    at: 1 put: data y;
	    at: 2 put: data z.

	tessCoord add: coords.
	tessData add: data.
	self gluTessVertex: coords data: data
    ]

    gluTessVertex: x y: y [
	<category: 'interface'>
	self gluTessVertex: (Vertex x: x y: y)
    ]

    gluTessVertex: x y: y z: z [
	<category: 'interface'>
	self gluTessVertex: (Vertex x: x y: y z: z)
    ]

    gluTessVertex: coords data: data [
	<category: 'private - C interface'>
	<cCall: 'gluTessVertex' returning: #void args: #(#self #cObject #smalltalk)>
	
    ]

    gluTessNormal: vertex [
	<category: 'C interface'>
	self gluTessNormal: vertex x y: vertex y z: vertex z
	
    ]

    gluTessNormal: x y: y z: z [
	<category: 'C interface'>
	<cCall: 'gluTessNormal' returning: #void args: #(#self #double #double #double)>
	
    ]

    callback: aCallback to: aBlock [
	<category: 'internal - callback definition'>
	"Associate a callback to a block"
	callbacks ifNil: [callbacks := Dictionary new].
	callbacks at: aCallback put: aBlock.
	self connect: aCallback
    ]

    getCallback: aCallback  [
	<category: 'internal - C Primitive - callback definition'>
	"Used to retreive the callback block associated"
	^callbacks at: aCallback
    ]

    connect: aCallback [
	<category: 'internal - C Primitive - Callback connect primitive'>
	<cCall: 'gluTessConnectSignal'
		returning: #void
		args: #( #self #int )>
    ]

]
