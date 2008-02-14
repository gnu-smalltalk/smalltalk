"=====================================================================
|
|   MySQL DBI driver unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Paolo Bonzini
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



TestCase subclass: DBIMySQLBaseTestCase [
    | connection testSupport testProgress |
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    setUp [
	<category: 'initialize-release'>
	super setUp.
	testSupport := DBIMySQLTestSupport mysqlTestSupport.
	connection := testSupport connect.
	testProgress := TestProgress new: testSupport class numRowsToInsert.
	testProgress
    ]

    tearDown [
	<category: 'initialize-release'>
	connection close
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLCreateTableTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    createTable [
	<category: 'tests'>
	| result |
	Transcript show: 'Creating table: ' , testSupport class tableName , '...'.
	result := connection do: testSupport createTable.
	Transcript
	    show: ' Done';
	    nl.
	self should: [result isSelect not and: [result rowsAffected = 0]]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLDropTableTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    dropTableIfExists [
	<category: 'tests'>
	| result |
	Transcript show: 'Dropping table: ' , testSupport class tableName , '...'.
	result := connection 
		    do: 'drop table if exists ' , testSupport class tableName.
	Transcript
	    show: ' Done';
	    nl.
	self should: [result isSelect not and: [result rowsAffected = 0]]
    ]

    dropTable [
	<category: 'tests'>
	| result |
	Transcript show: 'Dropping table: ' , testSupport class tableName , '...'.
	result := connection do: 'drop table ' , testSupport class tableName.
	Transcript
	    show: ' Done';
	    nl.
	self should: [result isSelect not and: [result rowsAffected = 0]]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLDeleteTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    deleteRows [
	<category: 'tests'>
	| result |
	Transcript 
	    show: 'Deleting ' , testSupport class numRowsToInsert printString 
		    , ' rows...'.
	result := connection do: 'delete from ' , testSupport class tableName.
	Transcript
	    show: ' Done';
	    nl.
	"Value is either 0 or numRowsToInsert, depending on the version"
	self should: [result isSelect not]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLInsertTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    insertRow [
	<category: 'tests'>
	| result |
	result := connection do: testSupport insertIntoTable.
	testProgress nextStep.
	^result
    ]

    insertRows [
	<category: 'tests'>
	| ok result |
	Transcript 
	    show: 'Inserting ' , testSupport class numRowsToInsert printString 
		    , ' rows'.
	ok := true.
	testSupport class numRowsToInsert timesRepeat: 
		[result := self insertRow.
		ok := ok and: [result isSelect not	"and: [result rowsAffected = 1]"]].
	self should: [ok]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLSelectTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    checkResult: resultSet [
	<category: 'tests'>
	| count numColumns row |
	count := 0.
	numColumns := resultSet columns size.
	[resultSet atEnd] whileFalse: 
		[row := resultSet next.
		1 to: numColumns do: [:columnNum | (row atIndex: columnNum) printString].
		count := count + 1.
		testProgress nextStep].
	^count
    ]

    selectRows [
	<category: 'tests'>
	| result |
	Transcript 
	    show: 'Selecting ' , testSupport class numRowsToInsert printString 
		    , ' rows'.
	result := connection 
		    select: 'select * from ' , testSupport class tableName.
	self should: 
		[result isSelect 
		    and: [(self checkResult: result) = testSupport class numRowsToInsert]]
    ]
]



Object subclass: RangedRandom [
    | random highValue lowValue range numRandomBits |
    
    <category: 'Mysql-Driver-Tests'>
    <comment: nil>

    RangedRandom class >> randomBits [
	<category: 'constants'>
	^16
    ]

    RangedRandom class >> randomFactor [
	<category: 'constants'>
	^1000000
    ]

    RangedRandom class >> randomMask [
	<category: 'constants'>
	^65535
    ]

    RangedRandom class >> between: anInteger and: anInteger2 [
	<category: 'instance creation'>
	^self new between: anInteger and: anInteger2
    ]

    between: anInteger and: anInteger2 [
	<category: 'initialize'>
	random := Random new.
	highValue := anInteger max: anInteger2.
	lowValue := anInteger min: anInteger2.
	range := highValue - lowValue.
	range > 0 ifTrue: [range := range + 1].
	numRandomBits := self randomBitsNeededFor: range
    ]

    next [
	<category: 'accessing'>
	| aRandom |
	aRandom := self nextRandom \\ range.
	aRandom = 0 ifTrue: [(self rangeIncludes: 0) ifFalse: [^self next]].
	^lowValue + aRandom
    ]

    maskFor: numBits [
	<category: 'private'>
	^(self class randomMask bitShift: numBits - self class randomBits) 
	    bitAnd: self class randomMask
    ]

    nextRandom [
	<category: 'private'>
	| nextRandom numBits numBitsToUse |
	nextRandom := 0.
	numBits := numRandomBits.
	[numBits = 0] whileFalse: 
		[numBitsToUse := numBits min: self class randomBits.
		nextRandom := (nextRandom bitShift: numBitsToUse) 
			    bitOr: ((random next * self class randomFactor) asInteger 
				    bitAnd: (self maskFor: numBitsToUse)).
		numBits := numBits - numBitsToUse].
	^nextRandom
    ]

    randomBitsNeededFor: anInteger [
	<category: 'private'>
	| numBits |
	numBits := (anInteger log: 2) ceiling.
	(1 bitShift: numBits) < anInteger ifTrue: [numBits := numBits + 1].
	^numBits
    ]

    rangeIncludes: aValue [
	<category: 'private'>
	^highValue >= aValue and: [lowValue <= aValue]
    ]
]



Object subclass: TestProgress [
    | resolution totalSteps numSteps stepsPerLevel currentStep displayCharacter |
    
    <category: 'Mysql-Driver-Tests'>
    <comment: nil>

    TestProgress class >> new: aNumSteps [
	<category: 'instance creation'>
	^self new initialize: aNumSteps
    ]

    TestProgress class >> defaultDisplayCharacter [
	<category: 'defaults'>
	^$.
    ]

    TestProgress class >> defaultResolution [
	<category: 'defaults'>
	^20
    ]

    initialize: aNumSteps [
	<category: 'initialize-release'>
	numSteps := aNumSteps.
	totalSteps := 0.
	resolution := self class defaultResolution.
	stepsPerLevel := numSteps // resolution.
	currentStep := 0.
	displayCharacter := self class defaultDisplayCharacter
    ]

    checkSteps [
	<category: 'private'>
	currentStep >= stepsPerLevel 
	    ifTrue: 
		[currentStep := 0.
		Transcript
		    nextPut: displayCharacter;
		    flush].
	totalSteps = numSteps 
	    ifTrue: 
		[Transcript
		    show: ' Done';
		    nl]
    ]

    currentStep [
	<category: 'accessing'>
	^currentStep
    ]

    displayCharacter [
	<category: 'accessing'>
	^displayCharacter
    ]

    displayCharacter: anObject [
	<category: 'accessing'>
	displayCharacter := anObject
    ]

    nextStep [
	<category: 'accessing'>
	currentStep := currentStep + 1.
	totalSteps := totalSteps + 1.
	self checkSteps
    ]

    numSteps [
	<category: 'accessing'>
	^numSteps
    ]

    resolution [
	<category: 'accessing'>
	^resolution
    ]

    stepsPerLevel [
	<category: 'accessing'>
	^stepsPerLevel
    ]

    totalSteps [
	<category: 'accessing'>
	^totalSteps
    ]
]



TestSuite subclass: DBIMySQLTestSuite [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    DBIMySQLTestSuite class >> suite [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	"super initialize."

	<category: 'initialize-release'>
	self name: 'DBIMySQL-Test'.
	self addTest: (DBIMySQLDropTableTestCase selector: #dropTableIfExists).
	self addTest: (DBIMySQLCreateTableTestCase selector: #createTable).
	self addTest: (DBIMySQLInsertTestCase selector: #insertRows).
	self addTest: (DBIMySQLSelectTestCase selector: #selectRows).
	self addTest: (DBIMySQLDeleteTestCase selector: #deleteRows).
	self addTest: (DBIMySQLDropTableTestCase selector: #dropTable).
	Transcript nl
    ]
]



Object subclass: DBIMySQLTestSupport [
    | randomGenerators mysqlTypes mysqlValues enumSetValues |
    
    <category: 'Mysql-Driver-Tests'>
    <comment: nil>

    Instance := nil.

    DBIMySQLTestSupport class >> mysqlTestSupport [
	<category: 'singleton'>
	Instance isNil ifTrue: [Instance := self new initialize].
	^Instance
    ]

    DBIMySQLTestSupport class >> resetMysqlTestSupport [
	<category: 'singleton'>
	Instance := nil
    ]

    DBIMySQLTestSupport class >> numRowsToInsert [
	<category: 'constants'>
	^40
    ]

    DBIMySQLTestSupport class >> tableName [
	<category: 'constants'>
	^'DBIMySQLTestTable'
    ]

    createDelimitedStringFor: aCollection delimiter: aDelimiter using: aBlock [
	<category: 'private'>
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
	^writeStream contents
    ]

    enumSetValues [
	<category: 'private'>
	^enumSetValues
    ]

    enumValues [
	<category: 'private'>
	^self 
	    createDelimitedStringFor: self enumSetValues
	    delimiter: ', '
	    using: [:enumValue | '''' , enumValue , '''']
    ]

    fieldNameFor: aType [
	<category: 'private'>
	^'test_' , aType
    ]

    getFieldDefinitionFor: aType [
	<category: 'private'>
	| writeStream |
	writeStream := WriteStream on: String new.
	self writeFieldDefinitionFor: aType on: writeStream.
	^writeStream contents
    ]

    nextRandomFor: aType [
	<category: 'private'>
	^(randomGenerators at: aType) next
    ]

    writeFieldDefinitionFor: aType on: aWriteStream [
	<category: 'private'>
	aWriteStream
	    nextPutAll: (self fieldNameFor: aType);
	    nextPut: $ ;
	    nextPutAll: (mysqlTypes at: aType)
    ]

    connect [
	<category: 'accessing'>
	| user password db isUser |
	user := TestSuitesScripter variableAt: 'mysqluser' ifAbsent: [nil].
	isUser := user notNil.
	isUser ifFalse: [user := 'root'].
	password := TestSuitesScripter variableAt: 'mysqlpassword'
		    ifAbsent: [isUser ifTrue: [nil] ifFalse: ['root']].
	db := TestSuitesScripter variableAt: 'mysqldb' ifAbsent: ['test'].
	^DBI.Connection 
	    connect: 'dbi:MySQL:dbname=' , db
	    user: user
	    password: password
    ]

    createTable [
	<category: 'accessing'>
	^self createTableNamed: self class tableName
    ]

    createTableNamed: aName [
	<category: 'accessing'>
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
	    contents
    ]

    insertIntoTable [
	<category: 'accessing'>
	^self insertIntoTableNamed: self class tableName
    ]

    insertIntoTableNamed: aName [
	<category: 'accessing'>
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
			    DBI.FieldConverter uniqueInstance
				printString: ((self perform: valueSelector) value: type value: self)]);
	    nextPut: $).
	^writeStream contents
    ]

    charValue [
	<category: 'private-values'>
	^[:type :support | 'Z']
    ]

    dateTimeValue [
	<category: 'private-values'>
	^
	[:type :support | 
	DateTime 
	    fromDays: (support dateValue value: #date value: support) days
	    seconds: (support timeValue value: #time value: support) seconds
	    offset: Duration zero]
    ]

    dateValue [
	<category: 'private-values'>
	^[:type :support | Date fromDays: (support nextRandomFor: type)]
    ]

    doubleValue [
	<category: 'private-values'>
	^[:type :support | 1.7976931348623d308]
    ]

    enumValue [
	<category: 'private-values'>
	^[:type :support | support enumSetValues at: (support nextRandomFor: type)]
    ]

    floatValue [
	<category: 'private-values'>
	^[:type :support | 3.4028235e38]
    ]

    intValue [
	<category: 'private-values'>
	^[:type :support | support nextRandomFor: type]
    ]

    null [
	<category: 'private-values'>
	^[:type :support | 'NULL']
    ]

    stringValue [
	<category: 'private-values'>
	^[:type :support | 'This is a String with UPPER and lower CaSeS']
    ]

    timestampValue [
	<category: 'private-values'>
	^[:type :support | DateTime now]
    ]

    timeValue [
	<category: 'private-values'>
	^[:type :support | Time fromSeconds: (support nextRandomFor: type)]
    ]

    initializeEnumSetValues [
	<category: 'private-initialize'>
	enumSetValues add: 'Apples'.
	enumSetValues add: 'Bananas'.
	enumSetValues add: 'Grapes'.
	enumSetValues add: 'Oranges'.
	enumSetValues add: 'Peaches'
    ]

    initializeMysqlTypes [
	<category: 'private-initialize'>
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
	    at: #enum put: 'ENUM(' , self enumValues , ')';
	    at: #set put: 'SET(' , self enumValues , ')'
    ]

    initializeMysqlValues [
	<category: 'private-initialize'>
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
	    at: #set put: #enumValue
    ]

    initializeRandomGenerators [
	<category: 'private-initialize'>
	randomGenerators
	    at: #tinyInt put: (RangedRandom between: -128 and: 127);
	    at: #tinyIntUnsigned put: (RangedRandom between: 0 and: 255);
	    at: #tinyIntZerofill put: (randomGenerators at: #tinyInt);
	    at: #tinyIntUnsignedZerofill put: (randomGenerators at: #tinyIntUnsigned);
	    at: #smallInt put: (RangedRandom between: -32768 and: 32767);
	    at: #smallIntUnsigned put: (RangedRandom between: 0 and: 65535);
	    at: #smallIntZerofill put: (randomGenerators at: #smallInt);
	    at: #smallIntUnsignedZerofill put: (randomGenerators at: #smallIntUnsigned);
	    at: #mediumInt put: (RangedRandom between: -8388608 and: 8388607);
	    at: #mediumIntUnsigned put: (RangedRandom between: 0 and: 16777215);
	    at: #mediumIntZerofill put: (randomGenerators at: #mediumInt);
	    at: #mediumIntUnsignedZerofill
		put: (randomGenerators at: #mediumIntUnsigned);
	    at: #int put: (RangedRandom between: -2147483648 and: 2147483647);
	    at: #intUnsigned put: (RangedRandom between: 0 and: 4294967295);
	    at: #intZerofill put: (randomGenerators at: #int);
	    at: #intUnsignedZerofill put: (randomGenerators at: #intUnsigned);
	    at: #bigInt
		put: (RangedRandom between: -9223372036854775808 and: 9223372036854775807);
	    at: #bigIntUnsigned
		put: (RangedRandom between: 0 and: 18446744073709551615);
	    at: #bigIntZerofill put: (randomGenerators at: #bigInt);
	    at: #bigIntUnsignedZerofill put: (randomGenerators at: #bigIntUnsigned);
	    at: #date put: (RangedRandom between: -329083 and: 2958098);
	    at: #time put: (RangedRandom between: 0 and: 86399);
	    at: #enum put: (RangedRandom between: 1 and: 5);
	    at: #set put: (randomGenerators at: #enum)
    ]

    initialize [
	<category: 'initialize-release'>
	randomGenerators := IdentityDictionary new.
	mysqlValues := IdentityDictionary new.
	enumSetValues := OrderedCollection new.
	mysqlTypes := IdentityDictionary new.
	self
	    initializeEnumSetValues;
	    initializeRandomGenerators;
	    initializeMysqlValues;
	    initializeMysqlTypes
    ]
]

