"======================================================================
|
|   OpenGL Nurbs object Definitions
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


CObject subclass: Nurbs [
    | callbacks |
    
    <category: 'OpenGL'>
    <comment: nil>

    Nurbs class >> gluNewNurbsRenderer [
	<category: 'private - C interface'>
	<cCall: 'gluNewNurbsRenderer' returning: #{Nurbs} args: #()>
	
    ]

    Nurbs class >> new [
	<category: 'initialize'>
	^self gluNewNurbsRenderer
	    addToBeFinalized;
	    yourself
    ]

    free [
	<category: 'freeing'>
	self removeToBeFinalized.
	self gluDeleteNurbsRenderer.
	self address: 0
    ]

    gluDeleteNurbsRenderer [
	<category: 'private - C interface'>
	<cCall: 'gluDeleteNurbsRenderer' returning: #void args: #(#self)>
	
    ]

    gluNurbsProperty: aProp value: avalue [
	<category: 'private - C interface'>
	<cCall: 'gluNurbsProperty' returning: #void args: #(#self #int #float)>
	
    ]

    gluNurbsCurve: sKnotsCount knots: sKnots stride: stride control: controlPoints order: aSOrder type: aType [
	<category: 'private - C interface'>
	<cCall: 'gluNurbsCurve' returning: #void args: #(#self #int #smalltalk #int #smalltalk #int #int)>
	
    ]

    gluNurbsSurface: asKnotsCount sKnots: asKnots tKnotCounts: atkKnotCount tKnots: atKnots sStride: astride tStride: tstride control: controlPoints sOrder: aSOrder tOrder: aTOrder type: aType [
	<category: 'private - C interface'>
	<cCall: 'gluNurbsSurface' returning: #void args: #(#self #int #smalltalk #int #smalltalk #int #int #smalltalk  #int #int #int)>
	
    ]

    gluPwlCurve: count edge: someDatas stride: aStride type: aType [
	<category: 'private - C interface'>
	<cCall: 'gluPwlCurve' returning: #void args: #(#self #int #smalltalk #int #int)>
    ]

    gluBeginSurface [
	<category: 'C interface'>
	<cCall: 'gluBeginSurface' returning: #void args: #(#self)>
	
    ]

    gluEndSurface [
	<category: 'C interface'>
	<cCall: 'gluEndSurface' returning: #void args: #(#self)>
	
    ]

    gluBeginTrim [
	<category: 'C interface'>
	<cCall: 'gluBeginTrim' returning: #void args: #(#self)>
	
    ]

    gluEndTrim [
	<category: 'C interface'>
	<cCall: 'gluEndTrim' returning: #void args: #(#self)>
	
    ]

    gluBeginCurve [
	<category: 'C interface'>
	<cCall: 'gluBeginCurve' returning: #void args: #(#self)>
	
    ]

    gluEndCurve [
	<category: 'C interface'>
	<cCall: 'gluEndCurve' returning: #void args: #(#self)>
	
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
	<cCall: 'gluNurbsConnectSignal'
		returning: #void
		args: #( #selfSmalltalk #int )>
    ]

]
