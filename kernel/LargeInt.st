"======================================================================
|
|   LargeInteger hierarchy Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
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



Integer subclass: LargeInteger [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: '
I represent a large integer, which has to be stored as a long sequence
of bytes. I have methods to do arithmetics and comparisons, but I need
some help from my children, LargePositiveInteger and LargeNegativeInteger,
to speed them up a bit.'>

    Zero := nil.
    One := nil.
    ZeroBytes := nil.
    OneBytes := nil.
    LeadingZeros := nil.
    TrailingZeros := nil.

    LargeInteger class >> new [
	<category: 'private'>
	self shouldNotImplement
    ]

    LargeInteger class >> initialize [
	"Private - Initialize the receiver's class variables"

	<category: 'private'>
	ZeroBytes := #[0].
	OneBytes := #[1].
	Zero := LargeZeroInteger basicNew: 1.
	One := (LargePositiveInteger basicNew: 1) setBytes: OneBytes.

	"The leading zeros table is used in division and to compute
	 #highBit. It is obtained by:
	 LeadingZeros := ByteArray new: 255.
	 127 to: 1 by: -1 do: [ :i |
	 LeadingZeros at: i put: 1 + (LeadingZeros at: i + i).
	 ]."
	LeadingZeros := #[7 6 6 5 5 5 5 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0].

	"The trailing zeros table is used in the GCD algorithm. It is obtained by:
	 TrailingZeros := ByteArray new: 255.
	 2 to: 254 by: 2 do: [ :i |
	 TrailingZeros at: i put: 1 + (TrailingZeros at: i // 2).
	 ]."
	TrailingZeros := #[0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 5 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 6 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 5 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 7 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 5 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 6 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 5 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0 4 0 1 0 2 0 1 0 3 0 1 0 2 0 1 0]
    ]

    LargeInteger class >> test: selector with: a with: b [
	<category: 'private'>
	| result |
	result := a perform: selector with: b.
	a printNl.
	b printNl.
	result printNl
    ]

    LargeInteger class >> from: byteArray [
	"Private - Answer an instance of a descendant of LargeInteger representing the
	 number whose base-256 representation is in byteArray (least significant
	 byte first).
	 The answered LargeInteger has the smallest possible representation
	 (i.e. there are no spurious leading bytes set to all zeros or all ones)
	 and already belongs to the correct class, either LargePositiveInteger,
	 LargeNegativeInteger or LargeZeroInteger"

	<category: 'private'>
	| class lastSignificant byte |
	lastSignificant := byteArray size.
	
	[byte := byteArray at: lastSignificant.
	lastSignificant = 1 
	    ifTrue: 
		[byte = 0 ifTrue: [^Zero].
		false	"Leave the while loop"]
	    ifFalse: 
		["Check if the current byte is spurious AND has the same
		 sign as the previous"

		(byte = 0 or: [byte = 255]) 
		    and: [(byte bitXor: (byteArray at: lastSignificant - 1)) < 128]]] 
		whileTrue: [lastSignificant := lastSignificant - 1].
	class := (byteArray at: lastSignificant) < 128 
		    ifTrue: [LargePositiveInteger]
		    ifFalse: [LargeNegativeInteger].
	^(class basicNew: lastSignificant) setBytes: byteArray
    ]

    LargeInteger class >> fromInteger: anInteger [
	"Private - Answer an instance of a descendant of LargeInteger representing
	 the (small) Integer contained in anInteger.
	 The answered LargeInteger has the smallest possible representation
	 (i.e. there are no spurious leading bytes set to all zeros or all ones)
	 and already belongs to the correct class, either LargePositiveInteger,
	 LargeNegativeInteger or LargeZeroInteger"

	<category: 'private'>
	| bytes int |
	anInteger isInteger ifFalse: [^anInteger].
	bytes := ByteArray new: CLongSize.
	int := anInteger.
	1 to: CLongSize
	    do: 
		[:i | 
		bytes at: i put: (int bitAnd: 255).
		int := int bitShift: -8].
	^self from: bytes
    ]

    LargeInteger class >> resultFrom: byteArray [
	"Private - Answer an instance of a descendant of Integer representing the
	 number whose base-256 representation is in byteArray (least significant
	 byte first).
	 If a kind of LargeInteger is answered, it has the smallest possible
	 representation (i.e. there are no spurious leading bytes set to all zeros
	 or all ones); however it is possible that this method answers an Integer."

	<category: 'private'>
	| result accum size |
	result := self from: byteArray.
	size := result size.
	size > CLongSize ifTrue: [^result].
	size = CLongSize 
	    ifTrue: [((result at: size) between: 64 and: 191) ifTrue: [^result]].
	accum := result negative ifTrue: [-1] ifFalse: [0].
	result size to: 1
	    by: -1
	    do: [:i | accum := (accum bitShift: 8) bitOr: (result at: i)].
	^accum
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'built-ins'>
	<primitive: VMpr_String_hash>
	^0
    ]

    size [
	"Answer the number of indexed instance variable in the receiver"

	<category: 'built-ins'>
	<primitive: VMpr_Object_basicSize>
	
    ]

    digitLength [
	"Answer the number of base-256 digits in the receiver"

	<category: 'built-ins'>
	<primitive: VMpr_Object_basicSize>
	
    ]

    at: anIndex [
	"Answer the anIndex-th byte in the receiver's representation"

	<category: 'built-ins'>
	<primitive: VMpr_Object_basicAt>
	^self mostSignificantByte
    ]

    at: anIndex put: aNumber [
	"Set the anIndex-th byte in the receiver's representation"

	<category: 'built-ins'>
	<primitive: VMpr_Object_basicAtPut>
	self checkIndexableBounds: anIndex put: aNumber
    ]

    primReplaceFrom: start to: stop with: replacementString startingAt: replaceStart [
	"Private - Replace the characters from start to stop with new
	 characters contained in replacementString (which, actually, can be
	 any variable byte class), starting at the replaceStart location of
	 replacementString"

	<category: 'built-ins'>
	<primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
	^self primitiveFailed
    ]

    digitAt: anIndex [
	"Answer the index-th base-256 digit of the receiver (byte), expressed
	 in two's complement"

	<category: 'built-ins'>
	<primitive: VMpr_Object_basicAt>
	^self mostSignificantByte
    ]

    digitAt: anIndex put: aNumber [
	"Set the anIndex-th base-256 digit in the receiver's representation"

	<category: 'built-ins'>
	<primitive: VMpr_Object_basicAtPut>
	self checkIndexableBounds: anIndex put: aNumber
    ]

    asCNumber [
	"Convert the receiver to a kind of number that is understood by
	 the C call-out mechanism."
	<category: 'coercion'>
	^self
    ]

    asObject [
	"This method always fails. The number of OOPs is far less than
	 the minimum number represented with a LargeInteger."

	<category: 'disabled'>
	self primitiveFailed
    ]

    asObjectNoFail [
	<category: 'disabled'>
	^nil
    ]

    = aNumber [
	"Answer whether the receiver and aNumber identify the same number."

	<category: 'testing'>
	<primitive: VMpr_LargeInteger_eq>
	(aNumber isKindOf: Number) ifFalse: [^false].
	aNumber generality = self generality 
	    ifFalse: [^self retryEqualityCoercing: aNumber].
	self sign = aNumber sign ifFalse: [^false].
	self size = aNumber size ifFalse: [^false].
	self size to: 1
	    by: -1
	    do: [:index | (self at: index) = (aNumber at: index) ifFalse: [^false]].
	^true
    ]

    ~= aNumber [
	"Answer whether the receiver and aNumber identify different numbers."

	<category: 'testing'>
	<primitive: VMpr_LargeInteger_ne>
	(aNumber isKindOf: Number) ifFalse: [^true].
	aNumber generality = self generality 
	    ifFalse: [^self retryInequalityCoercing: aNumber].
	self sign = aNumber sign ifFalse: [^true].
	self size = aNumber size ifFalse: [^true].
	self size to: 1
	    by: -1
	    do: [:index | (self at: index) = (aNumber at: index) ifFalse: [^true]].
	^false
    ]

    < aNumber [
	"Answer whether the receiver is smaller than aNumber"

	<category: 'testing'>
	<primitive: VMpr_LargeInteger_lt>
	aNumber generality = self generality 
	    ifFalse: [^self retryRelationalOp: #< coercing: aNumber].
	self sign < aNumber sign ifTrue: [^true].
	self sign > aNumber sign ifTrue: [^false].
	self size > aNumber size ifTrue: [^self sign = -1].
	aNumber size to: 1
	    by: -1
	    do: 
		[:index | 
		(self at: index) < (aNumber at: index) ifTrue: [^true].
		(self at: index) > (aNumber at: index) ifTrue: [^false]].
	^false
    ]

    <= aNumber [
	"Answer whether the receiver is smaller than aNumber or equal to it"

	<category: 'testing'>
	<primitive: VMpr_LargeInteger_le>
	aNumber generality = self generality 
	    ifFalse: [^self retryRelationalOp: #<= coercing: aNumber].
	self sign < aNumber sign ifTrue: [^true].
	self sign > aNumber sign ifTrue: [^false].
	self size > aNumber size ifTrue: [^self sign = -1].
	aNumber size to: 1
	    by: -1
	    do: 
		[:index | 
		(self at: index) < (aNumber at: index) ifTrue: [^true].
		(self at: index) > (aNumber at: index) ifTrue: [^false]].
	^true
    ]

    > aNumber [
	"Answer whether the receiver is greater than aNumber"

	<category: 'testing'>
	<primitive: VMpr_LargeInteger_gt>
	aNumber generality = self generality 
	    ifFalse: [^self retryRelationalOp: #> coercing: aNumber].
	aNumber sign < self sign ifTrue: [^true].
	aNumber sign > self sign ifTrue: [^false].
	aNumber size > self size ifTrue: [^self sign = -1].
	self size to: 1
	    by: -1
	    do: 
		[:index | 
		(aNumber at: index) < (self at: index) ifTrue: [^true].
		(aNumber at: index) > (self at: index) ifTrue: [^false]].
	^false
    ]

    >= aNumber [
	"Answer whether the receiver is greater than aNumber or equal to it"

	<category: 'testing'>
	<primitive: VMpr_LargeInteger_ge>
	aNumber generality = self generality 
	    ifFalse: [^self retryRelationalOp: #>= coercing: aNumber].
	aNumber sign < self sign ifTrue: [^true].
	aNumber sign > self sign ifTrue: [^false].
	aNumber size > self size ifTrue: [^self sign = -1].
	self size to: 1
	    by: -1
	    do: 
		[:index | 
		(aNumber at: index) < (self at: index) ifTrue: [^true].
		(aNumber at: index) > (self at: index) ifTrue: [^false]].
	^true
    ]

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	self subclassResponsibility
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	<category: 'arithmetic'>
	self subclassResponsibility
    ]

    * aNumber [
	"Multiply aNumber and the receiver, answer the result"

	<category: 'arithmetic'>
	| result |
	<primitive: VMpr_LargeInteger_times>
	aNumber sign = 0 ifTrue: [^0].
	aNumber generality = self generality 
	    ifFalse: [^self retryMultiplicationCoercing: aNumber].
	result := self abs multiply: aNumber abs.
	^self sign = aNumber sign ifTrue: [result] ifFalse: [result negated]
    ]

    / aNumber [
	"Divide aNumber and the receiver, answer the result (an Integer or
	 Fraction)"

	<category: 'arithmetic'>
	| gcd |
	aNumber sign = 0 ifTrue: [^self zeroDivide].
	self sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retryDivisionCoercing: aNumber].
	gcd := self gcd: aNumber.
	gcd = self 
	    ifTrue: [^Fraction numerator: 1 denominator: (aNumber divExact: gcd)].
	gcd = aNumber ifTrue: [^self divExact: gcd].
	^Fraction numerator: (self divExact: gcd)
	    denominator: (aNumber divExact: gcd)
    ]

    // aNumber [
	"Divide aNumber and the receiver, answer the result truncated towards
	 -infinity"

	<category: 'arithmetic'>
	<primitive: VMpr_LargeInteger_intDiv>
	aNumber sign = 0 ifTrue: [^self zeroDivide].
	self sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #// coercing: aNumber].
	self sign = aNumber sign 
	    ifFalse: [^self - aNumber + aNumber sign quo: aNumber].
	^self abs divide: aNumber abs
	    using: [:quo :rem :remNotZero | self species resultFrom: quo]
    ]

    rem: aNumber [
	"Divide aNumber and the receiver, answer the remainder truncated
	 towards 0"

	<category: 'arithmetic'>
	| result |
	<primitive: VMpr_LargeInteger_rem>
	aNumber sign = 0 ifTrue: [^self zeroDivide].
	self sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #rem: coercing: aNumber].
	^self abs divide: aNumber abs
	    using: [:quo :rem :remNotZero | self species resultFrom: rem]
    ]

    quo: aNumber [
	"Divide aNumber and the receiver, answer the result truncated
	 towards 0"

	<category: 'arithmetic'>
	| result |
	<primitive: VMpr_LargeInteger_quo>
	aNumber sign = 0 ifTrue: [^self zeroDivide].
	self sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #quo: coercing: aNumber].
	result := self abs divide: aNumber abs
		    using: [:quo :rem :remNotZero | self species resultFrom: quo].
	^self sign = aNumber sign ifTrue: [result] ifFalse: [result negated]
    ]

    divExact: aNumber [
	"Dividing receiver by arg assuming that the remainder is zero, and answer
	 the result"

	<category: 'arithmetic'>
	| result |
	<primitive: VMpr_LargeInteger_divExact>
	aNumber sign = 0 
	    ifTrue: 
		["Same as quo:, not worthwhile to implement it in Smalltalk."

		^self zeroDivide].
	self sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #divExact: coercing: aNumber].
	result := self abs divide: aNumber abs
		    using: [:quo :rem :remNotZero | self species resultFrom: quo].
	^self sign = aNumber sign ifTrue: [result] ifFalse: [result negated]
    ]

    \\ aNumber [
	"Divide aNumber and the receiver, answer the remainder truncated
	 towards -infinity"

	<category: 'arithmetic'>
	<primitive: VMpr_LargeInteger_modulo>
	aNumber sign = 0 ifTrue: [^self zeroDivide].
	self sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #\\ coercing: aNumber].
	aNumber sign < 0 ifTrue: [^(self negated \\ aNumber negated) negated].
	^self abs divide: aNumber
	    using: 
		[:quo :rem :remNotZero | 
		"must be positive"

		| remInteger |
		remInteger := self species resultFrom: rem.
		(remNotZero and: [self negative]) 
		    ifTrue: [aNumber - remInteger]
		    ifFalse: [remInteger]]
    ]

    estimatedLog [
	"Answer an estimate of (self abs floorLog: 10)"

	<category: 'arithmetic'>
	^(self size asFloatD * 8.0 / FloatD log10Base2) ceiling
    ]

    negated [
	"Answer the receiver's negated"

	<category: 'arithmetic'>
	| newBytes carry a |
	<primitive: VMpr_LargeInteger_negated>
	newBytes := ByteArray new: self size + 1.
	carry := 256.
	1 to: self size
	    do: 
		[:index | 
		a := carry - (self at: index).
		a < 256 
		    ifTrue: [carry := 255]
		    ifFalse: 
			[carry := 256.
			a := a - 256].
		newBytes at: index put: a].
	newBytes at: newBytes size put: (self mostSignificantByte bitXor: 255).
	^self species resultFrom: newBytes
    ]

    lowBit [
	"Return the index of the lowest order 1 bit of the receiver."

	<category: 'bit operations'>
	| each |
	1 to: self size
	    do: 
		[:index | 
		(each := self digitAt: index) = 0 
		    ifFalse: [^index * 8 - 7 + (TrailingZeros at: each)]].
	^self highBit
    ]

    bitAnd: aNumber [
	"Answer the receiver ANDed with aNumber"

	<category: 'bit operations'>
	| newBytes |
	<primitive: VMpr_LargeInteger_bitAnd>
	aNumber isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: aNumber mustBe: Integer].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #bitAnd: coercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size).
	1 to: newBytes size
	    do: [:index | newBytes at: index put: ((self at: index) bitAnd: (aNumber at: index))].
	^self species resultFrom: newBytes
    ]

    bitAt: aNumber [
	"Answer the aNumber-th bit in the receiver, where the LSB is 1"

	<category: 'bit operations'>
	| bit |
	bit := aNumber - 1.
	^(self at: bit // 8 + 1) bitAt: bit \\ 8 + 1
    ]

    bitInvert [
	"Answer the receiver's 1's complement"

	<category: 'bit operations'>
	| bytes |
	<primitive: VMpr_LargeInteger_bitInvert>
	bytes := ByteArray new: self size + 1.
	bytes at: bytes size put: (self mostSignificantByte bitXor: 255).
	1 to: self size
	    do: [:index | bytes at: index put: ((self at: index) bitXor: 255)].
	^self species resultFrom: bytes
    ]

    bitOr: aNumber [
	"Answer the receiver ORed with aNumber"

	<category: 'bit operations'>
	| newBytes |
	<primitive: VMpr_LargeInteger_bitOr>
	aNumber isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: aNumber mustBe: Integer].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #bitOr: coercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size).
	1 to: newBytes size
	    do: [:index | newBytes at: index put: ((self at: index) bitOr: (aNumber at: index))].
	^self species resultFrom: newBytes
    ]

    bitXor: aNumber [
	"Answer the receiver XORed with aNumber"

	<category: 'bit operations'>
	| newBytes |
	<primitive: VMpr_LargeInteger_bitXor>
	aNumber isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: aNumber mustBe: Integer].
	aNumber generality = self generality 
	    ifFalse: [^self retry: #bitXor: coercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size).
	1 to: newBytes size
	    do: [:index | newBytes at: index put: ((self at: index) bitXor: (aNumber at: index))].
	^self species resultFrom: newBytes
    ]

    bitShift: aNumber [
	"Answer the receiver shifted by aNumber places"

	<category: 'bit operations'>
	<primitive: VMpr_LargeInteger_bitShift>
	aNumber isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: aNumber mustBe: Integer].
	^aNumber > 0 
	    ifTrue: [self basicLeftShift: aNumber]
	    ifFalse: [self basicRightShift: aNumber negated]
    ]

    raisedToInteger: n [
	"Return self raised to the anInteger-th power"

	"For LargeIntegers only, it pays off to strip the rightmost
	 0 bits and put them back later with a left shift..."

	<category: 'accessing'>
	| nbit |
	nbit := 1.
	[(self bitAt: nbit) = 0] whileTrue: [nbit := nbit + 1].
	nbit = 1 ifTrue: [^super raisedToInteger: n].
	nbit := nbit - 1.
	^((self bitShift: nbit negated) raisedToInteger: n) bitShift: nbit * n
    ]

    basicLeftShift: totalShift [
	"Private - Left shift the receiver by aNumber places"

	<category: 'primitive operations'>
	| newBytes byteShift carry shift a |
	byteShift := totalShift // 8.
	shift := totalShift bitAnd: 7.
	newBytes := ByteArray new: (totalShift + 7) // 8 + self size.

	"That `+ 1' in the #to:do: performs an extra iteration that stores the
	 last carry in the extra byte reserved in the previous statement"
	carry := 0.
	1 to: newBytes size - byteShift
	    do: 
		[:index | 
		a := ((self at: index) bitShift: shift) + carry.
		carry := a bitShift: -8.
		a := a bitAnd: 255.
		newBytes at: index + byteShift put: a].
	^self species resultFrom: newBytes
    ]

    basicRightShift: totalShift [
	"Private - Right shift the receiver by 'shift' places"

	<category: 'primitive operations'>
	| shift newBytes byteShift carryShift x a |
	byteShift := totalShift // 8.
	shift := (totalShift bitAnd: 7) negated.
	carryShift := 8 + shift.
	self size <= (byteShift - 1) ifTrue: [^0].
	newBytes := ByteArray new: self size - byteShift + 1.
	x := (self at: byteShift + 1) bitShift: shift.
	byteShift + 1 to: self size
	    do: 
		[:j | 
		a := self at: j + 1.
		newBytes at: j - byteShift put: ((a bitShift: carryShift) bitAnd: 255) + x.
		x := a bitShift: shift].
	newBytes at: newBytes size put: self mostSignificantByte.
	^self species resultFrom: newBytes
    ]

    largeNegated [
	"Private - Same as negated, but always answer a LargeInteger"

	<category: 'primitive operations'>
	| newBytes carry a |
	newBytes := ByteArray new: self size + 1.
	carry := 256.
	1 to: self size
	    do: 
		[:index | 
		a := carry - (self at: index).
		a < 256 
		    ifTrue: [carry := 255]
		    ifFalse: 
			[carry := 256.
			a := a - 256].
		newBytes at: index put: a].
	newBytes at: newBytes size put: (self mostSignificantByte bitXor: 255).
	^self species from: newBytes
    ]

    zero [
	"Coerce 0 to the receiver's class"

	<category: 'coercion'>
	^Zero
    ]

    unity [
	"Coerce 1 to the receiver's class"

	<category: 'coercion'>
	^One
    ]

    coerce: aNumber [
	"Truncate the number; if needed, convert it to LargeInteger
	 representation."

	<category: 'coercion'>
	aNumber = 0 ifTrue: [^Zero].
	^aNumber isInteger 
	    ifTrue: [self species fromInteger: aNumber]
	    ifFalse: [self species fromInteger: aNumber truncated]
    ]

    generality [
	"Answer the receiver's generality"

	<category: 'coercion'>
	^200
    ]

    mostSignificantByte [
	"Private - Answer the value of the most significant byte"

	<category: 'private'>
	self subclassResponsibility
    ]

    species [
	<category: 'private'>
	^LargeInteger
    ]

    bytes [
	<category: 'private'>
	| bytes |
	bytes := ByteArray new: self size + 1.
	bytes 
	    replaceFrom: 1
	    to: self size
	    with: self
	    startingAt: 1.
	bytes at: bytes size put: self mostSignificantByte.
	^bytes
    ]

    setBytes: aByteArray [
	<category: 'private'>
	self 
	    primReplaceFrom: 1
	    to: self size
	    with: aByteArray
	    startingAt: 1
    ]
]



LargeInteger subclass: LargeNegativeInteger [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: '
Just like my brother LargePositiveInteger, I provide a few methods that
allow LargeInteger to determine the sign of a large integer in a fast way
during its calculations. For example, I know that I am smaller than any
LargePositiveInteger'>

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	"All we have to do is convert the two numbers to two positive
	 numbers and make LargePositiveInteger do the calculation.
	 Use #largeNegated to save some coercions."

	<category: 'reverting to LargePositiveInteger'>
	<primitive: VMpr_LargeInteger_plus>
	aNumber sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retrySumCoercing: aNumber].
	^aNumber sign = -1 
	    ifTrue: [(self largeNegated + aNumber largeNegated) negated]
	    ifFalse: [(self largeNegated - aNumber) negated]
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	"All we have to do is convert the two numbers to two positive
	 numbers and make LargePositiveInteger do the calculation.
	 Use #largeNegated to save some coercions."

	<category: 'reverting to LargePositiveInteger'>
	<primitive: VMpr_LargeInteger_minus>
	aNumber sign = 0 ifTrue: [^self].
	aNumber generality = self generality 
	    ifFalse: [^self retryDifferenceCoercing: aNumber].
	^aNumber sign = -1 
	    ifTrue: [(self largeNegated - aNumber largeNegated) negated]
	    ifFalse: [(self largeNegated + aNumber) negated]
    ]

    highBit [
	"Answer the receiver's highest bit's index"

	<category: 'reverting to LargePositiveInteger'>
	^(self at: self size) = 255 
	    ifTrue: [^8 * self size - 16 + ((self at: self size - 1) - 256) highBit]
	    ifFalse: [^8 * self size - 8 + ((self at: self size) - 256) highBit]
    ]

    gcd: anInteger [
	"Return the greatest common divisor between the receiver and anInteger"

	<category: 'reverting to LargePositiveInteger'>
	<primitive: VMpr_LargeInteger_gcd>
	^self negated gcd: anInteger abs
    ]

    positive [
	"Answer whether the receiver is >= 0"

	<category: 'numeric testing'>
	^false
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'numeric testing'>
	^false
    ]

    negative [
	"Answer whether the receiver is < 0"

	<category: 'numeric testing'>
	^true
    ]

    abs [
	"Answer the receiver's absolute value."

	"This is surely a large integer (while `aLargePositiveInteger negated'
	 might be the smallest small integer)."

	<category: 'numeric testing'>
	<primitive: VMpr_LargeInteger_negated>
	^self largeNegated
    ]

    sign [
	"Answer the receiver's sign"

	<category: 'numeric testing'>
	^-1
    ]

    asFloatD [
	"Answer the receiver converted to a FloatD"

	<category: 'converting'>
	^self negated asFloatD negated
    ]

    asFloatE [
	"Answer the receiver converted to a FloatE"

	<category: 'converting'>
	^self negated asFloatE negated
    ]

    asFloatQ [
	"Answer the receiver converted to a FloatQ"

	<category: 'converting'>
	^self negated asFloatQ negated
    ]

    mostSignificantByte [
	"Private - Answer the value of the most significant byte"

	<category: 'private'>
	^255
    ]
]



LargeInteger subclass: LargePositiveInteger [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: '
Just like my brother LargeNegativeInteger, I provide a few methods that
allow LargeInteger to determine the sign of a large integer in a fast way
during its calculations.  For example, I know that I am larger than any
LargeNegativeInteger.  In addition I implement the guts of arbitrary
precision arithmetic.'>

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	| newBytes carry a b result |
	<primitive: VMpr_LargeInteger_plus>
	aNumber sign = 0 ifTrue: [^self].
	aNumber sign = -1 ifTrue: [^self - aNumber negated].
	aNumber generality = self generality 
	    ifFalse: [^self retrySumCoercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size) + 1.
	carry := 0.
	1 to: newBytes size - 1
	    do: 
		[:index | 
		result := (self at: index) + (aNumber at: index) + carry.
		result > 255 
		    ifTrue: 
			[carry := 1.
			result := result - 256]
		    ifFalse: [carry := 0].
		newBytes at: index put: result].
	newBytes at: newBytes size put: carry.
	^LargeInteger resultFrom: newBytes
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	<category: 'arithmetic'>
	| newBytes carry a b result |
	<primitive: VMpr_LargeInteger_minus>
	aNumber sign = 0 ifTrue: [^self].
	aNumber sign = -1 ifTrue: [^self + aNumber negated].
	aNumber generality = self generality 
	    ifFalse: [^self retryDifferenceCoercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size) + 1.
	carry := 0.
	1 to: newBytes size - 1
	    do: 
		[:index | 
		result := (self at: index) - (aNumber at: index) + carry.
		result < 0 
		    ifTrue: 
			[carry := -1.
			result := result + 256]
		    ifFalse: [carry := 0].
		newBytes at: index put: result].
	newBytes at: newBytes size put: (carry bitAnd: 255).
	^LargeInteger resultFrom: newBytes
    ]

    gcd: anInteger [
	"Calculate the GCD between the receiver and anInteger"

	"Binary GCD - See Knuth `Seminumerical algorithms', Vol 2, 4.5.2
	 It was adapted to remove the variable `r' and to only work with
	 unsigned numbers"

	<category: 'arithmetic'>
	| adjust t tmp u v |
	<primitive: VMpr_LargeInteger_gcd>
	(self sign bitAnd: anInteger sign) = 0 ifTrue: [^self + anInteger].
	u := self bytes.
	v := anInteger abs.
	v generality = self generality ifFalse: [v := self coerce: v].
	v := v bytes.

	"Divide u and v by 2 as long as they are both even"
	adjust := t := self bytesTrailingZeros: u.
	self bytesRightShift: u big: t.
	adjust := adjust min: (t := self bytesTrailingZeros: v).
	self bytesRightShift: v big: t.
	u size = v size 
	    ifFalse: 
		[u size < v size 
		    ifTrue: [u := u copyGrowTo: v size]
		    ifFalse: [v := v copyGrowTo: u size]].

	"Well, this is it -- the stuff up to this point was just set up"
	
	[t := self 
		    bytes: u
		    from: 1
		    compare: v.
	t = 0] 
		whileFalse: 
		    [t < 0 
			ifTrue: 
			    [t := v.
			    v := u.
			    u := t].
		    self 
			bytes: u
			from: 1
			subtract: v.
		    ((u at: 1) bitAnd: 1) = 0 
			ifTrue: 
			    [t := self bytesTrailingZeros: u.
			    self bytesRightShift: u big: t]].
	self bytesLeftShift: u big: adjust.
	^self species resultFrom: u
    ]

    highBit [
	"Answer the receiver's highest bit's index"

	<category: 'arithmetic'>
	^(self at: self size) = 0 
	    ifTrue: [^8 * self size - 8 - (LeadingZeros at: (self at: self size - 1))]
	    ifFalse: [^8 * self size - (LeadingZeros at: (self at: self size))]
    ]

    positive [
	"Answer whether the receiver is >= 0"

	<category: 'numeric testing'>
	^true
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'numeric testing'>
	^true
    ]

    negative [
	"Answer whether the receiver is < 0"

	<category: 'numeric testing'>
	^false
    ]

    abs [
	"Answer the receiver's absolute value"

	<category: 'numeric testing'>
	^self
    ]

    sign [
	"Answer the receiver's sign"

	<category: 'numeric testing'>
	^1
    ]

    asFloat: characterization [
	"Answer the receiver converted to a Float"

	<category: 'private'>
	"Check for number bigger than maximum mantissa"

	| nTruncatedBits mantissa exponent mask trailingBits inexact carry |
	nTruncatedBits := self highBit - characterization precision.
	nTruncatedBits <= 0 ifTrue: [^self fastAsFloat: characterization].
	mantissa := self bitShift: nTruncatedBits negated.
	exponent := nTruncatedBits.

	"Apply IEEE 754 round to nearest even default rounding mode"
	carry := self bitAt: nTruncatedBits.
	(carry = 1 and: [mantissa odd or: [self lowBit < nTruncatedBits]]) 
	    ifTrue: [mantissa := mantissa + 1].
	^(characterization coerce: mantissa) timesTwoPower: exponent
    ]

    fastAsFloat: characterization [
	"Conversion can be exact, construct Float by successive mul add operations"

	<category: 'private'>
	| result byte |
	byte := characterization coerce: 256.
	result := characterization coerce: 0.
	self size to: 1
	    by: -1
	    do: [:index | result := result * byte + (self at: index)].
	^result
    ]

    mostSignificantByte [
	"Private - Answer the value of the most significant byte"

	<category: 'private'>
	^0
    ]

    asFloatD [
	"Answer the receiver converted to a FloatD"

	<category: 'converting'>
	<primitive: VMpr_LargeInteger_asFloatD>
	^self asFloat: FloatD
    ]

    asFloatE [
	"Answer the receiver converted to a FloatE"

	<category: 'converting'>
	<primitive: VMpr_LargeInteger_asFloatE>
	^self asFloat: FloatE
    ]

    asFloatQ [
	"Answer the receiver converted to a FloatQ"

	<category: 'converting'>
	<primitive: VMpr_LargeInteger_asFloatQ>
	^self asFloat: FloatQ
    ]

    replace: str withStringBase: radix [
	"Return in a String str the base radix representation of the
	 receiver."

	<category: 'converting'>
	| digits source quo t rem where |
	source := self.
	quo := ByteArray new: self size.
	where := str size.
	self size to: 1
	    by: -1
	    do: 
		[:i | 
		
		[rem := 0.
		i to: 1
		    by: -1
		    do: 
			[:j | 
			t := (rem bitShift: 8) + (source at: j).
			quo at: j put: t // radix.
			rem := t \\ radix].
		str at: where put: (Character digitValue: rem).
		where := where - 1.
		source := quo.
		(source at: i) = 0] 
			whileFalse].
	^str
    ]

    isSmall [
	"Private - Answer whether the receiver is small enough to employ simple
	 scalar algorithms for division and multiplication"

	<category: 'primitive operations'>
	^self size <= 2 and: [(self at: 2) = 0]
    ]

    divide: aNumber using: aBlock [
	"Private - Divide the receiver by aNumber (unsigned division). Evaluate
	 aBlock passing the result ByteArray, the remainder ByteArray, and
	 whether the division had a remainder"

	<category: 'primitive operations'>
	| result a b |
	aNumber isSmall 
	    ifTrue: 
		[result := ByteArray new: self size.
		b := 0.
		self size to: 1
		    by: -1
		    do: 
			[:j | 
			a := (b bitShift: 8) + (self at: j).
			result at: j put: a // (aNumber at: 1).
			b := a \\ (aNumber at: 1)].
		^aBlock 
		    value: result
		    value: (ByteArray with: b with: 0)
		    value: b ~= 0].

	"special case: numerator < denominator"
	self size < aNumber size 
	    ifTrue: 
		[^aBlock 
		    value: ZeroBytes
		    value: self
		    value: true].
	self size > aNumber size 
	    ifTrue: 
		[result := self primDivide: aNumber.
		^aBlock 
		    value: result key
		    value: result value
		    value: (result value anySatisfy: [:each | each ~= 0])].
	self size to: 1
	    by: -1
	    do: 
		[:index | 
		a := self at: index.
		b := aNumber at: index.
		b > a 
		    ifTrue: 
			[^aBlock 
			    value: ZeroBytes
			    value: self
			    value: true].
		a > b 
		    ifTrue: 
			[result := self primDivide: aNumber.
			^aBlock 
			    value: result key
			    value: result value
			    value: (result value anySatisfy: [:each | each ~= 0])]].
	"Special case: numerator = denominator"
	^aBlock 
	    value: OneBytes
	    value: ZeroBytes
	    value: false
    ]

    multiply: aNumber [
	"Private - Multiply the receiver by aNumber (unsigned multiply)"

	<category: 'primitive operations'>
	"Special case - other factor < 255"

	| newBytes byte carry index digit start |
	aNumber isSmall 
	    ifTrue: 
		[^self species from: (self bytes: self bytes multiply: (aNumber at: 1))].
	start := 1.
	[(aNumber at: start) = 0] whileTrue: [start := start + 1].
	newBytes := ByteArray new: self size + aNumber size + 2.
	1 to: self size
	    do: 
		[:indexA | 
		digit := self at: indexA.
		digit = 0 
		    ifFalse: 
			[carry := 0.
			index := indexA + start - 1.
			start to: aNumber size
			    do: 
				[:indexB | 
				byte := digit * (aNumber at: indexB) + carry + (newBytes at: index).
				carry := byte bitShift: -8.
				newBytes at: index put: (byte bitAnd: 255).
				index := index + 1].
			newBytes at: indexA + aNumber size put: carry]].
	"If I multiply two large integers, the result is large, so use #from:..."
	^self species from: newBytes
    ]

    bytes: bytes multiply: anInteger [
	"Private - Multiply the bytes in bytes by anInteger, which must be < 255.
	 Put the result back in bytes."

	<category: 'helper byte-level methods'>
	| byte carry |
	carry := 0.
	1 to: bytes size
	    do: 
		[:index | 
		byte := (bytes at: index) * anInteger + carry.
		carry := byte bitShift: -8.
		bytes at: index put: (byte bitAnd: 255)].
	carry > 0 ifTrue: [bytes at: bytes size - 1 put: carry].
	^bytes
    ]

    bytes: byteArray1 from: j compare: byteArray2 [
	"Private - Answer the sign of byteArray2 - byteArray1; the
	 j-th byte of byteArray1 is compared with the first of byteArray2,
	 the j+1-th with the second, and so on."

	<category: 'helper byte-level methods'>
	| a b i |
	i := byteArray2 size.
	j + byteArray2 size - 1 to: j
	    by: -1
	    do: 
		[:index | 
		b := byteArray2 at: i.
		a := byteArray1 at: index.
		a < b ifTrue: [^-1].
		a > b ifTrue: [^1].
		i := i - 1].
	^0
    ]

    bytes: byteArray1 from: j subtract: byteArray2 [
	"Private - Sutract the bytes in byteArray2 from those in byteArray1"

	<category: 'helper byte-level methods'>
	| carry a i |
	carry := 256.
	i := 1.
	j to: j + byteArray2 size - 1
	    do: 
		[:index | 
		a := (byteArray1 at: index) - (byteArray2 at: i) + carry.
		a < 256 
		    ifTrue: [carry := 255]
		    ifFalse: 
			[carry := 256.
			a := a - 256].
		byteArray1 at: index put: a.
		i := i + 1]
    ]

    bytesLeftShift: aByteArray [
	"Private - Left shift by 1 place the bytes in aByteArray"

	<category: 'helper byte-level methods'>
	| carry a |
	carry := 0.
	1 to: aByteArray size
	    do: 
		[:index | 
		a := aByteArray at: index.
		a := a + a + carry.
		carry := a bitShift: -8.
		a := a bitAnd: 255.
		aByteArray at: index put: a]
    ]

    bytesLeftShift: aByteArray n: shift [
	"Private - Left shift by shift places the bytes in aByteArray
	 (shift <= 7)"

	<category: 'helper byte-level methods'>
	| carry a |
	carry := 0.
	1 to: aByteArray size
	    do: 
		[:index | 
		a := aByteArray at: index.
		a := (a bitShift: shift) + carry.
		carry := a bitShift: -8.
		aByteArray at: index put: (a bitAnd: 255)]
    ]

    bytesLeftShift: aByteArray big: totalShift [
	"Private - Left shift the bytes in aByteArray by totalShift places"

	<category: 'helper byte-level methods'>
	| newBytes byteShift shift a last |
	totalShift = 0 ifTrue: [^self].
	byteShift := totalShift // 8.
	shift := totalShift bitAnd: 7.
	last := 0.
	aByteArray size - 1 to: byteShift + 1
	    by: -1
	    do: 
		[:index | 
		a := aByteArray at: index - byteShift.
		a := a bitShift: shift.
		aByteArray at: index + 1 put: last + (a bitShift: -8).
		last := a bitAnd: 255].
	aByteArray at: byteShift + 1 put: last.
	1 to: byteShift do: [:i | aByteArray at: i put: 0]
    ]

    bytesRightShift: aByteArray big: totalShift [
	"Private - Right shift the bytes in aByteArray by totalShift places"

	<category: 'helper byte-level methods'>
	| shift byteShift carryShift x a |
	totalShift = 0 ifTrue: [^self].
	byteShift := totalShift // 8.
	shift := (totalShift bitAnd: 7) negated.
	carryShift := 8 + shift.
	x := (aByteArray at: byteShift + 1) bitShift: shift.
	byteShift + 2 to: aByteArray size
	    do: 
		[:j | 
		a := aByteArray at: j.
		aByteArray at: j - byteShift - 1
		    put: ((a bitShift: carryShift) bitAnd: 255) + x.
		x := a bitShift: shift].
	aByteArray at: aByteArray size - byteShift put: x.
	aByteArray size - byteShift + 1 to: aByteArray size
	    do: [:i | aByteArray at: i put: 0]
    ]

    bytesRightShift: bytes n: aNumber [
	"Private - Right shift the bytes in `bytes' by 'aNumber' places
	 (shift <= 7)"

	<category: 'helper byte-level methods'>
	| shift carryShift x a |
	aNumber = 0 ifTrue: [^self].
	shift := aNumber negated.
	carryShift := 8 + shift.
	x := (bytes at: 1) bitShift: shift.
	2 to: bytes size
	    do: 
		[:j | 
		a := bytes at: j.
		bytes at: j - 1 put: ((a bitShift: carryShift) bitAnd: 255) + x.
		x := a bitShift: shift].
	bytes at: bytes size put: x
    ]

    bytesTrailingZeros: bytes [
	"Private - Answer the number of trailing zero bits in the receiver"

	<category: 'helper byte-level methods'>
	| each |
	1 to: bytes size
	    do: 
		[:index | 
		(each := bytes at: index) = 0 
		    ifFalse: [^index * 8 - 8 + (TrailingZeros at: each)]].
	^bytes size * 8
    ]

    primDivide: rhs [
	"Private - Implements Knuth's divide and correct algorithm from
	 `Seminumerical Algorithms' 3rd Edition, section 4.3.1 (which
	 is basically an enhanced version of the divide `algorithm' for
	 two-digit divisors which is taught in primary school!!!)"

	<category: 'helper byte-level methods'>
	"Leading zeros in `v'"

	"Cached v at: n, v at: n - 1, j + n, j + n - 1"

	"Cached `u size - v size' and `v size'"

	"High 2 bytes of `u'"

	"guess times the divisor (v)"

	"Quotient"

	"guess at the quotient byte and remainder"

	"The operands"

	"0. Initialize everything"

	| d vn vn1 jn jn1 m n high sub q guess rem u v |
	u := self bytes.
	v := rhs bytes.
	n := v size.
	sub := ByteArray new: n.
	m := u size - n.
	q := ByteArray new: m + 2.

	"1. Normalize the divisor
	 Knuth's algorithm is based on an initial guess for the quotient. The
	 guess is guaranteed to be no more than 2 in error, if v[n] >= 128.
	 If we multiply both vectors by the same value, the result of division
	 remains the same, so we can always guarantee that v[n] is
	 sufficiently large.
	 While the algorithm calls for d to be 255 / v[n], we will set d to a
	 simple left shift count because this is fast and nicely approximates that"
	[(v at: n) = 0] whileTrue: [n := n - 1].
	(v at: n) < 128 
	    ifFalse: [d := 0]
	    ifTrue: 
		["Multiply each value by the normalizing value"

		d := LeadingZeros at: (v at: n).
		self bytesLeftShift: u n: d.
		self bytesLeftShift: v n: d].
	vn := v at: n.	"Cache common values"
	vn1 := v at: n - 1.
	m + 1 to: 1
	    by: -1
	    do: 
		[:j | 
		jn := j + n.
		jn1 := jn - 1.

		"2. Calculate the quotient `guess'.
		 Remember that our guess will be generated such that
		 guess - 2 <= quotient <= guess.  Thus, we generate our first
		 guess at quotient, and keep decrementing by one until we have found
		 the real quotient."
		high := (u at: jn) * 256 + (u at: jn1).
		guess := high // vn.
		rem := high \\ vn.
		"(Array with: u with: high with: guess with: rem) printNl."

		"4. We know now that the quotient guess is most likely ok, but possibly
		 the real quotient is guess - 1 or guess - 2.  Multiply the divisor by the
		 guess and compare the result with the dividend."
		sub 
		    replaceFrom: 1
		    to: sub size
		    with: v
		    startingAt: 1.
		self bytes: sub multiply: guess.
		[(self 
		    bytes: u
		    from: j
		    compare: sub) >= 0] 
		    whileFalse: 
			["Our guess was one off, so we need to readjust it by one and subtract
			 back the divisor (since we multiplied by one in excess)."

			guess := guess - 1.
			self 
			    bytes: sub
			    from: 1
			    subtract: v].
		"(Array with: u with: sub with: guess with: rem) printNl."

		"Got another byte of the quotient"
		self 
		    bytes: u
		    from: j
		    subtract: sub.
		q at: j put: guess].
	"Readjust the remainder"
	self bytesRightShift: u n: d.
	^q -> u
    ]
]



LargePositiveInteger subclass: LargeZeroInteger [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: '
I am quite a strange class. Indeed, the concept of a "large integer"
that is zero is a weird one. Actually my only instance is zero but
is represented like LargeIntegers, has the same generality as
LargeIntegers, and so on. That only instance is stored in the class
variable Zero, and is used in arithmetical methods, when we have to
coerce a parameter that is zero.'>

    size [
	<category: 'accessing'>
	^0
    ]

    hash [
	<category: 'accessing'>
	^0
    ]

    at: anIndex [
	<category: 'accessing'>
	^0
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'numeric testing'>
	^false
    ]

    sign [
	"Answer the receiver's sign"

	<category: 'numeric testing'>
	^0
    ]

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	^aNumber
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	<category: 'arithmetic'>
	^aNumber negated
    ]

    * aNumber [
	"Multiply aNumber and the receiver, answer the result"

	<category: 'arithmetic'>
	^0
    ]

    / aNumber [
	"Divide aNumber and the receiver, answer the result (an Integer or
	 Fraction)"

	<category: 'arithmetic'>
	^0
    ]

    // aNumber [
	"Divide aNumber and the receiver, answer the result truncated towards
	 -infinity"

	<category: 'arithmetic'>
	^0
    ]

    rem: aNumber [
	"Divide aNumber and the receiver, answer the remainder truncated
	 towards 0"

	<category: 'arithmetic'>
	^0
    ]

    quo: aNumber [
	"Divide aNumber and the receiver, answer the result truncated
	 towards 0"

	<category: 'arithmetic'>
	^0
    ]

    \\ aNumber [
	"Divide aNumber and the receiver, answer the remainder truncated
	 towards -infinity"

	<category: 'arithmetic'>
	^0
    ]

    replace: str withStringBase: radix [
	"Return in a string the base radix representation of the receiver."

	<category: 'printing'>
	str at: str size put: $0.
	^str
    ]
]

