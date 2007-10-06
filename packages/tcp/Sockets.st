"======================================================================
|
|   Smalltalk TCP/IP sockets - Stream hierarchy
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2005, 2006 Free Software Foundation, Inc.
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



Stream subclass: AbstractSocket [
    | impl |
    
    <category: 'Sockets-Streams'>
    <comment: nil>

    CheckPeriod := nil.
    Timeout := nil.
    DefaultAddressClass := nil.

    AbstractSocket class >> checkPeriod [
	"Answer the period that is to elapse between socket polls if data
	 data is not ready and the connection is still open (in milliseconds)"

	<category: 'timed-out operations'>
	^CheckPeriod
    ]

    AbstractSocket class >> checkPeriod: anInteger [
	"Set the period that is to elapse between socket polls if data
	 data is not ready and the connection is still open (in milliseconds)"

	<category: 'timed-out operations'>
	CheckPeriod := anInteger truncated
    ]

    AbstractSocket class >> timeout [
	"Answer the period that is to elapse between the request for (yet
	 unavailable) data and the moment when the connection is considered dead
	 (in milliseconds)"

	<category: 'timed-out operations'>
	^Timeout
    ]

    AbstractSocket class >> timeout: anInteger [
	"Set the period that is to elapse between the request for (yet
	 unavailable) data and the moment when the connection is considered
	 dead (in milliseconds)"

	<category: 'timed-out operations'>
	Timeout := anInteger truncated
    ]

    AbstractSocket class >> defaultImplementationClass [
	"Answer the default implementation class.  Depending on the
	 subclass, this might be the default stream socket implementation
	 class of the default address class, or rather its default datagram
	 socket implementation class"

	<category: 'defaults'>
	self subclassResponsibility
    ]

    AbstractSocket class >> defaultAddressClass [
	"Answer the default address family to be used.  In the library,
	 the address family is represented by a subclass of SocketAddress
	 which is by default IPAddress."

	<category: 'defaults'>
	^DefaultAddressClass
    ]

    AbstractSocket class >> defaultAddressClass: class [
	"Set the default address family to be used.  In the library,
	 the address family is represented by a subclass of SocketAddress
	 which is by default IPAddress."

	<category: 'defaults'>
	DefaultAddressClass := class
    ]

    AbstractSocket class >> new: implementation [
	"Answer a new instance of the receiver, using as the underlying
	 layer the object passed as the `implementation' parameter; the
	 object is probably going to be some kind of AbstractSocketImpl."

	<category: 'instance creation'>
	^super new initialize: implementation
    ]

    AbstractSocket class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    soLinger [
	"Answer the number of seconds that the socket is allowed to wait
	 if it promises reliable delivery but has unacknowledged/untransmitted
	 packets when it is closed, or nil if those packets are left to their
	 destiny or discarded."

	<category: 'socket options'>
	^self implementation soLinger
    ]

    soLinger: linger [
	"Set the number of seconds that the socket is allowed to wait
	 if it promises reliable delivery but has unacknowledged/untransmitted
	 packets when it is closed."

	<category: 'socket options'>
	^self implementation soLinger: linger
    ]

    soLingerOff [
	"Specify that, even if the socket promises reliable delivery, any
	 packets that are unacknowledged/untransmitted when it is closed
	 are to be left to their destiny or discarded."

	<category: 'socket options'>
	^self implementation soLinger: nil
    ]

    species [
	<category: 'socket options'>
	^String
    ]

    address [
	"Answer an IP address that is of common interest (this can be either
	 the local or the remote address, according to the definition in the
	 subclass)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    available [
	"Answer whether there is data available on the socket."

	<category: 'accessing'>
	^self implementation canRead
    ]

    close [
	"Close the socket represented by the receiver."

	<category: 'accessing'>
	self flush.
	self implementation close
    ]

    flush [
	"Flush any buffers used by the receiver."

	<category: 'accessing'>
	
    ]

    isOpen [
	"Answer whether the connection between the receiver and the remote
	 endpoint is still alive."

	<category: 'accessing'>
	self implementation isNil ifTrue: [^false].
	^self implementation isOpen
    ]

    localAddress [
	"Answer the local IP address of the socket."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation localAddress
    ]

    localPort [
	"Answer the local IP port of the socket."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation localPort
    ]

    port [
	"Answer an IP port that is of common interest (this can be the port for
	 either the local or remote endpoint, according to the definitions in the
	 subclass"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    remoteAddress [
	"Answer the IP address of the socket's remote endpoint."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation remoteAddress
    ]

    remotePort [
	"Answer the IP port of the socket's remote endpoint."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation remotePort
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $[;
	    print: self address;
	    nextPut: $:;
	    print: self port;
	    nextPutAll: ']'
    ]

    implementation [
	<category: 'private'>
	^impl
    ]

    initialize: implementation [
	<category: 'private'>
	impl := implementation
    ]

    waitUntil: aBlock then: resultBlock onTimeoutDo: timeoutBlock [
	<category: 'private'>
	Timeout // CheckPeriod timesRepeat: 
		[aBlock value ifTrue: [^resultBlock value].
		(Delay forMilliseconds: CheckPeriod) wait].
	self close.
	^timeoutBlock value
    ]

    atEnd [
	"By default, answer whether the connection is still open."

	<category: 'stream protocol'>
	^self isOpen
    ]

    next [
	"Read another character from the socket, failing if the connection is
	 dead."

	<category: 'stream protocol'>
	^self implementation next
    ]

    nextPut: char [
	"Write `char' to the socket, failing if the connection is dead.  The
	 SIGPIPE signal is automatically caught and ignored by the system."

	<category: 'stream protocol'>
	^self implementation nextPut: char
    ]

    isExternalStream [
	"Answer whether the receiver streams on a file or socket."

	<category: 'testing'>
	^true
    ]
]



AbstractSocket subclass: DatagramSocket [
    
    <category: 'Sockets-Streams'>
    <comment: nil>

    DefaultBufferSize := nil.

    DatagramSocket class >> defaultImplementationClass [
	"Answer the default implementation class.  Depending on the
	 subclass, this might be the default stream socket implementation
	 class of the default address class, or rather its default datagram
	 socket implementation class"

	<category: 'accessing'>
	^self defaultAddressClass defaultDatagramSocketImplClass
    ]

    DatagramSocket class >> defaultBufferSize [
	"Answer the default maximum size for input datagrams."

	<category: 'accessing'>
	^DefaultBufferSize
    ]

    DatagramSocket class >> defaultBufferSize: size [
	"Set the default maximum size for input datagrams."

	<category: 'accessing'>
	DefaultBufferSize := size
    ]

    DatagramSocket class >> initialize [
	"Initialize the class to use an input datagram size of 128."

	<category: 'initialization'>
	DatagramSocket defaultBufferSize: 128
    ]

    DatagramSocket class >> new [
	"Answer a new datagram socket (by default an UDP socket), without
	 a specified local address and port."

	<category: 'instance creation'>
	^self local: nil port: 0
    ]

    DatagramSocket class >> port: localPort [
	"Create a new socket and bind it to the local host on the given port."

	<category: 'instance creation'>
	^self 
	    remote: nil
	    port: 0
	    local: nil
	    port: localPort
    ]

    DatagramSocket class >> local: ipAddressOrString port: remotePort [
	"Create a new socket and bind it to the given host (passed as a
	 String to be resolved or as an IPAddress), on the given port."

	<category: 'instance creation'>
	^self 
	    remote: nil
	    port: 0
	    local: ipAddressOrString
	    port: remotePort
    ]

    DatagramSocket class >> remote: ipAddressOrString port: remotePort local: ipAddress port: localPort [
	"Create a new socket and bind it to the given host (passed as a
	 String to be resolved or as an IPAddress), and to the given remotePort.
	 The default destination for the datagrams will be ipAddressOrString
	 (if not nil), on the remotePort port."

	<category: 'instance creation'>
	| localAddr remoteAddr addressClass |
	ipAddressOrString isString 
	    ifTrue: 
		[remoteAddr := SocketAddress byName: ipAddressOrString.
		remoteAddr isNil 
		    ifTrue: 
			[self error: 'cannot resolve host name ' , ipAddressOrString printString]]
	    ifFalse: [remoteAddr := ipAddressOrString].
	addressClass := remoteAddr isNil 
		    ifTrue: [self defaultAddressClass]
		    ifFalse: [remoteAddr class].
	addressClass := ipAddress isNil 
		    ifTrue: [addressClass]
		    ifFalse: [ipAddress class].
	localAddr := ipAddress isNil 
		    ifTrue: [addressClass anyLocalAddress]
		    ifFalse: [ipAddress].
	^(self new: addressClass defaultDatagramSocketImplClass new) 
	    remote: remoteAddr
	    port: remotePort
	    local: localAddr
	    port: localPort
    ]

    address [
	"Answer the local address."

	<category: 'accessing'>
	^self localAddress
    ]

    bufferSize [
	"Answer the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	^self implementation bufferSize
    ]

    bufferSize: size [
	"Set the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	self implementation bufferSize: size
    ]

    next [
	"Read a datagram on the socket and answer it."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: [self implementation next]
	    onTimeoutDo: [nil]
    ]

    nextPut: aDatagram [
	"Send the given datagram on the socket."

	<category: 'accessing'>
	self 
	    waitUntil: [self implementation canWrite]
	    then: 
		[self implementation nextPut: aDatagram.
		aDatagram]
	    onTimeoutDo: [nil]
    ]

    port [
	"Answer the local port."

	<category: 'accessing'>
	^self localPort
    ]

    peek [
	"Peek for a datagram on the socket and answer it."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: [self implementation peek]
	    onTimeoutDo: [nil]
    ]

    peek: datagram [
	"Peek for a datagram on the socket, store it in `datagram', and
	 answer the datagram itself."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: 
		[self implementation peek: datagram.
		true]
	    onTimeoutDo: [false]
    ]

    receive: datagram [
	"Read a datagram from the socket, store it in `datagram', and
	 answer the datagram itself."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: 
		[self implementation receive: datagram.
		true]
	    onTimeoutDo: [false]
    ]

    nextFrom: ipAddress port: port [
	"Answer the next datagram from the given address and port."

	<category: 'direct operations'>
	self 
	    waitUntil: [self implementation canRead]
	    then: [self implementation nextFrom: ipAddress port: port]
	    onTimeoutDo: [nil]
    ]

    remote: remoteAddress port: remotePort local: ipAddress port: localPort [
	"Private - Set the local endpoint of the socket and the default
	 address to which datagrams are sent."

	<category: 'private'>
	(self implementation)
	    soReuseAddr: 1;
	    bufferSize: self class defaultBufferSize;
	    connectTo: remoteAddress port: remotePort;
	    bindTo: ipAddress port: localPort
    ]
]



DatagramSocket subclass: MulticastSocket [
    
    <category: 'Sockets-Streams'>
    <comment: nil>

    interface [
	"Answer the local device supporting the multicast socket.  This
	 is usually set to any local address."

	<category: 'instance creation'>
	^self implementation ipMulticastIf
    ]

    interface: ipAddress [
	"Set the local device supporting the multicast socket.  This
	 is usually set to any local address."

	<category: 'instance creation'>
	self implementation ipMulticastIf: ipAddress
    ]

    join: ipAddress [
	"Join the multicast socket at the given IP address"

	<category: 'instance creation'>
	self implementation join: ipAddress
    ]

    leave: ipAddress [
	"Leave the multicast socket at the given IP address"

	<category: 'instance creation'>
	self implementation leave: ipAddress
    ]

    nextPut: packet timeToLive: timeToLive [
	"Send the datagram with a specific TTL (time-to-live)"

	<category: 'instance creation'>
	| oldTTL |
	oldTTL := self implementation timeToLive.
	self implementation timeToLive: timeToLive.
	self nextPut: packet.
	self implementation timeToLive: oldTTL
    ]

    timeToLive [
	"Answer the socket's datagrams' default time-to-live"

	<category: 'instance creation'>
	^self implementation timeToLive
    ]

    timeToLive: newTTL [
	"Set the default time-to-live for the socket's datagrams"

	<category: 'instance creation'>
	self implementation timeToLive: newTTL
    ]
]



AbstractSocket subclass: ServerSocket [
    
    <category: 'Sockets-Streams'>
    <comment: nil>

    ServerSocket class >> defaultQueueSize [
	"Answer the default length of the queue for pending connections.  When
	 the queue fills, new clients attempting to connect fail until the server
	 is send #accept to accept a connection from the queue."

	<category: 'instance creation'>
	^5
    ]

    ServerSocket class >> queueSize: backlog [
	"Answer a new ServerSocket serving on any local address and port, with a
	 pending connections queue of the given length."

	<category: 'instance creation'>
	^self 
	    port: 0
	    queueSize: backlog
	    bindTo: nil
    ]

    ServerSocket class >> queueSize: backlog bindTo: ipAddress [
	"Answer a new ServerSocket serving on the given local address,
	 and on any port, with a pending connections queue of the given length."

	<category: 'instance creation'>
	^self 
	    port: 0
	    queueSize: backlog
	    bindTo: ipAddress
    ]

    ServerSocket class >> port: anInteger [
	"Answer a new ServerSocket serving on any local address, on the given
	 port, with a pending connections queue of the default length."

	<category: 'instance creation'>
	^self 
	    port: anInteger
	    queueSize: self defaultQueueSize
	    bindTo: nil
    ]

    ServerSocket class >> port: anInteger queueSize: backlog [
	"Answer a new ServerSocket serving on any local address, on the given
	 port, with a pending connections queue of the given length."

	<category: 'instance creation'>
	^self 
	    port: anInteger
	    queueSize: backlog
	    bindTo: nil
    ]

    ServerSocket class >> port: anInteger bindTo: ipAddress [
	"Answer a new ServerSocket serving on the given address and port,
	 with a pending connections queue of the default length."

	<category: 'instance creation'>
	^self 
	    port: anInteger
	    queueSize: self defaultQueueSize
	    bindTo: ipAddress
    ]

    ServerSocket class >> port: anInteger queueSize: backlog bindTo: ipAddress [
	"Answer a new ServerSocket serving on the given address and port,
	 and with a pending connections queue of the given length."

	<category: 'instance creation'>
	| localAddr addressClass |
	addressClass := ipAddress isNil 
		    ifTrue: [self defaultAddressClass]
		    ifFalse: [ipAddress class].
	localAddr := ipAddress isNil 
		    ifTrue: [addressClass unknownAddress]
		    ifFalse: [ipAddress].
	^(self new: addressClass defaultStreamSocketImplClass new) 
	    port: anInteger
	    queueSize: backlog
	    bindTo: localAddr
    ]

    address [
	"Answer the local address"

	<category: 'accessing'>
	^self localAddress
    ]

    port [
	"Answer the local port (the port that the passive socket is listening on)."

	<category: 'accessing'>
	^self localPort
    ]

    waitForConnection [
	"Wait for a connection to be available, and suspend the currently
	 executing process in the meanwhile."

	<category: 'accessing'>
	self implementation ensureReadable
    ]

    accept [
	"Accept a new connection and create a new instance of Socket if there is
	 one, else answer nil."

	<category: 'accessing'>
	self available ifFalse: [^nil].	"Make it non-blocking"
	^self primAccept: Socket
    ]

    accept: socketClass [
	"Accept a new connection and create a new instance of socketClass if
	 there is one, else answer nil.  This is usually needed only to create
	 DatagramSockets."

	<category: 'accessing'>
	self available ifFalse: [^nil].	"Make it non-blocking"
	^self primAccept: socketClass
    ]

    primAccept: socketClass [
	"Accept a new connection and create a new instance of Socket if there is
	 one, else fail."

	<category: 'accessing'>
	| implClass newImpl |
	implClass := socketClass defaultImplementationClass.
	newImpl := self implementation accept: implClass.
	^socketClass new: newImpl
    ]

    port: anInteger queueSize: backlog bindTo: localAddr [
	"Initialize the ServerSocket so that it serves on the given
	 address and port, and has a pending connections queue of
	 the given length."

	<category: 'initializing'>
	(self implementation)
	    soReuseAddr: 1;
	    bindTo: localAddr port: anInteger;
	    listen: backlog
    ]
]



AbstractSocket subclass: Socket [
    | lookahead peerDead readBuffer writeBuffer outOfBand |
    
    <category: 'Sockets-Streams'>
    <comment: nil>

    Ports := nil.
    ReadBufferSize := nil.
    WriteBufferSize := nil.

    Socket class >> portEcho [
	"Answer the port on which the ECHO service listens"

	<category: 'well known ports'>
	^7
    ]

    Socket class >> portDiscard [
	"Answer the port on which the DISCARD service listens"

	<category: 'well known ports'>
	^9
    ]

    Socket class >> portSystat [
	"Answer the port on which the SYSTAT service listens"

	<category: 'well known ports'>
	^11
    ]

    Socket class >> portDayTime [
	"Answer the port on which the TOD service listens"

	<category: 'well known ports'>
	^13
    ]

    Socket class >> portNetStat [
	"Answer the port on which the NETSTAT service listens"

	<category: 'well known ports'>
	^15
    ]

    Socket class >> portFTP [
	"Answer the port on which the FTP daemon listens"

	<category: 'well known ports'>
	^21
    ]

    Socket class >> portSSH [
	"Answer the port on which the SSH daemon listens"

	<category: 'well known ports'>
	^22
    ]

    Socket class >> portTelnet [
	"Answer the port on which the TELNET daemon listens"

	<category: 'well known ports'>
	^23
    ]

    Socket class >> portSMTP [
	"Answer the port on which the SMTP daemon listens"

	<category: 'well known ports'>
	^25
    ]

    Socket class >> portTimeServer [
	"Answer the port on which the time server listens"

	<category: 'well known ports'>
	^37
    ]

    Socket class >> portDNS [
	"Answer the port on which the DNS listens"

	<category: 'well known ports'>
	^53
    ]

    Socket class >> portWhois [
	"Answer the port on which the WHOIS daemon listens"

	<category: 'well known ports'>
	^43
    ]

    Socket class >> portGopher [
	"Answer the port on which the Gopher daemon listens"

	<category: 'well known ports'>
	^70
    ]

    Socket class >> portFinger [
	"Answer the port on which the finger daemon listens"

	<category: 'well known ports'>
	^79
    ]

    Socket class >> portHTTP [
	"Answer the port on which the http daemon listens"

	<category: 'well known ports'>
	^80
    ]

    Socket class >> portPOP3 [
	"Answer the port on which the pop3 daemon listens"

	<category: 'well known ports'>
	^110
    ]

    Socket class >> portNNTP [
	"Answer the port on which the nntp daemon listens"

	<category: 'well known ports'>
	^119
    ]

    Socket class >> portExecServer [
	"Answer the port on which the exec server listens"

	<category: 'well known ports'>
	^512
    ]

    Socket class >> portLoginServer [
	"Answer the port on which the rlogin daemon listens"

	<category: 'well known ports'>
	^513
    ]

    Socket class >> portCmdServer [
	"Answer the port on which the rsh daemon listens"

	<category: 'well known ports'>
	^514
    ]

    Socket class >> portReserved [
	"Answer the last port reserved to privileged processes"

	<category: 'well known ports'>
	^1023
    ]

    Socket class >> defaultPortAt: protocol [
	"Answer the port that is used (by default) for the given service (high
	 level protocol)"

	<category: 'well known ports'>
	^Ports at: protocol
    ]

    Socket class >> defaultPortAt: protocol ifAbsent: port [
	"Answer the port that is used (by default) for the given service (high
	 level protocol), or the specified port if none is registered."

	<category: 'well known ports'>
	^Ports at: protocol ifAbsent: port
    ]

    Socket class >> defaultPortAt: protocol put: port [
	"Associate the given port to the service specified by `protocol'."

	<category: 'well known ports'>
	^Ports at: protocol put: port
    ]

    Socket class >> initialize [
	"Initialize the receiver's defaults"

	<category: 'well known ports'>
	self
	    readBufferSize: 1024;
	    writeBufferSize: 256.
	Ports := (Dictionary new)
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
    ]

    Socket class >> defaultImplementationClass [
	"Answer the default implementation class.  Depending on the
	 subclass, this might be the default stream socket implementation
	 class of the default address class, or rather its default datagram
	 socket implementation class"

	<category: 'accessing'>
	^self defaultAddressClass defaultStreamSocketImplClass
    ]

    Socket class >> readBufferSize [
	"Answer the size of the read buffer for newly-created sockets"

	<category: 'accessing'>
	^ReadBufferSize
    ]

    Socket class >> readBufferSize: anInteger [
	"Set the size of the read buffer for newly-created sockets"

	<category: 'accessing'>
	ReadBufferSize := anInteger
    ]

    Socket class >> writeBufferSize [
	"Answer the size of the write buffer for newly-created sockets"

	<category: 'accessing'>
	^WriteBufferSize
    ]

    Socket class >> writeBufferSize: anInteger [
	"Set the size of the write buffer for newly-created sockets"

	<category: 'accessing'>
	WriteBufferSize := anInteger
    ]

    Socket class >> remote: ipAddressOrString port: remotePort [
	"Create a new socket and connect to the given host (passed as a
	 String to be resolved or as a SocketAddress), and to the given port."

	<category: 'instance creation'>
	^self 
	    remote: ipAddressOrString
	    port: remotePort
	    local: nil
	    port: 0
    ]

    Socket class >> remote: ipAddressOrString port: remotePort local: ipAddress port: localPort [
	"Create a new socket and connect to the given host (passed as a
	 String to be resolved or as a SocketAddress), and to the given remotePort.
	 Then bind it to the local address passed in ipAddress, on the localPort
	 port; if the former is nil, any local address will do, and if the latter
	 is 0, any local port will do."

	<category: 'instance creation'>
	| localAddr remoteAddr addressClass |
	remoteAddr := ipAddressOrString isString 
		    ifTrue: [SocketAddress byName: ipAddressOrString]
		    ifFalse: [ipAddressOrString].
	remoteAddr isNil 
	    ifTrue: 
		[self error: 'cannot resolve host name ' , ipAddressOrString printString].
	addressClass := remoteAddr isNil 
		    ifTrue: [self defaultAddressClass]
		    ifFalse: [remoteAddr class].
	addressClass := ipAddress isNil 
		    ifTrue: [addressClass]
		    ifFalse: [ipAddress class].
	^(self new: addressClass defaultStreamSocketImplClass new) 
	    remote: remoteAddr
	    port: remotePort
	    local: localAddr
	    port: localPort
    ]

    address [
	"Answer the address of the remote endpoint"

	<category: 'accessing'>
	^self remoteAddress
    ]

    port [
	"Answer the port of the remote endpoint"

	<category: 'accessing'>
	^self remotePort
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPutAll: '[local ';
	    print: self localAddress;
	    nextPut: $:;
	    print: self localPort;
	    nextPutAll: ', remote ';
	    print: self remoteAddress;
	    nextPut: $:;
	    print: self remotePort;
	    nextPut: $]
    ]

    remote: remoteAddr port: remotePort local: localAddr port: localPort [
	<category: 'private'>
	localAddr isNil 
	    ifFalse: [self implementation bindTo: localAddr port: localPort].
	self implementation connectTo: remoteAddr port: remotePort
    ]

    species [
	<category: 'private'>
	^String
    ]

    atEnd [
	"Answer whether more data is available on the socket"

	<category: 'stream protocol'>
	^self peek isNil
    ]

    available [
	"Answer whether more data is available in the socket's read buffer
	 or from the operating system."

	<category: 'stream protocol'>
	^(self hasReadBuffer and: [self readBuffer notEmpty]) 
	    or: [super available]
    ]

    bufferContents [
	"Answer the current contents of the read buffer"

	<category: 'stream protocol'>
	| result |
	readBuffer isNil ifTrue: [^self pastEnd].
	result := self readBuffer bufferContents.
	lookahead isNil 
	    ifFalse: 
		[result := lookahead asString , result.
		lookahead := nil].
	^result
    ]

    close [
	"Flush and close the socket."

	<category: 'stream protocol'>
	super close.
	self deleteBuffers
    ]

    fill [
	"Fill the read buffer with data read from the socket"

	<category: 'stream protocol'>
	self readBuffer notNil ifTrue: [self readBuffer fill]
    ]

    flush [
	"Flush the write buffer to the operating system"

	<category: 'stream protocol'>
	self writeBuffer notNil ifTrue: [self writeBuffer flush]
    ]

    isPeerAlive [
	"Answer whether the connection with the peer remote machine is still
	 valid."

	<category: 'stream protocol'>
	^self readBuffer notNil
    ]

    next [
	"Read a byte from the socket.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	| result |
	lookahead isNil ifTrue: [^self readBuffer next].
	result := lookahead.
	lookahead := nil.
	^result
    ]

    nextHunk [
	"Answer the next buffers worth of stuff in the Stream represented
	 by the receiver.  Do at most one actual input operation."

	"Ensure that the buffer is full"

	<category: 'stream protocol'>
	self peek.
	^self bufferContents
    ]

    next: count [
	"Read `count' bytes from the socket.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	| result |
	lookahead isNil ifTrue: [^self readBuffer next: count].
	result := (String with: lookahead) , (self readBuffer next: count - 1).
	lookahead := nil.
	^result
    ]

    nextPut: char [
	"Write a character to the socket; this acts as a bit-bucket when
	 the socket is closed.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	self writeBuffer isNil ifTrue: [^self].
	self writeBuffer nextPut: char
    ]

    nextPutAll: aString [
	"Write aString to the socket; this acts as a bit-bucket when
	 the socket is closed.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	self writeBuffer isNil ifTrue: [^self].
	self writeBuffer nextPutAll: aString
    ]

    peek [
	"Read a byte from the socket, without advancing the buffer; answer
	 nil if no more data is available.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	lookahead isNil 
	    ifTrue: 
		[self readBuffer isNil ifTrue: [^nil].
		self readBuffer atEnd ifTrue: [^nil].
		lookahead := self readBuffer next].
	^lookahead
    ]

    peekFor: anObject [
	"Read a byte from the socket, advancing the buffer only if it matches
	 anObject; answer whether they did match or not.  This might yield
	 control to other Smalltalk Processes."

	<category: 'stream protocol'>
	lookahead isNil 
	    ifTrue: 
		[self readBuffer isNil ifTrue: [^false].
		self readBuffer atEnd ifTrue: [^false].
		lookahead := self readBuffer next].
	^lookahead = anObject 
	    ifTrue: 
		[lookahead := nil.
		true]
	    ifFalse: [false]
    ]

    readBufferSize: size [
	"Create a new read buffer of the given size (which is only
	 possible before the first read or if the current buffer is
	 empty)."

	<category: 'stream protocol'>
	readBuffer isNil ifTrue: [^self].
	(self hasReadBuffer and: [readBuffer notEmpty]) 
	    ifTrue: [self error: 'read buffer must be empty before changing its size'].
	readBuffer := self newReadBuffer: size
    ]

    writeBufferSize: size [
	"Create a new write buffer of the given size, flushing the
	 old one is needed.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	writeBuffer isNil ifTrue: [^self].
	self hasWriteBuffer ifTrue: [writeBuffer flush].
	writeBuffer := self newWriteBuffer: size
    ]

    deleteBuffers [
	<category: 'private - buffering'>
	readBuffer := writeBuffer := nil
    ]

    noBufferFlag [
	"Value that means `lazily initialize the readBuffer and writeBuffer'."

	<category: 'private - buffering'>
	^0
    ]

    hasReadBuffer [
	<category: 'private - buffering'>
	^readBuffer ~~ self noBufferFlag
    ]

    hasWriteBuffer [
	<category: 'private - buffering'>
	^writeBuffer ~~ self noBufferFlag
    ]

    initialize: implementation [
	<category: 'private - buffering'>
	super initialize: implementation.
	readBuffer := writeBuffer := self noBufferFlag
    ]

    newReadBuffer: size [
	<category: 'private - buffering'>
	^(ReadBuffer on: (String new: size)) fillBlock: 
		[:data :size | 
		self implementation ensureReadable.
		self implementation isOpen 
		    ifTrue: [self implementation read: data numBytes: size]
		    ifFalse: 
			[self deleteBuffers.
			0]]
    ]

    newWriteBuffer: size [
	<category: 'private - buffering'>
	^(WriteBuffer on: (String new: size)) flushBlock: 
		[:data :size | 
		| alive |
		self implementation ensureWriteable.
		alive := self implementation isOpen 
			    and: [(self implementation write: data numBytes: size) > -1].
		alive ifFalse: [self deleteBuffers]]
    ]

    readBuffer [
	<category: 'private - buffering'>
	readBuffer == self noBufferFlag 
	    ifTrue: [readBuffer := self newReadBuffer: ReadBufferSize].
	^readBuffer
    ]

    writeBuffer [
	<category: 'private - buffering'>
	writeBuffer == self noBufferFlag 
	    ifTrue: [writeBuffer := self newWriteBuffer: WriteBufferSize].
	^writeBuffer
    ]

    outOfBand [
	"Return a datagram socket to be used for receiving out-of-band data
	 on the receiver."

	<category: 'out-of-band data'>
	| outOfBandImpl |
	outOfBand isNil 
	    ifTrue: 
		[outOfBandImpl := self implementation outOfBandImplClass new.
		outOfBandImpl initialize: self implementation fd.
		outOfBand := DatagramSocket new: outOfBandImpl].
	^outOfBand
    ]
]



Eval [
    AbstractSocket
	timeout: 30000;
	checkPeriod: 100;
	defaultAddressClass: IPAddress
]

