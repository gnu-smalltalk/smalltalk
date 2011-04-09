"======================================================================
|
|   PostgreSQL bindings, Statement class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2011 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther
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


Statement subclass: PGStatement [
    | dbHandle queryString isSelect |

    <category: 'DBI-Drivers'>
    <comment: 'I represent a Postgres prepared statement. Or actually right
now the ability to execute commands with binding.'>

    SelectQueries := #('EXPLAIN' 'SELECT') asSet.

    dbHandle: aHandle [
        <category: 'private'>
        dbHandle := aHandle.
    ]

    queryString [
        <category: 'accessing'>
        ^queryString
    ]

    queryString: aSQLQuery [
        <category: 'accessing'>
        "In PostgreSQL one can use $1 for binding parameters with the
         executeWithAll:. The parameters must be all strings."
        queryString := aSQLQuery.
    ]

    isSelect [
        <category: 'accessing'>
        isSelect isNil
            ifTrue: [isSelect := SelectQueries includes: (self class getCommand: queryString)].
        ^isSelect
    ]

    checkResult: aRes [
        <category: 'private'>
        self isSelect
            ifTrue:  [aRes checkStatusForSelect]
            ifFalse: [aRes checkStatusForDo].
        ^ aRes
    ]

    execute [
        <category: 'querying'>
        | res |
        res := PGResultSet new: (dbHandle exec: queryString).
        ^ self checkResult: res.
    ]

    executeWithAll: params [
        | res strings |
        "In PostgreSQL one can use $1 for binding parameters with the
         executeWithAll:. The parameters must be all strings."
        strings := params collect: [ :each |
            each isString ifTrue: [each]
                ifFalse: [self connection fieldConverter printString: each]].

        res := PGResultSet new: (dbHandle exec: queryString with: strings).
        ^ self checkResult: res.
    ]
]
