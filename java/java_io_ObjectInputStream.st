"======================================================================
|
|   Java run-time support.  java.io.ObjectInputStream native methods.
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


!JavaVM methodsFor: 'java.io.ObjectInputStream'!

java_io_ObjectInputStream_allocateObject_java_lang_Class: arg1
    <javaNativeMethod: #'allocateObject(Ljava/lang/Class;)Ljava/lang/Object;'
        for: #{Java.java.io.ObjectInputStream} static: false>
    ^arg1 new
!

java_io_ObjectInputStream_callConstructor_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'callConstructor(Ljava/lang/Class;Ljava/lang/Object;)V'
        for: #{Java.java.io.ObjectInputStream} static: false>
    ^arg2 perform: (arg1 >> #'<init>()V')
! !

