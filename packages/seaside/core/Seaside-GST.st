Fraction extend [
    Object >> isFraction [
	<category: '*Seaside-Squeak-Core'>
	^false
    ]

    isFraction [
	<category: '*Seaside-Squeak-Core'>
	^true
    ]
]

SystemDictionary extend [
    garbageCollect [
	ObjectMemory globalGarbageCollect
    ]
]

BlockClosure extend [
    fixCallbackTemps [
	<category: '*Seaside-Squeak-Core'>
    ]

    valueWithPossibleArgument: anObject [
	<category: '*Seaside-Squeak-Core'>
	^self numArgs = 0
	    ifTrue: [ self value ]
	    ifFalse: [ self value: anObject ]
    ]
]

Dictionary extend [
    restoreFromSnapshot: anObject [
	<category: '*Seaside-Squeak-Core'>
	super restoreFromSnapshot: anObject snapshotCopy
    ]

    snapshotCopy [
	<category: '*Seaside-Squeak-Core'>
	^self deepCopy
    ]

    keysSortedSafely [
	^self keys asSortedCollection
    ]
]

Bag extend [
    restoreFromSnapshot: anObject [
	<category: '*Seaside-Squeak-Core'>
	super restoreFromSnapshot: anObject snapshotCopy
    ]

    snapshotCopy [
	<category: '*Seaside-Squeak-Core'>
	^self deepCopy
    ]
]

OrderedCollection extend [
    restoreFromSnapshot: anObject [
	<category: '*Seaside-Squeak-Core'>
	super restoreFromSnapshot: anObject snapshotCopy
    ]

    snapshotCopy [
	<category: '*Seaside-Squeak-Core'>
	^self copy
    ]
]

Set extend [
    restoreFromSnapshot: anObject [
	<category: '*Seaside-Squeak-Core'>
	super restoreFromSnapshot: anObject snapshotCopy
    ]

    snapshotCopy [
	<category: '*Seaside-Squeak-Core'>
	^self copy
    ]
]

SequenceableCollection extend [
    associationsDo: aBlock [
	<category: '*Seaside-Squeak-Core'>
	self do: aBlock
    ]

    atRandom: aRandom [
	<category: '*Seaside-Squeak-Core'>
	^self at: (aRandom between: 1 and: self size)
    ]
]

Collection extend [
    Object >> isCollection [
	<category: '*Seaside-Squeak-Core'>
	^false
    ]

    isCollection [
	<category: '*Seaside-Squeak-Core'>
	^true
    ]

    removeAllFoundIn: aCollection [
	<category: '*Seaside-Squeak-Core'>
	self removeAll: aCollection ifAbsent: [ :x | ]
    ]

    isEmptyOrNil [
	<category: '*Seaside-Squeak-Core'>
	^self isEmpty
    ]
]

UndefinedObject extend [
    isEmptyOrNil [
	<category: '*Seaside-Squeak-Core'>
	^true
    ]
]

Object extend [
    isEmptyOrNil [
	<category: '*Seaside-Squeak-Core'>
	^false
    ]

    beMutable [
	<category: '*Seaside-Squeak-Core'>
	"a hack that allows to cache a value in a literal array"
	self makeReadOnly: false
    ]

    className [
	<category: '*Seaside-Squeak-Core'>
	^self class name
    ]

    printStringLimitedTo: anInteger [
	<category: 'accessing'>
	^(Sockets.WriteBuffer on: (String new: anInteger))
	    flushBlock: [ :coll :size | ^(coll copyFrom: 1 to: size), '...' ];
	    print: self;
	    contents
    ]

   restoreFromSnapshot: anObject [
        <category: '*Seaside-Core'>
	self basicSize = anObject basicSize
	    ifFalse: [ self become: (self class basicNew: anObject basicSize) ].
	self class instSize = anObject class instSize
	    ifFalse: [ self halt ].
        1 to: self class instSize do: [ :i |
	    self instVarAt: i put: (anObject instVarAt: i) ].
        1 to: self basicSize do: [ :i |
	    self basicAt: i put: (anObject basicAt: i) ]
    ]
]

Character extend [
    to: aCharacter [
	^self codePoint
	    to: aCharacter codePoint
	    collect: [ :i | Character codePoint: i ]
    ]
]

Integer extend [
    atRandom [
	<category: '*Seaside-Squeak-Core'>
	^Random between: 1 and: self size
    ]

    printStringBase: anInteger [
	<category: '*Seaside-Squeak-Core'>
	^self printString: anInteger
    ]

    asTwoCharacterString [
	<category: '*Seaside-Squeak-Core'>
	(self between: 0 and: 9)
	    ifTrue: [ ^String with: $0 with: (Character digitValue: self) ].
	(self between: -9 and: 99) ifTrue: [ ^self printString ].
	^self printString copyFrom: 1 to: 2.
    ]
]

Symbol extend [
    asMutator [
         ^(self copyWith: $:) asSymbol
    ]

    capitalized [
	<category: '*Seaside-Squeak-Core'>
	^self asString capitalized asSymbol
    ]

    isKeyword [
	^self last = $:
    ]

    isUnary [
	^self numArgs = 0
    ]
]

FileStream extend [
    Stream >> closed [
	<category: '*Seaside-Squeak-Core'>
	^false
    ]

    closed [
	<category: '*Seaside-Squeak-Core'>
	^self isOpen not
    ]
]

Stream extend [
    binary [
	<category: '*Seaside-Squeak-Core'>
    ]

    asMIMEDocument [
	<category: '*Seaside-Squeak-Core'>
	^self asMIMEDocumentType: 'text/plain' toMimeType
    ]

    asMIMEDocumentType: mimeType [
	<category: '*Seaside-Squeak-Core'>
	^Seaside.WAMimeDocument contentType: mimeType seasideString contentStream: self
    ]

    upToAndSkipThroughAll: aCollection [
	"Needed for Seaside ports to other dialects where #upToAll: may have
	different semantics"
	<category: '*Seaside-Squeak-Core'>
	^self upToAll: aCollection
    ]
]

Number extend [
    printStringAsCents [
	^'$', ((self / 100) asScaledDecimal: 2) displayString
    ]
]

Date class extend [
    daysInMonthNumber: monthNumber forYear: yearNumber [
	<category: '*Seaside-Squeak-Core'>
	^self daysInMonthIndex: monthNumber forYear: yearNumber
    ]

    newDay: dayNumber monthNumber: monthNumber year: yearNumber [
	<category: '*Seaside-Squeak-Core'>
	^self newDay: dayNumber monthIndex: monthNumber year: yearNumber
    ]
]

DirectedMessage extend [
    valueWithPossibleArgument: anObject [
	<category: '*Seaside-Squeak-Core'>
	^self selector numArgs = 0
	    ifTrue: [ self receiver perform: self selector ]
	    ifFalse: [ self receiver perform: self selector with: anObject ]
    ]

    evaluateWithArguments: anArray [
	<category: '*Seaside-Squeak-Core'>
	^self receiver perform: self selector withArguments: anArray
    ]
]

Behavior extend [
    fullName [
	<category: '*Seaside-Squeak-Core'>
	^self nameIn: Smalltalk
    ]
]

CharacterArray extend [
    capitalized [
	<category: '*Seaside-Squeak-Core'>
	| s |
	s := self copy.
	s at: 1 put: (self at: 1) asUppercase.
	^s
    ]

    caseInsensitiveLessOrEqual: aString [
	<category: '*Seaside-Squeak-Core'>
	^self asLowercase < aString asLowercase
    ]

    includesSubString: aString [
	<category: '*Seaside-Squeak-Core'>
	^(self indexOfSubCollection: aString ifAbsent: [0]) > 0
    ]

    findTokens: aStringOrCharacter [
	^aStringOrCharacter isString
	    ifTrue: [ self subStrings: aStringOrCharacter first ]
	    ifFalse: [ self subStrings: aStringOrCharacter ]
    ]

    padded: where to: size with: aCharacter [
	<category: '*Seaside-Squeak-Core'>
	| start result |
	self size = size ifTrue: [ ^self ].
	result := String new: size withAll: aCharacter.
	start := where == #left ifTrue: [ size - self size + 1 ] ifFalse: [ 1 ].
	result replaceFrom: start to: start + self size - 1 with: self startingAt: 1.
	^result
    ]

]


SmallInteger extend [
    day [
	<category: '*Seaside-Squeak-Core'>
	^(self * 86400) second
    ]

    hour [
	<category: '*Seaside-Squeak-Core'>
	^(self * 3600) second
    ]

    minute [
	<category: '*Seaside-Squeak-Core'>
	^(self * 60) second
    ]

    second [
	<category: '*Seaside-Squeak-Core'>
	^Duration fromSeconds: self
    ]
]


Object subclass: WAMimeDocument [
    | contentStream content contentType |
    WAMimeDocument class >> contentType: mimeType content: content [
	^self new contentType: mimeType contentStream: nil content: content
    ]

    WAMimeDocument class >> contentType: mimeType contentStream: stream [
	^self new contentType: mimeType contentStream: stream content: nil
    ]

    asMIMEDocument [
	^self
    ]

    asMIMEDocumentType: type [
	type seasideString = contentType seasideString ifTrue: [ ^self ].
	^self class new
	    contentType: type contentStream: contentStream content: content
    ]

    contentType: mimeType contentStream: stream content: anObject [
        contentType := mimeType.
	contentStream := stream.
	content := anObject
    ]

    contentStream [
	contentStream isNil ifTrue: [ ^content readStream ].
	^contentStream
    ]

    contentType [
	^contentType
    ]

    content [
	contentStream isNil ifFalse: [ ^contentStream contents ].
	^content
    ]
]



"#seasideString implementations."

CharacterArray extend [
    seasideString [
	<category: '*Seaside-Squeak-Core'>
	^self asString
    ]
]

Exception extend [
    seasideString [
	<category: '*Seaside-Squeak-Core'>
	^self class fullName asString
    ]
]

Object extend [
    seasideString [
	<category: '*Seaside-Squeak-Core'>
	^self displayString
    ]
]

ByteArray extend [
    seasideString [
	<category: '*Seaside-Squeak-Core'>
	^self asString
    ]
]


Object subclass: WAGNUSmalltalkPlatform [
    WAGNUSmalltalkPlatform class >> initialize [
	Smalltalk at: #SeasidePlatformSupport put: self new
    ]

    addToShutDownList: anObject [
	"Add anObject to the shutdown-list of the system. On shutdown the message #shutDown will be sent to anObject."

	<category: 'startup/shutdown'>
	SpEnvironment addImageShutdownTask: [anObject shutDown] for: anObject
    ]

    addToStartUpList: anObject [
	"Add anObject to the startup-list of the system. On startup the message #startUp will be sent to anObject."

	<category: 'startup/shutdown'>
	SpEnvironment addImageStartupTask: [anObject startUp] for: anObject
    ]

    removeFromShutDownList: anObject [
	"Add anObject to the shutdown-list of the system. On shutdown the message #shutDown will be sent to anObject."

	<category: 'startup/shutdown'>
	SpEnvironment removeShutdownActionFor: anObject
    ]

    removeFromStartUpList: anObject [
	"Add anObject to the startup-list of the system. On startup the message #startUp will be sent to anObject."

	<category: 'startup/shutdown'>
	SpEnvironment removeStartupActionFor: anObject
    ]

    asMethodReturningString: aByteArrayOrString named: aSymbol [
	"Generates the source of a method named aSymbol that returns aByteArrayOrString as a String"
	<category: 'file-library'>
	^String streamContents: [ :stream |
		stream nextPutAll: aSymbol; nextPutAll: ' [ '; nl.
		stream tab; nextPutAll: '    ^'.
		aByteArrayOrString storeLiteralOn: stream.
		stream nl; nextPutAll: ']' ]
    ]

    asMethodReturningByteArray: aByteArrayOrString named: aSymbol [
	"Generates the source of a method named aSymbol that returns aByteArrayOrString as a ByteArray"
	<category: 'file-library'>
	^String streamContents: [ :stream |
		stream nextPutAll: aSymbol; nextPutAll: ' [ '; nl.
		stream tab; nextPutAll: '    ^#['.
		aByteArrayOrString asByteArray
			do: [ :each | each printOn: stream ]
			separatedBy: [ stream space ].
		stream nextPutAll: ']'; nl; nextPutAll: ']' ]
    ]

    base64Decode: aString [
        <category: 'text processing'>
        | codeChars decoder output index nl endChars end limit padding data sz |
        codeChars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
        decoder := (0 to: 255)
                    collect: [:n | (codeChars indexOf: (n + 1) asCharacter) - 1].
        decoder replaceAll: -1 with: 0.
        output := (data := String new: aString size * 3 // 4)
                    writeStream.
        index := 1.
        nl := Character nl.
        "There is padding at the end of a base64 message if the content is not a multiple of
         3 bytes in length.  The padding is either two ='s to pad-out a trailing byte, 1 = to
         pad out a trailing pair of bytes, or no padding.  Here we count the padding.  After
         processing the message we cut-back by the amount of padding."
        sz := end := aString size.
        endChars := codeChars , (String with: $=).

        [(endChars includes: (aString at: end))
            and: [end = sz or: [(aString at: end + 1) = nl]]]
                whileFalse: [end := end - 1].
        limit := end.
        padding := 0.
        [(aString at: end) == $=] whileTrue:
                [padding := padding - 1.
                end := end - 1].
        [index <= limit] whileTrue:
                [| triple |
                triple := ((decoder at: (aString at: index) asInteger) bitShift: 18)
                            + ((decoder at: (aString at: index + 1) asInteger) bitShift: 12)
                                + ((decoder at: (aString at: index + 2) asInteger) bitShift: 6)
                                + (decoder at: (aString at: index + 3) asInteger).
                output nextPut: (Character value: (triple digitAt: 3)).
                output nextPut: (Character value: (triple digitAt: 2)).
                output nextPut: (Character value: (triple digitAt: 1)).
                index := index + 4.
                [(index > sz or: [(aString at: index) = nl]) and: [index <= limit]]
                    whileTrue: [index := index + 1]].
        padding ~= 0 ifTrue: [output skip: padding].
        ^data copyFrom: 1 to: output position
    ]

    compile: aString into: aClass classified: aSymbol [
	aClass compile: aString classified: aSymbol
    ]

    contentsOfFile: aString binary: aBoolean [
	| data |
	data := (File name: aString) contents.
	aBoolean ifTrue: [ data := data asByteArray ].
	^data
    ]

    convertToSmalltalkNewlines: aString [
	^aString
    ]

    defaultDispatcherName [
	^'seaside'
    ]

    doTransaction: aBlock [
	"for Gemstone/S compatibility
	http://gemstonesoup.wordpress.com/2007/05/10/porting-application-specific-seaside-threads-to-gemstone/
	use when modifying an object from an outside thread"
	^aBlock value
    ]

    ensureExistenceOfFolder: aString [
	"creates a folder named aString in the image directory"
	(Directory image / aString) create
    ]

    filesIn: aPathString [
	"Return a collection of absolute paths for all the files (no directories) in the directory given by aPathString
	must not include file names that start with ."
	| directory |
	directory := File name: aPathString.
	^(directory files
		reject: [ :each | each first = $. ])
		collect: [ :each | each asString ]
    ]

    localNameOf: aFilename [
	^File fullNameFor: aFilename
    ]

    mimeDocumentClass [
	^ WAMimeDocument
    ]

    mimeDocumentOfType: type from: aFilename [
	"WACachedDocument clearCache.
	(WACachedDocument fileName: 'SqueakDebug.log') asMIMEDocument.
	(WACachedDocument fileName: 'SqueakDebug.log') asMIMEDocument."

	| content mimeType |
	mimeType := type ifNil: [
		self mimeDocumentClass guessTypeFromExtension: (File extensionFor: aFilename) ].
	content := (File name: aFilename) contents.
	^self mimeDocumentClass
		contentType: mimeType
		content: content
    ]

    openDebuggerOn: anError [
	anError creator primError: anError messageText
    ]

    randomClass [
	"used by Gemstone/S traditional Randoms which cannot be persisted"
	
	^Random
    ]

    readWriteStream [
	^WriteStream on: (String new: 4096)
    ]

    reducedConflictDictionary [
	"used by Gemstone/S reduced conflict classes that can be used to avoid transaction conflicts"
	^Dictionary
    ]

    removeSelector: aSymbol from: aClass [
	aClass removeSelector: aSymbol
    ]

    semaphoreClass [
	"used by Gemstone/S traditional Semaphores which cannot be persisted"
	^Semaphore
    ]

    defaultDirectoryName [
	<category: '*Seaside-Squeak-Core'>
	^Directory working name
    ]

    platformString [
	^'GNU Smalltalk'
    ]

    versionString [
	^Smalltalk version
    ]

    vmStatisticsReportString [
	^''
    ]

    walkbackStringsFor: anError [
	| ctx strings |
	strings := OrderedCollection new.
	ctx := anError signalingContext.
	[ strings size <= 20 and: [ ctx notNil ] ] whileTrue: [
	    ctx isInternalExceptionHandlingContext
		ifFalse: [ strings add: ctx printString ].
	    ctx := ctx parentContext ].
	^strings
    ]

    weakDictionaryOfSize: aNumber [
	^WeakKeyIdentityDictionary new: aNumber
    ]

    write: aStringOrByteArray toFile: aFileNameString inFolder: aFolderString [
	"writes aStringOrByteArray to a file named aFilenameString in the folder aFolderString"
	| stream fileName |
	aFolderString / aFileNameString withWriteStreamDo: [ :stream |
	    stream nextPutAll: aStringOrByteArray ]
    ]
]

WAGNUSmalltalkPlatform initialize!
