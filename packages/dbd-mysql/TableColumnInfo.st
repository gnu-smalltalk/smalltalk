"=====================================================================
|
|   MySQL DBI driver - TableColumnInfo class
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



ColumnInfo subclass: MySQLTableColumnInfo [
    
    <category: 'DBD-MySQL'>
    <comment: nil>
    | name type size nullable index |

    MySQLTableColumnInfo class >> from: aRow index: anInteger [
	^self new initializeFrom: aRow index: anInteger
    ]

    initializeFrom: aRow index: anInteger [
	| rawType |
	name := aRow atIndex: 1.
	rawType := aRow atIndex: 2.
	nullable := (aRow atIndex: 3) = 'YES'.
	index := anInteger.

	type := rawType copyUpTo: $(.
	(type = 'enum' or: [ type = 'set' or: [ rawType includes: $, ]])
	    ifTrue: [ type := rawType ]
	    ifFalse: [ size := (rawType copyAfter: $( ) asInteger ].
    ]

    name [
	"Return the name of the column."
	<category: 'accessing'>
	^name
    ]

    index [
	"Return the 1-based index of the column in the result set."
	<category: 'accessing'>
	^index
    ]

    isNullable [
	"Return whether the column can be NULL."
	<category: 'accessing'>
	^nullable
    ]

    type [
	"Return a string containing the type of the column."
	<category: 'accessing'>
	^type
    ]

    size [
	"Return the size of the column."
	<category: 'accessing'>
	^size
    ]
]
