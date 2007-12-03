"======================================================================
|
|   SQLite bindings, Row class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Daniele Sciascia
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


Row subclass: SQLiteRow [
    | values |
    
    SQLiteRow class >> forValues: anArray in: aResultSet [
        ^super new 
            values: anArray;
            resultSet: aResultSet;
            yourself
    ]
    
    values: anArray [
        <category: 'private'>
        values := anArray
    ]
    
    at: aColumnName [
	    <category: 'accessing'>
	    ^self atIndex: (resultSet columns at: aColumnName) index
    ]

    atIndex: aColumnIndex [
	    <category: 'accessing'>
	    ^values at: aColumnIndex
    ]
]

