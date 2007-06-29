"======================================================================
|
|   Java run-time support.  java.io.FileDescriptor native methods.
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


!JavaVM methodsFor: 'java.io.FileDescriptor'!

convertToSmalltalkFD
    <javaNativeMethod: #asFileDescriptor
        for: #{Java.java.io.FileDescriptor} static: false>
    ^JavaVM fileDescriptorFor: self fd!

java_io_FileDescriptor_init
    <javaNativeMethod: #'init()V'
        for: #{Java.java.io.FileDescriptor} static: true>
    self in: self new.
    self in perform: #'<init>(I)V' with: 0.
    self out: self new.
    self out perform: #'<init>(I)V' with: 1.
    self err: self new.
    self err perform: #'<init>(I)V' with: 2.
!

java_io_FileDescriptor_sync
    <javaNativeMethod: #'sync()V'
        for: #{Java.java.io.FileDescriptor} static: false>
    "TODO: use fsync ..."
!

java_io_FileDescriptor_valid
    <javaNativeMethod: #'valid()Z'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self fd >= 0 "TODO: check with fstat ..."
!

java_io_FileDescriptor_open_java_lang_String: arg1 int: arg2
    | mode |
    <javaNativeMethod: #'open(Ljava/lang/String;I)I'
        for: #{Java.java.io.FileDescriptor} static: false>
    mode := #('w' 'r' 'w' 'w+' 'a' 'a+' 'a' 'a+')
        at: arg2 \\ 8 + 1.

    ^JavaFileDescriptor fopen: arg1 mode: mode ifFail: [
        | exception msg errno |
        errno := File errno.
        errno < 1 ifTrue: [ ^0 ].
        msg := (self stringError: errno) asJavaString.
        exception := Java.java.io.FileNotFoundException new.
        exception perform: #'<init>(Ljava/lang/String;)V' with: msg.
        exception throw ]
!

java_io_FileDescriptor_write_int: arg1
    <javaNativeMethod: #'write(I)V'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor
	write: (ByteArray with: arg1) from: 1 to: 1
!

java_io_FileDescriptor_write_byteArray: arg1 int: arg2 int: arg3
    | array |
    <javaNativeMethod: #'write([BII)V'
        for: #{Java.java.io.FileDescriptor} static: false>
    array := ByteArray new: arg3.
    array replaceFrom: 1 to: arg3 with: arg1 startingAt: arg2 + 1.
    ^self asFileDescriptor write: array from: 1 to: arg3
!

java_io_FileDescriptor_close
    <javaNativeMethod: #'close()V'
        for: #{Java.java.io.FileDescriptor} static: false>
    self asFileDescriptor close
!

java_io_FileDescriptor_setLength_long: arg1
    | delta fd position |
    <javaNativeMethod: #'setLength(J)V'
        for: #{Java.java.io.FileDescriptor} static: false>
    fd := self asFileDescriptor.
    delta := fd size - arg1.
    delta = 0 ifTrue: [ ^self ].
    delta < 0 ifTrue: [ fd position: arg1; truncate. ^self ].

    "If the file is too short, we extend it.  We can't rely on
     ftruncate() extending the file.  So we lseek() to 1 byte less
     than we want, and then we write a single byte at the end."
    position := fd position.
    fd position: arg1 - 1.
    fd write: #[0].
    fd position: position
!

java_io_FileDescriptor_seek_long: arg1 int: arg2 boolean: arg3
    | pos fd |
    <javaNativeMethod: #'seek(JIZ)I'
        for: #{Java.java.io.FileDescriptor} static: false>
    fd := self asFileDescriptor.
    pos := arg1.
    arg2 = 0 ifFalse: [ pos := pos + fd position ].
    arg3 = 1 ifTrue: [ pos := pos min: fd size  ].
    fd position: pos.
    ^pos
!

java_io_FileDescriptor_getLength
    <javaNativeMethod: #'getLength()J'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor size
!

java_io_FileDescriptor_getFilePointer
    <javaNativeMethod: #'getFilePointer()J'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor position
!

java_io_FileDescriptor_read
    <javaNativeMethod: #'read()I'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor next value
!

java_io_FileDescriptor_read_byteArray: arg1 int: arg2 int: arg3
    | array count |
    <javaNativeMethod: #'read([BII)I'
        for: #{Java.java.io.FileDescriptor} static: false>
    array := ByteArray new: arg3.
    count := self asFileDescriptor read: array from: 1 to: arg3.
    arg1 replaceFrom: arg1 + 1 to: arg1 + count with: array startingAt: 1.
    ^count
!

java_io_FileDescriptor_available
    <javaNativeMethod: #'available()I'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor canRead
	ifTrue: [ 1 ]
	ifFalse: [ 0 ]
! !

