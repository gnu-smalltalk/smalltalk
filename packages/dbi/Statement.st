"=====================================================================
|
|   Generic database interface - Statement class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008, 2011 Free Software Foundation, Inc.
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



Object subclass: Statement [
    | connection |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a prepared statement.'>

    Statement class >> on: aConnection [
        "Return a new statement for this connection."

        <category: 'instance creation'>
        ^self new
            connection: aConnection;
            yourself
    ]

    Statement class >> getCommand: queryString [
        | readStream writeStream aCharacter |
        writeStream := WriteStream on: String new.
        readStream := ReadStream on: queryString.
        readStream skipSeparators.
        [readStream atEnd
	    or: [aCharacter := readStream next. aCharacter isSeparator]]
                whileFalse: [writeStream nextPut: aCharacter asUppercase].
        ^writeStream contents
    ]

    connection [
        "Return the connection for which the statement was prepared."

        <category: 'private'>
        ^connection
    ]

    connection: aConnection [
        "Associate the statement to the given Connection."

        <category: 'private'>
        connection := aConnection
    ]

    execute [
	"Execute with no parameters (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    executeWith: aParameter [
	"Execute with one parameters."

	<category: 'querying'>
	^self executeWithAll: {aParameter}
    ]

    executeWith: aParam1 with: aParam2 [
	"Execute with two parameters."

	<category: 'querying'>
	^self executeWithAll: 
		{aParam1.
		aParam2}
    ]

    executeWith: aParam1 with: aParam2 with: aParam3 [
	"Execute with three parameters."

	<category: 'querying'>
	^self executeWithAll: 
		{aParam1.
		aParam2.
		aParam3}
    ]

    executeWithAll: aParams [
	"Execute taking parameters from the Collection aParams (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]
]

