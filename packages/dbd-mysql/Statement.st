"=====================================================================
|
|   MySQL DBI driver - Statement class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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
 ======================================================================"


Statement subclass: MySQLStatement [
    | statement isSelect |

    <category: 'DBI-Framework'>
    <comment: 'I represent a prepared statement.'>

    SelectQueries := #('EXPLAIN' 'SELECT' 'SHOW' 'DESCRIBE') asSet.

    getCommand [
        | readStream writeStream aCharacter |
        writeStream := WriteStream on: String new.
        readStream := ReadStream on: statement.
        readStream skipSeparators.
        [readStream atEnd
	    or: [aCharacter := readStream next. aCharacter isSeparator]]
                whileFalse: [writeStream nextPut: aCharacter asUppercase].
        ^writeStream contents
    ]

    prepare: aSQLString [
	"Prepare the statement in aSQLString."

	<category: 'private'>
	statement := aSQLString.
	isSelect := SelectQueries includes: self getCommand.
    ]

    statement [
	"Return the SQL template."
	^statement
    ]

    execute [
	"Execute with no parameters"

	<category: 'abstract'>
        | queryInfo |
        connection requestPacket writeStream
            nextPutCommand: #cmdQuery message: statement;
            flush.

	^MySQLResultSet on: self
    ]

    isSelect [
	"Return whether the query is a SELECT-type query."
	^isSelect
    ]

    executeWithAll: aParams [
	"Execute taking parameters from the Collection aParams."

	<category: 'not implemented'>
	self notYetImplemented
    ]
]

