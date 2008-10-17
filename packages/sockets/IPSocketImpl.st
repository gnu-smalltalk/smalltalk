"======================================================================
|
|   Smalltalk IPv4 sockets
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



SocketAddress subclass: IPAddress [
    | address |
    
    <comment: '
This class models an IPv4 address.  It also acts as a factory for IPv4
stream (TCP), datagram (UDP) and raw sockets.'>
    <category: 'Sockets-Protocols'>

    IPAddress class >> initialize [
	"Set up the default implementation classes for the receiver"

	<category: 'initialization'>
	self defaultRawSocketImplClass: ICMPSocketImpl.
	self defaultDatagramSocketImplClass: UDPSocketImpl.
	self defaultStreamSocketImplClass: TCPSocketImpl
    ]

    IPAddress class >> createLoopbackHost [
	"Answer an object representing the loopback host in the address
	 family for the receiver.  This is 127.0.0.1 for IPv4."

	<category: 'initialization'>
	^IPAddress fromBytes: #[127 0 0 1]
    ]

    IPAddress class >> createUnknownAddress [
	"Answer an object representing an unkown address in the address
	 family for the receiver"

	<category: 'initialization'>
	^(IPAddress fromBytes: #[0 0 0 0])
	    name: '0.0.0.0';
	    yourself
    ]

    IPAddress class >> addressSize [
	"Answer the size of an IPv4 address."

	<category: 'constants'>
	^4
    ]

    IPAddress class >> version [
	"Answer the version of IP that the receiver implements."

	<category: 'constants'>
	^4
    ]

    IPAddress class >> fromBytes: aByteArray [
	"Answer a new IPAddress from a ByteArray containing the bytes
	 in the same order as the digit form: 131.175.6.2 would be
	 represented as #[131 175 6 2]."

	<category: 'instance creation'>
	^self basicNew 
	    address: ((aByteArray copyFrom: 1 to: 4) makeReadOnly: true)
    ]

    IPAddress class >> fromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new IPAddress from a ByteArray containing a
	 C sockaddr_in structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to."

	<category: 'instance creation'>
	portAdaptor value: (aByteArray at: 3) * 256 + (aByteArray at: 4).
	^self fromBytes: (aByteArray copyFrom: 5 to: 8)
    ]

    IPAddress class >> fromString: aString [
	"Answer a new IPAddress from a String containing the requested
	 address in digit form.  Hexadecimal forms are not allowed.
	 
	 An Internet host address is a number containing four bytes of data.
	 These are divided into two parts, a network number and a local
	 network address number within that network. The network number
	 consists of the first one, two or three bytes; the rest of the
	 bytes are the local address.
	 
	 Network numbers are registered with the Network Information Center
	 (NIC), and are divided into three classes--A, B, and C. The local
	 network address numbers of individual machines are registered with
	 the administrator of the particular network.
	 
	 Class A networks have single-byte numbers in the range 0 to 127. There
	 are only a small number of Class A networks, but they can each support
	 a very large number of hosts (several millions). Medium-sized Class B
	 networks have two-byte network numbers, with the first byte in the range
	 128 to 191; they support several thousands of host, but are almost
	 exhausted. Class C networks are the smallest and the most commonly
	 available; they have three-byte network numbers, with the first byte
	 in the range 192-223. Class D (multicast, 224.0.0.0 to 239.255.255.255)
	 and E (research, 240.0.0.0 to 255.255.255.255) also have three-byte
	 network numbers.
	 
	 Thus, the first 1, 2, or 3 bytes of an Internet address specifies a
	 network. The remaining bytes of the Internet address specify the address
	 within that network.  The Class A network 0 is reserved for broadcast to
	 all networks. In addition, the host number 0 within each network is
	 reserved for broadcast to all hosts in that network.  The Class A network
	 127 is reserved for loopback; you can always use the Internet address
	 `127.0.0.1' to refer to the host machine (this is answered by the
	 #loopbackHost class method).
	 
	 Since a single machine can be a member of multiple networks, it can have
	 multiple Internet host addresses. However, there is never supposed to be
	 more than one machine with the same host address.
	 
	 There are four forms of the standard numbers-and-dots notation for
	 Internet addresses: a.b.c.d specifies all four bytes of the address
	 individually; a.b.c interprets as a 2-byte quantity, which is useful for
	 specifying host addresses in a Class B network with network address number
	 a.b; a.b intrprets the last part of the address as a 3-byte quantity,
	 which is useful for specifying host addresses in a Class A network with
	 network address number a.
	 
	 If only one part is given, this corresponds directly to the host address
	 number."

	<category: 'instance creation'>
	| substrings |
	substrings := aString substrings: $..
	substrings := substrings collect: [:each | each asInteger].
	^self fromArray: substrings
    ]

    IPAddress class >> fromArray: parts [
	"Answer a new IPAddress from an array of numbers; the numbers
	 are to be thought as the dot-separated numbers in the standard
	 numbers-and-dots notation for IPv4 addresses."

	<category: 'instance creation'>
	| result last |
	result := ByteArray new: 4.

	"e.g. 2 parts (a.b): byte 1 are taken from a and b; byte
	 4 and 3 are bits 0-7 and 8-15 of c respectively; byte 2 is
	 whatever remains (bits 16-23 is the string is well-formed).
	 Handling (result at: parts size) specially simplifies
	 error checking."
	1 to: parts size - 1 do: [:i | result at: i put: (parts at: i) asInteger].
	last := (parts at: parts size) asInteger.
	result size to: parts size + 1
	    by: -1
	    do: 
		[:i | 
		result at: i put: last \\ 256.
		last := last // 256].
	result at: parts size put: last.
	^self fromBytes: result
    ]

    IPAddress class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    IPAddress class >> with: b1 with: b2 with: b3 with: b4 [
	"Answer a new IPAddress whose bytes (from most-significant
	 to least-significant) are in the parameters."

	<category: 'instance creation'>
	^self basicNew 
	    address: ((ByteArray 
		    with: b1
		    with: b2
		    with: b3
		    with: b4) makeReadOnly: true)
    ]

    IPAddress class >> isDigitAddress: aString [
	"Answer whether aString is a valid address in a.b.c.d form."

	<category: 'private'>
	| dots |
	dots := 0.
	(aString substrings: $.) do: 
		[:part | 
		dots := dots + 1.
		(part allSatisfy: [:each | each isDigit]) ifFalse: [^false].
		part asInteger > 255 ifTrue: [^false]].
	^dots = 4
    ]

    asByteArray [
	"Answer a read-only ByteArray of size four containing the
	 receiver's bytes in network order (big-endian)"

	<category: 'accessing'>
	^address
    ]

    addressClass [
	"Answer the `address class' of the receiver (see
	 IPAddress class>>#fromString:)"

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 ifTrue: [^$A].
	net < 192 ifTrue: [^$B].
	net < 224 ifTrue: [^$C].
	^net < 240 ifTrue: [$D] ifFalse: [$E]
    ]

    host [
	"Answer an host number for the receiver; this is given by
	 the last three bytes for class A addresses, by the last
	 two bytes for class B addresses, else by the last byte."

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 
	    ifTrue: 
		[^(address at: 4) + ((address at: 3) * 256) + ((address at: 2) * 65536)].
	net < 192 ifTrue: [^(address at: 4) + ((address at: 3) * 256)].
	^address at: 4
    ]

    network [
	"Answer a network number for the receiver; this is given by the
	 first three bytes for class C/D/E addresses, by the first two
	 bytes for class B addresses, else by the first byte."

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 ifTrue: [^net].
	net < 192 ifTrue: [^net * 256 + (address at: 2)].
	^net * 65536 + ((address at: 2) * 256) + (address at: 2)
    ]

    subnet [
	"Answer an host number for the receiver; this is 0 for class A
	 addresses, while it is given by the last byte of the network
	 number for class B/C/D/E addresses."

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 ifTrue: [^address at: 2].
	net < 192 ifTrue: [^address at: 3].
	^0
    ]

    isMulticast [
	"Answer whether the receiver reprensents an address reserved for
	 multicast datagram connections"

	<category: 'accessing'>
	^(address at: 1) between: 224 and: 239
	"^self addressClass == $D"
    ]

    printOn: aStream [
	"Print the receiver in dot notation."

	<category: 'printing'>
	address do: [:each | each printOn: aStream]
	    separatedBy: [aStream nextPut: $.]
    ]

    address: aByteArray [
	"Private - Set the ByteArray corresponding to the four parts of
	 the IP address in dot notation"

	<category: 'private'>
	address := aByteArray
    ]

    port: port [
	"Return a ByteArray containing a struct sockaddr for the given port
	 on the IP address represented by the receiver. Family = AF_INET."

	<category: 'private'>
	port < 0 | (port > 65535) ifTrue: [self error: 'port out of range'].
	^(ByteArray new: 16)
	    "Write sin_addr"
	    replaceFrom: 5
		to: 8
		with: address
		startingAt: 1;

	    "Write sin_len and sin_family = AF_INET"
	    at: 1 put: 16;
	    at: 2 put: self class addressFamily;

	    "Write sin_port in network order (big endian)"
	    at: 3 put: port // 256;
	    at: 4 put: (port bitAnd: 255);
	    yourself

    ]
]



SocketImpl subclass: TCPSocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv4 stream
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET and type SOCK_STREAM.'>
    <category: 'Sockets-Protocols'>

    valueWithoutBuffering: aBlock [
        "Evaluate aBlock, ensuring that any data that it writes to the socket
         is sent immediately to the network."

        <category: 'socket options'>
        ^[self optionAt: self class tcpNodelay
	    level: self class ipprotoTcp
	    put: 1.
	aBlock value] ensure:
            [self optionAt: self class tcpNodelay
		level: self class ipprotoTcp
		put: 0]
    ]
]



MulticastSocketImpl subclass: UDPSocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv4 datagram
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET and type SOCK_DGRAM.'>
    <category: 'Sockets-Protocols'>

    ipMulticastIf [
	"Answer the local device for a multicast socket (in the form of
	 an address)"

	<category: 'multicasting'>
	^self addressClass fromByteArray: (self 
		    optionAt: self ipMulticastIf
		    level: self class ipprotoIp
		    size: CInt sizeof)
    ]

    ipMulticastIf: interface [
	"Set the local device for a multicast socket (in the form of
	 an address, usually anyLocalAddress)"

	<category: 'multicasting'>
	self 
	    optionAt: self ipMulticastIf
	    level: self class ipprotoIp
	    put: interface
    ]

    join: ipAddress [
	"Join the multicast socket at the given address"

	<category: 'multicasting'>
	self primJoinLeave: ipAddress option: self ipAddMembership
    ]

    leave: ipAddress [
	"Leave the multicast socket at the given address"

	<category: 'multicasting'>
	self primJoinLeave: ipAddress option: self ipDropMembership
    ]

    primJoinLeave: ipAddress option: opt [
	"Private - Used to join or leave a multicast service."

	<category: 'multicasting'>
	| data |
	data := ByteArray new: IPAddress addressSize * 2.
	data
	    replaceFrom: 1
		to: IPAddress addressSize
		with: ipAddress asByteArray
		startingAt: 1;
	    replaceFrom: IPAddress addressSize + 1
		to: data size
		with: IPAddress anyLocalAddress asByteArray
		startingAt: 1.
	self 
	    optionAt: opt
	    level: self class ipprotoIp
	    put: data
    ]

    timeToLive [
	"Answer the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	^(self 
	    optionAt: self ipMulticastTtl
	    level: self class ipprotoIp
	    size: CInt sizeof) intAt: 1
    ]

    timeToLive: ttl [
	"Set the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	self 
	    optionAt: self ipMulticastTtl
	    level: self class ipprotoIp
	    put: ttl
    ]
]



RawSocketImpl subclass: ICMPSocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv4 raw
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET, type SOCK_RAW, protocol IPPROTO_ICMP.'>
    <category: 'Sockets-Protocols'>

]

