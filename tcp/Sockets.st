"======================================================================
|
|   Smalltalk TCP/IP sockets - Stream hierarchy
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


Stream subclass: #AbstractSocket
	  instanceVariableNames: 'impl'
	  classVariableNames: 'CheckPeriod Timeout DefaultAddressClass'
	  poolDictionaries: ''
	  category: 'Sockets-Streams'
!

AbstractSocket subclass: #DatagramSocket
	instanceVariableNames: ''
	classVariableNames: 'DefaultBufferSize '
	poolDictionaries: ''
	category: 'Sockets-Streams'
!

DatagramSocket subclass: #MulticastSocket
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sockets-Streams'
!

AbstractSocket subclass: #ServerSocket
	  instanceVariableNames: ''
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Sockets-Streams'
!

AbstractSocket subclass: #Socket
	  instanceVariableNames: 'lookahead peerDead readBuffer writeBuffer outOfBand'
	  classVariableNames: 'Ports ReadBufferSize WriteBufferSize'
	  poolDictionaries: ''
	  category: 'Sockets-Streams'
!

!AbstractSocket class methodsFor: 'timed-out operations'!

checkPeriod
    "Answer the period that is to elapse between socket polls if data
     data is not ready and the connection is still open (in milliseconds)"
    ^CheckPeriod
!

checkPeriod: anInteger
    "Set the period that is to elapse between socket polls if data
     data is not ready and the connection is still open (in milliseconds)"
    CheckPeriod := anInteger truncated
!

timeout
    "Answer the period that is to elapse between the request for (yet
     unavailable) data and the moment when the connection is considered dead
     (in milliseconds)"
    ^Timeout
!

timeout: anInteger
    "Set the period that is to elapse between the request for (yet
     unavailable) data and the moment when the connection is considered
     dead (in milliseconds)"
    Timeout := anInteger truncated
! !

!AbstractSocket class methodsFor: 'defaults'!

defaultImplementationClass
    "Answer the default implementation class.  Depending on the
     subclass, this might be the default stream socket implementation
     class of the default address class, or rather its default datagram
     socket implementation class"
    self subclassResponsibility
!
 
defaultAddressClass
    "Answer the default address family to be used.  In the library,
     the address family is represented by a subclass of SocketAddress
     which is by default IPAddress."
    ^DefaultAddressClass
!

defaultAddressClass: class
    "Set the default address family to be used.  In the library,
     the address family is represented by a subclass of SocketAddress
     which is by default IPAddress."
    DefaultAddressClass := class
! !

!AbstractSocket class methodsFor: 'instance creation'!

new: implementation
    "Answer a new instance of the receiver, using as the underlying
     layer the object passed as the `implementation' parameter; the
     object is probably going to be some kind of AbstractSocketImpl."
    ^super new initialize: implementation
!

new
    self shouldNotImplement
! !

!AbstractSocket methodsFor: 'socket options'!

soLinger
    "Answer the number of seconds that the socket is allowed to wait
     if it promises reliable delivery but has unacknowledged/untransmitted
     packets when it is closed, or nil if those packets are left to their
     destiny or discarded."
    ^self implementation soLinger
!

soLinger: linger
    "Set the number of seconds that the socket is allowed to wait
     if it promises reliable delivery but has unacknowledged/untransmitted
     packets when it is closed."
    ^self implementation soLinger: linger
!

soLingerOff
    "Specify that, even if the socket promises reliable delivery, any
     packets that are unacknowledged/untransmitted when it is closed
     are to be left to their destiny or discarded."
    ^self implementation soLinger: nil
!

species
    ^String
! !

!AbstractSocket methodsFor: 'accessing'!

address
    "Answer an IP address that is of common interest (this can be either
     the local or the remote address, according to the definition in the
     subclass)."
    self subclassResponsibility
!

available
    "Answer whether there is data available on the socket."
    ^self implementation canRead
!

close
    "Close the socket represented by the receiver."
    self flush.
    self implementation close.
!

flush
    "Flush any buffers used by the receiver."
!

isOpen
    "Answer whether the connection between the receiver and the remote
     endpoint is still alive."
    self implementation isNil ifTrue: [ ^false ].
    ^self implementation isOpen
!

localAddress
    "Answer the local IP address of the socket."
    self implementation isNil ifTrue: [ self error: 'socket not connected' ].
    ^self implementation localAddress
!

localPort
    "Answer the local IP port of the socket."
    self implementation isNil ifTrue: [ self error: 'socket not connected' ].
    ^self implementation localPort
!

port
    "Answer an IP port that is of common interest (this can be the port for 
     either the local or remote endpoint, according to the definitions in the
     subclass"
    self subclassResponsibility
!

remoteAddress
    "Answer the IP address of the socket's remote endpoint."
    self implementation isNil ifTrue: [ self error: 'socket not connected' ].
    ^self implementation remoteAddress
!

remotePort
    "Answer the IP port of the socket's remote endpoint."
    self implementation isNil ifTrue: [ self error: 'socket not connected' ].
    ^self implementation remotePort
! !

!AbstractSocket methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream
	print: self class;
	nextPut: $[;
	print: self address;
	nextPut: $: ;
	print: self port;
	nextPutAll: ']'
! !

!AbstractSocket methodsFor: 'private'!

implementation
    ^impl
!

initialize: implementation
    impl := implementation.
!

waitUntil: aBlock then: resultBlock onTimeoutDo: timeoutBlock

    Timeout // CheckPeriod timesRepeat: [
	aBlock value ifTrue: [ ^resultBlock value ].
	(Delay forMilliseconds: CheckPeriod) wait
    ].
    self close.
    ^timeoutBlock value.
! !

!AbstractSocket methodsFor: 'stream protocol'!

atEnd
    "By default, answer whether the connection is still open."
    ^self isOpen
!

next
    "Read another character from the socket, failing if the connection is
     dead."
    ^self implementation next
!

nextPut: char
    "Write `char' to the socket, failing if the connection is dead.  The
     SIGPIPE signal is automatically caught and ignored by the system."
    ^self implementation nextPut: char
! !

!AbstractSocket methodsFor: 'testing'!

isExternalStream
    "Answer whether the receiver streams on a file or socket."
    ^true
! !

!DatagramSocket class methodsFor: 'accessing'!

defaultImplementationClass
    "Answer the default implementation class.  Depending on the
     subclass, this might be the default stream socket implementation
     class of the default address class, or rather its default datagram
     socket implementation class"
    ^self defaultAddressClass defaultDatagramSocketImplClass
!
 
defaultBufferSize
    "Answer the default maximum size for input datagrams."
    ^DefaultBufferSize
!

defaultBufferSize: size
    "Set the default maximum size for input datagrams."
    DefaultBufferSize := size
! !

!DatagramSocket class methodsFor: 'initialization'!

initialize
    "Initialize the class to use an input datagram size of 128."
    DatagramSocket
	defaultBufferSize: 128
! !

!DatagramSocket class methodsFor: 'instance creation'!

new
    "Answer a new datagram socket (by default an UDP socket), without
     a specified local address and port."
    ^self local: nil port: 0
!

port: localPort
    "Create a new socket and bind it to the local host on the given port."
    ^self
	remote: nil
	port: 0
	local: nil
	port: localPort
!

local: ipAddressOrString port: remotePort
    "Create a new socket and bind it to the given host (passed as a
     String to be resolved or as an IPAddress), on the given port."
    ^self
	remote: nil
	port: 0
	local: ipAddressOrString
	port: remotePort
!

remote: ipAddressOrString port: remotePort local: ipAddress port: localPort
    "Create a new socket and bind it to the given host (passed as a
     String to be resolved or as an IPAddress), and to the given remotePort.
     The default destination for the datagrams will be ipAddressOrString
     (if not nil), on the remotePort port."
    | localAddr remoteAddr addressClass |
    ipAddressOrString isString
	ifTrue: [
	    remoteAddr := SocketAddress byName: ipAddressOrString.
	    remoteAddr isNil
		ifTrue: [ self error: 'cannot resolve host name ',
			      ipAddressOrString printString ]
	]
	ifFalse: [ remoteAddr := ipAddressOrString ].


    addressClass := remoteAddr isNil
	ifTrue: [ self defaultAddressClass ]
	ifFalse: [ remoteAddr class ].

    addressClass := ipAddress isNil
	ifTrue: [ addressClass ]
	ifFalse: [ ipAddress class ].

    localAddr := ipAddress isNil
	ifTrue: [ addressClass anyLocalAddress ]
	ifFalse: [ ipAddress ].

    ^(self new: addressClass defaultDatagramSocketImplClass new) 
	remote: remoteAddr
	port: remotePort
	local: localAddr
	port: localPort
! !

!DatagramSocket methodsFor: 'accessing'!

address
    "Answer the local address."
    ^self localAddress
!

bufferSize
    "Answer the size of the buffer in which datagrams are stored."
    ^self implementation bufferSize
!

bufferSize: size
    "Set the size of the buffer in which datagrams are stored."
    self implementation bufferSize: size
!

next
    "Read a datagram on the socket and answer it."
    ^self
	waitUntil: [ self implementation canRead ]
	then: [ self implementation next ]
	onTimeoutDo: [ nil ]
!

nextPut: aDatagram
    "Send the given datagram on the socket."
    self
	waitUntil: [ self implementation canWrite ]
	then: [ self implementation nextPut: aDatagram. aDatagram ]
	onTimeoutDo: [ nil ]
!

port
    "Answer the local port."
    ^self localPort
!

peek
    "Peek for a datagram on the socket and answer it."
    ^self
	waitUntil: [ self implementation canRead ]
	then: [ self implementation peek ]
	onTimeoutDo: [ nil ]
!

peek: datagram
    "Peek for a datagram on the socket, store it in `datagram', and
     answer the datagram itself."
    ^self
	waitUntil: [ self implementation canRead ]
	then: [ self implementation peek: datagram. true ]
	onTimeoutDo: [ false ]
!

receive: datagram
    "Read a datagram from the socket, store it in `datagram', and
     answer the datagram itself."
    ^self
	waitUntil: [ self implementation canRead ]
	then: [ self implementation receive: datagram. true ]
	onTimeoutDo: [ false ]
! !


!DatagramSocket methodsFor: 'direct operations'!

nextFrom: ipAddress port: port
    "Answer the next datagram from the given address and port."
    self
	waitUntil: [ self implementation canRead ]
	then: [ self implementation nextFrom: ipAddress port: port ]
	onTimeoutDo: [ nil ]
! !

!DatagramSocket methodsFor: 'private'!

remote: remoteAddress port: remotePort local: ipAddress port: localPort
    "Private - Set the local endpoint of the socket and the default
     address to which datagrams are sent."

    self implementation
        soReuseAddr: 1;
        bufferSize: self class defaultBufferSize;
        connectTo: remoteAddress port: remotePort;
	bindTo: ipAddress port: localPort.
! !


!MulticastSocket methodsFor: 'instance creation'!

interface
    "Answer the local device supporting the multicast socket.  This
     is usually set to any local address."
    ^self implementation ipMulticastIf
!

interface: ipAddress
    "Set the local device supporting the multicast socket.  This
     is usually set to any local address."
    self implementation ipMulticastIf: ipAddress
!

join: ipAddress
    "Join the multicast socket at the given IP address"
    self implementation join: ipAddress
!

leave: ipAddress
    "Leave the multicast socket at the given IP address"
    self implementation leave: ipAddress
!

nextPut: packet timeToLive: timeToLive
    "Send the datagram with a specific TTL (time-to-live)"
    | oldTTL |
    oldTTL := self implementation timeToLive.
    self implementation timeToLive: timeToLive.
    self nextPut: packet.
    self implementation timeToLive: oldTTL
!

timeToLive
    "Answer the socket's datagrams' default time-to-live"
    ^self implementation timeToLive
!

timeToLive: newTTL
    "Set the default time-to-live for the socket's datagrams"
    self implementation timeToLive: newTTL
! !



!ServerSocket class methodsFor: 'instance creation'!

defaultQueueSize
    "Answer the default length of the queue for pending connections.  When
     the queue fills, new clients attempting to connect fail until the server
     is send #accept to accept a connection from the queue."
    ^5
!

queueSize: backlog
    "Answer a new ServerSocket serving on any local address and port, with a
     pending connections queue of the given length."
    ^self
        port: 0
        queueSize: backlog
        bindTo: nil
!

queueSize: backlog bindTo: ipAddress
    "Answer a new ServerSocket serving on the given local address,
     and on any port, with a pending connections queue of the given length."
    ^self
        port: 0
        queueSize: backlog
        bindTo: ipAddress
!

port: anInteger
    "Answer a new ServerSocket serving on any local address, on the given
     port, with a pending connections queue of the default length."
    ^self
        port: anInteger
        queueSize: self defaultQueueSize
        bindTo: nil
!

port: anInteger queueSize: backlog
    "Answer a new ServerSocket serving on any local address, on the given
     port, with a pending connections queue of the given length."
    ^self
        port: anInteger
        queueSize: backlog
        bindTo: nil
!

port: anInteger bindTo: ipAddress
    "Answer a new ServerSocket serving on the given address and port,
     with a pending connections queue of the default length."
    ^self
        port: anInteger
        queueSize: self defaultQueueSize
        bindTo: ipAddress
!

port: anInteger queueSize: backlog bindTo: ipAddress
    "Answer a new ServerSocket serving on the given address and port,
     and with a pending connections queue of the given length."
    | localAddr addressClass |
    addressClass := ipAddress isNil
	ifTrue: [ self defaultAddressClass ]
	ifFalse: [ ipAddress class ].

    localAddr := ipAddress isNil
	ifTrue: [ addressClass unknownAddress ]
	ifFalse: [ ipAddress ].

    ^(self new: addressClass defaultStreamSocketImplClass new) 
	port: anInteger queueSize: backlog bindTo: localAddr
! !

!ServerSocket methodsFor: 'accessing'!

address
    "Answer the local address"
    ^self localAddress
!

port
    "Answer the local port (the port that the passive socket is listening on)."
    ^self localPort
!

waitForConnection
    "Wait for a connection to be available, and suspend the currently
     executing process in the meanwhile."
    self implementation ensureReadable
!

accept
    "Accept a new connection and create a new instance of Socket if there is
     one, else answer nil."
    self available ifFalse: [ ^nil ].	"Make it non-blocking"
    ^self primAccept: Socket
!

accept: socketClass
    "Accept a new connection and create a new instance of socketClass if
     there is one, else answer nil.  This is usually needed only to create
     DatagramSockets."

    self available ifFalse: [ ^nil ].	"Make it non-blocking"
    ^self primAccept: socketClass
!

primAccept: socketClass
    "Accept a new connection and create a new instance of Socket if there is
     one, else fail."
    | implClass newImpl |
    implClass := socketClass defaultImplementationClass.
    newImpl := self implementation accept: implClass.
    ^socketClass new: newImpl
! !

!ServerSocket methodsFor: 'initializing'!

port: anInteger queueSize: backlog bindTo: localAddr
    "Initialize the ServerSocket so that it serves on the given
     address and port, and has a pending connections queue of
     the given length."

    self implementation
	soReuseAddr: 1;
	bindTo: localAddr port: anInteger;
	listen: backlog
! !


!Socket class methodsFor: 'well known ports'!

portEcho	   "Answer the port on which the ECHO service listens"	  ^7!
portDiscard	   "Answer the port on which the DISCARD service listens" ^9!
portSystat	   "Answer the port on which the SYSTAT service listens"  ^11!
portDayTime	   "Answer the port on which the TOD service listens"     ^13!
portNetStat	   "Answer the port on which the NETSTAT service listens" ^15!
portFTP		   "Answer the port on which the FTP daemon listens"      ^21!
portSSH		   "Answer the port on which the SSH daemon listens"      ^22!
portTelnet	   "Answer the port on which the TELNET daemon listens"   ^23!
portSMTP	   "Answer the port on which the SMTP daemon listens"     ^25!
portTimeServer     "Answer the port on which the time server listens"     ^37!
portDNS		   "Answer the port on which the DNS listens"             ^53!
portWhois	   "Answer the port on which the WHOIS daemon listens"    ^43!
portGopher	   "Answer the port on which the Gopher daemon listens"   ^70!
portFinger	   "Answer the port on which the finger daemon listens"   ^79!
portHTTP	   "Answer the port on which the http daemon listens"     ^80!
portPOP3	   "Answer the port on which the pop3 daemon listens"     ^110!
portNNTP	   "Answer the port on which the nntp daemon listens"     ^119!
portExecServer     "Answer the port on which the exec server listens"     ^512!
portLoginServer    "Answer the port on which the rlogin daemon listens"   ^513!
portCmdServer      "Answer the port on which the rsh daemon listens"      ^514!
portReserved       "Answer the last port reserved to privileged processes"^1023!

defaultPortAt: protocol
    "Answer the port that is used (by default) for the given service (high
     level protocol)"
    ^Ports at: protocol
!

defaultPortAt: protocol ifAbsent: port
    "Answer the port that is used (by default) for the given service (high
     level protocol), or the specified port if none is registered."
    ^Ports at: protocol ifAbsent: port
!

defaultPortAt: protocol put: port
    "Associate the given port to the service specified by `protocol'."
    ^Ports at: protocol put: port
!

initialize
    "Initialize the receiver's defaults"
    self readBufferSize: 1024; writeBufferSize: 256.
    Ports := Dictionary new
	at: 'ftp' put: 21;
	at: 'telnet' put: 23;
	at: 'smtp' put: 25;
	at: 'dns' put: 42;
	at: 'whois' put: 43;
	at: 'finger' put: 79;
	at: 'http' put: 80;
	at: 'pop3' put: 110;
	at: 'nntp' put: 119;
	yourself
! !

!Socket class methodsFor: 'accessing'!

defaultImplementationClass
    "Answer the default implementation class.  Depending on the
     subclass, this might be the default stream socket implementation
     class of the default address class, or rather its default datagram
     socket implementation class"
    ^self defaultAddressClass defaultStreamSocketImplClass
!
 
readBufferSize
    "Answer the size of the read buffer for newly-created sockets"
    ^ReadBufferSize
!

readBufferSize: anInteger
    "Set the size of the read buffer for newly-created sockets"
    ReadBufferSize := anInteger
!

writeBufferSize
    "Answer the size of the write buffer for newly-created sockets"
    ^WriteBufferSize
!

writeBufferSize: anInteger
    "Set the size of the write buffer for newly-created sockets"
    WriteBufferSize := anInteger
! !

!Socket class methodsFor: 'instance creation'!

remote: ipAddressOrString port: remotePort
    "Create a new socket and connect to the given host (passed as a
     String to be resolved or as a SocketAddress), and to the given port."
    ^self
	remote: ipAddressOrString
	port: remotePort
	local: nil
	port: 0
!

remote: ipAddressOrString port: remotePort local: ipAddress port: localPort
    "Create a new socket and connect to the given host (passed as a
     String to be resolved or as a SocketAddress), and to the given remotePort.
     Then bind it to the local address passed in ipAddress, on the localPort
     port; if the former is nil, any local address will do, and if the latter
     is 0, any local port will do."
    | localAddr remoteAddr addressClass |
    remoteAddr := ipAddressOrString isString
	ifTrue: [ SocketAddress byName: ipAddressOrString ]
	ifFalse: [ ipAddressOrString ].

    remoteAddr isNil
	ifTrue: [ self error: 'cannot resolve host name ', ipAddressOrString printString ].

    addressClass := remoteAddr isNil
	ifTrue: [ self defaultAddressClass ]
	ifFalse: [ remoteAddr class ].

    addressClass := ipAddress isNil
	ifTrue: [ addressClass ]
	ifFalse: [ ipAddress class ].

    ^(self new: addressClass defaultStreamSocketImplClass new) 
	remote: remoteAddr
	port: remotePort
	local: localAddr
	port: localPort
! !

!Socket methodsFor: 'accessing'!

address
    "Answer the address of the remote endpoint"
    ^self remoteAddress
!

port
    "Answer the port of the remote endpoint"
    ^self remotePort
! !

!Socket methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream
	print: self class;
	nextPutAll: '[local ';
	print: self localAddress;
	nextPut: $: ;
	print: self localPort;
	nextPutAll: ', remote ';
	print: self remoteAddress;
	nextPut: $: ;
	print: self remotePort;
	nextPut: $]
! !

!Socket methodsFor: 'private'!

remote: remoteAddr port: remotePort local: localAddr port: localPort
    localAddr isNil ifFalse: [
	self implementation bindTo: localAddr port: localPort
    ].
    self implementation connectTo: remoteAddr port: remotePort
!

species
    ^String
! !

!Socket methodsFor: 'stream protocol'!

atEnd
    "Answer whether more data is available on the socket"
    ^self peek isNil
!

available
    "Answer whether more data is available in the socket's read buffer
     or from the operating system."
    ^(self hasReadBuffer and: [ self readBuffer notEmpty ])
	or: [ super available ]
!

bufferContents
    "Answer the current contents of the read buffer"
    | result |
    result := self readBuffer bufferContents.
    lookahead isNil ifFalse: [
	result := lookahead asString, result.
	lookahead := nil.
    ].
    ^result
!
    
close
    "Flush and close the socket."
    super close.
    self deleteBuffers
!

fill
    "Fill the read buffer with data read from the socket"
    self readBuffer fill
!

flush
    "Flush the write buffer to the operating system"
    self writeBuffer flush
!

isPeerAlive
    "Answer whether the connection with the peer remote machine is still
     valid."
    ^self readBuffer notNil
!

next
    "Read a byte from the socket.  This might yield control to other
     Smalltalk Processes."
    | result |
    lookahead isNil ifTrue: [ ^self readBuffer next ].
    result := lookahead.
    lookahead := nil.
    ^result
!

nextHunk
    "Answer the next buffers worth of stuff in the Stream represented
     by the receiver.  Do at most one actual input operation."

    "Ensure that the buffer is full"
    self peek.
    ^self bufferContents
!

next: count
    "Read `count' bytes from the socket.  This might yield control to other
     Smalltalk Processes."
    | result |
    lookahead isNil ifTrue: [ ^self readBuffer next: count ].
    result := (String with: lookahead), (self readBuffer next: count - 1).
    lookahead := nil.
    ^result
!

nextPut: char
    "Write a character to the socket; this acts as a bit-bucket when
     the socket is closed.  This might yield control to other
     Smalltalk Processes."
    self writeBuffer isNil ifTrue: [ ^self ].
    self writeBuffer nextPut: char
!

nextPutAll: aString
    "Write aString to the socket; this acts as a bit-bucket when
     the socket is closed.  This might yield control to other
     Smalltalk Processes."
    self writeBuffer isNil ifTrue: [ ^self ].
    self writeBuffer nextPutAll: aString
!

peek
    "Read a byte from the socket, without advancing the buffer; answer
     nil if no more data is available.  This might yield control to other
     Smalltalk Processes."
    lookahead isNil ifTrue: [
	self readBuffer isNil ifTrue: [ ^nil ].
	self readBuffer atEnd ifTrue: [ ^nil ].
	lookahead := self readBuffer next ].
    ^lookahead
!

peekFor: anObject
    "Read a byte from the socket, advancing the buffer only if it matches
     anObject; answer whether they did match or not.  This might yield
     control to other Smalltalk Processes."
    lookahead isNil ifTrue: [
	self readBuffer isNil ifTrue: [ ^false ].
	self readBuffer atEnd ifTrue: [ ^false ].
	lookahead := self readBuffer next ].
    ^lookahead = anObject
        ifTrue: [ lookahead := nil. true ]
        ifFalse: [ false ]
!

readBufferSize: size
    "Create a new read buffer of the given size (which is only
     possible before the first read or if the current buffer is
     empty)."
    readBuffer isNil ifTrue: [ ^self ].
    (self hasReadBuffer and: [ readBuffer notEmpty ])
	ifTrue: [ self error: 'read buffer must be empty before changing its size' ].

    readBuffer := self newReadBuffer: size.
!

writeBufferSize: size
    "Create a new write buffer of the given size, flushing the
     old one is needed.  This might yield control to other 
     Smalltalk Processes."
    writeBuffer isNil ifTrue: [ ^self ].
    self hasWriteBuffer ifTrue: [ writeBuffer flush ].
    writeBuffer := self newWriteBuffer: size.
! !

!Socket methodsFor: 'private - buffering'!

deleteBuffers
    readBuffer := writeBuffer := nil.
!

noBufferFlag
    "Value that means `lazily initialize the readBuffer and writeBuffer'."
    ^0
!

hasReadBuffer
    ^readBuffer ~~ self noBufferFlag
!

hasWriteBuffer
    ^writeBuffer ~~ self noBufferFlag
!

initialize: implementation
    super initialize: implementation.
    readBuffer := writeBuffer := self noBufferFlag.
!

newReadBuffer: size
    ^(ReadBuffer on: (String new: size))
	fillBlock: [ :data :size |
	    self implementation ensureReadable.
	    self implementation isOpen
		ifTrue: [ self implementation read: data numBytes: size ]
		ifFalse: [ self deleteBuffers. 0 ]
	]
!

newWriteBuffer: size
    ^(WriteBuffer on: (String new: size))
	flushBlock: [ :data :size || alive |
	    self implementation ensureWriteable.
	    alive := self implementation isOpen and: [
		(self implementation write: data numBytes: size) > -1 ].

	    alive ifFalse: [ self deleteBuffers ]
	]
!

readBuffer
    readBuffer == self noBufferFlag
	ifTrue: [ readBuffer := self newReadBuffer: ReadBufferSize ].
    ^readBuffer
!

writeBuffer
    writeBuffer == self noBufferFlag
	ifTrue: [ writeBuffer := self newWriteBuffer: WriteBufferSize ].
    ^writeBuffer
! !

!Socket methodsFor: 'out-of-band data'!

outOfBand
    "Return a datagram socket to be used for receiving out-of-band data
     on the receiver."
    | outOfBandImpl |
    outOfBand isNil ifTrue: [
	outOfBandImpl := self implementation outOfBandImplClass new.
	outOfBandImpl initialize: self implementation fd.
        outOfBand := DatagramSocket new: outOfBandImpl.
    ].
    ^outOfBand
! !


AbstractSocket
    timeout: 30000;
    checkPeriod: 100;
    defaultAddressClass: IPAddress!
