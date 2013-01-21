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

