"=====================================================================
|
|   SQLite bindings, Table class
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



Table subclass: SQLiteTable [
    
    <category: 'DBD-SQLite'>
    <comment: nil>

    | columnsArray |

    columnsArray [
	"Answer an array of column name -> ColumnInfo pairs."
	| query resultSet string i |
	columnsArray isNil ifTrue: [

	    query := 'select sql from (select * from
			sqlite_master union all select * from sqlite_temp_master)
			where tbl_name = %1 limit 1;' % { self name printString }.
	    resultSet := self connection select: query.
	    string := (resultSet next atIndex: 1).
	    string := string copyFrom: (string indexOf: $( ) + 1 to: string size - 1.
	    i := 0.
	    columnsArray := (string subStrings: $,) collect: [ :field |
		SQLiteTableColumnInfo from: field subStrings index: (i := i + 1) ] ].
	^columnsArray
    ]
]
