"=====================================================================
|
|   Generic database interface - ResultSet class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Stream subclass: ResultSet [
    | statement |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a result set, ie. the set of rows returned from a SELECT statement.
I may also be returned for DML statements (INSERT, UPDATE, DELETE), in which
case I only hold the number of rows affected.'>

    fetch [
	"Return the next row, or nil if at the end of the result set."
	<category: 'cursor access'>
	self atEnd ifTrue: [ ^nil ].
	^self next
    ]

    next [
	"Return the next row, or raise an error if at the end of the stream
	 (abstract)."
	<category: 'cursor access'>
	self subclassResponsibility
    ]

    atEnd [
	"Return whether all the rows in the result set have been consumed.
	 (abstract)."
	<category: 'cursor access'>
	self subclassResponsibility
    ]

    rows [
	"Answer the contents of the execution result as array of Rows."

	<category: 'accessing'>
	| pos |
	pos := self position.
	^[ self position: 0. self contents ]
	    ensure: [ self position: pos ]
    ]

    columns [
	"Answer a Dictionary of column name -> ColumnInfo pairs (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    columnNames [
	"Answer an array of column names in order (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    columnAt: aIndex [
	"Answer the aIndex'th column name."

	<category: 'accessing'>
	^self columnNames at: aIndex
    ]

    isSelect [
	"Returns true if the statement was a SELECT or similar operation
	 (e.g. SHOW, DESCRIBE, EXPLAIN), false otherwise."

	<category: 'accessing'>
	^false
    ]

    isDML [
	"Returns true if the statement was not a SELECT or similar operation
	 (e.g. SHOW, DESCRIBE, EXPLAIN)."

	<category: 'accessing'>
	^false
    ]

    position [
	"Returns the current row index (0-based) in the result set (abstract)."
	<category: 'stream protocol'>
	self subclassResponsibility
    ]

    position: anInteger [
	"Sets the current row index (0-based) in the result set (abstract)."
	<category: 'stream protocol'>
	self subclassResponsibility
    ]

    size [
	"Returns the number of rows in the result set."
	<category: 'stream protocol'>
	^self rowCount
    ]

    rowCount [
	"Returns the number of rows in the result set;
	 error for DML statements."

	<category: 'accessing'>
	self error: 'Not a SELECT statement.'
    ]

    rowsAffected [
	"For DML statments, returns the number of rows affected;
	 error for SELECT statements."

	<category: 'accessing'>
	self error: 'Not a DML statement.'
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."
	<category: 'printing'>
	self isSelect ifFalse: [ ^super printOn: aStream ].
	self rows do: 
		[:row | 
		row printOn: aStream.
		aStream nl]
    ]

    statement [
	"Return the Statement, if any, that generated the result set."

	<category: 'accessing'>
	^statement
    ]

    statement: aStatement [
	<category: 'private'>
	statement := aStatement
    ]
]

