"=====================================================================
|
|   Just a Database Manager - MySQL driver
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored by Paolo Bonzini
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

ReadStream subclass: #JdmReadStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


WriteStream subclass: #JdmWriteStream
	instanceVariableNames: 'outputPacket '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmPacket
	instanceVariableNames: 'packetNumber size buffer stream '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


JdmPacket subclass: #JdmInputPacket
	instanceVariableNames: 'readStream '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


JdmPacket subclass: #JdmOutputPacket
	instanceVariableNames: 'writeStream '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmMysqlCommand
	instanceVariableNames: 'command message '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Jdm.JdmConnection subclass: #JdmConnection
	instanceVariableNames: 'socket readStream writeStream hashesByProtocol responsePacket clientCapabilities '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Jdm.JdmServerInfo subclass: #JdmServerInfo
	instanceVariableNames: 'protocol serverThread hashSeed options '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Jdm.JdmServerVersion subclass: #JdmServerVersion
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmDateTime
	instanceVariableNames: 'date time '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmTimestampReader
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!

Object subclass: #JdmTimestampWriter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!

Jdm.JdmColumn subclass: #JdmColumn
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Object subclass: #JdmRow
	instanceVariableNames: 'numColumns values isEmpty '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


Jdm.JdmFieldConverter subclass: #JdmFieldConverter
	instanceVariableNames: 'types converterSelectors '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver'!


!JdmReadStream methodsFor: 'accessing'!

readNullTerminatedString
	^self upTo: self class null asCharacter! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmReadStream class
	instanceVariableNames: ''!


!JdmReadStream class methodsFor: 'constants'!

null
	^0! !

!JdmWriteStream methodsFor: 'accessing'!

flush
	outputPacket flush!

nextPutAllNullTerminated: aCollection2 
	self nextPutAll: aCollection2.
	self nextPut: self class null asCharacter!

nextPutCommand: aCommand 
	self
		nextPut: aCommand command asCharacter;
		nextPutAllNullTerminated: aCommand message!

outputPacket
	^outputPacket!

outputPacket: p
	outputPacket := p!

setWritePosition: aPosition 
    "aPosition timesRepeat: [ self nextPut: 0 asCharacter]"
    ptr := aPosition + 1! !

!JdmWriteStream methodsFor: 'initialize'!

initialize! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmWriteStream class
	instanceVariableNames: ''!

!JdmWriteStream class methodsFor: 'constants'!
null
	^0! !


!JdmWriteStream class methodsFor: 'instance creation'!
on: aCollection startingAt: aPosition 
outputPacket: op
	| ws |
	ws := (self on: aCollection)
		setWritePosition: aPosition.
	ws outputPacket: op.
	^ws! !

!JdmWriteStream class methodsFor: 'instance creation'!
xon: aCollection outputPacket: op
	| ws |
	ws := (super on: aCollection) initialize.
	ws outputPacket: op.
	^ws! !

!JdmErrorTable methodsFor: 'actions'!

throwException: aSymbol 
	self throwException: aSymbol message: ''!

throwException: aSymbol message: aString 
	self 
		error: (self errors at: aSymbol ifAbsent: ['Unknown']) , ': ' , aString! !

!JdmErrorTable methodsFor: 'initialize-release'!

initialize
	errors := JdmConnection dictionaryClass: IdentityDictionary
				from: self class errorTableMap! !

!JdmErrorTable methodsFor: 'accessing'!

errors
	^errors! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmErrorTable class
	instanceVariableNames: ''!


!JdmErrorTable class methodsFor: 'singleton'!

errorTable
	ErrorTable isNil ifTrue: [ErrorTable := self new initialize].
	^ErrorTable!

resetErrorTable
	ErrorTable := nil! !

!JdmErrorTable class methodsFor: 'errors'!

errorTableMap
	"JdmErrorTable resetErrorTable"
	^#(#protocol 'Invalid Protocol'
	    #authentication 'Access denied'
	    #setDatabase   'Could not set the database'
	    #invalidQuery 'Invalid query')! !

!JdmConnection methodsFor: 'factory'!

rowClass
	^Jdm.MySQL.JdmRow!

fieldConverter
	^Jdm.MySQL.JdmFieldConverter fieldConverter!

executeQuery: aQuery info: queryInfo
        | responsePacket |
	(self requestPacket writeStream)
		nextPutCommand: (JdmMysqlCommand withCommandNamed: #query message: aQuery);
		flush.

        (queryInfo at: 1) == #read ifTrue: [ ^nil ].
        responsePacket := self responsePacket.
	responsePacket checkStatusOnError: #invalidQuery.
	^(responsePacket readStream next: 2) asByteArray asInteger!

readColumnHeadings
        | columns column |
	columns := Array 
		new: (self responsePacket readStatusOnError: #invalidQuery).
        1 to: columns size do: [:index |
            column := JdmColumn readFrom: self responsePacket readStream.
            columns at: index put: column].
        self responsePacket checkForStatus: 254 onError: #invalidQuery.
        ^columns! !

!JdmConnection methodsFor: 'closing'!

close
	self
		closeRequest;
		closeSocket!

closeRequest
	(self requestPacket writeStream)
		nextPutCommand: (JdmMysqlCommand withCommandNamed: #quit message: '');
		flush!

closeSocket
	socket isNil ifFalse: [socket close].
	socket := nil! !

!JdmConnection methodsFor: 'initialize-release'!

initialize
	self
		initializeConnection;
		initializeUser;
		initializeDatabase!

initializeConnection
    | messageText |
    hashesByProtocol := self class dictionaryClass: Dictionary
				   from: self class protocolHashes.

    socket := TCP.Socket remote: connectionSpec host port: connectionSpec port.
    "socket := [ TCP Socket remote: connectionSpec host port: connectionSpec port ]
	on: Error
	do: [ :ex | messageText := ex messageText. ex return: nil ]."

    socket isNil ifTrue: [ ^self error: messageText].	
    
    readStream := socket.
    writeStream := socket.
    serverInfo := JdmServerInfo on: self.
    clientCapabilities := serverInfo protocol = 10 ifTrue: [1] ifFalse: [0]!

initializeDatabase
    (self requestPacket writeStream)
	nextPutCommand: (JdmMysqlCommand withCommandNamed: #initializeDatabase
					 message: connectionSpec database);
	flush.
    self responsePacket checkStatusOnError: #setDatabase!

initializeUser
    | replyStream password |
    password := connectionSpec password isEmpty 
	ifTrue: ['']
	ifFalse: 
	    [self 
		 hash: connectionSpec password
		 seed: self serverInfo hashSeed
		 for: self serverInfo protocol].
    
    replyStream := self replyPacket writeStream.

    replyStream 
	nextPutAll: (self class integerAsByteArray: (self clientCapabilities) length: 2) asByteString;
	nextPutAll: (self class integerAsByteArray: 65536 length: 3) asByteString;
	nextPutAllNullTerminated: connectionSpec user;
	nextPutAllNullTerminated: password.
    replyStream flush.
   
    self responsePacket checkStatusOnError: #authenticate! !

!JdmConnection methodsFor: 'hashing'!

getHashFor: aProtocol 
	^hashesByProtocol at: aProtocol ifAbsent: [nil]!

hash: aString seed: aSeed for: aProtocol 
	| aHashMethod |
	aHashMethod := self getHashFor: aProtocol.
	aHashMethod isNil ifTrue: [^aString].
	^self class 
		perform: aHashMethod
		with: aString
		with: aSeed! !

!JdmConnection methodsFor: 'accessing'!

clientCapabilities
	^clientCapabilities!

replyPacket
	^(JdmOutputPacket on: writeStream) 
		packetNumber: responsePacket packetNumber + 1!

requestPacket
	^JdmOutputPacket on: writeStream!

responsePacket
	^responsePacket := JdmInputPacket on: readStream! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmConnection class
	instanceVariableNames: ''!


!JdmConnection class methodsFor: 'constants'!

protocolHashes
	^#(9 #hash1:seed:
          10 #hash2:seed:)! !

!JdmConnection class methodsFor: 'hashing'!

hash1: aString seed: aSeed 
	"This algorithm is for protocol 9."

	| hashedString maxValue array num1 num2 |
	hashedString := String new: aSeed size.
	array := self randomInit1: aString seed: aSeed.
	maxValue := array at: 1.
	num1 := array at: 2.
	num2 := array at: 3.
	1 to: hashedString size
		do: 
			[:index | 
			| num3 |
			num1 := (num1 * 3 + num2) \\ maxValue.
			num2 := (num1 + num2 + 33) \\ maxValue.
			num3 := (num1 / maxValue * 31) truncated + 64.
			hashedString at: index put: num3 asCharacter].
	^hashedString!

hash2: aString seed: aSeed 
	"This algorithm is for clientProtocol 10."

	| hashedString maxValue result num1 num2 num3 |
	hashedString := String new: aSeed size.
	result := self randomInit2: aString seed: aSeed.
	maxValue := result at: 1.
	num1 := result at: 2.
	num2 := result at: 3.
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
	hashedString inject: 1
		into: 
			[:index :character | 
			hashedString at: index put: (character asInteger bitXor: num3) asCharacter.
			index + 1].
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

randomInit1: aString seed: aSeed 
	| result array1 array2 |
	result := Array new: 3.
	array1 := self hash: aString.
	array2 := self hash: aSeed.
	result at: 1 put: 16r01FFFFFF.
	result at: 2 put: ((array1 at: 1) bitXor: (array2 at: 1)) \\ (result at: 1).
	result at: 3 put: (result at: 2) // 2.
	^result!

randomInit2: aString seed: aSeed 
	| result array1 array2 |
	result := Array new: 3.
	array1 := self hash: aString.
	array2 := self hash: aSeed.
	result at: 1 put: 16r3FFFFFFF.
	result at: 2 put: ((array1 at: 1) bitXor: (array2 at: 1)) \\ (result at: 1).
	result at: 3 put: ((array1 at: 2) bitXor: (array2 at: 2)) \\ (result at: 1).
	^result! !

!JdmConnection class methodsFor: 'misc'!

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
	s at: index put: ((ba at: index) asCharacter).
	].
    ^s! !

!JdmPacket methodsFor: 'accessing'!

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

JdmPacket class
	instanceVariableNames: ''!


!JdmPacket class methodsFor: 'constants'!

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

!JdmPacket class methodsFor: 'instance creation'!

on: aStream 
	^(self new)
		stream: aStream;
		initialize! !

!JdmInputPacket methodsFor: 'initialize-release'!

initialize
	self stream atEnd
		ifTrue: [ size := packetNumber := 0. buffer := #[]. ^self ].
	size := self readSize.
	packetNumber := self readPacketNumber.
	buffer := self readBuffer.
	readStream := JdmReadStream on: buffer.! !

!JdmInputPacket methodsFor: 'reading'!

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

	JdmErrorTable errorTable throwException: aSymbol
		message: (int1 + int2) printString, ' ', readStream readNullTerminatedString
"	JdmErrorTable errorTable throwException: aSymbol
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

!JdmInputPacket methodsFor: 'accessing'!

readStream
	^readStream! !

!JdmOutputPacket methodsFor: 'accessing'!

writeStream
	^writeStream! !

!JdmOutputPacket methodsFor: 'actions'!

flush

	| aString ba s bytesSend |
	aString := self writeStream contents.
	self size: aString size - self class headerSize.
	ba := JdmConnection integerAsByteArray: self size length: self class sizeSize.
	s := JdmConnection byteArrayAsByteString: ba.
	aString replaceFrom: 1 to: self class sizeSize with: s startingAt: 1.

	aString at: self class sizeSize + 1 put: self packetNumber asCharacter.
	
	(self stream) nextPutAll: aString; flush
! !


!JdmOutputPacket methodsFor: 'initialize-release'!

initialize
	packetNumber := 0.
	buffer := String new: self class defaultBufferSize.
	writeStream := JdmWriteStream
		on: buffer
		startingAt: (self class headerSize)
		outputPacket: self.

	"This is a bit of a hack...I should utilize events instead"
! !	


!JdmMysqlCommand methodsFor: 'private-accessing'!

command: aCommand
	command := aCommand! !

!JdmMysqlCommand methodsFor: 'accessing'!

command
	^command!

message
	^message!

message: aMessage 
	message := aMessage isNil ifTrue: [' '] ifFalse: [aMessage]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmMysqlCommand class
	instanceVariableNames: ''!


!JdmMysqlCommand class methodsFor: 'instance creation'!

withCommand: aCommand 
	^self withCommand: aCommand message: nil!

withCommand: aCommand message: aMessage 
	^(self new)
		command: aCommand;
		message: aMessage!

withCommandNamed: aCommandName
	^self withCommandNamed: aCommandName message: nil!

withCommandNamed: aCommandName message: aMessage 
	^(self new)
		command: (self perform: aCommandName);
		message: aMessage! !

!JdmMysqlCommand class methodsFor: 'mysql-constants'!

connect
	^11!

createDatabase
	^5!

debug
	^13!

dropDatabase
	^6!

fieldList
	^4!

initializeDatabase
	^2!

killProcess
	^12!

processInfo
	^10!

query
	^3!

quit
	^1!

refresh
	^7!

shutdown
	^8!

sleep
	^0!

statistics
	^9! !

!JdmServerInfo methodsFor: 'initialize-release'!

initialize
	self serverVersion: JdmServerVersion new initialize.
	hashSeed := String new.
	protocol := -1.
	serverThread := -1.
	options := -1! !

!JdmServerInfo methodsFor: 'accessing'!

hashSeed
	^hashSeed!

hashSeed: anObject
	hashSeed := anObject!

options
	^options!

options: anObject
	options := anObject!

protocol
	^protocol!

protocol: aProtocol 
	self validateProtocol: aProtocol.
	protocol := aProtocol!

serverThread
	^serverThread!

serverThread: anObject
	serverThread := anObject! !

!JdmServerInfo methodsFor: 'reading'!

readFrom: aResponsePacket
	self
		readProtocolFrom: aResponsePacket;
		readServerVersionFrom: aResponsePacket;
		readServerThreadFrom: aResponsePacket;
		readHashSeedFrom: aResponsePacket;
		readOptionsFrom: aResponsePacket!

readHashSeedFrom: aResponsePacket
	hashSeed := aResponsePacket readStream readNullTerminatedString!

readOptionsFrom: aResponsePacket 
	options := (aResponsePacket readStream next: 2) asByteArray asInteger!

readProtocolFrom: aResponsePacket 
	protocol := (aResponsePacket readStatusOnError: #protocol)!

readServerThreadFrom: aResponsePacket
	serverThread := (aResponsePacket readStream next: 4) asByteArray asInteger!

readServerVersionFrom: aResponsePacket 
	serverVersion := JdmServerVersion readFrom: aResponsePacket readStream! !

!JdmServerInfo methodsFor: 'validation'!

validateProtocol: aProtocol 
	(aProtocol = 9 or: [aProtocol = 10]) 
		ifFalse: [JdmErrorTable errorTable error: #protocol]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmServerInfo class
	instanceVariableNames: ''!


!JdmServerInfo class methodsFor: 'constants'!

clientProtocolSize
	^1!

optionsSize
	^2!

serverThreadSize
	^4! !

!JdmServerInfo class methodsFor: 'instance creation'!

on: aConnection 
	^self new readFrom: aConnection responsePacket! !



!JdmServerVersion methodsFor: 'reading'!

readFrom: aStream
	fileFormat := Integer readFrom: aStream.
	aStream next.
	release := Integer readFrom: aStream.
	aStream next.
	version := Integer readFrom: aStream.
	aStream readNullTerminatedString! !

!JdmServerVersion class methodsFor: 'instance creation'!

readFrom: aStream 
	^self new readFrom: aStream! !

!JdmDateTime methodsFor: 'comparing'!

= aJdmDateTime 
	^aJdmDateTime class == self class 
		and: [self date = aJdmDateTime date and: [self time = aJdmDateTime time]]! !

!JdmDateTime methodsFor: 'accessing'!

date
	^date!

date: aJdmDate
	date := aJdmDate!

time
	^time!

time: aJdmTime 
	time := aJdmTime! !

!JdmDateTime methodsFor: 'printing'!

printOn: aStream 
	self date printOn: aStream.
	aStream nextPut: $ .
	self time printOn: aStream! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmDateTime class
	instanceVariableNames: ''!


!JdmDateTime class methodsFor: 'instance creation'!

fromDate: aJdmDate andTime: aJdmTime 
	^(self new)
		date: aJdmDate;
		time: aJdmTime!

readFrom: aStream 
	^JdmTimestampReader 
		readMysqlDateTimeFrom: aStream! !

!JdmTimestampReader class methodsFor: 'reading mysql'!

readMysqlDateFrom: aStream 
	| day month year |
	year := Integer readFrom: aStream.
	aStream next.
	month := Integer readFrom: aStream.
	aStream next.
	day := Integer readFrom: aStream.
	^Date 
		newDay: day
		monthIndex: month
		year: year!

readMysqlDateTimeFrom: aStream 
	| aJdmDate aJdmTime |
	aJdmDate := self readMysqlDateFrom: aStream.
	aStream next.
	aJdmTime := self readMysqlTimeFrom: aStream.
	^JdmDateTime fromDate: aJdmDate andTime: aJdmTime!

readMysqlTimeFrom: aStream 
	| hour minute second |
	hour := Integer readFrom: aStream.
	aStream next.
	minute := Integer readFrom: aStream.
	aStream next.
	second := Integer readFrom: aStream.
	^Time fromSeconds: 60 * (60 * hour + minute) + second!

readMysqlTimestampFrom: aStream 
	| year month day hour minute second |
	year := self readIntegerFrom: aStream next: 4.
	month := self readIntegerFrom: aStream next: 2.
	day := self readIntegerFrom: aStream next: 2.
	hour := self readIntegerFrom: aStream next: 2.
	minute := self readIntegerFrom: aStream next: 2.
	second := self readIntegerFrom: aStream next: 2.
	^JdmDateTime
		fromDate: (Date newDay: day monthIndex: month year: year)
		andTime: (Time fromSeconds: (3600 * hour) + (60 * minute) + second)! !


!JdmTimestampReader class methodsFor: 'private-reading'!

readIntegerFrom: aStream next: anInteger 
	^Integer readFrom: (ReadStream on: (aStream next: anInteger))! !

!JdmTimestampWriter class methodsFor: 'reading mysql'!

printMysqlDate: aDate on: aStream 
	aDate year printOn: aStream.
	aStream nextPut: $-.
	self print: aDate month on: aStream next: 2.
	aStream nextPut: $-.
	self print: aDate day on: aStream next: 2!

printMysqlTime: aTime on: aStream 
	self print: aTime hour on: aStream next: 2.
	aStream nextPut: $:.
	self print: aTime minute on: aStream next: 2.
	aStream nextPut: $:.
	self print: aTime second on: aStream next: 2!

printMysqlTimestamp: aDateTime on: aStream 
	self print: aDateTime year on: aStream next: 4.
	self print: aDateTime month on: aStream next: 2.
	self print: aDateTime day on: aStream next: 2.
	self print: aDateTime hour on: aStream next: 2.
	self print: aDateTime minute on: aStream next: 2.
	self print: aDateTime second on: aStream next: 2!


!JdmTimestampWriter class methodsFor: 'private-writing'!

print: anInteger on: aStream next: n 
	| str |
	str := anInteger printString.
	aStream next: n - str size put: $0.
	aStream nextPutAll: str! !


!JdmColumn methodsFor: 'reading'!

readDecimalPlaces: aReadStream
	decimalPlaces := aReadStream next asInteger!

readFlags: aReadStream 
	"Currently the size of both the flags field and decimalPlaces field is specified as a sum of the two.
        I am guessing that the size of the flags is more likely to change than that of the decimalPlaces.
        Right now I assume that the flags are all bytes but the last and that the last is the decimalPlaces"

	flags := (aReadStream next: aReadStream next asInteger - 1) asByteArray 
				asInteger!

readFrom: aReadStream 
	self
		readTable: aReadStream;
		readName: aReadStream;
		readSize: aReadStream;
		readType: aReadStream;
		readFlags: aReadStream;
		readDecimalPlaces: aReadStream!

readName: aReadStream
	name := (aReadStream next: aReadStream next asInteger)!

readSize: aReadStream
	size := (aReadStream next: aReadStream next asInteger) asByteArray asInteger!

readTable: aReadStream
	table := (aReadStream next: aReadStream next asInteger)!

readType: aReadStream
	type := (aReadStream next: aReadStream next asInteger) asByteArray asInteger! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmColumn class
	instanceVariableNames: ''!


!JdmColumn class methodsFor: 'constants-types'!

blobType
	^252!

datetimeType
	^12!

dateType
	^10!

decimalType
	^0!

doubleType
	^5!

enumType
	^247!

floatType
	^4!

int24Type
	^9!

longBlobType
	^251!

longlongType
	^8!

longType
	^3!

mediumBlobType
	^250!

newDateType
	^14!

nullType
	^6!

setType
	^248!

shortType
	^2!

stringType
	^254!

timestampType
	^7!

timeType
	^11!

tinyBlobType
	^249!

tinyType
	^1!

varStringType
	^253!

yearType
	^13! !

!JdmColumn class methodsFor: 'constants-flags'!

autoIncrementFlag
	^512!

binaryFlag
	^128!

blobFlag
	^16!

enumFlag
	^256!

multipleKeyFlag
	^8!

notNullFlag
	^1!

primaryKeyFlag
	^2!

timestampFlag
	^1024!

uniqueKeyFlag
	^4!

unsignedFlag
	^32!

zerofillFlag
	^64! !

!JdmColumn class methodsFor: 'instance creation'!

readFrom: aReadStream
	^self new readFrom: aReadStream! !

!JdmRow methodsFor: 'reading'!

checkForEndOrNull: aReadStream 
	"This is a bit unclean...the value 254 has been overloaded in the protocol.  When it is the only
        value in the stream, it indicates there are no more rows.  It also indicates that the following
        4 bytes contain the size of the field value.  The problem is that there is another condition that
        produces a single value on the stream...a row with one column whose value is NULL."

	| endOrNull |
	aReadStream size = 1 ifFalse: [^false].
	endOrNull := aReadStream next asInteger.
	endOrNull = 254 
		ifTrue: 
			[isEmpty := true.
			^true].
	endOrNull = 251 
		ifTrue: 
			[^true].
	"Unexpected Value"
	JdmErrorTable throwException: #invalidQuery
		message: 'Unexpected value ' , endOrNull printString.
	^true!

readFrom: aReadStream 
	(self checkForEndOrNull: aReadStream) ifTrue: [^self].
	self readRowsFrom: aReadStream!

readRowsFrom: aReadStream 
	1 to: numColumns
		do: 
			[:index | 
			| aSize |
			aSize := self readSizeFrom: aReadStream.
			aSize = -1 ifFalse: [values at: index put: (aReadStream next: aSize)]]!

readSizeFrom: aReadStream 
	| aSize |
	aSize := aReadStream next asInteger.
	aSize < 251 ifTrue: [^aSize].
	aSize = 251 ifTrue: [^-1].
	^(aReadStream next: (aSize bitAnd: 3) + 2) asByteArray asInteger! !

!JdmRow methodsFor: 'initialize-release'!

initialize
	values := Array new: numColumns.
	self initializeWithNulls.
	isEmpty := false.!

initializeWithNulls
	1 to: numColumns do: [:index | values at: index put: nil]! !

!JdmRow methodsFor: 'accessing'!

at: anIndex
	^values at: anIndex!

numColumns: anInteger
	numColumns := anInteger! !

!JdmRow methodsFor: 'testing'!

isEmpty
	^isEmpty! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmRow class
	instanceVariableNames: ''!


!JdmRow class methodsFor: 'instance creation'!

withNumColumns: anInteger 
	^(self new)
		numColumns: anInteger;
		initialize! !

!JdmFieldConverter methodsFor: 'converting-smalltalk'!

writeDate: aDate on: aStream
	JdmTimestampWriter printMysqlDate: aDate on: aStream!

writeDouble: aDouble on: aStream 
	| readStream character |
	readStream := ReadStream on: aDouble printString.
	
	[character := readStream next.
	character isNil] whileFalse: 
				[character = $d 
					ifTrue: 
						[character := readStream next.
						character isNil ifTrue: [^self].
						aStream nextPut: $e.
						character = $- ifFalse: [aStream nextPut: $+]].
				aStream nextPut: character]!

writeFloat: aFloat on: aStream 
	| readStream character |
	readStream := ReadStream on: aFloat printString.
	
	[character := readStream next.
	character isNil] whileFalse: 
				[character = $e 
					ifTrue: 
						[aStream nextPut: character.
						character := readStream next.
						character = $- ifFalse: [aStream nextPut: $+]].
				aStream nextPut: character]!

writeJdmDateTime: aJdmDateTime on: aStream 
	self writeDate: aJdmDateTime date on: aStream.
	aStream nextPut: $ .
	self writeTime: aJdmDateTime time on: aStream!

writeQuotedDate: aDate on: aStream
	aStream nextPut: $'.
	self writeDate: aDate on: aStream.
	aStream nextPut: $'.!

writeQuotedJdmDateTime: aJdmDateTime on: aStream
	aStream nextPut: $'.
	self writeJdmDateTime: aJdmDateTime on: aStream.
	aStream nextPut: $'.!

writeQuotedTime: aTime on: aStream
	aStream nextPut: $'.
	self writeTime: aTime on: aStream.
	aStream nextPut: $'.!

writeQuotedTimestamp: aTimestamp on: aStream
	aStream nextPut: $'.
	self writeTimestamp: aTimestamp on: aStream.
	aStream nextPut: $'.!

writeTime: aTime on: aStream
	JdmTimestampWriter printMysqlTime: aTime on: aStream!

writeTimestamp: aTimestamp on: aStream
	JdmTimestampWriter printMysqlTimestamp: aTimestamp on: aStream! !

!JdmFieldConverter methodsFor: 'actions'!

convert: aValue from: aColumn 
	^self perform: (types at: aColumn type) with: aValue with: aColumn!

convertToMysql: aValue 
	| writeStream |
	writeStream := WriteStream on: String new.
	self convertToMysql: aValue on: writeStream.
	^writeStream contents!

convertToMysql: aValue on: aStream 
	| aSelector |
	aSelector := converterSelectors at: aValue class name
				ifAbsent: 
					[aValue printOn: aStream.
					^self].
	^self 
		perform: aSelector
		with: aValue
		with: aStream! !

!JdmFieldConverter methodsFor: 'converting'!

toByteArray: aString column: aColumn
 	^aColumn isBinary
 		ifTrue: [aString isNil
				ifTrue: [nil]
				ifFalse: [aString asByteArray]]
		ifFalse: [aString]!

toDate: aString column: aColumn 
	^JdmTimestampReader 
		readMysqlDateFrom: (ReadStream on: aString)!

toDateTime: aString column: aColumn 
	^JdmDateTime readFrom: (ReadStream on: aString)!

toDouble: aString column: aColumn 
	| aStream writeStream character |
	aStream := ReadStream on: aString.
	writeStream := WriteStream on: String new.
	
	[character := aStream next.
	character isNil] whileFalse: 
				[character = $e 
					ifTrue: 
						[writeStream nextPut: $d.
						character := aStream next.
						character = $+ ifTrue: [character := aStream next]].
				writeStream nextPut: character].
	^FloatD readFrom: (ReadStream on: writeStream contents)!

toFloat: aString column: aColumn 
	| writeStream character aStream |
	aStream := ReadStream on: aString.
	writeStream := WriteStream on: String new.
	
	[character := aStream next.
	character isNil] 
			whileFalse: [character = $+ ifFalse: [writeStream nextPut: character]].
	^FloatE readFrom: (ReadStream on: writeStream contents)!

toInteger: aString column: aColumn 
	^Integer readFrom: (ReadStream on: aString)!

toString: aString column: aColumn
	^aString!

toTime: aString column: aColumn 
	^JdmTimestampReader 
		readMysqlTimeFrom: (ReadStream on: aString)!

toTimestamp: aString column: aColumn 
	^JdmTimestampReader 
		readMysqlTimestampFrom: (ReadStream on: aString)! !

!JdmFieldConverter methodsFor: 'private-initialize'!

buildConversionMap
	converterSelectors := IdentityDictionary new.
	converterSelectors
		at: #FloatD put: #writeDouble:on:;
		at: #FloatE put: #writeFloat:on:;
		at: #Time put: #writeQuotedTime:on:;
		at: #DateTime put: #writeQuotedTimestamp:on:;
		at: #Date put: #writeQuotedDate:on:;
		at: #JdmDateTime put: #writeQuotedJdmDateTime:on:!

buildTypeMap
	types := Dictionary new.
	types
		at: JdmColumn tinyType put: #toInteger:column:;
		at: JdmColumn shortType put: #toInteger:column:;
		at: JdmColumn longType put: #toInteger:column:;
		at: JdmColumn int24Type put: #toInteger:column:;
		at: JdmColumn longlongType put: #toInteger:column:;
		at: JdmColumn floatType put: #toFloat:column:;
		at: JdmColumn doubleType put: #toDouble:column:;
		at: JdmColumn decimalType put: #toDouble:column:;
		at: JdmColumn dateType put: #toDate:column:;
		at: JdmColumn datetimeType put: #toDateTime:column:;
		at: JdmColumn timeType put: #toTime:column:;
		at: JdmColumn timestampType put: #toTimestamp:column:;
		at: JdmColumn enumType put: #toString:column:;
		at: JdmColumn setType put: #toSet:column:;
		at: JdmColumn tinyBlobType put: #toByteArray:column:;
		at: JdmColumn mediumBlobType put: #toByteArray:column:;
		at: JdmColumn longBlobType put: #toByteArray:column:;
		at: JdmColumn blobType put: #toByteArray:column:;
		at: JdmColumn varStringType put: #toString:column:;
		at: JdmColumn stringType put: #toString:column:! !

!JdmFieldConverter methodsFor: 'initialize-release'!

initialize
	self
		buildTypeMap;
		buildConversionMap! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JdmFieldConverter class
	instanceVariableNames: ''!


!ByteArray methodsFor: 'accessing'!
asInteger 
    | shiftAmount anInteger |
	
    shiftAmount := 0.	
    anInteger := 0.
    1 to: self size 
	     do: 
	     [:index | 
		 anInteger := anInteger bitOr: ((self at: index) bitShift: shiftAmount).
		 shiftAmount := shiftAmount + 8].
    ^anInteger
!

asByteString
    | stream | 
    stream := WriteStream on: String new.
    1 to: self size do: [ :x |
	stream nextPut: (self basicAt: x) asCharacter].
    ^stream contents
! !

