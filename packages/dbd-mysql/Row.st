"=====================================================================
|
|   MySQL DBI driver - Row class
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



Row subclass: MySQLRow [
    | isEmpty |
    
    <shape: #pointer>
    <comment: nil>
    <category: 'Mysql-Driver'>

    MySQLRow class >> on: aResultSet readFrom: aConnection [
	<category: 'instance creation'>
	^(self new: aResultSet columnCount)
	    resultSet: aResultSet;
	    readFrom: aConnection
    ]

    checkForEndOrNull: aReadStream [
	"This is a bit unclean...the value 254 has been overloaded in the protocol.  When it is the only
	 value in the stream, it indicates there are no more rows.  It also indicates that the following
	 8 bytes contain the size of the field value.  The problem is that there is another condition that
	 produces a single value on the stream...a row with one column whose value is NULL."

	<category: 'reading'>
	| endOrNull |
	aReadStream size = 1 
	    ifTrue: 
		[endOrNull := aReadStream next asInteger.
		isEmpty := endOrNull = 254.
		^true].
	(aReadStream size < 9 and: [aReadStream peekFor: (Character value: 254)]) 
	    ifTrue: 
		[aReadStream next: aReadStream size - 1.
		isEmpty := true.
		^true].
	isEmpty := false.
	^false
    ]

    readFrom: aReadStream [
	<category: 'reading'>
	(self checkForEndOrNull: aReadStream) ifTrue: [^self].
	1 to: self columnCount
	    do: 
		[:index | 
		| aSize column |
		aSize := self readSizeFrom: aReadStream.
		aSize = -1 
		    ifFalse: 
			[column := resultSet columnsArray at: index.
			self at: index put: (column convert: (aReadStream next: aSize))]]
    ]

    readSizeFrom: aReadStream [
	<category: 'reading'>
	| aSize |
	aSize := aReadStream next asInteger.
	aSize < 251 ifTrue: [^aSize].
	aSize = 251 ifTrue: [^-1].
	aSize = 252 ifTrue: [^(aReadStream next: 2) asByteArray asInteger].
	aSize = 253 ifTrue: [^(aReadStream next: 3) asByteArray asInteger].
	aSize = 254 ifTrue: [^(aReadStream next: 8) asByteArray asInteger]
    ]

    at: aColumnName [
	<category: 'accessing'>
	^self basicAt: (resultSet columns at: aColumnName) index
    ]

    atIndex: anIndex [
	<category: 'accessing'>
	^self basicAt: anIndex
    ]

    columnCount [
	<category: 'accessing'>
	^self size
    ]

    columns [
	<category: 'accessing'>
	^resultSet columns
    ]

    columnNames [
	<category: 'accessing'>
	^resultSet columnNames
    ]

    isEmpty [
	<category: 'testing'>
	^isEmpty
    ]
]

