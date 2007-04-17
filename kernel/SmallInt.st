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

lowBit
    "Return the index of the lowest order 1 bit of the receiver."

    | n bit |
    self = 0 ifTrue: [ ^0 ].

    n := self.
    "The result is 1-based, but we start from 2 to compensate with the
     subtraction in the final line."
    bit := 2.

    (n bitAnd: 16r3FFFFFFF) = 0 ifTrue: [
	bit := bit + 30. n := n bitShift: -30 ].

    (n bitAnd: 16rFFFF) = 0 ifTrue: [ bit := bit + 16. n := n bitShift: -16 ].
    (n bitAnd: 16rFF) = 0 ifTrue: [ bit := bit + 8. n := n bitShift: -8 ].
    (n bitAnd: 16rF) = 0 ifTrue: [ bit := bit + 4. n := n bitShift: -4 ].
    (n bitAnd: 16r3) = 0 ifTrue: [ bit := bit + 2. n := n bitShift: -2 ].
    ^bit - (n bitAnd: 16r1)!

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


!SmallInteger methodsFor: 'built ins'!

+ arg
    "Sum the receiver and arg and answer another Number"
    <primitive: VMpr_SmallInteger_plus>
    ^self generality == arg generality
	ifFalse: [ self retrySumCoercing: arg ]
	ifTrue: [ (LargeInteger fromInteger: self) +
	    (LargeInteger fromInteger: arg) ]
!

- arg
    "Subtract arg from the receiver and answer another Number"
    <primitive: VMpr_SmallInteger_minus>
    ^self generality == arg generality
	ifFalse: [ self retryDifferenceCoercing: arg ]
	ifTrue: [ (LargeInteger fromInteger: self) -
	    (LargeInteger fromInteger: arg) ]
!

< arg
    "Answer whether the receiver is less than arg"
    <primitive: VMpr_SmallInteger_lt>
    ^self retryRelationalOp: #< coercing: arg
!

> arg
    "Answer whether the receiver is greater than arg"
    <primitive: VMpr_SmallInteger_gt>
    ^self retryRelationalOp: #> coercing: arg
!

<= arg
    "Answer whether the receiver is less than or equal to arg"
    <primitive: VMpr_SmallInteger_le>
    ^self retryRelationalOp: #<= coercing: arg
!

>= arg
    "Answer whether the receiver is greater than or equal to arg"
    <primitive: VMpr_SmallInteger_ge>
    ^self retryRelationalOp: #>= coercing: arg
!

= arg
    "Answer whether the receiver is equal to arg"
    <primitive: VMpr_SmallInteger_eq>
    ^self retryEqualityCoercing: arg
!

== arg
    "Answer whether the receiver is the same object as arg"
    <primitive: VMpr_SmallInteger_eq>
    "if they aren't = by the primitive, they're not =="
    ^false
!

~= arg
    "Answer whether the receiver is not equal to arg"
    <primitive: VMpr_SmallInteger_ne>
    ^self retryInequalityCoercing: arg
!

~~ arg
    "Answer whether the receiver is not the same object as arg"
    <primitive: VMpr_SmallInteger_ne>
    ^true			"see comment above for =="
!

* arg
    "Multiply the receiver and arg and answer another Number"
    <primitive: VMpr_SmallInteger_times>
    ^self generality == arg generality
	ifFalse: [ self retryMultiplicationCoercing: arg ]
	ifTrue: [ (LargeInteger fromInteger: self) *
	    (LargeInteger fromInteger: arg) ]
!

/ arg
    "Divide the receiver by arg and answer another Integer or Fraction"
    <primitive: VMpr_SmallInteger_divide>
    " Create a Fraction when it's appropriate "
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^arg class == self class
	ifTrue: [ (Fraction numerator: self denominator: arg) reduce ]
	ifFalse: [ self retryDivisionCoercing: arg ]
!

\\ arg
    "Calculate the remainder of dividing receiver by arg (with truncation
     towards -infinity) and answer it"
    <primitive: VMpr_SmallInteger_modulo>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #\\ coercing: arg
!

// arg
    "Dividing receiver by arg (with truncation towards -infinity) and answer
     the result"
    <primitive: VMpr_SmallInteger_intDiv>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #// coercing: arg
!

divExact: arg
    "Dividing receiver by arg assuming that the remainder is zero, and answer
     the result"
    "Use quo:, no speed to gain fom SmallIntegers."
    <primitive: VMpr_SmallInteger_quo>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #divExact: coercing: arg
!

quo: arg
    "Dividing receiver by arg (with truncation towards zero) and answer
     the result"
    <primitive: VMpr_SmallInteger_quo>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #quo: coercing: arg
!

bitAnd: arg
    "Do a bitwise AND between the receiver and arg, answer the result"
    <primitive: VMpr_SmallInteger_bitAnd>
    ^arg isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitAnd: arg ]
!

bitOr: arg
    "Do a bitwise OR between the receiver and arg, answer the result"
    <primitive: VMpr_SmallInteger_bitOr>
    ^arg isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitOr: arg ]
!

bitXor: arg
    "Do a bitwise XOR between the receiver and arg, answer the result"
    <primitive: VMpr_SmallInteger_bitXor>
    ^arg isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitXor: arg ]
!

bitShift: arg
    "Shift the receiver by arg places to the left if arg > 0,
     by arg places to the right if arg < 0, answer another Number"

    <primitive: VMpr_SmallInteger_bitShift>
    ^arg isSmallInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitShift: arg ]
!

asFloatD
    "Convert the receiver to a FloatD, answer the result"
    <primitive: VMpr_SmallInteger_asFloatD>
    self primitiveFailed
!

asFloatE
    "Convert the receiver to a FloatE, answer the result"
    <primitive: VMpr_SmallInteger_asFloatE>
    self primitiveFailed
!

asFloatQ
    "Convert the receiver to a FloatQ, answer the result"
    <primitive: VMpr_SmallInteger_asFloatQ>
    self primitiveFailed
!

asObject
    "Answer the object whose index is in the receiver, nil if there is a free
     object, fail if index is out of bounds"
    <primitive: VMpr_SmallInteger_asObject>
    self primitiveFailed
!

nextValidOop
    "Answer the index of the first non-free OOP after the receiver.  This is
    used internally; it is placed here to avoid polluting Object."
    <primitive: VMpr_SmallInteger_nextValidOop>
    ^nil
!

asObjectNoFail
    "Answer the object whose index is in the receiver, or nil if no object is
     found at that index"
    <primitive: VMpr_SmallInteger_asObject>
    ^nil
! !


!SmallInteger methodsFor: 'builtins'!

scramble
    "Answer the receiver with its bits mixed and matched."
    <primitive: VMpr_SmallInteger_scramble>
    self primitiveFailed
!

at: anIndex
    "Answer the index-th indexed instance variable of the receiver.
     This method always fails."
    SystemExceptions.NotIndexable signalOn: self
!

basicAt: anIndex
    "Answer the index-th indexed instance variable of the receiver.
     This method always fails."
    SystemExceptions.NotIndexable signalOn: self
!

at: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver
     This method always fails."

    SystemExceptions.NotIndexable signalOn: self
!

basicAt: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver
     This method always fails."

    SystemExceptions.NotIndexable signalOn: self
! !

