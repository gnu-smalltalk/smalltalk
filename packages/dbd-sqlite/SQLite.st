"======================================================================
|
|   SQLite bindings, bridge to the C library
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


Object subclass: SQLite3Handle [
    | db |

    errorMessage [
        <cCall: 'gst_sqlite3_error_message' returing: #string args: #(#self)>
    ]
    
    checkError: aBoolean [
	aBoolean ifFalse: [ self error: self errorMessage ]
    ]

    changes [
        <category: 'sqlite3 wrapper'>
        <cCall: 'gst_sqlite3_changes' returning: #int args: #(#self)>
    ]
]

SQLite3Handle subclass: SQLite3DBHandle [
    SQLite3DBHandle class >> open: dbname [
	| result rc |
        result := self new.
        rc := result open: dbname.
	rc = 0 ifFalse: [ self error: 'error: ', rc printString ].
	^result
    ]
    
    open: dbname [
        <cCall: 'gst_sqlite3_open' returning: #int args: #(#self #string)>
    ]

    close [
    	<cCall: 'gst_sqlite3_close' returning: #int args: #(#self)>
    ]
    
    prepare: aSQLQuery [
        ^SQLite3StmtHandle forQuery: aSQLQuery onHandle: db
    ]
]

SQLite3Handle subclass: SQLite3StmtHandle [
    | stmt colCount colTypes colNames returnedRow |
    
    SQLite3StmtHandle class >> forQuery: aSQLQuery onHandle: aDbHandle [
	| result rc |
	result := self new db: aDbHandle.
	rc := result prepare: aSQLQuery.
	rc = 0 ifFalse: [ self error: 'error: ', rc printString ].
        ^result
    ]
    
    db [
        <category: 'private'>
        ^db
    ]
    
    db: aDbHandle [
        <category: 'private'>
        db := aDbHandle
    ]
    
    finalize [
        <category: 'private'>
        <cCall: 'gst_sqlite3_finalize' returning: #int args: #(#self)>
    ]
    
    prepare: aSQLQuery [
        <category: 'sqlite3 wrapper'>
        <cCall: 'gst_sqlite3_prepare' returning: #int args: #(#self #string)>
    ]
    
    exec [
        <category: 'sqlite3 wrapper'>
        <cCall: 'gst_sqlite3_exec' returning: #int args: #(#self)>
    ]
    
    bindingAt: index put: value [
        <category: 'sqlite3 wrapper'>
        <cCall: 'gst_sqlite3_bind' returning: #int args: #(#self #smalltalk #smalltalk)>
    ]
    
    clearBindings [
        <category: 'sqlite3 wrapper'>
        <cCall: 'gst_sqlite3_clear_bindings' returning: #int args: #(#self)>
    ]
    
    reset [
        <category: 'sqlite3 wrapper'>
        <cCall: 'gst_sqlite3_reset' returning: #int args: #(#self)>
    ]
    
    colCount [
        <category: 'accessing'>
        ^colCount
    ]
    
    colTypes [
        <category: 'accessing'>
        ^colTypes
    ]
    
    colNames [
        <category: 'accessing'>
        ^colNames
    ]
    
    returnedRow [
        <category: 'accessing'>
        ^returnedRow
    ]
]
