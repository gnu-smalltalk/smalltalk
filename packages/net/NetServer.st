"======================================================================
|
|   Generic server framework
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2005, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
|
| This file is part of the GNU Smalltalk class library.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published by
| the Free Software Foundation; either version 2.1, or (at your option) 
| any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU Lesser General Public License 
| along with GNU Smalltalk; see the file COPYING.LIB.  If not, write to 
| the Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
| 02110-1301, USA.
|
 ======================================================================"



Object subclass: NetThread [
    | process socket priority |
    
    <import: Sockets>
    <category: 'Sockets-Serving framework'>
    <comment: 'A NetThread runs a process attached to a specified socket.'>

    NetThread class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    defaultPriority [
	<category: 'initialize-release'>
	^Processor userSchedulingPriority
    ]

    initialize [
	<category: 'initialize-release'>
	priority := self defaultPriority
    ]

    release [
	<category: 'initialize-release'>
	socket close.
	socket := nil.
	super release
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $:.
	self isRunning ifFalse: [^aStream nextPutAll: 'idle'].
	aStream print: self socket port
    ]

    createSocket [
	<category: 'private'>
	self subclassResponsibility
    ]

    startNewProcess [
	<category: 'private'>
	process := ([self run] newProcess)
		    priority: priority;
		    name: self class name , ' Process';
		    yourself.
	process resume
    ]

    isPeerAlive [
	<category: 'private'>
	^socket notNil and: [socket isPeerAlive]
    ]

    socket [
	<category: 'private'>
	^socket
    ]

    run [
	<category: 'running'>
	self subclassResponsibility
    ]

    isRunning [
	<category: 'serving'>
	^process notNil
    ]

    start [
	<category: 'serving'>
	self isRunning ifTrue: [^self].
	socket := self createSocket.
	self startNewProcess
    ]
]



NetThread subclass: NetServer [
    | port |
    
    <category: 'Sockets-Serving framework'>
    <comment: 'A NetServer keeps a socket listening on a port, and dispatches incoming
requests to NetSession objects.'>

    Servers := nil.

    NetServer class >> at: port [
	<category: 'accessing'>
	| server |
	Servers isNil ifTrue: [Servers := Dictionary new].
	^Servers at: port
	    ifAbsentPut: 
		[(self new)
		    port: port;
		    yourself]
    ]

    NetServer class >> initializeServer: port [
	<category: 'accessing'>
	| server |
	server := self at: port.
	server isRunning ifFalse: [server startOn: port].
	^server
    ]

    NetServer class >> terminateServer: port [
	<category: 'accessing'>
	Servers isNil ifTrue: [^self].
	(Servers includesKey: port) 
	    ifTrue: 
		[(Servers at: port) release.
		Servers removeKey: port]
    ]

    newSession [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    respondTo: aRequest [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    port [
	<category: 'accessing'>
	^port
    ]

    port: anObject [
	<category: 'accessing'>
	self stop.
	port := anObject
    ]

    priority [
	<category: 'accessing'>
	^priority
    ]

    priority: anInteger [
	<category: 'accessing'>
	priority := anInteger.
	self isRunning ifTrue: [process priority: priority]
    ]

    startOn: aPortNumber [
	<category: 'accessing'>
	self port: aPortNumber.
	self start
    ]

    createSocket [
	<category: 'private'>
	^ServerSocket port: port
    ]

    defaultPriority [
	<category: 'private'>
	^Processor lowIOPriority
    ]

    run [
	<category: 'private'>
	Processor activeProcess name: 'listen'.
	
	[socket waitForConnection.
	(self newSession)
	    server: self;
	    start] 
		repeat
    ]

    release [
	<category: 'initialize-release'>
	self stop.
	super release
    ]

    stop [
	<category: 'serving'>
	self isRunning 
	    ifTrue: 
		[process terminate.
		process := nil.
		socket close.
		socket := nil]
    ]
]



NetThread subclass: NetSession [
    | server |
    
    <category: 'Sockets-Serving framework'>
    <comment: 'NetSessions divide a session in separate requests and provide 
exception handling for those.'>

    log: request time: milliseconds [
	<category: 'abstract'>
	
    ]

    next [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    server [
	<category: 'accessing'>
	^server
    ]

    server: aServer [
	<category: 'accessing'>
	server := aServer
    ]

    createSocket [
	<category: 'private'>
	^server socket accept
    ]

    run [
	<category: 'private'>
	| req time |
	Processor activeProcess name: 'connection'.
	
	[
	[req := self next.
	time := Time millisecondsToRun: 
			[self server respondTo: req.
			req release]] 
		on: Error
		do: 
		    [:ex | 
		    "Ignore errors due to bad communication lines."

		    self isPeerAlive ifFalse: [ex return].
		    ex pass].
	self log: req time: time.
	self isPeerAlive] 
		whileTrue
    ]
]

