"=====================================================================
|
|   MySQL DBI driver - ResultSet class
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


ResultSet subclass: MySQLResultSet [
    | index rows rowCount columns columnsDict |
    
    <comment: nil>
    <category: 'DBI-Drivers'>

    MySQLResultSet class >> on: aStatement [
	<category: 'private'>
	^(self basicNew)
	    statement: aStatement;
	    readFrom: aStatement connection;
	    yourself
    ]

    readFrom: aConnection [
	<category: 'private'>
	rowCount := self isSelect
		ifTrue: [ self readSelectFrom: aConnection ]
		ifFalse: [ self readUpdateFrom: aConnection ]
    ]

    readUpdateFrom: aConnection [
	<category: 'private'>
	| responsePacket |
        responsePacket := aConnection responsePacket.
        responsePacket checkStatusOnError: #invalidQuery.
        ^(responsePacket readStream next: 2) asByteArray asInteger
    ]

    readSelectFrom: aConnection [
	<category: 'private'>
	| row responsePacket column |
        responsePacket := aConnection responsePacket.
        columns := Array
                new: (responsePacket readStatusOnError: #invalidQuery).

        1 to: columns size do: [:index |
            columns at: index put: (column := MySQLColumnInfo new).
	    column readFrom: aConnection responsePacket readStream index: index].

        responsePacket := aConnection responsePacket.
        responsePacket checkForStatus: 254 onError: #invalidQuery.

	rows := OrderedCollection new.
	[
	    row := MySQLRow on: self readFrom: aConnection responsePacket readStream.
	    row isEmpty
	] whileFalse: [ rows addLast: row ].

	index := 0.
	^rows size
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

    next [
	<category: 'cursor access'>
	self atEnd ifTrue: [self error: 'No more rows'].
	index := index + 1.
	^rows at: index
    ]

    atEnd [
	<category: 'cursor access'>
	^index >= self rowCount
    ]

    valueAtRow: aRowNum column: aColNum [
	<category: 'private'>
	^(rows at: aRowNum) atIndex: aColNum
    ]

    isSelect [
	<category: 'accessing'>
	^self statement isSelect
    ]

    isDML [
	<category: 'accessing'>
	^self statement isSelect not
    ]

    rowCount [
	<category: 'accessing'>
	self isSelect ifFalse: [super rowCount].
	^rowCount
    ]

    rowsAffected [
	<category: 'accessing'>
	self isDML ifFalse: [super rowsAffected].
	^rowCount
    ]

    columnsArray [
	<category: 'accessing'>
	^columns
    ]

    columns [
	<category: 'accessing'>
	| columnsDict |
	columnsDict isNil 
	    ifTrue: 
		[columnsDict := LookupTable new: columns size.
		columns do: [:col | columnsDict at: col name put: col]].
	^columnsDict
    ]

    columnNames [
	"Answer the names of the columns in this result set."

	<category: 'accessing'>
	^columns collect: [:col | col name]
    ]

    columnCount [
	"Answer the number of columns in the result set."

	<category: 'accessing'>
	^columns size
    ]

    rows [
	"This is slightly more efficient than the default method."

	<category: 'accessing'>
	^rows
    ]

    release [
	"Clear the result set."

	<category: 'MySQL specific'>
	columns := rows := nil
    ]
]
