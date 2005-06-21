"======================================================================
|
|   Generic server framework
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2005 Free Software Foundation, Inc.
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

Namespace current: NetClients!

Object subclass:  #NetThread
	instanceVariableNames: 'process socket priority '
	classVariableNames: ''
	poolDictionaries: 'TCP '
	category: 'Sockets-Serving framework'!

NetThread comment: 
'A NetThread runs a process attached to a specified socket.'!

NetThread subclass:  #NetServer
	instanceVariableNames: 'port process '
	classVariableNames: 'Servers '
	poolDictionaries: ''
	category: 'Sockets-Serving framework'!

NetServer comment: 
'A NetServer keeps a socket listening on a port, and dispatches incoming
requests to NetSession objects.'!

NetThread subclass:  #NetSession
	instanceVariableNames: 'server '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sockets-Serving framework'!

NetSession comment: 
'NetSessions divide a session in separate requests and provide 
exception handling for those.'!

!NetThread class methodsFor: 'instance creation'!

new
    ^self basicNew initialize! !

!NetThread methodsFor: 'initialize-release'!

defaultPriority
    ^Processor userSchedulingPriority!

initialize
    priority := self defaultPriority!

release
    self stop.
    super release! !

!NetThread methodsFor: 'printing'!

printOn: aStream
    aStream print: self class; nextPut: $:.
    self isRunning ifFalse: [ ^aStream nextPutAll: 'idle' ].
    aStream print: self socket port
! !

!NetThread methodsFor: 'private'!

createSocket
    self subclassResponsibility
!

newProcess
    ^[ self run ] forkAt: priority
!

socket
    ^socket
! !

!NetThread methodsFor: 'running'!

run
    self subclassResponsibility
! !

!NetThread methodsFor: 'serving'!

isRunning
    ^process notNil!

start
    self isRunning ifTrue: [^self].
    socket := self createSocket.
    process := self newProcess!

stop
    self isRunning
	ifTrue:
	    [process terminate.
	    process := nil.
	    socket close.
	    socket := nil.
	    ]! !


!NetServer class methodsFor: 'accessing'!

at: port
    | server |
    Servers isNil ifTrue: [ Servers := Dictionary new ].
    ^Servers at: port ifAbsentPut: [ self new ].
!

initializeServer: port
    | server |
    server := self at: port.
    server isRunning ifFalse: [server startOn: port].
    ^server
!

terminateServer: port
    Servers isNil ifTrue: [ ^self ].
    (Servers includesKey: port) ifTrue: [ 
	(Servers at: port) release.
	Servers removeKey: port.
    ]
! !

!NetServer methodsFor: 'abstract'!

newSession
    self subclassResponsibility
!

respondTo: aRequest
    self subclassResponsibility
! !

!NetServer methodsFor: 'accessing'!

port
    ^port!

port: anObject
    self stop.
    port := anObject!

priority
    ^priority!

priority: anInteger
    priority := anInteger.
    self isRunning ifTrue: [process priority: priority]!

startOn: aPortNumber
    self port: aPortNumber.
    self start
! !

!NetServer methodsFor: 'private'!

createSocket
    ^ServerSocket port: port
!

defaultPriority
    ^Processor lowIOPriority!

run
    Processor activeProcess name: 'listen'.
    [
        socket waitForConnection.
        self newSession
	    server: self;
	    start
    ] repeat! !


!NetSession methodsFor: 'abstract'!

log: request time: milliseconds
!

next
    self subclassResponsibility
! !

!NetSession methodsFor: 'accessing'!

server
    ^server
!

server: aServer
    server := aServer
! !

!NetSession methodsFor: 'private'!

createSocket
    ^server socket accept
!

run
    | req time |
    Processor activeProcess name: 'connection'.
    [
	[
	    req := self next.
	    time := Time millisecondsToRun: [
		self server respondTo: req.
		req release
	    ]
	]   on: ExAll
	    do: [ :ex |
		"Ignore errors due to bad communication lines."
		self socket isPeerAlive ifFalse: [ ex return ].
		ex pass
	    ].

	self log: req time: time.

	self socket isPeerAlive
    ] whileTrue
!

stop
    super stop.
! !


Namespace current: Smalltalk!
