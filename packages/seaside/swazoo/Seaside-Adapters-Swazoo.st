Object subclass: SwazooSeaside [
    
    <category: 'Seaside-Adapters-Swazoo'>
    <import: Swazoo>
    <comment: 'I offer the same functionality as WAKom for Swazoo 2.

You can start and stop me with:
SwazooSeaside startOn: 8080
SwazooSeaside stop
which listens to http://127.0.0.1:8080/seaside/

Encoding can be switched on with:
SwazooSeaside doEncoding: true

You can use a specific encoding with:
SwazooSeaside encoding: ''utf-8'''>

    SwazooSeaside class >> doEncoding: aBoolean [
	"toggle encoding mode
	 with encoding on you will end up with mulit byte strings
	 with encoding off you will end up with strings where each charachter is only a byte"

	<category: 'service'>
	SeasideSite doEncoding: aBoolean
    ]

    SwazooSeaside class >> encoding: aStringOrNil [
	"sets the encoding of the server"

	<category: 'service'>
	SeasideSite encoding: aStringOrNil
    ]

    SwazooSeaside class >> start [
	"Starts all exisitng sites. Use #startOn: if site on that port not yet exist"

	<category: 'service'>
	SwazooServer start
    ]

    SwazooSeaside class >> startOn: aPort [
	<category: 'service'>
	| site |
	site := SeasideSite ensureRegistered: aPort.
	site start
    ]

    SwazooSeaside class >> stop [
	"Stops all sites"

	<category: 'service'>
	SwazooServer stop
    ]
]



Swazoo.HTTPMessage extend [

    remoteAddress [
	<category: '*Seaside-Adapters-Swazoo'>
	^self peer
    ]

]



Swazoo.SwazooSite subclass: SeasideSite [
    | dispatcher codec |
    
    <comment: 'I am the implementation of the Seaside server adaptor for Swazoo 2.'>
    <category: 'Seaside-Adapters-Swazoo'>
    <import: Swazoo>

    SeasideSite class >> default [
	<category: 'convenience'>
	^self named: self defaultName
    ]

    SeasideSite class >> defaultHost [
	<category: 'accessing-defaults'>
	^'*'
    ]

    SeasideSite class >> defaultIp [
	<category: 'accessing-defaults'>
	^'*'
    ]

    SeasideSite class >> defaultName [
	<category: 'accessing-defaults'>
	^'seasidesite'
    ]

    SeasideSite class >> defaultPort [
	<category: 'accessing-defaults'>
	^8080
    ]

    SeasideSite class >> doEncoding: aBoolean [
	<category: 'convenience'>
	self default doEncoding: aBoolean
    ]

    SeasideSite class >> encoding: aStringOrNil [
	<category: 'convenience'>
	self default encoding: aStringOrNil
    ]

    SeasideSite class >> ensureRegistered [
	<category: 'convenience'>
	^self ensureRegistered: self defaultPort
    ]

    SeasideSite class >> ensureRegistered: aPort [
	<category: 'convenience'>
	^aPort = self defaultPort 
	    ifTrue: [self default isNil ifTrue: [self newDefault] ifFalse: [self default]]
	    ifFalse: 
		[| site |
		site := SwazooServer singleton siteAnyHostAllInterfacesOnPort: aPort.
		site isNil ifTrue: [site := self newOnPort: aPort].
		site]
    ]

    SeasideSite class >> nameForPort: aPort [
	<category: 'instance creation'>
	^'seasideOn' , aPort printString
    ]

    SeasideSite class >> newDefault [
	<category: 'instance creation'>
	^(self newNamed: self defaultName) 
	    host: self defaultHost
	    ip: self defaultIp
	    port: self defaultPort
    ]

    SeasideSite class >> newOnPort: aPort [
	<category: 'instance creation'>
	^(self newNamed: (self nameForPort: aPort)) 
	    host: self defaultHost
	    ip: self defaultIp
	    port: aPort
    ]

    answerTo: aSwazooRequest [
	<category: 'serving'>
	(self isImplemented: aSwazooRequest methodName) 
	    ifFalse: [^self notImplementedResponse].
	^SpExceptionContext for: 
		[| response |
		response := 
			[self dispatcher handleRequest: (self convertRequest: aSwazooRequest)] 
				on: WADynamicVariable
				do: [:notifiation | notifiation resume: notifiation defaultAction].
		^self convertResponse: response]
	    onAnyExceptionDo: [:exception | self internalErrorResponseFor: exception]
    ]

    codec [
	<category: 'accessing'>
	codec isNil ifTrue: [codec := WANullCodec new].
	^codec
    ]

    collectionClass [
	<category: 'private'>
	^OrderedCollection
    ]

    contentsOfResponse: aResponse [
	<category: 'private'>
	| contents |
	contents := aResponse contents contents.
	^aResponse contentType isBinary 
	    ifTrue: [contents]
	    ifFalse: [self encode: contents]
    ]

    convertHeader: aSwazooRequest [
	<category: 'private'>
	| swazooFields fields |
	swazooFields := aSwazooRequest headers fields.
	fields := Dictionary new: swazooFields size.
	swazooFields keysAndValuesDo: 
		[:key :field | 
		| value |
		value := String streamContents: [:stream | field valuesAsStringOn: stream].
		fields at: key asLowercase put: value].
	^fields
    ]

    convertRequest: aSwazooRequest [
	<category: 'private'>
	^WARequest 
	    method: aSwazooRequest methodName
	    url: aSwazooRequest uriString
	    headers: (self convertHeader: aSwazooRequest)
	    fields: (self parseFields: aSwazooRequest)
	    cookies: (self parseCookies: aSwazooRequest)
	    nativeRequest: aSwazooRequest
    ]

    convertResponse: aSeasideResponse [
	<category: 'private'>
	| swazooResponse |
	swazooResponse := HTTPResponse new.
	aSeasideResponse headers do: 
		[:each | 
		| field fieldClass |
		fieldClass := HeaderField classForFieldName: each key.
		field := fieldClass newForFieldName: each key withValueFrom: each value.
		swazooResponse headers addField: field].
	aSeasideResponse cookies 
	    do: [:each | swazooResponse cookie: (self cookieHeaderFor: each)].
	swazooResponse code: aSeasideResponse status asNumber.
	swazooResponse entity: (self contentsOfResponse: aSeasideResponse).
	swazooResponse contentType: aSeasideResponse contentType seasideString.
	aSeasideResponse release.
	^swazooResponse
    ]

    cookieHeaderFor: aCookie [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: aCookie key;
		    nextPutAll: '=';
		    nextPutAll: (aCookie value ifNil: ['']).
		aCookie path isNil 
		    ifFalse: 
			[stream
			    nextPutAll: '; path=';
			    nextPutAll: aCookie path].
		aCookie expiry isNil 
		    ifFalse: 
			[stream
			    nextPutAll: '; expires=';
			    nextPutAll: aCookie expiryString]]
    ]

    decode: aString [
	<category: 'private'>
	^self codec decode: aString
    ]

    decodeUrl: aString [
	<category: 'private'>
	^self codec decodeUrl: aString
    ]

    dispatcher [
	<category: 'accessing'>
	^WADispatcher default
    ]

    doEncoding: aBoolean [
	<category: 'encoding'>
	self encoding: (aBoolean ifTrue: ['utf-8'] ifFalse: [nil])
    ]

    encode: aString [
	<category: 'private'>
	^self codec encode: aString
    ]

    encoding: aStringOrNil [
	"valid values for aStringOrNil are:
	 nil
	 switches off all encoding, like WAKom
	 utf-8
	 uses the utf-8 fast path by Andreas Raab
	 any other encoding supported by Squeak
	 uses whatever TextConverter Squeak uses for this encoding"

	<category: 'encoding'>
	codec := WACodec forEncoding: aStringOrNil
    ]

    helpResolve: aResolution [
	<category: 'serving-private'>
	(self canAnswer and: [aResolution siteMatch: self]) ifFalse: [^nil].
	^self answerTo: aResolution request
    ]

    internalErrorResponseFor: anError [
	<category: 'private'>
	| entity |
	entity := (WARenderCanvas builder)
		    fullDocument: true;
		    render: 
			    [:html | 
			    (html heading)
				level1;
				with: 'Internal Error'.
			    (html heading)
				level2;
				with: anError seasideString.
			    (SeasidePlatformSupport walkbackStringsFor: anError) 
				do: [:each | html text: each]
				separatedBy: [html break]].
	^(HTTPResponse internalServerError)
	    entity: entity;
	    yourself
    ]

    isImplemented: aMethodName [
	<category: 'private'>
	^#('GET' 'POST') includes: aMethodName
    ]

    notImplementedResponse [
	<category: 'private'>
	^HTTPResponse notImplemented
    ]

    parseCookies: aSwazooRequest [
	<category: 'private'>
	| cookies swazooCookies cookieLine |
	cookies := Dictionary new.
	cookieLine := aSwazooRequest cookie.
	cookieLine isEmptyOrNil ifTrue: [^cookies].
	swazooCookies := cookieLine findTokens: $;.
	swazooCookies do: 
		[:each | 
		| pair key value |
		pair := each findTokens: $=.
		key := SpStringUtilities trimBlanksFrom: pair first.
		value := pair size > 1 
			    ifTrue: [SpStringUtilities trimBlanksFrom: pair second]
			    ifFalse: [nil].
		cookies at: key put: value].
	^cookies
    ]

    parseFields: aSwazooRequest [
	<category: 'private'>
	| fields |
	fields := Dictionary new.
	aSwazooRequest isPost 
	    ifTrue: 
		["break encapsulation"

		aSwazooRequest ensureFullRead.
		aSwazooRequest postData keysAndValuesDo: 
			[:key :value | 
			| previousData data |
			data := value filename isEmptyOrNil 
				    ifTrue: [self decodeUrl: value value]
				    ifFalse: 
					[(WAFile new)
					    fileName: (self decodeUrl: value filename);
					    contentType: value contentType toMimeType;
					    contents: value value;
					    yourself].
			previousData := fields at: key ifAbsent: [nil].
			previousData isNil 
			    ifTrue: [fields at: key put: data]
			    ifFalse: 
				[(previousData isKindOf: self collectionClass) 
				    ifTrue: [previousData add: data]
				    ifFalse: 
					[fields at: key put: (self collectionClass with: previousData with: data)]]]]
	    ifFalse: 
		[aSwazooRequest queries 
		    do: [:each | fields at: each key put: (self decodeUrl: each value)]].
	^fields
    ]
]



SeasideSite subclass: SeasideStreamSite [
    
    <comment: 'I do not work yet, do not use me.'>
    <category: 'Seaside-Adapters-Swazoo'>
    <import: Swazoo>

    convertRequest: aSwazooRequest [
	<category: 'accessing'>
	^(super convertRequest: aSwazooRequest)
	    responseStream: aSwazooRequest parent stream;
	    yourself
    ]
]

