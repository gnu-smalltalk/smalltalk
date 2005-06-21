"======================================================================
|
|   Java run-time support.  gnu.gcj.runtime.StackTrace native methods.
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


!JavaVM methodsFor: 'gnu.gcj.runtime.StackTrace'!

gnu_gcj_runtime_StackTrace_classAt_int: arg1
    | ctx |
    <javaNativeMethod: #'classAt(I)Ljava/lang/Class;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: false>
    ctx := self addrs at: arg1 + 1 ifAbsent: [ nil ].
    ctx isNil ifTrue: [ ^nil ].
    "ctx receiver class gets the class or metaclass,
     asClass            gets the class also for static methods,
     javaLangClass      converts to a java.lang.Class"
    ^ctx receiver class asClass javaLangClass
!

gnu_gcj_runtime_StackTrace_methodAt_int: arg1
    | ctx |
    <javaNativeMethod: #'methodAt(I)Ljava/lang/String;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: false>
    ctx := self addrs at: arg1 + 1 ifAbsent: [ nil ].
    ctx isNil ifTrue: [ ^nil ].
    ^ctx selector asString
!

gnu_gcj_runtime_StackTrace_getClass_gnu_gcj_RawData: arg1
    <javaNativeMethod: #'getClass(Lgnu/gcj/RawData;)Ljava/lang/Class;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: true>
    self notYetImplemented
!

gnu_gcj_runtime_StackTrace_update
    <javaNativeMethod: #'update()V'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: true>
!

gnu_gcj_runtime_StackTrace_fillInStackTrace_int: arg1 int: arg2
    | newAddrs ctx |
    <javaNativeMethod: #'fillInStackTrace(II)V'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: false>
    newAddrs := Array new: (arg1 + arg2 - 1 max: self addrs size).
    newAddrs replaceFrom: 1 to: self addrs size with: self addrs startingAt: 1.
    self addrs: newAddrs.

    ctx := arg2 = 1 ifTrue: [ thisContext ] ifFalse: [ self addrs at: arg2 - 1 ].
    arg2 to: arg2 + arg1 - 1 do: [ :each |
	[
	    ctx := ctx parentContext.
	    ctx isNil ifTrue: [ self len: each - arg2 - 1. ^self len ].
	    ctx class isKindOf: JavaObject
	] whileFalse.
	newAddrs at: each put: ctx
    ].
    self len: arg1.
    ^arg1 + 1
!

gnu_gcj_runtime_StackTrace_getCompiledMethodRef_gnu_gcj_RawData: arg1
    <javaNativeMethod: #'getCompiledMethodRef(Lgnu/gcj/RawData;)Lgnu/gcj/runtime/MethodRef;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: true>
    self notYetImplemented
! !
