"======================================================================
|
|   FileStream Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003
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


FileDescriptor subclass: #FileStream
		instanceVariableNames: 'writePtr writeEnd'
		classVariableNames: 'Verbose Record Includes'
		poolDictionaries: ''
		category: 'Streams-Files'
!

FileStream comment: 
'My instances are what conventional programmers think of as files.
My instance creation methods accept the name of a disk file (or any named
file object, such as /dev/rmt0 on UNIX or MTA0: on VMS).'
!



!FileStream class methodsFor: 'standard streams'!

stderr
    "Answer a FileStream that is attached the Smalltalk program's standard
     error file handle, which can be used for error messages and diagnostics
     issued by the program."
    ^stderr
!

stdin
    "Answer a FileStream that is attached the Smalltalk program's standard
     input file handle, which is the normal source of input for the program."
    ^stdin
!

stdout
    "Answer a FileStream that is attached the Smalltalk program's standard
     output file handle; this is used for normal output from the program."
    ^stdout
! !


!FileStream class methodsFor: 'file-in'!

initialize
    "Private - Initialize the receiver's class variables"
    Record := Verbose := false.
! !


!FileStream class methodsFor: 'file-in'!

fileIn: aFileName
    "File in the aFileName file. During a file in operation, global variables
     (starting with an uppercase letter) that are not declared yet don't yield
     an `unknown variable' error. Instead, they are defined as nil in the
     `Undeclared' dictionary (a global variable residing in Smalltalk).
     As soon as you add the variable to a namespace (for example by creating
     a class) the Association will be removed from Undeclared and reused
     in the namespace, so that the old references will automagically point
     to the new value."

    | oldIncludes newCollection file |
    Verbose ifTrue: [ Transcript nextPutAll: 'Loading ', aFileName; nl ].

    Record ifTrue: [
	newCollection := OrderedCollection new.
	Includes add: aFileName -> newCollection.
	oldIncludes := Includes.
	Includes := newCollection
    ].

    (self open: aFileName mode: FileStream read)
	fileIn;
	close.

    Record ifTrue: [ Includes := oldIncludes ].
!

fileIn: aFileName line: lineInteger from: realFileName at: aCharPos
    "File in the aFileName file giving errors such as if it was loaded
     from the given line, file name and starting position (instead of 1)."

    (self open: aFileName mode: FileStream read)
	fileInLine: lineInteger fileName: realFileName at: aCharPos;
	close.
!

fileIn: aFileName ifMissing: aSymbol
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

    Smalltalk at: aSymbol
	      ifAbsent: [ self fileIn: aFileName ]
!

fileIn: aFileName ifTrue: aBoolean
    "Conditionally do a file in, only if the supplied boolean is true.
     During a file in operation, global variables (starting with an
     uppercase letter) that are not declared don't yield an `unknown
     variable' error. Instead, they are defined as nil in the `Undeclared'
     dictionary (a global variable residing in Smalltalk).
     As soon as you add the variable to a namespace (for example by creating
     a class) the Association will be removed from Undeclared and reused
     in the namespace, so that the old references will automagically point
     to the new value."
							       
    aBoolean 
	ifTrue: [ self fileIn: aFileName ]
!

require: assoc
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
    Smalltalk at: assoc key
	      ifAbsent: [ self fileIn: assoc value ]
!

verbose: verboseFlag
    "Set whether Smalltalk should output debugging messages when filing in"
    | oldVerbose |
    oldVerbose := Verbose.
    Verbose := verboseFlag.
    ^oldVerbose
!

record: recordFlag
    "Set whether Smalltalk should record information aboutnested file-ins.
     When recording is enabled, use #generateMakefileOnto: to automatically
     generate a valid makefile for the intervening file-ins."
    | oldRecord |
    oldRecord := Record.
    Record := recordFlag.
    Includes := Record 
	ifTrue: [ OrderedCollection new ]
	ifFalse: [ nil ].
    ^oldRecord
!

generateMakefileOnto: aStream
    "Generate a make file for the file-ins since record was last set to true.
     Store it on aStream"
    aStream nextPutAll: 
'
#
# Automatically generated Smalltalk dependencies
#

'.
    self recursiveGenerateOnto: aStream with: Includes.
    aStream nextPutAll: 
'#
# End automatically generated Smalltalk dependencies
#

'.
! !


!FileStream class methodsFor: 'private'!

recursiveGenerateOnto: aStream with: includeCollection
    "Private - Generate a make file for the file in information in
     includeCollection. Store it on aStream"

    includeCollection isNil ifTrue: [ ^self ].
    includeCollection do: [ :include |
	include value size > 0 ifTrue: [
	    aStream
		nextPutAll: include key;
		nextPutAll: ': '.
	
	    include value do: [ :subinclude |
		aStream nextPutAll: subinclude key; space
	    ].
	    aStream nl; nl.
	    self recursiveGenerateOnto: aStream with: include value
	]
    ]
! !


!FileStream methodsFor: 'basic'!

peek
    "Return the next character in the file, or nil at eof.
     Don't advance the file pointer."

    writePtr notNil ifTrue: [ self basicFlush ].
    ptr > endPtr ifTrue: [
	self fill.
	self atEnd ifTrue: [ ^self pastEnd ].
    ].
    ^collection at: ptr.
!

next
    "Return the next character in the file, or nil at eof"

    | element |
    writePtr notNil ifTrue: [ self basicFlush ].
    ptr > endPtr ifTrue: [
	self fill.
	self atEnd ifTrue: [ ^self pastEnd ].
    ].
    element := collection at: ptr.
    ptr := ptr + 1.
    ^element
!

nextByte
    "Return the next byte in the file, or nil at eof"

    | a |
    a := self next.
    ^a isNil ifTrue: [ a ] ifFalse: [ a asInteger ]
!

nextPut: aCharacter
    "Store aCharacter on the file"

    ptr > collection size ifTrue: [ self flush ].

    writePtr isNil
        ifTrue: [
	    (access bitAnd: 2) = 0
	    	ifTrue: [ ^self shouldNotImplement ].

	    writePtr := writeEnd := ptr ]
        ifFalse: [ writeEnd := writeEnd + 1 ].

    collection at: ptr put: aCharacter.
    ptr := ptr + 1.
!

nextPutByte: anInteger
    "Store the byte, anInteger, on the file"
    self nextPut: anInteger asCharacter
!

nextPutByteArray: aByteArray
    "Store aByteArray on the file"
    ^self nextPutAll: aByteArray asString
!

position
    "Answer the zero-based position from the start of the file"
    ^super position + (ptr - 1) - endPtr
!

position: n
    "Set the file pointer to the zero-based position n"
    writePtr notNil ifTrue: [ self basicFlush ].
    ptr := 1.
    endPtr := 0.
    super position: n.
!

size
    "Return the current size of the file, in bytes"
    writePtr notNil ifTrue: [ self basicFlush ].
    ^super size
!

truncate
    "Truncate the file at the current position"
    writePtr notNil ifTrue: [ self basicFlush ].
    super truncate
!

copyFrom: from to: to
    "Answer the contents of the file between the two given positions"
    | offset fromPos toPos savePos |
    from > to ifTrue: [
        to + 1 = from ifTrue: [ ^self species new ].
        ^SystemExceptions.ArgumentOutOfRange signalOn: from mustBeBetween: 1 and: to + 1
    ].

    savePos := self fileOp: 5.
    offset := savePos - endPtr + 1.
    fromPos := from - offset.
    toPos := to - offset.

    (fromPos >= 1 and: [ toPos <= collection size ])
        ifTrue: [ ^collection copyFrom: fromPos to: toPos ].

    ^[
        self position: fromPos.
        self next: toPos - fromPos + 1
    ] ensure: [
        self position: savePos
    ]
! !


!FileStream methodsFor: 'filing in'!

fileIn
    "File in the contents of the receiver.
     During a file in operation, global variables (starting with an
     uppercase letter) that are not declared don't yield an `unknown
     variable' error. Instead, they are defined as nil in the `Undeclared'
     dictionary (a global variable residing in Smalltalk).
     As soon as you add the variable to a namespace (for example by creating
     a class) the Association will be removed from Undeclared and reused
     in the namespace, so that the old references will automagically point
     to the new value."

    self clean.
    self fileOp: 11 ifFail: [
        file isNil ifTrue: [ SystemExceptions.FileError signal: 'file already closed' ].
        self checkError.
        ^nil
    ]
!

fileInLine: lineNum fileName: aString at: charPosInt
    "Private - Much like a preprocessor #line directive; it is used
     by the Emacs Smalltalk mode."

    self clean.
    self fileOp: 12 with: lineNum with: aString with: charPosInt ifFail: [
        file isNil ifTrue: [ SystemExceptions.FileError signal: 'file already closed' ].
        self checkError.
        ^nil
    ]
! !

    

!FileStream methodsFor: 'overriding inherited methods'!

nextPutAllFlush: aCollection
    "Put all the characters in aCollection in the file, then flush the
     file buffers"
    | n storedCollection |
    writePtr notNil ifTrue: [ self basicFlush ].

    storedCollection := aCollection asString.
    self write: storedCollection.
    ptr := 1.
    endPtr := 0.
!

nextPutAll: aCollection
    "Put all the characters in aCollection in the file"
    | n storedCollection |
    writePtr isNil
        ifTrue: [
	    (access bitAnd: 2) = 0
	    	ifTrue: [ ^self shouldNotImplement ].

	    writePtr := ptr. writeEnd := ptr - 1 ].

    storedCollection := aCollection asString.
    n := storedCollection size.
    writeEnd + n > collection size ifFalse: [
        collection
            replaceFrom: writeEnd + 1
            to: writeEnd + n
            with: storedCollection
            startingAt: 1.

	writeEnd := writeEnd + n.
	ptr := writeEnd + 1.
        ^self
    ].

    self basicFlush.
    self write: storedCollection.
!

nextByteArray: anInteger
    "Return the next 'anInteger' bytes from the stream, as a ByteArray."
    | answer from n |
    writePtr notNil ifTrue: [ self basicFlush ].

    n := anInteger.
    answer := ByteArray new: n.
    from := 1.
    [ (ptr + n - 1) > endPtr ] whileFalse: [
        answer
            replaceFrom: from
            to: from + (endPtr - ptr)
            with: collection
            startingAt: ptr.

        from := from + endPtr - ptr - 1.
	n := n - ptr + endPtr - 1.
        self fill.
    ].
    answer
        replaceFrom: from
        to: answer size
        with: collection
        startingAt: ptr.

    ^answer
!

nextLine
    "Returns a collection of the same type that the stream accesses, containing
     the next line up to the next new-line character.  Returns the entire rest of the
     stream's contents if no new-line character is found. "
    | n resultStream result ch |
    writePtr notNil ifTrue: [ self basicFlush ].
    ptr > endPtr ifTrue: [
	self fill.
	self atEnd ifTrue: [ ^self pastEnd ].
    ].

    "First, examine the buffer's contents."
    [
        ptr to: endPtr do: [ :i |
	    ((ch := collection at: i) == ##(Character cr)
		or: [ ch == ##(Character nl) ])
		    ifTrue: [
			result := collection copyFrom: ptr to: i - 1.
			ptr := i + 1.
			ch == ##(Character cr)
			    ifTrue: [ self peekFor: ##(Character nl) ].

			"If we went through the loop only once, we're done."
			resultStream isNil ifTrue: [ ^result ].

			"Else finish the stream and return its contents."
			^resultStream nextPutAll: result; contents
		    ]
        ].

	resultStream isNil ifTrue: [
	    resultStream := WriteStream on: (self species new: endPtr - ptr + 20)
	].
	resultStream next: endPtr - ptr + 1 putAll: collection startingAt: ptr.
	self fill.
	self atEnd
    ] whileFalse.

    ^resultStream contents
!

next: anInteger
    "Return the next 'anInteger' characters from the stream, as a String."
    | answer from n |
    writePtr notNil ifTrue: [ self basicFlush ].

    n := anInteger.
    answer := self species new: n.
    from := 1.
    [ (ptr + n - 1) > endPtr ] whileTrue: [
        answer
            replaceFrom: from
            to: from + (endPtr - ptr)
            with: collection
            startingAt: ptr.

        from := from + (endPtr - ptr + 1).
	n := n - (endPtr - ptr + 1).
        self fill.
    ].
    answer
        replaceFrom: from
        to: answer size
        with: collection
        startingAt: ptr.

    ptr := ptr + (answer size - from + 1).
    ^answer
! !




!FileStream methodsFor: 'testing'!

atEnd
    "Answer whether data has come to an end"
    ^self basicAtEnd and: [ super atEnd ]
! !


!FileStream methodsFor: 'buffering'!

bufferSize
    "Answer the file's current buffer"
    ^collection size
!

bufferSize: bufSize
    "Flush the file and set the buffer's size to bufSize"
    self flush.
    collection := self species new: bufSize
!

newBuffer
    "Private - Answer a String to be used as the receiver's buffer"
    ^String new: 1024
!

flush
    "Flush the output buffer"
    writePtr notNil ifTrue: [ self basicFlush ].
!

pendingWrite
    "Answer whether the output buffer is full"
    ^writePtr notNil
!

clean
    "Synchronize the file descriptor's state with the object's state."
    writePtr notNil ifTrue: [ self basicFlush ].
    self position: self position.
!

basicFlush
    "Private - Flush the output buffer, fail if it is empty"
    | move |
    move := 8.

    endPtr + 1 = writePtr ifFalse: [
	self fileOp: move with: writePtr - endPtr - 1
    ].
    self write: collection from: writePtr to: writeEnd.
    writeEnd + 1 = ptr ifFalse: [
	self fileOp: move with: ptr - writeEnd - 1.
    ].

    writePtr := nil.
    ptr := 1.
    endPtr := 0.
!

nextHunk
    "Answer the next buffers worth of stuff in the Stream represented
     by the receiver.  Do at most one actual input operation."

    | answer |
    endPtr := endPtr + (self fileOp: 3
        with: collection
        with: endPtr + 1
        with: collection size - endPtr
	ifFail: [ self checkError ]).

    answer := collection copyFrom: ptr to: endPtr.
    ptr := 1.
    endPtr := 0.
    ^answer
!

fill
    "Private - Fill the input buffer"
    (access bitAnd: 1) = 0
    	ifTrue: [ ^self shouldNotImplement ].

    ptr := 1.
    endPtr := self read: collection.
! !

FileStream initialize!
