"=====================================================================
|
|   Just a Database Manager - MySQL driver unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Paolo Bonzini
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

Jdm addSubspace: #MySQL!
Namespace current: Jdm.MySQL!

TestCase subclass: #JdmMysqlBaseTestCase
	instanceVariableNames: 'connection testSupport testProgress '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


JdmMysqlBaseTestCase subclass: #JdmMysqlCreateTableTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


JdmMysqlBaseTestCase subclass: #JdmMysqlDropTableTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


JdmMysqlBaseTestCase subclass: #JdmMysqlDeleteTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


JdmMysqlBaseTestCase subclass: #JdmMysqlInsertTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


JdmMysqlBaseTestCase subclass: #JdmMysqlSelectTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


Object subclass: #JdmRangedRandom
	instanceVariableNames: 'random highValue lowValue range numRandomBits '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


Object subclass: #JdmTestProgress
	instanceVariableNames: 'resolution totalSteps numSteps stepsPerLevel currentStep displayCharacter '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


TestSuite subclass: #JdmMysqlTestSuite
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


Object subclass: #JdmMysqlTestSupport
	instanceVariableNames: 'randomGenerators connectionSpec mysqlTypes mysqlValues enumSetValues '
	classVariableNames: 'Instance '
	poolDictionaries: ''
	category: 'Mysql-Driver-Tests'!


!JdmMysqlBaseTestCase methodsFor: 'initialize-release'!

setUp
	super setUp.
	testSupport := JdmMysqlTestSupport mysqlTestSupport.
	connection := JdmConnection on: testSupport connectionSpec.
	testProgress := JdmTestProgress new: testSupport class numRowsToInsert.
	testProgress!

tearDown
	connection close.! !


!JdmMysqlBaseTestCase class methodsFor: 'constants'!

tableName
	^'TestTable'! !

!JdmMysqlCreateTableTestCase methodsFor: 'tests'!

createTable
	| result |
	Transcript show: 'Creating table: ', testSupport class tableName, '...'.
	result := connection createStatement 
				executeQuery: testSupport createTable.
	Transcript show: ' Done'.
	self should: [result type = #update and: [result value = 0]]! !

!JdmMysqlDropTableTestCase methodsFor: 'tests'!

dropTable
	| result |
	Transcript show: 'Dropping table: ', testSupport class tableName, '...'.
	result := connection createStatement 
				executeQuery: 'drop table ' , testSupport class tableName.
	Transcript show: ' Done'.
	self should: [result type = #update and: [result value = 0]]! !

!JdmMysqlDeleteTestCase methodsFor: 'tests'!

deleteRows
	| result |
	Transcript
		show: 'Deleting ' , testSupport class numRowsToInsert printString , ' rows...'.
	result := connection createStatement 
				executeQuery: 'delete from ' , testSupport class tableName.
	Transcript show: ' Done'.
	self should: [result type = #update and: [result value = 0]]! !

!JdmMysqlInsertTestCase methodsFor: 'tests'!

insertRow
	| result |
	result := connection createStatement 
				executeQuery: testSupport insertIntoTable.
	testProgress nextStep.
	^result!

insertRows
	| ok result |
	Transcript
		show: 'Inserting ' , testSupport class numRowsToInsert printString 
					, ' rows'.

	ok := true.
	testSupport class numRowsToInsert timesRepeat: [
		result := self insertRow.
		ok := ok and: [result type = #update and: [result value = 1]].
	].
	self should: [ ok ]! !

!JdmMysqlSelectTestCase methodsFor: 'tests'!

checkResult: aResult 
	| resultSet count numColumns |
	resultSet := aResult value.
	self should: [resultSet isNil not].
	count := 0.
	numColumns := resultSet columns size.
	[resultSet next] whileTrue: 
			[1 to: numColumns
				do: [:columnNum | (resultSet valueAt: columnNum) printString].
			count := count + 1.
			testProgress nextStep].
	^count!

selectRows
	| result |
	Transcript
		show: 'Selecting ' , testSupport class numRowsToInsert printString, ' rows'.
	result := connection createStatement 
				executeQuery: 'select * from ' , testSupport class tableName.
	self should: 
			[result type = #read 
				and: [(self checkResult: result) = testSupport class numRowsToInsert]]! !

!JdmMysqlTestSupport methodsFor: 'private'!

createDelimitedStringFor: aCollection delimiter: aDelimiter using: aBlock 
	| collection writeStream |
	collection := aCollection asOrderedCollection.
	collection size = 0 ifTrue: [^''].
	writeStream := WriteStream on: String new.
	writeStream nextPutAll: (aBlock value: collection first).
	2 to: collection size
		do: 
			[:index | 
			writeStream
				nextPutAll: aDelimiter;
				nextPutAll: (aBlock value: (collection at: index))].
	^writeStream contents!

enumSetValues
	^enumSetValues!

enumValues
	^self 
		createDelimitedStringFor: self enumSetValues
		delimiter: ', '
		using: [:enumValue | '''' , enumValue , '''']!

fieldNameFor: aType 
	^'Jdm' , aType!

getFieldDefinitionFor: aType 
	| writeStream |
	writeStream := WriteStream on: String new.
	self writeFieldDefinitionFor: aType on: writeStream.
	^writeStream contents!

nextRandomFor: aType
	^(randomGenerators at: aType) next!

writeFieldDefinitionFor: aType on: aWriteStream 
	aWriteStream
		nextPutAll: (self fieldNameFor: aType);
		nextPut: $ ;
		nextPutAll: (mysqlTypes at: aType)! !

!JdmMysqlTestSupport methodsFor: 'accessing'!

connectionSpec
	^JdmConnectionSpec new
		initialize;
		user: 'utente'; password: '';
		host: 'localhost'; database: 'test';
		port: 3306; yourself!

createTable
	^self createTableNamed: self class tableName!

createTableNamed: aName 
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: 'CREATE TABLE ';
		nextPutAll: aName;
		nextPut: $(;
		nl.
	writeStream nextPutAll: (self 
				createDelimitedStringFor: mysqlTypes keys
				delimiter: ', '
				using: [:field | self getFieldDefinitionFor: field]).
	^writeStream
		nextPut: $);
		contents!

insertIntoTable
	^self insertIntoTableNamed: self class tableName!

insertIntoTableNamed: aName 
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: 'INSERT INTO ';
		nextPutAll: aName;
		nextPutAll: ' (';
		nl.
	writeStream nextPutAll: (self 
				createDelimitedStringFor: mysqlTypes keys
				delimiter: ', '
				using: [:field | self fieldNameFor: field]).
	writeStream
		nextPutAll: ') VALUES (';
		nl.
	writeStream
		nextPutAll: (self 
					createDelimitedStringFor: mysqlTypes keys
					delimiter: ', '
					using: 
						[:type | 
						| valueSelector |
						valueSelector := mysqlValues at: type ifAbsent: #null.
						JdmFieldConverter fieldConverter 
							convertToMysql: ((self perform: valueSelector) value: type value: self)]);
		nextPut: $).
	^writeStream contents! !

!JdmMysqlTestSupport methodsFor: 'private-values'!

charValue
	^[:type :support | 'Z' ]!

dateTimeValue
	^
	[:type :support | 
	JdmDateTime fromDate: (support dateValue value: #date value: support)
		andTime: (support timeValue value: #time value: support)]!

dateValue
	^[:type :support | Date fromDays: (support nextRandomFor: type)]!

doubleValue
	^[:type :support | 1.7976931348623d308 ]!

enumValue
	^[:type :support | support enumSetValues at: (support nextRandomFor: type)]!

floatValue
	^[:type :support | 3.402823466e38 ]!

intValue
	^[:type :support | support nextRandomFor: type]!

null
	^[:type :support | 'NULL' ]!

stringValue
	^[:type :support | 'This is a String with UPPER and lower CaSeS' ]!

timestampValue
	^[:type :support | DateTime now]!

timeValue
	^[:type :support | Time fromSeconds: (support nextRandomFor: type)]! !

!JdmMysqlTestSupport methodsFor: 'private-initialize'!

initializeEnumSetValues
	enumSetValues add: 'Apples'.
	enumSetValues add: 'Bananas'.
	enumSetValues add: 'Grapes'.
	enumSetValues add: 'Oranges'.
	enumSetValues add: 'Peaches'.!

initializeMysqlTypes
	mysqlTypes
		at: #tinyInt put: 'TINYINT';
		at: #tinyIntUnsigned put: 'TINYINT UNSIGNED';
		at: #tinyIntZerofill put: 'TINYINT ZEROFILL';
		at: #tinyIntUnsignedZerofill put: 'TINYINT UNSIGNED ZEROFILL';

		at: #smallInt put: 'SMALLINT';
		at: #smallIntUnsigned put: 'SMALLINT UNSIGNED';
		at: #smallIntZerofill put: 'SMALLINT ZEROFILL';
		at: #smallIntUnsignedZerofill put: 'SMALLINT UNSIGNED ZEROFILL';

		at: #mediumInt put: 'MEDIUMINT';
		at: #mediumIntUnsigned put: 'MEDIUMINT UNSIGNED';
		at: #mediumIntZerofill put: 'MEDIUMINT ZEROFILL';
		at: #mediumIntUnsignedZerofill put: 'MEDIUMINT UNSIGNED ZEROFILL';

		at: #int put: 'INT';
		at: #intUnsigned put: 'INT UNSIGNED';
		at: #intZerofill put: 'INT ZEROFILL';
		at: #intUnsignedZerofill put: 'INT UNSIGNED ZEROFILL';

		at: #bigInt put: 'BIGINT';
		at: #bigIntUnsigned put: 'BIGINT UNSIGNED';
		at: #bigIntZerofill put: 'BIGINT ZEROFILL';
		at: #bigIntUnsignedZerofill put: 'BIGINT UNSIGNED ZEROFILL';

		at: #float put: 'FLOAT(4)';
		at: #double put: 'FLOAT(8)';
		at: #decimal put: 'DECIMAL(10, 5)';
		at: #date put: 'DATE';
		at: #time put: 'TIME';
		at: #dateTime put: 'DATETIME';
		at: #timestamp put: 'TIMESTAMP';
		at: #char put: 'CHAR';
		at: #varChar put: 'VARCHAR(70)';
		at: #tinyBlob put: 'TINYBLOB';
		at: #blob put: 'BLOB';
		at: #mediumBlob put: 'MEDIUMBLOB';
		at: #longBlob put: 'LONGBLOB';
		at: #tinyText put: 'TINYTEXT';
		at: #text put: 'TEXT';
		at: #mediumText put: 'MEDIUMTEXT';
		at: #enum put: 'ENUM(', self enumValues, ')';		
		at: #set put: 'SET(', self enumValues, ')'!

initializeMysqlValues
	mysqlValues
		at: #tinyInt put: #intValue;
		at: #tinyIntUnsigned put: #intValue;
		at: #tinyIntZerofill put: #intValue;
		at: #tinyIntUnsignedZerofill put: #intValue;

		at: #smallInt put: #intValue;
		at: #smallIntUnsigned put: #intValue;
		at: #smallIntZerofill put: #intValue;
		at: #smallIntUnsignedZerofill put: #intValue;

		at: #mediumInt put: #intValue;
		at: #mediumIntUnsigned put: #intValue;
		at: #mediumIntZerofill put: #intValue;
		at: #mediumIntUnsignedZerofill put: #intValue;

		at: #int put: #intValue;
		at: #intUnsigned put: #intValue;
		at: #intZerofill put: #intValue;
		at: #intUnsignedZerofill put: #intValue;

		at: #bigInt put: #intValue;
		at: #bigIntUnsigned put: #intValue;
		at: #bigIntZerofill put: #intValue;
		at: #bigIntUnsignedZerofill put: #intValue;

		at: #float put: #floatValue;
		at: #double put: #doubleValue;
		at: #decimal put: #doubleValue;
		at: #date put: #dateValue;
		at: #time put: #timeValue;
		at: #timestamp put: #timestampValue;
		at: #dateTime put: #dateTimeValue;
		at: #char put: #charValue;
		at: #varChar put: #stringValue;
		at: #tinyBlob put: #stringValue;
		at: #blob put: #stringValue;
		at: #mediumBlob put: #stringValue;
		at: #longBlob put: #stringValue;
		at: #tinyText put: #stringValue;
		at: #text put: #stringValue;
		at: #mediumText put: #stringValue;
		at: #enum put: #enumValue;		
		at: #set put: #enumValue!

initializeRandomGenerators
	randomGenerators
		at: #tinyInt put: (JdmRangedRandom between: -128 and: 127);
		at: #tinyIntUnsigned put: (JdmRangedRandom between: 0 and: 255);
		at: #tinyIntZerofill put: (randomGenerators at: #tinyInt);
		at: #tinyIntUnsignedZerofill
			put: (randomGenerators at: #tinyIntUnsigned);

		at: #smallInt put: (JdmRangedRandom between: -32768 and: 32767);
		at: #smallIntUnsigned put: (JdmRangedRandom between: 0 and: 65535);
		at: #smallIntZerofill put: (randomGenerators at: #smallInt);
		at: #smallIntUnsignedZerofill put: (randomGenerators at: #smallIntUnsigned);

		at: #mediumInt put: (JdmRangedRandom between: -8388608 and: 8388607);
		at: #mediumIntUnsigned put: (JdmRangedRandom between: 0 and: 16777215);
		at: #mediumIntZerofill put: (randomGenerators at: #mediumInt);
		at: #mediumIntUnsignedZerofill put: (randomGenerators at: #mediumIntUnsigned);

		at: #int put: (JdmRangedRandom between: -2147483648 and: 2147483647);
		at: #intUnsigned put: (JdmRangedRandom between: 0 and: 4294967295);
		at: #intZerofill put: (randomGenerators at: #int);
		at: #intUnsignedZerofill put: (randomGenerators at: #intUnsigned);

		at: #bigInt put: (JdmRangedRandom between: -9223372036854775808 and: 9223372036854775807);
		at: #bigIntUnsigned put: (JdmRangedRandom between: 0 and:  18446744073709551615);
		at: #bigIntZerofill put: (randomGenerators at: #bigInt);
		at: #bigIntUnsignedZerofill put: (randomGenerators at: #bigIntUnsigned);

		at: #date put: (JdmRangedRandom between: -329083 and:  2958098);
		at: #time put: (JdmRangedRandom between: 0 and: 86399);
		at: #enum put: (JdmRangedRandom between: 1 and: 5);
		at: #set put: (randomGenerators at: #enum)! !

!JdmMysqlTestSupport methodsFor: 'initialize-release'!

initialize
	randomGenerators := IdentityDictionary new.
	mysqlValues := IdentityDictionary new.
	enumSetValues := OrderedCollection new.
	mysqlTypes := IdentityDictionary new.
	self
		initializeEnumSetValues;
		initializeRandomGenerators;
		initializeMysqlValues;
		initializeMysqlTypes! !


!JdmMysqlTestSupport class methodsFor: 'singleton'!

mysqlTestSupport
	Instance isNil ifTrue: [Instance := self new initialize].
	^Instance!

resetMysqlTestSupport
	Instance := nil! !

!JdmMysqlTestSupport class methodsFor: 'constants'!

numRowsToInsert
	^500!

tableName
	^'JdmMysqlTestTable'! !

!JdmRangedRandom methodsFor: 'initialize'!

between: anInteger and: anInteger2 
	random := Random new.
	highValue := anInteger max: anInteger2.
	lowValue := anInteger min: anInteger2.
	range := highValue - lowValue.
	range > 0 ifTrue: [range := range + 1].
	numRandomBits := self randomBitsNeededFor: range! !

!JdmRangedRandom methodsFor: 'accessing'!

next
	| aRandom |
	aRandom := self nextRandom \\ range.
	aRandom = 0 ifTrue: [(self rangeIncludes: 0) ifFalse: [^self next]].
	^lowValue + aRandom! !

!JdmRangedRandom methodsFor: 'private'!

maskFor: numBits 
	^(self class randomMask bitShift: numBits - self class randomBits) 
		bitAnd: self class randomMask!

nextRandom
	| nextRandom numBits numBitsToUse |
	nextRandom := 0.
	numBits := numRandomBits.
	[numBits = 0] whileFalse: 
			[numBitsToUse := numBits min: self class randomBits.
			nextRandom := (nextRandom bitShift: numBitsToUse) 
						bitOr: ((random next * self class randomFactor) asInteger 
								bitAnd: (self maskFor: numBitsToUse)).
			numBits := numBits - numBitsToUse].
	^nextRandom!

randomBitsNeededFor: anInteger 
	| numBits |
	numBits := (anInteger log: 2) ceiling.
	(1 bitShift: numBits) < anInteger ifTrue: [numBits := numBits + 1].
	^numBits!

rangeIncludes: aValue
	^(highValue >= aValue and: [lowValue <= aValue])! !


!JdmRangedRandom class methodsFor: 'constants'!

randomBits
	^16!

randomFactor
	^1000000!

randomMask
	^16rFFFF! !

!JdmRangedRandom class methodsFor: 'instance creation'!

between: anInteger and: anInteger2
	^self new between: anInteger and: anInteger2! !

!JdmTestProgress methodsFor: 'initialize-release'!

initialize: aNumSteps
	numSteps := aNumSteps.
	totalSteps := 0.
	resolution := self class defaultResolution.
	stepsPerLevel := numSteps // resolution.
	currentStep := 0.
	displayCharacter := self class defaultDisplayCharacter! !

!JdmTestProgress methodsFor: 'private'!

checkSteps
	currentStep >= stepsPerLevel
		ifTrue: 
			[currentStep := 0.
			Transcript
				nextPut: displayCharacter;
				flush].
	totalSteps = numSteps 
		ifTrue: 
			[Transcript
				show: ' Done']! !

!JdmTestProgress methodsFor: 'accessing'!

currentStep
	^currentStep!

displayCharacter
	^displayCharacter!

displayCharacter: anObject
	displayCharacter := anObject!

nextStep
	currentStep := currentStep + 1.
	totalSteps := totalSteps + 1.
	self checkSteps!

numSteps
	^numSteps!

resolution
	^resolution!

stepsPerLevel
	^stepsPerLevel!

totalSteps
	^totalSteps! !


!JdmTestProgress class methodsFor: 'instance creation'!

new: aNumSteps
	^self new initialize: aNumSteps! !

!JdmTestProgress class methodsFor: 'defaults'!

defaultDisplayCharacter
	^$.!

defaultResolution
	^20! !

!JdmMysqlTestSuite methodsFor: 'initialize-release'!

initialize
"	super initialize."
	self name: 'JdmMysql-Test'.
	self addTest: (JdmMysqlCreateTableTestCase selector: #createTable).
	self addTest: (JdmMysqlInsertTestCase selector: #insertRows).
	self addTest: (JdmMysqlSelectTestCase selector: #selectRows).
	self addTest: (JdmMysqlDeleteTestCase selector: #deleteRows).
	self addTest: (JdmMysqlDropTableTestCase selector: #dropTable).
	Transcript nl! !

!JdmMysqlTestSuite class methodsFor: 'instance creation'!

new
	^super new initialize! !

!JdmMysqlTestSupport methodsFor: 'private'!

createDelimitedStringFor: aCollection delimiter: aDelimiter using: aBlock 
	| collection writeStream |
	collection := aCollection asOrderedCollection.
	collection size = 0 ifTrue: [^''].
	writeStream := WriteStream on: String new.
	writeStream nextPutAll: (aBlock value: collection first).
	2 to: collection size
		do: 
			[:index | 
			writeStream
				nextPutAll: aDelimiter;
				nextPutAll: (aBlock value: (collection at: index))].
	^writeStream contents!

enumSetValues
	^enumSetValues!

enumValues
	^self 
		createDelimitedStringFor: self enumSetValues
		delimiter: ', '
		using: [:enumValue | '''' , enumValue , '''']!

fieldNameFor: aType 
	^'Jdm' , aType!

getFieldDefinitionFor: aType 
	| writeStream |
	writeStream := WriteStream on: String new.
	self writeFieldDefinitionFor: aType on: writeStream.
	^writeStream contents!

nextRandomFor: aType
	^(randomGenerators at: aType) next!

writeFieldDefinitionFor: aType on: aWriteStream 
	aWriteStream
		nextPutAll: (self fieldNameFor: aType);
		nextPut: $ ;
		nextPutAll: (mysqlTypes at: aType)! !

!JdmMysqlTestSupport methodsFor: 'accessing'!

createTable
	^self createTableNamed: self class tableName!

createTableNamed: aName 
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: 'CREATE TABLE ';
		nextPutAll: aName;
		nextPut: $(;
		nl.
	writeStream nextPutAll: (self 
				createDelimitedStringFor: mysqlTypes keys
				delimiter: ', '
				using: [:field | self getFieldDefinitionFor: field]).
	^writeStream
		nextPut: $);
		contents!

insertIntoTable
	^self insertIntoTableNamed: self class tableName!

insertIntoTableNamed: aName 
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: 'INSERT INTO ';
		nextPutAll: aName;
		nextPutAll: ' (';
		nl.
	writeStream nextPutAll: (self 
				createDelimitedStringFor: mysqlTypes keys
				delimiter: ', '
				using: [:field | self fieldNameFor: field]).
	writeStream
		nextPutAll: ') VALUES (';
		nl.
	writeStream
		nextPutAll: (self 
					createDelimitedStringFor: mysqlTypes keys
					delimiter: ', '
					using: 
						[:type | 
						| valueSelector |
						valueSelector := mysqlValues at: type ifAbsent: #null.
						JdmFieldConverter fieldConverter 
							convertToMysql: ((self perform: valueSelector) value: type value: self)]);
		nextPut: $).
	^writeStream contents! !

!JdmMysqlTestSupport methodsFor: 'private-values'!

charValue
	^[:type :support | 'Z' ]!

dateTimeValue
	^
	[:type :support | 
	JdmDateTime fromDate: (support dateValue value: #date value: support)
		andTime: (support timeValue value: #time value: support)]!

dateValue
	^[:type :support | Date fromDays: (support nextRandomFor: type)]!

doubleValue
	^[:type :support | 1.7976931348623d308 ]!

enumValue
	^[:type :support | support enumSetValues at: (support nextRandomFor: type)]!

floatValue
	^[:type :support | 3.402823466e38 ]!

intValue
	^[:type :support | support nextRandomFor: type]!

null
	^[:type :support | 'NULL' ]!

stringValue
	^[:type :support | 'This is a String with UPPER and lower CaSeS' ]!

timestampValue
	^[:type :support | DateTime now]!

timeValue
	^[:type :support | Time fromSeconds: (support nextRandomFor: type)]! !

!JdmMysqlTestSupport methodsFor: 'private-initialize'!

initializeEnumSetValues
	enumSetValues add: 'Apples'.
	enumSetValues add: 'Bananas'.
	enumSetValues add: 'Grapes'.
	enumSetValues add: 'Oranges'.
	enumSetValues add: 'Peaches'.!

initializeMysqlTypes
	mysqlTypes
		at: #tinyInt put: 'TINYINT';
		at: #tinyIntUnsigned put: 'TINYINT UNSIGNED';
		at: #tinyIntZerofill put: 'TINYINT ZEROFILL';
		at: #tinyIntUnsignedZerofill put: 'TINYINT UNSIGNED ZEROFILL';

		at: #smallInt put: 'SMALLINT';
		at: #smallIntUnsigned put: 'SMALLINT UNSIGNED';
		at: #smallIntZerofill put: 'SMALLINT ZEROFILL';
		at: #smallIntUnsignedZerofill put: 'SMALLINT UNSIGNED ZEROFILL';

		at: #mediumInt put: 'MEDIUMINT';
		at: #mediumIntUnsigned put: 'MEDIUMINT UNSIGNED';
		at: #mediumIntZerofill put: 'MEDIUMINT ZEROFILL';
		at: #mediumIntUnsignedZerofill put: 'MEDIUMINT UNSIGNED ZEROFILL';

		at: #int put: 'INT';
		at: #intUnsigned put: 'INT UNSIGNED';
		at: #intZerofill put: 'INT ZEROFILL';
		at: #intUnsignedZerofill put: 'INT UNSIGNED ZEROFILL';

		at: #bigInt put: 'BIGINT';
		at: #bigIntUnsigned put: 'BIGINT UNSIGNED';
		at: #bigIntZerofill put: 'BIGINT ZEROFILL';
		at: #bigIntUnsignedZerofill put: 'BIGINT UNSIGNED ZEROFILL';

		at: #float put: 'FLOAT(4)';
		at: #double put: 'FLOAT(8)';
		at: #decimal put: 'DECIMAL(10, 5)';
		at: #date put: 'DATE';
		at: #time put: 'TIME';
		at: #dateTime put: 'DATETIME';
		at: #timestamp put: 'TIMESTAMP';
		at: #char put: 'CHAR';
		at: #varChar put: 'VARCHAR(70)';
		at: #tinyBlob put: 'TINYBLOB';
		at: #blob put: 'BLOB';
		at: #mediumBlob put: 'MEDIUMBLOB';
		at: #longBlob put: 'LONGBLOB';
		at: #tinyText put: 'TINYTEXT';
		at: #text put: 'TEXT';
		at: #mediumText put: 'MEDIUMTEXT';
		at: #enum put: 'ENUM(', self enumValues, ')';		
		at: #set put: 'SET(', self enumValues, ')'!

initializeMysqlValues
	mysqlValues
		at: #tinyInt put: #intValue;
		at: #tinyIntUnsigned put: #intValue;
		at: #tinyIntZerofill put: #intValue;
		at: #tinyIntUnsignedZerofill put: #intValue;

		at: #smallInt put: #intValue;
		at: #smallIntUnsigned put: #intValue;
		at: #smallIntZerofill put: #intValue;
		at: #smallIntUnsignedZerofill put: #intValue;

		at: #mediumInt put: #intValue;
		at: #mediumIntUnsigned put: #intValue;
		at: #mediumIntZerofill put: #intValue;
		at: #mediumIntUnsignedZerofill put: #intValue;

		at: #int put: #intValue;
		at: #intUnsigned put: #intValue;
		at: #intZerofill put: #intValue;
		at: #intUnsignedZerofill put: #intValue;

		at: #bigInt put: #intValue;
		at: #bigIntUnsigned put: #intValue;
		at: #bigIntZerofill put: #intValue;
		at: #bigIntUnsignedZerofill put: #intValue;

		at: #float put: #floatValue;
		at: #double put: #doubleValue;
		at: #decimal put: #doubleValue;
		at: #date put: #dateValue;
		at: #time put: #timeValue;
		at: #timestamp put: #timestampValue;
		at: #dateTime put: #dateTimeValue;
		at: #char put: #charValue;
		at: #varChar put: #stringValue;
		at: #tinyBlob put: #stringValue;
		at: #blob put: #stringValue;
		at: #mediumBlob put: #stringValue;
		at: #longBlob put: #stringValue;
		at: #tinyText put: #stringValue;
		at: #text put: #stringValue;
		at: #mediumText put: #stringValue;
		at: #enum put: #enumValue;		
		at: #set put: #enumValue!

initializeRandomGenerators
	randomGenerators
		at: #tinyInt put: (JdmRangedRandom between: -128 and: 127);
		at: #tinyIntUnsigned put: (JdmRangedRandom between: 0 and: 255);
		at: #tinyIntZerofill put: (randomGenerators at: #tinyInt);
		at: #tinyIntUnsignedZerofill
			put: (randomGenerators at: #tinyIntUnsigned);

		at: #smallInt put: (JdmRangedRandom between: -32768 and: 32767);
		at: #smallIntUnsigned put: (JdmRangedRandom between: 0 and: 65535);
		at: #smallIntZerofill put: (randomGenerators at: #smallInt);
		at: #smallIntUnsignedZerofill put: (randomGenerators at: #smallIntUnsigned);

		at: #mediumInt put: (JdmRangedRandom between: -8388608 and: 8388607);
		at: #mediumIntUnsigned put: (JdmRangedRandom between: 0 and: 16777215);
		at: #mediumIntZerofill put: (randomGenerators at: #mediumInt);
		at: #mediumIntUnsignedZerofill put: (randomGenerators at: #mediumIntUnsigned);

		at: #int put: (JdmRangedRandom between: -2147483648 and: 2147483647);
		at: #intUnsigned put: (JdmRangedRandom between: 0 and: 4294967295);
		at: #intZerofill put: (randomGenerators at: #int);
		at: #intUnsignedZerofill put: (randomGenerators at: #intUnsigned);

		at: #bigInt put: (JdmRangedRandom between: -9223372036854775808 and: 9223372036854775807);
		at: #bigIntUnsigned put: (JdmRangedRandom between: 0 and:  18446744073709551615);
		at: #bigIntZerofill put: (randomGenerators at: #bigInt);
		at: #bigIntUnsignedZerofill put: (randomGenerators at: #bigIntUnsigned);

		at: #date put: (JdmRangedRandom between: -329083 and:  2958098);
		at: #time put: (JdmRangedRandom between: 0 and: 86399);
		at: #enum put: (JdmRangedRandom between: 1 and: 5);
		at: #set put: (randomGenerators at: #enum)! !

!JdmMysqlTestSupport methodsFor: 'initialize-release'!

initialize
	randomGenerators := IdentityDictionary new.
	mysqlValues := IdentityDictionary new.
	enumSetValues := OrderedCollection new.
	mysqlTypes := IdentityDictionary new.
	self
		initializeEnumSetValues;
		initializeRandomGenerators;
		initializeMysqlValues;
		initializeMysqlTypes! !


!JdmMysqlTestSupport class methodsFor: 'singleton'!

mysqlTestSupport
	Instance isNil ifTrue: [Instance := self new initialize].
	^Instance!

resetMysqlTestSupport
	Instance := nil! !

!JdmMysqlTestSupport class methodsFor: 'constants'!

numRowsToInsert
	^500!

tableName
	^'JdmMysqlTestTable'! !

Namespace current: Smalltalk!


