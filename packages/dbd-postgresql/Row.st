"======================================================================
|
| Copyright 2006 Mike Anderson
| Written by Mike Anderson
|
| This is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| This code is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| Mumble; see the file COPYING.  If not, write to the Free Software
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
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

