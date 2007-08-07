"======================================================================
|
|   Virtual File System for ZIP files
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Namespace current: Kernel!

VFS.ArchiveFileHandler subclass: #ZipFileHandler
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ZipFileHandler comment: 'ZipFileHandler transparently extracts
files from a ZIP archive.'!

VFS.ArchiveMemberHandler subclass: #StoredZipMember
       instanceVariableNames: 'offset'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

StoredZipMember comment: 'ArchiveMemberHandler is the handler
class for stored ZIP archive members, which are optimized.'!

Stream subclass: #LimitedStream
       instanceVariableNames: 'stream offset limit'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

LimitedStream comment: 'I provide a view of a part of a substream.'!

!ZipFileHandler class methodsFor: 'registering'!

priority
    "Answer the priority for this class (higher number = higher priority) in
     case multiple classes implement the same file system."
    ^-10!

fileSystems
    "Answer the virtual file systems that can be processed by this subclass."
    ^#('uzip')! !

!ZipFileHandler methodsFor: 'members'!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."

    self notYetImplemented!

member: anArchiveMemberHandler mode: bits
    "Set the permission bits for the file in anArchiveMemberHandler."

    self notYetImplemented!

extractMember: anArchiveMemberHandler into: temp
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."
    Smalltalk system: ('unzip -p %1 %2 > %3'
	% { self realFileName. anArchiveMemberHandler name. temp name })!

removeMember: anArchiveMemberHandler
    "Remove the member represented by anArchiveMemberHandler."

    Smalltalk system: ('zip -d %1 %2'
	% { self realFileName. anArchiveMemberHandler name. })!

updateMember: anArchiveMemberHandler
    "Update the member represented by anArchiveMemberHandler by
     copying the file into which it was extracted back to the
     archive."

    self notYetImplemented!

centralDirectoryOf: f
    | r beginCD size comLen buf ofsCD |
    size := f size.
    r := 21.

    "Great idea, that of putting a variable-length item at the end.  Luckily,
     we can make a sanity check of the data and find the correct spot of the
     central directory's final record."
    size - 22 to: size - 65535 - 22 by: -257 do: [ :pos |
        buf := (f copyFrom: pos to: pos + r) asByteArray.
        beginCD := buf indexOfSubCollection: #[16r50 16r4B 5 6] ifAbsent: [ 0 ].
        beginCD = 0 ifFalse: [
            comLen := (buf at: beginCD + 21) * 256 + (buf at: beginCD + 20).
            (pos + beginCD + 21 + comLen) = size ifTrue: [
                ofsCD := ((buf at: beginCD + 19) * 16777216)
                     + ((buf at: beginCD + 18) * 65536)
                     + ((buf at: beginCD + 17) * 256)
                     + (buf at: beginCD + 16).

                ^(f copyFrom: ofsCD to: pos + beginCD - 2) asByteArray ] ].

        r := 278 ].

    self error: 'invalid data in ZIP file'
!

files
    "Extract the directory listing from the archive"

    ^Generator on: [ :gen |
	| f cd data path date method dataSize fileSize fnsize extra comment attr ofs |
	f := self open: FileStream read ifFail: [
	    self error: 'cannot open file for input' ].
        cd := ByteStream on: (self centralDirectoryOf: f).
	f close.

        date := DateTime now.
        [ cd atEnd ] whileFalse: [
	    cd skip: 10.
	    method := cd nextUshort.
	    data := method = 0
		ifTrue: [ Array new: 5 ]
		ifFalse: [ Array new: 4 ].

	    data at: 3 put: date.

	    cd skip: 12.
	    data at: 2 put: cd nextUlong.
	    fnsize := cd nextUshort.
	    extra := cd nextUshort.
	    comment := cd nextUshort.
	    cd skip: 4.
	    attr := cd nextUlong.
	    ofs := cd nextUlong.

	    data at: 1 put: (cd next: fnsize).
	    cd skip: extra + comment.

	    data at: 4 put: (attr bitAnd: 16) = 16.
	    method = 0 ifTrue: [
		data at: 5 put: (StoredZipMember new
		    name: (data at: 1);
		    parent: self;
		    offset: ofs;
		    yourself) ].

	    gen yield: data ] ]! !

!StoredZipMember methodsFor: 'accessing'!

offset
    ^offset!

offset: anInteger
    offset := anInteger!

!StoredZipMember methodsFor: 'opening'!

open: class mode: mode ifFail: aBlock
    | file |
    mode = FileStream read ifFalse: [ ^self notYetImplemented ].
    file := self parent open: class mode: mode ifFail: [ ^aBlock value ].
    file skip: self offset + 26.
    file skip: file nextUshort + file nextUshort.
    file setName: self fullName.
    ^LimitedStream on: file from: file position to: file position + self size - 1! !

!LimitedStream class methodsFor: 'instance creation'!

on: aStream from: start to: end
    ^self new
	stream: aStream;
	offset: start;
	limit: end + 1;
	yourself!

!LimitedStream methodsFor: 'stream operations'!

atEnd
    ^stream position >= limit or: [ stream atEnd ]!

copyFrom: start to: end
    (start between: 0 and: limit - offset)
        ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: start ].
    (end between: 0 and: limit - offset)
        ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: end ].
    ^stream copyFrom: offset + start to: offset + end!

isPositionable
    ^true!

next
    self atEnd ifTrue: [ ^self pastEnd ].
    ^stream next!

nextHunk
    ^stream next: (1024 min: limit - stream position)!

peek
    self atEnd ifTrue: [ ^nil ].
    ^stream peek!

peekFor: aCharacter
    self atEnd ifTrue: [ ^false ].
    ^stream peek!

position
    ^stream position - offset!

position: anInteger
    (anInteger between: 0 and: limit - offset)
        ifTrue: [ stream position: offset + anInteger ]
        ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger ]!

setToEnd
    stream position: limit!

size
    ^limit - offset!

skip: anInteger
    self position: anInteger + self position! !

!LimitedStream methodsFor: 'printing'!

printOn: aStream
    aStream
	print: stream;
	nextPut: $[;
	print: offset;
	nextPut: $:;
	print: limit;
	nextPut: $]! !

!LimitedStream methodsFor: 'accessing'!

name
    ^stream name!

species
    ^stream species!

stream: aStream
    stream := aStream!

limit: anInteger
    limit := anInteger!

offset: anInteger
    offset := anInteger! !


Namespace current: Smalltalk!

Kernel.ZipFileHandler register!
