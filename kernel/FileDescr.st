"======================================================================
|
|   FileDescriptor Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2005, 2006, 2007,2008
| Free Software Foundation, Inc.
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



ByteStream subclass: FileDescriptor [
    | fd file isPipe atEnd peek |
    
    <category: 'Streams-Files'>
    <comment: 'My instances are what conventional programmers think of as files.
My instance creation methods accept the name of a disk file (or any named
file object, such as /dev/rmt0 on UNIX or MTA0: on VMS).  In addition,
they accept a virtual filesystem path like `configure.gz#ugz'' which can
be used to transparently extract or decompress files from archives, or
do arbitrary processing on the files.'>

    AllOpenFiles := nil.

    FileDescriptor class >> append [
	"Open for writing.  The file is created if it does not exist.  The stream
	 is positioned at the end of the file."

	<category: 'instance creation'>
	^'a'
    ]

    FileDescriptor class >> create [
	"Open for reading and writing.  The file is created if it does not exist,
	 otherwise it is truncated.  The stream is positioned at the beginning of
	 the file."

	<category: 'instance creation'>
	^'w+'
    ]

    FileDescriptor class >> readWrite [
	"Open for reading and writing.  The stream is positioned at the beginning
	 of the file."

	<category: 'instance creation'>
	^'r+'
    ]

    FileDescriptor class >> on: fd [
	"Open a FileDescriptor on the given file descriptor.  Read-write access
	 is assumed."

	<category: 'instance creation'>
	^(self basicNew)
	    setFD: fd;
	    initialize
    ]

    FileDescriptor class >> open: fileName [
	"Open fileName in read-write mode - fail if the file cannot be opened.
	 Else answer a new FileStream.
	 The file will be automatically closed upon GC if the object is not
	 referenced anymore, but you should close it with #close anyway.
	 To keep a file open, send it #removeToBeFinalized"

	<category: 'instance creation'>
	^self open: fileName mode: FileStream readWrite
    ]

    FileDescriptor class >> open: fileName mode: fileMode [
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

	^self
	    open: fileName
	    mode: fileMode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , fileName]
    ]

    FileDescriptor class >> open: fileName mode: fileMode ifFail: aBlock [
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

	<category: 'instance creation'>
	((fileName indexOfSubCollection: '://') > 0 
	    and: [fileMode = FileStream read]) 
		ifTrue: [^NetClients.URIResolver openStreamOn: fileName ifFail: aBlock ].
	^self
	    fopen: fileName
	    mode: fileMode
	    ifFail: aBlock
    ]

    FileDescriptor class >> openTemporaryFile: baseName [
	"Open for writing a file whose name starts with baseName, followed
	 by six random alphanumeric characters.  The file is created with mode
	 read/write and permissions 0666 or 0600 on most recent operating
	 systems (beware, the former behavior might constitute a security
	 problem).  The file is opened with the O_EXCL flag, guaranteeing that
	 when the method returns successfully we are the only user."

	<category: 'instance creation'>
	^(self basicNew)
	    fileOp: 16
		with: baseName asString
		ifFail: [SystemExceptions.FileError signal: 'could not open temporary file'];
	    initialize;
	    yourself
    ]

    FileDescriptor class >> fopen: fileName mode: fileMode [
	"Open fileName in the required mode - answered by #append, #create,
	 #readWrite, #read or #write - and fail if the file cannot be opened.
	 Else answer a new FileStream. For mode anyway you can use any
	 standard C non-binary fopen mode.
	 The file will be automatically closed upon GC if the object is not
	 referenced anymore, but it is better to close it as soon as you're
	 finished with it anyway, using #close. To keep a file open even when
	 no references exist anymore, send it #removeToBeFinalized"

	<category: 'instance creation'>
	^(self basicNew)
	    fileOp: 0
		with: fileName asString
		with: fileMode
		ifFail: [SystemExceptions.FileError signal: 'could not open ' , fileName];
	    setFile: (File name: fileName);
	    initialize;
	    yourself
    ]

    FileDescriptor class >> fopen: fileName mode: fileMode ifFail: aBlock [
	"Open fileName in the required mode - answered by #append, #create,
	 #readWrite, #read or #write - and evaluate aBlock if the file cannot
	 be opened. Else answer a new FileStream. For mode anyway you can use any
	 The file will be automatically closed upon GC if the object is not
	 referenced anymore, but it is better to close it as soon as you're
	 finished with it anyway, using #close. To keep a file open even when
	 no references exist anymore, send it #removeToBeFinalized"

	<category: 'instance creation'>
	^(self basicNew)
	    fileOp: 0
		with: fileName asString
		with: fileMode
		ifFail: [^aBlock value];
	    setFile: (File name: fileName);
	    initialize;
	    yourself
    ]

    FileDescriptor class >> popen: commandName dir: direction [
	"Open a pipe on the given command and fail if the file cannot be opened.
	 Else answer a new FileStream.
	 The pipe will not be automatically closed upon GC, even if the object
	 is not referenced anymore, because when you close a pipe you have to wait
	 for the associated process to terminate.
	 direction is returned by #read or #write ('r' or 'w') and is interpreted
	 from the point of view of Smalltalk: reading means Smalltalk reads the
	 standard output of the command, writing means Smalltalk writes the standard input of the command. The other channel
	 (stdin when reading, stdout when writing) is the same as GST's, unless
	 commandName alters it."

	<category: 'instance creation'>
	^(self basicNew)
	    fileOp: 7
		with: commandName
		with: direction
		ifFail: 
		    [SystemExceptions.FileError signal: 'could not open pipe on' , commandName];
	    initialize;
	    yourself
    ]

    FileDescriptor class >> popen: commandName dir: direction ifFail: aBlock [
	"Open a pipe on the given command and evaluate aBlock
	 file cannot be opened. Else answer a new FileStream.
	 The pipe will not be automatically closed upon GC, even if the object
	 is not referenced anymore, because when you close a pipe you have to wait
	 for the associated process to terminate.
	 direction is interpreted from the point of view of Smalltalk: reading
	 means that Smalltalk reads the standard output of the command, writing
	 means that Smalltalk writes the standard input of the command"

	<category: 'instance creation'>
	^(self basicNew)
	    fileOp: 7
		with: commandName
		with: direction
		ifFail: [^aBlock value];
	    initialize;
	    yourself
    ]

    FileDescriptor class >> read [
	"Open text file for reading.  The stream is positioned at the beginning of
	 the file."

	<category: 'instance creation'>
	^'r'
    ]

    FileDescriptor class >> write [
	"Truncate file to zero length or create text file for writing.  The stream
	 is positioned at the beginning of the file."

	<category: 'instance creation'>
	^'w'
    ]

    FileDescriptor class >> initialize [
	"Initialize the receiver's class variables"

	<category: 'initialization'>
	ObjectMemory addDependent: self.
	AllOpenFiles := WeakIdentitySet new.
    ]

    FileDescriptor class >> update: aspect [
	"Close open files before quitting"

	<category: 'initialization'>
	aspect == #afterEvaluation 
	    ifTrue: 
		[stdin flush.
		stdout flush.
		stderr flush].
	aspect == #aboutToQuit 
	    ifTrue: 
		[stdin flush.
		stdout flush.
		stderr flush.
	        AllOpenFiles asArray do: [:each | each close]]
    ]

    checkError [
	"Perform error checking.  By default, we call
	 File class>>#checkError."

	<category: 'basic'>
	self isOpen ifFalse: [SystemExceptions.FileError signal: 'file closed'].
	File checkError.
	^0
    ]

    invalidate [
	"Invalidate a file descriptor"

	<category: 'basic'>
	fd := nil
    ]

    shutdown [
	"Close the transmission side of a full-duplex connection.  This is useful
	 on read-write pipes."

	<category: 'basic'>
	self isOpen ifFalse: [^self].
	self flush.
	self fileOp: 19.
	self checkError.
	access := 1
    ]

    close [
	"Close the file"

	<category: 'basic'>
	self isOpen ifFalse: [^self].
	self flush.
	self changed: #beforeClosing.
	self fileOp: 1.
	self removeToBeFinalized.
	self invalidate.
	self changed: #afterClosing
    ]

    finalize [
	"Close the file if it is still open by the time the object becomes
	 garbage."

	<category: 'basic'>
	AllOpenFiles remove: self ifAbsent: [].
	self isOpen ifFalse: [self close]
    ]

    next [
	"Return the next character in the file, or nil at eof"

	<category: 'basic'>
	| result |
	peek isNil 
	    ifFalse: 
		[collection at: 1 put: peek.
		peek := nil.
		result := 1]
	    ifTrue: 
		[result := self 
			    read: collection
			    from: 1
			    to: 1].
	^result > 0 
	    ifTrue: [collection at: 1]
	    ifFalse: 
		[atEnd := true.
		self pastEnd]
    ]

    peekFor: anObject [
	"Returns whether the next element of the stream is equal to anObject,
	 without moving the pointer if it is not."

	<category: 'basic'>
	| result |
	^self peek = anObject
	    ifTrue: [ self next ];
	    yourself
    ]

    peek [
	"Returns the next element of the stream without moving the pointer.
	 Returns nil when at end of stream."

	<category: 'basic'>
	| result |
	peek isNil ifFalse: [^peek].
	result := self 
		    read: collection
		    from: 1
		    to: 1.
	^result > 0 
	    ifTrue: [peek := collection at: 1]
	    ifFalse: 
		[atEnd := true.
		self pastEnd]
    ]

    nextByte [
	"Return the next byte in the file, or nil at eof"

	<category: 'basic'>
	| a |
	a := self next.
	^a isNil ifTrue: [a] ifFalse: [a asInteger]
    ]

    nextPut: aCharacter [
	"Store aCharacter on the file"

	<category: 'basic'>
	self write: aCharacter numBytes: 1
    ]

    nextPutByte: anInteger [
	"Store the byte, anInteger, on the file"

	<category: 'basic'>
	self nextPut: (Character value: anInteger)
    ]

    nextPutByteArray: aByteArray [
	"Store aByteArray on the file"

	<category: 'basic'>
	^self nextPutAll: aByteArray asString
    ]

    reset [
	"Reset the stream to its beginning"

	<category: 'basic'>
	self
	    checkIfPipe;
	    position: 0
    ]

    position [
	"Answer the zero-based position from the start of the file"

	<category: 'basic'>
	self checkIfPipe.
	peek isNil 
	    ifFalse: 
		[self skip: -1.
		peek := nil].
	^self fileOp: 5
    ]

    position: n [
	"Set the file pointer to the zero-based position n"

	<category: 'basic'>
	self checkIfPipe.
	peek := nil.
	^self fileOp: 4 with: n
    ]

    size [
	"Return the current size of the file, in bytes"

	<category: 'basic'>
	^self
	    checkIfPipe;
	    fileOp: 9
    ]

    truncate [
	"Truncate the file at the current position"

	<category: 'basic'>
	self
	    checkIfPipe;
	    fileOp: 10
    ]

    contents [
	"Answer the whole contents of the file"

	<category: 'basic'>
	| contents ch |
	^self isPipe 
	    ifTrue: 
		[contents := WriteStream on: (self species new: 1).
		[(ch := self next) isNil] whileFalse: [contents nextPut: ch].
		contents contents]
	    ifFalse: [^self next: self size - self position]
    ]

    copyFrom: from to: to [
	"Answer the contents of the file between the two given positions"

	<category: 'basic'>
	| savePos |
	from > to 
	    ifTrue: 
		[(from = to) + 1 ifTrue: [^self species new].
		^SystemExceptions.ArgumentOutOfRange 
		    signalOn: from
		    mustBeBetween: 0
		    and: to + 1].
	savePos := self fileOp: 5.
	^
	[self position: from.
	self next: to - from + 1] 
		ensure: [self position: savePos]
    ]

    exceptionalCondition [
	"Answer whether the file is open and an exceptional condition (such
	 as presence of out of band data) has occurred on it"

	<category: 'accessing'>
	| result |
	self isOpen ifFalse: [^false].
	result := self 
		    fileOp: 13
		    with: 2
		    ifFail: 
			[self close.
			0].
	^result == 1
    ]

    canWrite [
	"Answer whether the file is open and we can write from it"

	<category: 'accessing'>
	| result |
	self isOpen ifFalse: [^false].
	result := self 
		    fileOp: 13
		    with: 1
		    ifFail: 
			[self close.
			0].
	^result == 1
    ]

    canRead [
	"Answer whether the file is open and we can read from it"

	<category: 'accessing'>
	| result |
	self isOpen ifFalse: [^false].
	result := self 
		    fileOp: 13
		    with: 0
		    ifFail: 
			[self close.
			0].
	^result == 1
    ]

    ensureReadable [
	"If the file is open, wait until data can be read from it.  The wait
	 allows other Processes to run."

	<category: 'accessing'>
	self isPipe ifFalse: [^self].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 0
	    with: Semaphore new.
	self 
	    fileOp: 13
	    with: 0
	    ifFail: [self close]
    ]

    ensureWriteable [
	"If the file is open, wait until we can write to it.  The wait
	 allows other Processes to run."

	<category: 'accessing'>
	self 
	    fileOp: 13
	    with: 1
	    ifFail: [self close]
    ]

    waitForException [
	"If the file is open, wait until an exceptional condition (such
	 as presence of out of band data) has occurred on it.  The wait
	 allows other Processes to run."

	<category: 'accessing'>
	self isPipe ifFalse: [^self].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 2
	    with: Semaphore new.
	self 
	    fileOp: 13
	    with: 2
	    ifFail: [self close]
    ]

    isPeerAlive [
	"Present for compatibility with sockets.  For files, it answers
	 whether the file is still open"

	<category: 'accessing'>
	^self isOpen
    ]

    isOpen [
	"Answer whether the file is still open"

	<category: 'accessing'>
	^fd isInteger and: [fd positive]
    ]

    isPipe [
	"Answer whether the file is a pipe or an actual disk file"

	<category: 'accessing'>
	isPipe isNil ifTrue: [isPipe := self fileOp: 15].
	^isPipe
    ]

    fd [
	"Return the OS file descriptor of the file"

	<category: 'accessing'>
	^fd
    ]

    file [
	"Return the name of the file"

	<category: 'accessing'>
	^file
    ]

    name [
	"Return the name of the file"

	<category: 'accessing'>
	file isNil ifTrue: [^'descriptor #', fd printString ].
	^file displayString
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    nextPut: $<;
	    nextPutAll: (self isPipe ifTrue: ['Pipe'] ifFalse: [self class name]);
	    nextPutAll: ' on ';
	    nextPutAll: self name;
	    nextPut: $>
    ]

    setToEnd [
	"Reset the file pointer to the end of the file"

	<category: 'overriding inherited methods'>
	self position: self size
    ]

    skip: anInteger [
	"Skip anInteger bytes in the file"

	<category: 'overriding inherited methods'>
	| pos |
	pos := (self position + anInteger max: 0) min: self size - 1.
	self position: pos
    ]

    reverseContents [
	"Return the contents of the file from the last byte to the first"

	<category: 'overriding inherited methods'>
	^self contents reverse
    ]

    isEmpty [
	"Answer whether the receiver is empty"

	<category: 'overriding inherited methods'>
	^self size == 0
    ]

    next: n putAll: aCollection startingAt: position [
	"Put the characters in the supplied range of aCollection in the file"

	<category: 'overriding inherited methods'>
	^self 
	    write: aCollection
	    from: position
	    to: position + n - 1
    ]

    nextByteArray: anInteger [
	"Return the next 'anInteger' bytes from the stream, as a ByteArray."

	<category: 'overriding inherited methods'>
	^(self next: anInteger) asByteArray
    ]

    next: anInteger [
	"Return the next 'anInteger' characters from the stream, as a String."

	<category: 'overriding inherited methods'>
	| result n |
	result := self species new: anInteger.
	n := self read: result.
	n = 0 ifTrue: [atEnd := true].
	^n < anInteger ifTrue: [result copyFrom: 1 to: n] ifFalse: [result]
    ]

    atEnd [
	"Answer whether data has come to an end"

	<category: 'testing'>
	self isOpen ifFalse: [^true].
	self isPipe ifFalse: [^self fileOp: 6].
	atEnd isNil 
	    ifTrue: 
		[self ensureReadable.
		self peek.
		atEnd isNil ifTrue: [^false]].
	^atEnd
    ]

    checkIfPipe [
	<category: 'private'>
	self isPipe 
	    ifTrue: 
		[SystemExceptions.FileError signal: 'cannot do that to a pipe or socket.']
    ]

    setFile: aString [
	<category: 'private'>
	file := aString
    ]

    setFD: anInteger [
	<category: 'private'>
	access := 3.
	fd := anInteger.
	isPipe := nil
    ]

    basicNextByte [
	"Private - Return the next byte in the stream, or nil at eof"

	<category: 'private'>
	| a |
	a := self next.
	^a isNil ifTrue: [a] ifFalse: [a asInteger]
    ]

    basicNextPutByte: anInteger [
	"Private - Store anInteger in the file"

	<category: 'private'>
	self nextPut: anInteger asCharacter
    ]

    addToBeFinalized [
	"Add me to the list of open files."
	<category: 'initialize-release'>
	AllOpenFiles add: self.
	super addToBeFinalized
    ]

    removeToBeFinalized [
	"Remove me from the list of open files."
	<category: 'initialize-release'>
	AllOpenFiles remove: self ifAbsent: [].
	super removeToBeFinalized
    ]

    initialize [
	"Initialize the receiver's instance variables"

	<category: 'initialize-release'>
	self addToBeFinalized.
	collection := self newBuffer.
	ptr := 1.
	endPtr := 0.
	access isNil ifTrue: [access := 3].
	atEnd := false
    ]

    newBuffer [
	"Private - Answer a String to be used as the receiver's buffer"

	<category: 'initialize-release'>
	^String new: 1
    ]

    readStream [
	"Answer myself, or an alternate stream coerced for reading."
	<category: 'initialize-release'>
	^(access bitAnd: 1) = 0 
	    ifTrue: [self file readStream]
	    ifFalse: [self]
    ]

    isExternalStream [
	"We stream on an external entity (a file), so answer true"

	<category: 'class type methods'>
	^true
    ]

    isBinary [
	"We answer characters, so answer false"

	<category: 'class type methods'>
	^false
    ]

    isText [
	"We answer characters, so answer true"

	<category: 'class type methods'>
	^true
    ]

    nextHunk [
	"Answer the next buffers worth of stuff in the Stream represented
	 by the receiver.  Do at most one actual input operation."

	<category: 'low-level access'>
	| count answer |
	count := self read: (answer := String new: 1024).
	count < answer size ifTrue: [answer := answer copyFrom: 1 to: count].
	count = 0 
	    ifTrue: 
		[atEnd := true.
		^self pastEnd].
	^answer copyFrom: 1 to: count
    ]

    read: byteArray [
	"Ignoring any buffering, try to fill byteArray with the
	 contents of the file"

	<category: 'low-level access'>
	| count available |
	self ensureReadable.
	available := peek isNil ifTrue: [0] ifFalse: [1].
	peek isNil 
	    ifFalse: 
		[byteArray byteAt: 1 put: peek value.
		peek := nil].
	self isOpen ifFalse: [^available].
	count := self 
		    fileOp: 3
		    with: byteArray
		    with: available + 1
		    with: byteArray size
		    ifFail: [self checkError].
	count := count + available.
	count = 0 ifTrue: [atEnd := true].
	^count
    ]

    read: byteArray numBytes: anInteger [
	"Ignoring any buffering, try to fill anInteger bytes of byteArray
	 with the contents of the file"

	<category: 'low-level access'>
	| count available |
	self ensureReadable.
	available := peek isNil ifTrue: [0] ifFalse: [1].
	peek isNil 
	    ifFalse: 
		[byteArray byteAt: 1 put: peek value.
		peek := nil].
	self isOpen ifFalse: [^available].
	count := self 
		    fileOp: 3
		    with: byteArray
		    with: 1 + available
		    with: (anInteger min: byteArray size)
		    ifFail: [self checkError].
	count := count + available.
	count = 0 ifTrue: [atEnd := true].
	^count
    ]

    read: byteArray from: position to: end [
	"Ignoring any buffering, try to fill the given range of byteArray
	 with the contents of the file"

	<category: 'low-level access'>
	| count available |
	self ensureReadable.
	available := peek isNil ifTrue: [0] ifFalse: [1].
	peek isNil 
	    ifFalse: 
		[byteArray byteAt: position put: peek value.
		peek := nil].
	self isOpen ifFalse: [^available].
	count := self 
		    fileOp: 3
		    with: byteArray
		    with: position + available
		    with: (end min: byteArray size)
		    ifFail: [self checkError].
	count := count + available.
	count = 0 ifTrue: [atEnd := true].
	^count
    ]

    write: byteArray [
	"Ignoring any buffering, try to write the contents of byteArray in the
	 file"

	<category: 'low-level access'>
	^self 
	    write: byteArray
	    from: 1
	    to: byteArray size
    ]

    write: byteArray numBytes: anInteger [
	"Ignoring any buffering, try to write to the file the first anInteger
	 bytes of byteArray"

	<category: 'low-level access'>
	^self 
	    write: byteArray
	    from: 1
	    to: anInteger
    ]

    write: byteArray from: position to: end [
	"Ignoring any buffering, try to write to the file the given range
	 of byteArray, starting at the position-th element and ending
	 at the end-th."

	<category: 'low-level access'>
	| cur last soFar result |
	cur := position.
	last := end min: byteArray size.
	[cur <= last] whileTrue: 
		[self ensureWriteable.
		self isOpen ifFalse: [^cur - position].
		result := self 
			    fileOp: 2
			    with: byteArray
			    with: cur
			    with: last
			    ifFail: [self checkError].
		result = 0 ifTrue: [^cur - position].
		cur := cur + result].
	^cur - position
    ]

    fileIn [
        "File in the contents of the receiver.
         During a file in operation, global variables (starting with an
         uppercase letter) that are not declared don't yield an `unknown
         variable' error. Instead, they are defined as nil in the `Undeclared'
         dictionary (a global variable residing in Smalltalk).
         As soon as you add the variable to a namespace (for example by creating
         a class) the Association will be removed from Undeclared and reused
         in the namespace, so that the old references will automagically point
         to the new value."

        <category: 'built ins'>
        | pos |
	self isPipe ifTrue: [ ^super fileIn ].
        ^self
            fileInLine: 1
            file: self file full
            fileName: self name
            at: self position
    ]

    fileOp: ioFuncIndex [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 with: arg4 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 with: arg4 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'built ins'>
	<primitive: VMpr_FileDescriptor_fileOp>
	^aBlock value
    ]
]

