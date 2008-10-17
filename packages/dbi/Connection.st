"=====================================================================
|
|   Generic database interface - Connection class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



Object subclass: Connection [
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a connection to a database.'>

    | tables |

    Drivers := LookupTable new.

    Connection class >> updateDriverList [
	"Private - Look for new subclasses of Connection."
	<category: 'initialization'>
	Drivers := LookupTable new.
	Connection allSubclassesDo: [ :each |
	    each driverName isNil ifFalse: [
		Drivers at: each driverName put: each ] ]
    ]

    Connection class >> driverName [
	"Override this method, returning the name of the driver, in every
	 concrete subclass of Connection.  Abstract classes should return
	 nil instead."
	^nil
    ]

    Connection class >> fieldConverterClass [
	"Override this method, returning a subclass of FieldConverter, in every
	 concrete subclass of Connection that needs it."
	^FieldConverter
    ]

    Connection class >> paramConnect: params user: aUserName password: aPassword [
	"Connect to the database server using the parameters in params (a
	Dictionary) and the given username and password (abstract)."

	<category: 'connecting'>
	self subclassResponsibility
    ]

    Connection class >> connect: aDSN user: aUserName password: aPassword [
	"Connect to the database server identified by aDSN using the given
	 username and password.  The DSN is in the format
	 dbi:DriverName:dbname=database_name;host=hostname;port=port
	 Where dbi is constant, DriverName is the name of the driver, and
	 everything else is parameters in the form name1=value1;name2=value2;...
	 
	 Individual drivers may parse the parameters differently, though
	 the existing ones all support parameters dbname, host and port."

	<category: 'connecting'>
	| info driverClass driver |
	info := ConnectionInfo fromDSN: aDSN.
	info scheme asLowercase = 'dbi' 
	    ifFalse: [self error: 'Connection string is not for DBI!'].
	driver := info driver.
	driverClass := Drivers at: driver
		    ifAbsent: [self updateDriverList.
			Drivers at: driver
			    ifAbsent: [self error: 'Unknown driver: ' , driver]].
	^driverClass 
	    paramConnect: info params
	    user: aUserName
	    password: aPassword
    ]

    >> aString [
	"Returns a Table object corresponding to the given table."

	<category: 'accessing'>
	^self tableAt: aString
    ]

    primTableAt: aString ifAbsent: aBlock [
	"Returns a Table object corresponding to the given table.  Should be
	 overridden by subclasses."

	<category: 'querying'>
	self subclassResponsibility
    ]

    tableAt: aString [
	"Returns a Table object corresponding to the given table."

	<category: 'accessing'>
	^self tableAt: aString ifAbsent: [self error: 'Unknown table: ', aString]
    ]

    tableAt: aString ifAbsent: aBlock [
	"Returns a Table object corresponding to the given table."

	<category: 'accessing'>
	tables isNil ifTrue: [ tables := LookupTable new ].
	^tables at: aString ifAbsentPut: [self primTableAt: aString ifAbsent: aBlock]
    ]

    do: aSQLQuery [
	"Executes a SQL statement (usually one that doesn't return a result set).
	 Return value is a ResultSet, to which you can send #rowsAffected
	 (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    prepare: aSQLQuery [
	"Creates a statement object, that can be executed (with parameters, if
	 applicable) repeatedly (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    select: aSQLQuery [
	"Prepares and executes a SQL statement. Returns the result set or
	 throws an exception on failure (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    close [
	"Close the connection now; should happen on GC too (abstract)."

	<category: 'connecting'>
	self subclassResponsibility
    ]

    fieldConverter [
	"Returns a FieldConverter that can be used to insert Smalltalk
	 objects into queries."

	<category: 'accessing'>
	^self class fieldConverterClass uniqueInstance
    ]

    database [
	"Returns the database name for this connection.  This corresponds
	 to the catalog in SQL standard parlance (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]
]



Eval [
    Connection initialize
]

