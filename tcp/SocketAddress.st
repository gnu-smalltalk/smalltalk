"======================================================================
|
|   Smalltalk TCP/IP sockets - IPAddress class
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


Object subclass: #SocketAddress
       instanceVariableNames: 'name'
       classVariableNames: 'Cache'
       poolDictionaries: ''
       category: 'Sockets-Protocols'
! 

SocketAddress class instanceVariableNames:
    'anyLocalAddress localHostName loopbackHost unknownAddress
     defaultStreamSocketImplClass defaultDatagramSocketImplClass
     defaultRawSocketImplClass  '
!

!SocketAddress class methodsFor: 'accessing'!

defaultStreamSocketImplClass
    "Answer the class that, by default, is used to map between the
     Socket's protocol and a low-level C interface."
    ^defaultStreamSocketImplClass
!

defaultStreamSocketImplClass: aClass
    "Set which class will be used by default to map between the
     receiver's protocol and a low-level C interface."
    defaultStreamSocketImplClass := aClass
!

defaultRawSocketImplClass
    "Answer the class that, by default, is used to map between the
     Socket's protocol and a low-level C interface."
    ^defaultRawSocketImplClass
!

defaultRawSocketImplClass: aClass
    "Set which class will be used by default to map between the
     receiver's protocol and a low-level C interface."
    defaultRawSocketImplClass := aClass
!

defaultDatagramSocketImplClass
    "Answer the class that, by default, is used to map between the
     Socket's protocol and a low-level C interface."
    ^defaultDatagramSocketImplClass
!

defaultDatagramSocketImplClass: aClass
    "Set which class will be used by default to map between the
     receiver's protocol and a low-level C interface."
    defaultDatagramSocketImplClass := aClass
! !

!SocketAddress class methodsFor: 'initialization'!

newRawSocket
    "Create a new raw socket, providing access to low-level network protocols
     and interfaces for the protocol family represented by the receiver
     (for example, the C protocol family PF_INET for the IPAddress class)
     Ordinary user programs usually have no need to use this method."
    ^self new: defaultRawSocketImplClass new
! !

!SocketAddress class methodsFor: 'initialization'!

flush
    "Flush the cached IP addresses."
    localHostName := self primLocalName.
    anyLocalAddress := self createLocalAddress.
    unknownAddress := self createUnknownAddress.
    loopbackHost := self createLoopbackHost.
    loopbackHost isNil ifFalse: [ loopbackHost name: localHostName ].

    Cache := Dictionary new.
!

createLocalAddress
    "Answer an object representing a local address in the address
     family for the receiver"
    ^nil
!

createUnknownAddress
    "Answer an object representing an unkown address in the address
     family for the receiver"
    ^nil
!

createLoopbackHost
    "Answer an object representing the loopback host in the address
     family for the receiver.  By default this is the same as
     #createLocalAddress, since the loopback host is actually a
     local address that some implementations optimize specially."
    ^nil
!

update: aspect
    "Flush all the caches for IPAddress subclasses"
    aspect == #returnFromSnapshot ifTrue: [
	self withAllSubclassesDo: [ :each | each flush ]
    ]
! !

!SocketAddress class methodsFor: 'accessing'!

addressFamily
    "Answer the address family used for sockets whose endpoint is
     an instance of the receiver."
    ^nil
!

anyLocalAddress
    "Answer an IPAddress representing a local address."
    ^anyLocalAddress
!

at: host cache: aBlock
    "Private - Answer the list of addresses associated to the
     given host in the cache.  If the host is not cached yet,
     evaluate aBlock and cache and answer the result."
    ^Cache at: host ifAbsentPut: aBlock
!

isDigitAddress: aString
    "Answer whether the receiver can interpret aStrnig as a valid
     address without going through a resolver."
    ^false
!

localHostName
    "Answer the name of the local machine."
    ^localHostName
!

loopbackHost
    "Answer an instance of the receiver representing the local machine
     (127.0.0.1 in the IPv4 family)."
    ^loopbackHost		"127.0.0.1"
!

unknownAddress
    "Answer an instance of the receiver representing an unknown machine
     (0.0.0.0 in the IPv4 family)."
    "Answer an IPAddress representing an unknown machine (0.0.0.0)."
    ^unknownAddress		"0.0.0.0"
! !

!SocketAddress class methodsFor: 'host name lookup'!

allByName: aString
    "Answer all the IP addresses that refer to the the given host.  If
     a digit address is passed in aString, the result is an array
     containing the single passed address.  If the host could not be
     resolved to an IP address, answer nil."
    | host |
    host := aString asLowercase.
    self withAllSubclassesDo: [ :c |
        (c isDigitAddress: host) ifTrue: [
	    ^self at: host cache: [ Array with: (c fromString: host) ]
        ]
    ].

    ^self at: host cache: [
	| type addresses result class |
	result := CByte new.
	type := self lookupAllHostAddr: host withHostEnt: result.

	type >= 0 ifTrue: [
	    [
	        class := self withAllSubclasses
	            detect: [ :c | c addressFamily = type ]
	            ifNone: [ self error: 'unsupported address family' ].

		addresses := class extractAddressesAfterLookup: result
	    ]
	        ensure: [ result free ].
	].
	addresses
    ]
!

byName: aString
    "Answer a single IP address that refer to the the given host.  If
     a digit address is passed in aString, the result is the same as
     using #fromString:.  If the host could not be resolved to an IP
     address, answer nil."
    | all |
    aString isEmpty ifTrue: [ ^loopbackHost ].
    all := self allByName: aString.
    ^all isNil ifTrue: [ nil ] ifFalse: [ all anyOne ]
! !

!SocketAddress class methodsFor: 'private'!

extractAddressesAfterLookup: result
    "Private - Given a CByte object, extract the arrays returned by 
     gethostbyname and answer them."
    self subclassResponsibility
! !

!SocketAddress class methodsFor: 'abstract'!

fromSockAddr: aByteArray port: portAdaptor
    "Private - Answer a new IPAddress from a ByteArray containing a
     C sockaddr structure.  The portAdaptor's value is changed
     to contain the port that the structure refers to."

    self subclassResponsibility
! !

!SocketAddress methodsFor: 'accessing'!

= anIPAddress
    "Answer whether the receiver and anIPAddress represent
     the same machine.  The host name is not checked because
     an IPAddress created before a DNS is activated is named
     after its numbers-and-dots notation, while the same IPAddress,
     created when a DNS is active, is named after its resolved name."
    ^(self class == anIPAddress class) and: [
	self asByteArray = anIPAddress asByteArray
    ]
!

hash
    "Answer an hash value for the receiver"
    ^self asByteArray hash
!

name
    "Answer the host name (or the digit notation if the DNS could not
    resolve the address).  If the DNS answers a different IP address
    for the same name, the second response is not cached and the digit
    notation is also returned (somebody's likely playing strange jokes
    with your DNS)."

    | addresses bytes |
    name isNil ifFalse: [ ^name ].
    bytes := self asByteArray.
    name := self class
	primName: bytes
	len: bytes size
	type: self class addressFamily.

    "No DNS active..."
    name isNil ifTrue: [ ^name := self printString ].

    addresses := self class at: name cache: [ Array with: self ].

    addresses do: [ :each |
	each getName isNil ifTrue: [ each name: name ].
	(each = self and: [ each getName ~= name ]) ifTrue: [
	    "Seems like someone's joking with the DNS server
	     and changed this host's IP address even though the
	     name stays the same. Don't cache the name and don't
	     even give away an alphanumeric name"
	    ^name := self printString
	].
    ].
    ^name
!

asByteArray
    "Convert the receiver to a ByteArray passed to the operating system's
     socket functions)"
    self subclassResponsibility
! !

!SocketAddress methodsFor: 'private'!

getName
    "Private - Answer the name (which could be nil if the name has not
     been cached yet)."
    ^name
!

name: newName
    "Private - Cache the name of the host which the receiver represents." 
    name := newName
! !

