"======================================================================
|
|   Abstract socket implementations
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



FileDescriptor subclass: AbstractSocketImpl [
    | localAddress localPort remoteAddress remotePort |
    
    <category: 'Sockets-Protocols'>
    <comment: nil>

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

    AbstractSocketImpl class >> new [
	"Create a socket for the receiver."

	<category: 'socket creation'>
	| descriptor |
	descriptor := self 
		    create: self addressClass protocolFamily
		    type: self socketType
		    protocol: self protocol.
	File checkError.
	^self on: descriptor
    ]

    accept: implementationClass [
	"Accept a connection on the receiver, and create a new instance
	 of implementationClass that will deal with the newly created
	 active server socket."

	<category: 'socket operations'>
	| peer addrLen newFD fd |
	peer := ByteArray new: CSockAddrStruct sizeof.
	addrLen := CInt gcValue: CSockAddrStruct sizeof.
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	newFD := self 
		    accept: fd
		    peer: peer
		    addrLen: addrLen.
	^(implementationClass on: newFD)
	    hasBeenBound;
	    hasBeenConnectedTo: peer;
	    yourself
    ]

    addressClass [
	"Answer the class responsible for handling addresses for
	 the receiver"

	<category: 'socket operations'>
	^self class addressClass
    ]

    bindTo: ipAddress port: port [
	"Bind the receiver to the given IP address and port. `Binding' means
	 attaching the local endpoint of the socket."

	<category: 'socket operations'>
	| addr fd |
	addr := ipAddress port: port.
	
	(fd := self fd) isNil ifTrue: [ ^self ].
	[self 
	    bind: fd
	    to: addr
	    addrLen: addr size.
	File checkError] 
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
	sock := ByteArray new: CSockAddrStruct sizeof.
	addrLen := CInt gcValue: CSockAddrStruct sizeof.
	(fd := self fd) isNil ifTrue: [ ^nil ].
	self 
	    getSockName: fd
	    addr: sock
	    addrLen: addrLen.
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

    soError [
	"Answer the pending error on the socket, or 0 if none"

	<category: 'socket options'>
	| data |
	data := self 
		    optionAt: self class soError
		    level: self class solSocket
		    size: CInt sizeof.
	^data intAt: 1
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
	| byteArray |
	anObject class == ByteArray ifTrue: [^anObject].
	anObject class == self addressClass ifTrue: [^anObject asByteArray].
	byteArray := ByteArray new: CInt sizeof.
	anObject == true ifTrue: [byteArray intAt: 1 put: 1].
	anObject isInteger ifTrue: [byteArray intAt: 1 put: anObject].
	^byteArray
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
	    hasBeenConnectedTo: (self addressClass fromSockAddr: sockAddr port: port)
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
	self hasBeenBoundTo: (self addressClass fromSockAddr: sockAddr port: port)
	    port: port value
    ]

    hasBeenBound [
	"Retrieve the local address and port that the receiver has been bound to."

	<category: 'private'>
	self hasBeenBoundTo: self getSockName
    ]

    ensureReadable [
	"If the file is open, wait until data can be read from it.  The wait
	 allows other Processes to run."

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 0
	    with: Semaphore new.
	self 
	    fileOp: 13
	    with: 0
	    ifFail: [[File checkError: self soError] ensure: [self close]]
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
	    with: Semaphore new.
	self 
	    fileOp: 13
	    with: 1
	    ifFail: [[File checkError: self soError] ensure: [self close]]
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
	    with: Semaphore new.
	self 
	    fileOp: 13
	    with: 2
	    ifFail: [[File checkError: self soError] ensure: [self close]]
    ]
]



AbstractSocketImpl subclass: SocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: nil>

    SocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockStream
    ]

    outOfBandImplClass [
	"Return an implementation class to be used for out-of-band data
	 on the receiver."

	<category: 'abstract'>
	self subclassResponsibility
    ]

    connectTo: ipAddress port: port [
	"Try to connect the socket represented by the receiver to the given remote
	 machine."

	<category: 'socket operations'>
	| addr fd |
	addr := ipAddress port: port.
	
	[(fd := self fd) isNil ifTrue: [ ^self ].
	self 
	    connect: fd
	    to: addr
	    addrLen: addr size.
	File checkError] 
		ifCurtailed: [self close].

	"connect does not block, so wait for"
	self ensureWriteable.
	self isOpen ifTrue: [self hasBeenConnected]
    ]

    getPeerName [
	"Retrieve a ByteArray containing a sockaddr_in struct for the
	 remote endpoint of the socket."

	<category: 'socket operations'>
	| peer addrLen fd |
	peer := ByteArray new: CSockAddrStruct sizeof.
	addrLen := CInt gcValue: CSockAddrStruct sizeof.
	(fd := self fd) isNil ifTrue: [ ^nil ].
	self 
	    getPeerName: self fd
	    addr: peer
	    addrLen: addrLen.
	^peer
    ]

    hasBeenConnected [
	"Retrieve and save the remote address and port that the receiver is
	 connected to."

	<category: 'private'>
	self hasBeenConnectedTo: self getPeerName
    ]
]



AbstractSocketImpl subclass: DatagramSocketImpl [
    | bufSize |
    
    <category: 'Sockets-Protocols'>
    <comment: nil>

    DatagramSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockDgram
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
	"Peek for a datagram on the receiver, answer a new Datagram object"

	<category: 'socket operations'>
	^self receive: self msgPeek datagram: Datagram new
    ]

    peek: aDatagram [
	"Peek for a datagram on the receiver, answer aDatagram modified
	 to contain information on the newly received datagram."

	<category: 'socket operations'>
	^self receive: self msgPeek datagram: aDatagram
    ]

    next [
	"Retrieve a datagram from the receiver, answer a new Datagram object"

	<category: 'socket operations'>
	^self receive: 0 datagram: Datagram new
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
	    port: (aDatagram port isNil ifTrue: [remotePort] ifFalse: [aDatagram port])
    ]

    receive: flags datagram: aDatagram [
	"Receive a new datagram into `datagram', with the given flags, and
	 answer `datagram' itself; this is an abstract method.
	 The flags can be zero to receive the datagram, or `self msgPeek'
	 to only peek for it without removing it from the queue."

	<category: 'socket operations'>
	| address port data from addrLen fd |
	data := ByteArray new: self bufferSize.
	from := ByteArray new: CSockAddrStruct sizeof.
	addrLen := CInt gcValue: from size.
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	self 
	    receive: fd
	    buffer: data
	    size: data size
	    flags: (self flags bitOr: flags)
	    from: from
	    size: addrLen.
	port := ValueHolder new.
	^aDatagram
	    data: data;
	    address: (self addressClass fromSockAddr: from port: port);
	    port: port value;
	    yourself
    ]

    send: aDatagram to: theReceiver port: port [
	"Send aDatagram on the socket to the given receiver and port"

	<category: 'socket operations'>
	| size receiver fd |
	theReceiver isNil 
	    ifTrue: [receiver := nil. size := 0]
	    ifFalse: 
		[receiver := theReceiver port: port.
		size := receiver size].
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	self 
	    send: fd
	    buffer: aDatagram data
	    size: aDatagram data size
	    flags: self flags
	    to: receiver
	    size: size
    ]

    flags [
	<category: 'private'>
	^0
    ]
]



DatagramSocketImpl subclass: MulticastSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: nil>

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
    <comment: nil>

    RawSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockRaw
    ]
]

