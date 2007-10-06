Eval [
    'From VisualWorks®, Pre-Release 7 of June 3, 2002 on August 23, 2002 at 9:50:56 pm'
]



DatabasePlatform subclass: MySQLPlatform [
    
    <comment: nil>
    <category: 'Glorp-MySQL'>

    NewTableType := nil.

    MySQLPlatform class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2003 Free Software Foundation, Inc.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License (LGPL), WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.LIB file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    MySQLPlatform class >> defaultNewTableType [
	<category: 'accessing'>
	^'InnoDB'
    ]

    MySQLPlatform class >> newTableType [
	<category: 'accessing'>
	NewTableType isNil ifTrue: [NewTableType := self defaultNewTableType].
	^NewTableType
    ]

    MySQLPlatform class >> newTableType: aString [
	<category: 'accessing'>
	NewTableType := aString
    ]

    printDate: aDate for: aType [
	"Print a date (or timestamp) as yyyy-mm-dd"

	<category: 'converters'>
	| stream |
	aDate isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	stream nextPut: $'.
	self printDate: aDate isoFormatOn: stream.
	stream nextPut: $'.
	^stream contents
    ]

    printTime: aTime for: aType [
	"Print a time (or timestamp) as hh:mm:ss.fff"

	<category: 'converters'>
	| stream |
	aTime isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	stream nextPut: $'.
	self printTime: aTime isoFormatOn: stream.
	stream nextPut: $'.
	^stream contents
    ]

    printTimestamp: aTimestamp for: aType [
	<category: 'converters'>
	| stream |
	aTimestamp isNil ifTrue: [^'NULL'].
	stream := WriteStream on: String new.
	aTimestamp glorpPrintSQLOn: stream.
	^stream contents
    ]

    convertBooleanToDBBoolean: aBoolean for: aType [
	<category: 'converters'>
	aBoolean isNil ifTrue: [^nil].
	aBoolean isInteger ifTrue: [^aBoolean ~= 0].
	^aBoolean
    ]

    convertDBBooleanToBoolean: aBoolean for: aType [
	<category: 'converters'>
	aBoolean isInteger ifFalse: [^aBoolean].
	^aBoolean = 1
    ]

    bigint [
	<category: 'types'>
	^self int8
    ]

    boolean [
	<category: 'types'>
	^self typeNamed: #boolean ifAbsentPut: [BooleanType new typeString: 'bit']
    ]

    date [
	<category: 'types'>
	^self typeNamed: #date ifAbsentPut: [DateType new typeString: 'date']
    ]

    decimal [
	<category: 'types'>
	^self numeric
    ]

    double [
	<category: 'types'>
	^self float8
    ]

    float [
	<category: 'types'>
	^self float4
    ]

    float4 [
	<category: 'types'>
	^self typeNamed: #float4 ifAbsentPut: [FloatType new]
    ]

    float8 [
	<category: 'types'>
	^self typeNamed: #float8 ifAbsentPut: [DoubleType new]
    ]

    int [
	<category: 'types'>
	^self int4
    ]

    int2 [
	<category: 'types'>
	^self typeNamed: #int2
	    ifAbsentPut: [MySQLIntType new typeString: 'smallint']
    ]

    int8 [
	<category: 'types'>
	^self typeNamed: #int8 ifAbsentPut: [MySQLIntType new typeString: 'bigint']
    ]

    integer [
	<category: 'types'>
	^self int8
    ]

    numeric [
	<category: 'types'>
	^self typeNamed: #numeric ifAbsentPut: [NumericType new]
    ]

    real [
	<category: 'types'>
	^self float4
    ]

    serial [
	<category: 'types'>
	^self typeNamed: #serial ifAbsentPut: [MySQLAutoIncrementType new]
    ]

    smallint [
	<category: 'types'>
	^self int2
    ]

    text [
	<category: 'types'>
	^self typeNamed: #text ifAbsentPut: [MySQLTextType new]
    ]

    time [
	<category: 'types'>
	^self typeNamed: #time ifAbsentPut: [TimeType new typeString: 'time']
    ]

    timestamp [
	<category: 'types'>
	^self typeNamed: #timestamp
	    ifAbsentPut: [TimeStampType new typeString: 'datetime']
    ]

    timeStampTypeString [
	<category: 'types'>
	^'datetime'
    ]

    varchar [
	<category: 'types'>
	^self typeNamed: #varchar ifAbsentPut: [VarCharType new]
    ]

    int4 [
	<category: 'types'>
	^self typeNamed: #int4 ifAbsentPut: [MySQLIntType new typeString: 'int']
    ]

    areSequencesExplicitlyCreated [
	<category: 'SQL'>
	^false
    ]

    supportsANSIJoins [
	"Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"

	<category: 'SQL'>
	^true
    ]

    supportsMillisecondsInTimes [
	<category: 'SQL'>
	^false
    ]

    supportsConstraints [
	<category: 'SQL'>
	^false
    ]

    createTableStatementStringFor: aGLORPDatabaseTable [
	"^<String> This method returns a string which can be used to create a database table ..."

	<category: 'SQL'>
	| sqlStatementStream tmpString |
	tmpString := 'create table'.
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
	    nextPutAll: (self capitalWritingOfSQLCommands 
			ifTrue: [tmpString asUppercase]
			ifFalse: [tmpString]);
	    space.
	self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.

	"Now print the columns specification for each field in the table ..."
	self printColumnsSpecificationFor: aGLORPDatabaseTable
	    on: sqlStatementStream.
	aGLORPDatabaseTable hasPrimaryKeyConstraints 
	    ifTrue: 
		[sqlStatementStream nextPutAll: ', '.
		self printPrimaryKeyConstraintsOn: sqlStatementStream
		    for: aGLORPDatabaseTable].
	sqlStatementStream
	    nextPutAll: ') TYPE=';
	    nextPutAll: self class newTableType.
	^sqlStatementStream contents
    ]

    printPrimaryKeyConstraintsOn: sqlStatementStream for: aTable [
	"This method print the constraint specification on sqlStatementStream"

	<category: 'SQL'>
	| sepFlag |
	aTable primaryKeyFields isEmpty ifTrue: [^self].
	sqlStatementStream nextPutAll: ' PRIMARY KEY  ('.
	sepFlag := false.
	aTable primaryKeyFields do: 
		[:eachPrimaryKeyField | 
		sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
		sqlStatementStream nextPutAll: eachPrimaryKeyField name.
		sepFlag := true].
	sqlStatementStream nextPut: $)
    ]
]



AbstractIntegerType subclass: MySQLAutoIncrementType [
    
    <comment: nil>
    <category: 'Glorp-MySQL'>

    MySQLAutoIncrementType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2003 Free Software Foundation, Inc.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License (LGPL), WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.LIB file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    isGenerated [
	<category: 'testing'>
	^true
    ]

    typeString [
	<category: 'SQL'>
	^'int auto_increment'
    ]

    postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'SQL'>
	aDatabaseRow at: aDatabaseField
	    put: (aSession accessor executeSQLString: 'SELECT LAST_INSERT_ID()') first 
		    first
    ]
]



AbstractIntegerType subclass: MySQLIntType [
    
    <comment: nil>
    <category: 'Glorp-MySQL'>
]



TextType subclass: MySQLTextType [
    
    <comment: nil>
    <category: 'Glorp-MySQL'>

    converterForStType: aClass [
	<category: 'converting'>
	| conv |
	conv := super converterForStType: aClass.
	^MySQLTextConverter 
	    hostedBy: conv host
	    fromStToDb: conv stToDbSelector
	    fromDbToSt: conv dbToStSelector
    ]
]



DelegatingDatabaseConverter subclass: MySQLTextConverter [
    
    <comment: nil>
    <category: 'Glorp-MySQL'>

    MySQLTextConverter class >> convert: anObject fromDatabaseRepresentationAs: aDatabaseType [
	<category: 'conversion methods'>
	^super convert: anObject asString
	    fromDatabaseRepresentationAs: aDatabaseType
    ]

    MySQLTextConverter class >> convert: anObject toDatabaseRepresentationAs: aDatabaseType [
	<category: 'conversion methods'>
	^(super convert: anObject toDatabaseRepresentationAs: aDatabaseType) 
	    asByteArray
    ]
]



DatabaseAccessor subclass: DBIDatabaseAccessor [
    | isInTransaction |
    
    <comment: nil>
    <category: 'Glorp-MySQL'>

    loginIfError: aBlock [
	<category: 'login'>
	self logging ifTrue: [self log: 'Login'].
	isInTransaction := 0.
	self doCommand: 
		[connection := DBI.Connection 
			    connect: currentLogin connectString
			    user: currentLogin username
			    password: currentLogin password]
	    ifError: aBlock.
	self logging ifTrue: [self log: 'Login finished']
    ]

    connectionClassForLogin: aLogin [
	<category: 'login'>
	('dbi:*' match: aLogin connectString) ifTrue: [^DBI.Connection].
	self error: 'Unknown database: ' , aLogin database name
    ]

    logout [
	<category: 'login'>
	self isLoggedIn ifFalse: [^self].
	self logging ifTrue: [self log: 'Logout'].
	self doCommand: [connection close].
	self logging ifTrue: [self log: 'Logout finished'].
	connection := nil
    ]

    isLoggedIn [
	<category: 'login'>
	^connection notNil
    ]

    disconnect [
	<category: 'executing'>
	connection close
    ]

    dropConstraint: aConstraint [
	<category: 'executing'>
	
    ]

    dropTableNamed: aString [
	<category: 'executing'>
	self doCommand: [self executeSQLString: 'DROP TABLE ' , aString]
	    ifError: []
    ]

    dropTableNamed: aString ifAbsent: aBlock [
	<category: 'executing'>
	self doCommand: [self executeSQLString: 'DROP TABLE ' , aString]
	    ifError: aBlock
    ]

    executeSQLString: aString [
	<category: 'executing'>
	| resultSet rows numColumns |
	resultSet := connection do: aString.
	resultSet isSelect ifFalse: [^#()].
	self logging ifTrue: [self log: aString].

	"Optimize the cases of 0 returned rows."
	resultSet rowCount = 0 ifTrue: [^#()].
	numColumns := resultSet columnCount.
	rows := Array new: resultSet rowCount.
	1 to: rows size
	    do: [:i | rows at: i put: (self fetchValuesFrom: resultSet next)].
	^rows
    ]

    fetchValuesFrom: row [
	<category: 'executing'>
	| array |
	array := Array new: row columnCount.
	1 to: row columnCount do: [:i | array at: i put: (row atIndex: i)].
	^array
    ]

    commitTransaction [
	<category: 'transactions'>
	self logging ifTrue: [self log: 'Commit Transaction'].
	connection commitTransaction.
	isInTransaction > 0 ifTrue: [isInTransaction := isInTransaction - 1]
    ]

    isInTransaction [
	<category: 'transactions'>
	^isInTransaction > 0
    ]

    rollbackTransaction [
	<category: 'transactions'>
	self logging ifTrue: [self log: 'Rollback Transaction'].
	connection rollbackTransaction.
	isInTransaction > 0 ifTrue: [isInTransaction := isInTransaction - 1]
    ]

    beginTransaction [
	<category: 'transactions'>
	self logging ifTrue: [self log: 'Begin Transaction'].
	connection beginTransaction.
	isInTransaction := isInTransaction + 1
    ]
]



DelegatingDatabaseConverter extend [

    host [
	<category: 'accessing'>
	^host
    ]

    stToDbSelector [
	<category: 'accessing'>
	^stToDbSelector
    ]

    dbToStSelector [
	<category: 'accessing'>
	^dbToStSelector
    ]

]

