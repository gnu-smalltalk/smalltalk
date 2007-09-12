'From VisualWorks®, Pre-Release 7 of June 3, 2002 on August 23, 2002 at 9:50:56 pm'!
"Package GlorpDatabase(0.2.11,aknight)="!

DatabasePlatform subclass: #MySQLPlatform
    instanceVariableNames: ''
    classVariableNames: 'NewTableType'
    poolDictionaries: ''
    category: 'Glorp-MySQL'!

AbstractIntegerType subclass: #MySQLAutoIncrementType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-MySQL'!

AbstractIntegerType subclass: #MySQLIntType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-MySQL'!

TextType subclass: #MySQLTextType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-MySQL'!

DelegatingDatabaseConverter subclass: #MySQLTextConverter
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-MySQL'!

DatabaseAccessor subclass: #DBIDatabaseAccessor
    instanceVariableNames: 'isInTransaction'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-MySQL'!


!MySQLAutoIncrementType class methodsFor: 'LICENSE'!

LICENSE

    ^'Copyright 2003 Free Software Foundation, Inc.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License (LGPL), WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.LIB file that should accompany this distribution, or the GNU Lesser General Public License.'! !


!MySQLAutoIncrementType methodsFor: 'testing'!

isGenerated

    ^true! !

!MySQLAutoIncrementType methodsFor: 'SQL'!

typeString

    ^'int auto_increment'!

postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession
    aDatabaseRow at: aDatabaseField
        put: (aSession accessor
                        executeSQLString: 'SELECT LAST_INSERT_ID()') first first!


!MySQLTextType methodsFor: 'converting'!

converterForStType: aClass
    | conv |
    conv := super converterForStType: aClass.
    ^MySQLTextConverter
        hostedBy: conv host
        fromStToDb: conv stToDbSelector
	fromDbToSt: conv dbToStSelector! !

!DelegatingDatabaseConverter methodsFor: 'accessing'!

host
    ^host!

stToDbSelector
    ^stToDbSelector!

dbToStSelector
    ^dbToStSelector! !

!MySQLTextConverter class methodsFor: 'conversion methods'!

convert: anObject fromDatabaseRepresentationAs: aDatabaseType
    ^super convert: anObject asString fromDatabaseRepresentationAs: aDatabaseType!

convert: anObject toDatabaseRepresentationAs: aDatabaseType
    ^(super convert: anObject toDatabaseRepresentationAs: aDatabaseType) asByteArray! !



!DBIDatabaseAccessor methodsFor: 'login'!

loginIfError: aBlock 
    self logging
	ifTrue: [self log: 'Login'].

    isInTransaction := 0.
    self doCommand: [ connection := DBI.Connection
        connect: currentLogin connectString
    	user: currentLogin username
    	password: currentLogin password ] ifError: aBlock.
    self logging
	ifTrue: [self log: 'Login finished']!

connectionClassForLogin: aLogin 
    ('dbi:*' match: aLogin connectString)
    	ifTrue: [^DBI.Connection].
    self error: 'Unknown database: ' , aLogin database name!

logout
    self isLoggedIn ifFalse: [^self].
    self logging    ifTrue: [self log: 'Logout'].
    self doCommand: [connection close].	
    self logging    ifTrue: [self log: 'Logout finished'].
    connection := nil!

isLoggedIn

    ^connection notNil! !

!DBIDatabaseAccessor methodsFor: 'executing'!

disconnect
    connection close!

dropConstraint: aConstraint
!

dropTableNamed: aString
    self doCommand: [self executeSQLString: 'DROP TABLE ' , aString]
        ifError: []!

dropTableNamed: aString ifAbsent: aBlock 
    self doCommand: [self executeSQLString: 'DROP TABLE ' , aString]
        ifError: aBlock!

executeSQLString: aString 
    | resultSet rows numColumns |
    resultSet := connection do: aString.
    resultSet isSelect ifFalse: [ ^#() ].
    self logging ifTrue: [ self log: aString ].

    "Optimize the cases of 0 returned rows."
    resultSet rowCount = 0 ifTrue: [ ^#() ].

    numColumns := resultSet columnCount.
    rows := Array new: resultSet rowCount.
    1 to: rows size do: [ :i |
        rows at: i put: (self fetchValuesFrom: resultSet next) ].

    ^rows!

fetchValuesFrom: row
    | array |
    array := Array new: row columnCount.
    1 to: row columnCount
            do: [:i | array at: i put: (row atIndex: i)].
    ^array!

!DBIDatabaseAccessor methodsFor: 'transactions'!

commitTransaction

    self logging ifTrue: 
    	[self log: 'Commit Transaction'].
    connection commitTransaction.
    isInTransaction > 0 ifTrue: [ isInTransaction := isInTransaction - 1 ]!

isInTransaction

    ^isInTransaction > 0!

rollbackTransaction
    self logging ifTrue: 
    	[self log: 'Rollback Transaction'].
    connection rollbackTransaction.
    isInTransaction > 0 ifTrue: [ isInTransaction := isInTransaction - 1 ]!

beginTransaction
    self logging ifTrue: 
    	[self log: 'Begin Transaction'].
    connection beginTransaction.
    isInTransaction := isInTransaction + 1! !



!MySQLPlatform class methodsFor: 'LICENSE'!

LICENSE

    ^'Copyright 2003 Free Software Foundation, Inc.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License (LGPL), WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.LIB file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!MySQLPlatform class methodsFor: 'accessing'!

defaultNewTableType
    ^'InnoDB'!

newTableType
    NewTableType isNil ifTrue: [ NewTableType := self defaultNewTableType ].
    ^NewTableType!

newTableType: aString
    NewTableType := aString! !

!MySQLPlatform methodsFor: 'converters'!

printDate: aDate for: aType
    "Print a date (or timestamp) as yyyy-mm-dd"
    | stream |
    aDate isNil ifTrue: [^'NULL'].
    stream := WriteStream on: String new.
    stream nextPut: $'.
    self
        printDate: aDate
        isoFormatOn: stream.
    stream nextPut: $'.
    ^stream contents.!

printTime: aTime for: aType
    "Print a time (or timestamp) as hh:mm:ss.fff"
    | stream |
    aTime isNil ifTrue: [^'NULL'].
    stream := WriteStream on: String new.
    stream nextPut: $'.
    self
        printTime: aTime
        isoFormatOn: stream.
    stream nextPut: $'.
    ^stream contents.!

printTimestamp: aTimestamp for: aType
    | stream |
    aTimestamp isNil ifTrue: [^'NULL'].
    stream := WriteStream on: String new.
    aTimestamp glorpPrintSQLOn: stream.
    ^stream contents.!

convertBooleanToDBBoolean: aBoolean for: aType
    aBoolean isNil ifTrue: [^nil].
    aBoolean isInteger ifTrue: [ ^aBoolean ~= 0].
    ^aBoolean!

convertDBBooleanToBoolean: aBoolean for: aType
    aBoolean isInteger ifFalse: [^aBoolean].
    ^aBoolean = 1! !

!MySQLPlatform methodsFor: 'types'!

bigint
    ^self int8!

boolean
    ^self typeNamed: #boolean ifAbsentPut: [BooleanType new typeString: 'bit'].!

date
    ^self typeNamed: #date ifAbsentPut: [DateType new typeString: 'date'].!

decimal
    ^self numeric.!

double
    ^self float8!

float
    ^self float4.!

float4
    ^self typeNamed: #float4 ifAbsentPut: [FloatType new].!

float8
    ^self typeNamed: #float8 ifAbsentPut: [DoubleType new].!

int
    ^self int4!

int2
    ^self typeNamed: #int2 ifAbsentPut: [MySQLIntType new typeString: 'smallint'].!

int8
    ^self typeNamed: #int8 ifAbsentPut: [MySQLIntType new typeString: 'bigint'].!

integer
    ^self int8.!

numeric
    ^self typeNamed: #numeric ifAbsentPut: [NumericType new].!

real
    ^self float4!

serial
    ^self typeNamed: #serial ifAbsentPut: [MySQLAutoIncrementType new].!

smallint
    ^self int2!

text
    ^self typeNamed: #text ifAbsentPut: [MySQLTextType new].!

time
    ^self typeNamed: #time ifAbsentPut: [TimeType new typeString: 'time'].!

timestamp
    ^self typeNamed: #timestamp ifAbsentPut: [TimeStampType new typeString: 'datetime'].!

timeStampTypeString
    ^'datetime'.!

varchar
    ^self typeNamed: #varchar ifAbsentPut: [VarCharType new].!

int4
    ^self typeNamed: #int4 ifAbsentPut: [MySQLIntType new typeString: 'int'].! !

!MySQLPlatform methodsFor: 'SQL'!

areSequencesExplicitlyCreated
    ^false!

supportsANSIJoins
    "Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"
    ^true.!

supportsMillisecondsInTimes
    ^false.!

supportsConstraints
    ^false.!

createTableStatementStringFor: aGLORPDatabaseTable
    "^<String> This method returns a string which can be used to create a database table ..."

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
            nextPutAll: ') TYPE='; nextPutAll: self class newTableType.
    ^sqlStatementStream contents!

printPrimaryKeyConstraintsOn: sqlStatementStream for: aTable
    "This method print the constraint specification on sqlStatementStream"

    | sepFlag |
    aTable primaryKeyFields isEmpty ifTrue: [^self].
    sqlStatementStream
        nextPutAll: ' PRIMARY KEY  ('.
    sepFlag := false.
    aTable primaryKeyFields do: [:eachPrimaryKeyField |
        sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
        sqlStatementStream nextPutAll: eachPrimaryKeyField name.
        sepFlag := true].
    sqlStatementStream nextPut: $)! !
