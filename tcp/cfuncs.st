"======================================================================
|
|   C function definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2005 Free Software Foundation, Inc.
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

!IPAddress class methodsFor: 'C constants'!

addressFamily
    <cCall: 'TCPafInet' returning: #long args: #()>!

protocolFamily
    <cCall: 'TCPpfInet' returning: #long args: #()>! !

!AbstractSocketImpl class methodsFor: 'C constants'!

solSocket
    <cCall: 'TCPsolSocket' returning: #long args: #()>!

soLinger
    <cCall: 'TCPsoLinger' returning: #long args: #()>!

soError
    <cCall: 'TCPsoError' returning: #long args: #()>!

soReuseAddr
    <cCall: 'TCPsoReuseAddr' returning: #long args: #()>!

sockDgram
    <cCall: 'TCPsockDgram' returning: #long args: #()>!

sockStream
    <cCall: 'TCPsockStream' returning: #long args: #()>!

sockRDM
    <cCall: 'TCPsockRDM' returning: #long args: #()>!

sockRaw
    <cCall: 'TCPsockRaw' returning: #long args: #()>! !

!UDPSocketImpl class methodsFor: 'C constants'!

ipprotoIp
    <cCall: 'TCPipprotoIp' returning: #long args: #()>!

protocol
    <cCall: 'TCPipprotoUdp' returning: #long args: #()>! !

!TCPSocketImpl class methodsFor: 'C constants'!

protocol
    <cCall: 'TCPipprotoTcp' returning: #long args: #()>! !

!ICMPSocketImpl class methodsFor: 'C constants'!

protocol
    <cCall: 'TCPipprotoIcmp' returning: #long args: #()>! !

!OOBSocketImpl methodsFor: 'C constants'!

msgOOB
    <cCall: 'TCPmsgOOB' returning: #long args: #()>! !

!DatagramSocketImpl methodsFor: 'C constants'!

msgPeek
    <cCall: 'TCPmsgPeek' returning: #long args: #()>!

ipMulticastTtl
    <cCall: 'TCPipMulticastTtl' returning: #long args: #()>!

ipMulticastIf
    <cCall: 'TCPipMulticastIf' returning: #long args: #()>!

ipAddMembership
    <cCall: 'TCPipAddMembership' returning: #long args: #()>!

ipDropMembership
    <cCall: 'TCPipDropMembership' returning: #long args: #()>! !


!SocketAddress class methodsFor: 'C call-outs'!

lookupAllHostAddr: name withHostEnt: cObject
    <cCall: 'TCPlookupAllHostAddr' returning: #int
	args: #(#string #smalltalk)>!

primName: address len: len type: addressFamily
    <cCall: 'TCPgetHostByAddr' returning: #stringOut
	args: #(#byteArray #int #int)>!

primLocalName
    <cCall: 'TCPgetLocalName' returning: #stringOut
	args: #()>! !

!IPAddress class methodsFor: 'C call-outs'!

primAnyLocalAddress: hostName in: byteArray
    <cCall: 'TCPgetAnyLocalAddress' returning: #void
	args: #(#string #byteArrayOut)>! !

!AbstractSocketImpl methodsFor: 'C call-outs'!

accept: socket peer: peer addrLen: len
    <cCall: 'TCPaccept' returning: #int
	args: #(#int #byteArrayOut #byteArray )>!

bind: socket to: addr addrLen: len
    <cCall: 'TCPbind' returning: #int
	args: #(#int #byteArray #int )>!

connect: socket to: addr addrLen: len
    <cCall: 'TCPconnect' returning: #int
	args: #(#int #byteArray #int )>!

listen: socket log: len
    <cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>!

getPeerName: socket addr: addr addrLen: len
    <cCall: 'TCPgetpeername' returning: #int
	args: #(#int #byteArrayOut #byteArray )>!

getSockName: socket addr: addr addrLen: len
    <cCall: 'TCPgetsockname' returning: #int
	args: #(#int #byteArrayOut #byteArray )>!

receive: socket buffer: buf size: len flags: flags from: addr size: addrLen
    <cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #byteArrayOut #int #int #byteArray #byteArrayOut )>!

send: socket buffer: buf size: len flags: flags to: addr size: addrLen
    <cCall: 'TCPsendto' returning: #int
	args: #(#int #byteArray #int #int #unknown #int )>!

option: socket level: level at: name put: value size: len
    <cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #byteArray #int )>!

option: socket level: level at: name get: value size: len
    <cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #byteArrayOut #byteArrayOut )>!

create: family type: type protocol: protocol
    <cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>! !

!AbstractSocketImpl class methodsFor: 'C call-outs'!

accept: socket peer: peer addrLen: len
    <cCall: 'TCPaccept' returning: #int
	args: #(#int #byteArrayOut #byteArray )>!

bind: socket to: addr addrLen: len
    <cCall: 'TCPbind' returning: #int
	args: #(#int #byteArray #int )>!

connect: socket to: addr addrLen: len
    <cCall: 'TCPconnect' returning: #int
	args: #(#int #byteArray #int )>!

listen: socket log: len
    <cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>!

getPeerName: socket addr: addr addrLen: len
    <cCall: 'TCPgetpeername' returning: #int
	args: #(#int #byteArrayOut #byteArray )>!

getSockName: socket addr: addr addrLen: len
    <cCall: 'TCPgetsockname' returning: #int
	args: #(#int #byteArrayOut #byteArray )>!

receive: socket buffer: buf size: len flags: flags from: addr size: addrLen
    <cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #byteArrayOut #int #int #byteArray #byteArrayOut )>!

send: socket buffer: buf size: len flags: flags to: addr size: addrLen
    <cCall: 'TCPsendto' returning: #int
	args: #(#int #byteArray #int #int #unknown #int )>!

option: socket level: level at: name put: value size: len
    <cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #byteArray #int )>!

option: socket level: level at: name get: value size: len
    <cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #byteArrayOut #byteArrayOut )>!

create: family type: type protocol: protocol
    <cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>! !

