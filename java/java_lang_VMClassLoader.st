"======================================================================
|
|   Java run-time support.  java.lang.VMClassLoader native methods.
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


!JavaVM methodsFor: 'java.lang.VMClassLoader'!

java_lang_VMClassLoader_defineClass_java_lang_ClassLoader: arg1 java_lang_String: arg2 byteArray: arg3 int: arg4 int: arg5 java_security_ProtectionDomain: arg6
    <javaNativeMethod: #'defineClass(Ljava/lang/ClassLoader;Ljava/lang/String;[BIILjava/security/ProtectionDomain;)Ljava/lang/Class;'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
!

java_lang_VMClassLoader_linkClass0_java_lang_Class: arg1
    <javaNativeMethod: #'linkClass0(Ljava/lang/Class;)V'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
!

java_lang_VMClassLoader_markClassErrorState0_java_lang_Class: arg1
    <javaNativeMethod: #'markClassErrorState0(Ljava/lang/Class;)V'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
!

java_lang_VMClassLoader_getPrimitiveClass_char: arg1
    <javaNativeMethod: #'getPrimitiveClass(C)Ljava/lang/Class;'
        for: #{Java.java.lang.VMClassLoader} static: true>
    arg1 == $I asInteger ifTrue: [ ^IntClass ].
    arg1 == $B asInteger ifTrue: [ ^ByteClass ].
    arg1 == $S asInteger ifTrue: [ ^ShortClass ].
    arg1 == $J asInteger ifTrue: [ ^LongClass ].
    arg1 == $F asInteger ifTrue: [ ^FloatClass ].
    arg1 == $D asInteger ifTrue: [ ^DoubleClass ].
    arg1 == $V asInteger ifTrue: [ ^VoidClass ].
    arg1 == $Z asInteger ifTrue: [ ^BooleanClass ].
    arg1 == $C asInteger ifTrue: [ ^CharClass ].
    ^nil
!

java_lang_VMClassLoader_getSystemClassLoaderInternal
    <javaNativeMethod: #'getSystemClassLoaderInternal()Ljava/lang/ClassLoader;'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
! !
