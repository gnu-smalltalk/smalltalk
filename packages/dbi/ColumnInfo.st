"=====================================================================
|
|   Generic database interface - ColumnInfo class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
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



Object subclass: ColumnInfo [
    
    <category: 'DBI-Framework'>
    <comment: nil>

    name [
	"Return the name of the column (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    index [
	"Return the 1-based index of the column in the result set (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    isNullable [
	"Return whether the column can be NULL (always returns true in
	 ColumnInfo)."
	<category: 'accessing'>
	^true
    ]

    type [
	"Return a string containing the type of the column (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    size [
	"Return the size of the column (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."
	<category: 'printing'>
	aStream
	    nextPutAll: self name;
	    nextPut: $(;
	    nextPutAll: self type;
	    nextPut: $)
    ]
]

