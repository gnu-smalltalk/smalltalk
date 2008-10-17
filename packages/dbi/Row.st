"=====================================================================
|
|   Generic database interface - Row class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



Object subclass: Row [
    | resultSet |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a row in a result set.'>

    resultSet [
	"Return the result set that includes the receiver."

	<category: 'accessing'>
	^resultSet
    ]

    resultSet: aResultSet [
	<category: 'private'>
	resultSet := aResultSet
    ]

    at: aColumnName [
	"Return the value of the named column (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    asArray [
	"Return the values of the columns."

	<category: 'accessing'>
	^1 to: self columns size collect: [:index | self atIndex: index]
    ]

    asDictionary [
	"Return the names and values of the columns as a dictionary."

	| d |
	<category: 'accessing'>
	d := LookupTable new.
	self keysAndValuesDo: [ :key :value | d at: key put: value ].
	^d
    ]

    atIndex: aColumnIndex [
	"Return the value of the column at the given 1-based index (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    columnCount [
	"Return the number of columns in the row."

	<category: 'accessing'>
	^resultSet columnCount
    ]

    columns [
	"Return a Dictionary of ColumnInfo objects for the columns in the row,
	 where the keys are the column names."

	<category: 'accessing'>
	^resultSet columns
    ]

    columnNames [
	"Return an array of column names for the columns in the row."

	<category: 'accessing'>
	^resultSet columnNames
    ]

    columnAt: aIndex [
	"Return a ColumnInfo object for the aIndex-th column in the row."

	<category: 'accessing'>
	^resultSet columnAt: aIndex
    ]

    keysAndValuesDo: aBlock [
	"Pass to aBlock each column name and the corresponding value."

	<category: 'accessing'>
	self columns keysAndValuesDo: 
	    [:name :col | aBlock value: name value: (self atIndex: col index)]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	self keysAndValuesDo: [ :col :val |
	    aStream << col << ' -> ' << val printString << '   ' ]
    ]
]

