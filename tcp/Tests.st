"======================================================================
|
|   Smalltalk TCP/IP sockets - Tests & examples
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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


!Socket class methodsFor: 'tests'!

microTest
    "Extremely small test (try to receive SMTP header)"

    | s |
    s := Socket remote: IPAddress anyLocalAddress port: 25.
    (s upTo: Character cr) printNl.
    s close
!

tweakedLoopbackTest
    "Send data from one socket to another on the local machine, trying to avoid
     buffering overhead.  Tests most of the socket primitives.  Comparison of
     the results of loopbackTest and tweakedLoopbackTest should give a measure
     of the overhead of buffering when sending/receiving large quantities of
     data."

    ^self loopbackTest: #(5000 4000)
!

loopbackTest
    "Send data from one socket to another on the local machine. Tests most of
     the socket primitives."

    ^self loopbackTest: nil
!

loopbackTest: bufferSizes
    "Send data from one socket to another on the local machine. Tests most of
     the socket primitives.  The parameter is the size of the input and
     output buffer sizes."

    | queue server client bytesToSend sendBuf bytesSent
      bytesReceived t extraBytes timeout process |

    Transcript
	cr; show: 'starting loopback test'; cr.

    queue := ServerSocket port: 54321 queueSize: 5 bindTo: nil.
    client := Socket remote: queue localAddress port: 54321.

    bufferSizes isNil ifFalse: [
	client
	    readBufferSize: (bufferSizes at: 1);
	    writeBufferSize: (bufferSizes at: 2)
    ].

    timeout := false.
    process := [
	(Delay forMilliseconds: Socket timeout) wait.
	timeout := true
    ] fork.
    [   timeout ifTrue: [ self error: 'could not establish connection' ].
	(server := queue accept) isNil ] whileTrue: [ Processor yield ].

    process terminate.
    Transcript show: 'connection established'; cr.

    bytesToSend := 5000000.
    sendBuf := String new: 4000 withAll: $x.
    bytesSent := bytesReceived := 0.
    t := Time millisecondsToRun: [
	[
	    server nextPutAll: sendBuf; flush.
	    bytesSent := bytesSent + sendBuf size.
	    [ client available ] whileTrue: [
		client fill.
		bytesReceived := bytesReceived +
		    client bufferContents size.
	    ].
	    (bytesSent >= bytesToSend) and: [bytesReceived = bytesSent]
	] whileFalse
    ].

    Transcript show: 'closing connection'; cr.
    extraBytes := client bufferContents size.
    server close.
    extraBytes > 0 ifTrue: [
	Transcript show: ' *** received ', extraBytes size printString, ' extra bytes ***'; cr.
    ].
    client close.
    queue close.
    Transcript 
	show: 'loopback test done; ', (t / 1000.0) printString, ' seconds'; cr;
	show: ((bytesToSend asFloat / t) roundTo: 0.01) printString;
	showCr: ' kBytes/sec'.
!

producerConsumerTest
    "Send data from one socket to another on the local machine. Tests most of the
     socket primitives and works with different processes."

    | bytesToSend bytesSent bytesReceived t server client queue sema
      producer consumer queueReady |

    Transcript
	cr; show: 'starting loopback test'; cr.

    sema := Semaphore new.
    queueReady := Semaphore new.
    bytesToSend := 5000000.
    bytesSent := bytesReceived := 0.

    t := Time millisecondsToRun: [
	producer := [
	    | timeout process sendBuf |
	    queue := ServerSocket port: 54321 queueSize: 5 bindTo: nil.
	    queueReady signal.

	    timeout := false.
	    process := [
		(Delay forMilliseconds: Socket timeout) wait.
		timeout := true
	    ] fork.
	    [
		timeout ifTrue: [ self error: 'could not establish connection' ].
		(server := queue accept) isNil
	    ] whileTrue: [ Processor yield ].
	    process terminate.

	    Transcript show: 'connection established'; cr.
	    sendBuf := String new: 4000 withAll: $x.
	    [
		server nextPutAll: sendBuf.
		bytesSent := bytesSent + sendBuf size.
		(bytesSent >= bytesToSend)
	    ] whileFalse: [ Processor yield ].
	    sema signal.
	] fork.

	consumer := [
	    queueReady wait.
	    client := Socket remote: queue localAddress port: 54321.
	    [
		[ client available ] whileTrue: [
		    client fill.
		    bytesReceived := bytesReceived + client bufferContents size.
		].
		(bytesSent >= bytesToSend) and: [bytesReceived = bytesSent]
	    ] whileFalse: [ Processor yield ].
	    sema signal.
	] fork.

	sema wait.
	sema wait.
    ].
    Transcript show: 'closing connection'; cr.
    server close.
    client close.
    queue close.
    Transcript 
	show: 'loopback test done; ', (t / 1000.0) printString, ' seconds'; cr;
	show: ((bytesToSend asFloat / t) roundTo: 0.01) printString;
	showCr: ' kBytes/sec'.
!

udpLoopbackTest
    "Send data from one UDP socket to another on the local machine. Tests most of the
     socket primitives and works with different processes."

    | bytesToSend bytesSent bytesReceived t |

    Transcript
	cr; show: 'starting udp loopback test'; cr.

    bytesToSend := 5000000.
    bytesSent := bytesReceived := 0.

    t := Time millisecondsToRun: [
	| server client datagram |
	client := DatagramSocket port: 54322.
	server := DatagramSocket
	    remote: IPAddress anyLocalAddress port: 54322
	    local: nil port: 54321.

	datagram := Datagram data: (String new: 128 withAll: $x) asByteArray.
	[
	    server nextPut: datagram; flush.
	    bytesSent := bytesSent + datagram data size.
	    [ client available ] whileTrue: [
		bytesReceived := bytesReceived + client next data size ].
	    bytesReceived < bytesToSend
	] whileTrue.

	Transcript show: 'closing connection'; cr.
	server close.
	client close.
    ].
    Transcript 
	show: 'udp loopback test done; ', (t / 1000.0) printString, ' seconds'; cr;
	show: '% packets lost ', (100 - (bytesReceived / bytesSent * 100)) asFloat printString; cr;
	show: ((bytesToSend asFloat / t) roundTo: 0.01) printString;
	showCr: ' kBytes/sec'.
!

sendTest
    "Send data to the 'discard' socket of localhost."
    ^self sendTest: '127.0.0.1'
!

sendTest: host
    "Send data to the 'discard' socket of the given host. Tests the speed of
     one-way data transfers across the network to the given host. Note that
     many hosts do not run a discard server."
    "Socket sendTest: 'localhost'"

    | sock bytesToSend sendBuf bytesSent t |
    Transcript cr; show: 'starting send test'; cr.
    sock := Socket remote: host port: Socket portDiscard.
    Transcript show: 'connection established'; cr.

    bytesToSend := 5000000.
    sendBuf := String new: 4000 withAll: $x.
    bytesSent := 0.
    t := Time millisecondsToRun: [
	[bytesSent < bytesToSend] whileTrue: [
	    sock nextPutAll: sendBuf; flush.
	    bytesSent := bytesSent + sendBuf size.
	]
    ].
    Transcript show: 'closing connection'; cr.
    sock close.
    Transcript 
	show: 'send test done; time = ', (t / 1000) asFloat printString, ' seconds'; cr;
	show: (bytesToSend asFloat / t) printString;
	showCr: ' kBytes/sec'.
! !

