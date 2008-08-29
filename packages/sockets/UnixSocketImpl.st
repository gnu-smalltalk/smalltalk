"======================================================================
|
|   Smalltalk AF_UNIX sockets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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



SocketAddress subclass: UnixAddress [
    
    <comment: '
This class represents an address for a machine using the AF_UNIX
address family.  Since this address family is only used for local
sockets, the class is a singleton; the filesystem path to the socket
is represented using the port argument to socket functions, as either
a String or a File object.
'>
    <category: 'Sockets-Protocols'>

    UnixAddress class [
	| uniqueInstance |

	initialize [
	    "Set up the default implementation classes for the receiver"

	    <category: 'initialization'>
	    self defaultDatagramSocketImplClass: UnixDatagramSocketImpl.
	    self defaultStreamSocketImplClass: UnixSocketImpl
	]

	uniqueInstance [
	    <category: 'instance creation'>
	    uniqueInstance isNil ifTrue: [ uniqueInstance := self new ].
	    ^uniqueInstance
        ]

	createLoopbackHost [
	    "Answer an object representing the loopback host in the address
	     family for the receiver.  This is 127.0.0.1 for IPv4."

	    <category: 'initialization'>
	    ^self uniqueInstance
        ]

	createUnknownAddress [
	    "Answer an object representing an unkown address in the address
	     family for the receiver"

	    <category: 'initialization'>
	    ^self uniqueInstance
        ]

	fromSockAddr: aByteArray port: portAdaptor [
	    "Private - Answer the unique UnixAddress instance, filling
	     in the portAdaptor's value from a ByteArray containing a
	     C sockaddr_in structure."

	    <category: 'instance creation'>
	    | s size |
	    size := aByteArray
		indexOf: 0 startingAt: 4 ifAbsent: [ aByteArray size + 1 ].
	    s := String new: size - 3.
	    s replaceFrom: 1 to: s size with: aByteArray startingAt: 3.
	    portAdaptor value: s.
	    ^self uniqueInstance
	]

	extractAddressesAfterLookup: result [
	    "Not implemented, DNS should not answer AF_UNIX addresses!"

	    self shouldNotImplement
        ]
    ]

    = aSocketAddress [
	"Answer whether the receiver and aSocketAddress represent
	 the same socket on the same machine."

	<category: 'accessing'>
	^self == aSocketAddress
    ]

    isMulticast [
	"Answer whether an address is reserved for multicast connections."

	<category: 'testing'>
	^false
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'accessing'>
	^self class hash
    ]

    printOn: aStream [
	"Print the receiver in dot notation."

	<category: 'printing'>
	aStream nextPutAll: '[AF_UNIX address family]'
    ]

    port: port [
	"Return a ByteArray containing a struct sockaddr for the given port
	 on the IP address represented by the receiver. Family = AF_UNIX."

	<category: 'private'>
	| portString |
	portString := port asString.
	portString isEmpty
	    ifTrue: [self error: 'invalid socket path'].
	portString size > 108
	    ifTrue: [self error: 'socket path too long'].
	^(ByteArray new: 110)
            "Write sin_len and sin_family = AF_UNIX"
            at: 1 put: portString size + 3;
            at: 2 put: self class addressFamily;
	    replaceFrom: 3 to: portString size + 2 with: portString startingAt: 1;
	    yourself
    ]
]


SocketImpl subclass: UnixSocketImpl [
    
    <comment: '
This class represents a stream socket using the AF_UNIX address family.
It unlinks the filesystem path when the socket is closed.
'>
    
    <category: 'Sockets-Protocols'>

    activeSocketImplClass [
	"Return an implementation class to be used for the active socket
	 created when a connection is accepted by a listening socket.
	 Return SocketImpl, because the active socket should not delete
	 the socket file when it is closed."
	^SocketImpl
    ]

    close [
	<category: 'socket operations'>

	| port |
	port := localPort.
	[ super close ] ensure: [
	    port isNil ifFalse: [ port asFile remove ] ]
    ]
]

DatagramSocketImpl subclass: UnixDatagramSocketImpl [
    
    <comment: '
This class represents a datagram socket using the AF_UNIX address family.
It unlinks the filesystem path when the socket is closed.
'>
    
    <category: 'Sockets-Protocols'>

    close [
	<category: 'socket operations'>

	| port |
	port := localPort.
	[ super close ] ensure: [
	    port isNil ifFalse: [ port asFile remove ] ]
    ]
]
