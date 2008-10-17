"======================================================================
|
|   SQLite bindings, Connection class
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


Connection subclass: SQLiteConnection [
	| dbName stmtHandles handle |
	
	<category: 'DBI-Drivers'>
	<comment: 'I represent a connection to a SQLite database'>
	
	
	SQLiteConnection class >> paramConnect: params user: aUserName password: aPassword [
        <category: 'connecting'>
		| dbName aSqlite3Handle |
		
		dbName := params at: 'dbname'
		ifAbsent: [self error: 'Missing parameter: dbname'].
		aSqlite3Handle := SQLite3DBHandle open: dbName.
		^(self new)
		    initializeWithHandle: aSqlite3Handle;
		    database: dbName;
		    yourself
	]
	
	initializeWithHandle: aSqlite3Handle [ 
	    handle := aSqlite3Handle.
	    stmtHandles := WeakIdentitySet new.
	]
	
	database: aString [
	    <category: 'accessing'>
	    dbName := aString
	]
	
	database [
	    <category: 'accessing'>
	    ^dbName
	]
	
	close [
	    <category: 'connecting'>
	    stmtHandles do: [ :each | each removeToBeFinalized; finalize ].
	    ^handle close
	]
	
	SQLiteConnection class >> driverName [
	    <category: 'initialization'>
		^'SQLite'
	]
	
    handle [
        <category: 'private'>
        ^handle
    ]
	
	finalize [
	    <category: 'private'>
	    self close
	]
	
    do: aSQLQuery [
        <category: 'querying'>
        ^(self prepare: aSQLQuery) execute
    ]

    select: aSQLQuery [
        <category: 'querying'>
    	^(self prepare: aSQLQuery) execute
    ]

    prepare: aSQLQuery [
        <category: 'querying'>
        | stmtHandle |  
        stmtHandle := self handle prepare: aSQLQuery.
        stmtHandle addToBeFinalized.
        stmtHandles add: stmtHandle.
        ^(SQLiteStatement on: self)
                    handle: stmtHandle;
                    queryString: aSQLQuery.
    ]

    primTableAt: aString ifAbsent: aBlock [
	| table |
	[
	    table := (SQLiteTable name: aString connection: self)
		columnsArray;
		yourself ]
	    on: Error
	    do: [ :ex | ex return ].

	table isNil ifTrue: [ ^aBlock value ].
	^table
    ]
]
