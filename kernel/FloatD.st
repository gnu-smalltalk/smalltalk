"======================================================================
|
|   FloatD Method Definitions
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Float variableByteSubclass: #FloatD
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Data types'
!

FloatD comment: 
'My instances represent floating point numbers that have 64 bits of 
precision (well, less than that in precision; they are precisely the same
as C''s "double" datatype).  Besides the standard numerical operations,
I provide transcendental operations too.'  !


!FloatD class methodsFor: 'converting'!

coerce: aNumber
    "Answer aNumber converted to a FloatD"
    ^aNumber asFloatD
! !


!FloatD class methodsFor: 'byte-order dependancies'!

signByte
    "Answer the byte of the receiver that contains the exponent"
    ^##(| n k |
        n := 0.0d * -1.
        1 to: n size do: [ :i | (n at: i) = 128 ifTrue: [ k := i ] ].
        k)
! !


!FloatD class methodsFor: 'characterization'!

precision
    "Answer the number of bits in the mantissa. 1 + (2^-precision) = 1"
    ^CDoubleBinaryDigits
!

fminNormalized
    "Return the smallest normalized FloatD that is > 0"
    ^CDoubleMin
!

fmax
    "Return the largest normalized FloatD that is not infinite."
    ^CDoubleMax
!

emax
    "Return the maximum allowable exponent for a FloatD that is finite."
    ^CDoubleMaxExp
!

emin
    "Return the maximum allowable exponent for a FloatD that is finite."
    ^CDoubleMinExp
!

decimalDigits
    "Return the number of decimal digits of precision for a FloatD.
     Technically, if P is the precision for the representation, then
     the decimal precision Q is the maximum number of decimal digits
     such that any floating point number with Q base 10 digits can be
     rounded to a floating point number with P base 2 digits and back
     again, without change to the Q decimal digits."
    ^CDoubleDigits
!

infinity
    "Return a FloatD that represents positive infinity."
    ^CDoublePInf
!

negativeInfinity
    "Return a FloatD that represents negative infinity."

    ^CDoubleNInf
!

nan
    "Return a FloatD that represents a mathematically indeterminate value
     (e.g. Inf - Inf, Inf / Inf)."
    ^CDoubleNaN
! !



!FloatD methodsFor: 'coercing'!

zero
    "Coerce 0 to the receiver's class"
    ^0.0d0
!

unity
    "Coerce 1 to the receiver's class"
    ^1.0d0
!

coerce: aNumber
    "Coerce aNumber to the receiver's class"
    ^aNumber asFloatD
!

generality
    "Answer the receiver's generality"
    ^410
!

asFloatD
    "Just defined for completeness.  Return the receiver."
    ^self
! !


!FloatD methodsFor: 'private'!

ten
    "Private - Return 10, converted to the receiver's class."
    ^1.0d1
!

exponentLetter
    "Private - Return the letter to be printed just before the exponent"
    ^$d
! !

