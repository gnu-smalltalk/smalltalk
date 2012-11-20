"======================================================================
|
|   SQLite bindings, ResultSet class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2013 Free Software Foundation, Inc.
| Written by Daniele Sciascia
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

ResultSet subclass: SQLiteResultSet [
    | handle rows columns index lastRes |

    <comment: 'This class is doing three things at once. It can handle
    SELECT and DML. For the result of a select a legacy fetch all interface
    is provided or a stream based one.'>
		   
    SQLiteResultSet class >> on: aStatement [
        <category: 'instance creation'>
        ^self new initializeWithStatement: aStatement
    ]
    
    initializeWithStatement: aStatement [
        <category: 'initialization'>
        index := 0.
        self statement: aStatement.
        self handle: (aStatement handle).
        self isSelect
	    ifTrue: [lastRes := self handle exec.]
	    ifFalse: [self exec]
    ]
    
    exec [
        <category: 'initialization'>
	| resCode |
        resCode := self handle exec.
        self handle checkError: resCode = 101.
	rows := handle changes
    ]

    populateAllRows [
        <category: 'initialization'>
        
        rows := OrderedCollection new.
        [lastRes = 100]
            whileTrue: [
                rows addLast:
                        (SQLiteRow forValues: self handle returnedRow copy in: self).
                lastRes := self handle exec].
        
        self handle checkError: lastRes = 101.
    ]
    
    handle [
        <category: 'private'>
        ^handle
    ]
    
    handle: aSQLite3StmtHandle [
        <category: 'private'>
        handle := aSQLite3StmtHandle
    ]

    next [
        <category: 'cursor access'>
        | res |

        "At the end?"
    	self atEnd ifTrue: [self error: 'No more rows'].

        "Using cached results?"
        rows isNil ifFalse: [index := index + 1. ^self rows at: index].

        "first row handling.."
        index := index + 1.
        res := SQLiteRow forValues: self handle returnedRow copy in: self.
        lastRes := self handle exec.
        lastRes = 101 ifTrue: [self handle reset].

        ^ res.
    ]

    atEnd [
        <category: 'cursor access'>
        ^ rows isNil
            ifFalse: [index >= self rows size]
            ifTrue:  [lastRes ~= 100].
    ]
    
    position [
        <category: 'stream protocol'>
        ^index
    ]

    position: anInteger [
        <category: 'stream protocol'>
        rows isNil ifTrue: [self error: 'Can not set the position on SQLite'].

        (anInteger between: 0 and: self rows size)
            ifTrue: [ index := anInteger ] 
            ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger ].
        ^index
    ]

    columns [
        <category: 'accessing'>
        columns isNil
            ifTrue: [| n |
                     n := self handle colCount.
                     columns := LookupTable new: n.
                     1 to: n do: [:i | columns at: (self columnNames at: i)
                                               put: (SQLiteColumnInfo in: self at: i)]].
        ^columns
    ]

    columnNames [
        <category: 'accessing'>
        ^self handle colNames
    ]
    
    columnTypes [
        ^self handle colTypes
    ]
    
    columnTypeAt: index [
        ^self columnTypes at: index
    ]

    isSelect [
        <category: 'accessing'>
	^self statement isSelect
    ]

    isDML [
        <category: 'accessing'>
	^self statement isSelect not
    ]
    
    rows [
        <category: 'accessing'>
        rows isNil ifFalse: [^rows].
        index = 0 ifFalse: [
            ^ self error: 'Can only ask for the row set before the first fetch.'].

        self populateAllRows.
        ^ rows
    ]

    rowCount [
        <category: 'accessing'>
        "I'm only available for SELECT statements and only when used together with
        >>#rows. For streaming usage with >>#atEnd and >>#next I may not be used.
        This is because SQLite3 does not indicate the size of the query set."
        self isSelect 
            ifTrue: [^self rows size]
            ifFalse: [^self error: 'Not a SELECT statement.']
    ]

    rowsAffected [
        <category: 'accessing'>
        self isDML 
            ifTrue: [^self rows]
            ifFalse: [^self error: 'Not a DML statement.']
    ]
]
