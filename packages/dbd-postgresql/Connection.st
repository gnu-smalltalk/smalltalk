"=====================================================================
|
|   PosgreSQL DBI driver - Connection class and related classes
|
|
 ======================================================================"

"======================================================================
|
| Written by Mike Anderson gnu-smalltalk@gingerbread.plus.com 2006
| Based on PostgreSQL interface by Thomas Braun shin@shin.homelinux.net
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



Connection subclass: PGConnection [
    | handle |
    
    <comment: nil>
    <category: 'DBI-Drivers'>

    PGConnection class >> driverName [
	<category: 'initialization'>
	^'PostgreSQL'
    ]

    PGConnection class >> fieldConverterClass [
	<category: 'initialization'>
	^PGFieldConverter
    ]

    ConnectionStatus := #(#CONNECTION_OK
	#CONNECTION_BAD
	#CONNECTION_STARTED
	#CONNECTION_MADE
	#CONNECTION_AWAITING_RESPONSE
	#CONNECTION_AUTH_OK
	#CONNECTION_SETENV
	#CONNECTION_SSL_STARTUP
	#CONNECTION_NEEDED).

    PGConnection class >> connectionStatus: aCode [
	<category: 'constants'>
	^ConnectionStatus at: aCode + 1
    ]

    PGConnection class >> unrecognizedParameters [
	<category: 'private'>

	"These are the synonymous parameters which our superclass adds and
	 PQconnectdb does not understand"

	^#('db' 'database' 'hostname').
    ]

    PGConnection class >> paramConnect: aParams user: aUserName password: aPassword [
	"Normally you would use Connection>>connect:user:password: with a DSN
	 specifying the appropriate driver string.
	 Note that aUserName and aPassword may be nil; for Postgres, the username
	 defaults to the OS user if not supplied."

	<category: 'instance creation'>
	"Assemble a connection string in the right format"

	| connStr connParams handle conn connOK |
	connParams := OrderedCollection new.
	aParams keysAndValuesDo: [:k :v |
	    (self unrecognizedParameters includes: k)
		ifFalse: [connParams add: k , '=' , v]].

	aUserName notNil ifTrue: [connParams add: 'user=' , aUserName].
	aPassword notNil ifTrue: [connParams add: 'password=' , aPassword].
	connStr := connParams inject: '' into: [ :a :b | a, ' ', b ].
	handle := PQConnection connect: connStr.
	connOK := self connectionStatus: handle status.
	connOK == #CONNECTION_OK 
	    ifFalse: 
		[handle finish.
		self error: 'Connection failed (' , connOK , ')'].
	^(self new)
	    handle: handle;
	    yourself
    ]

    handle: aCObject [
	<category: 'private'>
	handle := aCObject.
	self addToBeFinalized
    ]

    finalize [
	<category: 'private'>
	self close
    ]

    do: aSQLQuery [
	<category: 'implementations'>
	^(PGResultSet new: (handle exec: aSQLQuery))
	    checkStatusForDo;
	    yourself
    ]

    prepare: aSQLQuery [
	"FIXME"

	<category: 'implementations'>
	self notYetImplemented
    ]

    select: aSQLQuery [
	<category: 'implementations'>
	^(PGResultSet new: (handle exec: aSQLQuery))
	    checkStatusForSelect;
	    yourself
    ]

    close [
	<category: 'implementations'>
	handle finish
    ]

    beginTransaction [
	<category: 'implementations'>
	^self do: 'BEGIN'
    ]

    commitTransaction [
	<category: 'implementations'>
	^self do: 'COMMIT'
    ]

    rollbackTransaction [
	<category: 'implementations'>
	^self do: 'ROLLBACK'
    ]

    database [
	<category: 'accessing'>
	^handle database
    ]

    primTableAt: aString ifAbsent: aBlock [
	| table |
	table := PGTable name: aString connection: self.
	table columnsArray isEmpty ifTrue: [ ^aBlock value ].
	^table
    ]
]


CObject subclass: PQConnection [
    "Connections"
    PQConnection class >> connect: aString [
        <cCall: 'PQconnectdb' returning: #{PQConnection} args: #(#string)>
    ]
    status [
        <cCall: 'PQstatus' returning: #int args: #(#self)>
    ]

    database [
        <cCall: 'PQdb' returning: #string args: #(#self)>
    ]

    errorMessage [
        <cCall: 'PQerrorMessage' returning: #string args: #(#self)>
    ]

    finish [
        <cCall: 'PQfinish' returning: #void args: #(#self)>
    ]

    "Executing SQL"
    exec: aSqlStatement [
        <cCall: 'PQexec' returning: #{PQResultSet} args: #(#self #string)>
    ]
]


