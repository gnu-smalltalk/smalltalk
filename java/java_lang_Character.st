"======================================================================
|
|   Java run-time support.  java.lang.Character native methods.
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


!JavaVM methodsFor: 'java.lang.Character'!

java_lang_Character_readChar_char: arg1
    <javaNativeMethod: #'readChar(C)C'
        for: #{Java.java.lang.Character} static: true>
    self notYetImplemented
!

java_lang_Character_toLowerCase_char: arg1
    <javaNativeMethod: #'toLowerCase(C)C'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 65 ifTrue: [ ^arg1 ].
    arg1 > 90 ifTrue: [ ^arg1 ].
    ^arg1 + 32
!

java_lang_Character_toUpperCase_char: arg1
    <javaNativeMethod: #'toUpperCase(C)C'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 97 ifTrue: [ ^arg1 ].
    arg1 > 122 ifTrue: [ ^arg1 ].
    ^arg1 - 32
!

java_lang_Character_toTitleCase_char: arg1
    <javaNativeMethod: #'toTitleCase(C)C'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 97 ifTrue: [ ^arg1 ].
    arg1 > 122 ifTrue: [ ^arg1 ].
    ^arg1 - 32
!

java_lang_Character_digit_char: arg1 int: arg2
    | value |
    <javaNativeMethod: #'digit(CI)I'
        for: #{Java.java.lang.Character} static: true>
    "Get the numeric value..."
    arg1 < 48 ifTrue: [ value := -1 ] ifFalse: [
    arg1 <= 57 ifTrue: [ value := arg1 - 48 ] ifFalse: [
    arg1 < 65 ifTrue: [ value := -1 ] ifFalse: [
    arg1 <= 90 ifTrue: [ value := arg1 - 55 ] ifFalse: [
    arg1 < 97 ifTrue: [ value := -1 ] ifFalse: [
    arg1 <= 122 ifTrue: [ value := arg1 - 87 ]]]]]].

    "... then compare it against the radix."
    value >= arg2 ifTrue: [ value := -1 ].
    ^value
!

java_lang_Character_getNumericValue_char: arg1
    <javaNativeMethod: #'getNumericValue(C)I'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 48 ifTrue: [ ^-1 ].
    arg1 <= 57 ifTrue: [ ^arg1 - 48 ].
    arg1 < 65 ifTrue: [ ^-1 ].
    arg1 <= 90 ifTrue: [ ^arg1 - 55 ].
    arg1 < 97 ifTrue: [ ^-1 ].
    arg1 <= 122 ifTrue: [ ^arg1 - 87 ].
    ^-1
!

java_lang_Character_getType_char: arg1
    <javaNativeMethod: #'getType(C)I'
        for: #{Java.java.lang.Character} static: true>
    self notYetImplemented
!

java_lang_Character_getDirectionality_char: arg1
    <javaNativeMethod: #'getDirectionality(C)B'
        for: #{Java.java.lang.Character} static: true>
    self notYetImplemented
! !

