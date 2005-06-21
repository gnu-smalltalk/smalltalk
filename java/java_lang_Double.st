"======================================================================
|
|   Java run-time support.  java.lang.Double native methods.
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


!JavaVM methodsFor: 'java.lang.Double'!

java_lang_Double_parseDouble_java_lang_String: arg1
    <javaNativeMethod: #'parseDouble(Ljava/lang/String;)D'
        for: #{Java.java.lang.Double} static: true>
    ^arg1 asString asNumber asFloatD
!

java_lang_Double_doubleToLongBits_double: arg1
    | exp mantissa expField |
    <javaNativeMethod: #'doubleToLongBits(D)J'
        for: #{Java.java.lang.Double} static: true>

    "Handle NaN here."
    arg1 = arg1 ifFalse: [ ^16r7FF8_0000_0000_0000 ].
    exp := arg1 exponent.
    mantissa := arg1 negative
        ifTrue: [ expField := exp - 1026. arg1 * -1 ]
        ifFalse: [ expField := exp + 1022. arg1 ].

    "Handle zero and infinity"
    arg1 = 0
	ifTrue: [ expField := exp - 1024. mantissa := 0 ]
	ifFalse: [
	    arg1 + arg1 = arg1
		ifTrue: [ expField := expField + 1026. mantissa := 0 ]
		ifFalse: [ mantissa := mantissa timesTwoPower: 52 - exp ].
	].

    ^mantissa asInteger + (expField * 16r10_0000_0000_0000)
!

java_lang_Double_doubleToRawLongBits_double: arg1
    | v1 v2 v3 v4 v12 v34 |
    <javaNativeMethod: #'doubleToRawLongBits(D)J'
        for: #{Java.java.lang.Double} static: true>
    v1 := ((arg1 at: 8) * 256 + (arg1 at: 7)) javaAsShort.
    v2 := (arg1 at: 6) * 256 + (arg1 at: 5).
    v3 := (arg1 at: 4) * 256 + (arg1 at: 3).
    v4 := (arg1 at: 2) * 256 + (arg1 at: 1).
    v12 := v1 * 65536 + v2.
    v34 := v3 * 65536 + v4.
    ^(v12 bitShift: 32) + v34
!

java_lang_Double_longBitsToDouble_long: arg1
    | s e m |
    <javaNativeMethod: #'longBitsToDouble(J)D'
        for: #{Java.java.lang.Double} static: true>
    s := arg1 < 0 ifTrue: [ -1.0d ] ifFalse: [ 1.0d ].
    e := (arg1 bitShift: -52) bitAnd: 16r7FF.
    m := arg1 bitAnd: 16rF_FFFF_FFFF_FFFF.

    e = 16r7FF ifTrue: [
        ^m = 0
            ifTrue: [ 1.0d / (0.0d * s) ]
            ifFalse: [ (1.0d / 0.0d) - (1.0d / 0.0d) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r10_0000_0000_0000 ].

    ^m * s timesTwoPower: e - 1075
!

java_lang_Double_toString_double: arg1 boolean: arg2
    <javaNativeMethod: #'toString(DZ)Ljava/lang/String;'
        for: #{Java.java.lang.Double} static: true>
    ^arg2 = 1
	ifTrue: [ arg1 asFloatE printString asJavaString ]
	ifFalse: [ arg1 asFloatD printString asJavaString ]
! !

