"======================================================================
|
|   FloatD Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2009 Free Software Foundation, Inc.
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



Float subclass: FloatD [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: 'My instances represent floating point numbers that have the same
accuracy as C''s "double" numbers.'>

    FloatD class >> coerce: aNumber [
	"Answer aNumber converted to a FloatD"

	<category: 'converting'>
	^aNumber asFloatD
    ]

    FloatD class >> signByte [
	"Answer the byte of the receiver that contains the sign bit"

	<category: 'byte-order dependencies'>
	^##(| n k |
	n := -2.0.
	1 to: n size do: [:i | (n at: i) >= 128 ifTrue: [k := i]].
	k)
    ]

    FloatD class >> fromBytes: aByteArray [
	"Answer a float with the bytes in aByteArray, which are in
	 big-endian format."

	<category: 'byte-order dependencies'>
	| b permutation |
	permutation := ##(| signByte perm |
	    signByte := FloatD signByte.
	    signByte = 1 ifTrue: [ perm := #[1 2 3 4 5 6 7 8] ].
	    signByte = 4 ifTrue: [ perm := #[4 3 2 1 8 7 6 5] ].
	    signByte = 5 ifTrue: [ perm := #[5 6 7 8 1 2 3 4] ].
	    signByte = 8 ifTrue: [ perm := #[8 7 6 5 4 3 2 1] ].
	    perm).
	b := FloatD new: 8.
	1 to: 8 do: [ :i |
	    b at: i put: (aByteArray at: (permutation at: i)) ].
	b makeReadOnly: true.
	^b
    ]

    FloatD class >> precision [
	"Answer the number of bits in the mantissa. 1 + (2^-precision) = 1"

	<category: 'characterization'>
	^CDoubleBinaryDigits
    ]

    FloatD class >> fminNormalized [
	"Return the smallest normalized FloatD that is > 0"

	<category: 'characterization'>
	^CDoubleMin
    ]

    FloatD class >> fmax [
	"Return the largest normalized FloatD that is not infinite."

	<category: 'characterization'>
	^CDoubleMax
    ]

    FloatD class >> emax [
	"Return the maximum allowable exponent for a FloatD that is finite."

	<category: 'characterization'>
	^CDoubleMaxExp
    ]

    FloatD class >> emin [
	"Return the maximum allowable exponent for a FloatD that is finite."

	<category: 'characterization'>
	^CDoubleMinExp
    ]

    FloatD class >> decimalDigits [
	"Return the number of decimal digits of precision for a FloatD.
	 Technically, if P is the precision for the representation, then
	 the decimal precision Q is the maximum number of decimal digits
	 such that any floating point number with Q base 10 digits can be
	 rounded to a floating point number with P base 2 digits and back
	 again, without change to the Q decimal digits."

	<category: 'characterization'>
	^CDoubleDigits
    ]

    FloatD class >> infinity [
	"Return a FloatD that represents positive infinity."

	<category: 'characterization'>
	^CDoublePInf
    ]

    FloatD class >> negativeInfinity [
	"Return a FloatD that represents negative infinity."

	<category: 'characterization'>
	^CDoubleNInf
    ]

    FloatD class >> nan [
	"Return a FloatD that represents a mathematically indeterminate value
	 (e.g. Inf - Inf, Inf / Inf)."

	<category: 'characterization'>
	^CDoubleNaN
    ]

    zero [
	"Coerce 0 to the receiver's class"

	<category: 'coercing'>
	^0.0
    ]

    half [
        "Coerce 0.5 to the receiver's class"

        <category: 'converting'>
	^0.5
    ]

    unity [
	"Coerce 1 to the receiver's class"

	<category: 'coercing'>
	^1.0
    ]

    coerce: aNumber [
	"Coerce aNumber to the receiver's class"

	<category: 'coercing'>
	^aNumber asFloatD
    ]

    generality [
	"Answer the receiver's generality"

	<category: 'coercing'>
	^410
    ]

    asFloatD [
	"Just defined for completeness.  Return the receiver."

	<category: 'coercing'>
	^self
    ]

    ten [
	"Private - Return 10, converted to the receiver's class."

	<category: 'private'>
	^10.0
    ]

    exponentLetter [
	"Private - Return the letter to be printed just before the exponent"

	<category: 'private'>
	^$d
    ]

    + arg [
	"Sum the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_plus>
	^self retrySumCoercing: arg
    ]

    - arg [
	"Subtract arg from the receiver and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_minus>
	^self retryDifferenceCoercing: arg
    ]

    < arg [
	"Answer whether the receiver is less than arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_lt>
	^self retryRelationalOp: #< coercing: arg
    ]

    > arg [
	"Answer whether the receiver is greater than arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_gt>
	^self retryRelationalOp: #> coercing: arg
    ]

    <= arg [
	"Answer whether the receiver is less than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_le>
	^self retryRelationalOp: #<= coercing: arg
    ]

    >= arg [
	"Answer whether the receiver is greater than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_ge>
	^self retryRelationalOp: #>= coercing: arg
    ]

    = arg [
	"Answer whether the receiver is equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_eq>
	^self retryEqualityCoercing: arg
    ]

    ~= arg [
	"Answer whether the receiver is not equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_ne>
	^self retryInequalityCoercing: arg
    ]

    * arg [
	"Multiply the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_times>
	^self retryMultiplicationCoercing: arg
    ]

    / arg [
	"Divide the receiver by arg and answer another FloatD"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_divide>
	^self generality = arg generality 
	    ifTrue: [self zeroDivide]
	    ifFalse: [self retryDivisionCoercing: arg]
    ]

    asFloatE [
	"Answer the receiver converted to a FloatE"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_asFloatE>
	self primitiveFailed
    ]

    asFloatQ [
	"Answer the receiver converted to a FloatQ"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_asFloatQ>
	self primitiveFailed
    ]

    truncated [
	"Truncate the receiver towards zero and answer the result"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_truncated>
	^super truncated
    ]

    fractionPart [
	"Answer the fractional part of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_fractionPart>
	self checkCoercion.
	^self primitiveFailed
    ]

    exponent [
	"Answer the exponent of the receiver in mantissa*2^exponent
	 representation ( |mantissa|<=1 )"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_exponent>
	
    ]

    timesTwoPower: arg [
	"Answer the receiver multiplied by 2^arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatD_timesTwoPower>
	
    ]
]

