"======================================================================
|
|   Java run-time support.  java.lang.System native methods.
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


!JavaVM methodsFor: 'java.lang.System'!

java_lang_System_currentTimeMillis
    <javaNativeMethod: #'currentTimeMillis()J'
        for: #{Java.java.lang.System} static: true>
    ^Time millisecondClock javaAsLong
!

java_lang_System_arraycopy_java_lang_Object: arg1 int: arg2 java_lang_Object: arg3 int: arg4 int: arg5
    <javaNativeMethod: #'arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V'
        for: #{Java.java.lang.System} static: true>
    arg3 replaceFrom: arg4 + 1 to: arg4 + arg5 with: arg1 startingAt: arg2 + 1
!

java_lang_System_identityHashCode_java_lang_Object: arg1
    <javaNativeMethod: #'identityHashCode(Ljava/lang/Object;)I'
        for: #{Java.java.lang.System} static: true>
    ^arg1 identityHash
!

java_lang_System_isWordsBigEndian
    <javaNativeMethod: #'isWordsBigEndian()Z'
        for: #{Java.java.lang.System} static: true>
    ^Memory bigEndian ifTrue: [ 1 ] ifFalse: [ 0 ]
!

java_lang_System_setIn0_java_io_InputStream: arg1
    <javaNativeMethod: #'setIn0(Ljava/io/InputStream;)V'
        for: #{Java.java.lang.System} static: true>
    self in: arg1
!

java_lang_System_setOut0_java_io_PrintStream: arg1
    <javaNativeMethod: #'setOut0(Ljava/io/PrintStream;)V'
        for: #{Java.java.lang.System} static: true>
    self out: arg1
!

java_lang_System_setErr0_java_io_PrintStream: arg1
    <javaNativeMethod: #'setErr0(Ljava/io/PrintStream;)V'
        for: #{Java.java.lang.System} static: true>
    self err: arg1
! !

