"=====================================================================
|
|   Generic database interface - Table class (bridge with ROE)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



ROE.RASQLRelation subclass: Table [
    
    <category: 'DBI'>
    <comment: nil>

    | columns |

    basicExec: aString [
	<category: 'private'>
	^connection do: aString
    ]

    basicQuery: aString [
	<category: 'private'>
	^(connection select: aString) contents
    ]

    columnsArray [
	"Answer a Dictionary of column name -> ColumnInfo pairs (abstract)."
	self subclassResponsibility
    ]

    columns [
        <category: 'accessing'>
        columns isNil
            ifTrue:
                [| n array |
		array := self columnsArray.
                columns := LookupTable new: array size.
                array do: [:col | columns at: col name put: col]].
        ^columns
    ]

    columnNames [
	"Answer an array of column names in order (abstract)."

	<category: 'accessing'>
	^self columnsArray collect: [:each | self name]
    ]

    columnAt: aIndex [
        "Answer the aIndex'th column name."

        <category: 'accessing'>
        ^(self columnsArray at: aIndex) name
    ]

    database [
	"Returns the database name for this table.  This corresponds
	 to the catalog in SQL standard parlance."

	<category: 'accessing'>
	^self connection database
    ]

    discoverAttributes [
	<category: 'private'>
	^self columnsArray
	    collect: [:each | RASimpleAttribute named: each name relation: self]
    ]

    size [
	<category: 'core'>
	^(self query: self sqlCount) first atIndex: 1
    ]

    print: anObject on: aStream [
        <category: 'printing'>
        self connection fieldConverter print: anObject on: aStream
    ]
]
