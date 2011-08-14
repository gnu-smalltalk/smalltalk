"======================================================================
|
|   Abstract socket implementations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
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



FileDescriptor subclass: AbstractSocketImpl [
    | localAddress localPort remoteAddress remotePort |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for socket implementations.
The implementation class serves an intermediary to routines that
perform the actual socket operations.  It hides the buffering and
blocking behavior of the Socket classes.

A default implementation is provided by each address family, but
this can be changed by class methods on SocketAddress sublcasses.'>

    AbstractSocketImpl class >> addressClass [
	"Answer the class responsible for handling addresses for
	 the receiver"

	<category: 'abstract'>
	self subclassResponsibility
    ]

    AbstractSocketImpl class >> protocol [
	"Answer the protocol parameter for `create'"

	<category: 'abstract'>
	^0
    ]

    AbstractSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'abstract'>
	self subclassResponsibility
    ]

    AbstractSocketImpl class >> newFor: addressClass [
	"Create a socket for the receiver."

	<category: 'socket creation'>
	| descriptor |
	descriptor := self 
		    create: addressClass protocolFamily
		    type: self socketType
		    protocol: self protocol.
	descriptor < 0 ifTrue: [ File checkError ].
	^self on: descriptor
    ]

    accept: implementationClass [
	"Accept a connection on the receiver, and create a new instance
	 of implementationClass that will deal with the newly created
	 active server socket."

	<category: 'socket operations'>
	| peer addrLen newFD fd |
	peer := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	newFD := self 
		    accept: fd
		    peer: peer
		    addrLen: addrLen.
        newFD < 0 ifTrue: [ self checkSoError ].
	^(implementationClass on: newFD)
	    hasBeenBound;
	    hasBeenConnectedTo: peer;
	    yourself
    ]

    bindTo: ipAddress port: port [
	"Bind the receiver to the given IP address and port. `Binding' means
	 attaching the local endpoint of the socket."

	<category: 'socket operations'>
	| addr fd |
	addr := ipAddress port: port.
	
	(fd := self fd) isNil ifTrue: [ ^self ].
	[(self 
	    bind: fd
	    to: addr
	    addrLen: addr size) < 0 ifTrue: [File checkError] ]
		ifCurtailed: [self close].
	self isOpen ifTrue: [self hasBeenBound]
    ]

    fileOp: ioFuncIndex [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    getSockName [
	"Retrieve a ByteArray containing a sockaddr_in struct for the
	 local endpoint of the socket."

	<category: 'socket operations'>
	| sock addrLen fd |
	sock := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil
	    ifTrue: [ ^nil ].
	(self getSockName: self fd addr: sock addrLen: addrLen) = -1
	    ifTrue: [ ^nil ].
	^sock
    ]

    listen: backlog [
	"Make the receiver a passive server socket with a pending connections
	 queue of the given size."

	<category: 'socket operations'>
	| fd |
	(fd := self fd) isNil ifTrue: [ ^self ].
	self listen: fd log: backlog
    ]

    connectTo: ipAddress port: port [
	"Connect the receiver to the given IP address and port. `Connecting'
	 means attaching the remote endpoint of the socket."

	<category: 'accessing'>
	self hasBeenConnectedTo: ipAddress port: port
    ]

    localAddress [
	"Answer the address of the local endpoint of the socket (even if IP
	 is not being used, this identifies the machine that is bound to the
	 socket)."

	<category: 'accessing'>
	^localAddress
    ]

    localPort [
	"Answer the port of the local endpoint of the socket (even if IP
	 is not being used, this identifies the service or process that
	 is bound to the socket)."

	<category: 'accessing'>
	^localPort
    ]

    remoteAddress [
	"Answer the address of the remote endpoint of the socket (even if IP
	 is not being used, this identifies the machine to which the socket
	 is connected)."

	<category: 'accessing'>
	^remoteAddress
    ]

    remotePort [
	"Answer the port of the remote endpoint of the socket (even if IP
	 is not being used, this identifies the service or process to which
	 the socket is connected)."

	<category: 'accessing'>
	^remotePort
    ]

    valueWithoutBuffering: aBlock [
	"Evaluate aBlock, ensuring that any data that it writes to the socket
	 is sent immediately to the network."

	<category: 'socket options'>
	aBlock value
    ]

    optionAt: opt level: level size: size [
	"Answer in a ByteArray of the given size the value of a socket option.
	 The option identifier is in `opt' and the level is in `level'.  A
	 layer over this method is provided for the most common socket options,
	 so this will be rarely used."

	<category: 'socket options'>
	| result len fd |
	result := ByteArray new: size.
	len := CInt gcValue: size.
	(fd := self fd) isNil ifTrue: [ ^nil ].
	self 
	    option: fd
	    level: level
	    at: opt
	    get: result
	    size: len.
	^result
    ]

    optionAt: opt level: level put: anObject [
	"Modify the value of a socket option.  The option identifier is in
	 `opt' and the level is in `level'.  anObject can be a boolean,
	 integer, socket address or ByteArray. A layer over this method is
	 provided for the most common socket options, so this will be rarely
	 used."

	<category: 'socket options'>
	| ba fd |
	ba := self makeByteArray: anObject.
	(fd := self fd) isNil ifTrue: [ ^self ].
	self 
	    option: fd
	    level: level
	    at: opt
	    put: ba
	    size: ba size
    ]

    soLinger [
	"Answer the number of seconds by which a `close' operation can block
	 to ensure that all the packets have reliably reached the destination,
	 or nil if those packets are left to their destiny."

	<category: 'socket options'>
	| data |
	data := self 
		    optionAt: self class soLinger
		    level: self class solSocket
		    size: CInt sizeof * 2.
	(data intAt: 1) = 0 ifTrue: [^nil].
	^data intAt: CInt sizeof + 1
    ]

    soLinger: linger [
	"Set the number of seconds by which a `close' operation can block
	 to ensure that all the packets have reliably reached the destination.
	 If linger is nil, those packets are left to their destiny."

	<category: 'socket options'>
	| data |
	data := ByteArray new: CInt sizeof * 2.
	linger isNil 
	    ifFalse: 
		[data at: 1 put: 1.
		data intAt: CInt sizeof + 1 put: linger].
	self 
	    optionAt: self class soLinger
	    level: self class solSocket
	    put: data
    ]

    soReuseAddr [
	"Answer whether another socket can be bound the same local address as this
	 one.  If you enable this option, you can actually have two sockets with the
	 same Internet port number; but the system won't allow you to use the two
	 identically-named sockets in a way that would confuse the Internet.  The
	 reason for this option is that some higher-level Internet protocols,
	 including FTP, require you to keep reusing the same socket number."

	<category: 'socket options'>
	^((self 
	    optionAt: self class soReuseAddr
	    level: self class solSocket
	    size: CInt sizeof) intAt: 1) 
	    > 0
    ]

    soReuseAddr: aBoolean [
	"Set whether another socket can be bound the same local address as this one."

	<category: 'socket options'>
	self 
	    optionAt: self class soReuseAddr
	    level: self class solSocket
	    put: aBoolean
    ]

    makeByteArray: anObject [
	"Private - Convert anObject to a ByteArray to be used to store socket
	 options.  This can be a ByteArray, a socket address valid for this
	 class, an Integer or a Boolean."

	<category: 'private'>
	anObject == true ifTrue: [
	    ^#[1 0 0 0]].
	anObject == false ifTrue: [
	    ^#[0 0 0 0]].
	anObject isInteger ifTrue: [
	    ^(ByteArray new: CInt sizeof)
		at: 1 put: (anObject bitAnd: 255);
		at: 2 put: (anObject // 256 bitAnd: 255);
		at: 3 put: (anObject // 65536 bitAnd: 255);
		at: 4 put: (anObject // 16777216 bitAnd: 255);
		yourself].

	^anObject asByteArray
    ]

    hasBeenConnectedTo: ipAddress port: port [
	"Store the remote address and port that the receiver is connected to."

	<category: 'private'>
	remoteAddress := ipAddress.
	remotePort := port
    ]

    hasBeenConnectedTo: sockAddr [
	"Store the remote address and port that the receiver is connected to."

	<category: 'private'>
	| port |
	port := ValueHolder new.
	self 
	    hasBeenConnectedTo: (SocketAddress fromSockAddr: sockAddr port: port)
	    port: port value
    ]

    hasBeenBoundTo: ipAddress port: port [
	"Store the local address and port that the receiver is bound to."

	<category: 'private'>
	localAddress := ipAddress.
	localPort := port
    ]

    hasBeenBoundTo: sockAddr [
	"Store the local address and port that the receiver has been bound to."

	<category: 'private'>
	| port |
	port := ValueHolder new.
	self hasBeenBoundTo: (SocketAddress fromSockAddr: sockAddr port: port)
	    port: port value
    ]

    hasBeenBound [
	"Retrieve the local address and port that the receiver has been bound to."

	<category: 'private'>
	self hasBeenBoundTo: self getSockName
    ]

    checkSoError [
        "Retrieve SO_ERROR and, if non-zero, raise an exception for its value."

	<category: 'private'>
        self isOpen ifFalse: [^SystemExceptions.FileError signal: 'file closed'].
        File checkError: self soError
    ]

    ensureReadable [
	"If the file is open, wait until data can be read from it.  The wait
	 allows other Processes to run."

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 0
	    with: Semaphore new
	    ifFail: [[self checkSoError] ensure: [^self close]].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 13
	    with: 0
	    ifFail: [[self checkSoError] ensure: [self close]]
    ]

    ensureWriteable [
	"If the file is open, wait until we can write to it.  The wait
	 allows other Processes to run."

	"FileDescriptor's ensureWriteable is actually dummy,
	 because not all devices support sending SIGIO's when
	 they become writeable -- notably, tty's under Linux :-("

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 1
	    with: Semaphore new
	    ifFail: [[self checkSoError] ensure: [^self close]].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 13
	    with: 1
	    ifFail: [[self checkSoError] ensure: [self close]]
    ]

    waitForException [
	"If the file is open, wait until an exceptional condition (such
	 as presence of out of band data) has occurred on it.  The wait
	 allows other Processes to run."

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 2
	    with: Semaphore new
	    ifFail: [[self checkSoError] ensure: [^self close]].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 13
	    with: 2
	    ifFail: [[self checkSoError] ensure: [self close]]
    ]

    soError [
	<category: 'private'>
	^self soError: self fd
    ]
]



AbstractSocketImpl subclass: SocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for stream socket
implementations.'>

    SocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockStream
    ]

    activeSocketImplClass [
	"Return an implementation class to be used for the active socket
	 created when a connection is accepted by a listening socket.
	 The default is simply the same class as the receiver."
	^self class
    ]

    outOfBandImplClass [
	"Return an implementation class to be used for out-of-band data
	 on the receiver."

	<category: 'abstract'>
	^OOBSocketImpl
    ]

    connectTo: ipAddress port: port [
	"Try to connect the socket represented by the receiver to the given remote
	 machine."

	<category: 'socket operations'>
	| addr fd peer |
	addr := ipAddress port: port.
	
	[(fd := self fd) isNil ifTrue: [ ^self ].
	(self 
	    connect: fd
	    to: addr
	    addrLen: addr size) < 0 ifTrue: [self checkSoError] ]
		ifCurtailed: [self close].

	"connect does not block, so wait for"
	self ensureWriteable.
	self isOpen ifTrue: [
	    peer := self getPeerName ifNil: [ addr ].
	    self hasBeenConnectedTo: peer]
    ]

    getPeerName [
	"Retrieve a ByteArray containing a sockaddr_in struct for the
	 remote endpoint of the socket."

	<category: 'socket operations'>
	| peer addrLen fd |
	peer := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil
	    ifTrue: [ ^nil ].
	(self getPeerName: self fd addr: peer addrLen: addrLen) = -1
	    ifTrue: [ ^nil ].
	^peer
    ]

]



AbstractSocketImpl subclass: DatagramSocketImpl [
    | bufSize |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for datagram socket
implementations.'>

    DatagramSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockDgram
    ]

    DatagramSocketImpl class >> datagramClass [
	"Answer the datagram class returned by default by instances of
	 this class."

	<category: 'parameters'>
	^Datagram
    ]

    bufferSize [
	"Answer the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	^bufSize
    ]

    bufferSize: size [
	"Set the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	bufSize := size
    ]

    peek [
	"Peek for a datagram on the receiver, answer a new object
	 of the receiver's datagram class."

	<category: 'socket operations'>
	^self receive: self msgPeek datagram: self class datagramClass new
    ]

    peek: aDatagram [
	"Peek for a datagram on the receiver, answer aDatagram modified
	 to contain information on the newly received datagram."

	<category: 'socket operations'>
	^self receive: self msgPeek datagram: aDatagram
    ]

    next [
	"Retrieve a datagram from the receiver, answer a new object
	 of the receiver's datagram class."

	<category: 'socket operations'>
	^self receive: 0 datagram: self class datagramClass new
    ]

    receive: aDatagram [
	"Retrieve a datagram from the receiver, answer aDatagram modified
	 to contain information on the newly received datagram."

	<category: 'socket operations'>
	^self receive: 0 datagram: aDatagram
    ]

    nextPut: aDatagram [
	"Send aDatagram on the socket"

	<category: 'socket operations'>
	self 
	    send: aDatagram
	    to: (aDatagram address isNil 
		    ifTrue: [remoteAddress]
		    ifFalse: [aDatagram address])
	    port: (aDatagram port isNil ifTrue: [remotePort] ifFalse: [aDatagram port]).
    ]

    receive: flags datagram: aDatagram [
	"Receive a new datagram into `datagram', with the given flags, and
	 answer `datagram' itself; this is an abstract method.
	 The flags can be zero to receive the datagram, or `self msgPeek'
	 to only peek for it without removing it from the queue."

	<category: 'socket operations'>
	| address port data from addrLen fd read |
	data := ByteArray new: self bufferSize.
	from := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	read := self 
	    receive: fd
	    buffer: data
	    size: data size
	    flags: (self flags bitOr: flags)
	    from: from
	    size: addrLen.
	read < 0 ifTrue: [ self checkSoError ].
	port := ValueHolder new.
	^aDatagram
	    data: data;
	    dataSize: read;
	    address: (SocketAddress fromSockAddr: from port: port);
	    port: port value;
	    yourself
    ]

    send: aDatagram to: theReceiver port: port [
	"Send aDatagram on the socket to the given receiver and port"

	<category: 'socket operations'>
	| size receiver fd sent |
	theReceiver isNil 
	    ifTrue: [receiver := nil. size := 0]
	    ifFalse: 
		[receiver := theReceiver port: port.
		size := receiver size].
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	sent := self 
	    send: fd
	    buffer: aDatagram data
	    size: aDatagram size
	    flags: self flags
	    to: receiver
	    size: size.
	sent < 0 ifTrue: [ self checkSoError ].
    ]

    flags [
	<category: 'private'>
	^0
    ]
]



DatagramSocketImpl subclass: MulticastSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for datagram socket
implementations that support multicast.'>

    ipMulticastIf [
	"Answer the local device for a multicast socket (in the form of
	 an address)"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    ipMulticastIf: interface [
	"Set the local device for a multicast socket (in the form of
	 an address, usually anyLocalAddress)"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    join: ipAddress [
	"Join the multicast socket at the given address"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    leave: ipAddress [
	"Leave the multicast socket at the given address"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    timeToLive [
	"Answer the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    timeToLive: ttl [
	"Set the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	self subclassResponsibility
    ]
]



DatagramSocketImpl subclass: RawSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for raw socket
implementations.  Raw socket packets are modeled as datagrams.'>

    RawSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockRaw
    ]
]




DatagramSocketImpl subclass: OOBSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for socket
implementations that send out-of-band data over a stream socket.'>

    canRead [
	"Answer whether out-of-band data is available on the socket"

	<category: 'implementation'>
	^self exceptionalCondition
    ]

    ensureReadable [
	"Stop the process until an error occurs or out-of-band data
	 becomes available on the socket"

	<category: 'implementation'>
	^self waitForException
    ]

    flags [
	<category: 'private'>
	^self msgOOB
    ]
]
