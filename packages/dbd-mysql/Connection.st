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
| This file is part of GNU Smalltalk.
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


ReadStream subclass: #MySQLReadStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


WriteStream subclass: #MySQLWriteStream
	instanceVariableNames: 'outputPacket '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #MySQLPacket
	instanceVariableNames: 'packetNumber size buffer stream '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


MySQLPacket subclass: #MySQLInputPacket
	instanceVariableNames: 'readStream '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


MySQLPacket subclass: #MySQLOutputPacket
	instanceVariableNames: 'writeStream '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Connection subclass: #MySQLConnection
	instanceVariableNames: 'socket serverInfo database responsePacket '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #MySQLServerInfo
	instanceVariableNames: 'protocol serverThread serverVersion charset status hashSeed options '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!

!MySQLReadStream methodsFor: 'accessing'!

readNullTerminatedString
	^self upTo: self null asCharacter! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MySQLReadStream class
	instanceVariableNames: ''!


!MySQLReadStream methodsFor: 'constants'!

null
	^0! !

!MySQLWriteStream methodsFor: 'mysql-constants'!

cmdConnect
	^11!

cmdCreateDatabase
	^5!

cmdDebug
	^13!

cmdDropDatabase
	^6!

cmdFieldList
	^4!

cmdInitializeDatabase
	^2!

cmdKillProcess
	^12!

cmdProcessInfo
	^10!

cmdQuery
	^3!

cmdQuit
	^1!

cmdRefresh
	^7!

cmdShutdown
	^8!

cmdSleep
	^0!

cmdStatistics
	^9! !

!MySQLWriteStream methodsFor: 'accessing'!

flush
	outputPacket flush!

nextPutAllNullTerminated: aCollection2 
	self nextPutAll: aCollection2.
	self nextPut: self null asCharacter!

nextPutCommand: aCommand
	self
		nextPut: (Character value: (self perform: aCommand));
		nextPut: self null asCharacter!

nextPutCommand: aCommand message: aString
	self
		nextPut: (Character value: (self perform: aCommand));
		nextPutAllNullTerminated: aString!

outputPacket
	^outputPacket!

outputPacket: p
	outputPacket := p!

setWritePosition: aPosition 
    "aPosition timesRepeat: [ self nextPut: 0 asCharacter]"
    ptr := aPosition + 1! !

!MySQLWriteStream methodsFor: 'initialize'!

initialize! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MySQLWriteStream class
	instanceVariableNames: ''!

!MySQLWriteStream methodsFor: 'constants'!
null
	^0! !


!MySQLWriteStream class methodsFor: 'instance creation'!
on: aCollection startingAt: aPosition 
outputPacket: op
	| ws |
	ws := (self on: aCollection)
		setWritePosition: aPosition.
	ws outputPacket: op.
	^ws! !

!MySQLWriteStream class methodsFor: 'instance creation'!
xon: aCollection outputPacket: op
	| ws |
	ws := (super on: aCollection) initialize.
	ws outputPacket: op.
	^ws! !

!MySQLConnection class methodsFor: 'errors'!

throwException: aSymbol 
	self throwException: aSymbol message: ''!

throwException: aSymbol message: aString 
	self 
		error: (self errorTable at: aSymbol ifAbsent: ['Unknown']) , ': ' , aString!

errorTable
	ErrorTable isNil ifTrue: [
	    ErrorTable := IdentityDictionary new.
	    1 to: self errorTableMap size by: 2 do: [ :i |
	        ErrorTable
		    at: (self errorTableMap at: i)
	            put: (self errorTableMap at: i + 1) ] ].

	^ErrorTable!

errorTableMap
	^#(#protocol 'Invalid Protocol'
	    #authentication 'Access denied'
	    #setDatabase   'Could not set the database'
	    #invalidQuery 'Invalid query')! !

!MySQLConnection class methodsFor: 'instance creation'!

driverName
    ^'MySQL'!

paramConnect: aParams user: aUserName password: aPassword
    | database connection host port |
    database := aParams at: 'dbname' ifAbsent: [ nil ].
    host := aParams at: 'host' ifAbsent: [ 'localhost' ].
    port := (aParams at: 'port' ifAbsent: [ 3306 ]) asInteger.

    connection := self new.
    connection connectTo: host port: port.
    connection login: aUserName password: aPassword.
    database isNil ifFalse: [ connection database: database ].
    ^connection! !

!MySQLConnection methodsFor: 'querying'!

beginTransaction
	^self do: 'START TRANSACTION'!

commitTransaction
	^self do: 'COMMIT'!

rollbackTransaction
	^self do: 'ROLLBACK'!

database
	^database!

do: aSQLQuery
	^(self prepare: aSQLQuery) execute!

select: aSQLQuery
	^(self prepare: aSQLQuery) execute!

prepare: aQuery
	^(MySQLStatement on: self) prepare: aQuery!

!MySQLConnection methodsFor: 'closing'!

finalize
	self close!

close
	self
		removeToBeFinalized;
		closeRequest;
		closeSocket!

closeRequest
	(self requestPacket writeStream)
		nextPutCommand: #cmdQuit;
		flush!

closeSocket
	socket isNil ifFalse: [socket close].
	socket := nil! !

!MySQLConnection methodsFor: 'initialize-release'!

connectTo: host port: port
    | messageText |
    socket := TCP.Socket remote: host port: port.
    self addToBeFinalized.

    socket isNil ifTrue: [ ^self error: messageText].	
    serverInfo := MySQLServerInfo new.
    serverInfo readFrom: self responsePacket
!

database: aString
    (self requestPacket writeStream)
	nextPutCommand: #cmdInitializeDatabase message: aString;
	flush.
    self responsePacket checkStatusOnError: #setDatabase.
    database := aString!

oldProtocolHashes: password
    password isEmpty ifTrue: [ ^'' ].
    ^{ self hash2: password seed: serverInfo hashSeed }!

newProtocolHashes: password
    password isEmpty ifTrue: [ ^String new: 1 ].
    ^{ self hashSHA1: password seed: serverInfo hashSeed.
       self hash2: password seed: serverInfo hashSeed }!

login: user password: password
    | replyStream hashes userSent longPassword |
    replyStream := self replyPacket writeStream.
    serverInfo hashSeed size = 8
	ifTrue: [
	    hashes := self oldProtocolHashes: password.
	    replyStream
	        nextPutAll: (self class integerAsByteArray: 1 length: 2) asByteString;
	        nextPutAll: (self class integerAsByteArray: 65536 length: 3) asByteString;
	        nextPutAllNullTerminated: user;
		nextPutAllNullTerminated: hashes first;
		flush ]
	ifFalse: [
	    hashes := self newProtocolHashes: password.
	    replyStream
	        nextPutAll: (self class integerAsByteArray: 41477 length: 4) asByteString;
	        nextPutAll: (self class integerAsByteArray: 65536 length: 4) asByteString;
	        nextPut: 8 asCharacter;
	        next: 23 put: 0 asCharacter;
	        nextPutAllNullTerminated: user;
		nextPut: hashes first size asCharacter;
		nextPutAll: hashes first;
        	flush.
   
	    (self responsePacket isStatus: 254 onError: #authenticate) ifTrue: [
		replyStream := self replyPacket writeStream.
		replyStream nextPutAll: hashes second; flush ] ]! !

!MySQLConnection methodsFor: 'hashing'!

hash: aString seed: aSeed for: hashMethod 
	^self class 
		perform: hashMethod
		with: aString
		with: aSeed! !

!MySQLConnection methodsFor: 'accessing'!

replyPacket
	^(MySQLOutputPacket on: socket) 
		packetNumber: responsePacket packetNumber + 1!

requestPacket
	^MySQLOutputPacket on: socket!

responsePacket
	^responsePacket := MySQLInputPacket on: socket! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MySQLConnection class
	instanceVariableNames: ''!


!MySQLConnection methodsFor: 'hashing'!

hashSHA1: aString seed: aSeed 
	"This algorithm is for MySQL 4.1+."

	| hashedString hashedStringSeeded result |
	"Compute hash1 = SHA1(password), then hash2 = SHA1(hash1). The server
	 already knows this, as that is what is held in its password table
	 (preceded with a *)."

	hashedString := SHA1 digestOf: aString.
	hashedStringSeeded := SHA1 digestOf: hashedString.

	"Append hash2 to the salt sent by the server and hash that."
	hashedStringSeeded := SHA1 digestOf: aSeed, hashedStringSeeded.

	"Finally, XOR the result with SHA1(password).  The server takes this,
	 computes SHA1(salt.`SHA1 stored in DB`), uses the latter result to
	 undo the XOR, computes again SHA1, and compares that with the SHA1
	 stored in the DB."

	result := String new: 20.
	1 to: 20 do: [ :i |
	    result at: i put: (Character value:
		((hashedString at: i) bitXor: (hashedStringSeeded at: i))) ].
	^result!

hash2: aString seed: longSeed 
	"This algorithm is for MySQL 3.22+."

	| hashedString maxValue result num1 num2 num3 aSeed |
	"Reserve a final byte for NULL termination"
	aSeed := longSeed copyFrom: 1 to: 8.
	hashedString := String new: aSeed size.
	result := self randomInit2: aString seed: aSeed.
	maxValue := 16r3FFFFFFF.
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
	hashedString keysAndValuesDo: [:index :character | 
		hashedString
			at: index
			put: (character asInteger bitXor: num3) asCharacter].
	^hashedString!

hash: aString 
	"Hash algorithm taken from mysql in order to send password to the server"

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
	^Array with: (num1 bitAnd: 2147483647) with: (num2 bitAnd: 2147483647)!

randomInit2: aString seed: aSeed 
	| result array1 array2 |
	result := Array new: 2.
	array1 := self hash: aString.
	array2 := self hash: aSeed.
	result at: 1 put: ((array1 at: 1) bitXor: (array2 at: 1)) \\ 16r3FFFFFFF.
	result at: 2 put: ((array1 at: 2) bitXor: (array2 at: 2)) \\ 16r3FFFFFFF.
	^result! !

!MySQLConnection class methodsFor: 'misc'!

byteArrayAsInteger: ba
    ^self byteArrayAsInteger: ba from: 1 for: ba size!

byteArrayAsInteger: ba from: anOffset for: aLength 
    | shiftAmount anInteger |
	
    shiftAmount := 0.	
    anInteger := 0.
    anOffset to: aLength
	     do: 
	     [:index | 
		 anInteger := anInteger bitOr: ((ba at: index) bitShift: shiftAmount).
		 shiftAmount := shiftAmount + 8].
    ^anInteger!

integerAsByteArray: int length: aLength 

    | aByteArray shiftAmount mask |
    aByteArray := ByteArray new: aLength.
    shiftAmount := 0.
    mask := 16rFF.
    1 to: aLength
      do: 
      [:index | 
	  aByteArray at: index put: (mask bitAnd: (int bitShift: shiftAmount)).
	  shiftAmount := shiftAmount - 8].
    ^aByteArray!

byteArrayAsByteString: ba
    | size s |
    size := ba size.
    s := String new: size.
    1 to: size do: [:index |
	s at: index put: (Character value: (ba at: index)).
	].
    ^s! !

!MySQLPacket methodsFor: 'accessing'!

packetNumber
	^packetNumber!

packetNumber: anInteger
	packetNumber := anInteger!

size
	^size!

size: anObject
	size := anObject!

stream
	^stream!

stream: anObject
	stream := anObject! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MySQLPacket class
	instanceVariableNames: ''!


!MySQLPacket class methodsFor: 'constants'!

defaultBufferSize
	^8192!

headerSize
	^4!

packetNumberOffset
	^4!

packetNumberSize
	^1!

izeOffset
	^1!

sizeSize
	^3! !

!MySQLPacket class methodsFor: 'instance creation'!

on: aStream 
	^(self new)
		stream: aStream;
		initialize! !

!MySQLInputPacket methodsFor: 'initialize-release'!

initialize
	self stream atEnd
		ifTrue: [ size := packetNumber := 0. buffer := #[]. ^self ].
	size := self readSize.
	packetNumber := self readPacketNumber.
	buffer := self readBuffer.
	readStream := MySQLReadStream on: buffer.! !

!MySQLInputPacket methodsFor: 'reading'!

isStatus: anInteger onError: aSymbol
	^(self readStatusOnError: aSymbol) = anInteger!

checkForStatus: anInteger onError: aSymbol
	(self readStatusOnError: aSymbol) = anInteger ifFalse: [self handleError: aSymbol]!

checkStatusOnError: aSymbol 
	self checkForStatus: 0 onError: aSymbol!

handleError: aSymbol 
	| ba int1 int2 |
	ba := (readStream next: 2) asByteArray.
	int1 := ba basicAt: 1.
	int2 := ba basicAt: 2.
	int2 := int2 bitShift: 8.

	MySQLConnection throwException: aSymbol
		message: (int1 + int2) printString, ' ', readStream readNullTerminatedString
"	MySQLConnection throwException: aSymbol
		message: (readStream next: 2) asByteArray asInteger printString , ' ' 
				, readStream readNullTerminatedString"!

readBuffer
	^self stream next: self size!

readPacketNumber
	| ba o int1 |
	o := (self stream next: self class packetNumberSize).
	ba := o asByteArray.
	int1 := ba basicAt: 1.
	^int1.

"	^(self stream next: self class packetNumberSize) asByteArray asInteger"!

readSize
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
	^int1 + int2 + int3.
"	^(self stream next: self class sizeSize) asByteArray asInteger
"
!

readStatusOnError: aSymbol 
	| status |
	status := readStream next asInteger.
	status = 255 ifFalse: [^status].
	self handleError: aSymbol! !

!MySQLInputPacket methodsFor: 'accessing'!

readStream
	^readStream! !

!MySQLOutputPacket methodsFor: 'accessing'!

writeStream
	^writeStream! !

!MySQLOutputPacket methodsFor: 'actions'!

flush

	| aString ba s bytesSend |
	aString := self writeStream contents.
	self size: aString size - self class headerSize.
	ba := MySQLConnection integerAsByteArray: self size length: self class sizeSize.
	s := MySQLConnection byteArrayAsByteString: ba.
	aString replaceFrom: 1 to: self class sizeSize with: s startingAt: 1.

	aString at: self class sizeSize + 1 put: (Character value: self packetNumber).
	(self stream) nextPutAll: aString; flush
! !


!MySQLOutputPacket methodsFor: 'initialize-release'!

initialize
	packetNumber := 0.
	buffer := String new: self class defaultBufferSize.
	writeStream := MySQLWriteStream
		on: buffer
		startingAt: (self class headerSize)
		outputPacket: self.

	"This is a bit of a hack...I should utilize events instead"
! !	


!MySQLServerInfo methodsFor: 'accessing'!

charset
	^charset!

status
	^status!

hashSeed
	^hashSeed!

options
	^options!

protocol
	^protocol!

serverThread
	^serverThread! !

!MySQLServerInfo methodsFor: 'reading'!

readFrom: aResponsePacket
	self
		readProtocolFrom: aResponsePacket;
		readServerVersionFrom: aResponsePacket;
		readServerThreadFrom: aResponsePacket;
		readHashSeedFrom: aResponsePacket;
		readOptionsFrom: aResponsePacket.
	aResponsePacket readStream atEnd ifFalse: [
		self
			readCharsetFrom: aResponsePacket;
			readStatusFrom: aResponsePacket;
			readMoreSeedFrom: aResponsePacket ]!

readStatusFrom: aResponsePacket
	status := (aResponsePacket readStream next: 2) asByteArray asInteger.
	aResponsePacket readStream next: 13!

readCharsetFrom: aResponsePacket
	charset := aResponsePacket readStream next value!

readHashSeedFrom: aResponsePacket
	hashSeed := aResponsePacket readStream readNullTerminatedString!

readMoreSeedFrom: aResponsePacket
	hashSeed := hashSeed, aResponsePacket readStream readNullTerminatedString!

readOptionsFrom: aResponsePacket 
	options := (aResponsePacket readStream next: 2) asByteArray asInteger!

readProtocolFrom: aResponsePacket 
	protocol := (aResponsePacket readStatusOnError: #protocol).
	protocol = 10 ifFalse: [MySQLConnection error: #protocol]!

readServerThreadFrom: aResponsePacket
	serverThread := (aResponsePacket readStream next: 4) asByteArray asInteger!

readServerVersionFrom: aResponsePacket 
	serverVersion := aResponsePacket readStream readNullTerminatedString! !

