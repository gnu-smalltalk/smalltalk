"=====================================================================
|
|   MySQL DBI driver - Connection class and related classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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



ReadStream subclass: MySQLReadStream [
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    readNullTerminatedString [
	<category: 'accessing'>
	^self upTo: self null asCharacter
    ]

    null [
	<category: 'constants'>
	^0
    ]
]



WriteStream subclass: MySQLWriteStream [
    | outputPacket |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    MySQLWriteStream class >> on: aCollection startingAt: aPosition outputPacket: op [
	<category: 'instance creation'>
	| ws |
	ws := (self on: aCollection) setWritePosition: aPosition.
	ws outputPacket: op.
	^ws
    ]

    MySQLWriteStream class >> xon: aCollection outputPacket: op [
	<category: 'instance creation'>
	| ws |
	ws := (super on: aCollection) initialize.
	ws outputPacket: op.
	^ws
    ]

    cmdConnect [
	<category: 'mysql-constants'>
	^11
    ]

    cmdCreateDatabase [
	<category: 'mysql-constants'>
	^5
    ]

    cmdDebug [
	<category: 'mysql-constants'>
	^13
    ]

    cmdDropDatabase [
	<category: 'mysql-constants'>
	^6
    ]

    cmdFieldList [
	<category: 'mysql-constants'>
	^4
    ]

    cmdInitializeDatabase [
	<category: 'mysql-constants'>
	^2
    ]

    cmdKillProcess [
	<category: 'mysql-constants'>
	^12
    ]

    cmdProcessInfo [
	<category: 'mysql-constants'>
	^10
    ]

    cmdQuery [
	<category: 'mysql-constants'>
	^3
    ]

    cmdQuit [
	<category: 'mysql-constants'>
	^1
    ]

    cmdRefresh [
	<category: 'mysql-constants'>
	^7
    ]

    cmdShutdown [
	<category: 'mysql-constants'>
	^8
    ]

    cmdSleep [
	<category: 'mysql-constants'>
	^0
    ]

    cmdStatistics [
	<category: 'mysql-constants'>
	^9
    ]

    flush [
	<category: 'accessing'>
	outputPacket flush
    ]

    nextPutAllNullTerminated: aCollection2 [
	<category: 'accessing'>
	self nextPutAll: aCollection2.
	self nextPut: self null asCharacter
    ]

    nextPutCommand: aCommand [
	<category: 'accessing'>
	self
	    nextPut: (Character value: (self perform: aCommand));
	    nextPut: self null asCharacter
    ]

    nextPutCommand: aCommand message: aString [
	<category: 'accessing'>
	self
	    nextPut: (Character value: (self perform: aCommand));
	    nextPutAllNullTerminated: aString
    ]

    outputPacket [
	<category: 'accessing'>
	^outputPacket
    ]

    outputPacket: p [
	<category: 'accessing'>
	outputPacket := p
    ]

    setWritePosition: aPosition [
	"aPosition timesRepeat: [ self nextPut: 0 asCharacter]"

	<category: 'accessing'>
	ptr := aPosition + 1
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    null [
	<category: 'constants'>
	^0
    ]
]



Object subclass: MySQLPacket [
    | packetNumber size buffer stream |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    MySQLPacket class >> defaultBufferSize [
	<category: 'constants'>
	^8192
    ]

    MySQLPacket class >> headerSize [
	<category: 'constants'>
	^4
    ]

    MySQLPacket class >> packetNumberOffset [
	<category: 'constants'>
	^4
    ]

    MySQLPacket class >> packetNumberSize [
	<category: 'constants'>
	^1
    ]

    MySQLPacket class >> izeOffset [
	<category: 'constants'>
	^1
    ]

    MySQLPacket class >> sizeSize [
	<category: 'constants'>
	^3
    ]

    MySQLPacket class >> on: aStream [
	<category: 'instance creation'>
	^(self new)
	    stream: aStream;
	    initialize
    ]

    packetNumber [
	<category: 'accessing'>
	^packetNumber
    ]

    packetNumber: anInteger [
	<category: 'accessing'>
	packetNumber := anInteger
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: anObject [
	<category: 'accessing'>
	size := anObject
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: anObject [
	<category: 'accessing'>
	stream := anObject
    ]
]



MySQLPacket subclass: MySQLInputPacket [
    | readStream |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    initialize [
	<category: 'initialize-release'>
	self stream atEnd 
	    ifTrue: 
		[size := packetNumber := 0.
		buffer := #[].
		^self].
	size := self readSize.
	packetNumber := self readPacketNumber.
	buffer := self readBuffer.
	readStream := MySQLReadStream on: buffer
    ]

    isStatus: anInteger onError: aSymbol [
	<category: 'reading'>
	^(self readStatusOnError: aSymbol) = anInteger
    ]

    checkForStatus: anInteger onError: aSymbol [
	<category: 'reading'>
	(self readStatusOnError: aSymbol) = anInteger 
	    ifFalse: [self handleError: aSymbol]
    ]

    checkStatusOnError: aSymbol [
	<category: 'reading'>
	self checkForStatus: 0 onError: aSymbol
    ]

    handleError: aSymbol [
	<category: 'reading'>
	| ba int1 int2 |
	ba := (readStream next: 2) asByteArray.
	int1 := ba basicAt: 1.
	int2 := ba basicAt: 2.
	int2 := int2 bitShift: 8.
	MySQLConnection throwException: aSymbol
	    message: (int1 + int2) printString , ' ' 
		    , readStream readNullTerminatedString
	"MySQLConnection throwException: aSymbol
	 message: (readStream next: 2) asByteArray asInteger printString , ' '
	 , readStream readNullTerminatedString"
    ]

    readBuffer [
	<category: 'reading'>
	^self stream next: self size
    ]

    readPacketNumber [
	<category: 'reading'>
	| ba o int1 |
	o := self stream next: self class packetNumberSize.
	ba := o asByteArray.
	int1 := ba basicAt: 1.
	^int1

	"^(self stream next: self class packetNumberSize) asByteArray asInteger"
    ]

    readSize [
	<category: 'reading'>
	| ba o int1 int2 int3 |
	o := self stream next: self class sizeSize.
	"o := String streamContents: [:aStream | 1 to: self class sizeSize
	 do: [:i | aStream nextPut: self stream next]]."
	ba := o asByteArray.
	int1 := ba basicAt: 1.
	int2 := ba basicAt: 2.
	int2 := int2 bitShift: 8.
	int3 := ba basicAt: 3.
	int3 := int3 bitShift: 16.
	^int1 + int2 + int3
	"^(self stream next: self class sizeSize) asByteArray asInteger"
    ]

    readStatusOnError: aSymbol [
	<category: 'reading'>
	| status |
	status := readStream next asInteger.
	status = 255 ifFalse: [^status].
	self handleError: aSymbol
    ]

    readStream [
	<category: 'accessing'>
	^readStream
    ]
]



MySQLPacket subclass: MySQLOutputPacket [
    | writeStream |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    writeStream [
	<category: 'accessing'>
	^writeStream
    ]

    flush [
	<category: 'actions'>
	| aString ba s bytesSend |
	aString := self writeStream contents.
	self size: aString size - self class headerSize.
	ba := MySQLConnection integerAsByteArray: self size
		    length: self class sizeSize.
	s := MySQLConnection byteArrayAsByteString: ba.
	aString 
	    replaceFrom: 1
	    to: self class sizeSize
	    with: s
	    startingAt: 1.
	aString at: self class sizeSize + 1
	    put: (Character value: self packetNumber).
	(self stream)
	    nextPutAll: aString;
	    flush
    ]

    initialize [
	<category: 'initialize-release'>
	packetNumber := 0.
	buffer := String new: self class defaultBufferSize.
	writeStream := MySQLWriteStream 
		    on: buffer
		    startingAt: self class headerSize
		    outputPacket: self

	"This is a bit of a hack...I should utilize events instead"
    ]
]



Connection subclass: MySQLConnection [
    | socket serverInfo database responsePacket |
    
    <comment: nil>
    <category: 'Mysql-Driver'>

    MySQLConnection class >> throwException: aSymbol [
	<category: 'errors'>
	self throwException: aSymbol message: ''
    ]

    MySQLConnection class >> throwException: aSymbol message: aString [
	<category: 'errors'>
	self 
	    error: (self errorTable at: aSymbol ifAbsent: ['Unknown']) , ': ' , aString
    ]

    MySQLConnection class >> errorTable [
	<category: 'errors'>
	ErrorTable isNil 
	    ifTrue: 
		[ErrorTable := IdentityDictionary new.
		1 to: self errorTableMap size
		    by: 2
		    do: 
			[:i | 
			ErrorTable at: (self errorTableMap at: i)
			    put: (self errorTableMap at: i + 1)]].
	^ErrorTable
    ]

    MySQLConnection class >> errorTableMap [
	<category: 'errors'>
	^#(#protocol 'Invalid Protocol' #authentication 'Access denied' #setDatabase 'Could not set the database' #invalidQuery 'Invalid query')
    ]

    MySQLConnection class >> driverName [
	<category: 'instance creation'>
	^'MySQL'
    ]

    MySQLConnection class >> paramConnect: aParams user: aUserName password: aPassword [
	<category: 'instance creation'>
	| database connection host port |
	database := aParams at: 'dbname' ifAbsent: [nil].

	(aParams includesKey: 'mysql_socket')
	    ifTrue: [
		host := Sockets.UnixAddress uniqueInstance.
		port := aParams at: 'mysql_socket' ]
	    ifFalse: [
		host := aParams at: 'host' ifAbsent: ['127.0.0.1'].
		port := (aParams at: 'port' ifAbsent: [3306]) asInteger ].

	connection := self new.
	connection connectTo: host port: port.
	connection login: aUserName password: aPassword.
	database isNil ifFalse: [connection database: database].
	^connection
    ]

    MySQLConnection class >> byteArrayAsInteger: ba [
	<category: 'misc'>
	^self 
	    byteArrayAsInteger: ba
	    from: 1
	    for: ba size
    ]

    MySQLConnection class >> byteArrayAsInteger: ba from: anOffset for: aLength [
	<category: 'misc'>
	| shiftAmount anInteger |
	shiftAmount := 0.
	anInteger := 0.
	anOffset to: aLength
	    do: 
		[:index | 
		anInteger := anInteger bitOr: ((ba at: index) bitShift: shiftAmount).
		shiftAmount := shiftAmount + 8].
	^anInteger
    ]

    MySQLConnection class >> integerAsByteArray: int length: aLength [
	<category: 'misc'>
	| aByteArray shiftAmount mask |
	aByteArray := ByteArray new: aLength.
	shiftAmount := 0.
	mask := 255.
	1 to: aLength
	    do: 
		[:index | 
		aByteArray at: index put: (mask bitAnd: (int bitShift: shiftAmount)).
		shiftAmount := shiftAmount - 8].
	^aByteArray
    ]

    MySQLConnection class >> byteArrayAsByteString: ba [
	<category: 'misc'>
	| size s |
	size := ba size.
	s := String new: size.
	1 to: size
	    do: [:index | s at: index put: (Character value: (ba at: index))].
	^s
    ]

    beginTransaction [
	<category: 'querying'>
	^self do: 'START TRANSACTION'
    ]

    commitTransaction [
	<category: 'querying'>
	^self do: 'COMMIT'
    ]

    rollbackTransaction [
	<category: 'querying'>
	^self do: 'ROLLBACK'
    ]

    database [
	<category: 'querying'>
	^database
    ]

    do: aSQLQuery [
	<category: 'querying'>
	^(self prepare: aSQLQuery) execute
    ]

    select: aSQLQuery [
	<category: 'querying'>
	^(self prepare: aSQLQuery) execute
    ]

    prepare: aQuery [
	<category: 'querying'>
	^(MySQLStatement on: self) prepare: aQuery
    ]

    finalize [
	<category: 'closing'>
	self close
    ]

    close [
	<category: 'closing'>
	self
	    removeToBeFinalized;
	    closeRequest;
	    closeSocket
    ]

    closeRequest [
	<category: 'closing'>
	(self requestPacket writeStream)
	    nextPutCommand: #cmdQuit;
	    flush
    ]

    closeSocket [
	<category: 'closing'>
	socket isNil ifFalse: [socket close].
	socket := nil
    ]

    connectTo: host port: port [
	<category: 'initialize-release'>
	| messageText |
	socket := Sockets.Socket remote: host port: port.
	self addToBeFinalized.
	socket isNil ifTrue: [^self error: messageText].
	serverInfo := MySQLServerInfo new.
	serverInfo readFrom: self responsePacket
    ]

    database: aString [
	<category: 'initialize-release'>
	(self requestPacket writeStream)
	    nextPutCommand: #cmdInitializeDatabase message: aString;
	    flush.
	self responsePacket checkStatusOnError: #setDatabase.
	database := aString
    ]

    oldProtocolHashes: password [
	<category: 'initialize-release'>
	password isEmpty ifTrue: [^''].
	^{self hash2: password seed: serverInfo hashSeed}
    ]

    newProtocolHashes: password [
	<category: 'initialize-release'>
	password isEmpty ifTrue: [^String new: 1].
	^
	{self hashSHA1: password seed: serverInfo hashSeed.
	self hash2: password seed: serverInfo hashSeed}
    ]

    login: user password: password [
	<category: 'initialize-release'>
	| replyStream hashes userSent longPassword |
	replyStream := self replyPacket writeStream.
	serverInfo hashSeed size = 8 
	    ifTrue: 
		[hashes := self oldProtocolHashes: password.
		replyStream
		    nextPutAll: (self class integerAsByteArray: 1 length: 2) asByteString;
		    nextPutAll: (self class integerAsByteArray: 65536 length: 3) asByteString;
		    nextPutAllNullTerminated: user;
		    nextPutAllNullTerminated: hashes first;
		    flush]
	    ifFalse: 
		[hashes := self newProtocolHashes: password.
		replyStream
		    nextPutAll: (self class integerAsByteArray: 41477 length: 4) asByteString;
		    nextPutAll: (self class integerAsByteArray: 65536 length: 4) asByteString;
		    nextPut: 8 asCharacter;
		    next: 23 put: 0 asCharacter;
		    nextPutAllNullTerminated: user;
		    nextPut: hashes first size asCharacter;
		    nextPutAll: hashes first;
		    flush.
		(self responsePacket isStatus: 254 onError: #authenticate) 
		    ifTrue: 
			[replyStream := self replyPacket writeStream.
			replyStream
			    nextPutAll: hashes second;
			    flush]]
    ]

    hash: aString seed: aSeed for: hashMethod [
	<category: 'hashing'>
	^self class 
	    perform: hashMethod
	    with: aString
	    with: aSeed
    ]

    replyPacket [
	<category: 'accessing'>
	^(MySQLOutputPacket on: socket) 
	    packetNumber: responsePacket packetNumber + 1
    ]

    requestPacket [
	<category: 'accessing'>
	^MySQLOutputPacket on: socket
    ]

    responsePacket [
	<category: 'accessing'>
	^responsePacket := MySQLInputPacket on: socket
    ]

    hashSHA1: aString seed: aSeed [
	"This algorithm is for MySQL 4.1+."

	<category: 'hashing'>
	"Compute hash1 = SHA1(password), then hash2 = SHA1(hash1). The server
	 already knows this, as that is what is held in its password table
	 (preceded with a *)."

	| hashedString hashedStringSeeded result |
	hashedString := SHA1 digestOf: aString.
	hashedStringSeeded := SHA1 digestOf: hashedString.

	"Append hash2 to the salt sent by the server and hash that."
	hashedStringSeeded := SHA1 digestOf: aSeed , hashedStringSeeded.

	"Finally, XOR the result with SHA1(password).  The server takes this,
	 computes SHA1(salt.`SHA1 stored in DB`), uses the latter result to
	 undo the XOR, computes again SHA1, and compares that with the SHA1
	 stored in the DB."
	result := String new: 20.
	1 to: 20
	    do: 
		[:i | 
		result at: i
		    put: (Character 
			    value: ((hashedString at: i) bitXor: (hashedStringSeeded at: i)))].
	^result
    ]

    hash2: aString seed: longSeed [
	"This algorithm is for MySQL 3.22+."

	<category: 'hashing'>
	"Reserve a final byte for NULL termination"

	| hashedString maxValue result num1 num2 num3 aSeed |
	aSeed := longSeed copyFrom: 1 to: 8.
	hashedString := String new: aSeed size.
	result := self randomInit2: aString seed: aSeed.
	maxValue := 1073741823.
	num1 := result at: 1.
	num2 := result at: 2.
	1 to: hashedString size
	    do: 
		[:index | 
		num1 := (num1 * 3 + num2) \\ maxValue.
		num2 := (num1 + num2 + 33) \\ maxValue.
		num3 := (num1 / maxValue * 31) truncated + 64.
		hashedString at: index put: num3 asCharacter].
	num1 := (num1 * 3 + num2) \\ maxValue.
	num2 := (num1 + num2 + 33) \\ maxValue.
	num3 := (num1 / maxValue * 31) truncated.
	hashedString keysAndValuesDo: 
		[:index :character | 
		hashedString at: index put: (character asInteger bitXor: num3) asCharacter].
	^hashedString
    ]

    hash: aString [
	"Hash algorithm taken from mysql in order to send password to the server"

	<category: 'hashing'>
	| num1 num2 num3 |
	num1 := 1345345333.
	num2 := 305419889.
	num3 := 7.
	aString do: 
		[:character | 
		(character = Character space or: [character = Character tab]) 
		    ifFalse: 
			[| charValue |
			charValue := character asInteger.
			num1 := num1 
				    bitXor: ((num1 bitAnd: 63) + num3) * charValue + (num1 bitShift: 8).
			num2 := num2 + ((num2 bitShift: 8) bitXor: num1).
			num3 := num3 + charValue]].
	^Array with: (num1 bitAnd: 2147483647) with: (num2 bitAnd: 2147483647)
    ]

    randomInit2: aString seed: aSeed [
	<category: 'hashing'>
	| result array1 array2 |
	result := Array new: 2.
	array1 := self hash: aString.
	array2 := self hash: aSeed.
	result at: 1 put: ((array1 at: 1) bitXor: (array2 at: 1)) \\ 1073741823.
	result at: 2 put: ((array1 at: 2) bitXor: (array2 at: 2)) \\ 1073741823.
	^result
    ]

    primTableAt: aString ifAbsent: aBlock [
	| table |
	[
	    table := (MySQLTable name: aString connection: self)
		columnsArray;
		yourself ]
	    on: Error
	    do: [ :ex | ex return ].

	table isNil ifTrue: [ ^aBlock value ].
	^table
    ]
]



Object subclass: MySQLServerInfo [
    | protocol serverThread serverVersion charset status hashSeed options |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    charset [
	<category: 'accessing'>
	^charset
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    hashSeed [
	<category: 'accessing'>
	^hashSeed
    ]

    options [
	<category: 'accessing'>
	^options
    ]

    protocol [
	<category: 'accessing'>
	^protocol
    ]

    serverThread [
	<category: 'accessing'>
	^serverThread
    ]

    readFrom: aResponsePacket [
	<category: 'reading'>
	self
	    readProtocolFrom: aResponsePacket;
	    readServerVersionFrom: aResponsePacket;
	    readServerThreadFrom: aResponsePacket;
	    readHashSeedFrom: aResponsePacket;
	    readOptionsFrom: aResponsePacket.
	aResponsePacket readStream atEnd 
	    ifFalse: 
		[self
		    readCharsetFrom: aResponsePacket;
		    readStatusFrom: aResponsePacket;
		    readMoreSeedFrom: aResponsePacket]
    ]

    readStatusFrom: aResponsePacket [
	<category: 'reading'>
	status := (aResponsePacket readStream next: 2) asByteArray asInteger.
	aResponsePacket readStream next: 13
    ]

    readCharsetFrom: aResponsePacket [
	<category: 'reading'>
	charset := aResponsePacket readStream next value
    ]

    readHashSeedFrom: aResponsePacket [
	<category: 'reading'>
	hashSeed := aResponsePacket readStream readNullTerminatedString
    ]

    readMoreSeedFrom: aResponsePacket [
	<category: 'reading'>
	hashSeed := hashSeed , aResponsePacket readStream readNullTerminatedString
    ]

    readOptionsFrom: aResponsePacket [
	<category: 'reading'>
	options := (aResponsePacket readStream next: 2) asByteArray asInteger
    ]

    readProtocolFrom: aResponsePacket [
	<category: 'reading'>
	protocol := aResponsePacket readStatusOnError: #protocol.
	protocol = 10 ifFalse: [MySQLConnection error: #protocol]
    ]

    readServerThreadFrom: aResponsePacket [
	<category: 'reading'>
	serverThread := (aResponsePacket readStream next: 4) asByteArray asInteger
    ]

    readServerVersionFrom: aResponsePacket [
	<category: 'reading'>
	serverVersion := aResponsePacket readStream readNullTerminatedString
    ]
]

