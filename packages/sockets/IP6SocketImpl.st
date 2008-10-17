"======================================================================
|
|   Smalltalk IPv6 addresses
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
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



SocketAddress subclass: IP6Address [
    | address |
    
    <comment: '
This class models an IPv6 address.  It also acts as a factory for IPv6
stream (TCP), datagram (UDP) and raw sockets.'>
    <category: 'Sockets-Protocols'>

    IP6Address class >> initialize [
	"Set up the default implementation classes for the receiver"

	<category: 'initialization'>
	self defaultRawSocketImplClass: ICMP6SocketImpl.
	self defaultDatagramSocketImplClass: UDPSocketImpl.
	self defaultStreamSocketImplClass: TCPSocketImpl
    ]

    IP6Address class >> createLoopbackHost [
	"Answer an object representing the loopback host in the address
	 family for the receiver.  This is ::1 for IPv4."

	<category: 'initialization'>
	^(IP6Address fromBytes: #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1])
	    name: '::1';
	    yourself
    ]

    IP6Address class >> createUnknownAddress [
	"Answer an object representing an unkown address in the address
	 family for the receiver"

	<category: 'initialization'>
	^(IP6Address fromBytes: #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0])
	    name: '::0';
	    yourself
    ]

    IP6Address class >> aiFlags [
	<category: 'private'>
	^self aiV4mapped + self aiAll
    ]

    IP6Address class >> addressSize [
	"Answer the size of an IPv4 address."

	<category: 'constants'>
	^16
    ]

    IP6Address class >> version [
	"Answer the version of IP that the receiver implements."

	<category: 'constants'>
	^6
    ]

    IP6Address class >> fromBytes: aByteArray [
	"Answer a new IP6Address from a ByteArray containing the bytes
	 in the same order as the digit form: 131.175.6.2 would be
	 represented as #[131 175 6 2]."

	<category: 'instance creation'>
	^self basicNew 
	    address: ((aByteArray copyFrom: 1 to: 16) makeReadOnly: true)
    ]

    IP6Address class >> fromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new IP6Address from a ByteArray containing a
	 C sockaddr_in structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to."

	<category: 'instance creation'>
	portAdaptor value: (aByteArray at: 3) * 256 + (aByteArray at: 4).
	^self fromBytes: (aByteArray copyFrom: 9 to: 24)
    ]

    IP6Address class >> invalidAddress [
	<category: 'private'>
	self error: 'invalid IPv6 address'
    ]

    IP6Address class >> readWordFrom: stream [
	<category: 'private'>
	| n |
	(stream atEnd or: [ stream peekFor: $: ])
	    ifTrue: [ self invalidAddress ].

	n := Integer readFrom: stream radix: 16.
	(n < 0 or: [ n > 65535 ]) ifTrue: [ self invalidAddress ].
	(stream atEnd or: [ stream peekFor: $: ]) ifTrue: [ ^n ].
	self invalidAddress
    ]

    IP6Address class >> fromString: aString [
	"Answer a new IP6Address from a String containing the requested
	 address in digit form."

	<category: 'instance creation'>
	| s n break count expected ipv4 i |
	n := WordArray new: 8.
	count := (aString occurrencesOf: $:) + 1.
	(aString includes: $.)
	    ifTrue: [
		ipv4 := IPAddress fromString: (aString copyAfterLast: $:).
		ipv4 := ipv4 asByteArray.
		n at: 7 put: ipv4 first * 256 + ipv4 second.
		n at: 8 put: ipv4 third * 256 + ipv4 fourth.
		count := count - 1.
		expected := 6 ]
	    ifFalse: [
		expected := 8 ].

	expected < count ifTrue: [ self invalidAddress ].

	i := 1.
	s := aString readStream.
	break := false.
	[ i > expected ] whileFalse: [
	    s atEnd ifTrue: [ self invalidAddress ].
	    (break not and: [ s peekFor: $: ])
		ifTrue: [
		    break := true.
		    i := i + expected - count + 1 ]
		ifFalse: [
		    n at: i put: (self readWordFrom: s).
		    i := i + 1 ] ].
	^self fromArray: n
    ]

    IP6Address class >> fromArray: parts [
	"Answer a new IP6Address from an array of numbers; the numbers
	 are to be thought as the colon-separated numbers in the standard
	 numbers-and-colons notation for IPv4 addresses."

	<category: 'instance creation'>
	| address |
	address := ByteArray new: 16.
	parts keysAndValuesDo: [ :i :each |
	    address at: i * 2 - 1 put: (each bitShift: -8).
	    address at: i * 2 put: (each bitAnd: 255) ].

	^self fromBytes: address
    ]

    IP6Address class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    IP6Address class >> isDigitAddress: aString [
	"Answer whether aString is a valid address in colon-separated form."

	<category: 'private'>
	^false
    ]

    asByteArray [
	"Answer a read-only ByteArray of size four containing the
	 receiver's bytes in network order (big-endian)"

	<category: 'accessing'>
	^address
    ]

    isMulticast [
	"Answer whether the receiver reprensents an address reserved for
	 multicast datagram connections"

	<category: 'accessing'>
	^address first = 255
    ]

    printOn: aStream [
	"Print the receiver in dot notation."

	<category: 'printing'>
	| n words format |
	n := 1.
	1 to: 16 do: [ :i |
	    (n = i and: [ (address at: n) = 0 ]) ifTrue: [ n := i + 1 ] ].

	n = 13 ifTrue: [
	    aStream nextPutAll: '::%1.%2.%3.%4' % (address copyFrom: 13).
	    ^self ].
	(n = 11 and: [ (address at: 11) = 255 and: [ (address at: 12) = 255 ]]) ifTrue: [ 
	    aStream nextPutAll: '::ffff:%1.%2.%3.%4' % (address copyFrom: 13).
	    ^self ].

	words := (1 to: 15 by: 2) collect: [ :i |
	    (((address at: i) * 256 + (address at: i + 1)) printString: 16)
		asLowercase ].

	format := n >= 15 ifTrue: [ '::%8' ] ifFalse: [ '%1:%2:%3:%4:%5:%6:%7:%8' ].
	aStream nextPutAll: format % words
    ]

    address: aByteArray [
	"Private - Set the ByteArray corresponding to the four parts of
	 the IP address in dot notation"

	<category: 'private'>
	address := aByteArray
    ]

    port: port [
	"Return a ByteArray containing a struct sockaddr for the given port
	 on the IP address represented by the receiver. Family = AF_INET6."

	<category: 'private'>
	port < 0 | (port > 65535) ifTrue: [self error: 'port out of range'].
	^(ByteArray new: 28)
	    "Write sin_addr"
	    replaceFrom: 9
		to: 24
		with: address
		startingAt: 1;

            "Write sin_len and sin_family = AF_INET6"
            at: 1 put: 28;
            at: 2 put: self class addressFamily;

	    "Write sin_port in network order (big endian)"
	    at: 3 put: port // 256;
	    at: 4 put: (port bitAnd: 255);
	    yourself

    ]
]



RawSocketImpl subclass: ICMP6SocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv6 raw
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET, type SOCK_RAW, protocol IPPROTO_ICMPV6.'>
    <category: 'Sockets-Protocols'>

]


CStruct subclass: CSockAddrIn6Struct [
    <declaration: #(
		#(#sin6Family #short)
		#(#sin6Port #(#array #byte 2))
		#(#sin6Flowinfo #int)
		#(#sin6Addr #(#array #byte 16))
		#(#sin6ScopeId #int)) >
]

