"======================================================================
|
|   FloatE Method Definitions
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



Float subclass: FloatE [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: 'My instances represent floating point numbers that have the same
accuracy as C''s "float" numbers.'>

    FloatE class >> coerce: aNumber [
	"Answer aNumber converted to a FloatE"

	<category: 'converting'>
	^aNumber asFloatE
    ]

    FloatE class >> signByte [
	"Answer the byte of the receiver that contains the sign bit"

	<category: 'byte-order dependancies'>
	^##(| n k |
	n := -2.0e.
	1 to: n size do: [:i | (n at: i) >= 128 ifTrue: [k := i]].
	k)
    ]

    FloatE class >> fromBytes: aByteArray [
        "Answer a float with the bytes in aByteArray, which are in
         big-endian format."

        <category: 'byte-order dependencies'>
        | b permutation |
        permutation := ##(| signByte perm |
            signByte := FloatE signByte.
            signByte = 1 ifTrue: [ perm := #[1 2 3 4] ].
            signByte = 4 ifTrue: [ perm := #[4 3 2 1] ].
            perm).
        b := FloatE new: 4.
        1 to: 4 do: [ :i |
            b at: i put: (aByteArray at: (permutation at: i)) ].
        b makeReadOnly: true.
        ^b
    ]

    FloatE class >> e [
	"Returns the value of e. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r2.B7E151628AED2A6ABF71588e
    ]

    FloatE class >> precision [
	"Answer the number of bits in the mantissa. 1 + (2^-precision) = 1"

	<category: 'characterization'>
	^CFloatBinaryDigits
    ]

    FloatE class >> fminNormalized [
	"Return the smallest normalized FloatE that is > 0"

	<category: 'characterization'>
	^CFloatMin
    ]

    FloatE class >> fmax [
	"Return the largest normalized FloatE that is not infinite."

	<category: 'characterization'>
	^CFloatMax
    ]

    FloatE class >> emax [
	"Return the maximum allowable exponent for a FloatE that is finite."

	<category: 'characterization'>
	^CFloatMaxExp
    ]

    FloatE class >> emin [
	"Return the maximum allowable exponent for a FloatE that is finite."

	<category: 'characterization'>
	^CFloatMinExp
    ]

    FloatE class >> decimalDigits [
	"Return the number of decimal digits of precision for a FloatE.
	 Technically, if P is the precision for the representation, then
	 the decimal precision Q is the maximum number of decimal digits
	 such that any floating point number with Q base 10 digits can be
	 rounded to a floating point number with P base 2 digits and back
	 again, without change to the Q decimal digits."

	<category: 'characterization'>
	^CFloatDigits
    ]

    FloatE class >> log10Base2 [
	"Returns the value of log2 10. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r3.5269E12F346E2BF924AFDBFDe
    ]

    FloatE class >> ln10 [
	"Returns the value of ln 10. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r2.4D763776AAA2B05BA95B58AEe
    ]

    FloatE class >> infinity [
	"Return a FloatE that represents positive infinity."

	<category: 'characterization'>
	^CFloatPInf
    ]

    FloatE class >> negativeInfinity [
	"Return a FloatE that represents negative infinity."

	<category: 'characterization'>
	^CFloatNInf
    ]

    FloatE class >> nan [
	"Return a FloatE that represents a mathematically indeterminate value
	 (e.g. Inf - Inf, Inf / Inf)."

	<category: 'characterization'>
	^CFloatNaN
    ]

    FloatE class >> pi [
	"Returns the value of pi. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r3.243F6A8885A308D313198A2Ee
    ]

    zero [
	"Coerce 0 to the receiver's class"

	<category: 'coercing'>
	^0.0e
    ]

    half [
        "Coerce 0.5 to the receiver's class"

        <category: 'converting'>
	^0.5e
    ]

    unity [
	"Coerce 1 to the receiver's class"

	<category: 'coercing'>
	^1.0e
    ]

    coerce: aNumber [
	"Coerce aNumber to the receiver's class"

	<category: 'coercing'>
	^aNumber asFloatE
    ]

    generality [
	"Answer the receiver's generality"

	<category: 'coercing'>
	^400
    ]

    asFloatE [
	"Just defined for completeness.  Return the receiver."

	<category: 'coercing'>
	^self
    ]

    ten [
	"Private - Return 10, converted to the receiver's class."

	<category: 'private'>
	^10.0e
    ]

    exponentLetter [
	"Private - Return the letter to be printed just before the exponent"

	<category: 'private'>
	^$e
    ]

    + arg [
	"Sum the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_plus>
	^self retrySumCoercing: arg
    ]

    - arg [
	"Subtract arg from the receiver and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_minus>
	^self retryDifferenceCoercing: arg
    ]

    < arg [
	"Answer whether the receiver is less than arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_lt>
	^self retryRelationalOp: #< coercing: arg
    ]

    > arg [
	"Answer whether the receiver is greater than arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_gt>
	^self retryRelationalOp: #> coercing: arg
    ]

    <= arg [
	"Answer whether the receiver is less than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_le>
	^self retryRelationalOp: #<= coercing: arg
    ]

    >= arg [
	"Answer whether the receiver is greater than or equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_ge>
	^self retryRelationalOp: #>= coercing: arg
    ]

    = arg [
	"Answer whether the receiver is equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_eq>
	^self retryEqualityCoercing: arg
    ]

    ~= arg [
	"Answer whether the receiver is not equal to arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_ne>
	^self retryInequalityCoercing: arg
    ]

    * arg [
	"Multiply the receiver and arg and answer another Number"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_times>
	^self retryMultiplicationCoercing: arg
    ]

    / arg [
	"Divide the receiver by arg and answer another FloatE"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_divide>
	^self generality = arg generality 
	    ifTrue: [self zeroDivide]
	    ifFalse: [self retryDivisionCoercing: arg]
    ]

    asFloatD [
	"Answer the receiver converted to a FloatD"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_asFloatD>
	self primitiveFailed
    ]

    asFloatQ [
	"Answer the receiver converted to a FloatQ"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_asFloatQ>
	self primitiveFailed
    ]

    truncated [
	"Truncate the receiver towards zero and answer the result"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_truncated>
	^super truncated
    ]

    fractionPart [
	"Answer the fractional part of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_fractionPart>
	self checkCoercion.
	^self primitiveFailed
    ]

    exponent [
	"Answer the exponent of the receiver in mantissa*2^exponent
	 representation ( |mantissa|<=1 )"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_exponent>
	
    ]

    timesTwoPower: arg [
	"Answer the receiver multiplied by 2^arg"

	<category: 'built ins'>
	<primitive: VMpr_FloatE_timesTwoPower>
	
    ]
]

