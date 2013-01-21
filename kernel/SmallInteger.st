"======================================================================
|
|   SmallInteger Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2007, 2008 Free Software Foundation, Inc.
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



Integer subclass: SmallInteger [
    
    <category: 'Language-Data types'>
    <comment: 'I am the integer class of the GNU Smalltalk system.  My instances can 
represent signed 30 bit integers and are as efficient as possible.'>

    SmallInteger class >> isIdentity [
	"Answer whether x = y implies x == y for instances of the receiver"

	<category: 'testing'>
	^true
    ]

    SmallInteger class >> bits [
	"Answer the number of bits (excluding the sign) that can be represented
	 directly in an object pointer"

	<category: 'getting limits'>
	^CLongSize * 8 - 3
    ]

    SmallInteger class >> largest [
	"Answer the largest integer represented directly in an object pointer"

	<category: 'getting limits'>
	| maxBit |
	maxBit := 1 bitShift: CLongSize * 8 - 3.
	^maxBit - 1 + maxBit
    ]

    SmallInteger class >> smallest [
	"Answer the smallest integer represented directly in an object pointer"

	<category: 'getting limits'>
	| maxBit |
	maxBit := 1 bitShift: CLongSize * 8 - 3.
	^maxBit negated - maxBit
    ]

    zero [
	"Coerce 0 to the receiver's class"

	<category: 'coercion methods'>
	^0
    ]

    unity [
	"Coerce 1 to the receiver's class"

	<category: 'coercion methods'>
	^1
    ]

    generality [
	"Return the receiver's generality"

	<category: 'coercion methods'>
	^100
    ]

    lowBit [
	"Return the index of the lowest order 1 bit of the receiver."

	<category: 'bit arithmetic'>
	| n bit |
	self = 0 ifTrue: [^0].
	n := self.
	"The result is 1-based, but we start from 2 to compensate with the
	 subtraction in the final line."
	bit := 2.
	(n bitAnd: 1073741823) = 0 
	    ifTrue: 
		[bit := bit + 30.
		n := n bitShift: -30].
	(n bitAnd: 65535) = 0 
	    ifTrue: 
		[bit := bit + 16.
		n := n bitShift: -16].
	(n bitAnd: 255) = 0 
	    ifTrue: 
		[bit := bit + 8.
		n := n bitShift: -8].
	(n bitAnd: 15) = 0 
	    ifTrue: 
		[bit := bit + 4.
		n := n bitShift: -4].
	(n bitAnd: 3) = 0 
	    ifTrue: 
		[bit := bit + 2.
		n := n bitShift: -2].
	^bit - (n bitAnd: 1)
    ]

    highBit [
	"Return the index of the highest order 1 bit of the receiver"

	<category: 'bit arithmetic'>
	| n bit |
	self = 0 ifTrue: [^0].
	bit := 0.
	self < 0 
	    ifTrue: 
		["Increment the result by one if not a power of two"

		n := self negated.
		(n bitAnd: self) = n ifFalse: [bit := 1]]
	    ifFalse: 
		[n := self.
		bit := 0].
	[n > 1073741823] whileTrue: 
		[bit := bit + 30.
		n := n bitShift: -30].
	n > 65535 
	    ifTrue: 
		[bit := bit + 16.
		n := n bitShift: -16].
	n > 255 
	    ifTrue: 
		[bit := bit + 8.
		n := n bitShift: -8].
	n > 15 
	    ifTrue: 
		[bit := bit + 4.
		n := n bitShift: -4].
	n > 3 
	    ifTrue: 
		[bit := bit + 2.
		n := n bitShift: -2].
	n > 1 
	    ifTrue: 
		[bit := bit + 1.
		n := n bitShift: -1].
	^n + bit
    ]

    isSmallInteger [
	<category: 'testing functionality'>
	^true
    ]

    + arg [
	"Sum the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_plus>
	^self generality == arg generality 
	    ifFalse: [self retrySumCoercing: arg]
	    ifTrue: [(LargeInteger fromInteger: self) + (LargeInteger fromInteger: arg)]
    ]

    - arg [
	"Subtract arg from the receiver and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_minus>
	^self generality == arg generality 
	    ifFalse: [self retryDifferenceCoercing: arg]
	    ifTrue: [(LargeInteger fromInteger: self) - (LargeInteger fromInteger: arg)]
    ]

    < arg [
	"Answer whether the receiver is less than arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_lt>
	^self retryRelationalOp: #< coercing: arg
    ]

    > arg [
	"Answer whether the receiver is greater than arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_gt>
	^self retryRelationalOp: #> coercing: arg
    ]

    <= arg [
	"Answer whether the receiver is less than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_le>
	^self retryRelationalOp: #<= coercing: arg
    ]

    >= arg [
	"Answer whether the receiver is greater than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_ge>
	^self retryRelationalOp: #>= coercing: arg
    ]

    = arg [
	"Answer whether the receiver is equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_eq>
	^self retryEqualityCoercing: arg
    ]

    == arg [
	"Answer whether the receiver is the same object as arg"

	"if they aren't = by the primitive, they're not =="

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_eq>
	^false
    ]

    ~= arg [
	"Answer whether the receiver is not equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_ne>
	^self retryInequalityCoercing: arg
    ]

    ~~ arg [
	"Answer whether the receiver is not the same object as arg"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_ne>
	^true	"see comment above for =="
    ]

    * arg [
	"Multiply the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_times>
	^self generality == arg generality 
	    ifFalse: [self retryMultiplicationCoercing: arg]
	    ifTrue: [(LargeInteger fromInteger: self) * (LargeInteger fromInteger: arg)]
    ]

    / arg [
	"Divide the receiver by arg and answer another Integer or Fraction"

	"Create a Fraction when it's appropriate"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_divide>
	arg = 0 ifTrue: [^self zeroDivide].
	^arg class == self class 
	    ifTrue: [(Fraction numerator: self denominator: arg) reduce]
	    ifFalse: [self retryDivisionCoercing: arg]
    ]

    \\ arg [
	"Calculate the remainder of dividing receiver by arg (with truncation
	 towards -infinity) and answer it"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_modulo>
	arg = 0 ifTrue: [^self zeroDivide].
	^self retry: #\\ coercing: arg
    ]

    // arg [
	"Dividing receiver by arg (with truncation towards -infinity) and answer
	 the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_intDiv>
	arg = 0 ifTrue: [^self zeroDivide].
	^self retry: #// coercing: arg
    ]

    divExact: arg [
	"Dividing receiver by arg assuming that the remainder is zero, and answer
	 the result"

	"Use quo:, no speed to gain fom SmallIntegers."

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_quo>
	self = 0 ifTrue: [^0].
	arg = 0 ifTrue: [^self zeroDivide].
	^self retry: #divExact: coercing: arg
    ]

    quo: arg [
	"Dividing receiver by arg (with truncation towards zero) and answer
	 the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_quo>
	arg = 0 ifTrue: [^self zeroDivide].
	^self retry: #quo: coercing: arg
    ]

    bitAnd: arg [
	"Do a bitwise AND between the receiver and arg, answer the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_bitAnd>
	^arg isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: arg mustBe: Integer]
	    ifTrue: [(LargeInteger fromInteger: self) bitAnd: arg]
    ]

    bitOr: arg [
	"Do a bitwise OR between the receiver and arg, answer the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_bitOr>
	^arg isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: arg mustBe: Integer]
	    ifTrue: [(LargeInteger fromInteger: self) bitOr: arg]
    ]

    bitXor: arg [
	"Do a bitwise XOR between the receiver and arg, answer the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_bitXor>
	^arg isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: arg mustBe: Integer]
	    ifTrue: [(LargeInteger fromInteger: self) bitXor: arg]
    ]

    bitShift: arg [
	"Shift the receiver by arg places to the left if arg > 0,
	 by arg places to the right if arg < 0, answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_bitShift>
	^arg isSmallInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: arg mustBe: Integer]
	    ifTrue: [(LargeInteger fromInteger: self) bitShift: arg]
    ]

    asCNumber [
	"Convert the receiver to a kind of number that is understood by
	 the C call-out mechanism."
	<category: 'coercion'>
	^self
    ]

    asFloatD [
	"Convert the receiver to a FloatD, answer the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_asFloatD>
	self primitiveFailed
    ]

    asFloatE [
	"Convert the receiver to a FloatE, answer the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_asFloatE>
	self primitiveFailed
    ]

    asFloatQ [
	"Convert the receiver to a FloatQ, answer the result"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_asFloatQ>
	self primitiveFailed
    ]

    asObject [
	"Answer the object whose index is in the receiver, nil if there is a free
	 object, fail if index is out of bounds"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_asObject>
	self primitiveFailed
    ]

    nextValidOop [
	"Answer the index of the first non-free OOP after the receiver.  This is
	 used internally; it is placed here to avoid polluting Object."

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_nextValidOop>
	^nil
    ]

    asObjectNoFail [
	"Answer the object whose index is in the receiver, or nil if no object is
	 found at that index"

	<category: 'built ins'>
	<primitive: VMpr_SmallInteger_asObject>
	^nil
    ]

    scramble [
	"Answer the receiver with its bits mixed and matched."

	<category: 'builtins'>
	<primitive: VMpr_SmallInteger_scramble>
	self primitiveFailed
    ]

    at: anIndex [
	"Answer the index-th indexed instance variable of the receiver.
	 This method always fails."

	<category: 'builtins'>
	SystemExceptions.NotIndexable signalOn: self
    ]

    basicAt: anIndex [
	"Answer the index-th indexed instance variable of the receiver.
	 This method always fails."

	<category: 'builtins'>
	SystemExceptions.NotIndexable signalOn: self
    ]

    at: anIndex put: value [
	"Store value in the index-th indexed instance variable of the receiver
	 This method always fails."

	<category: 'builtins'>
	SystemExceptions.NotIndexable signalOn: self
    ]

    basicAt: anIndex put: value [
	"Store value in the index-th indexed instance variable of the receiver
	 This method always fails."

	<category: 'builtins'>
	SystemExceptions.NotIndexable signalOn: self
    ]
]

