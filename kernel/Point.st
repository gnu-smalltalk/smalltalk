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



Object subclass: Point [
    | x y |
    
    <category: 'Language-Data types'>
    <comment: 'Beginning of a Point class for simple display manipulation.  Has not been
 exhaustively tested but appears to work for the basic primitives and for
 the needs of the Rectangle class.'>

    Point class >> new [
	"Create a new point with both coordinates set to 0"

	<category: 'instance creation'>
	^self basicNew x: 0 y: 0
    ]

    Point class >> x: xInteger y: yInteger [
	"Create a new point with the given coordinates"

	<category: 'instance creation'>
	^self basicNew x: xInteger y: yInteger
    ]

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: x;
	    nextPut: $@;
	    print: y
    ]

    storeOn: aStream [
	"Print Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	aStream
	    nextPut: $(;
	    store: x;
	    nextPutAll: ' @ ';
	    store: y;
	    nextPut: $)
    ]

    x [
	"Answer the x coordinate"

	<category: 'accessing'>
	^x
    ]

    y [
	"Answer the y coordinate"

	<category: 'accessing'>
	^y
    ]

    x: aNumber [
	"Set the x coordinate to aNumber"

	<category: 'accessing'>
	x := aNumber
    ]

    y: aNumber [
	"Set the y coordinate to aNumber"

	<category: 'accessing'>
	y := aNumber
    ]

    x: anXNumber y: aYNumber [
	"Set the x and y coordinate to anXNumber and aYNumber, respectively"

	<category: 'accessing'>
	x := anXNumber.
	y := aYNumber
    ]

    asPoint [
	<category: 'converting'>
	^self	"But I already AM a point!"
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'converting'>
	^self x hash bitXor: self y hash
    ]

    + delta [
	"Sum the receiver and delta, which can be a Number or a Point"

	<category: 'arithmetic'>
	| deltaPoint |
	deltaPoint := delta asPoint.
	^Point x: self x + deltaPoint x y: self y + deltaPoint y
    ]

    - delta [
	"Subtract delta, which can be a Number or a Point, from the receiver"

	<category: 'arithmetic'>
	| deltaPoint |
	deltaPoint := delta asPoint.
	^Point x: self x - deltaPoint x y: self y - deltaPoint y
    ]

    * scale [
	"Multiply the receiver by scale, which can be a Number or a Point"

	<category: 'arithmetic'>
	| scalePoint |
	scalePoint := scale asPoint.
	^Point x: self x * scalePoint x y: self y * scalePoint y
    ]

    / scale [
	"Divide the receiver by scale, which can be a Number or a Point, with
	 no loss of precision"

	<category: 'arithmetic'>
	| scalePoint |
	scalePoint := scale asPoint.
	^Point x: self x / scalePoint x y: self y / scalePoint y
    ]

    // scale [
	"Divide the receiver by scale, which can be a Number or a Point, with
	 truncation towards -infinity"

	<category: 'arithmetic'>
	| scalePoint |
	scalePoint := scale asPoint.
	^Point x: self x // scalePoint x y: self y // scalePoint y
    ]

    abs [
	"Answer a new point whose coordinates are the absolute values of the
	 receiver's"

	<category: 'arithmetic'>
	^Point x: self x abs y: self y abs
    ]

    rounded [
	"Answer a new point whose coordinates are rounded to the nearest integer"

	<category: 'truncation and round off'>
	^Point x: self x rounded y: self y rounded
    ]

    truncateTo: grid [
	"Answer a new point whose coordinates are rounded towards -infinity,
	 to a multiple of grid (which must be a Number)"

	<category: 'truncation and round off'>
	^Point x: (self x truncateTo: grid) y: (self y truncateTo: grid)
    ]

    = aPoint [
	"Answer whether the receiver is equal to aPoint"

	<category: 'comparing'>
	^aPoint class == Point and: [self x = aPoint x & (self y = aPoint y)]
    ]

    < aPoint [
	"Answer whether the receiver is higher and to the left of aPoint"

	<category: 'comparing'>
	^self x < aPoint x and: [self y < aPoint y]
    ]

    > aPoint [
	"Answer whether the receiver is lower and to the right of aPoint"

	<category: 'comparing'>
	^self x > aPoint x and: [self y > aPoint y]
    ]

    <= aPoint [
	"Answer whether aPoint is equal to the receiver, or the receiver
	 is higher and to the left of aPoint"

	<category: 'comparing'>
	^self x <= aPoint x and: [self y <= aPoint y]
    ]

    >= aPoint [
	"Answer whether aPoint is equal to the receiver, or the receiver
	 is lower and to the right of aPoint"

	<category: 'comparing'>
	^self x >= aPoint x and: [self y >= aPoint y]
    ]

    max: aPoint [
	"Answer self if it is lower and to the right of aPoint, aPoint otherwise"

	<category: 'comparing'>
	^(self x max: aPoint x) @ (self y max: aPoint y)
    ]

    min: aPoint [
	"Answer self if it is higher and to the left of aPoint, aPoint otherwise"

	<category: 'comparing'>
	^(self x min: aPoint x) @ (self y min: aPoint y)
    ]

    arcTan [
	"Answer the angle (measured counterclockwise) between the receiver and
	 a ray starting in (0, 0) and moving towards (1, 0) - i.e. 3 o'clock"

	<category: 'point functions'>
	^self y arcTan: self x
    ]

    dist: aPoint [
	"Answer the distance between the receiver and aPoint"

	<category: 'point functions'>
	| a b |
	a := self x - aPoint x.
	b := self y - aPoint y.
	^(a squared + b squared) sqrt
    ]

    dotProduct: aPoint [
	"Answer the dot product between the receiver and aPoint"

	<category: 'point functions'>
	^self x * aPoint x + (self y * aPoint y)
    ]

    grid: aPoint [
	"Answer a new point whose coordinates are rounded towards the nearest
	 multiple of aPoint"

	<category: 'point functions'>
	^Point x: (self x roundTo: aPoint x) y: (self y roundTo: aPoint y)
    ]

    normal [
	"Rotate the Point 90degrees clockwise and get the unit vector"

	<category: 'point functions'>
	| len |
	len := (self x squared + self y squared) sqrt.
	^Point x: self y negated / len y: x / len
    ]

    transpose [
	"Answer a new point whose coordinates are the receiver's coordinates
	 exchanged (x becomes y, y becomes x)"

	<category: 'point functions'>
	^Point x: y y: x
    ]

    truncatedGrid: aPoint [
	"Answer a new point whose coordinates are rounded towards -infinity,
	 to a multiple of grid (which must be a Point)"

	<category: 'point functions'>
	^Point x: (self x truncateTo: aPoint x) y: (self y truncateTo: aPoint y)
    ]
]



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

