"=====================================================================
|
|   MySQL DBI driver - ColumnInfo class
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


ColumnInfo subclass: #MySQLColumnInfo
	instanceVariableNames: 'table name size type flags decimalPlaces charset index '
	classVariableNames: 'Types ConverterSelectors TypeNames'
	poolDictionaries: ''
	category: 'Mysql-Driver'!


!MySQLColumnInfo methodsFor: 'testing'!

hasFlag: aFlag
	^(self flags bitAnd: aFlag) > 0!

isAutoIncrement
	^self hasFlag: self class autoIncrementFlag!

isBinary
	^self hasFlag: self class binaryFlag!

isBlob
	^self hasFlag: self class blobFlag!

isEnumeration
	^self hasFlag: self class enumFlag!

isMultipleKey
	^self hasFlag: self class multipleKeyFlag!

isNotNull
	^self hasFlag: self class notNullFlag!

isPrimaryKey
	^self hasFlag: self class primaryKeyFlag!

isTimestamp
	^self hasFlag: self class timestampFlag!

isUniqueKey
	^self hasFlag: self class uniqueKeyFlag!

isZerofill
	^self hasFlag: self class zerofillFlag! !

!MySQLColumnInfo methodsFor: 'accessing'!

decimalPlaces
	^decimalPlaces!

flags
	^flags!

index
	^index!

name
	^name!

size
	^size!

table
	^table!

type
	^TypeNames at: type! !

!MySQLColumnInfo class methodsFor: 'converting-smalltalk'!

writeBoolean: aBoolean on: aStream
	aBoolean
		ifTrue: [ aStream nextPutAll: 'True' ]
		ifFalse: [ aStream nextPutAll: 'False' ]!

writeDate: aDate on: aStream
	self printMysqlDate: aDate on: aStream!

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

writeMySQLDateTime: aMySQLDateTime on: aStream 
	self writeDate: aMySQLDateTime asDate on: aStream.
	aStream nextPut: $ .
	self writeTime: aMySQLDateTime asTime on: aStream!

writeQuotedDate: aDate on: aStream
	aStream nextPut: $'.
	self writeDate: aDate on: aStream.
	aStream nextPut: $'.!

writeQuotedTime: aTime on: aStream
	aStream nextPut: $'.
	self writeTime: aTime on: aStream.
	aStream nextPut: $'.!

writeQuotedTimestamp: aTimestamp on: aStream
	aStream nextPut: $'.
	self writeMySQLDateTime: aTimestamp on: aStream.
	aStream nextPut: $'.!

writeTime: aTime on: aStream
	self printMysqlTime: aTime on: aStream!

writeTimestamp: aTimestamp on: aStream
	self printMysqlTimestamp: aTimestamp on: aStream! !

!MySQLColumnInfo methodsFor: 'actions'!

convert: aValue
	^self perform: (Types at: type) with: aValue!

!MySQLColumnInfo class methodsFor: 'actions'!

convertToMysql: aValue 
	| writeStream |
	writeStream := WriteStream on: String new.
	self convertToMysql: aValue on: writeStream.
	^writeStream contents!

convertToMysql: aValue on: aStream 
	| aSelector |
	aSelector := ConverterSelectors at: aValue class name
				ifAbsent: 
					[aValue printOn: aStream.
					^self].
	^self 
		perform: aSelector
		with: aValue
		with: aStream! !

!MySQLColumnInfo methodsFor: 'converting'!

toBoolean: aString
	aString isNil ifTrue: [ ^nil ].
	^aString first value = 1!

toByteArray: aString
 	^self isBinary
 		ifTrue: [aString isNil
				ifTrue: [nil]
				ifFalse: [aString asByteArray]]
		ifFalse: [aString]!

toDate: aString
	^self class 
		readDateFrom: (ReadStream on: aString)!

toDateTime: aString
	^self class readTimestampFrom: aString readStream!

toDouble: aString
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

toFloat: aString
	| writeStream character aStream |
	aStream := ReadStream on: aString.
	writeStream := WriteStream on: String new.
	
	[character := aStream next.
	character isNil] 
			whileFalse: [character = $+ ifFalse: [writeStream nextPut: character]].
	^FloatE readFrom: (ReadStream on: writeStream contents)!

toInteger: aString
	^Integer readFrom: (ReadStream on: aString)!

toString: aString
	^aString!

toTime: aString
	^self class 
		readTimeFrom: (ReadStream on: aString)!

toTimestamp: aString
	^self class 
		readTimestampFrom: (ReadStream on: aString)! !

!MySQLColumnInfo class methodsFor: 'private-initialize'!

buildConversionMap
	ConverterSelectors := IdentityDictionary new.
	ConverterSelectors
		at: #Boolean put: #writeBoolean:on:;
		at: #FloatD put: #writeDouble:on:;
		at: #FloatE put: #writeFloat:on:;
		at: #Time put: #writeQuotedTime:on:;
		at: #DateTime put: #writeQuotedTimestamp:on:;
		at: #Date put: #writeQuotedDate:on:!

buildTypeNameMap
	TypeNames := Dictionary new.
	TypeNames
		at: MySQLColumnInfo bitType put: 'bit';
		at: MySQLColumnInfo tinyType put: 'tinyint';
		at: MySQLColumnInfo shortType put: 'smallint';
		at: MySQLColumnInfo int24Type put: 'mediumint';
		at: MySQLColumnInfo longType put: 'int';
		at: MySQLColumnInfo longlongType put: 'bigint';
		at: MySQLColumnInfo floatType put: 'float(4)';
		at: MySQLColumnInfo doubleType put: 'float(8)';
		at: MySQLColumnInfo oldDecimalType put: 'decimal';
		at: MySQLColumnInfo decimalType put: 'decimal';
		at: MySQLColumnInfo newDateType put: 'date';
		at: MySQLColumnInfo dateType put: 'date';
		at: MySQLColumnInfo datetimeType put: 'datetime';
		at: MySQLColumnInfo timeType put: 'time';
		at: MySQLColumnInfo timestampType put: 'timestamp';
		at: MySQLColumnInfo enumType put: 'enum';
		at: MySQLColumnInfo setType put: 'set';
		at: MySQLColumnInfo tinyBlobType put: 'tinyblob';
		at: MySQLColumnInfo mediumBlobType put: 'mediumblob';
		at: MySQLColumnInfo longBlobType put: 'longblob';
		at: MySQLColumnInfo blobType put: 'blob';
		at: MySQLColumnInfo varCharType put: 'varchar';
		at: MySQLColumnInfo varStringType put: 'varchar';
		at: MySQLColumnInfo stringType put: 'string'!

buildTypeMap
	Types := Dictionary new.
	Types
		at: MySQLColumnInfo bitType put: #toBoolean:;
		at: MySQLColumnInfo tinyType put: #toInteger:;
		at: MySQLColumnInfo shortType put: #toInteger:;
		at: MySQLColumnInfo longType put: #toInteger:;
		at: MySQLColumnInfo int24Type put: #toInteger:;
		at: MySQLColumnInfo longlongType put: #toInteger:;
		at: MySQLColumnInfo floatType put: #toFloat:;
		at: MySQLColumnInfo doubleType put: #toDouble:;
		at: MySQLColumnInfo oldDecimalType put: #toDouble:;
		at: MySQLColumnInfo decimalType put: #toDouble:;
		at: MySQLColumnInfo newDateType put: #toDate:;
		at: MySQLColumnInfo dateType put: #toDate:;
		at: MySQLColumnInfo datetimeType put: #toDateTime:;
		at: MySQLColumnInfo timeType put: #toTime:;
		at: MySQLColumnInfo timestampType put: #toTimestamp:;
		at: MySQLColumnInfo enumType put: #toString:;
		at: MySQLColumnInfo setType put: #toSet:;
		at: MySQLColumnInfo tinyBlobType put: #toByteArray:;
		at: MySQLColumnInfo mediumBlobType put: #toByteArray:;
		at: MySQLColumnInfo longBlobType put: #toByteArray:;
		at: MySQLColumnInfo blobType put: #toByteArray:;
		at: MySQLColumnInfo varCharType put: #toString:;
		at: MySQLColumnInfo varStringType put: #toString:;
		at: MySQLColumnInfo stringType put: #toString:! !

!MySQLColumnInfo class methodsFor: 'initialize-release'!

initialize
	self
		buildTypeMap;
		buildTypeNameMap;
		buildConversionMap! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!MySQLColumnInfo class methodsFor: 'reading mysql'!

readDateFrom: aStream 
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

readTimeFrom: aStream 
	| hour minute second |
	hour := Integer readFrom: aStream.
	aStream next.
	minute := Integer readFrom: aStream.
	aStream next.
	second := Integer readFrom: aStream.
	^Time fromSeconds: 60 * (60 * hour + minute) + second!

readTimestampFrom: aStream 
	| year month day hour minute second separators |
	year := self readIntegerFrom: aStream next: 4.
	separators := aStream peekFor: $-.
	month := self readIntegerFrom: aStream next: 2.
	separators ifTrue: [ aStream next ].
	day := self readIntegerFrom: aStream next: 2.
	separators ifTrue: [ aStream next ].
	hour := self readIntegerFrom: aStream next: 2.
	separators ifTrue: [ aStream next ].
	minute := self readIntegerFrom: aStream next: 2.
	separators ifTrue: [ aStream next ].
	second := self readIntegerFrom: aStream next: 2.
	^DateTime
		fromDays: (Date newDay: day monthIndex: month year: year) days
		seconds: (3600 * hour) + (60 * minute) + second
		offset: Duration zero! !


!MySQLColumnInfo class methodsFor: 'private-reading'!

readIntegerFrom: aStream next: anInteger 
	^Integer readFrom: (ReadStream on: (aStream next: anInteger))! !

!MySQLColumnInfo class methodsFor: 'reading mysql'!

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


!MySQLColumnInfo class methodsFor: 'private-writing'!

print: anInteger on: aStream next: n 
	| str |
	str := anInteger printString.
	aStream next: n - str size put: $0.
	aStream nextPutAll: str! !


!MySQLColumnInfo methodsFor: 'reading'!

charset
	^charset
! !

!MySQLColumnInfo methodsFor: 'reading'!

readDecimalPlaces: aReadStream
	decimalPlaces := aReadStream next asInteger!

readFlags: aReadStream 
	flags := (aReadStream next: 2) asByteArray asInteger!

readFrom: aReadStream index: i
	| length fields |
	"can be catalogue, db, table, org table, field (and org field follows)
	 or table, field, length, type, flags+decimal"
	index := i.
	fields := (1 to: 5) collect: [ :i |
		aReadStream next: aReadStream next asInteger ].
	aReadStream atEnd ifFalse: [
		table := fields at: 3.
		name := fields at: 5.
		"org field"
		aReadStream next: aReadStream next asInteger.
		length := aReadStream next asInteger - 10.
		self
			readCharset: aReadStream;
			readSize: aReadStream;
			readType: aReadStream;
			readFlags: aReadStream;
			readDecimalPlaces: aReadStream.
		aReadStream next: length.
		^self ].

	"MySQL 3.x format."
	table := fields at: 1.
	name := fields at: 2.
	size := (fields at: 3) asByteArray asInteger.
	type := (fields at: 4) first asInteger.
	self readFlags: (fields at: 5) readStream.
	decimalPlaces := (fields at: 5) last asInteger!


readCharset: aReadStream
	charset := (aReadStream next: 2) asByteArray asInteger!

readName: aReadStream
	name := (aReadStream next: aReadStream next asInteger)!

readSize: aReadStream
	size := (aReadStream next: 4) asByteArray asInteger!

readTable: aReadStream
	table := (aReadStream next: aReadStream next asInteger)!

readType: aReadStream
	type := aReadStream next asInteger! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MySQLColumnInfo class
	instanceVariableNames: ''!


!MySQLColumnInfo class methodsFor: 'constants-types'!

bitType
	^16!

blobType
	^252!

datetimeType
	^12!

newDateType
	^14!

dateType
	^10!

oldDecimalType
	^0!

decimalType
	^246!

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

varCharType
	^15!

varStringType
	^253!

yearType
	^13! !

!MySQLColumnInfo class methodsFor: 'constants-flags'!

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

!MySQLColumnInfo class methodsFor: 'instance creation'!

readFrom: aReadStream
	^self new readFrom: aReadStream! !

MySQLColumnInfo initialize!
