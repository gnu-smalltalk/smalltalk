"======================================================================
|
|   Smalltalk sockets - SocketAddress class
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



Object subclass: SocketAddress [
    | name |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This class is the abstract class for machine addresses over a network.
It also fulfills the function of the C style functions gethostname(),
gethostbyname(), and gethostbyaddr(), resolves machine names into their
corresponding numeric addresses (via DNS, /etc/hosts, or other mechanisms)
and vice versa.'>

    SocketAddress class [
	| anyLocalAddress loopbackHost unknownAddress defaultStreamSocketImplClass defaultDatagramSocketImplClass defaultRawSocketImplClass |
	
    ]

    Cache := nil.
    LocalHostName := nil.

    SocketAddress class >> defaultStreamSocketImplClass [
	"Answer the class that, by default, is used to map between the
	 Socket's protocol and a low-level C interface."

	<category: 'accessing'>
	^defaultStreamSocketImplClass ifNil: [ SocketImpl ]
    ]

    SocketAddress class >> defaultStreamSocketImplClass: aClass [
	"Set which class will be used by default to map between the
	 receiver's protocol and a low-level C interface."

	<category: 'accessing'>
	defaultStreamSocketImplClass := aClass
    ]

    SocketAddress class >> defaultRawSocketImplClass [
	"Answer the class that, by default, is used to map between the
	 Socket's protocol and a low-level C interface."

	<category: 'accessing'>
	^defaultRawSocketImplClass ifNil: [ RawSocketImpl ]
    ]

    SocketAddress class >> defaultRawSocketImplClass: aClass [
	"Set which class will be used by default to map between the
	 receiver's protocol and a low-level C interface."

	<category: 'accessing'>
	defaultRawSocketImplClass := aClass
    ]

    SocketAddress class >> defaultDatagramSocketImplClass [
	"Answer the class that, by default, is used to map between the
	 Socket's protocol and a low-level C interface."

	<category: 'accessing'>
	^defaultDatagramSocketImplClass ifNil: [ DatagramSocketImpl ]
    ]

    SocketAddress class >> defaultDatagramSocketImplClass: aClass [
	"Set which class will be used by default to map between the
	 receiver's protocol and a low-level C interface."

	<category: 'accessing'>
	defaultDatagramSocketImplClass := aClass
    ]

    SocketAddress class >> newSocket: socketClass [
        "Answer a new instance of socketClass, using the protocol
         family of the receiver."

        <category: 'private-creating sockets'>
        ^socketClass
            new: (socketClass defaultImplementationClassFor: self)
            addressClass: self
    ]

    SocketAddress class >> newRawSocket [
	"Create a new raw socket, providing access to low-level network protocols
	 and interfaces for the protocol family represented by the receiver
	 (for example, the C protocol family PF_INET for the IPAddress class)
	 Ordinary user programs usually have no need to use this method."

	<category: 'creating sockets'>
	^DatagramSocket new: self defaultRawSocketImplClass addressClass: self
    ]

    SocketAddress class >> initLocalAddresses [
	"Private - Initialize the anyLocalAddress class-instance variable
	 for the entire hierarchy."
	<category: 'initialization'>
	| all |
	"Initialize to the loopback host."
	self withAllSubclassesDo: [ :each | each anyLocalAddress: each loopbackHost].

	"Override with resolved addresses."
	all := self allByName: self localHostName.
	all isNil
	    ifFalse: [all do: [ :each | each class anyLocalAddress: each ]]
    ]

    SocketAddress class >> flush [
	"Flush the cached IP addresses."

	<category: 'initialization'>
	LocalHostName := nil.
	Cache := Dictionary new.
	self withAllSubclassesDo: [:each | each anyLocalAddress: nil ].
    ]

    SocketAddress class >> createUnknownAddress [
	"Answer an object representing an unkown address in the address
	 family for the receiver"

	<category: 'initialization'>
	^Socket defaultAddressClass unknownAddress
    ]

    SocketAddress class >> createLoopbackHost [
	"Answer an object representing the loopback host in the address
	 family for the receiver."

	<category: 'initialization'>
	^Socket defaultAddressClass loopbackHost
    ]

    SocketAddress class >> update: aspect [
	"Flush all the caches for IPAddress subclasses"

	<category: 'initialization'>
	aspect == #returnFromSnapshot ifTrue: [self flush].
    ]

    SocketAddress class >> anyLocalAddress [
	"Answer an IPAddress representing a local address."

	<category: 'accessing'>
	"The local address can be computed with a single lookup for all
	 the classes."
	anyLocalAddress isNil ifTrue: [ SocketAddress initLocalAddresses ].
	^anyLocalAddress
    ]

    SocketAddress class >> anyLocalAddress: anObject [
	"Private - Store an object representing a local address in the address
	 family for the receiver"

	<category: 'initialization'>
	anyLocalAddress := anObject
    ]

    SocketAddress class >> at: host cache: aBlock [
	"Private - Answer the list of addresses associated to the
	 given host in the cache.  If the host is not cached yet,
	 evaluate aBlock and cache and answer the result."

	<category: 'accessing'>
	self == SocketAddress ifFalse: [ ^aBlock value ].

	^Cache at: host ifAbsent: [
	    | result |
	    result := aBlock value.
	    result isNil
		ifTrue: [ nil ]
		ifFalse: [ Cache at: host put: result ] ]
    ]

    SocketAddress class >> aiFlags [
	<category: 'private'>
	^self == SocketAddress ifTrue: [ self aiAddrconfig ] ifFalse: [ 0 ]
    ]

    SocketAddress class >> isDigitAddress: aString [
	"Answer whether the receiver can interpret aString as a valid
	 address without going through a resolver."

	<category: 'accessing'>
	^false
    ]

    SocketAddress class >> localHostName [
	"Answer the name of the local machine."

	<category: 'accessing'>
	LocalHostName isNil ifTrue: [ LocalHostName := self primLocalName ].
	^LocalHostName
    ]

    SocketAddress class >> loopbackHost [
	"Answer an instance of the receiver representing the local machine
	 (127.0.0.1 in the IPv4 family)."

	<category: 'accessing'>
	loopbackHost isNil ifTrue: [ loopbackHost := self createLoopbackHost ].
	loopbackHost name: self localHostName.
	^loopbackHost
    ]

    SocketAddress class >> unknownAddress [
	"Answer an instance of the receiver representing an unknown machine
	 (0.0.0.0 in the IPv4 family)."

	<category: 'accessing'>
	unknownAddress isNil ifTrue: [ unknownAddress := self createUnknownAddress ].
	^unknownAddress
    ]

    SocketAddress class >> allByName: aString [
	"Answer all the IP addresses that refer to the the given host.  If
	 a digit address is passed in aString, the result is an array
	 containing the single passed address.  If the host could not be
	 resolved to an IP address, answer nil."

	<category: 'host name lookup'>
	| host addresses |
	host := aString asLowercase.
	self withAllSubclassesDo: 
		[:c | 
		(c isDigitAddress: host) 
		    ifTrue: [^self at: host cache: [Array with: (c fromString: host)]]].
	addresses := self at: host
	    cache: [ | hints result array |
		hints := CAddrInfoStruct gcNew.
		hints aiFamily value: self protocolFamily.
		hints aiFlags value: (self aiFlags bitOr: self aiCanonname).
		[(result := hints getaddrinfo: host) isNil
                    ifTrue: [nil]
                    ifFalse: [
		        array := self extractAddressesAfterLookup: result.
                        array isEmpty ifTrue: [nil] ifFalse: [array]]]
                    ensure: [result free]].

	^addresses
    ]

    SocketAddress class >> byName: aString [
	"Answer a single IP address that refer to the the given host.  If
	 a digit address is passed in aString, the result is the same as
	 using #fromString:.  If the host could not be resolved to an IP
	 address, answer nil."

	<category: 'host name lookup'>
	| all |
	aString isEmpty ifTrue: [^self loopbackHost].
	all := self allByName: aString.
	all isNil ifTrue: [^nil].
        self == SocketAddress ifFalse: [^all anyOne].
	^all detect: [:each | each isKindOf: Socket defaultAddressClass]
            ifNone: [all anyOne]
    ]

    SocketAddress class >> extractAddressesAfterLookup: aiHead [
	"Private - Given a CByte object, extract the arrays returned by
	 gethostbyname and answer them."

	<category: 'private'>
	| result addrBytes addr ai name |
	result := OrderedCollection new.
	name := aiHead aiCanonname value.
	ai := aiHead.
	[ ai isNil ] whileFalse: [
	    addrBytes := ByteArray fromCData: ai aiAddr value size: ai aiAddrlen value.
	    addr := self
		extractFromSockAddr: addrBytes
		port: NullValueHolder uniqueInstance.
	    addr isNil ifFalse: [
		addr name: name.
		(result includes: addr) ifFalse: [ result add: addr ] ].
	    ai := ai aiNext value ].
	^result
    ]

    SocketAddress class >> extractFromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new SocketAddress from a ByteArray containing a
	 C sockaddr structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to."

	<category: 'abstract'>
	| addressFamily |
	"BSD systems place a length byte at offset 1, so look-up offset 2
	 first.  If it is 0, we're on a little-endian system without
	 the sa_len field, so use offset 1 as a second possibility."
	addressFamily := aByteArray at: 2.
	addressFamily = 0 ifTrue: [ addressFamily := aByteArray at: 1 ].

	self allSubclassesDo: [ :each |
	    each addressFamily = addressFamily ifTrue: [
		^each fromSockAddr: aByteArray port: portAdaptor ] ].

	^nil
    ]

    SocketAddress class >> fromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new IPAddress from a ByteArray containing a
	 C sockaddr structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to.  Raise an error
	 if the address family is unknown."

	<category: 'abstract'>
	^(self extractFromSockAddr: aByteArray port: portAdaptor)
	    ifNil: [ self error: 'unknown address family' ]
    ]

    = aSocketAddress [
	"Answer whether the receiver and aSocketAddress represent
	 the same machine.  The host name is not checked because
	 an IPAddress created before a DNS is activated is named
	 after its numbers-and-dots notation, while the same IPAddress,
	 created when a DNS is active, is named after its resolved name."

	<category: 'accessing'>
	^self class == aSocketAddress class 
	    and: [self asByteArray = aSocketAddress asByteArray]
    ]

    isMulticast [
	"Answer whether an address is reserved for multicast connections."

	<category: 'testing'>
	^false
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'accessing'>
	^self asByteArray hash
    ]

    name [
	"Answer the host name (or the digit notation if the DNS could not
	 resolve the address).  If the DNS answers a different IP address
	 for the same name, the second response is not cached and the digit
	 notation is also returned (somebody's likely playing strange jokes
	 with your DNS)."

	<category: 'accessing'>
	| addresses bytes |
	name isNil ifFalse: [^name].
	bytes := self asByteArray.
	name := self class 
		    primName: bytes
		    len: bytes size
		    type: self class addressFamily.

	"No DNS active..."
	name isNil ifTrue: [^name := self printString].
	addresses := self class at: name cache: [Array with: self].
	addresses do: 
		[:each | 
		each getName isNil ifTrue: [each name: name].
		(each = self and: [each getName ~= name]) 
		    ifTrue: 
			["Seems like someone's joking with the DNS server
			 and changed this host's IP address even though the
			 name stays the same. Don't cache the name and don't
			 even give away an alphanumeric name"

			^name := self printString]].
	^name
    ]

    asByteArray [
	"Convert the receiver to a ByteArray passed to the operating system's
	 socket functions)"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    getName [
	"Private - Answer the name (which could be nil if the name has not
	 been cached yet)."

	<category: 'private'>
	^name
    ]

    name: newName [
	"Private - Cache the name of the host which the receiver represents."

	<category: 'private'>
	name := newName
    ]
]



CStruct subclass: CAddrInfoStruct [
    <declaration: #(
		#(#aiFlags #int)
		#(#aiFamily #int)
		#(#aiSocktype #int)
		#(#aiProtocol #int)
		#(#aiAddrlen #int)
		#(#aiCanonname #string)
		#(#aiAddr #(#ptr #{CObject}))
		#(#aiNext #(#ptr #{CAddrInfoStruct}))) >

    getaddrinfo: name [
	<category: 'C function wrappers'>
	^self getaddrinfo: name service: nil
    ]

    getaddrinfo: name service: service [
	<category: 'C function wrappers'>
	| res |
	res := self class address: 0.
	(CAddrInfoStruct getaddrinfo: name service: service
	    hints: self result: res) = -1 ifTrue: [ ^nil ].
	res address = 0 ifTrue: [ ^nil ].
	^res
    ]
]

