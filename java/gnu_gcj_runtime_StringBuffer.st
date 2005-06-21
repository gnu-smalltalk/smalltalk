"======================================================================
|
|   Java run-time support.  gnu.gcj.runtime.StringBuffer native methods.
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


!JavaVM methodsFor: 'gnu.gcj.runtime.StringBuffer'!

gnu_gcj_runtime_StringBuffer_append_int: arg1
    | s newValue needed |
    <javaNativeMethod: #'append(I)Lgnu/gcj/runtime/StringBuffer;'
        for: #{Java.gnu.gcj.runtime.StringBuffer} static: false>
    s := arg1 printString asByteArray.

    needed = self count + s size.
    self value size < needed ifTrue: [
        newValue := self value copyEmpty: (needed max: self value size * 2 + 2).
	newValue replaceFrom: 1 to: self count with: self value startingAt: 1.
	self value: newValue
    ].
    self value replaceFrom: self count + 1 to: needed with: s startingAt: 1.
    self count: needed.
    ^self
!

gnu_gcj_runtime_StringBuffer_toString
    <javaNativeMethod: #'toString()Ljava/lang/String;'
        for: #{Java.gnu.gcj.runtime.StringBuffer} static: false>
    ^Java.java.lang.String new
    	perform: #'<init>(Lgnu/gcj/runtime/StringBuffer;)V'
	with: self;

	yourself
! !
