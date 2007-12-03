"======================================================================
|
|   SQLite bindings, ColumnInfo class
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


ColumnInfo subclass: SQLiteColumnInfo [
    | resultSet index |
    
    TypeNames := nil.
    
    SQLiteColumnInfo class >> in: aResultSet at: anIndex [
        ^(self new)
            index: anIndex;
            resultSet: aResultSet;
            yourself
    ]
    
    SQLiteColumnInfo class >> initTypes [
        TypeNames := LookupTable new.
        TypeNames at: 1 put: 'Integer'.
        TypeNames at: 2 put: 'Float'.
        TypeNames at: 3 put: 'Text'.
        TypeNames at: 4 put: 'Blob'.
        TypeNames at: 5 put: 'Null'.
    ]
    
    resultSet: aResultSet [
        <category: 'private'>
        resultSet := aResultSet
    ]
    
    name [
	    <category: 'accessing'>
	    ^resultSet columnAt: self index
    ]

    index [
	    <category: 'accessing'>
        ^index
    ]
    
    index: anIndex [
        <category: 'private'>
        index := anIndex
    ]

    type [
	    <category: 'accessing'>
        ^TypeNames at: (resultSet columnTypeAt: self index)
    ]

    size [
	    "Return the size of the column (abstract)."
	    <category: 'accessing'>
	    self notYetImplemented
    ]

    printOn: aStream [
	    <category: 'printing'>
	    aStream
	        nextPutAll: self name;
	        nextPut: $(;
	        nextPutAll: self type;
	        nextPut: $)
    ]
]

Eval [
    SQLiteColumnInfo initTypes
]
