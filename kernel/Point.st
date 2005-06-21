"=====================================================================
|
|    Point Class Definitions
|
|
 ====================================================================="

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002
| Free Software Foundation, Inc.
| By Doug McCallum <uunet!ico.isc.com!dougm>
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


Object subclass: #Point
       instanceVariableNames: 'x y'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Data types'
!

Point comment:
'Beginning of a Point class for simple display manipulation.  Has not been
 exhaustively tested but appears to work for the basic primitives and for
 the needs of the Rectangle class.' !


!Number methodsFor: 'point creation'!

@ y
    "Answer a new point whose x is the receiver and whose y is y"
    ^ Point x: self y: y
!

asPoint
    "Answer a new point, self @ self"
    ^Point x: self y: self
! !



!Point class methodsFor: 'instance creation'!

new
    "Create a new point with both coordinates set to 0"
    ^self basicNew x: 0 y: 0
!

x: xInteger y: yInteger
    "Create a new point with the given coordinates"
    ^self basicNew x: xInteger y: yInteger
! !


!Point methodsFor: 'printing'!

printOn: aStream
    "Print a representation for the receiver on aStream"
    aStream print: x;
	nextPut: $@;
	print: y
! !


!Point methodsFor: 'storing'!

storeOn: aStream
    "Print Smalltalk code compiling to the receiver on aStream"
    aStream nextPut: $(;
	store: x;
	nextPutAll: ' @ ';
	store: y;
	nextPut: $)
! !


!Point methodsFor: 'accessing'!

x
    "Answer the x coordinate"
    ^x
!

y
    "Answer the y coordinate"
    ^y
!

x: aNumber
    "Set the x coordinate to aNumber"
    x := aNumber
!

y: aNumber
    "Set the y coordinate to aNumber"
    y := aNumber
!

x: anXNumber y: aYNumber
    "Set the x and y coordinate to anXNumber and aYNumber, respectively"
    x := anXNumber.
    y := aYNumber
! !


!Point methodsFor: 'converting'!

asPoint
    ^self			"But I already AM a point!"
!

hash
    "Answer an hash value for the receiver"
    ^self x hash bitXor: self y hash
! !


!Point methodsFor: 'arithmetic'!

+ delta
    "Sum the receiver and delta, which can be a Number or a Point"
    | deltaPoint |
    deltaPoint := delta asPoint.
    ^Point x: (self x + deltaPoint x) y: (self y + deltaPoint y)
!

- delta
    "Subtract delta, which can be a Number or a Point, from the receiver"
    | deltaPoint |
    deltaPoint := delta asPoint.
    ^Point x: (self x - deltaPoint x) y: (self y - deltaPoint y)
!

* scale
    "Multiply the receiver by scale, which can be a Number or a Point"
    | scalePoint |
    scalePoint := scale asPoint.
    ^Point x: (self x * scalePoint x) y: (self y * scalePoint y)
!

/ scale
    "Divide the receiver by scale, which can be a Number or a Point, with
     no loss of precision"
    | scalePoint |
    scalePoint := scale asPoint.
    ^Point x: (self x / scalePoint x) y: (self y / scalePoint y)
!

// scale
    "Divide the receiver by scale, which can be a Number or a Point, with
     truncation towards -infinity"
    | scalePoint |
    scalePoint := scale asPoint.
    ^Point x: (self x // scalePoint x) y: (self y // scalePoint y)
!

abs
    "Answer a new point whose coordinates are the absolute values of the
     receiver's"
    ^Point x: (self x abs) y: (self y abs)
! !


!Point methodsFor: 'truncation and round off'!

rounded
    "Answer a new point whose coordinates are rounded to the nearest integer"
    ^Point x: (self x rounded) y: (self y rounded)
!

truncateTo: grid
    "Answer a new point whose coordinates are rounded towards -infinity,
     to a multiple of grid (which must be a Number)"
    ^Point x: (self x truncateTo: grid) y: (self y truncateTo: grid)

! !



!Point methodsFor: 'comparing'!

= aPoint
    "Answer whether the receiver is equal to aPoint"
    ^(aPoint class == Point) and: [ (self x = aPoint x) & (self y = aPoint y) ]
!

< aPoint
    "Answer whether the receiver is higher and to the left of aPoint"
    ^(self x < aPoint x) and: [ (self y < aPoint y) ]
!

> aPoint
    "Answer whether the receiver is lower and to the right of aPoint"
    ^(self x > aPoint x) and: [ (self y > aPoint y) ]
!

<= aPoint
    "Answer whether aPoint is equal to the receiver, or the receiver
     is higher and to the left of aPoint"
    ^(self x <= aPoint x) and: [ (self y <= aPoint y) ]
!

>= aPoint
    "Answer whether aPoint is equal to the receiver, or the receiver
     is lower and to the right of aPoint"
    ^(self x >= aPoint x) and: [ (self y >= aPoint y) ]
!

max: aPoint
    "Answer self if it is lower and to the right of aPoint, aPoint otherwise"
    (self > aPoint)
       ifTrue: [ ^self ]
       ifFalse:[ ^aPoint ]
!

min: aPoint
    "Answer self if it is higher and to the left of aPoint, aPoint otherwise"
    (self < aPoint)
       ifTrue: [^ self ]
       ifFalse:[^ aPoint ]
! !


!Point methodsFor: 'point functions'!

arcTan
    "Answer the angle (measured counterclockwise) between the receiver and
     a ray starting in (0, 0) and moving towards (1, 0) - i.e. 3 o'clock"

    | result |
    self x = 0 ifTrue: [ ^self y sign * FloatD pi / -2 ].
    
    result := (self y / self x) arcTan.
    self x < 0 ifTrue: [ result := result + FloatD pi ].
    result > FloatD pi ifTrue: [ result := result - FloatD pi - FloatD pi ].
    ^result
!

dist: aPoint
    "Answer the distance between the receiver and aPoint"
    | a b |
    a := self x - aPoint x.
    b := self y - aPoint y.
    ^((a squared) + (b squared)) sqrt
!

dotProduct: aPoint
    "Answer the dot product between the receiver and aPoint"
    ^(self x * aPoint x) + (self y * aPoint y)
!

grid: aPoint
    "Answer a new point whose coordinates are rounded towards the nearest
     multiple of aPoint"
    ^Point 
	x: (self x roundTo: (aPoint x))
	y: (self y roundTo: (aPoint y))
!

normal
    "Rotate the Point 90degrees clockwise and get the unit vector"
    | len |
    len := ((self x squared) + (self y squared)) sqrt.
    ^Point x: (self y negated / len) y: (x / len)
!

transpose
    "Answer a new point whose coordinates are the receiver's coordinates
     exchanged (x becomes y, y becomes x)"
    ^Point x: y y: x
!

truncatedGrid: aPoint
    "Answer a new point whose coordinates are rounded towards -infinity,
     to a multiple of grid (which must be a Point)"
    ^Point
	x: (self x truncateTo: (aPoint x))
	y: (self y truncateTo: (aPoint y))
! !



