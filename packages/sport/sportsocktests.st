"======================================================================
|
|   Sport-A 2.030 tests (sockets)
|
|
 ======================================================================"


TestCase subclass: SpSocketBasics [
    testCreatingAndClosingAServerSocket [
	| serverSocket |
	serverSocket := SpSocket newTCPSocket.
	serverSocket
		setAddressReuse: true;
		bindSocketAddress: (SpIPAddress hostName: 'localhost' port: 10001);
		listenBackloggingUpTo: 50.
	serverSocket close
    ]

    testSimpleEchoingServer [
	| serverSocket testBytes clientSocket bytesFromServer |
	testBytes := ByteArray withAll: (Interval from: 0 to: 255).
	
	[serverSocket := SpSocket newTCPSocket.
	serverSocket
		setAddressReuse: true;
		bindSocketAddress: (SpIPAddress hostName: 'localhost' port: 10001);
		listenBackloggingUpTo: 50.
	
	[| conversationSocket bytesFromClient |
	conversationSocket := serverSocket accept.
	bytesFromClient := conversationSocket read: 1024.
	self assert: bytesFromClient = testBytes.
	conversationSocket write: bytesFromClient.
	conversationSocket close] 
			fork.
	clientSocket := SpSocket connectToServerOnHost: 'localhost' port: 10001.
	clientSocket write: testBytes.
	Processor yield.
	bytesFromServer := clientSocket read: 1024.
	self assert: bytesFromServer = testBytes] 
			ensure: 
				[serverSocket close.
				clientSocket close].
	^self
    ]
]

TestCase subclass: SpSocketBasicTests [
    | serverPort serverSocket serverAcceptLoop acceptedSocket |

    serverIPAddress [
	^SpIPAddress hostName: 'localhost' port: self serverPort
    ]

    serverPort [
	serverPort isNil ifTrue: [serverPort := 20000].
	^serverPort
    ]

    serverPort: anInteger  [
	serverPort := anInteger.
	^self
    ]

    startServer [
	serverSocket := SpSocket newTCPSocket.
	serverSocket bindSocketAddress: self serverIPAddress.
	serverSocket listenBackloggingUpTo: 5.
	serverAcceptLoop := 
			[acceptedSocket := serverSocket accept.
			acceptedSocket write: (acceptedSocket read: 1024) ] 
					forkAt: Processor userBackgroundPriority.
	^self
    ]

    stopServer [
	serverAcceptLoop terminate.
	acceptedSocket notNil ifTrue: [acceptedSocket close].
	serverSocket close.
	^self
    ]

    test03CreateSocket [
	"Using the simple service to create a TCP socket.  Same effect at test 01 and test 02"

	| socket |
	[socket := SpSocket   newTCPSocket] 
			ensure: [socket close].
	^self
    ]

    test11BindSocket [
	"Using the simple service to create a TCP socket.  Same effect at test 01 and test 02"

	| aServerSocket |
	[| ipAddress |
	aServerSocket := SpSocket newTCPSocket.
	ipAddress := SpIPAddress hostName: 'localhost' port: 20011.
	aServerSocket bindSocketAddress: ipAddress] 
			ensure: [aServerSocket close]
    ]

    test12BindSocket [
	"As 11, but set the address reuse option  on before binding."

	| aServerSocket |
	
	[| ipAddress |
	aServerSocket := SpSocket newTCPSocket.
	aServerSocket setAddressReuse: true.
	ipAddress := SpIPAddress hostName: 'localhost' port: 20012.
	aServerSocket bindSocketAddress: ipAddress] 
			ensure: [aServerSocket close]
    ]

    test21Listen [
	"Create a socket, set it to listen and close it again.
	To check this out on Linux:
		Put a breakpoint in the ensure block
		Run the method using SUnit debug
		From a linux shell prompt:'netstat -na | grep 20021'
		note the socket is listening
		Resume the Smalltalk process & let the socket close
		Run netstat again - socket not listed any more."

	| aServerSocket |
	[| ipAddress |
	aServerSocket := SpSocket newTCPSocket.
	ipAddress := SpIPAddress hostName: 'localhost' port: 20021.
	aServerSocket bindSocketAddress: ipAddress.
	aServerSocket listenBackloggingUpTo: 5.] 
			ensure: [aServerSocket close]
    ]

    test31Accept [
	"accept connection from a bound listening socket.  Close without having 
	handled any requests."

	|aServerSocket |
	[| ipAddress acceptLoopProcess |
	aServerSocket := SpSocket newTCPSocket.
	ipAddress := SpIPAddress hostName: 'localhost' port: 20031.
	aServerSocket bindSocketAddress: ipAddress.
	aServerSocket listenBackloggingUpTo: 5.
	acceptLoopProcess := [aServerSocket accept] forkAt: Processor userBackgroundPriority.
	(Delay forMilliseconds: 200) wait.
	acceptLoopProcess terminate] 
			ensure: [aServerSocket close]
    ]

    test32Accept [
	"As 31, but using the startServer stopServer services of this test class."

	self serverPort: 20032.
	self startServer.
	(Delay forMilliseconds: 200) wait.
	self stopServer.
	^self
    ]

    test41Connect [
	"accept connections from a bound listening socket.  connect another
	socket to that port and close everything.
	If you hit a socket in use problem, use netstat -an to see what is going on, and
	wait for any TIME_WAITs to expire."

	| clientSocket |
	self serverPort: self serverPort + 41.
	self startServer.
	[clientSocket := SpSocket newTCPSocket.
	clientSocket connectTo: self serverIPAddress] 
			ensure: 
				[(Delay forMilliseconds: 200) wait.
				clientSocket close].
	self stopServer
    ]

    test51IO [
	"Establish a client connection to a server socket, write something over the socket (the
	server will reflect it back), and read from the socket."

	| clientSocket |
	self serverPort: self serverPort + 51.
	self startServer.
	[| subjectBytes readBytes |
	clientSocket := SpSocket newTCPSocket.
	clientSocket connectTo: self serverIPAddress.
	subjectBytes := 'Hello, World' asByteArray.
	clientSocket write: subjectBytes.
	readBytes := clientSocket read: 1024.
	self assert: readBytes = subjectBytes ] 
			ensure: 
				[(Delay forMilliseconds: 200) wait.
				clientSocket close].
	self stopServer
    ]
]
