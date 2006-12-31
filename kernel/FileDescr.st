"======================================================================
|
|   FileDescriptor Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2005, 2006 Free Software Foundation, Inc.
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


ByteStream subclass: #FileDescriptor
		instanceVariableNames: 'file name isPipe atEnd peek'
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Streams-Files'
!

FileDescriptor comment: 
'My instances are what conventional programmers think of as files.
My instance creation methods accept the name of a disk file (or any named
file object, such as /dev/rmt0 on UNIX or MTA0: on VMS).  In addition,
they accept a virtual filesystem path like `configure.gz#ugz'' which can
be used to transparently extract or decompress files from archives, or
do arbitrary processing on the files.'
!



!FileDescriptor class methodsFor: 'instance creation'!

append
    "Open for writing.  The file is created if it does not exist.  The stream
     is positioned at the end of the file."

    ^'a'
!

create
    "Open for reading and writing.  The file is created if it does not exist,
    otherwise it is truncated.  The stream is positioned at the beginning of
    the file."

    ^'w+'
!

readWrite
    "Open for reading and writing.  The stream is positioned at the beginning
     of the file."

    ^'r+'
!

on: fd
    "Open a FileDescriptor on the given file descriptor.  Read-write access
     is assumed."
    ^self basicNew setFD: fd; initialize
!

open: fileName
    "Open fileName in read-write mode - fail if the file cannot be opened.
     Else answer a new FileStream.
     The file will be automatically closed upon GC if the object is not
     referenced anymore, but you should close it with #close anyway.
     To keep a file open, send it #removeToBeFinalized"
    ^self open: fileName mode: FileStream readWrite
!

open: fileName mode: fileMode
    "Open fileName in the required mode - answered by #append, #create,
     #readWrite, #read or #write - and fail if the file cannot be opened.
     Else answer a new FileStream. For mode anyway you can use any
     standard C non-binary fopen mode.  fileName can be a `virtual
     filesystem' path, including URLs and '#' suffixes that are
     inspected by the virtual filesystem layers and replaced with
     tasks such as un-gzipping a file or extracting a file from an
     archive.

     The file will be automatically closed upon GC if the object is not
     referenced anymore, but it is better to close it as soon as you're
     finished with it anyway, using #close. To keep a file open even when
     no references exist anymore, send it #removeToBeFinalized"

    ((fileName indexOfSubCollection: ':/') > 0 and: [
        fileMode = FileStream read ]) ifTrue: [
           ^NetClients.URIResolver openStreamOn: fileName ].

    ^(VFS.VFSHandler for: fileName)
	open: self mode: fileMode ifFail: [
 	    SystemExceptions.FileError signal: 'could not open ', fileName ]
!

open: fileName mode: fileMode ifFail: aBlock
    "Open fileName in the required mode - answered by #append, #create,
     #readWrite, #read or #write - and evaluate aBlock if the file cannot
     be opened. Else answer a new instance of the receiver. For mode
     anyway you can use any standard C non-binary fopen mode.  fileName
     can be a `virtual filesystem' path, including URLs and '#' suffixes
     that are inspected by the virtual filesystem layers and replaced with
     tasks such as un-gzipping a file or extracting a file from an
     archive.

     The file will be automatically closed upon GC if the object is not
     referenced anymore, but it is better to close it as soon as you're
     finished with it anyway, using #close. To keep a file open even when
     no references exist anymore, send it #removeToBeFinalized"

    ^(VFS.VFSHandler for: fileName)
	open: self mode: fileMode ifFail: aBlock
!

openTemporaryFile: baseName
    "Open for writing a file whose name starts with baseName, followed
     by six random alphanumeric characters.  The file is created with mode
     read/write and permissions 0666 or 0600 on most recent operating
     systems (beware, the former behavior might constitute a security
     problem).  The file is opened with the O_EXCL flag, guaranteeing that
     when the method returns successfully we are the only user."

    ^self basicNew
	fileOp: 16 with: baseName ifFail: [
 	    SystemExceptions.FileError signal: 'could not open temporary file' ];
	initialize;
	yourself
!
    
fopen: fileName mode: fileMode
    "Open fileName in the required mode - answered by #append, #create,
     #readWrite, #read or #write - and fail if the file cannot be opened.
     Else answer a new FileStream. For mode anyway you can use any
     standard C non-binary fopen mode.
     The file will be automatically closed upon GC if the object is not
     referenced anymore, but it is better to close it as soon as you're
     finished with it anyway, using #close. To keep a file open even when
     no references exist anymore, send it #removeToBeFinalized"

    ^self basicNew
	fileOp: 0 with: fileName with: fileMode ifFail: [
 	    SystemExceptions.FileError signal: 'could not open ', fileName ];
	initialize;
	yourself
!

fopen: fileName mode: fileMode ifFail: aBlock
    "Open fileName in the required mode - answered by #append, #create,
     #readWrite, #read or #write - and evaluate aBlock if the file cannot
     be opened. Else answer a new FileStream. For mode anyway you can use any
     The file will be automatically closed upon GC if the object is not
     referenced anymore, but it is better to close it as soon as you're
     finished with it anyway, using #close. To keep a file open even when
     no references exist anymore, send it #removeToBeFinalized"

    ^self basicNew
	fileOp: 0 with: fileName with: fileMode ifFail: [ ^aBlock value ];
	initialize;
	yourself
!

popen: commandName dir: direction
    "Open a pipe on the given command and fail if the file cannot be opened.
     Else answer a new FileStream.
     The pipe will not be automatically closed upon GC, even if the object
     is not referenced anymore, because when you close a pipe you have to wait
     for the associated process to terminate. To enforce automatic closing of
     the pipe, send it #addToBeFinalized.
     direction is returned by #read or #write ('r' or 'w') and is interpreted
     from the point of view of Smalltalk: reading means Smalltalk reads the
     standard output of the command, writing means Smalltalk writes the standard input of the command. The other channel
     (stdin when reading, stdout when writing) is the same as GST's, unless
     commandName alters it."

    ^self basicNew
	fileOp: 7 with: commandName with: direction ifFail: [
	    SystemExceptions.FileError signal: 'could not open pipe on', commandName ];
	initialize;
	yourself
!

popen: commandName dir: direction ifFail: aBlock
    "Open a pipe on the given command and evaluate aBlock
     file cannot be opened. Else answer a new FileStream.
     The pipe will not be automatically closed upon GC, even if the object
     is not referenced anymore, because when you close a pipe you have to wait
     for the associated process to terminate. To enforce automatic closing of
     the pipe, send it #addToBeFinalized.
     direction is interpreted from the point of view of Smalltalk: reading
     means that Smalltalk reads the standard output of the command, writing
     means that Smalltalk writes the standard input of the command"

    ^self basicNew
	fileOp: 7 with: commandName with: direction ifFail: [ ^aBlock value ];
	initialize;
	yourself
!

read
    "Open text file for reading.  The stream is positioned at the beginning of
    the file."
    ^'r'
!

write
    "Truncate file to zero length or create text file for writing.  The stream
    is positioned at the beginning of the file."
    ^'w'
! !


!FileDescriptor class methodsFor: 'initialization'!

initialize
    "Initialize the receiver's class variables"
    ObjectMemory addDependent: self
!

update: aspect
    "Close open files before quitting"
    aspect == #afterEvaluation ifTrue: [
	stdin flush. stdout flush. stderr flush
    ].
    aspect == #aboutToQuit ifTrue: [
        self allSubinstancesDo: [ :each |
	    each isOpen ifTrue: [ each close ]
	]
    ]
! !



!FileDescriptor methodsFor: 'basic'!

checkError
    "Perform error checking.  By default, we call
     File class>>#checkError."
    File checkError.
    ^0
!

invalidate
    "Invalidate a file descriptor"
    file := nil
!

close
    "Close the file"
    file isNil ifTrue: [ ^self ].

    self flush.
    self changed: #beforeClosing.
    self fileOp: 1.
    self removeToBeFinalized.
    self invalidate.
    self changed: #afterClosing.
!

finalize
    "Close the file if it is still open by the time the object becomes
    garbage."
    file isNil ifFalse: [ self close ].
!

next
    "Return the next character in the file, or nil at eof"
    | result | 
    peek isNil
	ifFalse: [ collection at: 1 put: peek. peek := nil. result := 1 ]
        ifTrue: [ result := self read: collection from: 1 to: 1 ].
    ^result > 0
	ifTrue: [ collection at: 1 ]
	ifFalse: [ atEnd := true. self pastEnd ].
!

peek
    "Returns the next element of the stream without moving the pointer.
    Returns nil when at end of stream."

    | result |
    peek isNil ifFalse: [ ^peek ].
    result := self read: collection from: 1 to: 1.
    ^result > 0
	ifTrue: [ peek := collection at: 1 ]
	ifFalse: [ atEnd := true. self pastEnd ]!

nextByte
    "Return the next byte in the file, or nil at eof"

    | a |
    a := self next.
    ^a isNil ifTrue: [ a ] ifFalse: [ a asInteger ]
!

nextPut: aCharacter
    "Store aCharacter on the file"

    self write: aCharacter numBytes: 1
!

nextPutByte: anInteger
    "Store the byte, anInteger, on the file"
    self nextPut: (Character value: anInteger)
!

nextPutByteArray: aByteArray
    "Store aByteArray on the file"
    ^self nextPutAll: aByteArray asString
!

reset
    "Reset the stream to its beginning"
    self
	checkIfPipe;
	position: 0
!

position
    "Answer the zero-based position from the start of the file"
    self checkIfPipe.
    peek isNil ifFalse: [ self skip: -1. peek := nil ].
    ^self fileOp: 5
!

position: n
    "Set the file pointer to the zero-based position n"
    self checkIfPipe.
    peek := nil.
    ^self fileOp: 4 with: n
!

size
    "Return the current size of the file, in bytes"
    ^self
	checkIfPipe;
	fileOp: 9
!

truncate
    "Truncate the file at the current position"
    self
	checkIfPipe;
	fileOp: 10.
!

contents
    "Answer the whole contents of the file"
    | contents ch |
    ^self isPipe
	ifTrue: [
	    contents := WriteStream on: (self species new: 1).
	    [ (ch := self next) isNil ]
		whileFalse: [ contents nextPut: ch ].
	    contents contents
	]
	ifFalse: [ ^self next: self size - self position ]
!

copyFrom: from to: to
    "Answer the contents of the file between the two given positions"
    | savePos |
    from > to ifTrue: [
        from = to + 1 ifTrue: [ ^self species new ].
        ^SystemExceptions.ArgumentOutOfRange signalOn: from mustBeBetween: 0 and: to + 1
    ].
    savePos := self fileOp: 5.
    ^[
        self position: from.
        self next: to - from + 1
    ] ensure: [
        self position: savePos
    ]
! !


!FileDescriptor methodsFor: 'accessing'!

exceptionalCondition
    "Answer whether the file is open and an exceptional condition (such
     as presence of out of band data) has occurred on it"
    | result |
    self isOpen ifFalse: [ ^false ].
    result := self fileOp: 13 with: 2 ifFail: [ self close. 0 ].
    ^result == 1
!

canWrite
    "Answer whether the file is open and we can write from it"
    | result |
    self isOpen ifFalse: [ ^false ].
    result := self fileOp: 13 with: 1 ifFail: [ self close. 0 ].
    ^result == 1
!

canRead
    "Answer whether the file is open and we can read from it"
    | result |
    self isOpen ifFalse: [ ^false ].
    result := self fileOp: 13 with: 0 ifFail: [ self close. 0 ].
    ^result == 1
!

ensureReadable
    "If the file is open, wait until data can be read from it.  The wait
     allows other Processes to run."
    self isPipe ifFalse: [ ^self ].
    self isOpen ifFalse: [ ^self ].

    self fileOp: 14 with: 0 with: Semaphore new.
    self fileOp: 13 with: 0 ifFail: [ self close ].
!

ensureWriteable
    "If the file is open, wait until we can write to it.  The wait
     allows other Processes to run."

    "2002-02-07 commented out the code below because not all devices
     support sending SIGIO's when they become writeable -- notably,
     tty's under Linux :-("

    "self isPipe ifFalse: [ ^self ].
    self isOpen ifFalse: [ ^self ].

    self fileOp: 14 with: 1 with: Semaphore new"
    self fileOp: 13 with: 1 ifFail: [ self close ].
!

waitForException
    "If the file is open, wait until an exceptional condition (such
     as presence of out of band data) has occurred on it.  The wait
     allows other Processes to run."
    self isPipe ifFalse: [ ^self ].
    self isOpen ifFalse: [ ^self ].

    self fileOp: 14 with: 2 with: Semaphore new.
    self fileOp: 13 with: 2 ifFail: [ self close ].
!

isOpen 
    "Answer whether the file is still open"
    ^file isInteger and: [ file positive ]
!

isPipe
    "Answer whether the file is a pipe or an actual disk file"
    isPipe isNil ifTrue: [ isPipe := self fileOp: 15 ].
    ^isPipe
!

fd
    "Return the OS file descriptor of the file"
    ^file
!

name
    "Return the name of the file"
    ^name
! !


!FileDescriptor methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"
    | text |
    text := name isNil
	ifTrue: [ 'File descriptor #', file printString ]
	ifFalse: [ (self isPipe ifTrue: ['Pipe on '] ifFalse: ['File ']),
		   name ].

    aStream
	nextPut: $<;
	nextPutAll: text;
	nextPut: $>
! !

    

!FileDescriptor methodsFor: 'overriding inherited methods'!

setToEnd
    "Reset the file pointer to the end of the file"
    self position: self size
!

skip: anInteger
    "Skip anInteger bytes in the file"
    | pos |
    pos := ((self position + anInteger) max: 0) min: self size - 1.
    self position: pos
!

reverseContents
    "Return the contents of the file from the last byte to the first"
    ^self contents reverse
!

isEmpty
    "Answer whether the receiver is empty"
    ^self size == 0
!

nextPutAll: aCollection
    "Put all the characters in aCollection in the file"
    self write: aCollection asString
!

nextPutAllFlush: aCollection
    "Put all the characters in aCollection in the file.  For compatibility
     with FileStream (FileDescriptor is not buffered, thus this method is
     equivalent to nextPutAll:"
    self write: aCollection asString
!

nextByteArray: anInteger
    "Return the next 'anInteger' bytes from the stream, as a ByteArray."
    ^(self next: anInteger) asByteArray
!

next: anInteger
    "Return the next 'anInteger' characters from the stream, as a String."
    | result n |
    result := self species new: anInteger.
    n := self read: result.

    n = 0
	ifTrue: [ atEnd := true ].
    ^n < anInteger
	ifTrue: [ collection copyFrom: 1 to: n ]
	ifFalse: [ collection ].
! !




!FileDescriptor methodsFor: 'testing'!

atEnd
    "Answer whether data has come to an end"
    self isOpen ifFalse: [ ^true ].
    self isPipe ifFalse: [ ^self fileOp: 6 ].
    atEnd isNil ifTrue: [
        self ensureReadable.
	self peek.
	atEnd isNil ifTrue: [ ^false ] ].
    ^atEnd
!

isExternalStream
    "Answer whether the receiver streams on a file or socket."
    ^true
! !


!FileDescriptor methodsFor: 'private'!

checkIfPipe
    self isPipe ifTrue: [
	SystemExceptions.FileError signal:
	    'cannot do that to a pipe or socket.' ]
!

setFD: fd
    access := 3.
    file := fd.
    name := 'descriptor #', fd printString.
    isPipe := nil
!

basicNextByte
    "Private - Return the next byte in the stream, or nil at eof"

    | a |
    a := self next.
    ^a isNil ifTrue: [ a ] ifFalse: [ a asInteger ]
!

basicNextPutByte: anInteger
    "Private - Store anInteger in the file"

    self nextPut: anInteger asCharacter
! !


!FileDescriptor methodsFor: 'initialize-release'!

initialize
    "Initialize the receiver's instance variables"
    self addToBeFinalized.
    collection := self newBuffer.
    ptr := 1.
    endPtr := 0.
    access isNil ifTrue: [ access := 3 ].
    atEnd := false.
!

newBuffer
    "Private - Answer a String to be used as the receiver's buffer"
    ^String new: 1
! !


!FileDescriptor methodsFor: 'class type methods'!

isExternalStream
    "We stream on an external entity (a file), so answer true"
    ^true
!

isBinary
    "We answer characters, so answer false"
    ^false
!

isText
    "We answer characters, so answer true"
    ^true
! !


!FileDescriptor methodsFor: 'low-level access'!

nextHunk
    "Answer the next buffers worth of stuff in the Stream represented
     by the receiver.  Do at most one actual input operation."

    | count answer |
    count := self read: (answer := String new: 1024).
    count < answer size ifTrue: [ answer := answer copyFrom: 1 to: count ].
    count = 0 ifTrue: [ atEnd := true. ^self pastEnd ].
    ^answer copyFrom: 1 to: count!

read: byteArray
    "Ignoring any buffering, try to fill byteArray with the
     contents of the file"
    | count available |
    self ensureReadable.
    available := peek isNil ifTrue: [ 0 ] ifFalse: [ 1 ].
    count := self
	fileOp: 3
	with: byteArray
        with: available + 1
	with: byteArray size
	ifFail: [ self checkError ].

    peek isNil ifFalse: [
	byteArray byteAt: 1 put: peek value. peek := nil ].

    count := count + available.
    count = 0 ifTrue: [ atEnd := true ].
    ^count
!

read: byteArray numBytes: anInteger
    "Ignoring any buffering, try to fill anInteger bytes of byteArray
     with the contents of the file"
    | count available |
    self ensureReadable.
    available := peek isNil ifTrue: [ 0 ] ifFalse: [ 1 ].
    count := self
	fileOp: 3
	with: byteArray
        with: 1 + available
	with: (anInteger min: byteArray size)
	ifFail: [ self checkError ].

    peek isNil ifFalse: [
	byteArray byteAt: 1 put: peek value. peek := nil ].

    count := count + available.
    count = 0 ifTrue: [ atEnd := true ].
    ^count
!

read: byteArray from: position to: end
    "Ignoring any buffering, try to fill the given range of byteArray
     with the contents of the file"
    | count available |
    self ensureReadable.
    available := peek isNil ifTrue: [ 0 ] ifFalse: [ 1 ].
    count := self
	fileOp: 3
	with: byteArray
        with: position + available
	with: (end min: byteArray size)
	ifFail: [ self checkError ].

    peek isNil ifFalse: [
	byteArray byteAt: 1 put: peek value. peek := nil ].

    count := count + available.
    count = 0 ifTrue: [ atEnd := true ].
    ^count
!

write: byteArray
    "Ignoring any buffering, try to write the contents of byteArray in the
     file"
    ^self write: byteArray from: 1 to: byteArray size
!

write: byteArray numBytes: anInteger
    "Ignoring any buffering, try to write to the file the first anInteger
     bytes of byteArray"
    ^self write: byteArray from: 1 to: anInteger
!

write: byteArray from: position to: end
    "Ignoring any buffering, try to write to the file the given range
     of byteArray, starting at the position-th element and ending
     at the end-th."
    | cur last soFar result |
    cur := position.
    last := end min: byteArray size.
    [ cur <= last ] whileTrue: [
        self ensureWriteable.
        result := self
	    fileOp: 2
	    with: byteArray
            with: cur
	    with: last
	    ifFail: [ self checkError ].

	result = 0 ifTrue: [ ^cur - position ].
        cur := cur + result.
    ].
    ^cur - position
! !
