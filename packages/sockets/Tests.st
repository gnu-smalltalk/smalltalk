Stream subclass: DummyStream [
    <category: 'Sockets-Tests'>

    | n |
    DummyStream class >> new [ ^super new initialize ]
    initialize [ n := 0 ]
    nextPut: anObject [ n := n + 1 ]
    next: anInteger putAll: aCollection startingAt: pos [ n := n + anInteger ]
    size [ ^n ]
]

Socket class extend [

    microTest [
	"Extremely small test (try to receive SMTP header)"

	<category: 'tests'>
	| s |
	s := Socket remote: IPAddress anyLocalAddress port: 25.
	(s upTo: Character cr) printNl.
	s close
    ]

    testPort2For: anAddressClass [
	<category: 'tests'>
	anAddressClass == UnixAddress ifTrue: [ ^'/tmp/gst.test2' ].
	^54322
    ]
	
    testPortFor: anAddressClass [
	<category: 'tests'>
	anAddressClass == UnixAddress ifTrue: [ ^'/tmp/gst.test' ].
	^54321
    ]
	
    tweakedLoopbackTest [
	"Send data from one socket to another on the local machine, trying to avoid
	 buffering overhead.  Tests most of the socket primitives.  Comparison of
	 the results of loopbackTest and tweakedLoopbackTest should give a measure
	 of the overhead of buffering when sending/receiving large quantities of
	 data."

	<category: 'tests'>
	^self loopbackTest: #(5000 4000)
    ]

    loopbackTest [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives."

	<category: 'tests'>
	^self loopbackTest: nil
    ]

    loopbackTest: bufferSizes [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives.  The parameter is the size of the input and
	 output buffer sizes."

	<category: 'tests'>
	^self loopbackTest: bufferSizes addressClass: Socket defaultAddressClass
    ]

    loopbackTestOn: addressClass [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives.  The parameter is the address class (family)
	 to use."

	<category: 'tests'>
	^self loopbackTest: nil addressClass: addressClass
    ]

    loopbackTest: bufferSizes addressClass: addressClass [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives.  The parameters are the size of the input and
	 output buffer sizes, and the address class (family) to use."

	<category: 'tests'>
	| queue server client bytesToSend sendBuf bytesSent bytesReceived
	  t extraBytes timeout process recvBuf |
	Transcript
	    cr;
	    show: 'starting loopback test';
	    cr.
	queue := ServerSocket 
		    port: (self testPortFor: addressClass)
		    queueSize: 5
		    bindTo: addressClass loopbackHost.
	client := Socket remote: queue localAddress port: (self testPortFor: addressClass).
	bufferSizes isNil 
	    ifFalse: 
		[client
		    readBufferSize: (bufferSizes at: 1);
		    writeBufferSize: (bufferSizes at: 2)].
	timeout := false.
	process := 
		[(Delay forMilliseconds: Socket timeout) wait.
		timeout := true] fork.
	
	[timeout ifTrue: [self error: 'could not establish connection'].
	(server := queue accept: StreamSocket) isNil] 
		whileTrue: [Processor yield].
	process terminate.
	Transcript
	    show: 'connection established';
	    cr.
	bytesToSend := 5000000.
	sendBuf := String new: 4000 withAll: $x.
	recvBuf := DummyStream new.
	bytesSent := bytesReceived := 0.
	t := Time millisecondsToRun: 
			[
			[server nextPutAll: sendBuf.
			bytesSent := bytesSent + sendBuf size.
			[client canRead] whileTrue: 
				[client nextAvailablePutAllOn: recvBuf.
				bytesReceived := recvBuf size].
			bytesSent >= bytesToSend and: [bytesReceived = bytesSent]] 
				whileFalse].
	Transcript
	    show: 'closing connection';
	    cr.
	extraBytes := client bufferContents size.
	server close.
	extraBytes > 0 
	    ifTrue: 
		[Transcript
		    show: ' *** received ' , extraBytes size printString , ' extra bytes ***';
		    cr].
	client close.
	queue close.
	Transcript
	    show: 'loopback test done; ' , (t / 1000.0) printString , ' seconds';
	    cr;
	    show: (bytesToSend asFloat / t roundTo: 0.01) printString;
	    showCr: ' kBytes/sec'
    ]

    producerConsumerTest [
	"Send data from one datagram socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	^self producerConsumerTestOn: Socket defaultAddressClass
    ]

    producerConsumerTestOn: addressClass [
	"Send data from one socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	| bytesToSend bytesSent bytesReceived t server client queue sema producer consumer queueReady |
	Transcript
	    cr;
	    show: 'starting loopback test';
	    cr.
	sema := Semaphore new.
	queueReady := Semaphore new.
	bytesToSend := 5000000.
	bytesSent := bytesReceived := 0.
	t := Time millisecondsToRun: 
			[producer := 
				[| timeout process sendBuf |
				queue := ServerSocket 
					    port: (self testPortFor: addressClass)
					    queueSize: 5
					    bindTo: addressClass loopbackHost.
				queueReady signal.
				timeout := false.
				process := 
					[(Delay forMilliseconds: Socket timeout) wait.
					timeout := true] fork.
				
				[timeout ifTrue: [self error: 'could not establish connection'].
				(server := queue accept ": StreamSocket") isNil] 
					whileTrue: [Processor yield].
				process terminate.
				Transcript
				    show: 'connection established';
				    cr.
				sendBuf := String new: 4000 withAll: $x.
				
				[server nextPutAll: sendBuf.
				bytesSent := bytesSent + sendBuf size.
				bytesSent >= bytesToSend] 
					whileFalse: [Processor yield].
				sema signal] 
					fork.
			consumer := 
				[| recvBuf |
				recvBuf := DummyStream new.
				queueReady wait.
				client := Socket remote: queue localAddress port: (self testPortFor: addressClass).
				
				[[client canRead] whileTrue: 
					[client nextAvailablePutAllOn: recvBuf.
					bytesReceived := recvBuf size].
				bytesSent >= bytesToSend and: [bytesReceived = bytesSent]] 
					whileFalse: [Processor yield].
				sema signal] 
					fork.
			sema wait.
			sema wait].
	Transcript
	    show: 'closing connection';
	    cr.
	server close.
	client close.
	queue close.
	Transcript
	    show: 'loopback test done; ' , (t / 1000.0) printString , ' seconds';
	    cr;
	    show: (bytesToSend asFloat / t roundTo: 0.01) printString;
	    showCr: ' kBytes/sec'
    ]

    datagramLoopbackTest [
	"Send data from one datagram socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	^self datagramLoopbackTestOn: Socket defaultAddressClass
    ]

    datagramLoopbackTestOn: addressClass [
	"Send data from one datagram socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	| bytesToSend bytesSent bytesReceived t |
	Transcript
	    cr;
	    show: 'starting datagram loopback test';
	    cr.
	bytesToSend := 5000000.
	bytesSent := bytesReceived := 0.
	t := Time millisecondsToRun: 
			[| server client datagram |
			client := DatagramSocket
				    local: addressClass loopbackHost
				    port: (self testPort2For: addressClass).
			server := DatagramSocket 
				    remote: addressClass loopbackHost
				    port: (self testPort2For: addressClass)
				    local: nil
				    port: (self testPortFor: addressClass).
			datagram := Datagram data: (String new: 128 withAll: $x) asByteArray.
			
			[server
			    nextPut: datagram;
			    flush.
			bytesSent := bytesSent + datagram data size.
			[client canRead] 
			    whileTrue: [bytesReceived := bytesReceived + client next data size].
			bytesReceived < bytesToSend] 
				whileTrue.
			Transcript
			    show: 'closing connection';
			    cr.
			server close.
			client close].
	Transcript
	    show: 'udp loopback test done; ' , (t / 1000.0) printString , ' seconds';
	    cr;
	    show: '% packets lost ' 
			, (100 - (bytesReceived / bytesSent * 100)) asFloat printString;
	    cr;
	    show: (bytesToSend asFloat / t roundTo: 0.01) printString;
	    showCr: ' kBytes/sec'
    ]

    sendTest [
	"Send data to the 'discard' socket of localhost."

	<category: 'tests'>
	^self sendTest: '127.0.0.1'
    ]

    sendTest: host [
	"Send data to the 'discard' socket of the given host. Tests the speed of
	 one-way data transfers across the network to the given host. Note that
	 many hosts do not run a discard server."

	"Socket sendTest: 'localhost'"

	<category: 'tests'>
	| sock bytesToSend sendBuf bytesSent t |
	Transcript
	    cr;
	    show: 'starting send test';
	    cr.
	sock := Socket remote: host port: Socket portDiscard.
	Transcript
	    show: 'connection established';
	    cr.
	bytesToSend := 5000000.
	sendBuf := String new: 4000 withAll: $x.
	bytesSent := 0.
	t := Time millisecondsToRun: 
			[[bytesSent < bytesToSend] whileTrue: 
				[sock
				    nextPutAll: sendBuf;
				    flush.
				bytesSent := bytesSent + sendBuf size]].
	Transcript
	    show: 'closing connection';
	    cr.
	sock close.
	Transcript
	    show: 'send test done; time = ' , (t / 1000.0) printString, ' seconds';
	    cr;
	    show: (bytesToSend asFloat / t) printString;
	    showCr: ' kBytes/sec'
    ]

]

