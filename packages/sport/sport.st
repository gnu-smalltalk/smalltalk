"======================================================================
|
|   Sport-A 2.030 for GNU Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
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


Object subclass: SpDate [
    | underlyingDate |
    
    <category: 'Sport-Times'>
    <comment: 'synchronized with 2.030'>

    SpDate class >> fromDays: anInteger [
	<category: 'instance creation'>
	^self new onDate: (Date fromDays: anInteger)
    ]

    SpDate class >> fromISO8610Stream: aStream [
	<category: 'instance creation'>
	| date |
	date := SpExceptionContext 
		    for: [self parseDateFromISO8601Stream: aStream]
		    on: SpError
		    do: [:ex | nil].
	^date isNil ifTrue: [nil] ifFalse: [self onDate: date]
    ]

    SpDate class >> fromISO8610String: aString [
	<category: 'instance creation'>
	^aString size == 10 
	    ifFalse: [nil]
	    ifTrue: [self fromISO8610Stream: aString readStream]
    ]

    SpDate class >> integerOfLength: aLength fromString: aString [
	"^an Integer or nil
	 I parse an integer from aString, if I have problems I return nil.  I make sure
	 the string form of the integer is exactly aLength characters long."

	"SpDate integerOfLength: 4 fromString: '2004'"

	<category: 'private'>
	^(aString size == aLength and: 
		[(aString asOrderedCollection select: [:aDigit | aDigit isDigit not]) 
		    isEmpty]) 
	    ifFalse: [nil]
	    ifTrue: [aString asNumber]
    ]

    SpDate class >> newDay: day month: month year: year [
	<category: 'instance creation'>
	^self new onDate: (Date 
		    newDay: day
		    month: month
		    year: year)
    ]

    SpDate class >> newDay: day monthNumber: month year: year [
	<category: 'instance creation'>
	^self new onDate: (Date 
		    newDay: day
		    month: month
		    year: year)
    ]

    SpDate class >> onDate: aDate [
	<category: 'instance creation'>
	^self new onDate: aDate
    ]

    SpDate class >> parseDateFromISO8601Stream: sourceStream [
	"^a Date or nil
	 I parse an ISO 8601 date from sourceStream.  If there are any parsing
	 problems, I return nil."

	<category: 'private'>
	| yyyy mm dd |
	yyyy := self integerOfLength: 4 fromString: (sourceStream upTo: $-).
	mm := self integerOfLength: 2 fromString: (sourceStream upTo: $-).
	dd := self integerOfLength: 2 fromString: (sourceStream next: 2).
	(yyyy isNil or: [mm isNil or: [dd isNil]]) ifTrue: [^nil].
	^SpExceptionContext 
	    for: 
		[Date 
		    newDay: dd
		    monthIndex: mm
		    year: yyyy]
	    on: SpError
	    do: [:ex | nil]
    ]

    SpDate class >> today [
	<category: 'instance creation'>
	^self onDate: Date today
    ]

    < anotherSpDate [
	"^a Boolean
	 Answer true if anotherSpDate is less (i.e. earlier) than me."

	<category: 'comparing'>
	^self underlyingDate < anotherSpDate underlyingDate
    ]

    <= anotherOSkDate [
	"^a Boolean
	 Answer true if anotherOSkDate is greater (i.e. later) than me."

	<category: 'comparing'>
	^self underlyingDate <= anotherOSkDate underlyingDate
    ]

    = anotherOSkDate [
	"^a Boolean
	 Answer true if anotherOSkDate is equivalent to me."

	<category: 'comparing'>
	^self underlyingDate = anotherOSkDate underlyingDate
    ]

    > anotherOSkDate [
	"^a Boolean
	 Answer true if anotherOSkDate is greater (i.e. later) than me."

	<category: 'comparing'>
	^self underlyingDate > anotherOSkDate underlyingDate
    ]

    >= anotherOSkDate [
	"^a Boolean
	 Answer true if anotherOSkDate is greater (i.e. later) than me."

	<category: 'comparing'>
	^self underlyingDate >= anotherOSkDate underlyingDate
    ]

    addDays: anInteger [
	"^a SpDate
	 I don't change the date I represent.  Rather, I create a new date which represents
	 my date offset by anInteger days."

	<category: 'services'>
	^SpDate fromDays: self asDays + anInteger
    ]

    addYears: anInteger [
	"^an OSkDate
	 I don't change the date I represent.  Rather, I create a new date which represents my
	 date offset by anInteger years."

	<category: 'services'>
	| correction |
	correction := (self underlyingDate monthIndex == 2 
				and: [self underlyingDate dayOfMonth == 29
				and: [(Date daysInYear: self underlyingDate year + anInteger) = 365]]) 
					ifTrue: [1] ifFalse: [0].

	^SpDate onDate: (Date 
		    newDay: self underlyingDate dayOfMonth - correction
		    monthIndex: self underlyingDate monthIndex
		    year: self underlyingDate year + anInteger)
    ]

    julianDay [
	"^an Integer
	 I return the integer number of days between January 1 and
	 the date I represent."

	<category: 'converting'>
	^self underlyingDate dayOfYear
    ]

    asDays [
	"^an Integer
	 I return the integer number of days between January 1, 1901 and
	 the date I represent."

	<category: 'converting'>
	^self underlyingDate asSeconds / (3600 * 24)
    ]

    asISO8610String [
	<category: 'printing'>
	| targetStream |
	targetStream := WriteStream on: String new.
	self asISO8610StringOn: targetStream.
	^targetStream contents
    ]

    asISO8610StringOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self underlyingDate year printString;
	    nextPut: $-.
	self underlyingDate monthIndex < 10 ifTrue: [aStream nextPut: $0].
	aStream
	    nextPutAll: self underlyingDate monthIndex printString;
	    nextPut: $-.
	self underlyingDate dayOfMonth < 10 ifTrue: [aStream nextPut: $0].
	aStream nextPutAll: self underlyingDate dayOfMonth printString.
	^self
    ]

    day [
	<category: 'accessing'>
	^self underlyingDate day
    ]

    daysInMonth [
	<category: 'accessing'>
	^self underlyingDate daysInMonth
    ]

    hash [
	"^an Object"

	<category: 'comparing'>
	^self underlyingDate hash
    ]

    max: anSpDate [
	<category: 'comparing'>
	^self > anSpDate ifTrue: [self] ifFalse: [anSpDate]
    ]

    min: anSpDate [
	<category: 'comparing'>
	^self < anSpDate ifTrue: [self] ifFalse: [anSpDate]
    ]

    monthIndex [
	<category: 'accessing'>
	^self underlyingDate monthIndex
    ]

    onDate: aDate [
	<category: 'initialize-release'>
	underlyingDate := aDate.
	^self
    ]

    printOn: aStream [
	<category: 'printing'>
	self underlyingDate printOn: aStream
    ]

    subtractDays: anInteger [
	"^a SpDate
	 I don't change the date I represent.  Rather, I create a new date which represents
	 my date offset by anInteger days."

	<category: 'services'>
	^SpDate fromDays: self asDays - anInteger
    ]

    underlyingDate [
	<category: 'private'>
	^underlyingDate
    ]

    weekdayIndex [
	"Sunday=1, ... , Saturday=7"

	<category: 'accessing'>
	^self underlyingDate weekdayIndex
    ]

    year [
	<category: 'accessing'>
	^self underlyingDate year
    ]
]



Object subclass: SpEnvironment [
    
    <category: 'Sport-Environmental'>
    <comment: 'synchronized with 2.030'>

    SpEnvironment class [
	| imageStartupTaskBlocks imageShutdownTaskBlocks |
	
    ]

    SpEnvironment class >> haveTasks [
	<category: 'private'>
	^self imageShutdownTaskBlocks notEmpty
		or: [ self imageStartupTaskBlocks notEmpty ]
    ]

    SpEnvironment class >> addImageStartupTask: aBlock for: anObject [
	"^self
	 I add aBlock to the list of actions and note that this is for anObject.  If there are
	 currenty no tasks, I add myself as an ObejctMemort dependant."

	<category: 'image shutdown'>
	self haveTasks ifFalse: [ObjectMemory addDependent: self].
	self imageStartupTaskBlocks at: anObject put: aBlock.
	
    ]

    SpEnvironment class >> addImageShutdownTask: aBlock for: anObject [
	"^self
	 I add aBlock to the list of actions and note that this is for anObject.  If there are
	 currenty no tasks, I add myself as an ObejctMemort dependant."

	<category: 'image shutdown'>
	self haveTasks ifFalse: [ObjectMemory addDependent: self].
	self imageShutdownTaskBlocks at: anObject put: aBlock.
	
    ]

    SpEnvironment class >> allSubclassesOf: aClass [
	"^an Array
	 I return the array of classes which are subclasses of aClass."

	<category: 'queries'>
	^aClass allSubclasses asArray

	"SpEnvironment allSubclassesOf: Error"
    ]

    SpEnvironment class >> byteArrayFromHexString: aString [
	"SpEnvironmet byteArrayFromHexString: '1abc3'"

	<category: 'hex'>
	| x |
	x := ByteArray new: (aString size + 1) // 2.
	1 to: aString size // 2 do: [ :i |
	    x at: i put: (aString at: i + i - 1) digitValue * 16 +
			 (aString at: i + i) digitValue ].
	aString size odd ifTrue: [
	    x at: x size put: aString last digitValue ].
	^x
    ]

    SpEnvironment class >> characterFromInteger: anInteger [
	<category: 'services'>
	^Character codePoint: anInteger

	"SpEnvironment characterFromInteger: 32"
    ]

    SpEnvironment class >> evaluate: aString in: anEnvironment [
	"Squeak doesn't need anEnvironment as VW"

	<category: 'compiling'>
	^Behavior 
	    evaluate: aString
    ]

    SpEnvironment class >> evaluate: aString receiver: anObject in: anEnvironment [
	"Squeak doesn't need anEnvironment as VW"

	<category: 'compiling'>
	^Behavior 
	    evaluate: aString to: anObject
    ]

    SpEnvironment class >> hexStringFromByteArray: aByteArray [

	<category: 'hex'>
	| x |
	x := String new: aByteArray size * 2.
	2 to: x size by: 2 do: [ :i |
	    x at: i - 1 put: (Character digitValue: (aByteArray at: i // 2) // 16).
	    x at: i put: (Character digitValue: (aByteArray at: i // 2) \\ 16) ].
	^x
    ]

    SpEnvironment class >> imageStartupTaskBlocks [
	<category: 'image shutdown'>
	imageStartupTaskBlocks isNil 
	    ifTrue: [imageStartupTaskBlocks := IdentityDictionary new].
	^imageStartupTaskBlocks
    ]

    SpEnvironment class >> imageShutdownTaskBlocks [
	<category: 'image shutdown'>
	imageShutdownTaskBlocks isNil 
	    ifTrue: [imageShutdownTaskBlocks := IdentityDictionary new].
	^imageShutdownTaskBlocks
    ]

    SpEnvironment class >> integerFromString: aString [
	"^an Integer
	 We need this because of what looks like a bug in GemStone's String>>asNumber
	 (e.g. '16rFF' -> 1.6000000000000000E+01, not 255)."

	<category: 'services'>
	| radix |
	(aString indexOf: $r) = 0 ifTrue: [ ^aString asNumber ].
	radix := (aString copyUpTo: $r) asInteger.
	^Number
		readFrom: (aString readStream skipTo: $r; yourself)
		radix: radix.

	"SpEnvironment integerFromString: '32'"
    ]

    SpEnvironment class >> isAmbraiSmalltalk [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isDolphin [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isGemStone [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isHeadless [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isGNUSmalltalk [
	<category: 'testing'>
	^true
    ]

    SpEnvironment class >> isObjectStudio [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isSmalltalkX [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isSmalltalkXY [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isSqueak [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isVASmalltalk [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isVisualSmalltalk [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> isVisualWorks [
	<category: 'testing'>
	^false
    ]

    SpEnvironment class >> onUnix [
	"we are running on Unix, yes or no?"

	<category: 'testing'>
	^self onWindows not
    ]

    SpEnvironment class >> onWindows [
	"we are running on Windows, yes or no?"

	<category: 'testing'>
	^Smalltalk hostSystem ~ 'mingw|windows'
    ]

    SpEnvironment class >> removeStartupActionFor: anObject [
	"^self
	 I remove the task block for an object it it has one.  If the collection
	 of tasks is now empty, I remove myself as an ObjectMemory dependent."

	<category: 'image shutdown'>
	(self imageStartupTaskBlocks includesKey: anObject)
	    ifTrue:
		[imageStartupTaskBlocks removeKey: anObject.
		self haveTasks ifFalse: [ObjectMemory removeDependent: self]].
    ]

    SpEnvironment class >> removeShutdownActionFor: anObject [
	"^self
	 I remove the task block for an object it it has one.  If the collection
	 of tasks is now empty, I remove myself as an ObjectMemory dependent."

	<category: 'image shutdown'>
	(self imageShutdownTaskBlocks includesKey: anObject)
	    ifTrue:
		[imageShutdownTaskBlocks removeKey: anObject.
		self haveTasks ifFalse: [ObjectMemory removeDependent: self]].
    ]

    SpEnvironment class >> runShellCommandString: aCommandString [
	^Smalltalk system: aCommandString
    ]

    SpEnvironment class >> streamStartPosition [
	"^an Integer
	 Streams start at position 1 in GemStone(!)."

	<category: 'services'>
	^0
    ]

    SpEnvironment class >> update: aspect [
	<category: 'image shutdown'>
	 aspect == #returnFromSnapshot
	     ifTrue:
		[self imageStartupTaskBlocks values
		    do: [:aStartupTask | aStartupTask value]].
	 aspect == #aboutToQuit
	     ifTrue:
		[self imageShutdownTaskBlocks values
		    do: [:aShutdownTask | aShutdownTask value]].
	 ^self
    ]

    SpEnvironment class >> writeStackDumpForException: exception to: targetStream [
	<category: 'services'>
	exception context backtraceOn: targetStream
    ]
]



Object subclass: SpExceptionContext [
    
    <category: 'Sport-Exceptions'>
    <comment: 'Exceptions vary quite a bit between Smalltalk implementaions, despite the presence of the ANSI Smalltalk specification.  This class representss a portable exception context in which a block can be executed, exceptions trapped and handlers defined.'>

    SpExceptionContext class >> brokenPipeException [
	"I return the exception that get's thrown when a socket connection gets
	 broken."

	<category: 'native exceptions'>
	^SystemExceptions.FileError
    ]

    SpExceptionContext class >> for: aBlock on: anException do: exceptionBlock [
	"^an Object
	 I return the result of evaluating aBlock. In VisualWorks and other
	 Smalltalks which are ANSI compliant, I delegate to aBlock."

	<category: 'instance creation'>
	^aBlock on: anException do: exceptionBlock
    ]

    SpExceptionContext class >> for: aBlock onAnyExceptionDo: exceptionBlock [
	"^an Object
	 I execute aBlock and if there is any exception I evaluate exceptionBlock.
	 Essentially, I look out for the most abstract kind of exception which ,
	 of course, will vary between Smalltalk implementations."

	<category: 'instance creation'>
	^aBlock on: Exception do: exceptionBlock
    ]
]



Object subclass: SpFileStream [
    | underlyingStream filename |
    
    <category: 'Sport-Files'>
    <comment: 'synchronized with 2.030'>

    SpFileStream class >> appendingToFilename: aSpFilename [
	"^a SpFileStream
	 I create a new instance of myself to append to the file identified by anOSkFilename."

	<category: 'instance creation'>
	^self new appendingToFilename: aSpFilename
    ]

    SpFileStream class >> readingFromFileNamed: aString [
	"^a SpFileStream
	 I create a new instance of myself to read from a file named aString."

	<category: 'instance creation'>
	^self new readingFromFileNamed: aString
    ]

    SpFileStream class >> readingFromFilename: aSpFilename [
	"^a SpFileStream
	 I create a new instance of myself to read the file identified by anOSkFilename."

	<category: 'instance creation'>
	^self new readingFromFilename: aSpFilename
    ]

    SpFileStream class >> writingToFileNamed: aString [
	"^a SpFileStream
	 I create a new instance of myself to write to a file named aString."

	<category: 'instance creation'>
	^self new writingToFileNamed: aString
    ]

    SpFileStream class >> writingToFilename: aSpFilename [
	"^an SpFileStream
	 I create a new instance of myself to append to the file identified by aSpFilename."

	<category: 'instance creation'>
	^self new writingToFilename: aSpFilename
    ]

    appendingToFilename: aSpFilename [
	<category: 'initialize-release'>
	self filename: aSpFilename.
	underlyingStream := FileStream
		open: aSpFilename name
		mode: FileStream append.
	^self
    ]

    atEnd [
	<category: 'services'>
	^self underlyingStream atEnd
    ]

    binary [
	<category: 'services'>
	"do nothing"
    ]

    close [
	<category: 'services'>
	^self underlyingStream close
    ]

    closed [
	<category: 'services'>
	^self underlyingStream isOpen not
    ]

    contentsStream [
	<category: 'accessing'>
	^self underlyingStream contents readStream
    ]

    cr [
	<category: 'services'>
	^self underlyingStream cr
    ]

    filename [
	<category: 'accessing'>
	^filename
    ]

    filename: aSpFilename [
	<category: 'accessing'>
	filename := aSpFilename
    ]

    flush [
	<category: 'services'>
	^self underlyingStream flush
    ]

    next [
	<category: 'services'>
	^self underlyingStream next
    ]

    nextPut: anObject [
	<category: 'services'>
	^self underlyingStream nextPut: anObject
    ]

    nextPutAll: aCollection [
	<category: 'services'>
	^self underlyingStream nextPutAll: aCollection
    ]

    peek [
	<category: 'services'>
	^self underlyingStream peek
    ]

    position [
	<category: 'services'>
	^self underlyingStream position
    ]

    position: aNumber [
	<category: 'services'>
	^self underlyingStream position: aNumber
    ]

    readingFromFileNamed: aString [
	"^self
	 I initialize myself to write to a file named aString."

	<category: 'initialize-release'>
	filename := aString.
	underlyingStream := (File path: aString) readStream.
	^self
    ]

    readingFromFilename: aSpFilename [
	<category: 'initialize-release'>
	self filename: aSpFilename.
	underlyingStream := FileStream
		open: aSpFilename name
		mode: FileStream read.
	^self
    ]

    skip: anInteger [
	<category: 'services'>
	^self underlyingStream skip: anInteger
    ]

    store: anObject [
	<category: 'services'>
	^self underlyingStream store: anObject
    ]

    throughAll: aCollection [
	<category: 'services'>
	^self underlyingStream upToAll: aCollection
    ]

    underlyingStream [
	<category: 'accessing'>
	^underlyingStream
    ]

    upTo: anObject [
	<category: 'services'>
	^self underlyingStream upTo: anObject
    ]

    upToAll: aCollection [
	"TODO: return aCollection at the end, as in VW"
	<category: 'services'>
	^self underlyingStream upToAll: aCollection
    ]

    upToEnd [
	<category: 'services'>
	^self underlyingStream upToEnd
    ]

    writingToFileNamed: aString [
	"^self
	 I initialize myself to write to a file named aString."

	<category: 'initialize-release'>
	filename := aString.
	underlyingStream := (File path: aString) writeStream.
	^self
    ]

    writingToFilename: aSpFilename [
	<category: 'initialize-release'>
	self filename: aSpFilename.
	underlyingStream := FileStream
		open: aSpFilename name
		mode: FileStream write.
	^self
    ]
]



Object subclass: SpFilename [
    | filename |
    
    <category: 'Sport-Files'>
    <comment: 'A SpFilename represents a file or directory and allows operations like delete, makeDirectory, etc.'>

    SpFilename class >> named: aString [
	"^a SpFilename
	 I create a new instance of myself to represent the filename identified by aString."

	<category: 'instance creation'>
	^self new named: aString
    ]

    appendStream [
	"^a SpFileStream
	 I create an append stream on the file I represent."

	<category: 'services'>
	^SpFileStream appendingToFilename: self
    ]

    asAbsoluteFilename [
	"Answer a Filename pointing to the same file using absolute path.
	 The method may answer the receiver it it is already absolute."

	<category: 'accessing'>
	^self class named: (File fullNameFor: self asString)
    ]

    asFilename [
	<category: 'accessing'>
	^self
    ]

    asString [
	<category: 'accessing'>
	^self filename
    ]

    construct: extraFn [
	"Make a new instance, treating the receiver as a directory, and
	 the string argument as a file within the pathname."

	<category: 'private'>
	^self class named: self filename , (String with: self separator) , extraFn
    ]

    createdTimestamp [
	"a SpTimestamp
	 timestamp of file creation."

	<category: 'accessing'>
	| entry |
	entry := File name: self asString.
	^SpTimestamp fromSeconds: entry creationTime asSeconds
    ]

    delete [
	<category: 'services'>
	| entry |
	entry := File name: self asString.
	entry remove
    ]

    directory [
	"a filename of the directory for this Filename."

	<category: 'accessing'>
	^self class named: self head
    ]

    directoryContents [
	<category: 'services'>
	"not yet ported"
    ]

    exists [
	"^a Boolean
	 I return true if the file or direcotory I represent actually exists"

	<category: 'testing'>
	^(File name: self asString) exists
    ]

    extension [
	"Answer the receiver's extension if any.  This is the characters from the
	 last occurrence of a period to the end, inclusive. E.g. the extension of
	 'squeak.image' is '.image'. Answer nil if none.  Note that e.g. .login has no
	 extension."

	<category: 'accessing'>
	^(File extensionFor: self asString)
    ]

    filename [
	"^a String"

	<category: 'private'>
	^filename
    ]

    head [
	"Answer the directory prefix as a String."

	<category: 'accessing'>
	^(File pathFor: self asString)
    ]

    isAbsolute [
	"Answer true if this name is absolute (e.g. not relative to the
	 'current directory')."

	<category: 'testing'>
	^(File fullNameFor: self asString) = self asString
    ]

    contentsOfEntireFile [
	<category: 'testing'>
	^(File name: self asString) contents
    ]

    fileSize [
	<category: 'testing'>
	^(File name: self asString) size
    ]

    isDirectory [
	<category: 'testing'>
	^(File name: self asString) isDirectory
    ]

    isRelative [
	"Answer true if this name must be interpreted relative to some directory."

	<category: 'testing'>
	^self isAbsolute not
    ]


    makeDirectory [
	<category: 'services'>
	[Directory create: self asString] on: Error do: [:ex | ]
    ]

    modifiedTimestamp [
	"a SpTimestamp
	 timestamp of last file modification"

	<category: 'accessing'>
	| entry |
	entry := File name: self asString.
	^SpTimestamp fromSeconds: entry lastModifyTime asSeconds
    ]

    name [
	"a String
	 return the filename identified by self."

	<category: 'initialize-release'>
	^filename
    ]

    named: aString [
	"^self
	 I initialize myself to represent the filename identified by aString."

	<category: 'initialize-release'>
	filename := aString.
	^self
    ]

    readStream [
	"^a SpFileStream
	 I create a read stream on the file I represent."

	<category: 'services'>
	^SpFileStream readingFromFilename: self
    ]

    separator [
	"Answer the platform's filename component separator."

	<category: 'private'>
	^Directory pathSeparator
    ]

    lastSeparatorIndex [
	"Answer the index of the last filename component separator in
	 `self asString'."
	^self asString lastIndexOf: self separator ifAbsent: [nil]
    ]

    tail [
	"Answer the filename suffix as a String."

	<category: 'accessing'>
	| index nm |
	nm := self asString.
	(index := self lastSeparatorIndex) notNil 
	    ifTrue: [^nm copyFrom: index + 1 to: nm size]
	    ifFalse: [^nm copy]
    ]

    writeStream [
	"^a SpFileStream
	 I create a write stream on the file I represent."

	<category: 'services'>
	^SpFileStream writingToFilename: self
    ]
]



Object subclass: SpSocket [
    | underlyingSocket class socketAddress |
    
    <category: 'Sport-Sockets'>
    <comment: 'synchronized with 2.030'>

    SpSocket class >> connectToServerOnHost: hostName port: portNumber [
	"^a SpSocket
	 I return a new instance of myself which represents a socket connecter
	 to a server listening on portNumber at hostName."

	<category: 'instance creation'>
	| newSocket |
	newSocket := self newTCPSocket.
	newSocket connectTo: (SpIPAddress hostName: hostName port: portNumber).
	^newSocket
    ]

    SpSocket class >> newSocketPair [
	"I return an array containing two SpSockets each representing one end of a
	 TCP connection. Port is fixed (for now)!!"

	"SpSocket newSocketPair"

	<category: 'instance creation'>
	| s1 s2 s3 |
	
	[s1 := (self newTCPSocket)
		    bindSocketAddress: (SpIPAddress hostName: 'localhost' port: 3523);
		    listenBackloggingUpTo: 50.
	s2 := SpSocket connectToServerOnHost: 'localhost' port: 3523.
        [
	    (s3 := s1 accept) isNil ] whileTrue: [ Processor yield ] ] 
		ifCurtailed: 
		    [s1 close.
		    s2 close].
	s1 close.
	^Array with: s3 with: s2
    ]

    SpSocket class >> newTCPSocket [
	"^a SpSocket
	 I return a new instance of myself that represents an unconfigured TCP socket."

	<category: 'instance creation'>
	^self new onClass: Sockets.StreamSocket
    ]

    SpSocket class >> onNativeclientSocket: aNativeSocket for: aServerSocket [
	"^a SpSocket
	 I create a new instance of my self at the request of aServerSocket  where
	 this new instance will be a connected client socket (connected via aNativeSoket)."

	<category: 'private'>
	^self new onNativeclientSocket: aNativeSocket for: aServerSocket
    ]

    accept [
	"^a SpSocket
	 I accept the next connection made to the server socket I represent.
	 This is a *blocking* request. That is, this method will not exit until
	 an inbound socket connection is made. When that happens the new
	 socket connected to the client (not the server socket) will be returned."

	<category: 'services-status'>
	^SpExceptionContext 
	    for: 
		[| clientSpecificSocket |
		[self underlyingSocket waitForConnection.
		(clientSpecificSocket := self underlyingSocket accept: Sockets.StreamSocket) isNil] 
			whileTrue: [ Processor yield ].
		self class onNativeclientSocket: clientSpecificSocket for: self]
	    on: Error
	    do: 
		[:ex | 
		(SpSocketError new)
		    parameter: ex;
		    raiseSignal: 'Error while trying to accept a socket connection.']
    ]

    acceptRetryingIfTransientErrors [
	"^a SpSocket
	 I try to do an accept.  If I get an exception which is 'transient' I retry.
	 For now in Squeak, I just do the accept"

	"^SpExceptionContext
	 for: [self accept]
	 on: OSErrorHolder transientErrorSignal
	 do: [:ex | ex restart]"

	<category: 'services-status'>
	^self accept
    ]

    bindSocketAddress: aSocketAddress [
	"^self
	 Equivalent of: bind(int sockfd, struct sockaddr *my_addr, socklen_t	addrlen);
	 see man bind. Bind the socket to aSocketAddress.	It seems that Squeak merges
	 the 'bind' and the 'listen', so here I'll just	remember the socket address and
	 use it when I get the listen request."

	<category: 'services-status'>
	socketAddress := aSocketAddress.
	^self
    ]

    close [
	"^self
	 The same as the close() posix function."

	<category: 'services-status'>
	self underlyingSocket isNil ifTrue: [ ^self ].
	self underlyingSocket close.
	underlyingSocket := nil
    ]

    connectTo: aSocketAddress [
	"^self
	 I instruct my underlying socket to connect to aSocketAddress."

	<category: 'services-status'>
	underlyingSocket := class
	    remote: (Sockets.IPAddress fromBytes: aSocketAddress hostAddress)
	    port: aSocketAddress portNumber
    ]

    getPeerName [
	"^a SpSocketAddress
	 see man getpeername.
	 I return the socket address of the other/remote/peer end of the socket I represent."

	<category: 'services-accessing'>
	^SpIPAddress host: self underlyingSocket remoteAddress asByteArray
	    port: self underlyingSocket remotePort
    ]

    getSocketName [
	"^a SpSocketAddress
	 see: man getsockname
	 I rreturn my local socket address which may be any subclass of SpSocketAddress."

	<category: 'services-accessing'>
	^SpIPAddress host: self underlyingSocket localAddress asByteArray
	    port: self underlyingSocket localPort
    ]

    isActive [
	"^a Boolean
	 In Squeak there is no simple >>isActive test, it seems."

	<category: 'testing'>
	^self underlyingSocket isOpen
    ]

    listenBackloggingUpTo: aNumberOfConnections [
	"^self
	 I set the socket I represent listening for incomming connections,
	 allowing a 	backlog of up to aNumberOfConnections.
	 Note that GNU Smalltalk combines bind and listen so I noted the
	 socket address when I was asked to bind - and I use that now."

	<category: 'services-status'>
	| localAddress |
	localAddress := socketAddress ifNotNil: [
	    Sockets.IPAddress fromBytes: socketAddress hostAddress ].

	underlyingSocket := Sockets.ServerSocket
	    port: socketAddress portNumber
	    queueSize: aNumberOfConnections
	    bindTo: localAddress.
	^self
    ]

    onNativeclientSocket: aNativeSocket for: aServerSocket [
	"^self
	 I initialize myself with the same properties as aServerSocket and with
	 aNativeSocket as my underlying socket."

	"communicationDomain := aServerSocket communicationDomain.
	 socketType := aServerSocket socketType.
	 protocolNumber := aServerSocket protocolNumber."

	<category: 'private'>
	underlyingSocket := aNativeSocket.
	^self
    ]

    onClass: aSocketClass [
	<category: 'initialize-release'>
	class := aSocketClass.
	^self
    ]

    read: targetNumberOfBytes [
	"^a ByteArray
	 I attempt to read the targetNumberOfBytes from my underlying socket.
	 If the targetNumberOfBytes	are not available, I return what I can get."

	<category: 'services-io'>
	| answer n |
	answer := ByteArray new: targetNumberOfBytes.
	n := self underlyingSocket nextAvailable: targetNumberOfBytes into: answer startingAt: 1.
	n < targetNumberOfBytes ifTrue: [ answer := answer copyFrom: 1 to: n ].
	^answer
    ]

    readInto: aByteArray startingAt: startIndex for: aNumberOfBytes [
	"^an Integer
	 I return the number of bytes actually read.	In Squeak it seems we can not specify the
	 number of bytes to be read.	We get what its there no matter how much their is!!"

	<category: 'services-io'>
	^self underlyingSocket nextAvailable: aNumberOfBytes into: aByteArray startingAt: startIndex
    ]

    readyForRead [
	"^a Boolean
	 I return true if a read operation will return some number of bytes."

	<category: 'services-io'>
	^self underlyingSocket canRead
    ]

    setAddressReuse: aBoolean [
	"^self
	 c.f. self class >>socketOptions and self >>setOptionForLevel:optionID:value:
	 If a boolean is true, I set address reuse on, otherwise I set address reuse	off."

	"self underlyingSocket setOption: 'SO_REUSEADDR' value: aBoolean"

	<category: 'services-options'>
	
    ]

    underlyingSocket [
	<category: 'private'>
	^underlyingSocket
    ]

    waitForReadDataUpToMs: aNumberOfMilliseconds [
	"^a Boolean
	 I return true if we think data became available within
	 aNumberOfMilliseconds, and false if we timed out.
	 Squeak wants a timeout in seconds, so I convert it here."

	<category: 'services-io'>
	| bad sem timeout socketWait |
	self underlyingSocket canRead ifTrue: [ ^true ].
	sem := Semaphore new.
	timeout :=
	    [ (Delay forMilliseconds: aNumberOfMilliseconds) wait. sem signal ]
		fork.
	socketWait :=
	    [ self underlyingSocket ensureReadable. sem signal ]
		fork.
	[ sem wait ] ensure: [
	    timeout terminate.
	    socketWait terminate ].
	^self underlyingSocket canRead
    ]

    write: sourceByteArray [
	"^an Integer
	 I write the contents of the sourceByteArray to my underlying Socket.
	 I return the number of bytes written."

	<category: 'services-io'>
	^SpExceptionContext 
	    for: [self underlyingSocket nextPutAll: sourceByteArray.
		sourceByteArray size]
	    on: Error
	    do: [:ex | SpSocketError raiseSignal: ex]
    ]

    writeFrom: aByteArray startingAt: startIndex for: length [
	"^an Integer
	 I return the number of bytes actually written."

	<category: 'services-io'>
	^SpExceptionContext 
	    for: 
		[self underlyingSocket 
		    next: length
		    putAll: aByteArray
		    startingAt: startIndex.
		length]
	    on: Error
	    do: [:ex | SpSocketError raiseSignal: ex]
    ]
]



Object subclass: SpSocketAddress [
    
    <category: 'Sport-Sockets'>
    <comment: 'synchronized with 2.030'>

    SpSocketAddress class >> on: subjectAddress for: aSocket [
	"^a SpSocketAddress
	 Well, in the future there may be more than one kind of socket address,
	 but for now there is just SpIPAddress, so I return one of those on the
	 details embodied in the subjectAddress.
	 No use is made of aSocket as yet, but it will be useful when there
	 are more kinds of socket address supported."

	<category: 'instance creation'>
	^SpIPAddress host: subjectAddress hostAddress port: subjectAddress port
    ]
]



SpSocketAddress subclass: SpIPAddress [
    | hostAddress portNumber |
    
    <category: 'Sport-Sockets'>
    <comment: 'synchronized with 2.030'>

    SpIPAddress class >> host: aHostAddress port: aPortNumber [
	"^a SpSocketAddress
	 I create a new instance of myself which represents an IP address/port
	 combination (a TCP/IP address, really). Note that aHostAddress must be a
	 four element byte array (e.g. #[127 0 0 1]) ."

	<category: 'instance creation'>
	^self new host: aHostAddress port: aPortNumber
    ]

    SpIPAddress class >> hostName: aHostNameString port: aPortNumber [
	"^a SpSocketAddress
	 I translate aHostNameString to an IP address and then create
	 a new instance of myself with >>host:port:"

	<category: 'instance creation'>
	^self host: (Sockets.IPAddress fromString: aHostNameString) asByteArray
	    port: aPortNumber
    ]

    host: aHostAddress port: aPortNumber [
	<category: 'initialize-release'>
	hostAddress := aHostAddress.
	portNumber := aPortNumber
    ]

    hostAddress [
	<category: 'accessing'>
	^hostAddress
    ]

    hostAddressString [
	<category: 'printing'>
	| targetStream |
	targetStream := String new writeStream.
	targetStream
	    nextPutAll: (self hostAddress at: 1) printString;
	    nextPut: $.;
	    nextPutAll: (self hostAddress at: 2) printString;
	    nextPut: $.;
	    nextPutAll: (self hostAddress at: 3) printString;
	    nextPut: $.;
	    nextPutAll: (self hostAddress at: 4) printString.
	^targetStream contents
    ]

    portNumber [
	<category: 'accessing'>
	^portNumber
    ]
]



Object subclass: SpStringUtilities [
    
    <category: 'Sport-Environmental'>
    <comment: 'synchronized with 2.030'>

    SpStringUtilities class >> bytes: subjectBytes asStringUsingEncodingNames: anEncodingName [
	<category: 'services-encoding'>
	^subjectBytes asString
    ]

    SpStringUtilities class >> prevIndexOf: anElement from: startIndex to: stopIndex in: aString [
	"Answer the previous index of anElement within the receiver between
	 startIndex and stopIndex working backwards through the receiver.  If the receiver
	 does not contain anElement, answer nil"

	<category: 'services'>
	startIndex to: stopIndex
	    by: -1
	    do: [:i | (aString at: i) = anElement ifTrue: [^i]].
	^nil
    ]

    SpStringUtilities class >> string: subjectString asBytesUsingEncodingNamed: anEncodingName [
	<category: 'services-encoding'>
	^subjectString asByteArray
    ]

    SpStringUtilities class >> stringFromBytes: aByteArray [
	"^a String
	 In GemStone ['Hello, World' asByteArray asString] returns the string 'aByteArray' !!
	 This is the boring long way of getting a string from a ByteArray - but it does work
	 in GemStone."

	"SpStringUtilities stringFromBytes: ('Hello, World' asByteArray)"

	<category: 'services-encoding'>
	^aByteArray asString
    ]

    SpStringUtilities class >> tokensBasedOn: separatorString in: aString [
	"Answer an OrderedCollection of the sub-sequences
	 of the receiver that are separated by anObject."

	<category: 'services'>
	| result lastIdx idx lastToken |
	result := OrderedCollection new.
	aString size = 0 ifTrue: [^result].
	lastIdx := 0.
	
	[idx := aString indexOfSubCollection: separatorString startingAt: lastIdx + 1.
	idx > 0] 
		whileTrue: 
		    [idx == (lastIdx + 1) 
			ifTrue: [result addLast: String new]
			ifFalse: [result addLast: (aString copyFrom: lastIdx + 1 to: idx - 1)].
		    lastIdx := idx].
	lastToken := lastIdx = aString size 
		    ifTrue: [String new]
		    ifFalse: [aString copyFrom: lastIdx + 1 to: aString size].
	result addLast: lastToken.
	^result
    ]

    SpStringUtilities class >> trimBlanksFrom: aString [
	"^a String
	 I return a copy of aString with all leading and trailing blanks removed."

	<category: 'services'>
	| first last |
	first := 1.
	last := aString size.
	[last > 0 and: [(aString at: last) isSeparator]] 
	    whileTrue: [last := last - 1].
	^last == 0 
	    ifTrue: [String new]
	    ifFalse: 
		[[first < last and: [(aString at: first) isSeparator]] 
		    whileTrue: [first := first + 1].
		aString copyFrom: first to: last]
    ]
]



Object subclass: SpTimestamp [
    | underlyingTimestamp |
    
    <category: 'Sport-Times'>
    <comment: 'synchronized with 2.030'>

    SpTimestamp class >> fromDate: aDate andTime: aTime [
	<category: 'instance creation'>
	^self new fromDate: aDate andTime: aTime
    ]

    SpTimestamp class >> fromRFC1123String: aString [
	"^a SpTimestamp"

	<category: 'instance creation'>
	| sourceStream dd mmm yyyy time |
	^SpExceptionContext for: 
		[sourceStream := ReadStream on: aString.
		sourceStream upTo: Character space.
		dd := sourceStream upTo: Character space.
		mmm := sourceStream upTo: Character space.
		yyyy := sourceStream upTo: Character space.
		time := sourceStream upTo: Character space.
		self fromDate: (Date 
			    newDay: dd asNumber
			    month: mmm
			    year: yyyy asNumber)
		    andTime: (Time readFrom: (ReadStream on: time))]
	    onAnyExceptionDo: 
		[:exception | 
		SpError raiseSignal: 'Error parsing RFC1123 date: ' , aString]
    ]

    SpTimestamp class >> fromSeconds: anInteger [
	"^a SpTimestamp
	 I return an instance of myself that represents anInteger number of seconds since..."

	<category: 'instance creation'>
	^self new fromSeconds: anInteger
    ]

    SpTimestamp class >> fromTimeStamp: aTimeStamp [
	"^a SpTimestamp, from a Squeak TimeStamp"

	<category: 'instance creation'>
	^self fromDate: aTimeStamp asDate andTime: aTimeStamp asTime
    ]

    SpTimestamp class >> now [
	"^a SpTimestamp
	 I return a new instance of myself which represents the time now in the
	 UTC (GMT ish) time zone."

	<category: 'instance creation'>
	^self new asNowUTC
    ]

    < aSpTimeStamp [
	<category: 'comparing'>
	^self underlyingTimestamp < aSpTimeStamp underlyingTimestamp
    ]

    = aSpTimeStamp [
	<category: 'comparing'>
	^self underlyingTimestamp = aSpTimeStamp underlyingTimestamp
    ]

    > aSpTimeStamp [
	<category: 'comparing'>
	^self underlyingTimestamp > aSpTimeStamp underlyingTimestamp
    ]

    asDate [
	<category: 'converting'>
	^SpDate onDate: self underlyingTimestamp asDate
    ]

    asNowUTC [
	"^self
	 Cheat for now and assumen that Timestamp>>now is UTC."

	<category: 'initialize-release'>
	underlyingTimestamp := DateTime now asUTC.
	^self
    ]

    asRFC1123String [
	"^a String
	 c.f  >>asRFC1123StringOn:"

	<category: 'converting'>
	| targetStream |
	targetStream := String new writeStream.
	self asRFC1123StringOn: targetStream.
	^targetStream contents
    ]

    asRFC1123StringOn: targetStream [
	"^self"

	<category: 'converting'>
	| aTimestamp |
	aTimestamp := self underlyingTimestamp asUTC.
	targetStream
            nextPutAll: aTimestamp dayOfWeekAbbreviation;
            nextPutAll: (aTimestamp day < 10 ifTrue: [ ', 0' ] ifFalse: [ ', ' ]);
            print: aTimestamp day;
            space;
            nextPutAll: aTimestamp monthAbbreviation;
            space;
            print: aTimestamp year;
            space;
            print: aTimestamp asTime;
	    nextPutAll: ' GMT'
    ]

    asSeconds [
	"^an Integer
	 I return the timestamp as a number of seconds."

	<category: 'converting'>
	^self underlyingTimestamp asSeconds
    ]

    asSpTimestamp [
	<category: 'converting'>
	^self
    ]

    asTime [
	<category: 'converting'>
	^self underlyingTimestamp asTime
    ]

    fromDate: aDate andTime: aTime [
	"^self
	 Initialize myself on the basis of aDate and aTime."

	<category: 'initialize-release'>
	underlyingTimestamp := DateTime
	    year: aDate year
	    month: aDate monthIndex
	    day: aDate day
	    hour: aTime hour
	    minute: aTime minute
	    second: aTime second.
	^self
    ]

    fromSeconds: anInteger [
	"^a SpTimestamp
	 I return an instance of myself that represents anInteger number of seconds
	 since January 1, 1901 0:00:00.000.  BTW, negative values of anInteger are fine."

	<category: 'initialize-release'>
	underlyingTimestamp := DateTime year: 1901 month: 1
		day: anInteger // 86400 + 1
		hour: 0 minute: 0 second: anInteger \\ 86400.
	^self
    ]

    hash [
	<category: 'comparing'>
	^self underlyingTimestamp hash
    ]

    printString [
	<category: 'private'>
	^self underlyingTimestamp printString
    ]

    underlyingTimestamp [
	<category: 'private'>
	^underlyingTimestamp
    ]
]



Object subclass: SpTranscript [
    
    <category: 'Sport-Environmental'>
    <comment: 'synchronized with 2.030'>

    SpTranscript class >> cr [
	<category: 'logging'>
	^SpEnvironment isHeadless ifTrue: [self] ifFalse: [Transcript cr]
    ]

    SpTranscript class >> nextPut: anObject [
	<category: 'logging'>
	^self show: (String with: anObject)
    ]

    SpTranscript class >> nextPutAll: aCollection [
	<category: 'logging'>
	^self show: aCollection
    ]

    SpTranscript class >> show: aString [
	<category: 'logging'>
	^SpEnvironment isHeadless 
	    ifTrue: [self]
	    ifFalse: [Transcript show: aString]
    ]
]



Object subclass: SpWeakArray [
    
    <category: 'Sport-Environmental'>
    <comment: 'synchronized with 2.030'>

    SpWeakArray class >> new: anInteger [
	"^a WeakArray
	 I don't return an instance of myself, I return a real WeakArray."

	<category: 'instance creation'>
	^WeakArray new: anInteger
    ]

    SpWeakArray class >> withAll: aCollection [
	"^a WeakArray
	 I don't return an instance of myself at all. I return a real Weak array."

	<category: 'instance creation'>
	^WeakArray withAll: aCollection asArray
    ]
]



Error subclass: SpAbstractError [
    <category: 'Sport-Exceptions'>
    <comment: 'synchronized with 2.030'>

    SpAbstractError class >> mayResume [
	<category: 'testing'>
	^false
    ]

    SpAbstractError class >> raiseSignal [
	"Raise an an exception."

	<category: 'signalling'>
	^self signal
    ]

    SpAbstractError class >> signalWith: anObject [
	"Raise an an exception."

	<category: 'signalling'>
	^self new signalWith: anObject
    ]

    SpAbstractError class >> raiseSignal: aString [
	"Raise an an exception."

	<category: 'signalling'>
	^self signal: aString
    ]

    errorString [
	<category: 'accessing'>
	^self messageText
    ]

    isResumable [
	"Determine whether an exception is resumable."

	<category: 'priv handling'>
	^self class mayResume
    ]

    parameter [
	<category: 'accessing'>
	^self tag
    ]

    parameter: anObject [
	<category: 'accessing'>
	self tag: anObject
    ]

    raiseSignal [
	"Raise an an exception."

	<category: 'signalling'>
	^self signal
    ]

    raiseSignal: aString [
	"Raise an an exception."

	<category: 'signalling'>
	^self signal: aString
    ]

    signalWith: anObject [
	"Raise an an exception."

	<category: 'signalling'>
	^self tag: anObject; signal
    ]
]



SpAbstractError subclass: SpError [
    
    <category: 'Sport-Exceptions'>
    <comment: 'synchronized with 2.030'>
]



SpError subclass: SpSocketError [
    
    <category: 'Sport-Sockets'>
    <comment: 'synchronized with 2.030'>
]

