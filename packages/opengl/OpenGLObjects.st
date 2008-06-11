"======================================================================
|
|   OpenGL Color and Vertex Classes
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



Object subclass: Color [
    
    <shape: #float>
    <category: 'OpenGL'>
    <comment: 'My instances are color represented as a combinasion of Red, Green, blue and Transparency'>

    Color class >> new [
	<category: 'Creating'>
	^self basicNew: 4
    ]

    Color class >> grey: value [
	<category: 'Creating'>
	^(self new)
	    red: value;
	    green: value;
	    blue: value;
	    alpha: 1.0
	]

    Color class >> red: aRed green: aGreen blue: aBlue [
	<category: 'Creating'>
	^(self new)
	    red: aRed;
	    green: aGreen;
	    blue: aBlue;
	    alpha: 1.0
    ]

    Color class >> red: aRed green: aGreen blue: aBlue alpha: aTransparency [
	<category: 'Creating'>
	^(self new)
	    red: aRed;
	    green: aGreen;
	    blue: aBlue;
	    alpha: aTransparency
    ]

    Color class >> black [
	<category: 'Creating'>
	^(self new)
	    red: 0.0;
	    green: 0.0;
	    blue: 0.0;
	    alpha: 1.0
    ]

    Color class >> white [
	<category: 'Creating'>
	^(self new)
	    red: 1.0;
	    green: 1.0;
	    blue: 1.0;
	    alpha: 1.0
    ]

    Color class >> red [
	<category: 'Creating'>
	^(self new)
	    red: 1.0;
	    green: 0.0;
	    blue: 0.0;
	    alpha: 1.0
    ]

    Color class >> green [
	<category: 'Creating'>
	^(self new)
	    red: 0.0;
	    green: 1.0;
	    blue: 0.0;
	    alpha: 1.0
    ]

    Color class >> blue [
	<category: 'Creating'>
	^(self new)
	    red: 0.0;
	    green: 0.0;
	    blue: 1.0;
	    alpha: 1.0
    ]

    red [
	<category: 'Accessing'>
	^self at: 1
    ]

    red: aFloat [
	<category: 'Accessing'>
	self at: 1 put: aFloat
    ]

    green [
	<category: 'Accessing'>
	^self at: 2
    ]

    green: aFloat [
	<category: 'Accessing'>
	self at: 2 put: aFloat
    ]

    blue [
	<category: 'Accessing'>
	^self at: 3
    ]

    blue: aFloat [
	<category: 'Accessing'>
	self at: 3 put: aFloat
    ]

    alpha [
	<category: 'Accessing'>
	^self at: 4
    ]

    alpha: aFloat [
	<category: 'Accessing'>
	self at: 4 put: aFloat
    ]

    + aColor [
	<category: 'Transforming'>
	^self class
	    red: self red + aColor red
	    green: self green + aColor green
	    blue: self blue + aColor blue
	    alpha: self alpha + aColor alpha
    ]

    * coeff [
	<category: 'Transforming'>
	^self class
	    red: self red * coeff
	    green: self green * coeff
	    blue: self blue * coeff
	    alpha: self alpha * coeff
    ]

    asArray [
	<category: 'Transforming'>
	^self alpha = 1.0
	    ifTrue: [ { self red. self green. self blue } ]
	    ifFalse: [ { self red. self green. self blue. self alpha } ]
    ]

    do: aBlock [
	<category: 'block'>
	1 to: self size do: [:i | aBlock value: (self at: i)]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPut: $(.
	self do: 
		[:aFloat | 
		aFloat printOn: aStream.
		aStream space].
	aStream nextPut: $)
    ]
]



"An object for a Vertex"



Object subclass: Vertex [
    
    <shape: #float>
    <category: 'OpenGL'>
    <comment: 'My instances are vertexes in either a 2D or 3D space. I also have
another axis for matrix works'>

    Vertex class >> fromArray: anArray [
	<category: 'Creating'>
	^(self basicNew: self numElements) initialize: anArray
    ]

    Vertex class >> new [
	<category: 'Creating'>
	| v |
	v := self basicNew: self numElements.
	v basicAt: 4 put: 1.0.
	^v
    ]

    Vertex class >> numElements [
	<category: 'Creating'>
	^4
    ]

    Vertex class >> x: anX y: aY [
	<category: 'Creating'>
	^self new x: anX y: aY
    ]

    Vertex class >> x: anX y: aY z: aZ [
	<category: 'Creating'>
	^self new x: anX y: aY z: aZ
    ]

    Vertex class >> x: anX y: aY z: aZ w: aW [
	<category: 'Creating'>
	^self new x: anX y: aY z: aZ w: aW
    ]

    x [
	<category: 'accessing'>
	^self at: 1
    ]

    y [
	<category: 'accessing'>
	^self at: 2
    ]

    z [
	<category: 'accessing'>
	^self at: 3
    ]

    w [
	<category: 'accessing'>
	^self at: 4
    ]

    x: aFloat [
	<category: 'accessing'>
	self at: 1 put: aFloat.
    ]

    y: aFloat [
	<category: 'accessing'>
	self at: 2 put: aFloat.
    ]

    z: aFloat [
	<category: 'accessing'>
	self at: 3 put: aFloat.
    ]

    w: aFloat [
	<category: 'accessing'>
	self at: 4 put: aFloat.
    ]

    x: anX y: aY [
	<category: 'accessing'>
	self at: 1 put: anX.
	self at: 2 put: aY
    ]

    x: anX y: aY z: aZ [
	<category: 'accessing'>
	self at: 1 put: anX.
	self at: 2 put: aY.
	self at: 3 put: aZ
    ]

    x: anX y: aY z: aZ w: aW [
	<category: 'accessing'>
	self at: 1 put: anX.
	self at: 2 put: aY.
	self at: 3 put: aZ.
	self at: 4 put: aW
    ]

    initialize: anArray [
	<category: 'Loading'>
	| aSize |
	aSize := anArray size.
	aSize > Vertex numElements ifTrue: [aSize := Vertex numElements].
	1 to: aSize do: [:i | self at: i put: (anArray at: i) ]
    ]

    + aVertex [
	<category: 'Transforming'>
	^self class
	    x: (self x / self w) + (aVertex x / aVertex w)
	    y: (self y / self w) + (aVertex y / aVertex w)
	    z: (self z / self w) + (aVertex z / aVertex w)
	    w: 1.0
    ]

    * coeff [
	<category: 'Transforming'>
	^self class
	    x: self x * coeff
	    y: self y * coeff
	    z: self z * coeff
	    w: self w
    ]

    asArray [
	<category: 'Transforming'>
	^self w = 1.0
	    ifFalse: [ { self x. self y. self z. self w } ]
	    ifTrue: 
		[self z = 0.0
		    ifFalse: [ { self x. self y. self z } ]
		    ifTrue: [ { self x. self y } ]]
    ]

    do: aBlock [
	<category: 'block'>
	1 to: self size do: [:i | aBlock value: (self at: i)]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPut: ${.
	self do: 
		[:aFloat | 
		aFloat printOn: aStream.
		aStream space].
	aStream nextPut: $}
    ]
]



" ****** "

" Matrix "

" ****** "



Object subclass: Matrix16f [
    
    <shape: #float>
    <category: 'OpenGL'>
    <comment: 'My instances are general 4x4 matrix for transformation'>

    IdentityMatrix := nil.
    ZeroMatrix := nil.

    Matrix16f class >> identity [
	<category: 'initializing'>
	^self new setIdentity
    ]

    Matrix16f class >> initialize [
	<category: 'initializing'>
	ZeroMatrix := self new.
	IdentityMatrix := self new.
	IdentityMatrix at: 1 put: 1.0.
	IdentityMatrix at: 6 put: 1.0.
	IdentityMatrix at: 11 put: 1.0.
	IdentityMatrix at: 16 put: 1.0
    ]

    Matrix16f class >> new [
	<category: 'initializing'>
	^self basicNew: self numElements
    ]

    Matrix16f class >> numElements [
	<category: 'initializing'>
	^16
    ]

    = aMatrix [
	"Compare two matrix"

	<category: 'comparing'>
	self class = aMatrix class 
	    ifTrue: 
		[(1 to: self size) 
		    do: [:index | (self at: index) = (aMatrix at: index) ifFalse: [^false]].
		^true]
	    ifFalse: [^false]
    ]

    isZero [
	<category: 'testing'>
	^self = ZeroMatrix
    ]

    isIdentity [
	<category: 'testing'>
	^self = IdentityMatrix
    ]

    column1 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 1)
	    y: (self at: 5)
	    z: (self at: 9)
    ]

    column1: aVertex [
	<category: 'accessing'>
	self at: 1 put: aVertex x.
	self at: 5 put: aVertex y.
	self at: 9 put: aVertex z
    ]

    column2 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 2)
	    y: (self at: 6)
	    z: (self at: 10)
    ]

    column2: aVertex [
	<category: 'accessing'>
	self at: 2 put: aVertex x.
	self at: 6 put: aVertex y.
	self at: 10 put: aVertex z
    ]

    column3 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 3)
	    y: (self at: 7)
	    z: (self at: 11)
    ]

    column3: aVertex [
	<category: 'accessing'>
	self at: 3 put: aVertex x.
	self at: 7 put: aVertex y.
	self at: 11 put: aVertex z
    ]

    column4 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 4)
	    y: (self at: 8)
	    z: (self at: 12)
    ]

    column4: aVertex [
	<category: 'accessing'>
	self at: 4 put: aVertex x.
	self at: 8 put: aVertex y.
	self at: 12 put: aVertex z
    ]

    row1 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 1)
	    y: (self at: 2)
	    z: (self at: 3)
    ]

    row1: aVertex [
	<category: 'accessing'>
	self at: 1 put: aVertex x.
	self at: 2 put: aVertex y.
	self at: 3 put: aVertex z
    ]

    row2 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 5)
	    y: (self at: 6)
	    z: (self at: 7)
    ]

    row2: aVertex [
	<category: 'accessing'>
	self at: 5 put: aVertex x.
	self at: 6 put: aVertex y.
	self at: 7 put: aVertex z
    ]

    row3 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 9)
	    y: (self at: 10)
	    z: (self at: 11)
    ]

    row3: aVertex [
	<category: 'accessing'>
	self at: 9 put: aVertex x.
	self at: 10 put: aVertex y.
	self at: 11 put: aVertex z
    ]

    row4 [
	<category: 'accessing'>
	^Vertex 
	    x: (self at: 13)
	    y: (self at: 14)
	    z: (self at: 15)
    ]

    row4: aVertex [
	<category: 'accessing'>
	self at: 13 put: aVertex x.
	self at: 14 put: aVertex y.
	self at: 15 put: aVertex z
    ]

    at: x at: y [
	"accessing element x y"

	<category: 'accessing'>
	^self at: x * 4 + y
    ]

    at: x at: y put: aNumber [
	"accessing element x y"

	<category: 'accessing'>
	^self at: x * 4 + y put: aNumber asFloat
    ]

    a11 [
	"access element 1 1"

	<category: 'accessing'>
	^self at: 1
    ]

    a11: aNumber [
	"set element 1 1"

	<category: 'accessing'>
	self at: 1 put: aNumber
    ]

    a12 [
	"access element 1 2"

	<category: 'accessing'>
	^self at: 2
    ]

    a12: aNumber [
	"set element 1 2"

	<category: 'accessing'>
	self at: 2 put: aNumber
    ]

    a13 [
	"access element 1 3"

	<category: 'accessing'>
	^self at: 3
    ]

    a13: aNumber [
	"set element 1 3"

	<category: 'accessing'>
	self at: 3 put: aNumber
    ]

    a14 [
	"access element 1 4"

	<category: 'accessing'>
	^self at: 4
    ]

    a14: aNumber [
	"set element 1 4"

	<category: 'accessing'>
	self at: 4 put: aNumber
    ]

    a21 [
	"access element 2 1"

	<category: 'accessing'>
	^self at: 5
    ]

    a21: aNumber [
	"set element 2 1"

	<category: 'accessing'>
	self at: 5 put: aNumber
    ]

    a22 [
	"access element 2 2"

	<category: 'accessing'>
	^self at: 6
    ]

    a22: aNumber [
	"set element 2 2"

	<category: 'accessing'>
	self at: 6 put: aNumber
    ]

    a23 [
	"access element 2 3"

	<category: 'accessing'>
	^self at: 7
    ]

    a23: aNumber [
	"set element 2 3"

	<category: 'accessing'>
	self at: 7 put: aNumber
    ]

    a24 [
	"access element 2 4"

	<category: 'accessing'>
	^self at: 8
    ]

    a24: aNumber [
	"set element 2 4"

	<category: 'accessing'>
	self at: 8 put: aNumber
    ]

    a31 [
	"access element 3 1"

	<category: 'accessing'>
	^self at: 9
    ]

    a31: aNumber [
	"set element 3 1"

	<category: 'accessing'>
	self at: 9 put: aNumber
    ]

    a32 [
	"access element 3 2"

	<category: 'accessing'>
	^self at: 10
    ]

    a32: aNumber [
	"set element 3 2"

	<category: 'accessing'>
	self at: 10 put: aNumber
    ]

    a33 [
	"access element 3 3"

	<category: 'accessing'>
	^self at: 11
    ]

    a33: aNumber [
	"set element 3 3"

	<category: 'accessing'>
	self at: 11 put: aNumber
    ]

    a34 [
	"access element 3 4"

	<category: 'accessing'>
	^self at: 12
    ]

    a34: aNumber [
	"set element 3 4"

	<category: 'accessing'>
	self at: 12 put: aNumber
    ]

    a41 [
	"access element 4 1"

	<category: 'accessing'>
	^self at: 13
    ]

    a41: aNumber [
	"set element 4 1"

	<category: 'accessing'>
	self at: 13 put: aNumber
    ]

    a42 [
	"access element 4 2"

	<category: 'accessing'>
	^self at: 14
    ]

    a42: aNumber [
	"set element 4 2"

	<category: 'accessing'>
	self at: 14 put: aNumber
    ]

    a43 [
	"access element 4 3"

	<category: 'accessing'>
	^self at: 15
    ]

    a43: aNumber [
	"set element 4 3"

	<category: 'accessing'>
	self at: 15 put: aNumber
    ]

    a44 [
	"access element 4 4"

	<category: 'accessing'>
	^self at: 16
    ]

    a44: aNumber [
	"set element 4 4"

	<category: 'accessing'>
	self at: 16 put: aNumber
    ]

    clone [
	<category: 'private'>
	| aMatrix |
	aMatrix := self class new.
	(1 to: self size) do: [:i | aMatrix at: i put: (self at: i)].
	^aMatrix
    ]

    + anObject [
	<category: 'arithmetics'>
	^anObject isNumber 
	    ifTrue: [self clone addNumber: anObject asFloat]
	    ifFalse: [self clone addArray: anObject]
    ]

    - anObject [
	<category: 'arithmetics'>
	^anObject isNumber 
	    ifTrue: [self clone subNumber: anObject asFloat]
	    ifFalse: [self clone subArray: anObject]
    ]

    printOn: aStream [
	"Print the receiver on aStream"

	<category: 'dispatching'>
	1 to: 4
	    do: 
		[:r | 
		1 to: 4
		    do: 
			[:c | 
			(self at: (r - 1) * 4 + c) printOn: aStream.
			aStream nextPut: Character space].
		r < 4 ifTrue: [aStream nextPut: Character cr]]
    ]

    productFromMatrix4x4: matrix [
	"Multiply a 4x4 matrix with the receiver."

	<category: 'dispatching'>
	| result |
	result := self class new.
	result 
	    a11: matrix a11 * self a11 + (matrix a12 * self a21) 
		    + (matrix a13 * self a31) + (matrix a14 * self a41).
	result 
	    a12: matrix a11 * self a12 + (matrix a12 * self a22) 
		    + (matrix a13 * self a32) + (matrix a14 * self a42).
	result 
	    a13: matrix a11 * self a13 + (matrix a12 * self a23) 
		    + (matrix a13 * self a33) + (matrix a14 * self a43).
	result 
	    a14: matrix a11 * self a14 + (matrix a12 * self a24) 
		    + (matrix a13 * self a34) + (matrix a14 * self a44).
	result 
	    a21: matrix a21 * self a11 + (matrix a22 * self a21) 
		    + (matrix a23 * self a31) + (matrix a24 * self a41).
	result 
	    a22: matrix a21 * self a12 + (matrix a22 * self a22) 
		    + (matrix a23 * self a32) + (matrix a24 * self a42).
	result 
	    a23: matrix a21 * self a13 + (matrix a22 * self a23) 
		    + (matrix a23 * self a33) + (matrix a24 * self a43).
	result 
	    a24: matrix a21 * self a14 + (matrix a22 * self a24) 
		    + (matrix a23 * self a34) + (matrix a24 * self a44).
	result 
	    a31: matrix a31 * self a11 + (matrix a32 * self a21) 
		    + (matrix a33 * self a31) + (matrix a34 * self a41).
	result 
	    a32: matrix a31 * self a12 + (matrix a32 * self a22) 
		    + (matrix a33 * self a32) + (matrix a34 * self a42).
	result 
	    a33: matrix a31 * self a13 + (matrix a32 * self a23) 
		    + (matrix a33 * self a33) + (matrix a34 * self a43).
	result 
	    a34: matrix a31 * self a14 + (matrix a32 * self a24) 
		    + (matrix a33 * self a34) + (matrix a34 * self a44).
	result 
	    a41: matrix a41 * self a11 + (matrix a42 * self a21) 
		    + (matrix a43 * self a31) + (matrix a44 * self a41).
	result 
	    a42: matrix a41 * self a12 + (matrix a42 * self a22) 
		    + (matrix a43 * self a32) + (matrix a44 * self a42).
	result 
	    a43: matrix a41 * self a13 + (matrix a42 * self a23) 
		    + (matrix a43 * self a33) + (matrix a44 * self a43).
	result 
	    a44: matrix a41 * self a14 + (matrix a42 * self a24) 
		    + (matrix a43 * self a34) + (matrix a44 * self a44).
	^result
    ]

    productFromVector3: aVector3 [
	"Multiply aVector (temporarily converted to 4D) with the receiver"

	<category: 'dispatching'>
	| x y z rx ry rz rw |
	x := aVector3 x.
	y := aVector3 y.
	z := aVector3 z.
	rx := x * self a11 + (y * self a21) + (z * self a31) + self a41.
	ry := x * self a12 + (y * self a22) + (z * self a32) + self a42.
	rz := x * self a13 + (y * self a23) + (z * self a33) + self a43.
	rw := x * self a14 + (y * self a24) + (z * self a34) + self a44.
	^Vertex 
	    x: rx / rw
	    y: ry / rw
	    z: rz / rw
    ]

    productFromVector4: aVector4 [
	"Multiply aVector with the receiver"

	<category: 'dispatching'>
	| x y z w rx ry rz rw |
	x := aVector4 x.
	y := aVector4 y.
	z := aVector4 z.
	w := aVector4 w.
	rx := x * self a11 + (y * self a21) + (z * self a31) + (w * self a41).
	ry := x * self a12 + (y * self a22) + (z * self a32) + (w * self a42).
	rz := x * self a13 + (y * self a23) + (z * self a33) + (w * self a43).
	rw := x * self a14 + (y * self a24) + (z * self a34) + (w * self a44).
	^Vertex 
	    x: rx
	    y: ry
	    z: rz
	    w: rw
    ]

    addNumber: aNumber [
	<category: 'dispatching'>
	(1 to: self size) do: [:i | self at: i put: (self at: i) + aNumber].
	^self
    ]

    addArray: anArray [
	<category: 'dispatching'>
	(1 to: self size) 
	    do: [:i | self at: i put: (self at: i) + (anArray at: i)].
	^self
    ]

    subNumber: aNumber [
	<category: 'dispatching'>
	(1 to: self size) do: [:i | self at: i put: (self at: i) - aNumber].
	^self
    ]

    subArray: anArray [
	<category: 'dispatching'>
	(1 to: self size) 
	    do: [:i | self at: i put: (self at: i) - (anArray at: i)].
	^self
    ]

    composedWithGlobal: aMatrix [
	<category: 'transforming'>
	| result |
	result := self class new.
	self 
	    privateTransformMatrix: aMatrix
	    with: self
	    into: result.
	^result
    ]

    composedWithLocal: aMatrix [
	<category: 'transforming'>
	| result |
	result := self class new.
	self 
	    privateTransformMatrix: self
	    with: aMatrix
	    into: result.
	^result
    ]

    composeWith: m2 [
	"Perform a 4x4 matrix multiplication."

	<category: 'transforming'>
	^self composedWithLocal: m2
    ]

    composeWith: m2 times: nTimes [
	"Perform a 4x4 matrix exponentiation and multiplication."

	<category: 'transforming'>
	| result |
	result := self.
	nTimes negative ifTrue: [self halt].
	nTimes >= 2 
	    ifTrue: 
		[result := result composeWith: (m2 composedWithLocal: m2) times: nTimes // 2].
	nTimes \\ 2 = 1 ifTrue: [result := result composedWithLocal: m2].
	^result
    ]

    inverseTransformation [
	"Return the inverse matrix of the receiver."

	<category: 'transforming'>
	^self clone inplaceHouseHolderInvert
    ]

    localDirToGlobal: aVector [
	"Multiply direction vector with the receiver"

	<category: 'transforming'>
	| x y z rx ry rz |
	x := aVector x.
	y := aVector y.
	z := aVector z.
	rx := x * self a11 + (y * self a12) + (z * self a13).
	ry := x * self a21 + (y * self a22) + (z * self a23).
	rz := x * self a31 + (y * self a32) + (z * self a33).
	^Vertex 
	    x: rx
	    y: ry
	    z: rz
    ]

    localPointToGlobal: aVector [
	"Multiply aVector (temporarily converted to 4D) with the receiver"

	<category: 'transforming'>
	| x y z rx ry rz rw |
	x := aVector x.
	y := aVector y.
	z := aVector z.
	rx := x * self a11 + (y * self a12) + (z * self a13) + self a14.
	ry := x * self a21 + (y * self a22) + (z * self a23) + self a24.
	rz := x * self a31 + (y * self a32) + (z * self a33) + self a34.
	rw := x * self a41 + (y * self a42) + (z * self a43) + self a44.
	^Vertex 
	    x: rx / rw
	    y: ry / rw
	    z: rz / rw
    ]

    orthoNormInverse [
	<category: 'transforming'>
	| m x y z rx ry rz |
	m := self clone.
	"transpose upper 3x3 matrix"
	m
	    a11: self a11;
	    a12: self a21;
	    a13: self a31.
	m
	    a21: self a12;
	    a22: self a22;
	    a23: self a32.
	m
	    a31: self a13;
	    a32: self a23;
	    a33: self a33.
	"Compute inverse translation vector"
	x := self a14.
	y := self a24.
	z := self a34.
	rx := x * m a11 + (y * m a12) + (z * m a13).
	ry := x * m a21 + (y * m a22) + (z * m a23).
	rz := x * m a31 + (y * m a32) + (z * m a33).
	m
	    a14: 0.0 - rx;
	    a24: 0.0 - ry;
	    a34: 0.0 - rz.
	^m
    ]

    quickTransformV3ArrayFrom: srcArray to: dstArray [
	"Transform the 3 element vertices from srcArray to dstArray.
	 ASSUMPTION: a41 = a42 = a43 = 0.0 and a44 = 1.0"

	<category: 'transforming'>
	| a11 a12 a13 a14 a21 a22 a23 a24 a31 a32 a33 a34 x y z index |
	a11 := self a11.
	a12 := self a12.
	a13 := self a13.
	a14 := self a14.
	a21 := self a21.
	a22 := self a22.
	a23 := self a23.
	a24 := self a24.
	a31 := self a31.
	a32 := self a32.
	a33 := self a33.
	a34 := self a34.
	1 to: srcArray size
	    do: 
		[:i | 
		index := (i - 1) * 3.
		x := srcArray at: index + 1.
		y := srcArray at: index + 2.
		z := srcArray at: index + 3.
		dstArray at: index + 1 put: a11 * x + (a12 * y) + (a13 * z) + a14.
		dstArray at: index + 2 put: a21 * x + (a22 * y) + (a23 * z) + a24.
		dstArray at: index + 3 put: a31 * x + (a32 * y) + (a33 * z) + a34].
	^dstArray
    ]

    transposed [
	"Return a transposed copy of the receiver"

	<category: 'transforming'>
	| matrix |
	matrix := self class new.
	matrix
	    a11: self a11;
	    a12: self a21;
	    a13: self a31;
	    a14: self a41;
	    a21: self a12;
	    a22: self a22;
	    a23: self a32;
	    a24: self a42;
	    a31: self a13;
	    a32: self a23;
	    a33: self a33;
	    a34: self a43;
	    a41: self a14;
	    a42: self a24;
	    a43: self a34;
	    a44: self a44.
	^matrix
    ]

    inplaceHouseHolderInvert [
	"Solve the linear equation self * aVector = x by using HouseHolder's transformation.
	 Note: This scheme is numerically better than using gaussian elimination even though it takes
	 somewhat longer"

	<category: 'transforming'>
	| d x sigma beta sum s |
	x := Matrix identity.
	d := Matrix new.
	1 to: 4
	    do: 
		[:j | 
		sigma := 0.0.
		j to: 4 do: [:i | sigma := sigma + (self at: i at: j) squared].
		sigma isZero ifTrue: [^nil].	"matrix is singular"
		(self at: j at: j) < 0.0 
		    ifTrue: [s := sigma sqrt]
		    ifFalse: [s := sigma sqrt negated].
		1 to: 4
		    do: 
			[:r | 
			d 
			    at: j
			    at: r
			    put: s].
		beta := 1.0 / (s * (self at: j at: j) - sigma).
		self 
		    at: j
		    at: j
		    put: (self at: j at: j) - s.

		"update remaining columns"
		j + 1 to: 4
		    do: 
			[:k | 
			sum := 0.0.
			j to: 4 do: [:i | sum := sum + ((self at: i at: j) * (self at: i at: k))].
			sum := sum * beta.
			j to: 4
			    do: 
				[:i | 
				self 
				    at: i
				    at: k
				    put: (self at: i at: k) + ((self at: i at: j) * sum)]].

		"update vector"
		1 to: 4
		    do: 
			[:r | 
			sum := nil.
			j to: 4
			    do: 
				[:i | 
				sum := sum isNil 
					    ifTrue: [(x at: i at: r) * (self at: i at: j)]
					    ifFalse: [sum + ((x at: i at: r) * (self at: i at: j))]].
			sum := sum * beta.
			j to: 4
			    do: 
				[:i | 
				x 
				    at: i
				    at: r
				    put: (x at: i at: r) + (sum * (self at: i at: j))]]].

	"Now calculate result"
	1 to: 4
	    do: 
		[:r | 
		4 to: 1
		    by: -1
		    do: 
			[:i | 
			i + 1 to: 4
			    do: 
				[:j | 
				x 
				    at: i
				    at: r
				    put: (x at: i at: r) - ((x at: j at: r) * (self at: i at: j))].
			x 
			    at: i
			    at: r
			    put: (x at: i at: r) / (d at: i at: r)]].
	self loadFrom: x

	"Return receiver"
    ]

    setBetaSplineBaseBias: beta1 tension: beta2 [
	"Set the receiver to the betaSpline base matrix
	 if beta1=1 and beta2=0 then the bSpline base matrix will be returned"

	"for further information see:
	 Foley, van Dam, Feiner, Hughes
	 'Computer Graphics: Principles and Practice'
	 Addison-Wesley Publishing Company
	 Second Edition, pp. 505"

	<category: 'initialize'>
	| b12 b13 delta |
	b12 := beta1 * beta1.
	b13 := beta1 * b12.
	delta := 1.0 / ((beta2 + (2.0 * b13) + 4.0) * (b12 + beta1) + 2.0).
	self
	    a11: delta * -2.0 * b13;
	    a12: delta * 2.0 * (beta2 + b13 + b12 + beta1);
	    a13: delta * -2.0 * (beta2 + b12 + beta1 + 1.0);
	    a14: delta * 2.0;
	    a21: delta * 6.0 * b13;
	    a22: delta * -3.0 * (beta2 + (2.0 * (b13 + b12)));
	    a23: delta * 3.0 * (beta2 + (2.0 * b12));
	    a24: 0.0;
	    a31: delta * -6.0 * b13;
	    a32: delta * 6.0 * (b13 - beta1);
	    a33: delta * 6.0 * beta1;
	    a34: 0.0;
	    a41: delta * 2.0 * b13;
	    a42: delta * ((beta2 + 4.0) * (b12 + beta1));
	    a43: delta * 2.0;
	    a44: 0.0
    ]

    setBezierBase [
	"Set the receiver to the bezier base matrix"

	"for further information see:
	 Foley, van Dam, Feiner, Hughes
	 'Computer Graphics: Principles and Practice'
	 Addison-Wesley Publishing Company
	 Second Edition, pp. 505"

	<category: 'initialize'>
	self
	    a11: -1.0;
	    a12: 3.0;
	    a13: -3.0;
	    a14: 1.0;
	    a21: 3.0;
	    a22: -6.0;
	    a23: 3.0;
	    a24: 0.0;
	    a31: -3.0;
	    a32: 3.0;
	    a33: 0.0;
	    a34: 0.0;
	    a41: 1.0;
	    a42: 0.0;
	    a43: 0.0;
	    a44: 0.0
    ]

    setBSplineBase [
	"Set the receiver to the BSpline base matrix"

	"for further information see:
	 Foley, van Dam, Feiner, Hughes
	 'Computer Graphics: Principles and Practice'
	 Addison-Wesley Publishing Company
	 Second Edition, pp. 505"

	<category: 'initialize'>
	self
	    a11: -1.0 / 6.0;
	    a12: 3.0 / 6.0;
	    a13: -3.0 / 6.0;
	    a14: 1.0 / 6.0;
	    a21: 3.0 / 6.0;
	    a22: -6.0 / 6.0;
	    a23: 3.0 / 6.0;
	    a24: 0.0 / 6.0;
	    a31: -3.0 / 6.0;
	    a32: 0.0 / 6.0;
	    a33: 3.0 / 6.0;
	    a34: 0.0 / 6.0;
	    a41: 1.0 / 6.0;
	    a42: 4.0 / 6.0;
	    a43: 1.0 / 6.0;
	    a44: 0.0 / 6.0
    ]

    setCardinalBase [
	"Set the receiver to the cardinal spline base matrix - just catmull * 2"

	"for further information see:
	 Foley, van Dam, Feiner, Hughes
	 'Computer Graphics: Principles and Practice'
	 Addison-Wesley Publishing Company
	 Second Edition, pp. 505"

	<category: 'initialize'>
	self
	    a11: -1.0;
	    a12: 3.0;
	    a13: -3.0;
	    a14: 1.0;
	    a21: 2.0;
	    a22: -5.0;
	    a23: 4.0;
	    a24: -1.0;
	    a31: -1.0;
	    a32: 0.0;
	    a33: 1.0;
	    a34: 0.0;
	    a41: 0.0;
	    a42: 2.0;
	    a43: 0.0;
	    a44: 0.0
    ]

    setCatmullBase [
	"Set the receiver to the Catmull-Rom base matrix"

	"for further information see:
	 Foley, van Dam, Feiner, Hughes
	 'Computer Graphics: Principles and Practice'
	 Addison-Wesley Publishing Company
	 Second Edition, pp. 505"

	<category: 'initialize'>
	self
	    a11: -0.5;
	    a12: 1.5;
	    a13: -1.5;
	    a14: 0.5;
	    a21: 1.0;
	    a22: -2.5;
	    a23: 2.0;
	    a24: -0.5;
	    a31: -0.5;
	    a32: 0.0;
	    a33: 0.5;
	    a34: 0.0;
	    a41: 0.0;
	    a42: 1.0;
	    a43: 0.0;
	    a44: 0.0
    ]

    setIdentity [
	"Set the receiver to the identity matrix"

	<category: 'initialize'>
	self loadFrom: IdentityMatrix
    ]

    setPolylineBase [
	"Set the receiver to the polyline base matrix :)"

	<category: 'initialize'>
	self
	    a11: 0.0;
	    a12: 0.0;
	    a13: 0.0;
	    a14: 0.0;
	    a21: 0.0;
	    a22: 0.0;
	    a23: 0.0;
	    a24: 0.0;
	    a31: 0.0;
	    a32: -1.0;
	    a33: 1.0;
	    a34: 0.0;
	    a41: 0.0;
	    a42: 1.0;
	    a43: 0.0;
	    a44: 0.0
    ]

    setScale: aVector [
	<category: 'initialize'>
	self
	    a11: aVector x;
	    a22: aVector y;
	    a33: aVector z
    ]

    setTranslation: aVector [
	<category: 'initialize'>
	self
	    a14: aVector x;
	    a24: aVector y;
	    a34: aVector z
    ]

    setZero [
	"Set the receiver to the zero matrix"

	<category: 'initialize'>
	self loadFrom: ZeroMatrix
    ]

    skew: vector [
	"Set the skew-symetric matrix up"

	<category: 'initialize'>
	self a21: vector z.
	self a12: vector z negated.
	self a31: vector y negated.
	self a13: vector y.
	self a32: vector x.
	self a23: vector x negated
    ]

    loadFrom: anArray [
	<category: 'internal'>
	(1 to: self size) do: [:i | self at: i put: (anArray at: i) asFloat]
	"return self"
    ]
]



Eval [
    Matrix16f initialize
]

