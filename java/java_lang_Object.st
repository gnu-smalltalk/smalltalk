"======================================================================
|
|   Java run-time support.  java.lang.Object native methods.
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


!JavaVM methodsFor: 'java.lang.Object'!

java_lang_Object_getClass
    <javaNativeMethod: #'getClass()Ljava/lang/Class;'
        for: #{Java.java.lang.Object} static: false>
    ^self class javaLangClass
!

java_lang_Object_hashCode
    <javaNativeMethod: #'hashCode()I'
        for: #{Java.java.lang.Object} static: false>
    ^self identityHash
!

java_lang_Object_notify
    | waitSemaphores |
    <javaNativeMethod: #'notify()V'
        for: #{Java.java.lang.Object} static: false>

    JavaMonitor notify: self!

java_lang_Object_notifyAll
    | waitSemaphores |
    <javaNativeMethod: #'notifyAll()V'
        for: #{Java.java.lang.Object} static: false>

    JavaMonitor notifyAll: self!

java_lang_Object_wait_long: arg1 int: arg2
    | s p waitSemaphores |
    <javaNativeMethod: #'wait(JI)V'
        for: #{Java.java.lang.Object} static: false>

    JavaMonitor waitOn: self timeout: arg1!

java_lang_Object_clone
    <javaNativeMethod: #'clone()Ljava/lang/Object;'
        for: #{Java.java.lang.Object} static: false>
    (self implementsInterface: Java.java.lang.Cloneable asJavaClass)
	ifFalse: [ JavaVM throw: Java.java.lang.CloneNotSupportedException ].

    ^self shallowCopy
! !

