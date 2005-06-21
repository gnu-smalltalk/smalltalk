"======================================================================
|
|   C function definitions
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

SocketAddress class
	defineCFunc: 'TCPlookupAllHostAddr'
	withSelectorArgs: 'lookupAllHostAddr: name withHostEnt: cObject'
	returning: #int
	args: #(#string #smalltalk).

SocketAddress class
	defineCFunc: 'TCPgetHostByAddr'
	withSelectorArgs: 'primName: address len: len type: addressFamily'
	returning: #stringOut
	args: #(#byteArray #int #int).
!

SocketAddress class
	defineCFunc: 'TCPgetLocalName'
	withSelectorArgs: 'primLocalName'
	returning: #stringOut
	args: #().
!

IPAddress class
	defineCFunc: 'TCPgetAnyLocalAddress'
	withSelectorArgs: 'primAnyLocalAddress: hostName in: byteArray'
	returning: #void
	args: #(#string #byteArrayOut).
!

{{'TCPafInet'.		  'addressFamily'.	IPAddress class}.
 {'TCPpfInet'.		  'protocolFamily'.	IPAddress class}.
 {'TCPsolSocket'.	  'solSocket'.    	AbstractSocketImpl class}.
 {'TCPsoLinger'.	  'soLinger'.		AbstractSocketImpl class}.
 {'TCPsoError'.		  'soError'.		AbstractSocketImpl class}.
 {'TCPsoReuseAddr'.	  'soReuseAddr'.	AbstractSocketImpl class}.
 {'TCPsockDgram'.	  'sockDgram'.		AbstractSocketImpl class}.
 {'TCPsockStream'.	  'sockStream'.		AbstractSocketImpl class}.
 {'TCPsockRDM'.		  'sockRDM'.		AbstractSocketImpl class}.
 {'TCPsockRaw'.		  'sockRaw'.		AbstractSocketImpl class}.
 {'TCPipprotoIp'.   	  'ipprotoIp'.   	UDPSocketImpl class}.
 {'TCPipprotoUdp'.   	  'protocol'.   	UDPSocketImpl class}.
 {'TCPipprotoTcp'.   	  'protocol'.   	TCPSocketImpl class}.
 {'TCPipprotoIcmp'.   	  'protocol'.   	ICMPSocketImpl class}.

 {'TCPmsgOOB'.		  'msgOOB'.		OOBSocketImpl}.
 {'TCPmsgPeek'.		  'msgPeek'.		DatagramSocketImpl}.
 {'TCPipMulticastTtl'.	  'ipMulticastTtl'.	DatagramSocketImpl}.
 {'TCPipMulticastIf'.	  'ipMulticastIf'.	DatagramSocketImpl}.
 {'TCPipAddMembership'.  'ipAddMembership'.	DatagramSocketImpl}.
 {'TCPipDropMembership'. 'ipDropMembership'.	DatagramSocketImpl}}

do: [ :each |
    (each at: 3)
    	defineCFunc: (each at: 1)
	withSelectorArgs: (each at: 2)
	returning: #long
	args: #().
]!


#(('TCPaccept'  'accept: socket  peer: peer addrLen: len' #int #(#int #byteArrayOut #byteArray))
  ('TCPbind'    'bind: socket    to: addr   addrLen: len' #int #(#int #byteArray    #int))
  ('TCPconnect' 'connect: socket to: addr   addrLen: len' #int #(#int #byteArray    #int))
  ('TCPlisten'  'listen: socket  log: len'		  #int #(#int #int))

  ('TCPgetpeername' 'getPeerName: socket addr: addr addrLen: len' #int #(#int #byteArrayOut #byteArray))
  ('TCPgetsockname' 'getSockName: socket addr: addr addrLen: len' #int #(#int #byteArrayOut #byteArray))

  ('TCPrecvfrom' 'receive: socket buffer: buf size: len flags: flags from: addr size: addrLen' #int #(#int #byteArrayOut #int #int #byteArray #byteArrayOut))
  ('TCPsendto'   'send:    socket buffer: buf size: len flags: flags to: addr   size: addrLen' #int #(#int #byteArray    #int #int #unknown   #int))

  ('TCPsetsockopt'  'option: socket level: level at: name put: value size: len' #int #(#int #int #int #byteArray    #int))
  ('TCPgetsockopt'  'option: socket level: level at: name get: value size: len' #int #(#int #int #int #byteArrayOut #byteArrayOut))

 ('TCPsocket'      'create: family type: type protocol: protocol' #int #(#int #int #int))
)

do: [ :each |
    AbstractSocketImpl
	perform: #defineCFunc:withSelectorArgs:returning:args:
	withArguments: each.

    AbstractSocketImpl class
	perform: #defineCFunc:withSelectorArgs:returning:args:
	withArguments: each.
]!
