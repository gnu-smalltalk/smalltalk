"======================================================================
|
|   Java run-time support.  java.nio.channels.FileChannelImpl native methods.
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


!JavaVM methodsFor: 'java.nio.channels.FileChannelImpl'!

java_nio_channels_FileChannelImpl_implPosition
    <javaNativeMethod: #'implPosition()J'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    ^self fd asFileDescriptor position
!

java_nio_channels_FileChannelImpl_implPosition_long: arg1
    | desc |
    <javaNativeMethod: #'implPosition(J)Ljava/nio/channels/FileChannel;'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    desc := self fd asFileDescriptor.
    desc position: (arg1 min: desc size)
!

java_nio_channels_FileChannelImpl_implTruncate_long: arg1
    | delta fd position |
    <javaNativeMethod: #'implTruncate(J)Ljava/nio/channels/FileChannel;'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    fd := self fd asFileDescriptor.
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

java_nio_channels_FileChannelImpl_nio_mmap_file_long: arg1 long: arg2 int: arg3
    <javaNativeMethod: #'nio_mmap_file(JJI)Lgnu/gcj/RawData;'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    self notYetImplemented
!

java_nio_channels_FileChannelImpl_nio_unmmap_file_gnu_gcj_RawData: arg1 int: arg2
    <javaNativeMethod: #'nio_unmmap_file(Lgnu/gcj/RawData;I)V'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    self notYetImplemented
!

java_nio_channels_FileChannelImpl_nio_msync_gnu_gcj_RawData: arg1 int: arg2
    <javaNativeMethod: #'nio_msync(Lgnu/gcj/RawData;I)V'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    self notYetImplemented
!

java_nio_channels_FileChannelImpl_size
    <javaNativeMethod: #'size()J'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    ^self fd asFileDescriptor size
!

java_nio_channels_FileChannelImpl_implRead_byteArray: arg1 int: arg2 int: arg3
    | array count |
    <javaNativeMethod: #'implRead([BII)I'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    array := ByteArray new: arg3.
    count := self fd asFileDescriptor read: array from: 1 to: arg3.
    arg1 replaceFrom: arg1 + 1 to: arg1 + count with: array startingAt: 1.
    ^count
!

java_nio_channels_FileChannelImpl_implWrite_byteArray: arg1 int: arg2 int: arg3
    | array |
    <javaNativeMethod: #'implWrite([BII)I'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    array := ByteArray new: arg3.
    array replaceFrom: 1 to: arg3 with: arg1 startingAt: arg2 + 1.
    ^self fd asFileDescriptor write: array from: 1 to: arg3
! !

