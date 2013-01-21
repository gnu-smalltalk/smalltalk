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
