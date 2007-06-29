"======================================================================
|
|   Java run-time support.  java.lang.String native methods.
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


!JavaVM methodsFor: 'java.lang.String'!

convertJavaString
    <javaNativeMethod: #asString for: #{Java.java.lang.String} static: false>
    (self boffset = 0 and: [ self count = self data size ])
	ifTrue: [ ^self data ].

    ^self data copyFrom: self boffset + 1 to: self boffset + self count!

java_lang_String_charAt_int: arg1
    <javaNativeMethod: #'charAt(I)C'
        for: #{Java.java.lang.String} static: false>
    arg1 < 0 ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg1 >= self count ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    ^(self data at: arg1 + self boffset + 1) value
!

java_lang_String_getChars_int: arg1 int: arg2 charArray: arg3 int: arg4
    | ofs |
    <javaNativeMethod: #'getChars(II[CI)V'
        for: #{Java.java.lang.String} static: false>

    arg1 < 0 ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg1 >= self count ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg4 + (arg2 - arg1) > arg3 size ifTrue: [
	^JavaVM arrayIndexOutOfBounds: self index: arg3 size + 1 ].

    ofs := arg1 - arg4 + self boffset.
    arg4 + 1 to: arg4 + (arg2 - arg1) do: [ :destIndex |
    	arg3 at: destIndex put: (self data at: destIndex + ofs) value ].
!

java_lang_String_getBytes_int: arg1 int: arg2 byteArray: arg3 int: arg4
    <javaNativeMethod: #'getBytes(II[BI)V'
        for: #{Java.java.lang.String} static: false>

    arg1 < 0 ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg1 >= self count ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg4 + (arg2 - arg1) > arg3 size ifTrue: [
	^JavaVM arrayIndexOutOfBounds: self index: arg3 size + 1 ].

    arg3
	replaceFrom: arg4 + 1
	to: arg4 + (arg2 - arg1)
	with: self data
	startingAt: arg1 + 1.
!

java_lang_String_getBytes_java_lang_String: arg1
    <javaNativeMethod: #'getBytes(Ljava/lang/String;)[B'
        for: #{Java.java.lang.String} static: false>

    ^(ByteArray new: self count)
	replaceFrom: 1 to: self count
	with: self data
	startingAt: self boffset + 1;

	yourself
!

java_lang_String_equals_java_lang_Object: arg1
    | left thisOfs thatOfs |
    <javaNativeMethod: #'equals(Ljava/lang/Object;)Z'
        for: #{Java.java.lang.String} static: false>
    self class = arg1 class ifFalse: [ ^0 ].
    self count = arg1 count ifFalse: [ ^0 ].
    self count = 0 ifTrue: [ ^1 ].
    left := self count.
    thisOfs := self boffset.
    thatOfs := arg1 boffset.
    [
	(self data at: thisOfs + left) = (arg1 data at: thatOfs + left)
	    ifFalse: [ ^0 ].

        (left := left - 1) = 0 ] whileFalse.

    ^1
!

java_lang_String_contentEquals_java_lang_StringBuffer: arg1
    <javaNativeMethod: #'contentEquals(Ljava/lang/StringBuffer;)Z'
        for: #{Java.java.lang.String} static: false>
    self notYetImplemented
!

java_lang_String_equalsIgnoreCase_java_lang_String: arg1
    | left thisOfs thatOfs |
    <javaNativeMethod: #'equalsIgnoreCase(Ljava/lang/String;)Z'
        for: #{Java.java.lang.String} static: false>

    self class = arg1 class ifFalse: [ ^0 ].
    self count = arg1 count ifFalse: [ ^0 ].
    self count = 0 ifTrue: [ ^1 ].
    left := self count.
    thisOfs := self boffset.
    thatOfs := arg1 boffset.
    [
	(self data at: thisOfs + left) asLowercase
	    = (arg1 data at: thatOfs + left) asLowercase
	        ifFalse: [ ^0 ].

        (left := left - 1) = 0 ] whileFalse.

    ^1
!

java_lang_String_compareTo_java_lang_String: arg1
    | left thisOfs thatOfs delta |
    <javaNativeMethod: #'compareTo(Ljava/lang/String;)I'
        for: #{Java.java.lang.String} static: false>

    self count < arg1 count
	ifTrue: [
	    (left := self count) = 0 ifTrue: [ ^0 - arg1 count ] ]
	ifFalse: [
	    (left := arg1 count) = 0 ifTrue: [ ^self count ] ].
	    
    thisOfs := self boffset.
    thatOfs := arg1 boffset.
    [
	delta := (self data at: thisOfs + left)-(arg1 data at: thatOfs + left).
	delta = 0 ifFalse: [ ^delta ].

        (left := left - 1) = 0 ] whileFalse.

    ^self count - arg1 count
!

java_lang_String_regionMatches_int: arg1 java_lang_String: arg2 int: arg3 int: arg4
    | ofs left thisOfs thatOfs |
    <javaNativeMethod: #'regionMatches(ILjava/lang/String;II)Z'
        for: #{Java.java.lang.String} static: false>

    arg1 < 0 ifTrue: [ ^0 ].
    arg3 < 0 ifTrue: [ ^0 ].
    arg4 < 0 ifTrue: [ ^0 ].
    arg4 >= self count - arg1 ifTrue: [ ^0 ].
    arg4 >= arg2 count - arg3 ifTrue: [ ^0 ].

    left := arg4.
    thisOfs := self boffset + arg1.
    thatOfs := arg2 boffset + arg3.
    [
	(self data at: thisOfs + left) = (arg1 data at: thatOfs + left)
	    ifFalse: [ ^0 ].

        (left := left - 1) = 0 ] whileFalse.

    ^1
!

java_lang_String_regionMatches_boolean: arg1 int: arg2 java_lang_String: arg3 int: arg4 int: arg5
    | ofs left thisOfs thatOfs |
    <javaNativeMethod: #'regionMatches(ZILjava/lang/String;II)Z'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^0 ].
    arg4 < 0 ifTrue: [ ^0 ].
    arg5 < 0 ifTrue: [ ^0 ].
    arg5 >= self count - arg2 ifTrue: [ ^0 ].
    arg5 >= arg3 count - arg4 ifTrue: [ ^0 ].

    left := arg5.
    thisOfs := self boffset + arg2.
    thatOfs := arg3 boffset + arg4.
    arg1 = 0
	ifTrue: [
	    [
		(self data at: thisOfs + left) = (arg1 data at: thatOfs + left)
		    ifFalse: [ ^0 ].

        	(left := left - 1) = 0 ] whileFalse ]
	ifFalse: [
	    [
		(self data at: thisOfs + left) asLowercase
		    = (arg1 data at: thatOfs + left) asLowercase
		    ifFalse: [ ^0 ].

        	(left := left - 1) = 0 ] whileFalse ].

    ^1
!

java_lang_String_startsWith_java_lang_String: arg1 int: arg2
    | ofs left result |
    <javaNativeMethod: #'startsWith(Ljava/lang/String;I)Z'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^0 ].
    arg1 count >= self count - arg2 ifTrue: [ ^0 ].
    ofs := (self boffset + arg2) - arg1 boffset.
    self boffset + arg2 + 1 to: self boffset + arg1 count do: [ :index |
	(self data at: index) = (arg1 data at: index + ofs) ifFalse: [^0] ].

    ^1
!

java_lang_String_hashCode
    | hash |
    <javaNativeMethod: #'hashCode()I'
        for: #{Java.java.lang.String} static: false>

    (hash := self cachedHashCode) = 0
	ifTrue: [
	    self boffset + 1 to: self boffset + self count do: [ :index |
		"Complicated way to multiply hash by 31 and reasonably
		 try to avoid LargeIntegers..."
		hash := ((hash bitAnd: 16r7FFFFFF)
			    bitShift: 5) - hash + (self data at: index) value.
	    ].
	    self cachedHashCode: hash ].

    ^hash 
!

java_lang_String_indexOf_int: arg1 int: arg2
    | ch |
    <javaNativeMethod: #'indexOf(II)I'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^-1 ].
    arg2 >= self count ifTrue: [ ^-1 ].
    ch := arg1 asCharacter.
    self boffset + arg2 + 1 to: self boffset + self count do:
	[ :index |
	    (self data at: index) = ch ifTrue: [ ^index - self boffset - 1 ] ].

    ^-1
!

java_lang_String_lastIndexOf_int: arg1 int: arg2
    | ch |
    <javaNativeMethod: #'lastIndexOf(II)I'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^-1 ].
    arg2 >= self count ifTrue: [ ^-1 ].
    ch := arg1 asCharacter.
    self boffset + self count to: self boffset + arg2 + 1 by: -1 do:
	[ :index |
	    (self data at: index) = ch ifTrue: [ ^index - self boffset - 1 ] ].

    ^-1
!

java_lang_String_indexOf_java_lang_String: arg1 int: arg2

    | firstCh ofs left result |
    <javaNativeMethod: #'indexOf(Ljava/lang/String;I)I'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^-1 ].
    arg2 >= self count ifTrue: [ ^-1 ].
    arg1 count = 0 ifTrue: [ ^arg2 ].

    ofs := arg1 boffset + 1.
    firstCh := arg1 data at: ofs.
    self boffset + arg2 + 1 to: self boffset + self count - (arg1 count - 1) do:
	[ :first |
	    (self data at: first) = firstCh ifTrue: [
		left := arg1 count.
		[
		    (left := left - 1) = 0 ifTrue: [ ^first - self boffset - 1 ].
		    (self data at: first + left) = (arg1 data at: ofs + left)
		] whileTrue.
	    ]
	].

    ^-1
!

java_lang_String_substring_int: arg1 int: arg2
    <javaNativeMethod: #'substring(II)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM stringIndexOutOfBounds: self index: arg2 ].
    arg2 >= self count
	ifTrue: [ ^JavaVM stringIndexOutOfBounds: self index: arg2 ].

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: self data
	with: self boffset + arg1
	with: (arg2 - arg1 min: self count)
	with: true
!

java_lang_String_concat_java_lang_String: arg1

    | result |
    <javaNativeMethod: #'concat(Ljava/lang/String;)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    result := String new: self count + arg1 count.
    result
	replaceFrom: 1 to: self count
	with: self data
	startingAt: self boffset + 1.

    result
	replaceFrom: self count + 1 to: self size
	with: arg1 data
	startingAt: arg1 boffset + 1.

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: result
	with: 0
	with: result size
	with: true
!

java_lang_String_replace_char: arg1 char: arg2
    <javaNativeMethod: #'replace(CC)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: (self data
		  copyReplacing: arg1 asCharacter
		  withObject: arg2 asCharacter)
	with: self boffset
        with: self count
	with: true
!

java_lang_String_toLowerCase_java_util_Locale: arg1
    <javaNativeMethod: #'toLowerCase(Ljava/util/Locale;)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: self data asLowercase
	with: self boffset
        with: self count
	with: true
!

java_lang_String_toUpperCase_java_util_Locale: arg1
    <javaNativeMethod: #'toUpperCase(Ljava/util/Locale;)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: self data asUppercase
	with: self boffset
        with: self count
	with: true
!

java_lang_String_trim
    <javaNativeMethod: #'trim()Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    1 to: self size do: [ :first |
	(self data at: first) isSeparator ifFalse: [
	    self size to: first by: -1 do: [ :last |
		(self data at: last) isSeparator ifFalse: [
		    ^Java.java.lang.String new
			perform: #'<init>([CIIZ)V'
			with: self data
			with: first - 1
			with: last - first + 1
			with: true ]]]].

    ^Java.java.lang.String new
	perform: #'<init>()V'
!

java_lang_String_toCharArray
    <javaNativeMethod: #'toCharArray()[C'
        for: #{Java.java.lang.String} static: false>

    ^(ByteArray new: self count)
        replaceFrom: 1 to: self count
	with: self data
	startingAt: self boffset + 1;

	asArray
!

java_lang_String_valueOf_charArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'valueOf([CII)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: true>

    ^Java.java.lang.String new
	perform: #'<init>([CII)V'
	with: arg1
	with: arg2
	with: arg3
!

java_lang_String_valueOf_char: arg1
    <javaNativeMethod: #'valueOf(C)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: true>

    ^Java.java.lang.String new
	perform: #'<init>([C)V'
	with: { arg1 }
!

java_lang_String_valueOf_int: arg1
    <javaNativeMethod: #'valueOf(I)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: true>

    ^Java.java.lang.String new
	perform: #'<init>([C)V'
	with: arg1 printString
!

java_lang_String_intern
    <javaNativeMethod: #'intern()Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>
    self notYetImplemented
!

java_lang_String_init_charArray: arg1 int: arg2 int: arg3 boolean: arg4
    <javaNativeMethod: #'init([CIIZ)V'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].
    arg2 + arg3 > arg1 size
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].

    arg1 isString
	ifTrue: [
	    self data: arg1.
	    self boffset: arg2.
	    arg4 = 0 ifTrue: [ self data: self data copy ] ]
	ifFalse: [
	    self data: (String new: arg3).
	    self boffset: 0.
	    1 to: arg3 do: [ :i |
		self data at: i put: (arg1 at: arg2 + i) asCharacter ] ].

    self count: arg3.
!

java_lang_String_init_byteArray: arg1 int: arg2 int: arg3 int: arg4
    <javaNativeMethod: #'init([BIII)V'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].
    arg2 + arg3 > arg1 size
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].

    self data: arg1 asString.
    self boffset: arg2.
    self count: arg3.
!

java_lang_String_init_byteArray: arg1 int: arg2 int: arg3 java_lang_String: arg4
    <javaNativeMethod: #'init([BIILjava/lang/String;)V'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].
    arg2 + arg3 > arg1 size
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].

    self data: arg1 asString.
    self boffset: arg2.
    self count: arg3.
!

java_lang_String_init_gnu_gcj_runtime_StringBuffer: arg1
    <javaNativeMethod: #'init(Lgnu/gcj/runtime/StringBuffer;)V'
        for: #{Java.java.lang.String} static: false>
    self notYetImplemented
!

java_lang_String_rehash
    <javaNativeMethod: #'rehash()V'
        for: #{Java.java.lang.String} static: true>
! !

