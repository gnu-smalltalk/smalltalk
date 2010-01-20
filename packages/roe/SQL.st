"=====================================================================
|
|   ROE SQL statement generator
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RAConcreteRelation subclass: RASQLRelation [
    | connection |
    
    <category: 'Roe-Relations-Concrete'>
    <comment: nil>
    
    Log := false.

    RASQLRelation class >> log [
	^Log
    ]

    RASQLRelation class >> log: aBoolean [
	Log := aBoolean.
    ]

    RASQLRelation class >> name: aString [
	self shouldNotImplement
    ]

    RASQLRelation class >> name: aString connection: aConnection [
	^self basicNew initializeWithName: aString connection: aConnection
    ]

    addValues: anArray [
	<category: 'adding'>
	self exec: (self sqlInsert: (self attributes collect: [:ea | ea name])
		    values: anArray)
    ]

    attributes [
	<category: 'accessing'>
	attributes isNil ifTrue: [attributes := self discoverAttributes].
	^attributes
    ]

    basicExec: aString [
	<category: 'private'>
	self subclassResponsibility
    ]

    basicQuery: aString [
	<category: 'private'>
	self subclassResponsibility
    ]

    connection [
	<category: 'accessing'>
	^connection
    ]

    deleteFor: aRelation [
	<category: 'removing'>
	| conditionString |
	conditionString := RASingleTableSqlPrinter print: aRelation for: self.
	self exec: (self sqlDeleteWhere: conditionString)
    ]

    discoverAttributes [
	<category: 'private'>
	self subclassResponsibility
    ]

    exec: aString [
	<category: 'private'>
	^self logging: aString do: [self basicExec: aString]
    ]

    for: aRelation do: aBlock [
	<category: 'private'>
	(self query: (self sqlPrinterClass print: aRelation for: self)) 
	    do: [:ea | aBlock value: (RASimpleTuple relation: aRelation values: ea asArray)]
    ]

    for: aRelation update: aBlock [
	<category: 'updating'>
	| tuple conditionString |
	tuple := RAUpdateTuple relation: aRelation.
	aBlock value: tuple.
	conditionString := RASingleTableSqlPrinter print: aRelation for: self.
	self exec: (self sqlUpdate: tuple nodes where: conditionString)
    ]

    initializeWithName: aString connection: aConnection [
	<category: 'initializing'>
	super initializeWithName: aString.
	connection := aConnection
    ]

    log [
	<category: 'private'>
	^Log
    ]

    logging: aString do: aBlock [
	<category: 'private'>
	| time val |
	self log
	    ifTrue: [Transcript nextPutAll: aString].
	time := Time millisecondsToRun: [val := aBlock value].
	self log
	    ifTrue: [Transcript nextPutAll: ' [' , time printString , ']'; nl].
	^val
    ]

    query: aString [
	<category: 'private'>
	^self logging: aString do: [self basicQuery: aString]
    ]

    size [
	<category: 'core'>
	self subclassResponsibility
    ]

    sqlCount [
	<category: 'private'>
	^'SELECT COUNT(*) FROM ' , self name
    ]

    sqlDeleteWhere: conditionString [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'DELETE FROM ';
		    nextPutAll: self name;
		    nextPutAll: ' WHERE ';
		    nextPutAll: conditionString]
    ]

    sqlInsert: attributeNames values: anArray [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'INSERT INTO ';
		    nextPutAll: self name;
		    nextPutAll: ' ('.
		attributeNames do: 
			[:each | self printAttribute: each on: stream ]
		    separatedBy: [stream nextPutAll: ', '].
		stream nextPutAll: ') VALUES ('.
		anArray do: 
			[:each | self print: each on: stream ]
		    separatedBy: [stream nextPutAll: ', '].
		stream nextPutAll: ')']
    ]

    printAttribute: each on: aStream [
        <category: 'printing'>
	aStream
	    nextPut: $";
	    nextPutAll: each;
	    nextPut: $"
    ]

    print: anObject on: aStream [
        <category: 'printing'>
	anObject isNil ifTrue: [
	    aStream nextPutAll: 'NULL'. ^self ].
	aStream nextPut: $'.
	anObject isString
	    ifTrue: [ aStream nextPutAll: anObject asEscapedSql ]
	    ifFalse: [ aStream nextPutAll: anObject printString asEscapedSql ].
	aStream nextPut: $'
    ]

    sqlPrinterClass [
	<category: 'private'>
	^RASqlPrinter
    ]

    sqlUpdate: attributesToNodes where: conditionString [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'UPDATE ';
		    nextPutAll: name;
		    nextPutAll: ' SET '.
		attributesToNodes keysAndValuesDo: 
			[:attribute :node | 
			stream
			    nextPutAll: '"' , attribute originalAttribute name , '"';
			    nextPutAll: ' = (';
			    nextPutAll: (RASqlUpdatePrinter print: node for: self);
			    nextPutAll: '), '].
		stream skip: -2.
		stream nextPutAll: ' WHERE '.
		stream nextPutAll: conditionString]
    ]
]


RAPrinter subclass: RASingleTableSqlPrinter [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    errorInvalidOperation [
	<category: 'visiting'>
	self error: 'Invalid operation on this relation'
    ]

    printOperator: aNode [
	<category: 'private'>
	stream nextPutAll: aNode sqlOperator
    ]

    visitAlias: aRelation [
	<category: 'visiting'>
	self visit: aRelation source
    ]

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: '"' , aNode attribute originalAttribute name , '"'
    ]

    visitCartesianProduct: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitDifference: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitDistinct: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitGroup: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitIntersection: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitInterval: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitOrder: aRelation [
	<category: 'visiting'>
	self visit: aRelation source
    ]

    visitProjection: aRelation [
	<category: 'visiting'>
	self visit: aRelation source
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	stream nextPutAll: ' 1=1'
    ]

    visitSelection: aRelation [
	<category: 'visiting'>
	self visit: aRelation source.
	stream nextPutAll: ' AND ( '.
	self visitConditionNodesFor: aRelation.
	stream nextPutAll: ')'
    ]

    visitUnion: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]
]



RAPrinter subclass: RASqlPrinter [
    | tableCounter columnCounter columnMap |
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    attributeNames: aCollection [
	<category: 'private'>
	^String streamContents: 
		[:s | 
		aCollection 
		    do: [:each | s nextPutAll: (self columnNameForAttribute: each)]
		    separatedBy: [s nextPutAll: ', ']]
    ]

    attributeNames: aCollection aliasedAs: aliasCollection [
	<category: 'private'>
	^String streamContents: 
		[:s | 
		(1 to: aCollection size)
		    do: 
			[:index || attr alias |
			attr := aCollection at: index.
			alias := aliasCollection at: index.
			s
			    nextPutAll: (self columnNameForAttribute: attr);
			    nextPutAll: ' AS ';
			    nextPutAll: (self columnNameForAttribute: alias) ]
		    separatedBy: [s nextPutAll: ', ']]
    ]

    columnNameForAttribute: anAttribute [
	<category: 'private'>
	columnMap ifNil: [columnMap := Dictionary new].
	^columnMap at: anAttribute ifAbsentPut: [self nextColumnName]
    ]

    nextColumnName [
	<category: 'accessing'>
	columnCounter := columnCounter ifNil: [1]
		    ifNotNil: [:foo | columnCounter + 1].
	^'c' , columnCounter printString
    ]

    nextTableName [
	<category: 'accessing'>
	tableCounter := tableCounter ifNil: [1] ifNotNil: [:foo | tableCounter + 1].
	^'t' , tableCounter printString
    ]

    printOperator: aNode [
	<category: 'private'>
	stream nextPutAll: aNode sqlOperator
    ]

    select: aString fromRelation: aRelation [
	<category: 'private'>
	stream
	    nextPutAll: 'SELECT ';
	    nextPutAll: aString;
	    nextPutAll: ' FROM '.
	self subselectRelation: aRelation
    ]

    selectAllFromRelation: aRelation [
	<category: 'private'>
	self select: '*' fromRelation: aRelation
    ]

    subselectRelation: aRelation [
	<category: 'private'>
	stream nextPut: $(.
	self visit: aRelation.
	stream
	    nextPutAll: ') AS ';
	    nextPutAll: self nextTableName
    ]

    visitAlias: aRelation [
	<category: 'visiting'>
	self select: (self attributeNames: aRelation source attributes
		    aliasedAs: aRelation attributes)
	    fromRelation: aRelation source
    ]

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: (self columnNameForAttribute: aNode attribute)
    ]

    visitBoolean: aBoolean [
	<category: 'visiting-objects'>
	self visitObject: aBoolean
    ]

    visitCartesianProduct: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation left.
	stream nextPutAll: ', '.
	self subselectRelation: aRelation right
    ]

    visitClone: aRelation [
	<category: 'visiting'>
	self visitAlias: aRelation
    ]

    visitDate: aDate [
	<category: 'visiting-objects'>
	self visitObject: aDate
    ]

    visitDifference: aRelation [
	<category: 'visiting'>
	self visit: aRelation left.
	stream nextPutAll: ' EXCEPT '.
	self visit: aRelation right.
    ]

    visitDistinct: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT DISTINCT * FROM '.
	self subselectRelation: aRelation source
    ]

    visitGroup: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation source.
	stream nextPutAll: ' GROUP BY '.
	stream nextPutAll: (self attributeNames: aRelation group)
    ]

    visitIntersection: aRelation [
	<category: 'visiting'>
	self visit: aRelation left.
	stream nextPutAll: ' INTERSECT '.
	self visit: aRelation right.
    ]

    visitInterval: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation source.
	stream
	    nextPutAll: ' LIMIT ';
	    print: aRelation limit.
	stream
	    nextPutAll: ' OFFSET ';
	    print: aRelation offset
    ]

    visitOrder: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation source.
	stream nextPutAll: ' ORDER BY '.
	(1 to: aRelation order size) do: 
		[:index | 
		stream 
		    nextPutAll: (self columnNameForAttribute: (aRelation order at: index)).
		(aRelation ascending at: index) 
		    ifTrue: [stream nextPutAll: ' ASC']
		    ifFalse: [stream nextPutAll: ' DESC']]
	    separatedBy: [stream nextPutAll: ', ']
    ]

    visitProjection: aRelation [
	<category: 'visiting'>
	self select: (self attributeNames: aRelation attributes)
	    fromRelation: aRelation source
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT '.
	aRelation attributes do: 
		[:attr | 
		stream
		    nextPutAll: '"';
		    nextPutAll: attr name;
		    nextPutAll: '" AS ';
		    nextPutAll: (self columnNameForAttribute: attr)]
	    separatedBy: [stream nextPutAll: ', '].
	stream nextPutAll: ' FROM ' , aRelation name
    ]

    visitSelection: aRelation [
	<category: 'visiting'>
	self selectAllFromRelation: aRelation source.
	stream nextPutAll: ' WHERE '.
	self visitConditionNodesFor: aRelation
    ]

    visitUndefinedObject: anUndefinedObject [
	<category: 'visiting-objects'>
	stream nextPutAll: 'NULL'
    ]

    visitUnion: aRelation [
	<category: 'visiting'>
	self visit: aRelation left.
	stream nextPutAll: ' UNION '.
	self visit: aRelation right.
    ]
]



RAPrinter subclass: RASqlUpdatePrinter [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: '"' , aNode attribute originalAttribute name , '"'
    ]
]


String extend [

    asEscapedSql [
       <category: '*Roe'>
       ^String streamContents: 
               [:stream | 
               self do: 
                       [:char | 
                       (#($' $\) includes: char) ifTrue: [stream nextPut: char].

                       stream nextPut: char]]
    ]

]
