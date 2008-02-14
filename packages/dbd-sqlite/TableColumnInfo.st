"=====================================================================
|
|   SQLite bindings, TableColumnInfo class
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



ColumnInfo subclass: SQLiteTableColumnInfo [
    
    <category: 'DBD-SQLite'>
    <comment: nil>
    | name type index |

    SQLiteTableColumnInfo class >> from: aRow index: anInteger [
	^self new initializeFrom: aRow index: anInteger
    ]

    initializeFrom: aRow index: anInteger [
	name := aRow at: 1.
	type := aRow at: 2.
	index := anInteger.
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

    type [
	"Return a string containing the type of the column."
	<category: 'accessing'>
	^type
    ]
]
