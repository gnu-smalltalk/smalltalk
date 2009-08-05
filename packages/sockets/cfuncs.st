SocketAddress class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafUnspec' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfUnspec' returning: #long args: #()>
	
    ]

    aiAddrconfig [
	<category: 'C constants'>
	<cCall: 'TCPaiAddrconfig' returning: #long args: #()>
	
    ]

    aiCanonname [
	<category: 'C constants'>
	<cCall: 'TCPaiCanonname' returning: #long args: #()>
	
    ]

]

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

IP6Address class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafInet6' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfInet6' returning: #long args: #()>
	
    ]

    aiAll [
	<category: 'C constants'>
	<cCall: 'TCPaiAll' returning: #long args: #()>
	
    ]

    aiV4mapped [
	<category: 'C constants'>
	<cCall: 'TCPaiV4mapped' returning: #long args: #()>
	
    ]

]

UnixAddress class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafUnix' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfUnix' returning: #long args: #()>
	
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

    ipprotoTcp [
	<category: 'C constants'>
	<cCall: 'TCPipprotoTcp' returning: #long args: #()>
	
    ]

    tcpNodelay [
	<category: 'C constants'>
	<cCall: 'TCPtcpNodelay' returning: #long args: #()>
	
    ]

]



ICMP6SocketImpl class extend [

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoIcmpv6' returning: #long args: #()>
	
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



CAddrInfoStruct extend [
    free [
	<category: 'C call-outs'>
	<cCall: 'TCPfreeaddrinfo' returning: #void
	args: #(#self)>
	
    ]

    CAddrInfoStruct class >> getaddrinfo: name service: servname hints: hints result: res [
	<category: 'C call-outs'>
	<cCall: 'TCPgetaddrinfo' returning: #int
	args: #(#string #string #cObject #cObjectPtr)>
	
    ]

    aiAddr [
	<category: 'C call-outs'>
	<cCall: 'TCPgetAiAddr' returning: #(#ptr #{CObject})
	args: #(#self)>
	
    ]

    aiCanonname [
	<category: 'C call-outs'>
	<cCall: 'TCPgetAiCanonname' returning: #{CString}
	args: #(#self)>
	
    ]
]

SocketAddress class extend [

    primName: address len: len type: addressFamily [
	<category: 'C call-outs'>
	<cCall: 'TCPgetHostByAddr' returning: #stringOut
	args: #(#cObject #int #int)>
	
    ]

    primLocalName [
	<category: 'C call-outs'>
	<cCall: 'TCPgetLocalName' returning: #stringOut
	args: #()>
	
    ]

]



AbstractSocketImpl extend [

    accept: socket peer: peer addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPaccept' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    bind: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPbind' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    connect: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPconnect' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    listen: socket log: len [
	<category: 'C call-outs'>
	<cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>
	
    ]

    getPeerName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetpeername' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    getSockName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockname' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    receive: socket buffer: buf size: len flags: flags from: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #cObject #int #int #cObject #cObject )>
	
    ]

    send: socket buffer: buf size: len flags: flags to: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPsendto' returning: #int
	args: #(#int #cObject #int #int #cObject #int )>
	
    ]

    soError: socket [
	<category: 'C constants'>
	<cCall: 'TCPgetSoError' returning: #int args: #(#int)>
	
    ]

    option: socket level: level at: name put: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #cObject #int )>
	
    ]

    option: socket level: level at: name get: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #cObject #cObject )>
	
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
	args: #(#int #cObject #cObject )>
	
    ]

    bind: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPbind' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    connect: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPconnect' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    listen: socket log: len [
	<category: 'C call-outs'>
	<cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>
	
    ]

    getPeerName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetpeername' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    getSockName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockname' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    receive: socket buffer: buf size: len flags: flags from: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #cObject #int #int #cObject #cObject )>
	
    ]

    send: socket buffer: buf size: len flags: flags to: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPsendto' returning: #int
	args: #(#int #cObject #int #int #cObject #int )>
	
    ]

    option: socket level: level at: name put: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #cObject #int )>
	
    ]

    option: socket level: level at: name get: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #cObject #cObject )>
	
    ]

    create: family type: type protocol: protocol [
	<category: 'C call-outs'>
	<cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>
	
    ]

]

