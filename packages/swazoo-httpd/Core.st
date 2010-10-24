"======================================================================
|
|   Swazoo 2.1 core
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SwazooResource [
    | enabled uriPattern parent |
    
    <category: 'Swazoo-Core'>
    <comment: 'Resource is an abstract class for all so called web resources. Such resource has its url address and can serve with responding to web requests. Every resource need to #answerTo: aHTTPRequest with aHTTPResponse. Site is a subclass of a Resource. You can subclass it with your own implementation. There is also a CompositeResource, which can hold many subresources. Site is also aCopmpositeResource and therefore you can add your own resources to your site.'>

    SwazooResource class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    SwazooResource class >> uriPattern: aString [
	<category: 'instance creation'>
	^self new uriPattern: aString
    ]

    answerTo: aRequest [
	"override in your Resource and return a HTTPResponse"

	<category: 'serving'>
	^nil
    ]

    authenticationRealm [
	"rfc2617 3.2.1: A string to be displayed to users so they know which username and
	 password to use. This string should contain at least the name of
	 the host performing the authentication and might additionally
	 indicate the collection of users who might have access. An example
	 might be 'registered_users@gotham.news.com'"

	<category: 'authentication'>
	^'Swazoo server'
    ]

    authenticationScheme [
	"#Basic or #Digest, see rfc2617. Digest is recomended because password
	 goes encrypted to server"

	<category: 'authentication'>
	^#Digest
    ]

    canAnswer [
	<category: 'testing'>
	^self isEnabled and: [self isValidlyConfigured]
    ]

    currentUrl [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents
    ]

    disable [
	<category: 'start/stop'>
	enabled := false
    ]

    enable [
	<category: 'start/stop'>
	enabled := true
    ]

    helpResolve: aResolution [
	<category: 'accessing'>
	^aResolution resolveLeafResource: self
    ]

    initUriPattern [
	<category: 'private-initialize'>
	self uriPattern: ''
    ]

    initialize [
	<category: 'private-initialize'>
	self enable.
	self initUriPattern
    ]

    isEnabled [
	<category: 'testing'>
	^enabled
    ]

    isValidlyConfigured [
	<category: 'testing'>
	^self uriPattern ~= ''
    ]

    match: anIdentifier [
	<category: 'private'>
	^self uriPattern = anIdentifier
    ]

    onResourceCreated [
	"Received after the resource has been added to its parent resource. Opportunity to perform initialization that depends on knowledge of the resource tree structure"

	<category: 'private-initialize'>
	
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aResource [
	<category: 'private'>
	parent := aResource
    ]

    printUrlOn: aWriteStream [
	<category: 'accessing'>
	self parent printUrlOn: aWriteStream.
	aWriteStream nextPutAll: self uriPattern
    ]

    root [
	<category: 'accessing'>
	^self parent isNil ifTrue: [self] ifFalse: [self parent root]
    ]

    start [
	<category: 'start/stop'>
	
    ]

    stop [
	<category: 'start/stop'>
	
    ]

    unauthorizedResponse [
	"Resource should call this method and return its result immediately, if request is not authorized
	 to access that resource and a HTTP authorization is needed"

	"^HTTPAuthenticationChallenge newForResource: self"

	<category: 'authentication'>
	
    ]

    unauthorizedResponsePage [
	"Resource should override this method with it's own html message"

	<category: 'authentication'>
	^'<HTML>
  <HEAD>
    <TITLE>Authentication error</TITLE>
  </HEAD>
  <BODY>
    <H1>401 Authentication error</H1>
    <P>Bad username or password</P>
  </BODY>
</HTML>'
    ]

    uriPattern [
	<category: 'accessing'>
	^uriPattern
    ]

    uriPattern: anIdentifier [
	<category: 'accessing'>
	anIdentifier notNil ifTrue: [uriPattern := anIdentifier]
    ]
]



SwazooResource subclass: CompositeResource [
    | children |
    
    <category: 'Swazoo-Core'>
    <comment: nil>

    addResource: aResource [
	<category: 'adding/removing'>
	self children add: aResource.
	aResource parent: self.
	aResource onResourceCreated.
	^aResource
    ]

    addResources: anOrderedCollection [
	<category: 'adding/removing'>
	anOrderedCollection do: [:each | self addResource: each].
	^anOrderedCollection
    ]

    children [
	<category: 'accessing'>
	children isNil ifTrue: [self initChildren].
	^children
    ]

    currentUrl [
	<category: 'accessing'>
	| string |
	string := super currentUrl.
	^string last = $/ ifTrue: [string] ifFalse: [string , '/']
    ]

    hasNoResources [
	<category: 'testing'>
	^self children isEmpty
    ]

    helpResolve: aResolution [
	<category: 'accessing'>
	^aResolution resolveCompositeResource: self
    ]

    includesResource: aResource [
	<category: 'testing'>
	^self children includes: aResource
    ]

    initChildren [
	<category: 'initialize-release'>
	children := OrderedCollection new
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self initChildren
    ]

    isRootPath [
	<category: 'testing'>
	^self uriPattern = '/'
    ]

    match: anIdentifier [
	<category: 'private'>
	^self uriPattern match: anIdentifier
    ]

    printUrlOn: aWriteStream [
	<category: 'accessing'>
	super printUrlOn: aWriteStream.
	self isRootPath ifFalse: [aWriteStream nextPut: $/]
    ]

    removeResource: aResource [
	<category: 'adding/removing'>
	self children remove: aResource ifAbsent: [nil]
    ]
]



CompositeResource subclass: SwazooSite [
    | name serving |
    
    <category: 'Swazoo-Core'>
    <comment: 'Site : Swazoo can serve many sites at once (virtual sites). Class Site is therefore a main class to start configuring your server. It holds an IP, port and hostname of your site.'>

    SwazooSite class >> named: aString [
	"return a website with that name"

	<category: 'accessing'>
	^SwazooServer singleton siteNamed: aString
    ]

    SwazooSite class >> newNamed: aString [
	<category: 'instance creation'>
	| site |
	site := self new name: aString.
	SwazooServer singleton addSite: site.
	site initialize.
	^site
    ]

    addAlias: anAlias [
	<category: 'accessing'>
	self uriPattern add: anAlias
    ]

    aliases [
	<category: 'accessing'>
	^self uriPattern
    ]

    compile: tag [
	<category: 'config-from-file'>
	^SwazooCompiler evaluate: tag
    ]

    helpResolve: aResolution [
	<category: 'private'>
	^aResolution resolveSite: self
    ]

    host [
	"hostname of this site. Example: www.ibm.com.
	 hostname must be unique on that server.
	 Don't mix with ip, which also can be something like www.ibm.com.
	 There can be many sites with different hostnames on the same ip !!"

	<category: 'accessing'>
	^self uriIdentifier host
    ]

    host: aString [
	<category: 'private'>
	self uriIdentifier host: aString
    ]

    host: aHostString ip: anIPString port: aNumber [
	"see comments in methods host and ip !!"

	"hostname must be unique!!"

	<category: 'accessing'>
	| site |
	site := SwazooServer singleton siteHostnamed: aHostString.
	(site notNil and: [site ~= self]) 
	    ifTrue: [^SwazooSiteError error: 'Site with that hostname already exist!'].
	self uriIdentifier 
	    setIp: anIPString
	    port: aNumber
	    host: aHostString
    ]

    host: aHostString port: aNumber [
	"run on all ip interfaces on specified port"

	"hostname must be unique!!"

	<category: 'accessing'>
	self 
	    host: aHostString
	    ip: '*'
	    port: aNumber
    ]

    initUriPattern [
	<category: 'initialize-release'>
	self uriPattern: OrderedCollection new.
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self stop.	"in case you initialize working site"
	self initUriPattern
    ]

    ip [
	"IP address of this site. Swazoo can have virtual sites, that is, more than one
	 site can share the same ip and port!!
	 IP can be a number or full DNS name. For example: server.ibm.com or 234.12.45.66"

	<category: 'accessing'>
	^self uriIdentifier ip
    ]

    ip: aString [
	<category: 'private'>
	self uriIdentifier ip: aString
    ]

    isRootPath [
	<category: 'testing'>
	^false
    ]

    isServing [
	"is this site on-line?"

	<category: 'testing'>
	^serving notNil and: [serving]
    ]

    match: aRequest [
	<category: 'private'>
	self uriPattern detect: [:each | each requestMatch: aRequest]
	    ifNone: [^false].
	^true
    ]

    name [
	"a short name of that site. Example: for host www.ibm.com, name it ibm"

	<category: 'accessing'>
	name isNil ifTrue: [^''].
	^name
    ]

    name: aString [
	"a short name of that site. Example: for host www.ibm.com, name it ibm"

	"name must be unique"

	<category: 'accessing'>
	(SwazooServer singleton siteNamed: aString) notNil 
	    ifTrue: [^SwazooSiteError error: 'Site with that name already exist!'].
	name := aString
    ]

    nextTagFrom: aStream [
	<category: 'config-from-file'>
	aStream upTo: $<.
	^aStream atEnd ifTrue: [nil] ifFalse: [aStream upTo: $>]
    ]

    onAllInterfaces [
	"site is running on all machine's IP interfaces"

	<category: 'testing'>
	^self ip = '*' or: [self ip = '0.0.0.0']
    ]

    onAnyHost [
	"site don't care about host name during url resolution"

	<category: 'testing'>
	^self host = '*'
    ]

    port [
	<category: 'accessing'>
	^self uriIdentifier port
    ]

    port: aNumber [
	<category: 'private'>
	self uriIdentifier port: aNumber
    ]

    printUrlOn: aWriteStream [
	<category: 'private'>
	self uriIdentifier printUrlOn: aWriteStream
    ]

    readCompositeFrom: aStream storingInto: aComposite [
	<category: 'config-from-file'>
	| tag |
	
	[tag := self nextTagFrom: aStream.
	tag = '/CompositeResource'] 
		whileFalse: 
		    [| thingy |
		    thingy := self compile: tag.
		    aComposite addResource: thingy.
		    (thingy isKindOf: CompositeResource) 
			ifTrue: [self readCompositeFrom: aStream storingInto: thingy]]
    ]

    readFrom: aStream [
	"read configuration from an XML file, see sites.cnf"

	<category: 'config-from-file'>
	| tag |
	tag := self nextTagFrom: aStream.
	tag isNil ifTrue: [^nil].
	tag = 'Site' 
	    ifFalse: [^SwazooSiteError error: 'invalid site specification!'].
	
	[tag := self nextTagFrom: aStream.
	tag = '/Site'] whileFalse: 
		    [| thingy |
		    thingy := self compile: tag.
		    (thingy isKindOf: SiteIdentifier) 
			ifTrue: [self addAlias: thingy]
			ifFalse: 
			    [self addResource: thingy.
			    (thingy isKindOf: CompositeResource) 
				ifTrue: [self readCompositeFrom: aStream storingInto: thingy]]]
    ]

    serving: aBoolean [
	<category: 'private'>
	serving := aBoolean
    ]

    sslPort: aNumber [
	<category: 'accessing'>
	self uriPattern size < 2 
	    ifTrue: [self uriPattern add: SSLSiteIdentifier new].
	(self uriPattern at: 2) 
	    setIp: self ip
	    port: aNumber
	    host: self host
    ]

    start [
	<category: 'start/stop'>
	| swazoo |
	swazoo := SwazooServer singleton.
	
	[self aliases do: 
		[:each | 
		| httpServer |
		httpServer := swazoo serverFor: each.	"it will also create and start it if needed"
		httpServer addSite: self]] 
		ifCurtailed: [self stop].
	self serving: true
    ]

    stop [
	<category: 'start/stop'>
	| swazoo |
	swazoo := SwazooServer singleton.
	self aliases do: 
		[:each | 
		| httpServer |
		httpServer := swazoo serverFor: each.
		(swazoo servers includes: httpServer) 
		    ifTrue: 
			[httpServer removeSite: self.
			httpServer hasNoSites 
			    ifTrue: 
				[swazoo removeServer: httpServer.
				httpServer stop]]].
	self serving: false
    ]

    uriIdentifier [
	<category: 'private'>
	self uriPattern isEmpty ifTrue: [self uriPattern add: SiteIdentifier new].
	^self uriPattern first
    ]

    uriPattern [
	<category: 'private'>
	uriPattern isNil ifTrue: [self initUriPattern].
	^uriPattern
    ]

    watchdogAction [
	"override in your subclass"

	<category: 'private'>
	
    ]
]



Object subclass: SwazooServer [
    | sites servers watchdog |
    
    <category: 'Swazoo-Core'>
    <comment: 'SwazooServer is where all begins in Swazoo!
SwazooServer singleton : return one and only one server which holds the Sites. Also used to start and stop all sites ato once, to add new sited etc. When running, a collection of HTTPServers is also stored in SwazooServer singleton.

SwazooServer demoStart  will create and run a demo site on http://localhost:8888 which 
                              returns a web page with ''Hello World!'''>

    Singleton := nil.

    SwazooServer class >> configureFrom: aFilenameString [
	<category: 'config-from-file'>
	| sites stream |
	self singleton removeAllSites.
	stream := aFilenameString asFilename readStream.
	[sites := self readSitesFrom: stream] ensure: [stream close].
	sites do: 
		[:each | 
		self singleton addSite: each.
		each start]
    ]

    SwazooServer class >> demoStart [
	"on http://localhost:8888/ will return simple 'Hello World'"

	<category: 'start/stop'>
	| site |
	site := self singleton siteNamed: 'swazoodemo'.
	site isNil ifTrue: [site := self singleton prepareDemoSite].
	site start
    ]

    SwazooServer class >> demoStop [
	<category: 'start/stop'>
	self stopSite: 'swazoodemo'
    ]

    SwazooServer class >> exampleConfigurationFile [
	"example sites.cnf, which will serve static files from current directory and respond with
	 'Hello Worlrd' from url http://localhost:8888/foo/Howdy"

	"<Site>
	 <SiteIdentifier ip: '127.0.0.1' port: 8888 host: 'localhost' >
	 <CompositeResource uriPattern: '/'>
	 <CompositeResource uriPattern: 'foo'>
	 <HelloWorldResource uriPattern: 'Howdy'>
	 </CompositeResource>
	 </CompositeResource>
	 <FileResource uriPattern: '/' filePath: '.'>
	 </Site>"

	<category: 'config-from-file'>
	
    ]

    SwazooServer class >> initSingleton [
	<category: 'private'>
	Singleton := super new
    ]

    SwazooServer class >> initialize [
	"self initialize"

	<category: 'initialize'>
	SpEnvironment addImageStartupTask: [self singleton restartServers]
	    for: self singleton
    ]

    SwazooServer class >> new [
	<category: 'private'>
	^self shouldNotImplement
    ]

    SwazooServer class >> readSitesFrom: aStream [
	<category: 'private'>
	| sites instance |
	sites := OrderedCollection new.
	
	[instance := SwazooSite new readFrom: aStream.
	instance notNil] 
		whileTrue: [sites add: instance].
	^sites
    ]

    SwazooServer class >> restart [
	<category: 'start/stop'>
	self
	    stop;
	    start
    ]

    SwazooServer class >> singleton [
	<category: 'accessing'>
	Singleton isNil ifTrue: [self initSingleton].
	^Singleton
    ]

    SwazooServer class >> siteHostnamed: aString [
	<category: 'accessing'>
	^self singleton siteHostnamed: aString
    ]

    SwazooServer class >> siteNamed: aString [
	<category: 'accessing'>
	^self singleton siteNamed: aString
    ]

    SwazooServer class >> start [
	"start all sites"

	<category: 'start/stop'>
	self singleton start
    ]

    SwazooServer class >> startOn: aPortNumber [
	"start a site on that port, on all ip interfaces and accepting all hosts.
	 It also created a site if there is any site on that port yet"

	<category: 'start/stop'>
	^self singleton startOn: aPortNumber
    ]

    SwazooServer class >> startSite: aString [
	"start site with that name"

	<category: 'start/stop'>
	self singleton startSite: aString
    ]

    SwazooServer class >> stop [
	"stop all sites"

	<category: 'start/stop'>
	self singleton stop
    ]

    SwazooServer class >> stopOn: aPortNumber [
	"stop a site on that port, if any runingon all ip interfaces and accepting all hosts."

	<category: 'start/stop'>
	^self singleton stopOn: aPortNumber
    ]

    SwazooServer class >> stopSite: aString [
	"stop site with that name"

	<category: 'start/stop'>
	self singleton stopSite: aString
    ]

    SwazooServer class >> swazooVersion [
	<category: 'accessing'>
	^'Swazoo 2.2 Smalltalk Web Server'
    ]

    addServer: aHTTPServer [
	<category: 'private-servers'>
	^self servers add: aHTTPServer
    ]

    addSite: aSite [
	<category: 'adding/removing'>
	(self siteNamed: aSite name) notNil 
	    ifTrue: [^SwazooSiteError error: 'Site with that name already exist!'].
	(self siteHostnamed: aSite host) notNil 
	    ifTrue: [^SwazooSiteError error: 'Site host name must be unique!'].
	(self 
	    hasSiteHostnamed: aSite host
	    ip: aSite ip
	    port: aSite port) 
		ifTrue: 
		    [^SwazooSiteError 
			error: 'Site with that host:ip:port combination already exist!'].
	(self allowedHostIPPortFor: aSite) 
	    ifFalse: 
		[^SwazooSiteError 
		    error: 'Site with such host:ip:port combination not allowed!'].
	self sites add: aSite
    ]

    allSites [
	<category: 'accessing'>
	^self sites copy
    ]

    allowedHostIPPortFor: aSite [
	"is host:ip:port combination of aSite allowed regarding to existing sites?"

	"rules:
	 1. host name must be unique, except if it is * (anyHost)
	 2. only one site per port can run on any host and all IP interfaces (ip = * or 0.0.0.0)
	 3. if there is a site runing on all IPs, then no one can run on specific ip, per port
	 4. 3 vice versa
	 5. there is no site with the same host ip port combination
	 "

	<category: 'private'>
	(self siteHostnamed: aSite host) notNil ifTrue: [^false].
	(aSite onAllInterfaces and: [self hasSiteOnPort: aSite port]) 
	    ifTrue: [^false].
	(aSite onAllInterfaces not 
	    and: [self hasSiteOnAllInterfacesOnPort: aSite port]) ifTrue: [^false].
	(self 
	    hasSiteHostnamed: aSite host
	    ip: aSite ip
	    port: aSite port) ifTrue: [^false].
	^true
    ]

    hasSiteHostnamed: aHostname ip: ipString port: aNumber [
	<category: 'private'>
	^self sites contains: 
		[:each | 
		each host = aHostname and: [each ip = ipString and: [each port = aNumber]]]
    ]

    hasSiteOnAllInterfacesOnPort: aNumber [
	"only one site per port is allowed when listening to all interfaces"

	<category: 'private'>
	^self sites 
	    contains: [:each | each onAllInterfaces and: [each port = aNumber]]
    ]

    hasSiteOnPort: aNumber [
	<category: 'private'>
	^self sites contains: [:each | each port = aNumber]
    ]

    initServers [
	<category: 'initialize-release'>
	servers := Set new
    ]

    initSites [
	<category: 'initialize-release'>
	sites := OrderedCollection new
    ]

    initialize [
	<category: 'initialize-release'>
	self initSites.
	self initServers
    ]

    isServing [
	"any site running currently?"

	<category: 'testing'>
	^self servers notEmpty
    ]

    isWatchdogRunning [
	<category: 'private-watchdog'>
	^self watchdog notNil	"and: [self watchdog is not].  ?!!?"
    ]

    newServerFor: aSiteIdentifier [
	<category: 'private-servers'>
	^aSiteIdentifier newServer
    ]

    prepareDemoSite [
	"on http://localhost:8888 to return 'Hello Word'"

	<category: 'private'>
	| site |
	site := SwazooSite newNamed: 'swazoodemo'.	"which is now also added to SwazoServer"
	site 
	    host: '*'
	    ip: '*'
	    port: 8888.
	site addResource: (HelloWorldResource uriPattern: '/').
	^site
    ]

    prepareDemoSiteOnPort: aNumber [
	"this site will run on all IP interfaces on that port, returning 'Hello World'"

	<category: 'private'>
	| name site |
	name := 'port' , aNumber printString.
	site := SwazooSite newNamed: name.	"which is now also added to SwazoServer"
	site 
	    host: '*'
	    ip: '*'
	    port: aNumber.
	site addResource: (HelloWorldResource uriPattern: '/').
	^site
    ]

    removeAllSites [
	<category: 'private'>
	self sites copy do: [:each | self removeSite: each]
    ]

    removeServer: aHTTPServer [
	<category: 'private-servers'>
	^self servers remove: aHTTPServer
    ]

    removeSite: aSite [
	<category: 'adding/removing'>
	aSite stop.
	self sites remove: aSite
    ]

    restart [
	<category: 'start/stop'>
	self
	    stop;
	    start
    ]

    restartServers [
	"do that after image restart, because TCP sockets are probably not valid anymore"

	<category: 'private-servers'>
	self servers do: [:each | each restart]
    ]

    serverFor: aSiteIdentifier [
	<category: 'private-servers'>
	| httpServer |
	aSiteIdentifier isEmpty ifTrue: [^nil].	"in case of new one  initializing"
	^self servers 
	    detect: [:each | each ip = aSiteIdentifier ip & (each port = aSiteIdentifier port)]
	    ifNone: 
		[httpServer := self newServerFor: aSiteIdentifier.
		self addServer: httpServer.
		httpServer start.
		^httpServer]
    ]

    servers [
	<category: 'private'>
	servers isNil ifTrue: [self initServers].
	^servers
    ]

    siteAnyHostAllInterfacesOnPort: aNumber [
	"for host: * ip: * sites"

	<category: 'private'>
	^self sites detect: 
		[:each | 
		each onAnyHost and: [each onAllInterfaces and: [each port = aNumber]]]
	    ifNone: [nil]
    ]

    siteHostnamed: aString [
	"find a site with that host name"

	<category: 'accessing'>
	| string |
	aString = '*' ifTrue: [^nil].	"what else should we return?"
	string := aString isNil ifTrue: [''] ifFalse: [aString asLowercase].
	^self sites 
	    detect: [:each | each host notNil and: [each host asLowercase = string]]
	    ifNone: [nil]
    ]

    siteNamed: aString [
	"find a site with that short name"

	<category: 'accessing'>
	| string |
	string := aString isNil ifTrue: [''] ifFalse: [aString asLowercase].
	^self sites detect: [:each | each name asLowercase = string] ifNone: [nil]
    ]

    sites [
	<category: 'private'>
	sites isNil ifTrue: [self initSites].
	^sites
    ]

    start [
	<category: 'start/stop'>
	self sites do: [:site | site start].
	self startWatchdog
    ]

    startOn: aPortNumber [
	"start a site on that port, on all ip interfaces and accepting all hosts.
	 It also created a site if there is any site on that port yet"

	"opening http://localhost:portNumber will return a simple 'Hello world'"

	<category: 'start/stop'>
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	site isNil ifTrue: [site := self prepareDemoSiteOnPort: aPortNumber].
	site start.
	^site
    ]

    startSite: aString [
	"start site with that name"

	<category: 'start/stop'>
	| site |
	site := self siteNamed: aString.
	^site notNil 
	    ifTrue: 
		[site start.
		self isWatchdogRunning ifFalse: [self startWatchdog].
		site]
	    ifFalse: [nil]
    ]

    startWatchdog [
	"SwazooServer singleton startWatchdog"

	<category: 'private-watchdog'>
	self isWatchdogRunning ifTrue: [self stopWatchdog].
	self 
	    watchdog: (
		[[true] whileTrue: 
			[(self respondsTo: #watchdogSites) ifTrue: [self watchdogSites].
			(self respondsTo: #watchdogOther) ifTrue: [self watchdogOther].	"if any"
			(Delay forSeconds: self watchdogPeriod) wait]] 
			forkAt: Processor lowIOPriority)
    ]

    stop [
	<category: 'start/stop'>
	self sites do: [:site | site stop].
	self servers do: [:server | server stop].
	self initServers.
	self stopWatchdog
    ]

    stopOn: aPortNumber [
	"stop a site on that port, if any running on all ip interfaces and accepting all hosts"

	<category: 'start/stop'>
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	^site notNil 
	    ifTrue: 
		[site stop.
		site]
	    ifFalse: [nil]
    ]

    stopSite: aString [
	"stop site with that name"

	<category: 'start/stop'>
	| site |
	site := self siteNamed: aString.
	^site notNil 
	    ifTrue: 
		[site stop.
		site]
	    ifFalse: [nil]
    ]

    stopWatchdog [
	<category: 'private-watchdog'>
	self watchdog notNil 
	    ifTrue: 
		[self watchdog terminate.
		self watchdog: nil]
    ]

    watchdog [
	<category: 'private-watchdog'>
	^watchdog
    ]

    watchdog: aProcess [
	<category: 'private-watchdog'>
	watchdog := aProcess
    ]

    watchdogPeriod [
	<category: 'private-watchdog'>
	^10	"seconds"
    ]

    watchdogSites [
	<category: 'private-watchdog'>
	self sites do: [:each | each isServing ifTrue: [each watchdogAction]]
    ]
]



Eval [
    SwazooServer initialize
]
