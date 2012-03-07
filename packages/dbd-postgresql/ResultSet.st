"=====================================================================
|
|   PosgreSQL DBI driver - ResultSet class
|
|
 ======================================================================"

"======================================================================
|
| Written by Mike Anderson gnu-smalltalk@gingerbread.plus.com 2006
| Based on PostgreSQL interface by Thomas Braun shin@shin.homelinux.net
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
 ======================================================================
"



ResultSet subclass: PGResultSet [
    | handle index rowCount columns columnsArray |
    
    <comment: nil>
    <category: 'DBI-Drivers'>

    PGResultSet class >> new: aCObject [
	<category: 'private'>
	^(self basicNew)
	    handle: aCObject;
	    yourself
    ]

    ResultStatus := #(#PGRES_EMPTY_QUERY
	#PGRES_COMMAND_OK
	#PGRES_TUPLES_OK
	#PGRES_COPY_OUT
	#PGRES_COPY_IN
	#PGRES_BAD_RESPONSE
	#PGRES_NONFATAL_ERROR
	#PGRES_FATAL_ERROR).

    PGResultSet class >> resultStatus: aCode [
	<category: 'constants'>
	^ResultStatus at: aCode + 1
    ]

    handle: aCObject [
	<category: 'private'>
	handle := aCObject.
	index := 0.
	rowCount := nil.
	columns := nil.
	self addToBeFinalized
    ]

    finalize [
	<category: 'private'>
	self primClear
    ]

    next [
	<category: 'cursor access'>
	| r |
	self atEnd ifTrue: [self error: 'No more rows'].
	"FIXME - This could be neater"
	r := PGRow in: self at: index.
	index := index + 1.
	^r
    ]

    atEnd [
	<category: 'cursor access'>
	^index >= self rowCount
    ]

    checkStatusForDo [
	<category: 'private'>
	(#(#PGRES_COMMAND_OK #PGRES_TUPLES_OK #PGRES_EMPTY_QUERY) 
	    includes: self resultStatus) ifFalse: [self error: self errorMessage]
    ]

    checkStatusForSelect [
	<category: 'private'>
	| stat |
	stat := self resultStatus.
	stat = #PGRES_TUPLES_OK 
	    ifFalse: 
		[| msg |
		stat = #PGRES_EMPTY_QUERY 
		    ifTrue: [self error: 'Empty query - no result set'].
		stat = #PGRES_COMMAND_OK 
		    ifTrue: [self error: 'Not a SELECT - no result set'].
		msg := self errorMessage.
		msg isEmpty ifTrue: [self error: stat].
		self error: msg]
    ]

    rawValueAtRow: aRowNum column: aColNum [
	"Answer a given result value at row aRowNum and column aColNum.
	 Both values 0-based."

	<category: 'private'>
	| v |
	v := handle
		    row: aRowNum
		    column: aColNum - 1.
	(v isEmpty and: 
		[(handle
		    isNullRow: aRowNum
		    column: aColNum - 1) = 1]) 
	    ifTrue: [v := nil].
	^v
    ]

    valueAtRow: aRowNum column: aColNum [
	<category: 'private'>
	^PGColumnInfo convert: (self rawValueAtRow: aRowNum column: aColNum)
	    type: (self columnsArray at: aColNum) type
    ]

    isSelect [
	<category: 'accessing'>
	^self resultStatus = #PGRES_TUPLES_OK
    ]

    isDML [
	<category: 'accessing'>
	^self resultStatus = #PGRES_COMMAND_OK
    ]

    position [
        <category: 'cursor access'>
        ^index
    ]

    position: anInteger [
        <category: 'cursor access'>
        (anInteger between: 0 and: self size)
            ifTrue: [ index := anInteger ] 
            ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger ].
        ^index
    ]

    rowCount [
	<category: 'accessing'>
	self isSelect ifFalse: [super rowCount].
	rowCount isNil ifTrue: [rowCount := handle numTuples].
	^rowCount
    ]

    rowsAffected [
	<category: 'accessing'>
	self isDML ifFalse: [super rowsAffected].
	^handle rowsAffected asInteger
    ]

    columnsArray [
	<category: 'accessing'>
	columnsArray isNil 
	    ifTrue: 
		[| n |
		n := handle numFields.
		columnsArray := Array new: n.
		1 to: n do: [:i | columnsArray at: i put: (PGColumnInfo in: self at: i)]].
	^columnsArray
    ]

    columns [
	<category: 'accessing'>
	columns isNil 
	    ifTrue: 
		[| n |
		columns := LookupTable new: self columnsArray size.
		columnsArray do: [:col | columns at: col name put: col]].
	^columns
    ]

    columnNames [
	"Answer the names of the columns in this result set."

	<category: 'accessing'>
	^self columnsArray collect: [:col | col name]
    ]

    columnAt: aIndex [
	"Answer the name of a given column."

	<category: 'accessing'>
	^handle fieldName: aIndex - 1
    ]

    columnCount [
	"Answer the number of columns in the result set."

	<category: 'accessing'>
	^handle numFields
    ]

    rows [
	"This is slightly more efficient than the default method."

	<category: 'accessing'>
	| r n |
	n := self rowCount.
	r := WriteStream on: (Array new: n).
	0 to: n - 1 do: [:i | r nextPut: (PGRow in: self at: i)].
	^r contents
    ]

    resultStatus [
	"Answer the symbolic execution status."

	<category: 'PG specific'>
	^self class resultStatus: handle status
    ]

    errorMessage [
	<category: 'PG specific'>
	^handle errorMessage
    ]

    primClear [
	<category: 'PG specific'>
	handle ifNotNil: [
		handle clear.
		handle := nil]
    ]

    release [
	"Clear the result set."

	<category: 'result set'>
	self removeToBeFinalized.
	self primClear
    ]

    columnTypeAt: aIndex [
	"Used by PGColumnInfo. Prefer (columns at: aName) type or (columnsArray at: aIndex) type"

	<category: 'PG specific'>
	^PGColumnInfo 
	    typeFromOid: (handle fieldType: aIndex - 1)
    ]

    columnSizeAt: aIndex [
	"Used by PGColumnInfo. Prefer (columns at: aName) size or (columnsArray at: aIndex) size"

	<category: 'PG specific'>
	^handle fieldSize: aIndex - 1
    ]
]


CObject subclass: PQResultSet [
    <category: 'private'>

    "Results"
    status [
        <cCall: 'PQresultStatus' returning: #int args: #( #self)>
    ]

    errorMessage [
        <cCall: 'PQresultErrorMessage' returning: #string args: #( #self)>
    ]

    clear [
        <cCall: 'PQclear' returning: #void args: #( #self)>
    ]

    "Result sets"
    numTuples [
        <cCall: 'PQntuples' returning: #int args: #( #self)>
    ]

    row: aRowNum column: aColNum [
        <cCall: 'PQgetvalue' returning: #string args: #( #self #int #int)>
    ]

    isNullRow: aRowNum column: aColNum [
        <cCall: 'PQgetisnull' returning: #int args: #( #self #int #int)>
    ]

    "DML results"
    rowsAffected [
        <cCall: 'PQcmdTuples' returning: #string args: #( #self)>
    ]
	
    lastOid [
        <cCall: 'PQoidValue' returning: #uInt args: #( #self)>
    ]

    "Column info"
    numFields [
        <cCall: 'PQnfields' returning: #int args: #( #self)>
    ]

    fieldName: aColNum [
        <cCall: 'PQfname' returning: #string args: #( #self #int)>
    ]

    fieldIsBinary: aColNum [
        <cCall: 'PQfformat' returning: #int args: #( #self #int)>
    ]
    
    fieldType: aColNum [
        <cCall: 'PQftype' returning: #uInt "Oid" args: #( #self #int)>
    ]

    fieldMod: aColNum [
        <cCall: 'PQfmod' returning: #int "eg. precision or size" args: #( #self #int)>
    ]

    fieldSize: aColNum [
        <cCall: 'PQfsize' returning: #int args: #( #self #int)>
    ]

]

