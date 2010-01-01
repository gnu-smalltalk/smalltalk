"======================================================================
|
|   Stream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2006,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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



Iterable subclass: Stream [
    
    <category: 'Streams'>
    <comment: 'I am an abstract class that provides interruptable sequential access to
objects.  I can return successive objects from a source, or accept
successive objects and store them sequentially on a sink.  I provide
some simple iteration over the contents of one of my instances, and 
provide for writing collections sequentially.'>

    file [
	"Return nil by default; not all streams have a file."

	<category: 'accessing-reading'>
	^nil
    ]

    name [
	"Return nil by default; not all streams have a name."

	<category: 'accessing-reading'>
	^nil
    ]

    next [
	"Return the next object in the receiver"

	<category: 'accessing-reading'>
	self subclassResponsibility
    ]

    next: anInteger [
	"Return the next anInteger objects in the receiver"

	<category: 'accessing-reading'>
	| answer |
	self
	    next: anInteger
	    into: (answer := self species new: anInteger)
	    startingAt: 1.
	^answer
    ]

    next: anInteger putAllOn: aStream [
	"Read up to anInteger bytes from the stream and store them
	 into aStream.  Return the number of bytes that were read, raising
	 an exception if we could not read the full amount of data."

	<category: 'buffering'>
	| read |
	read := 0.
	[ read = anInteger ] whileFalse: [
            self atEnd ifTrue: [
                ^SystemExceptions.NotEnoughElements signalOn: anInteger - read].
            read := read + (self
				nextAvailable: anInteger - read
				putAllOn: aStream)
        ].
	^read
    ]

    next: anInteger into: answer startingAt: pos [
	"Read up to anInteger bytes from the stream and store them
	 into answer.  Return the number of bytes that were read, raising
	 an exception if we could not read the full amount of data."

	<category: 'buffering'>
	| read |
	read := 0.
	[ read = anInteger ] whileFalse: [
            self atEnd ifTrue: [
                ^SystemExceptions.NotEnoughElements signalOn: anInteger - read].
            read := read + (self
				nextAvailable: anInteger - read
				into: answer
				startingAt: read + pos)
        ].
	^answer
    ]

    nextAvailable: anInteger putAllOn: aStream [
	"Copy up to anInteger objects in the receiver to aStream.  Besides
	 stopping if the end of the stream is reached, this may return
	 less than this number of bytes for various reasons.  For example,
	 on files and sockets this operation could be non-blocking,
	 or could do at most one I/O operation."

	<category: 'accessing-reading'>
	| n coll |
	n := anInteger min: 1024.
	n := self
	    nextAvailable: n
	    into: (coll := self species new: n)
	    startingAt: 1.
	aStream next: n putAll: coll startingAt: 1.
	^n
    ]

    nextAvailable: anInteger [
	"Return up to anInteger objects in the receiver.  Besides stopping if
	 the end of the stream is reached, this may return less than this
	 number of bytes for various reasons.  For example, on files and sockets
	 this operation could be non-blocking, or could do at most one I/O
	 operation."

	<category: 'accessing-reading'>
	| n answer |
	n := self
	    nextAvailable: anInteger
	    into: (answer := self species new: anInteger)
	    startingAt: 1.
	n < anInteger ifTrue: [ answer := answer copyFrom: 1 to: n ].
	^answer
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
	"Place the next anInteger objects from the receiver into aCollection,
	 starting at position pos.  Return the number of items stored.
	 Besides stopping if the end of the stream is reached, this may
	 return less than this number of bytes for various reasons.
	 For example, on files and sockets this operation could be
	 non-blocking, or could do at most one I/O operation."

	<category: 'accessing-reading'>
	| i |
	i := -1.
	[(i := i + 1) = anInteger] whileFalse: [
		self atEnd ifTrue: [^i].
		aCollection at: i + pos put: self next].
	^anInteger
    ]

    nextMatchFor: anObject [
	"Answer whether the next object is equal to anObject. Even if it does
	 not, anObject is lost"

	<category: 'accessing-reading'>
	^anObject = self next
    ]

    splitAt: anObject [
	"Answer an OrderedCollection of parts of the receiver. A new (possibly
	 empty) part starts at the start of the receiver, or after every
	 occurrence of an object which is equal to anObject (as compared by
	 #=)."

	<category: 'accessing-reading'>
	| result |
	result := OrderedCollection new: 10.
	[self atEnd] whileFalse: [result addLast: (self upTo: anObject)].
	^result
    ]

    contents [
	"Answer the whole contents of the receiver, from the next object to
	 the last"

	<category: 'accessing-reading'>
	^self upToEnd
    ]

    upToEnd [
	"Answer every item in the collection on which the receiver is
	 streaming, from the next one to the last"

	<category: 'accessing-reading'>
	| ws |
	ws := WriteStream on: (self species new: 8).
	self nextPutAllOn: ws.
	^ws contents
    ]

    nextLine [
	"Returns a collection of the same type that the stream accesses, containing
	 the next line up to the next new-line character.  Returns the entire rest of the
	 stream's contents if no new-line character is found."

	<category: 'accessing-reading'>
	| next ws |
	ws := WriteStream on: (self species new: 40).
	
	[self atEnd or: 
		[(next := self next) == ##(Character cr) 
		    or: [next == ##(Character nl) or: [next isNil]]]] 
		whileFalse: [ws nextPut: next].
	next == ##(Character cr) ifTrue: [self peekFor: ##(Character nl)].
	^ws contents
    ]

    upTo: anObject [
	"Returns a collection of the same type that the stream accesses, up to
	 but not including the object anObject.  Returns the entire rest of the
	 stream's contents if anObject is not present."

	<category: 'accessing-reading'>
	| next ws |
	ws := WriteStream on: (self species new: 8).
	[self atEnd or: [(next := self next) = anObject]] 
	    whileFalse: [ws nextPut: next].
	^ws contents
    ]

    upToAll: aCollection [
	"If there is a sequence of objects remaining in the stream that is
	 equal to the sequence in aCollection, set the stream position just
	 past that sequence and answer the elements up to, but not including,
	 the sequence. Else, set the stream position to its end and answer
	 all the remaining elements."

	<category: 'accessing-reading'>
	| result prefix ch j |
	self atEnd ifTrue: [^self species new].
	aCollection isEmpty ifTrue: [^self species new].
	result := WriteStream on: (self species new: 20).

	"Use the Knuth-Morris-Pratt algorithm."
	prefix := self prefixTableFor: aCollection.
	ch := self next.
	j := 1.
	result nextPut: ch.
	
	[(ch = (aCollection at: j) or: [(j := prefix at: j) = 0]) 
	    ifTrue: 
		[j := j + 1.
		j > prefix size 
		    ifTrue: 
			[result skip: aCollection size negated.
			^result contents].
		self atEnd ifTrue: [^result contents].
		ch := self next.
		result nextPut: ch]] 
		repeat
    ]

    nextPut: anObject [
	"Write anObject to the receiver"

	<category: 'accessing-writing'>
	self subclassResponsibility
    ]

    next: n putAll: aCollection startingAt: start [
	"Write n objects to the stream, reading them from aCollection
	 and starting at the start-th item."

	<category: 'accessing-writing'>
	aCollection 
	    from: start
	    to: start + n - 1
	    do: [:element | self nextPut: element].
	^aCollection
    ]

    nextPutAllFlush: aCollection [
	"Put all the elements of aCollection in the stream, then flush the
	 buffers if supported by the stream."

	<category: 'accessing-writing'>
	self
	    nextPutAll: aCollection;
	    flush
    ]

    nextPutAll: aCollection [
	"Write all the objects in aCollection to the receiver"

	<category: 'accessing-writing'>
	aCollection nextPutAllOn: self.
	^aCollection
    ]

    nextPutAllOn: aStream [
        "Write all the objects in the receiver to aStream"

	[self atEnd] whileFalse: 
		[self nextAvailablePutAllOn: aStream].
    ]

    next: anInteger put: anObject [
	"Write anInteger copies of anObject to the receiver"

	<category: 'accessing-writing'>
	anInteger timesRepeat: [self nextPut: anObject].
	^anObject
    ]

    atEnd [
	"Answer whether the stream has got to an end"

	<category: 'testing'>
	self subclassResponsibility
    ]

    readStream [
	"As a wild guess, return the receiver.  WriteStreams should override
	 this method."

	<category: 'testing'>
	^self
    ]

    isSequenceable [
	"Answer whether the receiver can be accessed by a numeric index with
	 #at:/#at:put:."

	<category: 'testing'>
	^false
    ]

    isExternalStream [
	"Answer whether the receiver streams on a file or socket.
	 By default, answer false."

	<category: 'testing'>
	^false
    ]

    linesDo: aBlock [
	"Evaluate aBlock once for every line in the receiver (assuming the
	 receiver is streaming on Characters)."

	<category: 'enumerating'>
	"FIXME: this is not very safe if the block uses the stream too.
	 But maybe we can assume it doesn't?"
	[[self atEnd] whileFalse: [aBlock value: self nextLine]]
	    on: SystemExceptions.EndOfStream
	    do: [:ex | ex stream == self ifFalse: [ex resume]]
    ]

    do: aBlock [
	"Evaluate aBlock once for every object in the receiver"

	<category: 'enumerating'>
	"FIXME: this is not very safe if the block uses the stream too.
	 But maybe we can assume it doesn't?"
	[[self atEnd] whileFalse: [aBlock value: self next]]
	    on: SystemExceptions.EndOfStream
	    do: [:ex | ex stream == self ifFalse: [ex resume]]
    ]

    species [
	<category: 'basic'>
	^Array
    ]

    isUnicode [
	"Answer whether the receiver is able to store Unicode characters.
	 Note that if this method returns true, the stream may or may not
	 be able to store Characters (as opposed to UnicodeCharacters)
	 whose value is above 127."

	<category: 'character writing'>
	^self species isUnicode
    ]

    encoding [
	"Answer the encoding to be used when storing Unicode characters."

	<category: 'character writing'>
	self species isUnicode ifTrue: [ ^'Unicode' ].
	^self species defaultEncoding
    ]

    cr [
	"Store a cr on the receiver"

	<category: 'character writing'>
	self nextPut: Character cr
    ]

    nl [
	"Store a new line on the receiver"

	<category: 'character writing'>
	self nextPut: Character nl
    ]

    crTab [
	"Store a cr and a tab on the receiver"

	<category: 'character writing'>
	self cr.
	self tab
    ]

    nlTab [
	"Store a new line and a tab on the receiver"

	<category: 'character writing'>
	self nl.
	self tab
    ]

    space: n [
	"Store n spaces on the receiver"

	<category: 'character writing'>
	self next: n put: Character space
    ]

    tab: n [
	"Store n tabs on the receiver"

	<category: 'character writing'>
	self next: n put: Character tab
    ]

    space [
	"Store a space on the receiver"

	<category: 'character writing'>
	self nextPut: Character space
    ]

    tab [
	"Store a tab on the receiver"

	<category: 'character writing'>
	self nextPut: Character tab
    ]

    close [
	"Do nothing. This is provided for consistency with file streams"

	<category: 'polymorphism'>
	
    ]

    pastEnd [
	"The end of the stream has been reached.  Signal a Notification."

	<category: 'polymorphism'>
	SystemExceptions.EndOfStream signalOn: self.
	^nil
    ]

    flush [
	"Do nothing. This is provided for consistency with file streams"

	<category: 'polymorphism'>
	
    ]

    << anObject [
	"This method is a short-cut for #display:; it prints anObject on the
	 receiver by sending displayOn: to anObject. This method is provided
	 so that you can use cascading and obtain better-looking code"

	<category: 'printing'>
	anObject displayOn: self
    ]

    display: anObject [
	"Print anObject on the receiver by sending displayOn: to anObject. This
	 method is provided so that you can use cascading and obtain
	 better-looking code"

	<category: 'printing'>
	anObject displayOn: self
    ]

    print: anObject [
	"Print anObject on the receiver by sending printOn: to anObject. This
	 method is provided so that you can use cascading and obtain
	 better-looking code"

	<category: 'printing'>
	anObject printOn: self
    ]

    store: anObject [
	"Print Smalltalk code compiling to anObject on the receiver, by sending
	 storeOn: to anObject. This method is provided so that you can use
	 cascading and obtain better-looking code"

	<category: 'storing'>
	anObject storeOn: self
    ]

    fileOut: aClass [
	"File out aClass on the receiver. If aClass is not a metaclass, file out
	 class and instance methods; if aClass is a metaclass, file out only the
	 class methods"

	<category: 'filing out'>
	aClass fileOutOn: self
    ]

    isPositionable [
	"Answer true if the stream supports moving backwards with #skip:."

	<category: 'positioning'>
	^false
    ]

    skip: anInteger [
	"Move the position forwards by anInteger places"

	<category: 'positioning'>
	anInteger < 0 
	    ifTrue: 
		[SystemExceptions.InvalidArgument signalOn: anInteger
		    reason: 'must be positive'].
	anInteger timesRepeat: 
		[self atEnd ifTrue: [^false].
		self next].
	^true
    ]

    skipTo: anObject [
	"Move the current position to after the next occurrence of anObject
	 and return true if anObject was found.  If anObject doesn't exist, the
	 pointer is atEnd, and false is returned."

	<category: 'positioning'>
	[self atEnd] whileFalse: [self next = anObject ifTrue: [^true]].
	^false
    ]

    skipToAll: aCollection [
	"If there is a sequence of objects remaining in the stream that is
	 equal to the sequence in aCollection, set the stream position just
	 past that sequence and answer true. Else, set the stream position
	 to its end and answer false."

	<category: 'positioning'>
	| prefix ch j |
	self atEnd ifTrue: [^false].
	aCollection isEmpty ifTrue: [^true].

	"Use the Knuth-Morris-Pratt algorithm."
	prefix := self prefixTableFor: aCollection.
	ch := self next.
	j := 1.
	
	[(ch = (aCollection at: j) or: [(j := prefix at: j) = 0]) 
	    ifTrue: 
		[j := j + 1.
		j > prefix size ifTrue: [^true].
		self atEnd ifTrue: [^false].
		ch := self next]] 
		repeat
    ]

    nextAvailablePutAllOn: aStream [
	"Copy to aStream a more-or-less arbitrary amount of data.  When used
	 on files, this does at most one I/O operation.  For other kinds of
	 stream, the definition may vary.  This method is used to do
	 stream-to-stream copies."

	<category: 'streaming protocol'>
	self nextAvailable: 16rFFFFFFF putAllOn: aStream.
    ]

    prefixTableFor: aCollection [
	"Private - Answer the prefix table for the Knuth-Morris-Pratt algorithm.
	 After a failure, the table is looked up to see how the longest prefix
	 that still matches.  For example, when searching 'aabab' in 'aabaabab',
	 when the fourth `a' is reached the table tells that we can proceed with
	 the match as long as we restart from the second `a' in the searched
	 string."

	<category: 'private'>
	| prefix j |
	prefix := aCollection size < 256 
		    ifTrue: [ByteArray new: aCollection size]
		    ifFalse: [Array new: aCollection size].
	prefix
	    at: 1 put: 0;
	    at: 2 put: 1.
	aCollection 
	    from: 2
	    to: aCollection size - 1
	    keysAndValuesDo: 
		[:i :ch | 
		j := prefix at: i.
		[j <= 1 or: [ch = (aCollection at: j)]] whileFalse: [j := prefix at: j].
		prefix at: i + 1 put: j].
	^prefix
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
	pos := [self position] on: MessageNotUnderstood do: [:ex | ex return: 0].
	^self 
	    fileInLine: 1
	    file: self file
	    at: pos
    ]

    fileInLine: lineNum file: aFile at: charPosInt [
	"Private - Much like a preprocessor #line directive; it is used internally
	 by #fileIn, and explicitly by the Emacs Smalltalk mode."

	<category: 'built ins'>
	^self
	    fileInLine: 1
	    file: (aFile ifNotNil: [aFile full])
	    fileName: (aFile ifNotNil: [aFile displayString])
	    at: charPosInt
    ]

    fileInLine: lineNum file: aFile fileName: aString at: charPosInt [
	"Private - Much like a preprocessor #line directive; it is used internally
	 by #fileIn, and explicitly by the Emacs Smalltalk mode."

	<category: 'private'>
	<primitive: VMpr_Stream_fileInLine>
	self primitiveFailed
    ]

    fileInLine: lineNum fileName: aString at: charPosInt [
	"Private - Much like a preprocessor #line directive; it is used internally
	 by #fileIn, and explicitly by the Emacs Smalltalk mode."

	<category: 'built ins'>
	<primitive: VMpr_Stream_fileInLine>
	self primitiveFailed
    ]
]

