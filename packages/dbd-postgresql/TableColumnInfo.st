"=====================================================================
|
|   PosgreSQL DBI driver - TableColumnInfo class
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



ColumnInfo subclass: PGTableColumnInfo [
    
    <category: 'DBD-PostgreSQL'>
    <comment: nil>
    | name type size nullable index |

    PGTableColumnInfo class >> from: aRow [
	^self new initializeFrom: aRow
    ]

    initializeFrom: aRow [
	| prec radix scale |
	name := aRow atIndex: 1.
	type := aRow atIndex: 2.
	size := aRow atIndex: 3.
	prec := aRow atIndex: 4.
	radix := aRow atIndex: 5.
	scale := aRow atIndex: 6.
	nullable := (aRow atIndex: 7) = 'YES'.
	index := aRow atIndex: 8.

	radix = 2 ifTrue: [
	    prec := (prec / 3.32192809) ceiling.
	    scale := (scale / 3.32192809) ceiling ].

	size isNil
	    ifTrue: [
		scale isNil
		    ifFalse: [
			size := prec + scale.
			type := '%1(%2,%3)' % {type. prec. scale } ]
		    ifTrue: [ size := prec ] ]
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
