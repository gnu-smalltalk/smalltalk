"======================================================================
|
|   Swazoo 2.1 HTTP request/response header components
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


Object subclass: HTTPHeaders [
    | fields |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    addField: aField [
	"HTTPSpec1.1 Sec4.2
	 Multiple message-header fields with the same field-name MAY be present in a message if and only if the entire field-value for that header field is defined as a comma-separated list [i.e., #(values)]. It MUST be possible to combine the multiple header fields into one 'field-name: field-value' pair, without changing the semantics of the message, by appending each subsequent field-value to the first, each separated by a comma. The order in which header fields with the same field-name are received is therefore significant to the interpretation of the combined field value, and thus a proxy MUST NOT change the order of these field values when a message is forwarded.
	 Note that we have to use the field name here as we may be adding a field for which there is no class, i.e. it's a GenericHeaderField."

	<category: 'services'>
	(self includesFieldNamed: aField name) 
	    ifTrue: [(self fieldNamed: aField name) combineWith: aField]
	    ifFalse: [self fields at: aField name asUppercase put: aField].
	^self
    ]

    fieldNamed: aString [
	"^aString
	 If I contain a field named aString, I return it.  Otherwise an exception is thrown.
	 This is a bad way of getting a field.  Use >> fieldOfClass: instead."

	<category: 'services'>
	| targetString |
	targetString := aString asUppercase.
	^self fields detect: [:aField | aField name asUppercase = targetString]
    ]

    fieldNamed: aString ifNone: aBlock [
	"^aString
	 If I contain a field named aString, I return it.  Otherwise I evaluate aBlock."

	<category: 'services'>
	^self fields at: aString asUppercase ifAbsent: aBlock
    ]

    fieldNamed: aFieldName ifPresent: presentBlock ifAbsent: absentBlock [
	"^an Object
	 I look for a field named aFieldName among my fields.  If I find it, I return the result of evaluating presentBlock with the found field as an argument, otherwise I return the result of evaluate the absentBlock"

	<category: 'services'>
	| foundField |
	foundField := self fieldNamed: aFieldName ifNone: [nil].
	^foundField isNil 
	    ifTrue: [absentBlock value]
	    ifFalse: [presentBlock value: foundField]
    ]

    fieldOfClass: aClass [
	"^aString
	 If I contain a field of class aClass, I return it.   Otherwise an exception is thrown."

	<category: 'services'>
	^self fields detect: [:aField | aField class == aClass] ifNone: [^nil]
    ]

    fieldOfClass: aClass ifNone: aBlock [
	"^aString
	 If I contain a field of class aClass, I return it.   Otherwise I evaluate aBlock."

	<category: 'services'>
	^self fields detect: [:aField | aField class == aClass] ifNone: aBlock
    ]

    fieldOfClass: fieldClass ifPresent: presentBlock ifAbsent: absentBlock [
	"^an Object
	 I look for a field of class fieldClass among my fields.  If I find it, I return the result of evaluating presentBlock with the found field as an argument, otherwise I return the result of evaluate the absentBlock"

	<category: 'services'>
	| foundField |
	foundField := self fieldOfClass: fieldClass ifNone: [nil].
	^foundField isNil 
	    ifTrue: [absentBlock value]
	    ifFalse: [presentBlock value: foundField]
    ]

    fields [
	<category: 'private'>
	fields isNil ifTrue: [fields := Dictionary new].
	^fields
    ]

    getOrMakeFieldOfClass: aClass [
	"^a HeaderField
	 If I contain a field of class aClass, I return it.   Otherwise I create a new instance if the field class and add it to my collection of headers."

	<category: 'services'>
	^self fieldOfClass: aClass
	    ifNone: 
		[| newField |
		newField := aClass new.
		self addField: newField.
		newField]
    ]

    includesFieldNamed: aString [
	"^a Boolean
	 I return true if one of my fields has the name aString."

	<category: 'testing'>
	| targetField |
	targetField := self fieldNamed: aString ifNone: [nil].
	^targetField notNil
    ]

    includesFieldOfClass: aClass [
	"^a Boolean
	 I return true if one of my fields is of class aClass."

	<category: 'testing'>
	^self 
	    fieldOfClass: aClass
	    ifPresent: [:aField | true]
	    ifAbsent: [false]
    ]

    printOn: aStream [
	<category: 'private'>
	aStream
	    nextPutAll: 'a HTTPHeaders';
	    cr.
	self fields values do: 
		[:each | 
		aStream
		    nextPutAll: '   ' , each printString;
		    cr]
    ]
]



Object subclass: HeaderField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HeaderField class [
	| httpFieldNameToClassDictionary |
	
    ]

    HeaderField class >> classForFieldName: aString [
	"^a Class
	 If I can find a specific header field with a name matching aString I return that.  Otherwise I return the GenericHeaderField class."

	<category: 'private'>
	^self httpFieldNameToClassDictionary at: aString
	    ifAbsent: [GenericHeaderField]
    ]

    HeaderField class >> fromLine: aString [
        "for testing only"
 	<category: 'instance creation'>
 	| sourceStream fieldName fieldValue |
 	sourceStream := ReadStream on: aString.
 	fieldName := sourceStream upTo: $:.
 	fieldValue := sourceStream upToEnd.
 	^self name: fieldName value: fieldValue
    ]

    HeaderField class >> name: fieldName value: fieldValue [
	<category: 'instance creation'>
	| upName trimValue fieldClass |
	upName := (HTTPString trimBlanksFrom: fieldName) asUppercase.
	fieldClass := self classForFieldName: upName.
	trimValue := HTTPString trimBlanksFrom: fieldValue.
	^fieldClass newForFieldName: upName withValueFrom: trimValue
    ]

    HeaderField class >> httpFieldNameToClassDictionary [
	"^a Class
	 I return the dictionarry of my subclasses keyed on the name of the field they represent.
	 Note that we only need *Request* headers listed in here because they are the only thing we will be parsing for."

	"After a change here, remeber to do 'HeaderField resetHttpFieldNameToClassDictionary'"

	<category: 'private'>
	httpFieldNameToClassDictionary isNil 
	    ifTrue: 
		[| headerClasses |
		headerClasses := OrderedCollection new.
		headerClasses
		    add: ContentDispositionField;
		    add: HTTPContentLengthField;
		    add: ContentTypeField;
		    add: HTTPAcceptField;
		    add: HTTPAuthorizationField;
		    add: HTTPConnectionField;
		    add: HTTPHostField;
		    add: HTTPIfMatchField;
		    add: HTTPIfModifiedSinceField;
		    add: HTTPIfNoneMatchField;
		    add: HTTPIfRangeField;
		    add: HTTPIfUnmodifiedSinceField;
		    add: HTTPRefererField;
		    add: HTTPUserAgentField.
		httpFieldNameToClassDictionary := Dictionary new.
		headerClasses do: 
			[:aClass | 
			httpFieldNameToClassDictionary at: aClass fieldName asUppercase put: aClass]].
	^httpFieldNameToClassDictionary
    ]

    HeaderField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	<category: 'private'>
	^self subclassResponsibility
    ]

    HeaderField class >> resetHttpFieldNameToClassDictionary [
	<category: 'private'>
	httpFieldNameToClassDictionary := nil.
	^self
    ]

    combineWith: aHeaderField [
	<category: 'services'>
	SwazooHeaderFieldParseError raiseSignal: 'Not supported'
    ]

    fieldName [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    isConditional [
	<category: 'testing'>
	^false
    ]

    isContentDisposition [
	<category: 'testing'>
	^false
    ]

    isContentType [
	<category: 'testing'>
	^false
    ]

    name [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self name;
	    nextPutAll: ': '.
	self valuesAsStringOn: aStream.
	^self
    ]

    values [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    valuesAsString [
	<category: 'printing'>
	| targetStream |
	targetStream := WriteStream on: String new.
	self valuesAsStringOn: targetStream.
	^targetStream contents
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	^self subclassResponsibility
    ]
]



HeaderField subclass: GenericHeaderField [
    | name value |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    GenericHeaderField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	<category: 'instance creation'>
	^self new forFieldName: fieldNameString andValue: fieldValueString
    ]

    combineWith: aHeaderField [
	"^self
	 I simply take my values and concatenate the values of aHeaderField."

	<category: 'services'>
	value := self value , ', ' , aHeaderField value.
	^self
    ]

    fieldName [
	<category: 'accessing'>
	1 halt: 'use >>name instead'.
	^self name
    ]

    forFieldName: fieldNameString andValue: fieldValueString [
	<category: 'initialize-release'>
	name := fieldNameString.
	value := fieldValueString.
	^self
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    values [
	<category: 'accessing'>
	^(HTTPString subCollectionsFrom: self value delimitedBy: $,) 
	    collect: [:each | HTTPString trimBlanksFrom: each]
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: value.
	^self
    ]
]



HeaderField subclass: SpecificHeaderField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    SpecificHeaderField class >> fieldName [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    SpecificHeaderField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	<category: 'private'>
	^self newWithValueFrom: fieldValueString
    ]

    SpecificHeaderField class >> newWithValueFrom: fieldValueString [
	<category: 'private'>
	^self new valueFrom: fieldValueString
    ]

    name [
	<category: 'accessing'>
	^self class fieldName
    ]

    parameterAt: aString ifAbsent: aBlock [
	<category: 'accessing'>
	1 halt: 'use the transfer encodings of the field, not this'.
	^self parameters at: aString ifAbsent: aBlock
    ]

    parseValueFrom: aString [
	<category: 'private'>
	^self subclassResponsibility
    ]

    readParametersFrom: sourceStream [
	"^a Dictionary
	 c.f. RFC 2616 3.6 Transfer Codings"

	<category: 'private'>
	| parameters |
	parameters := Dictionary new.
	[sourceStream atEnd] whileFalse: 
		[| attribute value |
		attribute := HTTPString trimBlanksFrom: (sourceStream upTo: $=).
		value := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
		parameters at: attribute put: value].
	^parameters
    ]

    valueFrom: fieldValueString [
	<category: 'initialize-release'>
	self parseValueFrom: fieldValueString.
	^self
    ]

    values [
	<category: 'accessing'>
	^Array with: self value
    ]
]



SpecificHeaderField subclass: ContentDispositionField [
    | type parameters |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    ContentDispositionField class >> fieldName [
	<category: 'accessing'>
	^'Content-Disposition'
    ]

    isContentDisposition [
	<category: 'testing'>
	^true
    ]

    parameterAt: aString [
	<category: 'services'>
	^parameters at: aString ifAbsent: [nil]
    ]

    parseValueFrom: aString [
	<category: 'private'>
	| sourceStream |
	sourceStream := aString readStream.
	type := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
	parameters := self readParametersFrom: sourceStream.
	^self
    ]
]



SpecificHeaderField subclass: ContentTypeField [
    | mediaType transferCodings |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    ContentTypeField class >> fieldName [
	<category: 'accessing'>
	^'Content-Type'
    ]

    defaultMediaType [
	"^a String
	 See RFC 2616 '7.2.1 Type'.  If no media type is specified, application/octet-stream is the default."

	<category: 'accessing'>
	^'application/octet-stream'
    ]

    isContentType [
	<category: 'testing'>
	^true
    ]

    mediaType [
	<category: 'accessing'>
	^mediaType isNil ifTrue: [self defaultMediaType] ifFalse: [mediaType]
    ]

    mediaType: aString [
	<category: 'accessing'>
	mediaType := aString.
	^self
    ]

    parseValueFrom: aString [
	<category: 'private'>
	| sourceStream |
	sourceStream := aString readStream.
	mediaType := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
	transferCodings := self readParametersFrom: sourceStream.
	^self
    ]

    transferCodings [
	<category: 'accessing'>
	transferCodings isNil ifTrue: [transferCodings := String new].
	^transferCodings
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self mediaType.
	self transferCodings isEmpty 
	    ifFalse: 
		[self transferCodings keysAndValuesDo: 
			[:name :value | 
			aStream
			    nextPutAll: ' ';
			    nextPutAll: name;
			    nextPut: $=;
			    nextPutAll: value]].
	^self
    ]
]



SpecificHeaderField subclass: HTTPAcceptField [
    | mediaTypes |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPAcceptField class >> fieldName [
	<category: 'accessing'>
	^'Accept'
    ]

    combineWith: aHeaderField [
	"^self
	 I simply take my values and concatenate the values of aHeaderField."

	<category: 'services'>
	self mediaTypes addAll: aHeaderField mediaTypes.
	^self
    ]

    mediaTypes [
	<category: 'accessing'>
	mediaTypes isNil ifTrue: [mediaTypes := OrderedCollection new].
	^mediaTypes
    ]

    parseValueFrom: aString [
	<category: 'private'>
	mediaTypes := HTTPString subCollectionsFrom: aString delimitedBy: $,.
	^self
    ]

    valuesAsStringOn: targetStream [
	<category: 'printing'>
	self mediaTypes isEmpty 
	    ifFalse: 
		[targetStream nextPutAll: self mediaTypes first.
		2 to: self mediaTypes size
		    do: 
			[:methodIndex | 
			targetStream
			    nextPut: $,;
			    nextPutAll: (self mediaTypes at: methodIndex)]].
	^self
    ]
]



SpecificHeaderField subclass: HTTPAllowField [
    | methods |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPAllowField class >> fieldName [
	<category: 'accessing'>
	^'Allow'
    ]

    methods [
	<category: 'accessing'>
	methods isNil ifTrue: [methods := OrderedCollection new].
	^methods
    ]

    valuesAsStringOn: targetStream [
	<category: 'printing'>
	self methods isEmpty 
	    ifFalse: 
		[targetStream nextPutAll: self methods first.
		2 to: self methods size
		    do: 
			[:methodIndex | 
			targetStream
			    nextPut: $,;
			    nextPutAll: (self methods at: methodIndex)]].
	^self
    ]
]



SpecificHeaderField subclass: HTTPAuthorizationField [
    | credentials |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPAuthorizationField class >> fieldName [
	<category: 'accessing'>
	^'Authorization'
    ]

    HTTPAuthorizationField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	"^an HTTPAuthorizationField
	 I return an instance of one of my concrete subclasses.  To get to this point, the field name *must* be 'AUTHORIZATION'."

	<category: 'private'>
	| sourceStream schemeName |
	sourceStream := ReadStream on: fieldValueString.
	schemeName := sourceStream upTo: Character space.
	^schemeName = 'Basic' 
	    ifTrue: [HTTPAuthorizationBasicField newWithValueFrom: sourceStream upToEnd]
	    ifFalse: [HTTPAuthorizationDigestField newWithValueFrom: sourceStream upToEnd]
    ]

    credentials [
	<category: 'accessing'>
	^credentials
    ]

    parseValueFrom: aString [
	<category: 'private'>
	credentials := HTTPString trimBlanksFrom: aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self credentials.
	^self
    ]
]



HTTPAuthorizationField subclass: HTTPAuthorizationBasicField [
    | userid password |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    password [
	"^a String
	 I return the password string (as defined in RFC 2617 pp.2) part of the user-pass value in my credentials."

	<category: 'services'>
	password isNil ifTrue: [self resolveUserPass].
	^password
    ]

    resolveUserPass [
	"^self
	 I look at my credentials string and pull out the userid and password.  Note that having to check for atEnd before the upToEnd is for GemStone which crashes if upToEnd is used when already atEnd."

	"(Base64EncodingReadStream on: 'YnJ1Y2U6c3F1aWRzdXBwbGllZHBhc3N3b3Jk' ) upToEnd asString"

	<category: 'private'>
	| userPassString sourceStream |
	userPassString := userPassString := Base64MimeConverter 
			    mimeDecode: self credentials
			    as: String.
	sourceStream := ReadStream on: userPassString.
	userid := sourceStream upTo: $:.
	password := sourceStream atEnd 
		    ifTrue: [String new]
		    ifFalse: [sourceStream upToEnd].
	^self
    ]

    userid [
	"^a String
	 I return the userid string (as defined in RFC 2617 pp.2) part of the user-pass value in my credentials."

	<category: 'services'>
	userid isNil ifTrue: [self resolveUserPass].
	^userid
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'Basic '.
	super valuesAsStringOn: aStream.
	^self
    ]
]



HTTPAuthorizationField subclass: HTTPAuthorizationDigestField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'Digest '.
	super valuesAsStringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPCacheControlField [
    | directives private maxAge noStore noCache mustRevalidate |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPCacheControlField class >> fieldName [
	<category: 'accessing'>
	^'Cache-Control'
    ]

    directives [
	"for easy setting directives in one string"

	<category: 'accessing'>
	^directives
    ]

    directives: aString [
	"for easy setting directives in one string"

	"example: 'no-store, no-cache, must-revalidate'"

	<category: 'accessing'>
	directives := aString
    ]

    maxAge [
	"^an Integer or nil
	 I return my max age which is either an integer number of seconds for which the entity can be considdered fresh, or nil, in which case other headers such as Expires can be used by a cache to determine the expiration time of the entity."

	<category: 'accessing'>
	^maxAge
    ]

    maxAge: anIntegerOrNil [
	"^self
	 I record the number of seconds for which the resource is 'fresh' and after which will expire and become 'stale' for caching purposes.  Setting this to nil means the max age is unspecified, and this is the default.  This directive takes presidence over any Expires header when a cache or client is handling an HTTP message."

	<category: 'services'>
	maxAge := anIntegerOrNil.
	^self
    ]

    private [
	"^a Boolean or nil
	 There are three possible values for private.  Explicity true (the entity can only be cached in private caches), explicity false (this is a public entity and can be held in a shared/public cache perhaps even when stale) or nil (the default which means that the entity may be held in a public shared cache, but only until it goes stale)."

	<category: 'accessing'>
	^private
    ]

    setNotPublicOrPrivate [
	"^self
	 I am being told that the entity in my message is not explicity public or private.  This is the default and means that public caches may retain copies of the resource, but should not be as relaxed about the rules as with an explicitly public resource. c.f >>setPublic & >>setPrivate."

	<category: 'services'>
	private := nil.
	^self
    ]

    setPrivate [
	"^self
	 I am being told that the entity in my message is a private one that can only be cached on private caches, i.e. caches that can be drawn upon a single clients.  An example of a private cache is the one *inside* your web browser.   This is probably what you want if the entity contains personal information."

	<category: 'services'>
	private := true.
	^self
    ]

    setPublic [
	"^self
	 I am being told that the entity in my message is a public one that can be cached on public caches, i.e. caches that can be drawn upon by many clients.  This is probably not what you want if the entity contains personal information!!  c.f. >>setPrivate  Note that expicitly setting cache-control public actually loosens some other rules and means resources can be used by cached beyond their normal life."

	<category: 'services'>
	private := false.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPut: Character space.
	self directives notNil ifTrue: [aStream nextPutAll: self directives].
	self private notNil 
	    ifTrue: 
		[self writePublicOrPrivateTo: aStream.
		self maxAge notNil ifTrue: [aStream nextPutAll: ', ']].
	self maxAge notNil ifTrue: [self writeMaxAgeTo: aStream].
	^self
    ]

    writeMaxAgeTo: aStream [
	"^self
	 I write the maxAge directive to aStream"

	<category: 'printing'>
	aStream nextPutAll: 'max-age='.
	self maxAge printOn: aStream.
	^self
    ]

    writePublicOrPrivateTo: aStream [
	"^self
	 I write the either the public or the private directive to aStream"

	<category: 'printing'>
	self private 
	    ifTrue: [aStream nextPutAll: 'private']
	    ifFalse: [aStream nextPutAll: 'public'].
	^self
    ]
]



SpecificHeaderField subclass: HTTPConnectionField [
    | connectionToken |
    
    <category: 'Swazoo-Headers'>
    <comment: 'c.f. RFC 2616 14.10

   The Connection header has the following grammar:

       Connection = "Connection" ":" 1#(connection-token)
       connection-token  = token

'>

    HTTPConnectionField class >> fieldName [
	<category: 'accessing'>
	^'Connection'
    ]

    connectionToken [
	"^a String
	 Common values are 'close' and 'keep-alive'."

	<category: 'accessing'>
	^connectionToken
    ]

    connectionToken: aString [
	"^self"

	<category: 'accessing'>
	connectionToken := aString.
	^self
    ]

    connectionTokenIsClose [
	<category: 'testing'>
	^self connectionToken = 'close'
    ]

    parseValueFrom: aString [
	<category: 'private'>
	connectionToken := HTTPString trimBlanksFrom: aString.
	^self
    ]

    setToClose [
	<category: 'services'>
	self connectionToken: 'close'.
	^self
    ]

    setToKeepAlive [
	<category: 'services'>
	self connectionToken: 'keep-alive'.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: connectionToken.
	^self
    ]
]



SpecificHeaderField subclass: HTTPContentLengthField [
    | contentLength |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPContentLengthField class >> fieldName [
	<category: 'accessing'>
	^'Content-Length'
    ]

    contentLength [
	<category: 'accessing'>
	^contentLength
    ]

    contentLength: anInteger [
	<category: 'accessing'>
	contentLength := anInteger
    ]

    parseValueFrom: aString [
	<category: 'private'>
	contentLength := aString asNumber.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self contentLength printOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPCookieField [
    | values |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPCookieField class >> fieldName [
	<category: 'accessing'>
	^'Cookie'
    ]
]



SpecificHeaderField subclass: HTTPDateField [
    | date |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPDateField class >> fieldName [
	<category: 'accessing'>
	^'Date'
    ]

    date [
	<category: 'accessing'>
	^date
    ]

    date: aDate [
	"^self
	 Note that this is an HTTP Date, and so is really a timestamp :-/"

	<category: 'accessing'>
	date := aDate.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self date asRFC1123StringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPETagField [
    | entityTag |
    
    <category: 'Swazoo-Headers'>
    <comment: 'RFC 2626 14.19 ETag

   The ETag response-header field provides the current value of the
   entity tag for the requested variant. The headers used with entity
   tags are described in sections 14.24, 14.26 and 14.44. The entity tag
   MAY be used for comparison with other entities from the same resource
   (see section 13.3.3).

      ETag = "ETag" ":" entity-tag

   Examples:

      ETag: "xyzzy"
      ETag: W/"xyzzy"
      ETag: ""

'>

    HTTPETagField class >> fieldName [
	<category: 'accessing'>
	^'ETag'
    ]

    entityTag [
	<category: 'accessing'>
	^entityTag
    ]

    entityTag: aString [
	<category: 'accessing'>
	entityTag := aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $";
	    nextPutAll: self entityTag;
	    nextPut: $".
	^self
    ]
]



SpecificHeaderField subclass: HTTPExpiresField [
    | timestamp |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPExpiresField class >> fieldName [
	<category: 'accessing'>
	^'Expires'
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    timestamp: aTimestamp [
	<category: 'accessing'>
	timestamp := aTimestamp
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self timestamp asRFC1123StringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPHostField [
    | hostName portNumber |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPHostField class >> fieldName [
	<category: 'accessing'>
	^'Host'
    ]

    hostName [
	<category: 'accessing'>
	^hostName
    ]

    parseValueFrom: aString [
	<category: 'private'>
	| sourceStream portNumberString |
	sourceStream := ReadStream on: aString.
	hostName := sourceStream upTo: $:.
	portNumberString := sourceStream atEnd 
		    ifTrue: [String new]
		    ifFalse: [sourceStream upToEnd].
	portNumberString notEmpty 
	    ifTrue: [portNumber := portNumberString asNumber].
	^self
    ]

    portNumber [
	<category: 'accessing'>
	^portNumber isNil ifTrue: [80] ifFalse: [portNumber]
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self hostName.
	portNumber notNil 
	    ifTrue: 
		[aStream nextPut: $:.
		self portNumber printOn: aStream].
	^self
    ]
]



SpecificHeaderField subclass: HTTPIfModifiedSinceField [
    | date |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPIfModifiedSinceField class >> fieldName [
	<category: 'accessing'>
	^'If-Modified-Since'
    ]

    date [
	<category: 'accessing'>
	^date
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.  So in my case, I'm looking to see that the entity has not changed since my date.
	 anEntity *must* respond to >>lastModified"

	<category: 'testing'>
	^anEntity lastModified <= self date
    ]

    isConditional [
	<category: 'testing'>
	^true
    ]

    parseValueFrom: aString [
	<category: 'private'>
	date := SpTimestamp fromRFC1123String: aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self date notNil ifTrue: [self date asRFC1123StringOn: aStream].
	^self
    ]
]



SpecificHeaderField subclass: HTTPIfRangeField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPIfRangeField class >> fieldName [
	<category: 'accessing'>
	^'If-Range'
    ]
]



SpecificHeaderField subclass: HTTPIfUnmodifiedSinceField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPIfUnmodifiedSinceField class >> fieldName [
	<category: 'accessing'>
	^'If-Unmodified-Since'
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.
	 anEntity *must* respond to >>entutyTag"

	<category: 'testing'>
	1 halt.
	^self
    ]

    isConditional [
	<category: 'testing'>
	^true
    ]
]



SpecificHeaderField subclass: HTTPLastModifiedField [
    | timestamp |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPLastModifiedField class >> fieldName [
	<category: 'accessing'>
	^'Last-Modified'
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    timestamp: aTimestamp [
	<category: 'accessing'>
	timestamp := aTimestamp
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self timestamp asRFC1123StringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPLocationField [
    | uri |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPLocationField class >> fieldName [
	<category: 'accessing'>
	^'Location'
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]

    uri: aSwazooURI [
	<category: 'accessing'>
	uri := aSwazooURI.
	^self
    ]

    uriString: aString [
	<category: 'accessing'>
	uri := SwazooURI fromString: aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self uri printOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPMatchField [
    | entityTags |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    addEntityTag: aString [
	<category: 'services'>
	self entityTags add: aString.
	^self
    ]

    combineWith: aHeaderField [
	"^self
	 I add the entity tags of aHeaderField to my own collection of entity tags."

	<category: 'services'>
	self entityTags addAll: aHeaderField entityTags.
	^self
    ]

    entityTags [
	<category: 'accessing'>
	^self matchesAnyCurrentEntity 
	    ifTrue: [nil]
	    ifFalse: 
		[entityTags isNil ifTrue: [entityTags := OrderedCollection new].
		entityTags]
    ]

    isConditional [
	<category: 'testing'>
	^true
    ]

    matchesAnyCurrentEntity [
	<category: 'testing'>
	^entityTags = '*'
    ]

    parseValueFrom: aString [
	<category: 'private'>
	aString = '*' 
	    ifTrue: [entityTags := aString]
	    ifFalse: 
		[| sourceStream |
		entityTags := OrderedCollection new.
		sourceStream := ReadStream on: aString.
		[sourceStream atEnd] whileFalse: 
			[| entityTag |
			sourceStream upTo: $".
			entityTag := sourceStream upTo: $".
			entityTags add: entityTag.
			sourceStream upTo: $,]].
	^self
    ]

    valuesAsStringOn: targetStream [
	<category: 'printing'>
	self write: self entityTags first asQuotedStringTo: targetStream.
	2 to: self entityTags size
	    do: 
		[:tagIndex | 
		targetStream nextPut: $,.
		self write: (self entityTags at: tagIndex) asQuotedStringTo: targetStream].
	^self
    ]

    write: aString asQuotedStringTo: targetStream [
	"^self
	 See RFC 2616 2.2"

	<category: 'printing'>
	targetStream nextPut: $".
	aString do: 
		[:character | 
		character == $" 
		    ifTrue: [targetStream nextPutAll: '\"']
		    ifFalse: [targetStream nextPut: character]].
	targetStream nextPut: $".
	^self
    ]
]



HTTPMatchField subclass: HTTPIfMatchField [
    
    <category: 'Swazoo-Headers'>
    <comment: 'From RFC 2616

14.24 If-Match

   The If-Match request-header field is used with a method to make it
   conditional. A client that has one or more entities previously
   obtained from the resource can verify that one of those entities is
   current by including a list of their associated entity tags in the
   If-Match header field. Entity tags are defined in section 3.11. The
   purpose of this feature is to allow efficient updates of cached
   information with a minimum amount of transaction overhead. It is also
   used, on updating requests, to prevent inadvertent modification of
   the wrong version of a resource. As a special case, the value "*"
   matches any current entity of the resource.

       If-Match = "If-Match" ":" ( "*" | 1#entity-tag )

   If any of the entity tags match the entity tag of the entity that
   would have been returned in the response to a similar GET request
   (without the If-Match header) on that resource, or if "*" is given

   and any current entity exists for that resource, then the server MAY
   perform the requested method as if the If-Match header field did not
   exist.

   A server MUST use the strong comparison function (see section 13.3.3)
   to compare the entity tags in If-Match.

   If none of the entity tags match, or if "*" is given and no current
   entity exists, the server MUST NOT perform the requested method, and
   MUST return a 412 (Precondition Failed) response. This behavior is
   most useful when the client wants to prevent an updating method, such
   as PUT, from modifying a resource that has changed since the client
   last retrieved it.

   If the request would, without the If-Match header field, result in
   anything other than a 2xx or 412 status, then the If-Match header
   MUST be ignored.

   The meaning of "If-Match: *" is that the method SHOULD be performed
   if the representation selected by the origin server (or by a cache,
   possibly using the Vary mechanism, see section 14.44) exists, and
   MUST NOT be performed if the representation does not exist.

   A request intended to update a resource (e.g., a PUT) MAY include an
   If-Match header field to signal that the request method MUST NOT be
   applied if the entity corresponding to the If-Match value (a single
   entity tag) is no longer a representation of that resource. This
   allows the user to indicate that they do not wish the request to be
   successful if the resource has been changed without their knowledge.
   Examples:

       If-Match: "xyzzy"
       If-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"
       If-Match: *

   The result of a request having both an If-Match header field and
   either an If-None-Match or an If-Modified-Since header fields is
   undefined by this specification.

'>

    HTTPIfMatchField class >> fieldName [
	<category: 'accessing'>
	^'If-Match'
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.
	 anEntity *must* respond to >>entutyTag"

	<category: 'testing'>
	1 halt.
	^self
    ]
]



HTTPMatchField subclass: HTTPIfNoneMatchField [
    
    <category: 'Swazoo-Headers'>
    <comment: 'This is a confitional header field.  The HTTP client is asking for a resource on the basis of this condition.  So, we need to have first found the resource, and then we can considder the condition, as follows ...

From RFC 2616:

14.26 If-None-Match

   The If-None-Match request-header field is used with a method to make
   it conditional. A client that has one or more entities previously
   obtained from the resource can verify that none of those entities is
   current by including a list of their associated entity tags in the
   If-None-Match header field. The purpose of this feature is to allow
   efficient updates of cached information with a minimum amount of
   transaction overhead. It is also used to prevent a method (e.g. PUT)
   from inadvertently modifying an existing resource when the client
   believes that the resource does not exist.

   As a special case, the value "*" matches any current entity of the
   resource.

       If-None-Match = "If-None-Match" ":" ( "*" | 1#entity-tag )

   If any of the entity tags match the entity tag of the entity that
   would have been returned in the response to a similar GET request
   (without the If-None-Match header) on that resource, or if "*" is
   given and any current entity exists for that resource, then the
   server MUST NOT perform the requested method, unless required to do
   so because the resource''s modification date fails to match that
   supplied in an If-Modified-Since header field in the request.
   Instead, if the request method was GET or HEAD, the server SHOULD
   respond with a 304 (Not Modified) response, including the cache-
   related header fields (particularly ETag) of one of the entities that
   matched. For all other request methods, the server MUST respond with
   a status of 412 (Precondition Failed).

   See section 13.3.3 for rules on how to determine if two entities tags
   match. The weak comparison function can only be used with GET or HEAD
   requests.

   If none of the entity tags match, then the server MAY perform the
   requested method as if the If-None-Match header field did not exist,
   but MUST also ignore any If-Modified-Since header field(s) in the
   request. That is, if no entity tags match, then the server MUST NOT
   return a 304 (Not Modified) response.

   If the request would, without the If-None-Match header field, result
   in anything other than a 2xx or 304 status, then the If-None-Match
   header MUST be ignored. (See section 13.3.4 for a discussion of
   server behavior when both If-Modified-Since and If-None-Match appear
   in the same request.)

   The meaning of "If-None-Match: *" is that the method MUST NOT be
   performed if the representation selected by the origin server (or by
   a cache, possibly using the Vary mechanism, see section 14.44)
   exists, and SHOULD be performed if the representation does not exist.
   This feature is intended to be useful in preventing races between PUT
   operations.

   Examples:

       If-None-Match: "xyzzy"
       If-None-Match: W/"xyzzy"
       If-None-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"
       If-None-Match: W/"xyzzy", W/"r2d2xxxx", W/"c3piozzzz"
       If-None-Match: *

   The result of a request having both an If-None-Match header field and
   either an If-Match or an If-Unmodified-Since header fields is
   undefined by this specification.'>

    HTTPIfNoneMatchField class >> fieldName [
	<category: 'accessing'>
	^'If-None-Match'
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.  So in my case, I'm looking to see that the entity has a tag which is in my collection of entityTags.
	 anEntity *must* respond to >>entityTag"

	<category: 'testing'>
	^self entityTags includes: anEntity entityTag
    ]
]



SpecificHeaderField subclass: HTTPRefererField [
    | uri |
    
    <category: 'Swazoo-Headers'>
    <comment: 'RFC 2616: 14.36 Referer

   The Referer[sic] request-header field allows the client to specify,
   for the server''s benefit, the address (URI) of the resource from
   which the Request-URI was obtained (the "referrer", although the
   header field is misspelled.) The Referer request-header allows a
   server to generate lists of back-links to resources for interest,
   logging, optimized caching, etc. It also allows obsolete or mistyped
   links to be traced for maintenance. The Referer field MUST NOT be
   sent if the Request-URI was obtained from a source that does not have
   its own URI, such as input from the user keyboard.

       Referer        = "Referer" ":" ( absoluteURI | relativeURI )

   Example:

       Referer: http://www.w3.org/hypertext/DataSources/Overview.html

   If the field value is a relative URI, it SHOULD be interpreted
   relative to the Request-URI. The URI MUST NOT include a fragment. See
   section 15.1.3 for security considerations.

'>

    HTTPRefererField class >> fieldName [
	<category: 'accessing'>
	^'Referer'
    ]

    parseValueFrom: aString [
	<category: 'private'>
	uri := SwazooURI fromString: aString.
	^self
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self uri printOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPServerField [
    | productTokens |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPServerField class >> fieldName [
	<category: 'accessing'>
	^'Server'
    ]

    productTokens [
	<category: 'accessing'>
	^productTokens
    ]

    productTokens: aString [
	<category: 'accessing'>
	productTokens := aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self productTokens.
	^self
    ]
]



SpecificHeaderField subclass: HTTPSetCookieField [
    | cookies |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPSetCookieField class >> fieldName [
	<category: 'accessing'>
	^'Set-Cookie'
    ]

    addCookie: aCookieString [
	<category: 'services'>
	^self cookies add: aCookieString
    ]

    combineWith: aSetCookieField [
	"^self
	 I add the cookies of aSetCookieField to my own collection of cookies."

	<category: 'services'>
	self cookies addAll: aSetCookieField cookies.
	^self
    ]

    cookies [
	<category: 'accessing'>
	cookies isNil ifTrue: [cookies := OrderedCollection new].
	^cookies
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: (self cookies at: 1).
	2 to: self cookies size
	    do: 
		[:cookieIndex | 
		aStream
		    nextPutAll: ', ';
		    nextPutAll: (self cookies at: cookieIndex)].
	^self
    ]
]



SpecificHeaderField subclass: HTTPUserAgentField [
    | productTokens |
    
    <category: 'Swazoo-Headers'>
    <comment: 'RFC 2616: 14.43 User-Agent

   The User-Agent request-header field contains information about the
   user agent originating the request. This is for statistical purposes,
   the tracing of protocol violations, and automated recognition of user
   agents for the sake of tailoring responses to avoid particular user
   agent limitations. User agents SHOULD include this field with
   requests. The field can contain multiple product tokens (section 3.8)
   and comments identifying the agent and any subproducts which form a
   significant part of the user agent. By convention, the product tokens
   are listed in order of their significance for identifying the
   application.

       User-Agent     = "User-Agent" ":" 1*( product | comment )

   Example:

       User-Agent: CERN-LineMode/2.15 libwww/2.17b3'>

    HTTPUserAgentField class >> fieldName [
	<category: 'accessing'>
	^'User-Agent'
    ]

    parseValueFrom: aString [
	"^self
	 I could try and parse out the product name and version numbers, but there is no need to worry about this at the moment, so I just record the string."

	<category: 'private'>
	productTokens := HTTPString trimBlanksFrom: aString.
	^self
    ]

    productTokens [
	<category: 'accessing'>
	^productTokens
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: productTokens.
	^self
    ]
]



SpecificHeaderField subclass: HTTPWWWAuthenticateField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPWWWAuthenticateField class >> fieldName [
	<category: 'accessing'>
	^'WWW-Authenticate'
    ]

    isBasic [
	"^a Boolean
	 I return true if I represent a header for basic authentication. c.f. RFC 2617 sec 2."

	<category: 'testing'>
	^false
    ]

    isDigest [
	"^a Boolean
	 I return true if I represent a header for digest authentication. c.f. RFC 2617 sec 3."

	<category: 'testing'>
	^false
    ]
]



HTTPWWWAuthenticateField subclass: HTTPWWWAuthenticateBasicField [
    | realm |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    isBasic [
	"^a Boolean
	 I return true if I represent a header for basic authentication. c.f. RFC 2617 sec 2."

	<category: 'testing'>
	^true
    ]

    realm [
	"^a String
	 I return the realm for which I represent an autentication challenge.  This string will be presented to the browser user in the login dialog."

	<category: 'accessing'>
	^realm
    ]

    realm: anObject [
	<category: 'accessing'>
	realm := anObject
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'Basic realm="';
	    nextPutAll: self realm;
	    nextPut: $".
	^self
    ]
]



HTTPWWWAuthenticateField subclass: HTTPWWWAuthenticateDigestField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    isDigest [
	"^a Boolean
	 I return true if I represent a header for digest authentication. c.f. RFC 2617 sec 3."

	<category: 'testing'>
	^true
    ]
]



