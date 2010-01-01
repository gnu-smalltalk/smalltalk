"=====================================================================
|
|   PosgreSQL DBI driver - FieldConverter class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
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


FieldConverter subclass: PGFieldConverter [
    
    <category: 'DBD-PostgreSQL'>
    <comment: nil>

    writeBoolean: aBoolean on: aStream [
        <category: 'converting-smalltalk'>
        aStream nextPut: $'.
        aStream nextPut: (aBoolean ifTrue: [ $t ] ifFalse: [ $f ])
        aStream nextPut: $'.
    ]

    writeDateTime: aDateTime on: aStream [
        <category: 'converting-smalltalk'>
        aStream nextPutAll: 'timestamp '.
	aDateTime offset = 0
	    ifFalse: [ aStream nextPutAll: 'with time zone ' ].
        aStream nextPut: $'.
        aDateTime printOn: aStream.
        aStream nextPut: $'.
    ]

    writeQuotedTime: aTime on: aStream [
        <category: 'converting-smalltalk'>
	"HACK.  Time should support timezones too."
	(aTime respondsTo: #offset)
	     ifTrue: [ self writeDateTime: aTime on: aStream ]
	     ifFalse: [ super writeTime: aTime on: aStream ]
    ]
]
