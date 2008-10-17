"======================================================================
|
|   SQLite bindings test suite
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



TestCase subclass: SQLiteBaseTest [
    | connection |
    
    setUp [
	| f |
	f := File name: 'testdb'.
	f exists ifTrue: [ f remove ].
        connection := DBI.Connection
                        connect: 'dbi:SQLite:dbname=testdb'
                        user: nil
                        password: nil.
	connection do: '
	    BEGIN TRANSACTION'.
	connection do: '
	    CREATE TABLE test(int_field integer, string_field text,
			      double_field double)'.
	connection do: '
	    INSERT INTO "test" VALUES(1, "one", 1.0)'.
	connection do: '
	    INSERT INTO "test" VALUES(2, "two", 2.0)'.
	connection do: '
	    INSERT INTO "test" VALUES(3, "three", 3.0)'.
	connection do: '
	    COMMIT'.
    ]
    
    tearDown [
	| f |
        connection close.
	f := File name: 'testdb'.
	f exists ifTrue: [ f remove ].
    ]
    
    connection [
        ^connection
    ]
]

SQLiteBaseTest subclass: SQLiteDMLResultSetTestCase [
    | rs |
    
    setUp [
        super setUp.
        rs := self connection
		 do: 'delete from test where string_field like "t%"'
    ]

    testRowsAffected [
	self assert: rs rowsAffected = 2
    ]
]
    

SQLiteBaseTest subclass: SQLiteResultSetTestCase [
    | rs |
    
    setUp [
        super setUp.
        rs := self connection
		select: 'select * from test'
    ]
    
    testNext [
        self should: [rs position = 0].
        rs next.
        self should: [rs position = 1].
        rs next.
        self should: [rs position = 2].
        rs next.
        self should: [rs atEnd]
    ]
    
    testAtEnd [
        self shouldnt: [rs atEnd].
        rs next.
        self shouldnt: [rs atEnd].
        rs next.
        self shouldnt: [rs atEnd].
        rs next.
        self should: [rs atEnd]
    ]
    
    testColumnNames [
        self should: [rs columnNames = #('int_field' 'string_field' 'double_field')]
    ]
    
    testRowCount [
        self should: [rs rowCount = 3]
    ]
]

SQLiteBaseTest subclass: SQLiteRowTestCase [
    | rs row |
    
    setUp [
        super setUp.
        rs := self connection select: 'select * from test where int_field = 1'.
        row := rs rows at: 1.
    ]
    
    testAt [
        self should: [(row at: 'int_field') = 1].
        self should: [(row at: 'string_field') = 'one'].
        self should: [(row at: 'double_field') = 1.0]
    ]
    
    testAtIndex [
        self should: [(row atIndex: 1) = 1].
        self should: [(row atIndex: 2) = 'one'].
        self should: [(row atIndex: 3) = 1.0]
    ]
]


SQLiteBaseTest subclass: SQLitePreparedStatementTestCase [
    | stmt stmt2 stmt3 |
    
    setUp [
        super setUp.
        stmt := self connection prepare: 'SELECT * FROM test WHERE int_field = ?'.
        stmt2 := self connection prepare: 'SELECT * FROM test WHERE int_field = ? AND string_field = ? AND double_field = ?'.
        stmt3 := self connection prepare: 'SELECT * FROM test WHERE int_field = :i AND string_field = :s AND double_field = :d'.
    ]
    
    testExecute [
        | rs row |
        "execute with one parameter"
        rs := stmt executeWith: 1.
        row := rs rows at: 1.
        self should: [(row atIndex: 1) = 1].
        
        "re-execute so that we are sure that the statement is reset"
        rs := stmt executeWith: 2.
        row := rs rows at: 1.
        self should: [(row atIndex: 1) = 2].
    ]
    
    testExecuteWithAllNamed [
        | rs row |
        rs := stmt3 executeWithAll: (Dictionary from: {
	    ':i' -> 1. ':s' -> 'one'. ':d' -> 1.0 }).
        row := rs rows at: 1.
        self should: [(row atIndex: 1) = 1].
        
        rs := stmt3 executeWithAll: (Dictionary from: {
	    ':i' -> 1. ':s' -> 'two'. ':d' -> 3.0 }).
        self should: [rs rows size = 0].
    ]
    
    testExecuteWithAll [
        | rs row |
        rs := stmt2 executeWithAll: #(1 'one' 1.0).
        row := rs rows at: 1.
        self should: [(row atIndex: 1) = 1].
        
        rs := stmt2 executeWithAll: #(1 'two' 3.0).
        self should: [rs rows size = 0].
    ]
]

TestSuite subclass: SQLiteTestSuite [
    SQLiteTestSuite class >> suite [
        ^super new initialize
    ]
    
    initialize [
        self name: 'SQLite-Test'.
        self addTest: (SQLiteResultSetTestCase selector: #testNext).
        self addTest: (SQLiteResultSetTestCase selector: #testAtEnd).
        self addTest: (SQLiteResultSetTestCase selector: #testColumnNames).
        self addTest: (SQLiteResultSetTestCase selector: #testRowCount).

        self addTest: (SQLiteRowTestCase selector: #testAt).
        self addTest: (SQLiteRowTestCase selector: #testAtIndex).

        self addTest: (SQLiteDMLResultSetTestCase selector: #testRowsAffected).
        
        self addTest: (SQLitePreparedStatementTestCase selector: #testExecute).
        self addTest: (SQLitePreparedStatementTestCase selector: #testExecuteWithAll).
        self addTest: (SQLitePreparedStatementTestCase selector: #testExecuteWithAllNamed).
    ]
]
