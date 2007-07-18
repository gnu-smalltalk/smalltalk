Integer class extend [

    ntohs [
	<category: 'Internet hacking'>
	Memory bigEndian ifTrue: [^self].
	^(self bitShift: -8) + ((self bitAnd: 255) bitShift: 8)
    ]

    ntohl [
	<category: 'Internet hacking'>
	Memory bigEndian ifTrue: [^self].
	^(self bitShift: -16) ntohs + ((self bitAnd: 65535) ntohs bitShift: 16)
    ]

]



Eval [
    DLD addLibrary: 'libc'
]



Object subclass: ResolverQuestion [
    | name type class |
    
    <category: nil>
    <comment: nil>

    ResolverQuestion class >> name: aName type: aType class: aClass [
	<category: 'instance creation'>
	^self new 
	    name: aName
	    type: aType
	    class: aClass
    ]

    name: aName type: aType class: aClass [
	<category: 'accessing'>
	name := aName.
	type := aType.
	class := aClass
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    qClass [
	"don't take away the 'class' selector"

	<category: 'accessing'>
	^class
    ]
]



Object subclass: ResolverResponse [
    | name type class timeToLive |
    
    <category: nil>
    <comment: nil>

    ResolverResponse class >> name: aName type: aType class: aClass timeToLive: aShort [
	<category: 'instance creation'>
	^self new 
	    init: aName
	    type: aType
	    class: aClass
	    timeToLive: aShort
    ]

    init: aName type: aType class: aClass timeToLive: aShort [
	<category: 'private'>
	name := aName.
	type := aType.
	class := aClass.
	timeToLive := aShort
    ]
]



ResolverResponse subclass: CanonicalName [
    | canonicalName |
    
    <category: nil>
    <comment: nil>

    CanonicalName class >> name: aName type: aType class: aClass timeToLive: aShort canonicalName: cName [
	<category: 'instance creation'>
	^self new 
	    init: aName
	    type: aType
	    class: aClass
	    timeToLive: aShort
	    canonicalName: cName
    ]

    init: aName type: aType class: aClass timeToLive: aShort canonicalName: cName [
	<category: 'private'>
	self 
	    init: aName
	    type: aType
	    class: aClass
	    timeToLive: aShort.
	canonicalName := cName
    ]
]



ResolverResponse subclass: HostInformation [
    | cpuName osName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: MailBoxDomain [
    | domainName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: MailDestination [
    | domainName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: MailForwarder [
    | forwardToHostName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: MailGroupMember [
    | groupMemberName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: MailRename [
    | newName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: NullResponse [
    | data |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: NameServer [
    | serverHost |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: DomainNamePointer [
    | domainName |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: StartOfAuthority [
    | sourceServer responsibleMailbox serialNum refreshTime retryTime expireTime minTimeToLive |
    
    <category: nil>
    <comment: nil>
]



ResolverResponse subclass: MailBoxInfo [
    | responsibleMailbox errorMailBox |
    
    <category: nil>
    <comment: nil>
]



Object subclass: Resolver [
    | message ptr header |
    
    <category: 'Internet'>
    <comment: nil>

    TypeBlocks := nil.

    Resolver class >> new [
	<category: 'instance creation'>
	^super new init
    ]

    Resolver class >> initialize [
	<category: 'instance creation'>
	TypeBlocks := Dictionary new.
	TypeBlocks at: 1
	    put: 
		[:resolver :name :type :class | 
		"A"

		HostAddress 
		    name: name
		    type: type
		    class: class
		    addr: resolver scanAddr].
	TypeBlocks at: 2
	    put: 
		[:resolver :name :type :class | 
		"NS"

		NameServer 
		    name: name
		    type: type
		    class: class
		    host: resolver scanName].
	TypeBlocks at: 3
	    put: 
		[:resolver :name :type :class | 
		"MD"

		MailDestination 
		    name: name
		    type: type
		    class: class
		    dest: resolver scanName].
	TypeBlocks at: 4
	    put: 
		[:resolver :name :type :class | 
		"MF"

		MailForwarder 
		    name: name
		    type: type
		    class: class
		    dest: resolver scanName].
	TypeBlocks at: 5
	    put: 
		[:resolver :name :type :class | 
		"CNAME"

		CanonicalName 
		    name: name
		    type: type
		    class: class
		    canonicalName: resolver scanName].
	TypeBlocks at: 6
	    put: 
		[:resolver :name :type :class | 
		"SOA"

		StartOfAuthority 
		    name: name
		    type: type
		    class: class
		    source: resolver scanName
		    responsible: resolver scanName
		    serialNum: resolver scanShort
		    refresh: resolver scanLong
		    retry: resolver scanLong
		    expire: resolver scanLong
		    minTTL: resolver scanShort].
	TypeBlocks at: 7
	    put: 
		[:resolver :name :type :class | 
		"MB"

		MailBoxDomain 
		    name: name
		    type: type
		    class: class
		    mailBox: resolver scanName].
	TypeBlocks at: 8
	    put: 
		[:resolver :name :type :class | 
		"MG"

		MailGroupMember 
		    name: name
		    type: type
		    class: class
		    group: resolver scanName].
	TypeBlocks at: 9
	    put: 
		[:resolver :name :type :class | 
		"MR"

		MailRename 
		    name: name
		    type: type
		    class: class
		    rename: resolver scanName].
	TypeBlocks at: 10
	    put: 
		[:resolver :name :type :class | 
		"NULL"

		NullResponse 
		    name: name
		    type: type
		    class: class
		    data: resolver scanName	"notright"].
	TypeBlocks at: 11
	    put: 
		[:resolver :name :type :class | 
		"WKS"

		NullResponse 
		    name: name
		    type: type
		    class: class
		    data: resolver scanName	"notright"].
	TypeBlocks at: 12
	    put: 
		[:resolver :name :type :class | 
		"PTR"

		DomainNamePointer 
		    name: name
		    type: type
		    class: class
		    pointer: resolver scanName].
	TypeBlocks at: 13
	    put: 
		[:resolver :name :type :class | 
		"HINFO"

		HostInformation 
		    name: name
		    type: type
		    class: class
		    cpu: resolver scanString
		    os: resolver scanString].
	TypeBlocks at: 14
	    put: 
		[:resolver :name :type :class | 
		"MINFO"

		MailBoxInfo 
		    name: name
		    type: type
		    class: class
		    responsibleMailBox: resolver scanName
		    errorMailBox: resolver scanName]
    ]

    init [
	<category: 'private'>
	message := (CUCharType arrayType: 2000) new.
	ptr := 0
    ]

    scanName [
	<category: 'private'>
	| len components |
	components := OrderedCollection new: 1.
	
	[len := message at: ptr.
	len ~= 0] 
		whileTrue: [components addAll: self scanNameComponent].
	^components
    ]

    scanNameComponent [
	<category: 'private'>
	| str |
	str := self scanNameComponentAt: ptr.
	self advancePtr.
	^self
    ]

    advancePtr [
	<category: 'private'>
	| len |
	len := message at: ptr.
	len > 63 ifTrue: [ptr := ptr + 2] ifFalse: [ptr := ptr + len + 1]
    ]

    scanNameComponentAt: aPtr [
	<category: 'private'>
	| len str |
	len := message at: aPtr.
	len > 63 ifTrue: [^self scanCompressedNameAt: aPtr].
	str := String fromCData: (message addressAt: aPtr + 1) size: len.
	^Array with: str
    ]

    scanCompressedNameAt: aPtr [
	<category: 'private'>
	| len components |
	len := (message at: aPtr) bitAnd: 127.
	len := (len bitShift: 8) + (message at: aPtr + 1).
	components := self scanNameComponentAt: len.
	^components
    ]

    scanShort [
	<category: 'private'>
	| value |
	value := (message at: ptr) bitShift: 8.
	value := value + (message at: ptr + 1).
	ptr := ptr + 2.
	^value
    ]

    scanLong [
	<category: 'private'>
	| value |
	value := self scanShort bitShift: 16.
	value := value + self scanShort.
	^value
    ]

    scanString [
	<category: 'private'>
	| str len |
	len := message at: ptr.
	str := String fromCData: (message addressAt: ptr + 1) size: len.
	ptr := ptr + len + 1.
	^str
    ]

    scanQuestion [
	<category: 'private'>
	| name type class |
	name := self scanName.
	type := self scanShort.
	class := self scanShort.
	^ResolverQuestion 
	    name: name
	    type: type
	    class: class
    ]

    scanResourceRecord [
	<category: 'private'>
	| name type class timeToLive len creationBlock |
	name := self scanName.
	type := self scanShort.
	class := self scanShort.
	len := self scanShort.
	creationBlock := TypeBlocks at: type
		    ifAbsent: [^self error: 'Unknown resourcetype ' , type printString].
	^creationBlock 
	    value: name
	    value: type
	    value: class
    ]

    testAccess [
	<category: 'accessing'>
	| len str header |
	'here goes' printNl.
	len := Resolver 
		    domain: 'gnu.org'
		    class: 255
		    type: 255
		    answer: message
		    ansLen: message sizeof.
	'len is ' print.
	len printNl.
	len > 0 
	    ifTrue: 
		[header := message castTo: (CType baseType: ResolveHeader).
		'after cast' printNl.
		header id value ntohs printNl.
		Transcript nextPutAll: 'queries: '.
		header qdCount value ntohs printNl.
		Transcript nextPutAll: 'answers: '.
		header anCount value ntohs printNl.
		Transcript nextPutAll: 'nsCount: '.
		header nsCount value ntohs printNl.
		Transcript nextPutAll: 'arCount: '.
		header arCount value ntohs printNl.
		header sizeof to: len
		    do: [:i | (message at: i type: CUChar scalarIndex) asciiValue printNl]]
    ]
]



Eval [
    Resolver class 
	defineCFunc: 'res_init'
	withSelectorArgs: 'init'
	returning: #long
	args: #().

    Resolver class 
	defineCFunc: 'res_query'
	withSelectorArgs: 'domain: domain class: class type: type 
		       answer: answer ansLen: anslen'
	returning: #long
	args: #(#string #long #long #cObject #long).

    Resolver init printNl.
    CStruct newStruct: #ResolveHeader
	declaration: #(#(#id #uShort)
		       #(#resp1 #uChar)
		       #(#resp2 #uChar)
		       #(#qdCount #uShort)
		       #(#anCount #uShort)
		       #(#nsCount #uShort)
		       #(#arCount #uShort)).

    Resolver initialize.
    Resolver new testAccess
]

