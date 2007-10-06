IPAddress class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafInet' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfInet' returning: #long args: #()>
	
    ]

]



AbstractSocketImpl class extend [

    solSocket [
	<category: 'C constants'>
	<cCall: 'TCPsolSocket' returning: #long args: #()>
	
    ]

    soLinger [
	<category: 'C constants'>
	<cCall: 'TCPsoLinger' returning: #long args: #()>
	
    ]

    soError [
	<category: 'C constants'>
	<cCall: 'TCPsoError' returning: #long args: #()>
	
    ]

    soReuseAddr [
	<category: 'C constants'>
	<cCall: 'TCPsoReuseAddr' returning: #long args: #()>
	
    ]

    sockDgram [
	<category: 'C constants'>
	<cCall: 'TCPsockDgram' returning: #long args: #()>
	
    ]

    sockStream [
	<category: 'C constants'>
	<cCall: 'TCPsockStream' returning: #long args: #()>
	
    ]

    sockRDM [
	<category: 'C constants'>
	<cCall: 'TCPsockRDM' returning: #long args: #()>
	
    ]

    sockRaw [
	<category: 'C constants'>
	<cCall: 'TCPsockRaw' returning: #long args: #()>
	
    ]

]



UDPSocketImpl class extend [

    ipprotoIp [
	<category: 'C constants'>
	<cCall: 'TCPipprotoIp' returning: #long args: #()>
	
    ]

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoUdp' returning: #long args: #()>
	
    ]

]



TCPSocketImpl class extend [

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoTcp' returning: #long args: #()>
	
    ]

]



ICMPSocketImpl class extend [

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoIcmp' returning: #long args: #()>
	
    ]

]



OOBSocketImpl extend [

    msgOOB [
	<category: 'C constants'>
	<cCall: 'TCPmsgOOB' returning: #long args: #()>
	
    ]

]



DatagramSocketImpl extend [

    msgPeek [
	<category: 'C constants'>
	<cCall: 'TCPmsgPeek' returning: #long args: #()>
	
    ]

    ipMulticastTtl [
	<category: 'C constants'>
	<cCall: 'TCPipMulticastTtl' returning: #long args: #()>
	
    ]

    ipMulticastIf [
	<category: 'C constants'>
	<cCall: 'TCPipMulticastIf' returning: #long args: #()>
	
    ]

    ipAddMembership [
	<category: 'C constants'>
	<cCall: 'TCPipAddMembership' returning: #long args: #()>
	
    ]

    ipDropMembership [
	<category: 'C constants'>
	<cCall: 'TCPipDropMembership' returning: #long args: #()>
	
    ]

]



SocketAddress class extend [

    lookupAllHostAddr: name withHostEnt: cObject [
	<category: 'C call-outs'>
	<cCall: 'TCPlookupAllHostAddr' returning: #int
	args: #(#string #smalltalk)>
	
    ]

    primName: address len: len type: addressFamily [
	<category: 'C call-outs'>
	<cCall: 'TCPgetHostByAddr' returning: #stringOut
	args: #(#byteArray #int #int)>
	
    ]

    primLocalName [
	<category: 'C call-outs'>
	<cCall: 'TCPgetLocalName' returning: #stringOut
	args: #()>
	
    ]

]



IPAddress class extend [

    primAnyLocalAddress: hostName in: byteArray [
	<category: 'C call-outs'>
	<cCall: 'TCPgetAnyLocalAddress' returning: #void
	args: #(#string #byteArrayOut)>
	
    ]

]



AbstractSocketImpl extend [

    accept: socket peer: peer addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPaccept' returning: #int
	args: #(#int #byteArrayOut #byteArray )>
	
    ]

    bind: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPbind' returning: #int
	args: #(#int #byteArray #int )>
	
    ]

    connect: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPconnect' returning: #int
	args: #(#int #byteArray #int )>
	
    ]

    listen: socket log: len [
	<category: 'C call-outs'>
	<cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>
	
    ]

    getPeerName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetpeername' returning: #int
	args: #(#int #byteArrayOut #byteArray )>
	
    ]

    getSockName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockname' returning: #int
	args: #(#int #byteArrayOut #byteArray )>
	
    ]

    receive: socket buffer: buf size: len flags: flags from: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #byteArrayOut #int #int #byteArray #byteArrayOut )>
	
    ]

    send: socket buffer: buf size: len flags: flags to: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPsendto' returning: #int
	args: #(#int #byteArray #int #int #unknown #int )>
	
    ]

    option: socket level: level at: name put: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #byteArray #int )>
	
    ]

    option: socket level: level at: name get: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #byteArrayOut #byteArrayOut )>
	
    ]

    create: family type: type protocol: protocol [
	<category: 'C call-outs'>
	<cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>
	
    ]

]



AbstractSocketImpl class extend [

    accept: socket peer: peer addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPaccept' returning: #int
	args: #(#int #byteArrayOut #byteArray )>
	
    ]

    bind: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPbind' returning: #int
	args: #(#int #byteArray #int )>
	
    ]

    connect: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPconnect' returning: #int
	args: #(#int #byteArray #int )>
	
    ]

    listen: socket log: len [
	<category: 'C call-outs'>
	<cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>
	
    ]

    getPeerName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetpeername' returning: #int
	args: #(#int #byteArrayOut #byteArray )>
	
    ]

    getSockName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockname' returning: #int
	args: #(#int #byteArrayOut #byteArray )>
	
    ]

    receive: socket buffer: buf size: len flags: flags from: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #byteArrayOut #int #int #byteArray #byteArrayOut )>
	
    ]

    send: socket buffer: buf size: len flags: flags to: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPsendto' returning: #int
	args: #(#int #byteArray #int #int #unknown #int )>
	
    ]

    option: socket level: level at: name put: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #byteArray #int )>
	
    ]

    option: socket level: level at: name get: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #byteArrayOut #byteArrayOut )>
	
    ]

    create: family type: type protocol: protocol [
	<category: 'C call-outs'>
	<cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>
	
    ]

]

