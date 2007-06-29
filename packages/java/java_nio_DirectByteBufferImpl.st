"======================================================================
|
|   Java run-time support.  java.nio.DirectByteBufferImpl native methods.
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


!JavaVM methodsFor: 'java.nio.DirectByteBufferImpl'!

java_nio_DirectByteBufferImpl_allocateImpl_int: arg1
    <javaNativeMethod: #'allocateImpl(I)Lgnu/gcj/RawData;'
        for: #{Java.java.nio.DirectByteBufferImpl} static: true>
    "We map the gnu.gcj.RawData class to a Smalltalk CObject."
    ^CObject alloc: arg1 type: CByteType
!

java_nio_DirectByteBufferImpl_freeImpl_gnu_gcj_RawData: arg1
    <javaNativeMethod: #'freeImpl(Lgnu/gcj/RawData;)V'
        for: #{Java.java.nio.DirectByteBufferImpl} static: true>
    arg1 free
!

java_nio_DirectByteBufferImpl_getImpl_int: arg1
    <javaNativeMethod: #'getImpl(I)B'
        for: #{Java.java.nio.DirectByteBufferImpl} static: false>
    ^self address at: arg1
!

java_nio_DirectByteBufferImpl_putImpl_int: arg1 byte: arg2
    <javaNativeMethod: #'putImpl(IB)V'
        for: #{Java.java.nio.DirectByteBufferImpl} static: false>
    ^self address at: arg1 put: (arg2 bitAnd: 255)
! !
