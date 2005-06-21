"======================================================================
|
|   Java run-time support.  java.lang.Math native methods.
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


!JavaVM methodsFor: 'java.lang.Math'!

java_lang_Math_sin_double: arg1
    <javaNativeMethod: #'sin(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 sin
!

java_lang_Math_cos_double: arg1
    <javaNativeMethod: #'cos(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 cos
!

java_lang_Math_tan_double: arg1
    <javaNativeMethod: #'tan(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 tan
!

java_lang_Math_asin_double: arg1
    <javaNativeMethod: #'asin(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcSin
!

java_lang_Math_acos_double: arg1
    <javaNativeMethod: #'acos(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcCos
!

java_lang_Math_atan_double: arg1
    <javaNativeMethod: #'atan(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcTan
!

java_lang_Math_atan2_double: arg1 double: arg2
    <javaNativeMethod: #'atan2(DD)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcTan: arg2
!

java_lang_Math_exp_double: arg1
    <javaNativeMethod: #'exp(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 exp
!

java_lang_Math_log_double: arg1
    <javaNativeMethod: #'log(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 ln
!

java_lang_Math_sqrt_double: arg1
    <javaNativeMethod: #'sqrt(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 sqrt
!

java_lang_Math_pow_double: arg1 double: arg2
    <javaNativeMethod: #'pow(DD)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 raisedTo: arg2
!

java_lang_Math_IEEEremainder_double: arg1 double: arg2
    <javaNativeMethod: #'IEEEremainder(DD)D'
        for: #{Java.java.lang.Math} static: true>
    arg2 = 0.0 ifTrue: [ ^FloatD nan ].
    arg1 = arg1 ifFalse: [ ^arg2 ].
    arg2 = arg2 ifFalse: [ ^arg2 ].
    ^arg1 rem: arg2
!

java_lang_Math_ceil_double: arg1
    <javaNativeMethod: #'ceil(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 ceiling
!

java_lang_Math_floor_double: arg1
    <javaNativeMethod: #'floor(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 floor
!

java_lang_Math_rint_double: arg1
    <javaNativeMethod: #'rint(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 rounded
! !

