"=====================================================================
|
|   PosgreSQL DBI driver - Row class
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



Row subclass: PGRow [
    | index |
    
    <comment: nil>
    <category: 'DBI-Drivers'>

    PGRow class >> in: aPGResultSet at: aIndex [
	<category: 'instance creation'>
	^self new
	    resultSet: aPGResultSet;
	    index: aIndex
    ]

    index: aIndex [
	<category: 'initialization'>
	index := aIndex
    ]

    at: aColumnName [
	<category: 'accessing'>
	^resultSet valueAtRow: index
	    column: (resultSet columns at: aColumnName) index
    ]

    atIndex: aColumnIndex [
	<category: 'accessing'>
	^resultSet valueAtRow: index column: aColumnIndex
    ]

    raw: aColumnName [
	<category: 'PG specific'>
	^resultSet rawValueAtRow: index
	    column: (resultSet columns at: aColumnName) index
    ]

    rawAtIndex: aColumnIndex [
	<category: 'PG specific'>
	^resultSet rawValueAtRow: index column: aColumnIndex
    ]
]

