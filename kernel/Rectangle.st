"========================================================================
|
|   Rectangle Class
|
|
 ========================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006
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


Object subclass: #Rectangle
       instanceVariableNames: 'origin corner'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Data types'
!

Rectangle comment:
'Beginning of the Rectangle class for simple display manipulation.
 Rectangles require the Point class to be available.  An extension
 to the Point class is made here that since it requires Rectangles
 to be defined (see converting)' !


!Rectangle class methodsFor: 'instance creation'!

new
    "Answer the (0 @ 0 corner: 0 @ 0) rectangle"

    ^self origin: 0 @ 0 corner: 0 @ 0
!

origin: originPoint corner: cornerPoint
    "Answer a rectangle with the given corners"
    ^self basicNew origin: originPoint corner: cornerPoint
!

origin: originPoint extent: extentPoint
    "Answer a rectangle with the given origin and size"
    ^self basicNew origin: originPoint corner: (originPoint + extentPoint)
!

left: leftNumber right: rightNumber top: topNumber bottom: bottomNumber
    "Answer a rectangle with the given coordinates"
    ^self basicNew
	origin: (Point x: leftNumber y: topNumber)
	corner: (Point x: rightNumber y: bottomNumber)
! !


!Rectangle methodsFor: 'accessing'!

bottom
    "Answer the corner's y of the receiver"
    ^corner y
!

bottom: aNumber
    "Set the corner's y of the receiver"
    corner y: aNumber
!

bottomCenter
    "Answer the center of the receiver's bottom side"
    ^self xCenter @ corner y
!

bottomLeft
    "Answer the bottom-left corner of the receiver"
    ^origin x @ corner y
!

bottomLeft: aPoint
    "Answer the receiver with the bottom-left changed to aPoint"
    origin x: aPoint x.
    corner y: aPoint y.
!

bottomRight
    "Answer the bottom-right corner of the receiver"
    ^corner copy
!

bottomRight: aPoint
    "Change the bottom-right corner of the receiver"
    corner := aPoint copy
!

center
    "Answer the center of the receiver"
    ^self xCenter @ self yCenter
!

corner
    "Answer the corner of the receiver"
    ^corner
!

corner: aPoint
    "Set the corner of the receiver"
    corner := aPoint
!

extent
    "Answer the extent of the receiver"
    ^corner - origin
!

extent: aPoint
    "Change the size of the receiver, keeping the origin the same"
    corner := origin + aPoint
!

height
    "Answer the height of the receiver"
    ^self bottom - self top
!

height: aNumber
    "Set the height of the receiver"
    corner y: (self origin y + aNumber)
!

left
    "Answer the x of the left edge of the receiver"
    ^origin x
!

left: aValue
    "Set the x of the left edge of the receiver"
    origin x: aValue
!

left: l top: t right: r bottom: b
    "Change all four the coordinates of the receiver's corners"
    origin := l @ t.
    corner := r @ b
!

leftCenter
    "Answer the center of the receiver's left side"
    ^origin x @ self yCenter
!

origin
    "Answer the top-left corner of the receiver"
    ^origin
!

origin: aPoint
    "Change the top-left corner of the receiver to aPoint"
    origin := aPoint copy
!

origin: pnt1 corner: pnt2
    "Change both the origin (top-left corner) and the corner (bottom-right
     corner) of the receiver"
    origin := pnt1 copy.
    corner := pnt2 copy
!

origin: pnt1 extent: pnt2
    "Change the top-left corner and the size of the receiver"
    origin := pnt1 copy.
    corner := pnt1 + pnt2
!

right
    "Answer the x of the bottom-right corner of the receiver"
    ^corner x
!

right: aNumber
    "Change the x of the bottom-right corner of the receiver"
    corner x: aNumber
!

rightCenter
    "Answer the center of the receiver's right side"
    ^corner x @ self yCenter
!

top
    "Answer the y of the receiver's top-left corner"
    ^origin y
!

top: aValue
    "Change the y of the receiver's top-left corner"
    origin y: aValue
!

topCenter
    "Answer the center of the receiver's top side"
    ^self xCenter @ origin y
!

topLeft
    "Answer the receiver's top-left corner"
    ^origin copy
!

topLeft: aPoint
    "Change the receiver's top-left corner's coordinates to aPoint"
    origin := aPoint copy
!

topRight
    "Answer the receiver's top-right corner"
    ^corner x @ origin y
!

topRight: aPoint
    "Change the receiver's top-right corner to aPoint"
    corner x: aPoint x.
    origin y: aPoint y
!

width
    "Answer the receiver's width"
    ^self right - self left
!

width: aNumber
    "Change the receiver's width to aNumber"
    corner x: origin x + aNumber
! !




!Rectangle methodsFor: 'testing'!

containsPoint: aPoint
    "Answer true if aPoint is equal to, or below and to the right of, the
     receiver's origin; and aPoint is above and to the left of the receiver's
     corner"
    ^(aPoint >= origin) and: [aPoint < corner]
!

contains: aRectangle
    "Answer true if the receiver contains (see containsPoint:) both
     aRectangle's origin and aRectangle's corner"
    ^(self containsPoint: aRectangle origin) and: [
       (self containsPoint: aRectangle corner)]
!

intersects: aRectangle
    "Answer true if the receiver intersect aRectangle, i.e. if it contains
     (see containsPoint:) any of aRectangle corners or if aRectangle contains
     the receiver"

    | selfNorm rectNorm left top right bottom |

    selfNorm := self       normalized.
    rectNorm := aRectangle normalized.

    right  := selfNorm right  min: rectNorm right.
    left   := selfNorm left   max: rectNorm left.
    right <= left ifTrue: [ ^false ].

    bottom := selfNorm bottom min: rectNorm bottom.
    top    := selfNorm top    max: rectNorm top.
    ^bottom > top! !

= aRectangle
    "Answer whether the receiver is equal to aRectangle"
    ^(self class == aRectangle class) 
	and: [ origin = aRectangle origin
	    and: [ corner = aRectangle corner ] ]
!

hash
    "Answer an hash value for the receiver"
    ^origin hash bitXor: corner hash
! !


!Rectangle methodsFor: 'rectangle functions'!

amountToTranslateWithin: aRectangle
    "Answer a Point so that if aRectangle is translated by that point,
     its origin lies within the receiver's."
    (aRectangle contains: self) ifTrue: [ ^0@0 ].
    ^aRectangle origin - origin
!

translatedToBeWithin: aRectangle
    "Answer a copy of the receiver that does not extend beyond aRectangle."

    ^self translateBy: (self amountToTranslateWithin: aRectangle)
!

area
    "Answer the receiver's area. The area is the width times the height,
     so it is possible for it to be negative if the rectangle is not
     normalized."
    ^self width * self height
!

areasOutside: aRectangle
    "Answer a collection of rectangles containing the parts of the receiver
     outside of aRectangle. For all points in the receiver, but outside
     aRectangle, exactly one rectangle in the collection will contain that
     point."
     
    "The basic algorithm is to first determine that there is an
     intersection by finding the overlapping rectangle.  From the
     overlapping rectangle, determine which edges it runs along.
     For each edge, if it doesn't run along that edge, add a new
     rectangle to the collection.
     Most times 2 or 3 rectangles get formed, some times 0, 1 or 4."

    | ansSet l t r b xsect |
    xsect := self intersect: aRectangle.
    xsect area = 0 ifTrue: [ ^{self copy} ].

    ansSet := Set new: 8.
    l := self left min: self right.
    r := self left max: self right.
    t := self top min: self bottom.
    b := self top max: self bottom.
    l = xsect left ifFalse: [
	 ansSet add: (l @ t corner: xsect left @ b)
    ].
    t = xsect top ifFalse: [
	 ansSet add: (xsect left @ t corner: xsect topRight)
    ].
    b = xsect bottom ifFalse: [
	 ansSet add: (xsect bottomLeft corner: xsect right @ b)
    ].
    r = xsect right ifFalse: [
	 ansSet add: (xsect right @ t corner: r @ b)
    ].
    ^ansSet asArray
!

expandBy: delta
    "Answer a new rectangle that is the receiver expanded by aValue:
     if aValue is a rectangle, calculate origin=origin-aValue origin,
     corner=corner+aValue corner; else calculate origin=origin-aValue,
     corner=corner+aValue."
    (delta isMemberOf: Point) ifTrue:
       [^Rectangle origin: (origin-delta)
		   corner: (corner+delta)].
    (delta isMemberOf: Rectangle) ifTrue:
       [^Rectangle origin: (origin-(delta origin))
		   corner: (corner+(delta corner))].
    (delta isKindOf: Number) ifTrue:
       [^Rectangle left: (origin x)-delta
		   right:(corner x)+delta
		   top:  (origin y)-delta
		   bottom:(corner y)+delta].

    SystemExceptions.WrongClass signalOn: delta
	mustBe: #( #{Point} #{Rectangle} #{Number} )
!

insetBy: delta
    "Answer a new rectangle that is the receiver inset by aValue:
     if aValue is a rectangle, calculate origin=origin+aValue origin,
     corner=corner-aValue corner; else calculate origin=origin+aValue,
     corner=corner-aValue."
    (delta isMemberOf: Point) ifTrue:
       [^Rectangle origin: (origin+delta)
		   corner: (corner-delta)].
    (delta isMemberOf: Rectangle) ifTrue:
       [^Rectangle origin: (origin+(delta origin))
		   corner: (corner-(delta corner))].
    (delta isKindOf: Number) ifTrue:
       [^Rectangle left: (origin x)+delta
		   right:(corner x)-delta
		   top:  (origin y)+delta
		   bottom:(corner y)-delta].

    SystemExceptions.WrongClass signalOn: delta
	mustBe: #( #{Point} #{Rectangle} #{Number} )
!

insetOriginBy: originDelta corner: cornerDelta
    "Answer a new rectangle that is the receiver inset so that
     origin=origin+originDelta, corner=corner-cornerDelta.
     The deltas can be points or numbers"
    ^Rectangle origin: origin + originDelta
	      corner: corner - cornerDelta
!

merge: aRectangle
    "Answer a new rectangle which is the smallest rectangle containing
     both the receiver and aRectangle."
    
    ^Rectangle 
	origin: (origin min: aRectangle origin)
	corner: (corner max: aRectangle corner)
!

intersect: aRectangle
    "Answers the rectangle (if any) created by the overlap of
     rectangles A and B.  Answers nil if the rectangles do not
     overlap"

    | selfNorm rectNorm left top right bottom |

    selfNorm := self       normalized.
    rectNorm := aRectangle normalized.

    right  := selfNorm right  min: rectNorm right.
    left   := selfNorm left   max: rectNorm left.
    right <= left ifTrue: [ ^nil ].

    bottom := selfNorm bottom min: rectNorm bottom.
    top    := selfNorm top    max: rectNorm top.
    bottom <= top ifTrue: [ ^nil ].

    ^Rectangle origin: left @ top corner: right @ bottom
! !


!Rectangle methodsFor: 'copying'!

copy
    "Return a deep copy of the receiver for safety."
    ^self deepCopy
! !


!Rectangle methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream print: origin;
	nextPutAll: ' corner: ';
	print: corner
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    aStream nextPutAll: '(Rectangle origin: ';
	store: origin;
	nextPutAll: ' corner: ';
	store: corner;
	nextPut: $)
! !


!Rectangle methodsFor: 'private'!

normalize
    "Normalize the receiver (make origin < corner)"
    self right > self left
        ifTrue: [ temp := self left. origin x: corner x. corner x: temp ].
    self bottom > self top
        ifTrue: [ temp := self top. origin y: corner y. corner y: temp ].
!

normalized
    "Answer the receiver if it is normalized, otherwise create and
     return a copy which is normalized (has origin < corner)"
    (self right > self left and: [ self bottom > self top ])
        ifTrue: [ ^self ].

    ^Rectangle
        origin: (origin min: corner)
        corner: (origin max: corner)
!

xCenter
    "Answer the x of the receiver's center"
    ^origin x + corner x / 2
!

yCenter
    "Answer the y of the receiver's center"
    ^origin y + corner y / 2
! !



!Rectangle methodsFor: 'truncation and round off'!

rounded
    "Answer a copy of the receiver with the coordinates rounded to the nearest
     integers"
    ^Rectangle origin: origin rounded corner: corner rounded
! !


!Rectangle methodsFor: 'transforming'!

moveBy: aPoint
    "Change the receiver so that the origin and corner are shifted by aPoint"
    origin := origin + aPoint.
    corner := corner + aPoint
!

moveTo: aPoint
    "Change the receiver so that the origin moves to aPoint and the size
     remains unchanged"
    | diff |
    diff := aPoint - origin.
    origin := aPoint copy.
    corner := corner + diff
!

scaleBy: scale
    "Answer a copy of the receiver in which the origin and corner are
     multiplied by scale"
    ^Rectangle origin: origin * scale corner: corner * scale
!

translateBy: factor
    "Answer a copy of the receiver in which the origin and corner are shifted
     by aPoint"
    ^Rectangle origin: origin + factor corner: corner + factor
! !


!Number methodsFor: 'converting'!

asRectangle
    "Answer an empty rectangle whose origin is (self asPoint)"
    ^Rectangle left: self top: self right: self bottom: self
! !


!Point methodsFor: 'converting'!

asRectangle
    "Answer an empty rectangle whose origin is self"
    ^Rectangle origin: self corner: self copy
!

corner: aPoint
    "Answer a Rectangle whose origin is the receiver and whose corner
     is aPoint"
    ^Rectangle origin: self corner: aPoint
!

extent: aPoint
    "Answer a Rectangle whose origin is the receiver and whose extent
     is aPoint"
    ^Rectangle origin: self extent: aPoint
! !
