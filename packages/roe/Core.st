"=====================================================================
|
|   ROE core
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

Collection subclass: RAMappedCollection [
    | relation |
    
    <category: 'Roe-Mapping'>
    <comment: nil>

    RAMappedCollection class >> on: aRelation [
	^self new initializeWithRelation: aRelation
    ]

    do: aBlock [
	relation do: [:tuple | aBlock value: (self objectsForTuple: tuple)]
    ]

    initializeWithRelation: aRelation [
	relation := aRelation
    ]

    objectForTuple: anArray relation: aRelation attributes: attributeCollection [
	^aRelation objectForValues: (self valuesForTuple: anArray
		    attributes: attributeCollection)
    ]

    objectsForTuple: anArray [
	^relation attributesGroupedByOriginalRelation collect: 
		[:relationToAttributes | 
		self 
		    objectForTuple: anArray
		    relation: relationToAttributes key
		    attributes: relationToAttributes value]
    ]

    valueForAttribute: anAttribute fromTuple: anArray [
	^anArray at: (relation attributes indexOf: anAttribute)
    ]

    valuesForTuple: aTuple attributes: attributeCollection [
	^Dictionary from: (attributeCollection 
		    collect: [:attr | attr -> (aTuple valueForAttribute: attr)])
    ]
]



RAMappedCollection subclass: RASingleMappedCollection [
    
    <category: 'Roe-Mapping'>
    <comment: nil>

    do: aBlock [
	super do: [:ea | aBlock value: ea first]
    ]
]



Collection subclass: RARelation [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    isMutable [
        <category: 'testing'>
	^true
    ]
    
    * aRelation [
	<category: 'core operators'>
	^RACartesianProduct of: self with: aRelation
    ]

    , aRelation [
	<category: 'core operators'>
	^self union: aRelation
    ]

    - aRelation [
	<category: 'core operators'>
	^self difference: aRelation
    ]

    = other [
	"pretty hackish"

	<category: 'comparing'>
	^self printString = other printString
    ]

    >> aSymbol [
	<category: 'convenience'>
	^self attributeNamed: aSymbol
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitRelation: self
    ]

    asAlgebraicString [
	<category: 'converting'>
	^String 
	    streamContents: [:stream | (RAAlgebraicPrinter on: stream for: self) visit: self]
    ]

    asArray [
	<category: 'converting'>
	^((OrderedCollection new)
	    addAll: self;
	    yourself) asArray
    ]

    asMappedCollection [
	<category: 'converting'>
	^RAMappedCollection on: self
    ]

    asSingleMappedCollection [
	<category: 'converting'>
	^RASingleMappedCollection on: self
    ]

    attributeNamed: aString [
	<category: 'accessing'>
	^self attributeNamed: aString
	    ifAbsent: [self couldNotFindAttributeError: aString]
    ]

    attributeNamed: aString ifAbsent: errorBlock [
	<category: 'accessing'>
	| attribute |
	attribute := nil.
	self attributes do: 
		[:ea | 
		ea name asString = aString asString 
		    ifTrue: 
			[attribute ifNil: [attribute := ea]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: aString]]].
	^attribute ifNotNil: [:foo | attribute] ifNil: errorBlock
    ]

    attributes [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^Array with: self -> self attributes
    ]

    clone [
	<category: 'core operators'>
	^RAClone of: self
    ]

    concreteRelation [
	<category: 'private'>
	self subclassResponsibility
    ]

    copyFrom: start to: stop [
	<category: 'core operators'>
	^self from: start to: stop
    ]

    couldNotFindAttributeError: aString [
	<category: 'private'>
	self error: 'Could not find attribute named ' , aString printString
    ]

    delete [
	<category: 'removing'>
	self concreteRelation deleteFor: self
    ]

    difference: aRelation [
	<category: 'core operators'>
	^RADifference of: self with: aRelation
    ]

    distinct [
	<category: 'core operators'>
	^RADistinct source: self
    ]

    do: aBlock [
	<category: 'enumerating'>
	self concreteRelation for: self do: aBlock
    ]

    from: start to: stop [
	<category: 'core operators'>
	^RARange 
	    of: self
	    from: start
	    to: stop
    ]

    groupBy: aString [
	<category: 'core operators'>
	^self groupByAll: (Array with: aString)
    ]

    groupByAll: attributeNames [
	<category: 'core operators'>
	^RAGrouping of: self by: attributeNames
    ]

    hash [
	<category: 'comparing'>
	^self printString hash
    ]

    indexBy: attributeName [
	<category: 'core operators'>
	^RAIndexWrapper on: self key: attributeName
    ]

    intersection: aRelation [
	<category: 'core operators'>
	^RAIntersection of: self with: aRelation
    ]

    keyBy: attributeName [
	<category: 'core operators'>
	^RAIndexWrapper on: self uniqueKey: attributeName
    ]

    orderBy: aString [
	<category: 'core operators'>
	^self orderByAll: (Array with: aString)
    ]

    orderBy: aString ascending: aBoolean [
	<category: 'core operators'>
	^self orderByAll: (Array with: aString) ascending: (Array with: aBoolean)
    ]

    orderByAll: attributeNames [
	<category: 'core operators'>
	| ascending |
	ascending := Array new: attributeNames size withAll: true.
	^self orderByAll: attributeNames ascending: ascending
    ]

    orderByAll: attributeNames ascending: booleanArray [
	<category: 'core operators'>
	^RAOrdering 
	    of: self
	    order: attributeNames
	    ascending: booleanArray
    ]

    project: aString [
	<category: 'core operators'>
	^self projectAll: (Array with: aString)
    ]

    projectAll: attributeNames [
	<category: 'core operators'>
	^RAProjection of: self into: attributeNames
    ]

    rename: oldName to: newName [
	<category: 'core operators'>
	^self renameAll: (Array with: oldName) to: (Array with: newName)
    ]

    renameAll: oldNameArray to: newNameArray [
	<category: 'core operators'>
	^RAAlias 
	    of: self
	    from: oldNameArray
	    to: newNameArray
    ]

    select: aBlock [
	<category: 'core operators'>
	^RASelection from: self where: aBlock
    ]

    species [
	<category: 'private'>
	^OrderedCollection
    ]

    union: aRelation [
	<category: 'core operators'>
	^RAUnion of: self with: aRelation
    ]

    update: aBlock [
	<category: 'updating'>
	self concreteRelation for: self update: aBlock
    ]

    where: attributeName equals: anObject [
	<category: 'convenience'>
	| attr |
	attr := self attributeNamed: attributeName.
	^self 
	    select: [:ea | (ea valueForAttribute: attr) = anObject]
    ]

    whereEqual: attributePair [
	<category: 'convenience'>
	^self select: 
		[:ea | 
		(ea valueForAttributeNamed: attributePair first) 
		    = (ea valueForAttributeNamed: attributePair last)]
    ]

    print: anObject on: aStream [
	<category: 'printing'>
	anObject printOn: aStream
    ]
]



RARelation subclass: RABinaryTransformation [
    | left right |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RABinaryTransformation class >> of: leftRelation with: rightRelation [
	^self new setLeftRelation: leftRelation rightRelation: rightRelation
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^left attributesGroupedByOriginalRelation 
	    , right attributesGroupedByOriginalRelation
    ]

    concreteRelation [
	<category: 'private'>
	^left concreteRelation
    ]

    isMutable [
	<category: 'testing'>
	^left isMutable and: [ right isMutable ]
    ]

    left [
	<category: 'accessing'>
	^left
    ]

    printOn: aStream [
	<category: 'printing'>
	(RAAlgebraicPrinter on: aStream) visit: self
    ]

    right [
	<category: 'accessing'>
	^right
    ]

    setLeftRelation: leftRelation rightRelation: rightRelation [
	<category: 'initialization'>
	left := leftRelation.
	right := rightRelation
    ]
]



RABinaryTransformation subclass: RACartesianProduct [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    isMutable [
        <category: 'testing'>
	^false
    ]
    
    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitCartesianProduct: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes , right attributes
    ]
]



RABinaryTransformation subclass: RADifference [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitDifference: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes
    ]
]



RABinaryTransformation subclass: RAIntersection [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitIntersection: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes
    ]
]



RABinaryTransformation subclass: RAUnion [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitUnion: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes
    ]
]



RARelation subclass: RAConcreteRelation [
    | name attributes |
    
    <category: 'Roe-Relations-Concrete'>
    <comment: nil>

    RAConcreteRelation class >> factory: aFactory name: aString [
	<category: 'instance creation'>
	^(self new)
	    factory: aFactory;
	    name: aString;
	    yourself
    ]

    addAllValues: anArray [
	<category: 'adding'>
	anArray do: [:row | self addValues: row]
    ]

    addValues: anArray [
	<category: 'adding'>
	self subclassResponsibility
    ]

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    concreteRelation [
	<category: 'private'>
	^self
    ]

    for: aRelation do: aBlock [
	<category: 'private'>
	self subclassResponsibility
    ]

    for: aRelation update: aBlock [
	<category: 'updating'>
	self subclassResponsibility
    ]

    initializeWithName: aString [
	<category: 'initializing'>
	name := aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPut: $(;
	    nextPutAll: self name;
	    nextPut: $)
    ]
]



RARelation subclass: RAIndexedRelation [
    
    <category: 'Roe-Relations-Indexed'>
    <comment: nil>

    at: anObject [
	| relation |
	relation := self where: self keyName equals: anObject.
	self keyIsUnique 
	    ifFalse: [^relation]
	    ifTrue: [relation do: [:tuple | ^tuple]].
	self error: 'No value for key ' , anObject printString
    ]

    keyAttribute [
	^self attributeNamed: self keyName
    ]

    keyIsUnique [
	self subclassResponsibility
    ]

    keyName [
	self subclassResponsibility
    ]
]



RAIndexedRelation subclass: RAIndexWrapper [
    | source key unique |
    
    <category: 'Roe-Relations-Indexed'>
    <comment: nil>

    RAIndexWrapper class >> on: aRelation key: anAttribute [
	^self new 
	    setRelation: aRelation
	    key: anAttribute
	    unique: false
    ]

    RAIndexWrapper class >> on: aRelation uniqueKey: anAttribute [
	^self new 
	    setRelation: aRelation
	    key: anAttribute
	    unique: true
    ]

    acceptRoeVisitor: aVisitor [
	^aVisitor visitTransformation: self
    ]

    attributes [
	^source attributes
    ]

    concreteRelation [
	^source concreteRelation
    ]

    keyIsUnique [
	^unique
    ]

    keyName [
	^key
    ]

    isMutable [
	<category: 'testing'>
	^source isMutable
    ]

    printOn: aStream [
	source printOn: aStream
    ]

    setRelation: aRelation key: aString unique: aBoolean [
	source := aRelation.
	key := aString.
	unique := aBoolean
    ]

    source [
	^source
    ]
]



RARelation subclass: RATransformation [
    | source |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitTransformation: self
    ]

    attributes [
	<category: 'accessing'>
	^source attributes
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^source attributesGroupedByOriginalRelation
    ]

    concreteRelation [
	<category: 'private'>
	^source concreteRelation
    ]

    isMutable [
	<category: 'testing'>
	^source isMutable
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self asAlgebraicString
    ]

    source [
	<category: 'accessing'>
	^source
    ]
]



RATransformation subclass: RAAlias [
    | attributes |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAAlias class >> of: aRelation from: attributeRefs to: nameArray [
	^self new 
	    setRelation: aRelation
	    attributes: attributeRefs
	    newNames: nameArray
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitAlias: self
    ]

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^source attributesGroupedByOriginalRelation collect: 
		[:assoc | 
		assoc key 
		    -> (assoc value collect: 
				[:attr | 
				attributes 
				    detect: [:ea | (ea respondsTo: #source) and: [ea source = attr]]
				    ifNone: [attr]])]
    ]

    setRelation: aRelation attributes: attributeRefs newNames: newNames [
	<category: 'initializing'>
	source := aRelation.
	attributes := source attributes copy.
	attributeRefs with: newNames
	    do: 
		[:ref :new | 
		| attr |
		attr := ref resolveAttributeIn: attributes.
		attributes replaceAll: attr
		    with: (RAAliasedAttribute attribute: attr name: new)]
    ]
]



RATransformation subclass: RAClone [
    | attributes |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAClone class >> of: aRelation [
	^self basicNew setRelation: aRelation
    ]

    acceptRoeVisitor: aVisitor [
	^aVisitor visitClone: self
    ]

    attributes [
	^attributes
    ]

    setRelation: aRelation [
	source := aRelation.
	attributes := source attributes 
		    collect: [:ea | RAClonedAttribute attribute: ea]
    ]
]



RATransformation subclass: RADistinct [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RADistinct class >> source: aRelation [
	^self basicNew setSource: aRelation
    ]

    isMutable [
        <category: 'testing'>
	^false
    ]
    
    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitDistinct: self
    ]

    setSource: aRelation [
	<category: 'visiting'>
	source := aRelation
    ]
]



RATransformation subclass: RAGrouping [
    | group |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAGrouping class >> of: aSource by: attributeRefs [
	<category: 'instance creation'>
	^self basicNew setSource: aSource groupAttributes: attributeRefs
    ]

    isMutable [
        <category: 'testing'>
	^false
    ]
    
    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitGroup: self
    ]

    group [
	<category: 'accessing'>
	^group
    ]

    setSource: aRelation groupAttributes: attributeRefs [
	<category: 'initializing'>
	source := aRelation.
	group := attributeRefs 
		    collect: [:ea | ea resolveAttributeIn: source attributes]
    ]
]



RATransformation subclass: RAOrdering [
    | order ascending |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAOrdering class >> of: aRelation order: attributeRefs ascending: booleanArray [
	<category: 'instance creation'>
	^self basicNew 
	    setSource: aRelation
	    orderAttributes: attributeRefs
	    ascending: booleanArray
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitOrder: self
    ]

    ascending [
	<category: 'accessing'>
	^ascending
    ]

    order [
	<category: 'accessing'>
	^order
    ]

    setSource: aRelation orderAttributes: attributeRefs ascending: booleanArray [
	<category: 'initialization'>
	source := aRelation.
	order := attributeRefs 
		    collect: [:ea | ea resolveAttributeIn: source attributes].
	ascending := booleanArray
    ]
]



RATransformation subclass: RAProjection [
    | attributes |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAProjection class >> of: aRelation into: attributeRefs [
	^self new setRelation: aRelation attributes: attributeRefs
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitProjection: self
    ]

    attributes [
	<category: 'visiting'>
	^attributes
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^source attributesGroupedByOriginalRelation 
	    collect: [:assoc | assoc key -> (assoc value select: [:ea | attributes includes: ea])]
	    thenSelect: [:assoc | assoc value isEmpty not]
    ]

    setRelation: aRelation attributes: attributeRefs [
	<category: 'initializing'>
	source := aRelation.
	attributes := attributeRefs 
		    collect: [:ea | ea resolveAttributeIn: source attributes]
    ]
]



RATransformation subclass: RARange [
    | offset limit |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RARange class >> of: aSource from: min to: max [
	<category: 'instance creation'>
	^self basicNew setSource: aSource from: min to: max
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitInterval: self
    ]

    limit [
	<category: 'accessing-interval'>
	^limit
    ]

    offset [
	<category: 'accessing-interval'>
	^offset
    ]

    setSource: aRelation from: start to: stop [
	<category: 'initializing'>
	source := aRelation.
	offset := start - 1.
        limit := stop - start + 1
    ]

    start [
	<category: 'accessing-interval'>
	^offset + 1
    ]

    stop [
	<category: 'accessing-interval'>
	^offset + limit
    ]
]



RATransformation subclass: RASelection [
    | condition |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RASelection class >> from: aRelation where: aBlock [
	^self new setRelation: aRelation condition: aBlock
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitSelection: self
    ]

    evaluateTuple: anArray [
	<category: 'evaluating'>
	^condition value: anArray
    ]

    setRelation: aRelation condition: aBlock [
	<category: 'initializing'>
	source := aRelation.
	condition := aBlock
    ]
]




DateTime extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitDateAndTime: self
    ]

]



Object extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitObject: self
    ]

]



Object subclass: RAAttribute [
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RAAttribute class >> errorCouldNotResolveAttribute [
	<category: 'private'>
	self error: 'could not resolve attribute'
    ]

    RAAttribute class >> ambiguousAttributeError: aString [
	<category: 'private'>
	self error: 'More than one attribute named ' , aString printString
    ]

    name [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    originalAttribute [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    originalRelation [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPutAll: '(' , self name , ')'
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	self subclassResponsibility
    ]
]



RAAttribute subclass: RAAliasedAttribute [
    | source name |
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RAAliasedAttribute class >> attribute: anAttribute name: aString [
	<category: 'instance creation'>
	^self new setAttribute: anAttribute name: aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    originalAttribute [
	<category: 'accessing'>
	^source originalAttribute
    ]

    originalRelation [
	<category: 'accessing'>
	^source originalRelation
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	| attribute |
	aCollection do: 
		[:ea | 
		self = ea
		    ifTrue: 
			[attribute ifNil: [attribute := self]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self name]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

    setAttribute: anAttribute name: aString [
	<category: 'private'>
	source := anAttribute.
	name := aString asString
    ]

    source [
	<category: 'accessing'>
	^source
    ]
]



RAAttribute subclass: RAClonedAttribute [
    | source |
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RAClonedAttribute class >> attribute: anAttribute [
	^self new setAttribute: anAttribute
    ]

    name [
	^source name
    ]

    originalAttribute [
	^source originalAttribute
    ]

    originalRelation [
	^source originalRelation
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	| attribute |
	aCollection do: 
		[:ea | 
		self = ea
		    ifTrue: 
			[attribute ifNil: [attribute := self]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self name]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

    setAttribute: anAttribute [
	source := anAttribute
    ]
]



RAAttribute subclass: RASimpleAttribute [
    | relation name |
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RASimpleAttribute class >> named: aString relation: aRelation [
	<category: 'instance creation'>
	^self new setName: aString relation: aRelation
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    originalAttribute [
	<category: 'accessing'>
	^self
    ]

    originalRelation [
	<category: 'accessing'>
	^relation
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	| attribute |
	aCollection do: 
		[:ea | 
		self = ea
		    ifTrue: 
			[attribute ifNil: [attribute := self]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self name]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

    setName: aString relation: aRelation [
	<category: 'private'>
	name := aString asString.
	relation := aRelation
    ]
]



Object subclass: RAConditionNode [
    
    <category: 'Roe-Conditions'>
    <comment: nil>

    & other [
	<category: 'logical'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #&
    ]

    * other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #*
    ]

    + other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #+
    ]

    - other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #-
    ]

    / other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #/
    ]

    < other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #<
    ]

    <= other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #<=
    ]

    = other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #=
    ]

    > other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #>
    ]

    >= other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #>=
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	self subclassResponsibility
    ]

    asString [
	<category: 'converting'>
	^self
    ]

    like: aString [
	<category: 'comparing'>
	^self like: aString ignoreCase: false
    ]

    like: aString ignoreCase: aBoolean [
	<category: 'comparing'>
	^aBoolean 
	    ifFalse: 
		[RABinaryNode 
		    left: self
		    right: aString
		    operator: #like]
	    ifTrue: 
		[RABinaryNode 
		    left: self
		    right: aString
		    operator: #ilike]
    ]

    | other [
	<category: 'logical'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #|
    ]

    ~= other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #~=
    ]
]



RAConditionNode subclass: RAAttributeNode [
    | attribute |
    
    <category: 'Roe-Conditions'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitAttributeNode: self
    ]

    attribute [
	<category: 'private'>
	^attribute
    ]

    attribute: anAttribute [
	<category: 'private'>
	attribute := anAttribute
    ]

    name [
	<category: 'accessing'>
	^attribute name
    ]
]



RAConditionNode subclass: RABinaryNode [
    | left right operator |
    
    <category: 'Roe-Conditions'>
    <comment: nil>

    RABinaryNode class >> left: leftNode right: rightNode operator: aSymbol [
	^self new 
	    setLeft: leftNode
	    right: rightNode
	    operator: aSymbol
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitBinaryNode: self
    ]

    left [
	<category: 'accessing'>
	^left
    ]

    operator [
	<category: 'accessing'>
	^operator
    ]

    right [
	<category: 'accessing'>
	^right
    ]

    setLeft: aNode right: otherNode operator: aSymbol [
	<category: 'private'>
	left := aNode.
	right := otherNode.
	operator := aSymbol
    ]

    sqlOperator [
	<category: 'accessing'>
	right isNil 
	    ifTrue: 
		[operator = #= ifTrue: [^' IS '].
		operator = #~= ifTrue: [^' IS NOT ']].
	operator = #& ifTrue: [^' AND '].
	operator = #| ifTrue: [^' OR '].
	operator = #~= ifTrue: [^' != '].
	operator = #like ifTrue: [^' LIKE '].
	operator = #ilike ifTrue: [^' ILIKE '].
	^operator
    ]
]



Object subclass: RATuple [
    | relation |
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    RATuple class >> relation: aRelation [
	^self basicNew initializeWithRelation: aRelation
    ]

    at: anObject [
	^self 
	    valueForAttribute: (anObject resolveAttributeIn: relation attributes)
    ]

    doesNotUnderstand: aMessage [
	| selector |
	selector := aMessage selector.
	(selector numArgs = 0 and: [self hasAttributeNamed: selector asString]) 
	    ifTrue: [^self valueForAttributeNamed: selector].
	((selector numArgs = 1 and: [self hasAttributeNamed: selector allButLast]) 
	    and: [self isMutable]) 
		ifTrue: 
		    [^self takeValue: aMessage argument forAttributeNamed: selector allButLast].
	^super doesNotUnderstand: aMessage
    ]

    hasAttributeNamed: aString [
	| s |
	s := aString asString.
	^relation attributes anySatisfy: [:ea | ea name = s]
    ]

    initializeWithRelation: aRelation [
	relation := aRelation
    ]

    isMutable [
	^false
    ]

    name [
	^self valueForAttributeNamed: #name ifAbsent: [super name]
    ]

    takeValue: anObject forAttribute: anAttribute [
	self isMutable 
	    ifTrue: [self subclassResponsibility]
	    ifFalse: [self shouldNotImplement]
    ]

    takeValue: anObject forAttributeNamed: aString [
	self takeValue: anObject forAttribute: (relation attributeNamed: aString)
    ]

    valueForAttribute: anAttribute [
	^self subclassResponsibility
    ]

    valueForAttributeNamed: aString [
	^self valueForAttribute: (relation attributeNamed: aString)
    ]

    valueForAttributeNamed: aString ifAbsent: errorBlock [
	^self valueForAttribute: (relation attributeNamed: aString
		    ifAbsent: [^errorBlock value])
    ]
]



RATuple subclass: RASelectTuple [
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    valueForAttribute: anAttribute [
	^RAAttributeNode new attribute: anAttribute
    ]
]



RATuple subclass: RASimpleTuple [
    | values |
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    RASimpleTuple class >> relation: aRelation values: anArray [
	^self basicNew initializeWithRelation: aRelation values: anArray
    ]

    initializeWithRelation: aRelation [
	<category: 'initializing'>
	self initializeWithRelation: aRelation
	    values: (Array new: aRelation attributes size)
    ]

    initializeWithRelation: aRelation values: anArray [
	<category: 'initializing'>
	super initializeWithRelation: aRelation.
	values := anArray
    ]

    valueForAttribute: anAttribute [
	<category: 'accessing'>
	^values at: (relation attributes indexOf: anAttribute)
    ]

    values [
	<category: 'accessing'>
	^values
    ]
]



RATuple subclass: RAUpdateTuple [
    | nodes |
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    isMutable [
	^true
    ]

    nodes [
	^nodes ifNil: [nodes := Dictionary new]
    ]

    takeValue: anObject forAttribute: anAttribute [
	self nodes at: anAttribute put: anObject
    ]

    valueForAttribute: anAttribute [
	^RAAttributeNode new attribute: anAttribute
    ]
]



Object subclass: RAVisitor [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    visit: anObject [
	<category: 'visiting'>
	^anObject acceptRoeVisitor: self
    ]

    visitAlias: aRelation [
	<category: 'visiting'>
	^self visitTransformation: aRelation
    ]

    visitBoolean: aBoolean [
	<category: 'visiting-objects'>
	^self visitObject: aBoolean
    ]

    visitCartesianProduct: aRelation [
	<category: 'visiting'>
	
    ]

    visitClone: aClone [
	<category: 'visiting'>
	
    ]

    visitDate: aDate [
	<category: 'visiting-objects'>
	^self visitObject: aDate
    ]

    visitDateAndTime: aDateAndTime [
	<category: 'visiting-objects'>
	^self visitObject: aDateAndTime
    ]

    visitDecimal: aDecimal [
	<category: 'visiting-objects'>
	^self visitNumber: aDecimal
    ]

    visitDifference: aRelation [
	<category: 'visiting'>
	
    ]

    visitDistinct: aRelation [
	<category: 'visiting'>
	
    ]

    visitFloat: aFloat [
	<category: 'visiting-objects'>
	^self visitNumber: aFloat
    ]

    visitGroup: aRelation [
	<category: 'visiting'>
	
    ]

    visitInteger: anInteger [
	<category: 'visiting-objects'>
	^self visitNumber: anInteger
    ]

    visitIntersection: aRelation [
	<category: 'visiting'>
	
    ]

    visitInterval: aRelation [
	<category: 'visiting'>
	
    ]

    visitNumber: aNumber [
	<category: 'visiting-objects'>
	^self visitObject: aNumber
    ]

    visitObject: anObject [
	<category: 'visiting-objects'>
	
    ]

    visitOrder: aRelation [
	<category: 'visiting'>
	
    ]

    visitProjection: aRelation [
	<category: 'visiting'>
	
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	
    ]

    visitSelection: aRelation [
	<category: 'visiting'>
	
    ]

    visitString: aString [
	<category: 'visiting-objects'>
	^self visitObject: aString
    ]

    visitTime: aTime [
	<category: 'visiting-objects'>
	^self visitObject: aTime
    ]

    visitTransformation: aRelation [
	<category: 'visiting'>
	^self visit: aRelation source
    ]

    visitUndefinedObject: anUndefinedObject [
	<category: 'visiting-objects'>
	^self visitObject: anUndefinedObject
    ]

    visitUnion: aRelation [
	<category: 'visiting'>
	
    ]
]



RAVisitor subclass: RAPrinter [
    | stream relation |
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    RAPrinter class >> on: aStream for: aConcreteRelation [
	^self new stream: aStream relation: aConcreteRelation
    ]

    RAPrinter class >> print: aRelation for: aConcreteRelation [
	^String streamContents: [:s |
	    (self on: s for: aConcreteRelation) visit: aRelation]
    ]

    printOperator: aNode [
	<category: 'printing'>
	stream nextPutAll: aNode operator
    ]

    stream: aStream relation: aConcreteRelation [
	<category: 'accessing'>
	stream := aStream.
	relation := aConcreteRelation
    ]

    tupleFor: aRelation [
	<category: 'accessing'>
	^RASelectTuple relation: aRelation
    ]

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: aNode name
    ]

    visitBinaryNode: aNode [
	<category: 'visiting'>
	stream nextPut: $(.
	self visit: aNode left.
	self printOperator: aNode.
	self visit: aNode right.
	stream nextPut: $)
    ]

    visitConditionNodesFor: aRelation [
	<category: 'visiting'>
	self visit: (aRelation evaluateTuple: (self tupleFor: aRelation))
    ]

    visitObject: anObject [
	<category: 'visiting'>
	relation print: anObject on: stream
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	aRelation printOn: stream
    ]
]



RAPrinter subclass: RAAlgebraicPrinter [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    visitAlias: aRelation [
	| sourceAttributes attributes |
	stream nextPutAll: 'R['.
	sourceAttributes := aRelation source attributes.
	attributes := aRelation attributes.
	sourceAttributes with: attributes
	    do: 
		[:old :new | 
		old = new 
		    ifFalse: 
			[stream
			    nextPutAll: old name;
			    nextPutAll: '->';
			    nextPutAll: new name;
			    nextPutAll: ',']].
	(stream contents endsWith: ',') ifTrue: [stream skip: -1].
	stream nextPutAll: ']'.
	self visitTransformation: aRelation
    ]

    visitCartesianProduct: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' X '.
	self visit: aRelation right
    ]

    visitDifference: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' \ '.
	self visit: aRelation right
    ]

    visitDistinct: aRelation [
	stream nextPut: ${.
	self visit: aRelation source.
	stream nextPut: $}
    ]

    visitGroup: aRelation [
	stream nextPutAll: 'G['.
	aRelation group do: [:each | stream nextPutAll: each name]
	    separatedBy: [stream nextPut: $,].
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitIntersection: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' n '.
	self visit: aRelation right
    ]

    visitInterval: aRelation [
	stream nextPutAll: 'I['.
	stream print: aRelation start.
	stream nextPut: $,.
	stream print: aRelation stop.
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitOrder: aRelation [
	stream nextPutAll: 'O['.
	(1 to: aRelation order size) do: 
		[:index | 
		stream nextPutAll: (aRelation order at: index) name.
		(aRelation ascending at: index) 
		    ifTrue: [stream nextPutAll: '->asc']
		    ifFalse: [stream nextPutAll: '->desc']]
	    separatedBy: [stream nextPut: $,].
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitProjection: aRelation [
	stream nextPutAll: 'P['.
	aRelation attributes do: [:each | stream nextPutAll: each name]
	    separatedBy: [stream nextPut: $,].
	stream nextPutAll: ']'.
	self visitTransformation: aRelation
    ]

    visitRelation: aRelation [
	stream nextPutAll: aRelation name
    ]

    visitSelection: aRelation [
	stream nextPutAll: 'S['.
	self visitConditionNodesFor: aRelation.
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitTransformation: aRelation [
	stream nextPut: $(.
	super visitTransformation: aRelation.
	stream nextPut: $)
    ]

    visitUnion: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' u '.
	self visit: aRelation right
    ]
]



UndefinedObject extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitUndefinedObject: self
    ]

]



Date extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitDate: self
    ]

]



Number extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitNumber: self
    ]

]



Boolean extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitBoolean: self
    ]

]



Integer extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitInteger: self
    ]

]



Time extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitTime: self
    ]

]



ScaledDecimal extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitDecimal: self
    ]

]



Float extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitFloat: self
    ]

]



String extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitString: self
    ]

    resolveAttributeIn: aCollection [
	| attribute string |
	string := self asString asUppercase.
	aCollection do: 
		[:ea | 
		string = ea name asString asUppercase
		    ifTrue: 
			[attribute ifNil: [attribute := ea]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

]



