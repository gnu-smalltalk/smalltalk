"=====================================================================
|
|   PosgreSQL DBI driver - Table class
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



Table subclass: PGTable [
    
    <category: 'DBD-PostgreSQL'>
    <comment: nil>

    | columnsArray |

    columnsArray [
	"Answer a Dictionary of column name -> ColumnInfo pairs (abstract)."
	| query resultSet |
	columnsArray isNil ifTrue: [
	    query := 'select column_name, data_type, character_maximum_length,
	        numeric_precision, numeric_precision_radix, numeric_scale,
	        is_nullable, ordinal_position
		from information_schema.columns
		where table_schema = current_schema and table_name = %1
                and table_catalog = %2
		order by ordinal_position' % {
		    self name printString. self connection database printString }.
	    resultSet := self connection select: query.
	    columnsArray := resultSet rows
	        collect: [ :row | PGTableColumnInfo from: row ] ].
	^columnsArray
    ]
]
