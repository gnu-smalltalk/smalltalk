"======================================================================
|
|   FloatQ Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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


Float variableByteSubclass: #FloatQ
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Data types'
!

FloatQ comment: 
'My instances represent floating point numbers that have the same
accuracy as C''s "long double" numbers.'  !


!FloatQ class methodsFor: 'converting'!

coerce: aNumber
    "Answer aNumber converted to a FloatQ"
    ^aNumber asFloatQ
! !


!FloatQ class methodsFor: 'byte-order dependancies'!

signByte
    "Answer the byte of the receiver that contains the sign bit"
    ^##(| n k |
	n := 0.0q * -1.
	1 to: n size do: [ :i | (n at: i) = 128 ifTrue: [ k := i ] ].
	k)
! !


!FloatQ class methodsFor: 'characterization'!

e
    "Returns the value of e. Hope is that it is precise enough"
    ^2.7182818284590452353602874713527q0
!

precision
    "Answer the number of bits in the mantissa. 1 + (2^-precision) = 1"
    ^CLongDoubleBinaryDigits
!

fminNormalized
    "Return the smallest normalized FloatQ that is > 0"
    ^CLongDoubleMin
!

fmax
    "Return the largest normalized FloatQ that is not infinite."
    ^CLongDoubleMax
!

emax
    "Return the maximum allowable exponent for a FloatQ that is finite."
    ^CLongDoubleMaxExp
!

emin
    "Return the maximum allowable exponent for a FloatQ that is finite."
    ^CLongDoubleMinExp
!

decimalDigits
    "Return the number of decimal digits of precision for a FloatQ.
     Technically, if P is the precision for the representation, then
     the decimal precision Q is the maximum number of decimal digits
     such that any floating point number with Q base 10 digits can be
     rounded to a floating point number with P base 2 digits and back
     again, without change to the Q decimal digits."
    ^CLongDoubleDigits
!

log10Base2
    "Returns the value of log2 10. Hope is that it is precise enough"
    ^3.3219280948873623478703194294894q0
!

ln10
    "Returns the value of ln 10. Hope is that it is precise enough"
    ^2.3025850929940456840179914546844q0
!

infinity
    "Return a FloatQ that represents positive infinity."
    ^CLongDoublePInf
!

negativeInfinity
    "Return a FloatQ that represents negative infinity."

    ^CLongDoubleNInf
!

nan
    "Return a FloatQ that represents a mathematically indeterminate value
     (e.g. Inf - Inf, Inf / Inf)."
    ^CLongDoubleNaN
!

pi
    "Returns the value of pi. Hope is that it is precise enough"
    ^3.14159265358979323846264338327950288q0
! !



!FloatQ methodsFor: 'coercing'!

zero
    "Coerce 0 to the receiver's class"
    ^0.0q0
!

unity
    "Coerce 1 to the receiver's class"
    ^1.0q0
!

coerce: aNumber
    "Coerce aNumber to the receiver's class"
    ^aNumber asFloatQ
!

generality
    "Answer the receiver's generality"
    ^420
!

asFloatQ
    "Just defined for completeness.  Return the receiver."
    ^self
! !


!FloatQ methodsFor: 'private'!

ten
    "Private - Return 10, converted to the receiver's class."
    ^1.0q1
!

exponentLetter
    "Private - Return the letter to be printed just before the exponent"
    ^$q
! !

