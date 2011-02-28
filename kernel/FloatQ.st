"======================================================================
|
|   FloatQ Method Definitions
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



Float subclass: FloatQ [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: 'My instances represent floating point numbers that have the same
accuracy as C''s "long double" numbers.'>

    FloatQ class >> coerce: aNumber [
	"Answer aNumber converted to a FloatQ"

	<category: 'converting'>
	^aNumber asFloatQ
    ]

    FloatQ class >> signByte [
	"Answer the byte of the receiver that contains the sign bit"

	<category: 'byte-order dependancies'>
	^##(| n k |
	n := -2.0q.
	1 to: n size do: [:i | (n at: i) >= 128 ifTrue: [k := i]].
	k)
    ]

    FloatQ class >> e [
	"Returns the value of e. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r2.B7E151628AED2A6ABF7158809CF4F3C75Eq
    ]

    FloatQ class >> precision [
	"Answer the number of bits in the mantissa. 1 + (2^-precision) = 1"

	<category: 'characterization'>
	^CLongDoubleBinaryDigits
    ]

    FloatQ class >> fminNormalized [
	"Return the smallest normalized FloatQ that is > 0"

	<category: 'characterization'>
	^CLongDoubleMin
    ]

    FloatQ class >> fmax [
	"Return the largest normalized FloatQ that is not infinite."

	<category: 'characterization'>
	^CLongDoubleMax
    ]

    FloatQ class >> emax [
	"Return the maximum allowable exponent for a FloatQ that is finite."

	<category: 'characterization'>
	^CLongDoubleMaxExp
    ]

    FloatQ class >> emin [
	"Return the maximum allowable exponent for a FloatQ that is finite."

	<category: 'characterization'>
	^CLongDoubleMinExp
    ]

    FloatQ class >> decimalDigits [
	"Return the number of decimal digits of precision for a FloatQ.
	 Technically, if P is the precision for the representation, then
	 the decimal precision Q is the maximum number of decimal digits
	 such that any floating point number with Q base 10 digits can be
	 rounded to a floating point number with P base 2 digits and back
	 again, without change to the Q decimal digits."

	<category: 'characterization'>
	^CLongDoubleDigits
    ]

    FloatQ class >> log10Base2 [
	"Returns the value of log2 10. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r3.5269E12F346E2BF924AFDBFD36BF6D3362q
    ]

    FloatQ class >> ln10 [
	"Returns the value of ln 10. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r2.4D763776AAA2B05BA95B58AE0B4C28A38Aq
    ]

    FloatQ class >> infinity [
	"Return a FloatQ that represents positive infinity."

	<category: 'characterization'>
	^CLongDoublePInf
    ]

    FloatQ class >> negativeInfinity [
	"Return a FloatQ that represents negative infinity."

	<category: 'characterization'>
	^CLongDoubleNInf
    ]

    FloatQ class >> nan [
	"Return a FloatQ that represents a mathematically indeterminate value
	 (e.g. Inf - Inf, Inf / Inf)."

	<category: 'characterization'>
	^CLongDoubleNaN
    ]

    FloatQ class >> pi [
	"Returns the value of pi. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r3.243F6A8885A308D313198A2E0370734483q
    ]

    zero [
	"Coerce 0 to the receiver's class"

	<category: 'coercing'>
	^0.0q
    ]

    half [
        "Coerce 0.5 to the receiver's class"

        <category: 'converting'>
	^0.5q
    ]

    unity [
	"Coerce 1 to the receiver's class"

	<category: 'coercing'>
	^1.0q
    ]

    coerce: aNumber [
	"Coerce aNumber to the receiver's class"

	<category: 'coercing'>
	^aNumber asFloatQ
    ]

    generality [
	"Answer the receiver's generality"

	<category: 'coercing'>
	^420
    ]

    asFloatQ [
	"Just defined for completeness.  Return the receiver."

	<category: 'coercing'>
	^self
    ]

    ten [
	"Private - Return 10, converted to the receiver's class."

	<category: 'private'>
	^10.0q
    ]

    exponentLetter [
	"Private - Return the letter to be printed just before the exponent"

	<category: 'private'>
	^$q
    ]

    + arg [
	"Sum the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_plus>
	^self retrySumCoercing: arg
    ]

    - arg [
	"Subtract arg from the receiver and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_minus>
	^self retryDifferenceCoercing: arg
    ]

    < arg [
	"Answer whether the receiver is less than arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_lt>
	^self retryRelationalOp: #< coercing: arg
    ]

    > arg [
	"Answer whether the receiver is greater than arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_gt>
	^self retryRelationalOp: #> coercing: arg
    ]

    <= arg [
	"Answer whether the receiver is less than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_le>
	^self retryRelationalOp: #<= coercing: arg
    ]

    >= arg [
	"Answer whether the receiver is greater than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_ge>
	^self retryRelationalOp: #>= coercing: arg
    ]

    = arg [
	"Answer whether the receiver is equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_eq>
	^self retryEqualityCoercing: arg
    ]

    ~= arg [
	"Answer whether the receiver is not equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_ne>
	^self retryInequalityCoercing: arg
    ]

    * arg [
	"Multiply the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_times>
	^self retryMultiplicationCoercing: arg
    ]

    / arg [
	"Divide the receiver by arg and answer another FloatQ"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_divide>
	^self generality = arg generality 
	    ifTrue: [self zeroDivide]
	    ifFalse: [self retryDivisionCoercing: arg]
    ]

    asFloatD [
	"Answer the receiver converted to a FloatD"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_asFloatD>
	self primitiveFailed
    ]

    asFloatE [
	"Answer the receiver converted to a FloatE"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_asFloatE>
	self primitiveFailed
    ]

    truncated [
	"Truncate the receiver towards zero and answer the result"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_truncated>
	^super truncated
    ]

    fractionPart [
	"Answer the fractional part of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_fractionPart>
	self checkCoercion.
	^self primitiveFailed
    ]

    exponent [
	"Answer the exponent of the receiver in mantissa*2^exponent
	 representation ( |mantissa|<=1 )"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_exponent>
	
    ]

    timesTwoPower: arg [
	"Answer the receiver multiplied by 2^arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatQ_timesTwoPower>
	
    ]
]

