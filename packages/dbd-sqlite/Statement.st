"======================================================================
|
|   SQLite bindings, Statement class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Daniele Sciascia
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



Statement subclass: SQLiteStatement [
    | handle queryString isSelect |
    
    <category: 'DBI-Drivers'>
    <comment: 'I represent a SQLite prepared statement'>
    
    SelectQueries := #('EXPLAIN' 'SELECT') asSet.

    handle [
        <category: 'private'>
        ^handle
    ]
    
    handle: aSqlite3StmtHandle [
        <category: 'private'>
        handle := aSqlite3StmtHandle
    ]
    
    queryString [
        <category: 'accessing'>
        ^queryString
    ]
    
    queryString: aSQLQuery [
        <category: 'accessing'>
        queryString := aSQLQuery.
        
    ]
    
    isSelect [
        <category: 'accessing'>
        isSelect isNil
            ifTrue: [isSelect := SelectQueries includes: self getCommand].
        ^isSelect
    ]
    
    execute [
        <category: 'querying'>
        ^SQLiteResultSet on: self
    ]
    
    executeWithAll: aParams [
        <category: 'querying'>
        | resCode |
        ^[aParams keysAndValuesDo: [:i :param | 
                resCode := self handle bindingAt: i put: param.
                self handle checkError: resCode = 0].
                                          
        SQLiteResultSet on: self] ensure: [self resetAndClear]
    ]
    
    resetAndClear [
        <category: 'private'>
        self handle reset.
        self handle clearBindings.
    ]
    
    getCommand [
        <category: 'private'>
        ^ self class getCommand: queryString.
    ]
]
