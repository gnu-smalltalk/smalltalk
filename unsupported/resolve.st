!Integer methodsFor: 'Internet hacking' ifTrue: Bigendian!

ntohs
    ^self
!

ntohl
    ^self
! !


!Integer methodsFor: 'Internet hacking' ifTrue: Bigendian not!

ntohs
    ^(self bitShift: -8) + ((self bitAnd: 255) bitShift: 8)
!

ntohl
    ^(self bitShift: -16) ntohs + 
	((self bitAnd: 65535) ntohs bitShift: 16)
! !


Object subclass: #ResolverQuestion
       instanceVariableNames: 'name type class'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!ResolverQuestion class methodsFor: 'instance creation'!

name: aName type: aType class: aClass
    ^self new name: aName type: aType: class: aClass
! !

!ResolverQuestion methodsFor: 'accessing'!

name: aName type: aType class: aClass
    name := aName.
    type := aType.
    class := aClass.
!

name
    ^name
!

type
    ^type
!

qClass				"don't take away the 'class' selector"
    ^class
! !


Object subclass: #ResolverResponse
       instanceVariableNames: 'name type class timeToLive'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #CanonicalName
       instanceVariableNames: 'canonicalName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #HostInformation
       instanceVariableNames: 'cpuName osName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #MailBoxDomain
       instanceVariableNames: 'domainName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #MailDestination
       instanceVariableNames: 'domainName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #MailForwarder
       instanceVariableNames: 'forwardToHostName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #MailGroupMember
       instanceVariableNames: 'groupMemberName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #MailRename
       instanceVariableNames: 'newName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 



ResolverResponse subclass: #NullResponse
       instanceVariableNames: 'data'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 



ResolverResponse subclass: #NameServer
       instanceVariableNames: 'serverHost'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #DomainNamePointer
       instanceVariableNames: 'domainName'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #StartOfAuthority
       instanceVariableNames: 'sourceServer responsibleMailbox serialNum
			       refreshTime retryTime expireTime minTimeToLive'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

ResolverResponse subclass: #MailBoxInfo
       instanceVariableNames: 'responsibleMailbox errorMailBox'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 




!ResolverResponse class methodsFor: 'instance creation'!

name: aName type: aType class: aClass timeToLive: aShort
    ^self new init: aName type: aType class: aClass timeToLive: aShort
! !


!ResolverResponse methodsFor: 'private'!

init: aName type: aType class: aClass timeToLive: aShort
    name := aName.
    type := aType.
    class := aClass.
    timeToLive := aShort.
! !

!CanonicalName class methodsFor: 'instance creation'!

name: aName type: aType class: aClass timeToLive: aShort canonicalName: cName
    ^self new init: aName type: aType class: aClass timeToLive: aShort 
	      canonicalName: cName
! !


!CanonicalName methodsFor: 'private'!

init: aName type: aType class: aClass timeToLive: aShort canonicalName: cName
    self init: aName type: aType class: aClass timeToLive: aShort.
    canonicalName := cName.
! !


Object subclass: #Resolver
       instanceVariableNames: 'message ptr header'
       classVariableNames: 'TypeBlocks'
       poolDictionaries: ''
       category: 'Internet'
!


Resolver class
	defineCFunc: 'res_init'
	withSelectorArgs: 'init'
	returning: #long
	args: #()
!


Resolver class
	defineCFunc: 'res_query'
	withSelectorArgs: 'domain: domain class: class type: type 
		       answer: answer ansLen: anslen'
	returning: #long
	args: #(#string #long #long #cObject #long)
! 

Resolver init printNl!
    
CStruct newStruct: #ResolveHeader
	declaration:
	    #(
	      (#id #uShort)
	      (#resp1 #uChar)
	      (#resp2 #uChar)
	      (#qdCount #uShort)
	      (#anCount #uShort)
	      (#nsCount #uShort)
	      (#arCount #uShort)
	     )
!



!Resolver class methodsFor: 'instance creation'!

new
    ^super new init
!

initialize
    TypeBlocks := Dictionary new.
    TypeBlocks at: 1		"A"
	       put: [ :resolver :name :type: class | 
			HostAddress name: name type: type
				   class: class addr: resolver scanAddr ].

    TypeBlocks at: 2		"NS"
	       put: [ :resolver :name :type: class | 
			NameServer name: name type: type
				   class: class host: resolver scanName ].

    TypeBlocks at: 3		"MD"
	       put: [ :resolver :name :type: class | 
			MailDestination name: name type: type
				   class: class dest: resolver scanName ].

    TypeBlocks at: 4		"MF"
	       put: [ :resolver :name :type: class | 
			MailForwarder name: name type: type
				   class: class dest: resolver scanName ].

    TypeBlocks at: 5		"CNAME"
	       put: [ :resolver :name :type: class | 
			CanonicalName name: name type: type
				   class: class canonicalName: resolver scanName ].

    TypeBlocks at: 6		"SOA"
	       put: [ :resolver :name :type: class | 
			StartOfAuthority name: name type: type
					 class: class 
					 source: resolver scanName 
					 responsible: resolver scanName
					 serialNum: resolver scanShort
					 refresh: resolver scanLong
					 retry: resolver scanLong
					 expire: resolver scanLong
					 minTTL: resolver scanShort
			    ].

    TypeBlocks at: 7		"MB"
	       put: [ :resolver :name :type: class | 
			MailBoxDomain name: name type: type
				   class: class mailBox: resolver scanName ].

    TypeBlocks at: 8		"MG"
	       put: [ :resolver :name :type: class | 
			MailGroupMember name: name type: type
				   class: class group: resolver scanName ].

    TypeBlocks at: 9		"MR"
	       put: [ :resolver :name :type: class | 
			MailRename name: name type: type
				   class: class rename: resolver scanName ].

    TypeBlocks at: 10		"NULL"
	       put: [ :resolver :name :type: class | 
			NullResponse name: name type: type
				   class: class data: "notright"resolver scanName ].

    TypeBlocks at: 11		"WKS"
	       put: [ :resolver :name :type: class | 
			NullResponse name: name type: type
				   class: class data: "notright"resolver scanName ].

    TypeBlocks at: 12		"PTR"
	       put: [ :resolver :name :type: class | 
			DomainNamePointer name: name type: type
				   class: class pointer: resolver scanName ].

    TypeBlocks at: 13		"HINFO"
	       put: [ :resolver :name :type: class | 
			HostInformation name: name type: type
				      class: class cpu: resolver scanString
				      os: resolver scanString ].

    TypeBlocks at: 14		"MINFO"
	       put: [ :resolver :name :type: class | 
			MailBoxInfo name: name type: type
				      class: class 
				      responsibleMailBox: resolver scanName 
				      errorMailBox: resolver scanName ].


! !


Resolver initialize!

!Resolver methodsFor: 'private'!

init
    message :=  (CType baseType: CArray subType: CUChar
		      numElements: 2000) new.
    ptr := 0.
!

scanName
    | len components |
    components := OrderedCollection new: 1.
    [ len := message at: ptr.
      len ~= 0 ] whileTrue:
	  [ components addAll: self scanNameComponent ].
    ^components
!

scanNameComponent
    | str |
    str := self scanNameComponentAt: ptr.
    self advancePtr.
    ^self
! !

advancePtr
    | len |
    len := message at: ptr.
    len > 63
	ifTrue: [ ptr := ptr + 2 ]
	ifFalse: [ ptr := ptr + len + 1 ].
! !
    
scanNameComponentAt: aPtr
    | len str | 
    len := message at: aPtr.
    len > 63
	ifTrue: [ ^self scanCompressedNameAt: aPtr ].
    
    str := String fromCData: (message addressAt: aPtr + 1) size: len.
    ^Array with: str
!

scanCompressedNameAt: aPtr
    | localPtr components |
    localPtr := (message at: aPtr) bitAnd: 2r001111111.
    localPtr := (len bitShift: 8) + message at: aPtr + 1.
    components := self scanNameComponentAt: localPtr.
    ^components
!

scanShort
    | value |
    value := (message at: ptr) bitShift: 8.
    value := value + (message at: ptr + 1).
    ptr := ptr + 2.
    ^value
!

scanLong
    | value |
    value := self scanShort bitShift: 16.
    value := value + self scanShort.
    ^value
!

scanString
    | str len | 
    len := message at: ptr.
    str := String fromCData: (message addressAt: ptr + 1) size: len.
    ptr := ptr + len + 1.
    ^str
!

scanQuestion
    | name type class |
    name := self scanName.
    type := self scanShort.
    class := self scanShort.
    ^ResolverQuestion name: name type: type class: class
!

scanResourceRecord
    | name type class timeToLive len creationBlock|
    name := self scanName.
    type := self scanShort.
    class := self scanShort.
    len := self scanShort.
    creationBlock := TypeBlocks at: type 
			       ifAbsent: 
				   [ ^self error: 'Unknown resourcetype ', 
					 type printString ].
    ^creationBlock value: name value: type value: class. 
! !



!Resolver methodsFor: 'accessing'!

testAccess
    | len str header |
    'here goes' printNl.
    len := Resolver domain: 'taligent.com' class: 255
	      type: 255 
	      answer: message ansLen: message sizeof.
    'len is ' print. len printNl.
    len > 0 
	ifTrue: [ header := ans castTo: (CType baseType: ResolveHeader).
		  'after cast' printNl.
		  header id value ntohs printNl.
		  Transcript nextPutAll: 'queries: '. header qdCount value ntohs printNl.
		  Transcript nextPutAll: 'answers: '. header anCount value ntohs printNl.
		  Transcript nextPutAll: 'nsCount: '. header nsCount value ntohs printNl.
		  Transcript nextPutAll: 'arCount: '. header arCount value ntohs printNl.
		  header sizeof  to: len do:
		      [ :i | (ans at: i type: CUChar scalarIndex ) asciiValue printNl ].

		  ].
! !


Resolver new testAccess
!
