"======================================================================
|
|   SmallInteger Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
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


Integer subclass: #SmallInteger
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Data types'
!

SmallInteger comment:
'I am the integer class of the GNU Smalltalk system.  My instances can 
represent signed 30 bit integers and are as efficient as possible.' !


!SmallInteger class methodsFor: 'testing'!

isIdentity
    "Answer whether x = y implies x == y for instances of the receiver"
    ^true
! !


!SmallInteger class methodsFor: 'getting limits'!

bits
    "Answer the number of bits (excluding the sign) that can be represented
    directly in an object pointer"
    ^CLongSize * 8 - 3
!

largest
    "Answer the largest integer represented directly in an object pointer"
    | maxBit |
    maxBit := 1 bitShift: CLongSize * 8 - 3.
    ^(maxBit - 1) + maxBit
!

smallest
    "Answer the smallest integer represented directly in an object pointer"
    | maxBit |
    maxBit := 1 bitShift: CLongSize * 8 - 3.
    ^maxBit negated - maxBit
! !


!SmallInteger methodsFor: 'coercion methods'!

zero
    "Coerce 0 to the receiver's class"
    ^0
!

unity
    "Coerce 1 to the receiver's class"
    ^1
!

generality
    "Return the receiver's generality"
    ^100
! !


!SmallInteger methodsFor: 'bit arithmetic'!

highBit
    "Return the index of the highest order 1 bit of the receiver"

    | n bit |
    self = 0 ifTrue: [ ^0 ].

    bit := 0.
    self < 0
	ifTrue: [
	    "Increment the result by one if not a power of two"
	    n := self negated. 
	    (n bitAnd: self) = n ifFalse: [ bit := 1 ]
	]
	ifFalse: [ n := self. bit := 0 ].

    [ n > 16r3FFFFFFF ] whileTrue: [
	bit := bit + 30. n := n bitShift: -30 ].

    n > 16rFFFF ifTrue: [ bit := bit + 16. n := n bitShift: -16 ].
    n > 16rFF ifTrue: [ bit := bit + 8. n := n bitShift: -8 ].
    n > 16rF ifTrue: [ bit := bit + 4. n := n bitShift: -4 ].
    n > 16r3 ifTrue: [ bit := bit + 2. n := n bitShift: -2 ].
    n > 16r1 ifTrue: [ bit := bit + 1. n := n bitShift: -1 ].
    ^n + bit
! !


!SmallInteger methodsFor: 'testing functionality'!

isSmallInteger
    ^true
! !
