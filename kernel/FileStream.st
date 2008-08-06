"======================================================================
|
|   FileStream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2006,2008
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



FileDescriptor subclass: FileStream [
    | collection ptr endPtr writePtr writeEnd |
    
    <category: 'Streams-Files'>
    <comment: 'My instances are what conventional programmers think of as files.
My instance creation methods accept the name of a disk file (or any named
file object, such as /dev/rmt0 on UNIX or MTA0: on VMS).'>

    Verbose := nil.
    Record := nil.
    Includes := nil.

    FileStream class >> stderr [
	"Answer a FileStream that is attached the Smalltalk program's standard
	 error file handle, which can be used for error messages and diagnostics
	 issued by the program."

	<category: 'standard streams'>
	^stderr
    ]

    FileStream class >> stdin [
	"Answer a FileStream that is attached the Smalltalk program's standard
	 input file handle, which is the normal source of input for the program."

	<category: 'standard streams'>
	^stdin
    ]

    FileStream class >> stdout [
	"Answer a FileStream that is attached the Smalltalk program's standard
	 output file handle; this is used for normal output from the program."

	<category: 'standard streams'>
	^stdout
    ]

    FileStream class >> initialize [
	"Private - Initialize the receiver's class variables"

	<category: 'file-in'>
	Record := Verbose := false
    ]

    FileStream class >> fileIn: aFileName [
	"File in the aFileName file. During a file in operation, global variables
	 (starting with an uppercase letter) that are not declared yet don't yield
	 an `unknown variable' error. Instead, they are defined as nil in the
	 `Undeclared' dictionary (a global variable residing in Smalltalk).
	 As soon as you add the variable to a namespace (for example by creating
	 a class) the Association will be removed from Undeclared and reused
	 in the namespace, so that the old references will automagically point
	 to the new value."

	<category: 'file-in'>
	| oldIncludes newCollection file stream |
	Verbose 
	    ifTrue: 
		[Transcript
		    nextPutAll: 'Loading ' , aFileName;
		    nl].
	Record 
	    ifTrue: 
		[newCollection := OrderedCollection new.
		Includes add: aFileName -> newCollection.
		oldIncludes := Includes.
		Includes := newCollection].
	stream := self open: aFileName mode: FileStream read.
	[ stream fileIn ] ensure: [
	    stream close.
	    Record ifTrue: [Includes := oldIncludes] ]
    ]

    FileStream class >> fileIn: aFileName line: lineInteger from: realFileName at: aCharPos [
	"File in the aFileName file giving errors such as if it was loaded
	 from the given line, file name and starting position (instead of 1)."

	<category: 'file-in'>
	(self open: aFileName mode: FileStream read)
	    fileInLine: lineInteger
		fileName: realFileName
		at: aCharPos;
	    close
    ]

    FileStream class >> fileIn: aFileName ifMissing: aSymbol [
	"Conditionally do a file in, only if the key (often a class) specified
	 by 'aSymbol' is not present in the Smalltalk system dictionary already.
	 During a file in operation, global variables (starting with an
	 uppercase letter) that are not declared don't yield an `unknown
	 variable' error. Instead, they are defined as nil in the `Undeclared'
	 dictionary (a global variable residing in Smalltalk).
	 As soon as you add the variable to a namespace (for example by creating
	 a class) the Association will be removed from Undeclared and reused
	 in the namespace, so that the old references will automagically point
	 to the new value."

	<category: 'file-in'>
	Smalltalk at: aSymbol ifAbsent: [self fileIn: aFileName]
    ]

    FileStream class >> fileIn: aFileName ifTrue: aBoolean [
	"Conditionally do a file in, only if the supplied boolean is true.
	 During a file in operation, global variables (starting with an
	 uppercase letter) that are not declared don't yield an `unknown
	 variable' error. Instead, they are defined as nil in the `Undeclared'
	 dictionary (a global variable residing in Smalltalk).
	 As soon as you add the variable to a namespace (for example by creating
	 a class) the Association will be removed from Undeclared and reused
	 in the namespace, so that the old references will automagically point
	 to the new value."

	<category: 'file-in'>
	aBoolean ifTrue: [self fileIn: aFileName]
    ]

    FileStream class >> require: assoc [
	"Conditionally do a file in from the value of assoc, only if the
	 key of assoc is not present in the Smalltalk system dictionary already.
	 During a file in operation, global variables (starting with an
	 uppercase letter) that are not declared don't yield an `unknown
	 variable' error. Instead, they are defined as nil in the `Undeclared'
	 dictionary (a global variable residing in Smalltalk).
	 As soon as you add the variable to a namespace (for example by creating
	 a class) the Association will be removed from Undeclared and reused
	 in the namespace, so that the old references will automagically point
	 to the new value."

	<category: 'file-in'>
	Smalltalk at: assoc key ifAbsent: [self fileIn: assoc value]
    ]

    FileStream class >> verbose: verboseFlag [
	"Set whether Smalltalk should output debugging messages when filing in"

	<category: 'file-in'>
	| oldVerbose |
	oldVerbose := Verbose.
	Verbose := verboseFlag.
	^oldVerbose
    ]

    FileStream class >> record: recordFlag [
	"Set whether Smalltalk should record information about nested file-ins.
	 When recording is enabled, use #generateMakefileOnto: to automatically
	 generate a valid makefile for the intervening file-ins."

	<category: 'file-in'>
	| oldRecord |
	oldRecord := Record.
	Record := recordFlag.
	Includes := Record ifTrue: [OrderedCollection new] ifFalse: [nil].
	^oldRecord
    ]

    FileStream class >> generateMakefileOnto: aStream [
	"Generate a make file for the file-ins since record was last set to true.
	 Store it on aStream"

	<category: 'file-in'>
	aStream 
	    nextPutAll: '
#
# Automatically generated Smalltalk dependencies
#

'.
	self recursiveGenerateOnto: aStream with: Includes.
	aStream 
	    nextPutAll: '#
# End automatically generated Smalltalk dependencies
#

'
    ]

    FileStream class >> recursiveGenerateOnto: aStream with: includeCollection [
	"Private - Generate a make file for the file in information in
	 includeCollection. Store it on aStream"

	<category: 'private'>
	includeCollection isNil ifTrue: [^self].
	includeCollection do: 
		[:include | 
		include value size > 0 
		    ifTrue: 
			[aStream
			    nextPutAll: include key;
			    nextPutAll: ': '.
			include value do: 
				[:subinclude | 
				aStream
				    nextPutAll: subinclude key;
				    space].
			aStream
			    nl;
			    nl.
			self recursiveGenerateOnto: aStream with: include value]]
    ]

    peek [
	"Return the next character in the file, or nil at eof.
	 Don't advance the file pointer."

	<category: 'basic'>
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr 
	    ifTrue: 
		[self fill.
		self atEnd ifTrue: [^self pastEnd]].
	^collection at: ptr
    ]

    next [
	"Return the next character in the file, or nil at eof"

	<category: 'basic'>
	| element |
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr 
	    ifTrue: 
		[self fill.
		self atEnd ifTrue: [^self pastEnd]].
	element := collection at: ptr.
	ptr := ptr + 1.
	^element
    ]

    nextPut: aCharacter [
	"Store aCharacter on the file"

	<category: 'basic'>
	ptr > collection size ifTrue: [self flush].
	writePtr isNil 
	    ifTrue: 
		[(access bitAnd: 2) = 0 ifTrue: [^self shouldNotImplement].
		writePtr := ptr.
		writeEnd := ptr - 1].
	collection at: ptr put: aCharacter.
	ptr := ptr + 1.
	writeEnd := ptr - 1
    ]

    bufferStart [
	"Private - Answer the offset from the start of the file corresponding
	 to the beginning of the read buffer."

	<category: 'basic'>
	^super position - endPtr
    ]

    position [
	"Answer the zero-based position from the start of the file"

	<category: 'basic'>
	^self bufferStart + ptr - 1
    ]

    position: n [
	"Set the file pointer to the zero-based position n"

	"There is a lot of duplicate code between here and #flush."

	<category: 'basic'>
	| pos bufferStart |
	writePtr notNil 
	    ifTrue: 
		[bufferStart := self bufferStart.
		pos := bufferStart + endPtr.
		self 
		    fileOp: 18
		    with: collection
		    with: writePtr
		    with: writeEnd
		    with: bufferStart + writePtr - 1].

	"If we didn't write, pos is nil and we always do the lseek.  It makes
	 no sense to do an lseek (to get the current file pointer in #bufferStart)
	 only to possibly skip this other lseek."
	pos = n ifFalse: [super position: n].
	ptr := 1.
	endPtr := 0.
	writePtr := nil
    ]

    size [
	"Return the current size of the file, in bytes"

	<category: 'basic'>
	writePtr notNil ifTrue: [self flush].
	^super size
    ]

    truncate [
	"Truncate the file at the current position"

	<category: 'basic'>
	writePtr notNil ifTrue: [self flush].
	super truncate
    ]

    copyFrom: from to: to [
	"Answer the contents of the file between the two given positions"

	<category: 'basic'>
	| offset fromPos toPos result |
	from > to 
	    ifTrue: 
		[to + 1 = from ifTrue: [^self species new].
		^SystemExceptions.ArgumentOutOfRange 
		    signalOn: from
		    mustBeBetween: 1
		    and: to + 1].
	self checkIfPipe.
	endPtr = 0 
	    ifFalse: 
		[offset := self bufferStart - 1.
		fromPos := from - offset.
		toPos := to - offset.
		(fromPos >= 1 and: [toPos <= endPtr]) 
		    ifTrue: [^collection copyFrom: fromPos to: toPos]].
	writePtr notNil ifTrue: [self flush].
	result := self species new: to - from + 1.
	self 
	    fileOp: 17
	    with: result
	    with: 1
	    with: result size
	    with: from.
	^result
    ]

    next: n putAll: aCollection startingAt: pos [
	"Write n values from aCollection, the first being at pos."
	<category: 'overriding inherited methods'>
	| written |
	written := collection size - ptr + 1 min: n.
	self 
	    next: written
	    bufferAll: aCollection
	    startingAt: pos.
	written = n ifTrue: [^self].
	self flush.
	n - written < collection size 
	    ifTrue: 
		[self 
		    next: n - written
		    bufferAll: aCollection
		    startingAt: pos + written]
	    ifFalse: 
		[super 
		    next: n - written
		    putAll: aCollection asString
		    startingAt: pos + written]
    ]

    upTo: aCharacter [
	"Returns a collection of the same type that the stream accesses,
	 containing data up to aCharacter.  Returns the entire rest of
	 the stream's contents if no such character is found."

	<category: 'overriding inherited methods'>
	| n resultStream result ch |
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr 
	    ifTrue: 
		[self fill.
		self atEnd ifTrue: [^self pastEnd]].

	"First, examine the buffer's contents."
	
	[ptr to: endPtr
	    do: 
		[:i | 
		(ch := collection at: i) == aCharacter
		    ifTrue: 
			[result := collection copyFrom: ptr to: i - 1.
			ptr := i + 1.

			"If we went through the loop only once, we're done."
			resultStream isNil ifTrue: [^result].

			"Else finish the stream and return its contents."
			^resultStream
			    nextPutAll: result;
			    contents]].
	resultStream isNil 
	    ifTrue: 
		[resultStream := WriteStream on: (self species new: endPtr - ptr + 20)].
	resultStream 
	    next: endPtr - ptr + 1
	    putAll: collection
	    startingAt: ptr.
	ptr := endPtr + 1.
	self fill.
	self atEnd] 
		whileFalse.
	^resultStream contents
    ]

    nextLine [
	"Returns a collection of the same type that the stream accesses, containing
	 the next line up to the next new-line character.  Returns the entire rest of the
	 stream's contents if no new-line character is found."

	<category: 'overriding inherited methods'>
	| n resultStream result ch |
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr 
	    ifTrue: 
		[self fill.
		self atEnd ifTrue: [^self pastEnd]].

	"First, examine the buffer's contents."
	
	[ptr to: endPtr
	    do: 
		[:i | 
		((ch := collection at: i) == ##(Character cr) or: [ch == ##(Character nl)]) 
		    ifTrue: 
			[result := collection copyFrom: ptr to: i - 1.
			ptr := i + 1.
			ch == ##(Character cr) ifTrue: [self peekFor: ##(Character nl)].

			"If we went through the loop only once, we're done."
			resultStream isNil ifTrue: [^result].

			"Else finish the stream and return its contents."
			^resultStream
			    nextPutAll: result;
			    contents]].
	resultStream isNil 
	    ifTrue: 
		[resultStream := WriteStream on: (self species new: endPtr - ptr + 20)].
	resultStream 
	    next: endPtr - ptr + 1
	    putAll: collection
	    startingAt: ptr.
	ptr := endPtr + 1.
	self fill.
	self atEnd] 
		whileFalse.
	^resultStream contents
    ]

    nextAvailable: anInteger putAllOn: aStream [
	"Copy up to anInteger bytes from the stream into
	 aStream.  Return the number of bytes read."

	<category: 'buffering'>
	| last n |
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr ifTrue: [self fill].

	"Fetch data from the buffer, without doing more than one I/O operation."
	last := endPtr min: ptr + anInteger - 1.
	n := last - ptr + 1.
	aStream next: n putAll: collection startingAt: ptr.
	ptr := ptr + n.
	^n
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
	"Read up to anInteger bytes from the stream and store them
	 into aCollection.  Return the number of bytes read."

	<category: 'buffering'>
	| last n |
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr ifTrue: [self fill].

	"Fetch data from the buffer, without doing more than one I/O operation."
	last := endPtr min: ptr + anInteger - 1.
	n := last - ptr + 1.
	aCollection replaceFrom: pos to: pos + n - 1 with: collection startingAt: ptr.
	ptr := ptr + n.
	^n
    ]

    nextPutAllOn: aStream [
	"Put all the characters of the receiver in aStream."

	<category: 'overriding inherited methods'>
	| buf bufSize |
	writePtr notNil ifTrue: [self flush].
	ptr > endPtr ifTrue: [self fill].
	[ self atEnd ] whileFalse: [
	    aStream next: endPtr - ptr + 1 putAll: collection startingAt: ptr.
	    ptr := endPtr + 1.
	    self resetBuffer; fill.
	]
    ]

    atEnd [
	"Answer whether data has come to an end"

	<category: 'testing'>
	^ptr > endPtr and: [super atEnd]
    ]

    bufferSize [
	"Answer the file's current buffer"

	<category: 'buffering'>
	^collection size
    ]

    bufferSize: bufSize [
	"Flush the file and set the buffer's size to bufSize"

	<category: 'buffering'>
	self flush.
	collection := self species new: bufSize
    ]

    initialize [
        "Initialize the receiver's instance variables"

        <category: 'initialize-release'>
        super initialize.
        collection := self newBuffer.
        ptr := 1.
        endPtr := 0.
    ]

    newBuffer [
	"Private - Answer a String to be used as the receiver's buffer"

	<category: 'buffering'>
	^self species new: 1024
    ]

    flush [
	"Flush the output buffer."

	"Decide whether to use a pwrite or a write.  In many cases, a regular
	 write can be better than a pwrite+lseek.
	 
	 We are now at (self bufferStart + endPtr).  The position we will
	 set is (self bufferStart + ptr - 1).  If we perform a write, we
	 will do a single seek from (self bufferStart + endPtr) to (self
	 bufferStart + writePtr - 1), and then issue the write which will
	 set the file pointer to (self bufferStart + writeEnd): That's why
	 if writeEnd = ptr - 1, we use write.  Otherwise we use pwrite
	 and possibly an lseek after it."

	<category: 'buffering'>
	(self isPipe or: [writePtr notNil and: [ptr - 1 = writeEnd]]) 
	    ifTrue: 
		[writePtr notNil 
		    ifTrue: 
			[(self isPipe or: [writePtr - 1 = endPtr]) 
			    ifFalse: [super skip: writePtr - 1 - endPtr].
			super 
			    next: writeEnd - writePtr + 1
			    putAll: collection
			    startingAt: writePtr]]
	    ifFalse: 
		[writePtr notNil 
		    ifTrue: 
			[self 
			    fileOp: 18
			    with: collection
			    with: writePtr
			    with: writeEnd
			    with: self bufferStart + writePtr - 1].
		ptr - 1 = endPtr ifFalse: [super skip: ptr - 1 - endPtr]].

	ptr := 1.
	endPtr := 0.
	writePtr := nil
    ]

    resetBuffer [
	"Reset the buffer.  Only valid if no write is pending."

	<category: 'private-buffering'>
	ptr := 1.
	endPtr := 0.
	writePtr := nil
    ]

    pendingWrite [
	"Answer whether the output buffer is full."

	<category: 'buffering'>
	^writePtr notNil
    ]

    clean [
	"Synchronize the file descriptor's state with the object's state."

	<category: 'buffering'>
	self flush
    ]

    next: n bufferAll: aCollection startingAt: pos [
	"Private - Assuming that the buffer has space for n characters, store
	 n characters of aCollection in the buffer, starting from the pos-th."

	<category: 'buffering'>
	writePtr isNil 
	    ifTrue: 
		[(access bitAnd: 2) = 0 ifTrue: [^self shouldNotImplement].
		writePtr := ptr.
		writeEnd := ptr - 1].
	n = 0 ifTrue: [^self].
	collection 
	    replaceFrom: ptr
	    to: ptr + n - 1
	    with: aCollection
	    startingAt: pos.
	ptr := ptr + n.
	writeEnd := ptr - 1
    ]

    fill [
	"Private - Fill the input buffer"

	<category: 'buffering'>
	(access bitAnd: 1) = 0 ifTrue: [^self shouldNotImplement].
	ptr > endPtr ifTrue: [self flush].
	endPtr := endPtr + (super 
			    nextAvailable: collection size - endPtr
			    into: collection
			    startingAt: endPtr + 1)
    ]
]



Eval [
    FileStream initialize
]

