"======================================================================
|
|   Java run-time support.  java.lang.Float native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Float'!

java_lang_Float_floatToIntBits_float: arg1
    | v1 v12 |
    <javaNativeMethod: #'floatToIntBits(F)I'
        for: #{Java.java.lang.Float} static: true>

    "Handle NaN here."
    arg1 = arg1 ifFalse: [ ^16r7FC0_0000 ].
    v1 := ((arg1 at: 4) * 256 + (arg1 at: 3)) javaAsShort.
    v12 := (v1 * 256 + (arg1 at: 2)) * 256 + (arg1 at: 1).

    "Handle zero and infinity here."
    arg1 + arg1 = arg1 ifTrue: [ v12 := v12 bitAnd: 16r-80_0000 ].
    ^v12
!

java_lang_Float_floatToRawIntBits_float: arg1
    | v1 v2 |
    <javaNativeMethod: #'floatToRawIntBits(F)I'
        for: #{Java.java.lang.Float} static: true>
    v1 := ((arg1 at: 4) * 256 + (arg1 at: 3)) javaAsShort.
    v2 := (arg1 at: 2) * 256 + (arg1 at: 1).
    ^v1 * 65536 + v2
!

java_lang_Float_intBitsToFloat_int: arg1
    | s e m |
    <javaNativeMethod: #'intBitsToFloat(I)F'
        for: #{Java.java.lang.Float} static: true>

    "Extract sign and exponent"
    s := arg1 < 0 ifTrue: [ -1.0e ] ifFalse: [ 1.0e ].
    e := (arg1 bitShift: -23) bitAnd: 255.
    m := arg1 bitAnd: 16r7FFFFF.

    "Extract mantissa and check for infinity or NaN"
    e = 127 ifTrue: [
        ^m = 0
            ifTrue: [ 1.0e / (0.0e * s) ]
            ifFalse: [ (1.0e / 0.0e) - (1.0e / 0.0e) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r800000 ].

    ^m * s timesTwoPower: e - 150
! !
