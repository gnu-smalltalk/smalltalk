"======================================================================
|
|   Smalltalk TCP/IP sockets
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


SocketAddress subclass: #IPAddress
       instanceVariableNames: 'address'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Sockets-Protocols'
! 

SocketImpl subclass:  #TCPSocketImpl
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sockets-Protocols'!

TCPSocketImpl comment: 
nil!

DatagramSocketImpl subclass:  #OOBSocketImpl
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sockets-Protocols'!

OOBSocketImpl comment: 
nil!

MulticastSocketImpl subclass:  #UDPSocketImpl
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sockets-Protocols'!

UDPSocketImpl comment: 
nil!

RawSocketImpl subclass:  #ICMPSocketImpl
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sockets-Protocols'!

ICMPSocketImpl comment: 
nil!

CStruct newStruct: #CSockAddrStruct declaration: #( 
	(#sinFamily #short)
	(#sinPort (#array #byte 2))
	(#sinAddr (#array #byte 4))
	(#sinZero (#array #byte 8))
)!

!IPAddress class methodsFor: 'initialization'!

initialize
    "Set up the default implementation classes for the receiver"
    self defaultRawSocketImplClass: ICMPSocketImpl.
    self defaultDatagramSocketImplClass: UDPSocketImpl.
    self defaultStreamSocketImplClass: TCPSocketImpl
!

createLocalAddress
    "Answer an object representing a local address in the address
     family for the receiver"
    | localAddrBytes |
    self
	primAnyLocalAddress: localHostName
	in: (localAddrBytes := ByteArray new: 4).
    ^IPAddress fromBytes: localAddrBytes.
!

createLoopbackHost
    "Answer an object representing the loopback host in the address
     family for the receiver.  This is 127.0.0.1 for IPv4."
    ^IPAddress fromBytes: #[127 0 0 1].
!

createUnknownAddress
    "Answer an object representing an unkown address in the address
     family for the receiver"
    ^(IPAddress fromBytes: #[0 0 0 0])
	name: '0.0.0.0';
	yourself
! !

!IPAddress class methodsFor: 'constants'!

addressSize
    "Answer the size of an IPv4 address."
    ^4
!

version
    "Answer the version of IP that the receiver implements."
    ^4
! !

!IPAddress class methodsFor: 'instance creation'!

fromBytes: aByteArray
    "Answer a new IPAddress from a ByteArray containing the bytes
     in the same order as the digit form: 131.175.6.2 would be
     represented as #[131 175 6 2]."
    ^self basicNew
	address: ((aByteArray copyFrom: 1 to: 4) makeReadOnly: true)
!

fromSockAddr: aByteArray port: portAdaptor
    "Private - Answer a new IPAddress from a ByteArray containing a
     C sockaddr_in structure.  The portAdaptor's value is changed
     to contain the port that the structure refers to."
    | s |
    s := CSockAddrStruct sizeof.
    portAdaptor value:
	(aByteArray at: s - 13) * 256 + (aByteArray at: s - 12).
    
    ^self fromBytes: (aByteArray copyFrom: s - 11 to: s - 8)
!

fromString: aString
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

    | substrings |
    substrings := aString substrings: $. .
    substrings := substrings collect: [ :each | each asInteger ].
    ^self fromArray: substrings
!

fromArray: parts
    "Answer a new IPAddress from an array of numbers; the numbers
     are to be thought as the dot-separated numbers in the standard
     numbers-and-dots notation for IPv4 addresses."

    | result last |
    result := ByteArray new: 4.

    "e.g. 2 parts (a.b): byte 1 are taken from a and b; byte 
     4 and 3 are bits 0-7 and 8-15 of c respectively; byte 2 is
     whatever remains (bits 16-23 is the string is well-formed).
     Handling (result at: parts size) specially simplifies
     error checking."

    1 to: parts size - 1 do: [ :i |
	result at: i put: (parts at: i) asInteger
    ].
    last := (parts at: parts size) asInteger.
    result size to: parts size + 1 by: -1 do: [ :i |
	result at: i put: last \\ 256.
	last := last // 256.
    ].
    result at: parts size put: last.
    ^self fromBytes: result
!

new
    self shouldNotImplement
!

with: b1 with: b2 with: b3 with: b4
    "Answer a new IPAddress whose bytes (from most-significant
     to least-significant) are in the parameters."
    ^self basicNew address:
	((ByteArray with: b1 with: b2 with: b3 with: b4) makeReadOnly: true)
! !

!IPAddress class methodsFor: 'private'!

extractAddressesAfterLookup: result
    "Private - Given a CByte object, extract the arrays returned by 
     gethostbyname and answer them."
    | addresses index addr |
    addresses := WriteStream on: (Array new: 1).
    index := 0.
    [
       addr := self
	    with: (result at: index)
	    with: (result at: index + 1)
	    with: (result at: index + 2)
	    with: (result at: index + 3).

	index := index + 4.
	addr = unknownAddress
    ]   whileFalse: [ addresses nextPut: addr ].
    ^addresses contents.
!

isDigitAddress: aString
    "Answer whether the receiver is a valid address in a.b.c.d form."
    | dots |
    dots := 0.
    (aString substrings: $.) do: [ :part |
	dots := dots + 1.
	(part allSatisfy: [ :each | each isDigit ])
	    ifFalse: [ ^false ].

	part asInteger > 255 ifTrue: [ ^false ].
    ].
    ^dots = 4
! !


!IPAddress methodsFor: 'accessing'!

asByteArray
    "Answer a read-only ByteArray of size four containing the
     receiver's bytes in network order (big-endian)"
    ^address
!

addressClass
    "Answer the `address class' of the receiver (see
    IPAddress class>>#fromString:)"
    | net |
    net := address at: 1.
    net < 128 ifTrue: [ ^$A ].
    net < 192 ifTrue: [ ^$B ].
    net < 224 ifTrue: [ ^$C ].
    ^net < 240 ifTrue: [ $D ] ifFalse: [ $E ]
!

host
    "Answer an host number for the receiver; this is given by
     the last three bytes for class A addresses, by the last
     two bytes for class B addresses, else by the last byte."
    | net |
    net := address at: 1.
    net < 128 ifTrue: [
	^(address at: 4) + ((address at: 3) * 256) + ((address at: 2) * 65536)
    ].
    net < 192 ifTrue: [
	^(address at: 4) + ((address at: 3) * 256)
    ].
    ^address at: 4
!

network
    "Answer a network number for the receiver; this is given by the
     first three bytes for class C/D/E addresses, by the first two
     bytes for class B addresses, else by the first byte."
    | net |
    net := address at: 1.
    net < 128 ifTrue: [ ^net ].
    net < 192 ifTrue: [	^net * 256 + (address at: 2) ].
    ^net * 65536 + ((address at: 2) * 256) + (address at: 2)
!

subnet
    "Answer an host number for the receiver; this is 0 for class A
     addresses, while it is given by the last byte of the network
     number for class B/C/D/E addresses."
    | net |
    net := address at: 1.
    net < 128 ifTrue: [ ^(address at: 2) ].
    net < 192 ifTrue: [	^(address at: 3) ].
    ^0
!

isMulticast
    "Answer whether the receiver reprensents an address reserved for
     multicast datagram connections"
    ^(address at: 1) between: 224 and: 239
    "^self addressClass == $D"
! !

!IPAddress methodsFor: 'printing'!

printOn: aStream
    "Print the receiver in dot notation."
    address
	do: [ :each | each printOn: aStream ]
	separatedBy: [ aStream nextPut: $. ]
! !

!IPAddress methodsFor: 'private'!

address: aByteArray
    "Private - Set the ByteArray corresponding to the four parts of
     the IP address in dot notation"
    address := aByteArray
!

port: port
    "Return a ByteArray containing a struct sockaddr for the given port
     on the IP address represented by the receiver. Family = AF_INET."

    (port < 0) | (port > 16rFFFF)
	ifTrue: [ self error: 'port out of range' ].

    ^(ByteArray new: CSockAddrStruct sizeof)

	"Write sin_addr"
	replaceFrom: CSockAddrStruct sizeof - 11
	to: CSockAddrStruct sizeof - 8
	with: address
	startingAt: 1;

	"Write sin_family = AF_INET in host order"
	shortAt: 1 put: self class addressFamily;

	"Write sin_port in network order (big endian)"
	at: CSockAddrStruct sizeof - 13 put: port // 256;
	at: CSockAddrStruct sizeof - 12 put: (port bitAnd: 255);

	"ouf..."
	yourself
! !



!TCPSocketImpl class methodsFor: 'implementation'!

addressClass
    "Answer the class that holds network addresses for TCP sockets,
     i.e. IPAddress."
    ^IPAddress
! !

!TCPSocketImpl methodsFor: 'implementation'!

outOfBandImplClass
    "Return an implementation class to be used for out-of-band data
     on the receiver."
    ^OOBSocketImpl
! !



!OOBSocketImpl class methodsFor: 'implementation'!

addressClass
    "Answer the class that holds network addresses for TCP sockets,
     i.e. IPAddress."
    ^IPAddress
! !

!OOBSocketImpl methodsFor: 'implementation'!

canRead
    "Answer whether out-of-band data is available on the socket"
    ^self exceptionalCondition
!

ensureReadable
    "Stop the process until an error occurs or out-of-band data
     becomes available on the socket"
    ^self waitForException
! !

!OOBSocketImpl methodsFor: 'private'!

flags
    ^self msgOOB
! !



!UDPSocketImpl class methodsFor: 'implementation'!

addressClass
    "Answer the class that holds network addresses for UDP sockets,
     i.e. IPAddress."
    ^IPAddress
! !

!UDPSocketImpl methodsFor: 'multicasting'!

ipMulticastIf
    "Answer the local device for a multicast socket (in the form of
     an address)"
    ^self addressClass fromByteArray: (self
	optionAt: self ipMulticastIf
	level: self class ipprotoIp
	size: CInt sizeof)
!

ipMulticastIf: interface
    "Set the local device for a multicast socket (in the form of
     an address, usually anyLocalAddress)"
    self
	optionAt: self ipMulticastIf
	level: self class ipprotoIp
	put: interface
!

join: ipAddress
    "Join the multicast socket at the given address"
    self primJoinLeave: ipAddress option: self ipAddMembership
!

leave: ipAddress
    "Leave the multicast socket at the given address"
    self primJoinLeave: ipAddress option: self ipDropMembership
!

primJoinLeave: ipAddress option: opt
    "Private - Used to join or leave a multicast service."
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
!

timeToLive
    "Answer the time to live of the datagrams sent through the receiver
     to a multicast socket."
    ^(self
	optionAt: self ipMulticastTtl
	level: self class ipprotoIp
	size: CInt sizeof) intAt: 1
!

timeToLive: ttl
    "Set the time to live of the datagrams sent through the receiver
     to a multicast socket."
    self
	optionAt: self ipMulticastTtl
	level: self class ipprotoIp
	put: ttl
! !



!ICMPSocketImpl class methodsFor: 'implementation'!

addressClass
     "Answer the class that holds network addresses for ICMP sockets,
     i.e. IPAddress."
    ^IPAddress
! !


