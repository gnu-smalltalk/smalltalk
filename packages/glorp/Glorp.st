Object subclass: GlorpHelper [
    
    <import: Glorp>
    <category: 'Glorp-Extensions'>
    <comment: nil>

    GlorpHelper class >> do: aBlock for: aCollection separatedBy: separatorBlock [
	<category: 'helpers'>
	| array |
	array := aCollection asArray.
	1 to: array size
	    do: 
		[:i | 
		| each |
		each := array at: i.
		aBlock value: each.
		i = array size ifFalse: [separatorBlock value]]
    ]

    GlorpHelper class >> print: printBlock on: stream for: aCollection separatedBy: separatorString [
	<category: 'helpers'>
	| array |
	array := aCollection asArray.
	1 to: array size
	    do: 
		[:index | 
		stream nextPutAll: (printBlock value: (array at: index)).
		index == array size ifFalse: [stream nextPutAll: separatorString]]
    ]

    GlorpHelper class >> separate: aCollection by: aOneArgumentBlock [
	<category: 'helpers'>
	^aCollection inject: Dictionary new
	    into: 
		[:dict :each | 
		| val |
		val := aOneArgumentBlock value: each.
		(dict at: val ifAbsentPut: [OrderedCollection new]) add: each]
    ]

    GlorpHelper class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    GlorpHelper class >> glorpBaseExpressionClass [
	"This is to work around Dolphin's obnoxious insistence on absolute prerequisite enforcement. We have to define extension methods on blocks for asGlorpExpression. These need to create a messageArchiver. Those have to be in the dialect-specific prereq, but since that gets loaded before anything else it can't reference Glorp classes. So have it send a message instead"

	<category: 'glorp'>
	^BaseExpression
    ]

    GlorpHelper class >> glorpMessageArchiverClass [
	"This is to work around Dolphin's obnoxious insistence on absolute prerequisite enforcement. We have to define extension methods on blocks for asGlorpExpression. These need to create a messageArchiver. Those have to be in the dialect-specific prereq, but since that gets loaded before anything else it can't reference Glorp classes. So have it send a message instead"

	<category: 'glorp'>
	^MessageArchiver
    ]
]



Object subclass: AddingWriteStream [
    | target |
    
    <category: 'Collections-Streams'>
    <comment: '
Why *can''t* you stream onto a set? Or a bag, or a SortedCollection? No good reason that I can see. This implements only a subset of stream behaviour, that which is necessary to let us build up collections where we have to "append" elements using #add: rather than #at:put: and explicit grows.

Instance Variables:
    target	<Collection>	The thing we''re streaming onto.

'>

    AddingWriteStream class >> on: aCollection [
	<category: 'instance creation'>
	^self new target: aCollection
    ]

    contents [
	<category: 'accessing'>
	^target
    ]

    nextPut: anObject [
	<category: 'accessing'>
	target add: anObject
    ]

    on: aSet [
	<category: 'accessing'>
	target := aSet
    ]

    target [
	<category: 'accessing'>
	^target
    ]

    target: aCollection [
	<category: 'accessing'>
	target := aCollection
    ]
]



Object subclass: CachePolicy [
    | expiryAction numberOfElements |
    
    <category: 'Glorp-Core'>
    <comment: '
A CachePolicy implements the different possible policies we might use for caching. The superclass implements the trivial policy of keeping all objects forever.

The policy also controls what we store in the cache. In general, it''s assumed to be a cache entry of some sort, and the policy is responsible for wrapping and unwrapping objects going to and from the cache. The default policy is that the objects themselves are the cache entry (saving one object per cached object in overhead).

Instance Variables:
    size	<Number>	The minimum cache size we want to use.
    expiryAction <Symbol> What to do when an object has expired. Currently hard-coded as one of #remove, #notify, #refresh, #notifyAndRemove.

'>

    CachePolicy class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    CachePolicy class >> default [
	<category: 'instance creation'>
	^Dialect isVisualWorks ifTrue: [WeakVWCachePolicy new] ifFalse: [self new]
    ]

    CachePolicy class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    dictionaryClass [
	<category: 'accessing'>
	^Dictionary
    ]

    expiryAction [
	<category: 'accessing'>
	^expiryAction
    ]

    expiryAction: aSymbol [
	"See class comment for possible values"

	<category: 'accessing'>
	expiryAction := aSymbol
    ]

    numberOfElements [
	<category: 'accessing'>
	^numberOfElements
    ]

    numberOfElements: anInteger [
	<category: 'accessing'>
	numberOfElements := anInteger
    ]

    collectionForExtraReferences [
	<category: 'initialize'>
	^nil
    ]

    initialize [
	<category: 'initialize'>
	numberOfElements := 100.
	expiryAction := #remove
    ]

    newItemsIn: aCache [
	<category: 'initialize'>
	^self dictionaryClass new: 20
    ]

    notifyOfExpiry: anObject in: aCache [
	<category: 'expiry'>
	anObject glorpNoticeOfExpiryIn: aCache session
    ]

    release: aCache [
	<category: 'expiry'>
	(expiryAction == #notify or: [expiryAction == #notifyAndRemove]) 
	    ifTrue: [aCache do: [:each | each glorpNoticeOfExpiryIn: aCache session]]
    ]

    takeExpiryActionForKey: key withValue: anObject in: aCache [
	<category: 'expiry'>
	expiryAction == #refresh ifTrue: [aCache session refresh: anObject].
	(#(#notify #notifyAndRemove) includes: expiryAction) 
	    ifTrue: [self notifyOfExpiry: anObject in: aCache].
	(#(#remove #notifyAndRemove) includes: expiryAction) 
	    ifTrue: [aCache removeKey: key ifAbsent: []]
    ]

    cacheEntryFor: anObject [
	<category: 'wrap/unwrap'>
	^anObject
    ]

    contentsOf: aCacheEntry [
	<category: 'wrap/unwrap'>
	^aCacheEntry
    ]

    hasExpired: aCacheEntry [
	<category: 'wrap/unwrap'>
	^false
    ]

    markEntryAsCurrent: aCacheEntry in: aCache [
	<category: 'wrap/unwrap'>
	^self
    ]
]



Object subclass: Login [
    | database username password connectString name |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    Login class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    = aLogin [
	<category: 'accessing'>
	^self class == aLogin class and: 
		[self name = aLogin name and: 
			[self database class = aLogin database class and: 
				[self username = aLogin username and: 
					[self password = aLogin password 
					    and: [self connectString = aLogin connectString]]]]]
    ]

    connectString [
	<category: 'accessing'>
	^connectString
    ]

    connectString: aString [
	<category: 'accessing'>
	connectString := aString
    ]

    database [
	<category: 'accessing'>
	^database
    ]

    database: aSymbol [
	<category: 'accessing'>
	database := aSymbol
    ]

    hash [
	<category: 'accessing'>
	^self name hash + self database class hash + self username hash 
	    + self password hash + self connectString hash
    ]

    name [
	<category: 'accessing'>
	name isNil ifTrue: [^self connectString] ifFalse: [^name]
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    password [
	<category: 'accessing'>
	^password
    ]

    password: aString [
	<category: 'accessing'>
	password := aString
    ]

    username [
	<category: 'accessing'>
	^username
    ]

    username: aString [
	<category: 'accessing'>
	username := aString
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'a Login('.
	database printOn: aStream.
	aStream nextPutAll: ', '.
	username printOn: aStream.
	aStream nextPutAll: ', '.
	password printOn: aStream.
	aStream nextPutAll: ', '.
	connectString printOn: aStream.
	aStream nextPutAll: ')'
    ]
]



Object subclass: GlorpExpression [
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    GlorpExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    GlorpExpression class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    className [
	<category: 'printing'>
	^self class name
    ]

    displayString [
	<category: 'printing'>
	| stream |
	stream := String new writeStream.
	self printOnlySelfOn: stream.
	^stream contents
    ]

    printOn: aStream [
	<category: 'printing'>
	self printTreeOn: aStream
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    additionalExpressions [
	<category: 'preparing'>
	^#()
    ]

    additionalExpressionsIn: aQuery [
	"Return the collection of additional expressions (representing joins) that this expression tree requires"

	<category: 'preparing'>
	| allExpressions |
	allExpressions := ExpressionGroup with: self.
	allExpressions addAll: aQuery ordering.
	allExpressions addAll: aQuery tracing additionalExpressions.
	^allExpressions inject: OrderedCollection new
	    into: 
		[:sum :each | 
		sum addAll: each additionalExpressions.
		sum]
    ]

    allRelationsFor: rootExpression do: aBlock andBetweenDo: anotherBlock [
	"In any normal relationship, there's only one thing. Just do it"

	<category: 'preparing'>
	aBlock value: rootExpression leftChild value: rootExpression rightChild
    ]

    allTables [
	<category: 'preparing'>
	^self inject: Set new
	    into: 
		[:sum :each | 
		sum addAll: each tables.
		sum]
    ]

    allTablesToPrint [
	<category: 'preparing'>
	^self inject: Set new
	    into: 
		[:sum :each | 
		sum addAll: each tablesToPrint.
		sum]
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	self subclassResponsibility
    ]

    assignTableAliasesStartingAt: anInteger [
	<category: 'preparing'>
	^anInteger
    ]

    hasBindableExpressionsIn: aCommand [
	<category: 'preparing'>
	^false
    ]

    prepareIn: aQuery [
	<category: 'preparing'>
	(self additionalExpressionsIn: aQuery) do: [:each | aQuery addJoin: each]
    ]

    tableForANSIJoin [
	"Which table will we join to."

	<category: 'preparing'>
	^nil
    ]

    tables [
	<category: 'preparing'>
	^#()
    ]

    tablesToPrint [
	<category: 'preparing'>
	^#()
    ]

    validate [
	<category: 'preparing'>
	
    ]

    anySatisfy: aBlock [
	"Answer true if aBlock answers true for any element of the receiver.
	 An empty collection answers false."

	<category: 'iterating'>
	self do: [:each | (aBlock value: each) ifTrue: [^true]].
	^false
    ]

    collect: aBlock [
	<category: 'iterating'>
	| newCollection |
	newCollection := OrderedCollection new.
	self do: [:each | newCollection add: (aBlock value: each)].
	^newCollection
    ]

    detect: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument.
	 Answer the first element for which aBlock evaluates to true."

	<category: 'iterating'>
	^self detect: aBlock ifNone: [self notFoundError]
    ]

    detect: aBlock ifNone: exceptionBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument.
	 Answer the first element for which aBlock evaluates to true."

	<category: 'iterating'>
	self do: [:each | (aBlock value: each) ifTrue: [^each]].
	^exceptionBlock value
    ]

    do: aBlock [
	"Iterate over the expression tree"

	<category: 'iterating'>
	self do: aBlock skipping: IdentitySet new
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	aBlock value: self
    ]

    inject: anObject into: aBlock [
	<category: 'iterating'>
	| sum |
	sum := anObject.
	self do: [:each | sum := aBlock value: sum value: each].
	^sum
    ]

    select: aBlock [
	<category: 'iterating'>
	| newCollection |
	newCollection := OrderedCollection new.
	self do: [:each | (aBlock value: each) ifTrue: [newCollection add: each]].
	^newCollection
    ]

    AND: anExpression [
	"This method doesn't really have to exist, because it would be inferred using operationFor:, but it's included here for efficiency and to make it a little less confusing how relation expression get created. Note that the two expression must already be  built on the same base!"

	<category: 'api'>
	anExpression isNil ifTrue: [^self].
	^RelationExpression 
	    named: #AND
	    basedOn: self
	    withArguments: (Array with: anExpression)
    ]

    asGlorpExpression [
	<category: 'api'>
	^self
    ]

    base [
	<category: 'api'>
	self subclassResponsibility
    ]

    equals: anExpression [
	<category: 'api'>
	^RelationExpression 
	    named: #=
	    basedOn: self
	    withArguments: (Array with: anExpression)
    ]

    get: aSymbol withArguments: anArray [
	<category: 'api'>
	self subclassResponsibility
    ]

    getFunction: aSymbol withArguments: anArray [
	<category: 'api'>
	| expression |
	expression := FunctionExpression for: aSymbol withArguments: anArray.
	expression isNil ifTrue: [^nil].
	expression base: self.
	^expression
    ]

    OR: anExpression [
	"This method doesn't really have to exist, because it would be inferred using operationFor:, but it's included here for efficiency and to make it a little less confusing how relation expression get created.  Note that the two expression must already be  built on the same base!"

	<category: 'api'>
	anExpression isNil ifTrue: [^self].
	^RelationExpression 
	    named: #OR
	    basedOn: self
	    withArguments: (Array with: anExpression)
    ]

    parameter: aConstantExpression [
	"Create a parameter expression with the given name. But note that the name doesn't have to be a string. Database fields, symbols, and integers are all plausible"

	<category: 'api'>
	^ParameterExpression forField: aConstantExpression value basedOn: self
    ]

    inspectorHierarchies [
	<category: 'inspecting'>
	| hierarchy |
	hierarchy := ((Smalltalk at: #Tools ifAbsent: [^#()]) at: #Trippy
		    ifAbsent: [^#()]) at: #Hierarchy ifAbsent: [^#()].
	^Array with: (hierarchy 
		    id: #expression
		    label: 'Expression Tree'
		    parentBlock: [:each | nil]
		    childrenBlock: [:each | each inspectorChildren])
    ]

    canBeUsedForRetrieve [
	"Return true if this is a valid argument for a retrieve: clause"

	<category: 'testing'>
	^false
    ]

    canBind [
	"Return true if this represents a value that can be bound into a prepared statement"

	<category: 'testing'>
	^false
    ]

    canKnit [
	"Return true if, when building objects, we can knit the object corresponding to this expression to a related object. Roughly speaking, is this a mapping expression"

	<category: 'testing'>
	^false
    ]

    hasImpliedClauses [
	"Return true if this implies additional SQL clauses beyond just a single field expression"

	<category: 'testing'>
	^false
    ]

    hasTableAliases [
	<category: 'testing'>
	^false
    ]

    isEmptyExpression [
	<category: 'testing'>
	^false
    ]

    isGlorpExpression [
	<category: 'testing'>
	^true
    ]

    isPrimaryKeyExpression [
	<category: 'testing'>
	^false
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^self subclassResponsibility
    ]

    hasDescriptor [
	<category: 'accessing'>
	^false
    ]

    printsTable [
	<category: 'accessing'>
	^false
    ]

    requiresDistinct [
	<category: 'accessing'>
	^false
    ]

    valueIn: aDictionary [
	"Return the value associated with this expression given the parameters in aDictionary. Only meaningful for ParameterExpressions"

	<category: 'accessing'>
	^self
    ]

    asGeneralGlorpExpression [
	"Convert the result to a general (tree-format) expression, if it's the more limited primary key expression"

	<category: 'converting'>
	^self
    ]

    asGlorpExpressionForDescriptor: aDescriptor [
	<category: 'converting'>
	self ultimateBaseExpression descriptor: aDescriptor
    ]

    asGlorpExpressionOn: aBaseExpression [
	<category: 'converting'>
	aBaseExpression ultimateBaseExpression == self ultimateBaseExpression 
	    ifTrue: [^self].
	^self rebuildOn: aBaseExpression
    ]

    asIndependentJoins [
	"If this is an ANDed clause, split it into independent joins"

	<category: 'converting'>
	^Array with: self
    ]

    in: anExpression [
	<category: 'initialize'>
	^RelationExpression 
	    named: #IN
	    basedOn: self
	    withArguments: (Array with: anExpression)
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    primaryKeyFromDictionary: aDictionary [
	"Given a set of parameters, return a primary key suitable for retrieving our target. We can't do this for general expressions, so indicate failure by returning nil"

	<category: 'primary keys'>
	^nil
    ]
]



GlorpExpression subclass: FunctionExpression [
    | function base |
    
    <category: 'Glorp-Expressions'>
    <comment: '
This represents a database function or other modifier. For example, conversion to upper or lower case, or the ascending/descending modifier in order by clauses. At the moment it is hard-coded to to handle only the descending modifier and does not handle e.g. function arguments, functions that differ between databases, functional syntax ( as opposed to postfix). One would probably define subclasses to handle these cases, but this is the simplest thing that could possibly work for the current functionality.'>

    FunctionExpression class [
	| possibleFunctions |
	
    ]

    FunctionExpression class >> initialize [
	<category: 'private'>
	self resetPossibleFunctions
    ]

    FunctionExpression class >> initializePossibleFunctions [
	"self initializePossibleFunctions"

	<category: 'private'>
	possibleFunctions := (IdentityDictionary new)
		    at: #descending put: (PostfixFunction named: 'DESC');
		    at: #distinct put: (InfixFunction named: 'DISTINCT');
		    at: #max put: (InfixFunction named: 'MAX');
		    at: #not put: (InfixFunction named: 'NOT');
		    yourself
    ]

    FunctionExpression class >> named: aString [
	"Used for creating template instances only"

	<category: 'private'>
	^self new function: aString
    ]

    FunctionExpression class >> resetPossibleFunctions [
	"self resetPossibleFunctions"

	<category: 'private'>
	possibleFunctions := nil
    ]

    FunctionExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    FunctionExpression class >> for: aSymbol withArguments: anArray [
	<category: 'instance creation'>
	| function newFunction |
	function := self possibleFunctions at: aSymbol ifAbsent: [^nil].
	newFunction := function copy.
	newFunction arguments: anArray.
	^newFunction
    ]

    FunctionExpression class >> possibleFunctions [
	<category: 'functions'>
	possibleFunctions isNil ifTrue: [self initializePossibleFunctions].
	^possibleFunctions
    ]

    arguments: anArray [
	<category: 'accessing'>
	^self
    ]

    base [
	<category: 'accessing'>
	^base
    ]

    base: anExpression [
	<category: 'accessing'>
	base := anExpression
    ]

    canHaveBase [
	<category: 'accessing'>
	^true
    ]

    field [
	<category: 'accessing'>
	^base field
    ]

    function: aString [
	<category: 'accessing'>
	function := aString
    ]

    function: aString arguments: anArray [
	<category: 'accessing'>
	self function: aString
    ]

    mappedFields [
	<category: 'accessing'>
	^base mappedFields
    ]

    table [
	<category: 'accessing'>
	^self field table
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	^base ultimateBaseExpression
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: function
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	self subclassResponsibility
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: function
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'api'>
	| newBase |
	newBase := base asExpressionJoiningSource: source toTarget: target.
	^(self new)
	    function: function;
	    base: newBase
    ]

    get: aSymbol withArguments: anArray [
	<category: 'api'>
	self error: 'Expressions cannot be built on function expressions'
    ]

    canBeUsedForRetrieve [
	"Return true if this is a valid argument for a retrieve: clause"

	<category: 'testing'>
	^true
    ]

    valueInBuilder: anElementBuilder [
	<category: 'As yet unclassified'>
	^self base valueInBuilder: anElementBuilder
    ]
]



GlorpExpression subclass: ConstantExpression [
    | value |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    ConstantExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    ConstantExpression class >> for: anObject [
	<category: 'instance creation'>
	^self new value: anObject
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	aStream print: value
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	self value glorpPrintSQLOn: aStream
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream print: value
    ]

    canBind [
	"Return true if this represents a value that can be bound into a prepared statement"

	<category: 'testing'>
	^true
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^false
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]

    valueIn: aDictionary [
	<category: 'accessing'>
	^value
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	^self
    ]

    rebuildOn: aBaseExpression [
	<category: 'preparing'>
	^self
    ]

    asGlorpExpressionOn: aBaseExpression [
	<category: 'converting'>
	^self
    ]
]



Object subclass: ObjectTransaction [
    | undoMap |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: '
An ObjectTransaction knows how to remember the state of objects and revert them back to that state later on. It does this by making a *shallow* copy of the registered objects and everything connected to them, and then putting that into an identity dictionary keyed by the originals.

If you have to undo, you push the state from the shallow copies back into the originals.

Yes, that works, and it''s all you have to do. It even handles collections become:ing different sizes.

This is fairly independent of GLORP. You could use this mechanism in general, if you provided your own mechanism for figuring out what to register, or even just uncommented the one in here.

Instance Variables:
    undoMap	<IdentityDictionary>	 The dictionary of originals->copies.

'>

    ObjectTransaction class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    ObjectTransaction class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    initialize [
	<category: 'initializing'>
	self initializeUndoMap
    ]

    initializeUndoMap [
	<category: 'initializing'>
	undoMap := IdentityDictionary new
    ]

    isShapeOf: original differentThanThatOf: copy [
	<category: 'private/restoring'>
	^original class ~~ copy class or: [original basicSize ~= copy basicSize]
    ]

    restoreIndexedInstanceVariablesOf: original toThoseOf: copy [
	<category: 'private/restoring'>
	1 to: copy basicSize
	    do: [:index | original basicAt: index put: (copy basicAt: index)]
    ]

    restoreNamedInstanceVariablesOf: original toThoseOf: copy [
	<category: 'private/restoring'>
	1 to: copy class instSize
	    do: [:index | original instVarAt: index put: (copy instVarAt: index)]
    ]

    restoreShapeOf: original toThatOf: copy [
	<category: 'private/restoring'>
	| newOriginal |
	(copy class isBits or: [copy class isVariable]) 
	    ifTrue: [newOriginal := copy class basicNew: copy basicSize]
	    ifFalse: [newOriginal := copy class basicNew].
	original become: newOriginal
    ]

    restoreStateOf: original toThatOf: copy [
	<category: 'private/restoring'>
	(self isShapeOf: original differentThanThatOf: copy) 
	    ifTrue: [self restoreShapeOf: original toThatOf: copy].
	self restoreNamedInstanceVariablesOf: original toThoseOf: copy.
	self restoreIndexedInstanceVariablesOf: original toThoseOf: copy
    ]

    abort [
	<category: 'begin/commit/abort'>
	undoMap 
	    keysAndValuesDo: [:original :copy | self restoreStateOf: original toThatOf: copy]
    ]

    begin [
	<category: 'begin/commit/abort'>
	self initializeUndoMap
    ]

    commit [
	<category: 'begin/commit/abort'>
	self initializeUndoMap
    ]

    undoMap [
	<category: 'accessing'>
	^undoMap
    ]

    instanceVariablesOf: anObject do: aBlock [
	<category: 'private/registering'>
	(1 to: anObject class instSize) 
	    do: [:index | aBlock value: (anObject instVarAt: index)].
	(1 to: anObject basicSize) 
	    do: [:index | aBlock value: (anObject basicAt: index)]
    ]

    shallowCopyOf: anObject ifNotNeeded: aBlock [
	<category: 'private/registering'>
	| copy |
	copy := anObject shallowCopy.
	^copy == anObject ifTrue: [aBlock value] ifFalse: [copy]
    ]

    isRegistered: anObject [
	"Note: We can never have a situation where a proxy is registered but its contents aren't, so we don't have to worry about that ambiguous case."

	<category: 'registering'>
	| realObject |
	realObject := self realObjectFor: anObject ifNone: [^false].
	^undoMap includesKey: realObject
    ]

    realObjectFor: anObject [
	"If this is a proxy, return the contents (if available). Otherwise, return nil"

	<category: 'registering'>
	^self realObjectFor: anObject ifNone: [nil]
    ]

    realObjectFor: anObject ifNone: aBlock [
	"If this is a proxy, return the contents (if available). Otherwise, evaluate the block"

	<category: 'registering'>
	^anObject class == Proxy 
	    ifTrue: 
		[anObject isInstantiated ifTrue: [anObject getValue] ifFalse: [aBlock value]]
	    ifFalse: [anObject]
    ]

    register: anObject [
	"Make anObject be a member of the current transaction. Return the object if registered, or nil otherwise"

	<category: 'registering'>
	| copy realObject |
	(self requiresRegistrationFor: anObject) ifFalse: [^nil].
	realObject := self realObjectFor: anObject ifNone: [^nil].
	copy := self shallowCopyOf: realObject ifNotNeeded: [^nil].
	undoMap at: realObject put: copy.
	self registerTransientInternalsOfCollection: realObject.
	^realObject
    ]

    registeredObjectsDo: aBlock [
	"Iterate over all our objects. Note that this will include objects without descriptors. Be sure we're iterating over a copy of the keys, because this will add objects to the undoMap"

	<category: 'registering'>
	undoMap keys do: aBlock
    ]

    registerTransientInternalsOfCollection: aCollection [
	"If this is a collection, then we may need to register any internal structures it has, e.g. an internal array. This is implementation dependent for the collection. We will also explicitly exclude strings"

	<category: 'registering'>
	aCollection glorpIsCollection ifFalse: [^self].
	aCollection class isBits ifTrue: [^self].
	aCollection glorpRegisterCollectionInternalsIn: self
    ]

    requiresRegistrationFor: anObject [
	<category: 'registering'>
	| realObject |
	realObject := self realObjectFor: anObject ifNone: [^false].
	^(self isRegistered: realObject) not
    ]
]



Object subclass: Mapping [
    | descriptor attributeName attributeAccessor readOnly |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    Mapping class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    Mapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    allTables [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    attributeAccessor [
	<category: 'accessing'>
	^attributeAccessor
    ]

    attributeName [
	"Private - Answer the value of the receiver's ''attributeName'' instance variable."

	<category: 'accessing'>
	^attributeName
    ]

    attributeName: anObject [
	"Private - Set the value of the receiver's ''attributeName'' instance variable to the argument, anObject."

	<category: 'accessing'>
	attributeName := anObject.
	self initializeAccessor
    ]

    descriptor [
	"Private - Answer the value of the receiver's ''descriptor'' instance variable."

	<category: 'accessing'>
	^descriptor
    ]

    descriptor: anObject [
	"Private - Set the value of the receiver's ''descriptor'' instance variable to the argument, anObject."

	<category: 'accessing'>
	descriptor := anObject
    ]

    fieldsForSelectStatement [
	"Return a collection of fields that this mapping will read from a row"

	<category: 'accessing'>
	^self mappedFields
    ]

    initializeAccessor [
	<category: 'accessing'>
	attributeName == nil ifTrue: [^self].
	attributeAccessor := AttributeAccessor newForAttributeNamed: attributeName.
	self updateUseDirectAccess
    ]

    readOnly [
	<category: 'accessing'>
	^readOnly
    ]

    readOnly: aBoolean [
	<category: 'accessing'>
	readOnly := aBoolean
    ]

    session [
	<category: 'accessing'>
	^self descriptor session
    ]

    system [
	<category: 'accessing'>
	^self descriptor system
    ]

    updateUseDirectAccess [
	<category: 'accessing'>
	(self attributeAccessor notNil 
	    and: [self descriptor notNil and: [self descriptor system notNil]]) 
		ifTrue: 
		    [self attributeAccessor 
			useDirectAccess: self descriptor system useDirectAccessForMapping]
    ]

    canBeUsedForRetrieve [
	"Return true if this is a valid argument for a retrieve: clause"

	<category: 'testing'>
	self isRelationship ifFalse: [^true].
	^self isToManyRelationship not
    ]

    controlsTables [
	"Return true if this type of mapping 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

	<category: 'testing'>
	self subclassResponsibility
    ]

    hasImpliedClauses [
	"Return true if this implies multiple sql clauses"

	<category: 'testing'>
	^false
    ]

    includesSubFieldsInSelectStatement [
	<category: 'testing'>
	^false
    ]

    isRelationship [
	"True when the mapping associates different persistent classes."

	<category: 'testing'>
	^self subclassResponsibility
    ]

    isStoredInSameTable [
	"True when the mapping is between two objects that occupy the same table, e.g. an embedded mapping."

	<category: 'testing'>
	^self subclassResponsibility
    ]

    isToManyRelationship [
	<category: 'testing'>
	^false
    ]

    isTypeMapping [
	<category: 'testing'>
	^false
    ]

    mappedFields [
	<category: 'testing'>
	self subclassResponsibility
    ]

    applicableMappingForObject: anObject [
	"For polymorphism with conditional mappings"

	<category: 'mapping'>
	^self
    ]

    expressionFor: anObject [
	"Return our expression using the object's values. e.g. if this was a direct mapping from id->ID and the object had id: 3, then return TABLE.ID=3"

	<category: 'mapping'>
	self subclassResponsibility
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	<category: 'mapping'>
	self subclassResponsibility
    ]

    mapObject: anObject inElementBuilder: anObject1 [
	<category: 'mapping'>
	self subclassResponsibility
    ]

    readBackNewRowInformationFor: anObject fromRowsIn: aRowMap [
	"
	 self subclassResponsibility. ?"

	<category: 'mapping'>
	
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	self subclassResponsibility
    ]

    trace: aTracing context: anExpression [
	<category: 'mapping'>
	self subclassResponsibility
    ]

    translateFields: anOrderedCollection [
	"Normal mappings don't translate"

	<category: 'mapping'>
	^anOrderedCollection
    ]

    getValueFrom: anObject [
	<category: 'public'>
	^attributeAccessor getValueFrom: anObject
    ]

    printOn: aStream [
	<category: 'public'>
	super printOn: aStream.
	aStream
	    nextPutAll: '(';
	    nextPutAll: (attributeName isNil ifTrue: [''] ifFalse: [attributeName]);
	    nextPutAll: ')'
    ]

    setValueIn: anObject to: aValue [
	<category: 'public'>
	attributeAccessor setValueIn: anObject to: aValue
    ]

    allRelationsFor: rootExpression do: aBlock andBetweenDo: anotherBlock [
	"Normal mappings just operate on a single expression"

	<category: 'printing SQL'>
	aBlock value: rootExpression leftChild value: rootExpression rightChild
    ]

    initialize [
	<category: 'initialize/release'>
	readOnly := false
    ]

    joinExpressionFor: anExpression [
	<category: 'preparing'>
	^nil
    ]

    multipleTableExpressionsFor: anExpression [
	<category: 'preparing'>
	^#()
    ]
]



Mapping subclass: TypeMapping [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    TypeMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    canBeTypeMappingParent [
	<category: 'testing'>
	^true
    ]

    isAbstract [
	<category: 'testing'>
	self subclassResponsibility
    ]

    isRelationship [
	<category: 'testing'>
	^false
    ]

    isTypeMapping [
	<category: 'testing'>
	^true
    ]

    isTypeMappingRoot [
	<category: 'testing'>
	| superClassDescriptor |
	superClassDescriptor := self descriptorForSuperclass.
	^superClassDescriptor isNil 
	    or: [superClassDescriptor typeMapping canBeTypeMappingParent not]
    ]

    mappedClass [
	<category: 'accessing'>
	^self descriptor describedClass
    ]

    addTypeMappingCriteriaTo: collection in: expression [
	<category: 'mapping'>
	^self
    ]

    allDescribedConcreteClasses [
	<category: 'mapping'>
	^Array with: self describedClass
    ]

    describedClass [
	<category: 'mapping'>
	^self descriptor describedClass
    ]

    describedConcreteClassFor: aRow withBuilder: builder [
	<category: 'mapping'>
	^self mappedClass
    ]

    descriptorForSuperclass [
	<category: 'mapping'>
	^self system descriptorFor: self mappedClass superclass
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	"do  nothing"

	<category: 'mapping'>
	
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	"do  nothing"

	<category: 'mapping'>
	
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	^#()
    ]

    typeMappingRoot [
	<category: 'mapping'>
	^self isTypeMappingRoot 
	    ifTrue: [self mappedClass]
	    ifFalse: [self descriptorForSuperclass typeMapping typeMappingRoot]
    ]
]



Object subclass: DatabaseConverter [
    | name |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DatabaseConverter class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    DatabaseConverter class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    convert: anObject fromDatabaseRepresentationAs: aDatabaseType [
	<category: 'converting'>
	self subclassResponsibility
    ]

    convert: anObject toDatabaseRepresentationAs: aDatabaseType [
	<category: 'converting'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialize'>
	name := #unnamed
    ]

    printOn: aString [
	<category: 'printing'>
	aString nextPutAll: 'DatabaseConverter(' , name , ')'
    ]
]



Object subclass: DatabaseTable [
    | name fields primaryKeyFields foreignKeyConstraints parent schema |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DatabaseTable class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    DatabaseTable class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    DatabaseTable class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: '(';
	    nextPutAll: (name isNil ifTrue: [''] ifFalse: [name]);
	    nextPutAll: ')'
    ]

    printSQLOn: aWriteStream withParameters: aDictionary [
	<category: 'printing'>
	aWriteStream nextPutAll: self name
    ]

    sqlString [
	<category: 'printing'>
	^name
    ]

    creationStringFor: aDatabaseAccessor [
	<category: 'create/delete in db'>
	| creationStream |
	creationStream := WriteStream on: (String new: 1000).
	creationStream
	    nextPutAll: 'CREATE TABLE ';
	    nextPutAll: self name;
	    nextPutAll: ' ( ';
	    nl.
	self printFieldsOn: creationStream for: aDatabaseAccessor.
	aDatabaseAccessor platform supportsConstraints 
	    ifTrue: 
		[self hasPrimaryKeyConstraints 
		    ifTrue: [self printDelimiterOn: creationStream].
		self printPrimaryKeyConstraintsOn: creationStream for: aDatabaseAccessor
		"self hasForeignKeyConstraints ifTrue: [self printDelimiterOn: creationStream].
		 self printForeignKeyConstraintsOn: creationStream for: aDatabaseAccessor"].
	creationStream nextPutAll: ')'.
	^creationStream contents
    ]

    dropForeignKeyConstraintsFromAccessor: aDatabaseAccessor [
	<category: 'create/delete in db'>
	self foreignKeyConstraints 
	    do: [:each | aDatabaseAccessor dropConstraint: each]
    ]

    dropFromAccessor: aDatabaseAccessor [
	<category: 'create/delete in db'>
	aDatabaseAccessor platform supportsConstraints 
	    ifTrue: [self dropPrimaryKeyConstraintsFromAccessor: aDatabaseAccessor].
	aDatabaseAccessor dropTableNamed: self name
    ]

    dropPrimaryKeyConstraintsFromAccessor: aDatabaseAccessor [
	<category: 'create/delete in db'>
	self primaryKeyFields isEmpty 
	    ifFalse: 
		[aDatabaseAccessor doCommand: 
			[aDatabaseAccessor 
			    executeSQLString: 'ALTER TABLE ' , self name , ' DROP CONSTRAINT ' 
				    , self primaryKeyUniqueConstraintName]
		    ifError: [:ex | Transcript show: (ex messageText ifNil: [ex printString])].
		aDatabaseAccessor doCommand: 
			[aDatabaseAccessor 
			    executeSQLString: 'ALTER TABLE ' , self name , ' DROP CONSTRAINT ' 
				    , self primaryKeyConstraintName]
		    ifError: [:ex | Transcript show: (ex messageText ifNil: [ex printString])]]
    ]

    primaryKeyConstraintName [
	<category: 'create/delete in db'>
	^self name , '_PK'
    ]

    primaryKeyUniqueConstraintName [
	<category: 'create/delete in db'>
	^self name , '_UNIQ'
    ]

    printDelimiterOn: aStream [
	<category: 'create/delete in db'>
	aStream
	    nextPut: $,;
	    nl
    ]

    printFieldsOn: creationStream for: aDatabaseAccessor [
	<category: 'create/delete in db'>
	GlorpHelper 
	    do: [:each | each printCreationStringFor: aDatabaseAccessor on: creationStream]
	    for: fields
	    separatedBy: [self printDelimiterOn: creationStream]
    ]

    printForeignKeyConstraintsOn: creationStream for: anObject [
	<category: 'create/delete in db'>
	GlorpHelper 
	    print: [:each | each creationString]
	    on: creationStream
	    for: foreignKeyConstraints
	    separatedBy: ','
    ]

    printPrimaryKeyConstraintsOn: aStream for: aDatabaseAccessor [
	<category: 'create/delete in db'>
	self primaryKeyFields isEmpty ifTrue: [^self].
	aStream nextPutAll: 'CONSTRAINT '.
	aStream nextPutAll: self primaryKeyConstraintName.
	aStream nextPutAll: ' PRIMARY KEY  ('.
	GlorpHelper 
	    print: [:each | each name]
	    on: aStream
	    for: self primaryKeyFields
	    separatedBy: ','.
	aStream nextPut: $).
	aStream
	    nextPutAll: ',';
	    nl.
	aStream nextPutAll: 'CONSTRAINT '.
	aStream nextPutAll: self primaryKeyUniqueConstraintName.
	aStream nextPutAll: ' UNIQUE  ('.
	GlorpHelper 
	    print: [:each | each name]
	    on: aStream
	    for: self primaryKeyFields
	    separatedBy: ','.
	aStream nextPut: $)
    ]

    hasCompositePrimaryKey [
	<category: 'testing'>
	^primaryKeyFields size > 1
    ]

    hasConstraints [
	<category: 'testing'>
	^self hasForeignKeyConstraints or: [self hasPrimaryKeyConstraints]
    ]

    hasFieldNamed: aString [
	<category: 'testing'>
	^fields contains: [:each | each name = aString]
    ]

    hasForeignKeyConstraints [
	<category: 'testing'>
	^foreignKeyConstraints isEmpty not
    ]

    hasPrimaryKeyConstraints [
	<category: 'testing'>
	^self primaryKeyFields isEmpty not
    ]

    addAsPrimaryKeyField: aField [
	<category: 'private/fields'>
	primaryKeyFields := primaryKeyFields , (Array with: aField)
    ]

    <= aTable [
	<category: 'comparing'>
	^self name <= aTable name
    ]

    creator [
	<category: 'accessing'>
	^self schema
    ]

    creator: aString [
	"For backward-compatibility. Use schema: instead."

	<category: 'accessing'>
	self schema: aString
    ]

    fields [
	<category: 'accessing'>
	^fields
    ]

    foreignKeyConstraints [
	"Private - Answer the value of the receiver's ''foreignKeyConstraints'' instance variable."

	<category: 'accessing'>
	^foreignKeyConstraints
    ]

    isAliased [
	<category: 'accessing'>
	^parent notNil
    ]

    name [
	"Private - Answer the value of the receiver's ''name'' instance variable."

	<category: 'accessing'>
	^(schema isNil or: [schema isEmpty]) 
	    ifTrue: [name]
	    ifFalse: [schema , '.' , name]
    ]

    name: anObject [
	<category: 'accessing'>
	name := anObject
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aDatabaseTable [
	<category: 'accessing'>
	parent := aDatabaseTable
    ]

    primaryKeyFields [
	<category: 'accessing'>
	^primaryKeyFields
    ]

    qualifiedName [
	<category: 'accessing'>
	^self name
    ]

    schema [
	<category: 'accessing'>
	^schema
    ]

    schema: aString [
	<category: 'accessing'>
	schema := aString
    ]

    sqlTableName [
	"Our name, as appropriate for the list of tables in a SQL statement. Take into account aliasing"

	<category: 'accessing'>
	^parent isNil 
	    ifTrue: [self name]
	    ifFalse: [parent sqlTableName , ' ' , self name]
    ]

    initialize [
	<category: 'initialize'>
	schema := ''.
	fields := OrderedCollection new.
	primaryKeyFields := #().
	foreignKeyConstraints := OrderedCollection new: 4
    ]

    postInitializeIn: aDescriptorSystem [
	"Any initialization that happens after all the fields have been added"

	<category: 'initialize'>
	fields do: [:each | each postInitializeIn: aDescriptorSystem]
    ]

    addField: aField [
	<category: 'fields'>
	fields add: aField.
	aField isPrimaryKey ifTrue: [self addAsPrimaryKeyField: aField].
	aField table: self.
	aField position: fields size.
	^aField
    ]

    addForeignKeyFrom: sourceField to: targetField [
	<category: 'fields'>
	^self 
	    addForeignKeyFrom: sourceField
	    to: targetField
	    suffixExpression: nil
    ]

    addForeignKeyFrom: sourceField to: targetField suffixExpression: suffixExpression [
	<category: 'fields'>
	| newFK |
	newFK := ForeignKeyConstraint 
		    sourceField: sourceField
		    targetField: targetField
		    suffixExpression: suffixExpression.
	newFK name: newFK name , (foreignKeyConstraints size + 1) printString.
	^foreignKeyConstraints add: newFK
    ]

    createFieldNamed: aString type: dbType [
	<category: 'fields'>
	| existingField |
	existingField := fields detect: [:each | each name = aString] ifNone: [nil].
	existingField notNil 
	    ifTrue: [self error: 'field ' , aString , ' already exists'].
	^self addField: (DatabaseField named: aString type: dbType)
    ]

    fieldNamed: aString [
	<category: 'fields'>
	^fields detect: [:each | each name = aString]
    ]

    newFieldNamed: aString [
	<category: 'fields'>
	^self error: 'use #createFieldNamed:type:'
    ]
]



Object subclass: JoinPrinter [
    | joinsToProcess availableTables query |
    
    <category: 'Glorp-Queries'>
    <comment: nil>

    JoinPrinter class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    JoinPrinter class >> for: aQuery [
	<category: 'instance creation'>
	^self new query: aQuery
    ]

    setUp [
	<category: 'initializing'>
	availableTables := Set new
    ]

    nextJoin [
	<category: 'printing'>
	^joinsToProcess detect: 
		[:eachJoinExpression | 
		eachJoinExpression tablesForANSIJoin 
		    anySatisfy: [:eachTable | availableTables includes: eachTable]]
    ]

    printJoinsOn: aCommand [
	<category: 'printing'>
	joinsToProcess := query joins copy.
	availableTables := Set with: self rootTable.
	joinsToProcess size timesRepeat: [aCommand nextPut: $(].
	aCommand nextPutAll: self rootTable sqlTableName.
	[joinsToProcess isEmpty] whileFalse: 
		[| next |
		next := self nextJoin.
		next printForANSIJoinTo: availableTables on: aCommand.
		aCommand nextPut: $).
		joinsToProcess remove: next.
		availableTables addAll: next tablesForANSIJoin].
	self printLeftoverTablesOn: aCommand
    ]

    printLeftoverTablesOn: aCommand [
	"Now there might be leftover tables whose joins were implied directly by the where clause"

	<category: 'printing'>
	| leftOverTables |
	leftOverTables := self allTables asSet copy.
	availableTables do: [:each | leftOverTables remove: each ifAbsent: []].
	leftOverTables isEmpty ifFalse: [aCommand nextPutAll: ', '].
	GlorpHelper 
	    print: [:each | each sqlTableName]
	    on: aCommand
	    for: leftOverTables
	    separatedBy: ', '
    ]

    allTables [
	<category: 'accessing'>
	^query tablesToPrint
    ]

    query: aQuery [
	<category: 'accessing'>
	query := aQuery.
	self setUp
    ]

    rootTable [
	"Pick a table to start with"

	<category: 'accessing'>
	^self allTables first
    ]
]



DatabaseConverter subclass: DelegatingDatabaseConverter [
    | host stToDbSelector dbToStSelector |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DelegatingDatabaseConverter class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    DelegatingDatabaseConverter class >> hostedBy: anObject fromStToDb: stDbSelector fromDbToSt: dbStSelector [
	<category: 'instance creation'>
	^super new 
	    hostedBy: anObject
	    fromStToDb: stDbSelector
	    fromDbToSt: dbStSelector
    ]

    convert: anObject fromDatabaseRepresentationAs: aDatabaseType [
	<category: 'converting'>
	^host 
	    perform: dbToStSelector
	    with: anObject
	    with: aDatabaseType
    ]

    convert: anObject toDatabaseRepresentationAs: aDatabaseType [
	<category: 'converting'>
	^host 
	    perform: stToDbSelector
	    with: anObject
	    with: aDatabaseType
    ]

    hostedBy: anObject fromStToDb: stDbSelector fromDbToSt: dbStSelector [
	<category: 'initialize-release'>
	host := anObject.
	stToDbSelector := stDbSelector.
	dbToStSelector := dbStSelector
    ]
]



FunctionExpression subclass: PostfixFunction [
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    PostfixFunction class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	base printSQLOn: aStream withParameters: aDictionary.
	aStream
	    nextPutAll: ' ';
	    nextPutAll: function
    ]
]



TypeMapping subclass: FilteredTypeMapping [
    | field key keyDictionary |
    
    <category: 'Glorp-Mappings'>
    <comment: '
EnumeratedMapping knows what type an object should be based on the value of a single row.'>

    FilteredTypeMapping class >> to: field keyedBy: key [
	<category: 'instance creation'>
	^self new field: field keyedBy: key
    ]

    FilteredTypeMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    describedConcreteClassFor: aRow withBuilder: builder [
	<category: 'types'>
	^self keyDictionary 
	    at: (aRow atIndex: (builder translateFieldPosition: field))
    ]

    keys [
	<category: 'types'>
	^self keyDictionary keys
    ]

    buildKeyDictionary [
	<category: 'initialize-release'>
	| subclassDescriptor |
	keyDictionary := Dictionary new.
	keyDictionary at: key put: descriptor describedClass.
	descriptor describedClass allSubclasses do: 
		[:each | 
		subclassDescriptor := descriptor system descriptorFor: each.
		keyDictionary at: subclassDescriptor typeMapping keyedBy
		    put: subclassDescriptor describedClass]
    ]

    field: aField keyedBy: aKey [
	<category: 'initialize-release'>
	field := aField.
	key := aKey
    ]

    field [
	<category: 'accessing'>
	^field
    ]

    keyDictionary [
	<category: 'accessing'>
	keyDictionary isNil ifTrue: [self buildKeyDictionary].
	^keyDictionary
    ]

    keyedBy [
	<category: 'accessing'>
	^key
    ]

    keyedBy: aKey [
	<category: 'accessing'>
	key := aKey
    ]

    mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	<category: 'accessing'>
	^Array with: self field
    ]

    addTypeMappingCriteriaTo: collection in: base [
	<category: 'mapping'>
	| singleRightValue r l |
	singleRightValue := self keys size = 1.
	r := ConstantExpression for: (singleRightValue 
			    ifTrue: [self keys asArray first]
			    ifFalse: [self keys]).
	l := FieldExpression forField: self field basedOn: base.
	collection 
	    add: (singleRightValue ifTrue: [l equals: r] ifFalse: [l in: r])
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	<category: 'mapping'>
	| row |
	readOnly ifTrue: [^self].
	row := aRowMap findOrAddRowForTable: self field table withKey: anObject.
	row at: field put: key
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	^#()
    ]

    trace: aTracing context: anExpression [
	<category: 'mapping'>
	^self
    ]
]



Object subclass: Dialect [
    
    <category: 'Glorp-Extensions'>
    <comment: nil>

    Dialect class [
	| dialectName timestampClass |
	
    ]

    Dialect class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    Dialect class >> addSeconds: seconds to: aTime [
	<category: 'dates'>
	self isVisualWorks ifTrue: [^aTime addSeconds: seconds].
	self isDolphin ifTrue: [^self addTimeForDolphin: aTime seconds: seconds].
	self isGNU ifTrue: [^aTime addSeconds: seconds].
	self error: 'not implemented'
    ]

    Dialect class >> addTimeForDolphin: aTime seconds: seconds [
	"Dolphin's time/date arithmetic is pretty weak, especially for timestamps. Hack around it. This is likely only to work for seconds <24 hours"

	<category: 'dates'>
	| result |
	^aTime class == Time 
	    ifTrue: 
		[Time 
		    fromMilliseconds: (aTime asMilliseconds + (seconds * 1000)) \\ 86400000]
	    ifFalse: 
		[result := self timestampClass date: aTime date
			    time: (self addTimeForDolphin: aTime time seconds: seconds).
		(seconds > 0 and: [result time < aTime time]) 
		    ifTrue: [result date: (result date addDays: 1)].
		(seconds < 0 and: [result time > aTime time]) 
		    ifTrue: [result date: (result date addDays: -1)].
		^result]
    ]

    Dialect class >> newDateWithYears: year months: monthNumber days: dayOfMonth [
	"Read the y/m/d given. m is a 1-indexed month number (i.e. Jan=1)"

	<category: 'dates'>
	self isVisualWorks 
	    ifTrue: 
		[^Date 
		    newDay: dayOfMonth
		    monthNumber: monthNumber
		    year: year].
	self isGNU 
	    ifTrue: 
		[^Date 
		    newDay: dayOfMonth
		    monthIndex: monthNumber
		    year: year].
	self error: 'not implemented'
	"self isDolphin ifTrue: [ | dateToModify newDate|
	 dateToModify := aDate class == Date ifTrue: [aDate] ifFalse: [aDate date].
	 newDate := Date newDay: dayOfMonth monthNumber: monthNumber year: year.
	 dateToModify setDays: newDate asDays.
	 ^self]."
    ]

    Dialect class >> newTimestampWithYears: year months: monthNumber days: dayOfMonth hours: hours minutes: minutes seconds: seconds milliseconds: milliseconds offset: utcOffsetSeconds [
	<category: 'dates'>
	| date time ts |
	self isGNU 
	    ifTrue: 
		[^self timestampClass 
		    year: year
		    month: monthNumber
		    day: dayOfMonth
		    hour: hours
		    minute: minutes
		    second: seconds
		    offset: (Duration fromSeconds: utcOffsetSeconds)].
	date := self 
		    newDateWithYears: year
		    months: monthNumber
		    days: dayOfMonth.
	time := self 
		    newTimeWithHours: hours
		    minutes: minutes
		    seconds: seconds
		    milliseconds: milliseconds.
	self isVisualWorks 
	    ifTrue: 
		[ts := self timestampClass fromDate: date andTime: time.
		^ts addMilliseconds: milliseconds].
	self error: 'not implemented'
    ]

    Dialect class >> newTimeWithHours: hours minutes: minutes seconds: seconds milliseconds: milliseconds [
	<category: 'dates'>
	self isGNU 
	    ifTrue: [^Time fromSeconds: hours * 60 * 60 + (minutes * 60) + seconds].
	self isVisualWorks 
	    ifTrue: [^Time fromSeconds: hours * 60 * 60 + (minutes * 60) + seconds].
	self error: 'Not implemented yet'
    ]

    Dialect class >> supportsMillisecondsInTimes [
	<category: 'dates'>
	self isGNU ifTrue: [^false].
	self isVisualWorks ifTrue: [^false].
	self isDolphin ifTrue: [^true].
	self error: 'not yet implemented'
    ]

    Dialect class >> timeOffsetFromGMT [
	<category: 'dates'>
	self isGNU ifTrue: [Time timezoneBias / (60 * 60)].
	self isVisualWorks 
	    ifTrue: [^(self smalltalkAt: #TimeZone) default secondsFromGMT / (60 * 60)].
	^0
    ]

    Dialect class >> timestampClass [
	<category: 'dates'>
	timestampClass == nil ifFalse: [^timestampClass].
	Dialect isGNU ifTrue: [^timestampClass := self smalltalkAt: #DateTime].
	(Dialect isSqueak or: [Dialect isDolphin]) 
	    ifTrue: [^timestampClass := self smalltalkAt: #TimeStamp].
	Dialect isVisualWorks 
	    ifTrue: [^timestampClass := self smalltalkAt: #Timestamp].
	self error: 'Not yet implemented'
    ]

    Dialect class >> timestampNow [
	<category: 'dates'>
	self isGNU ifTrue: [^self timestampClass dateAndTimeNow].
	Dialect isSqueak ifTrue: [^self timestampClass current].
	Dialect isVisualWorks ifTrue: [^self timestampClass now].
	Dialect isDolphin ifTrue: [^self timestampClass current].
	self error: 'Not yet implemented'
    ]

    Dialect class >> timestampNowUTC [
	<category: 'dates'>
	self isGNU ifTrue: [^self timestampClass utcDateAndTimeNow].
	Dialect isVisualWorks 
	    ifTrue: [^(self smalltalkAt: #Timestamp) fromSeconds: Time secondClock].
	Dialect isDolphin ifTrue: [self error: 'not supported'].
	self error: 'Not yet implemented'
    ]

    Dialect class >> totalSeconds [
	<category: 'dates'>
	self isGNU ifTrue: [^Time utcSecondClock].
	self isVisualAge 
	    ifTrue: [^(self smalltalkAt: #AbtTimestamp) now totalSeconds].
	^Time totalSeconds
    ]

    Dialect class >> basicIsDolphin [
	<category: 'private'>
	^Smalltalk includesKey: #DolphinSplash
    ]

    Dialect class >> basicIsGNU [
	<category: 'private'>
	^Smalltalk includesKey: #BindingDictionary
    ]

    Dialect class >> basicIsSqueak [
	<category: 'private'>
	^(Smalltalk respondsTo: #vmVersion) 
	    and: [(Smalltalk vmVersion copyFrom: 1 to: 6) = 'Squeak']
    ]

    Dialect class >> basicIsVisualAge [
	<category: 'private'>
	^Smalltalk class name == #EsSmalltalkNamespace
	"| sys |
	 sys := Smalltalk at: #System ifAbsent: [^false].
	 (sys respondsTo: #vmType) ifFalse: [^false].
	 ^sys vmType = 'ES'"
    ]

    Dialect class >> basicIsVisualWorks [
	<category: 'private'>
	^Smalltalk class name == #NameSpace
	"Smalltalk class selectors do: [ :s |
	 (s == #versionName and: [ (Smalltalk versionName copyFrom: 1 to: 11) = 'VisualWorks'])
	 ifTrue: [^true]].
	 ^false"
    ]

    Dialect class >> determineDialect [
	<category: 'private'>
	self basicIsDolphin ifTrue: [^dialectName := #Dolphin].
	self basicIsGNU ifTrue: [^dialectName := #GNU].
	self basicIsVisualAge ifTrue: [^dialectName := #VisualAge].
	self basicIsVisualWorks ifTrue: [^dialectName := #VisualWorks].
	self basicIsSqueak ifTrue: [^dialectName := #Squeak].
	self error: 'I don''t know what dialect this is'
    ]

    Dialect class >> dialectName [
	<category: 'identifying'>
	dialectName isNil ifTrue: [self determineDialect].
	^dialectName
    ]

    Dialect class >> isDolphin [
	<category: 'identifying'>
	^self dialectName = #Dolphin
    ]

    Dialect class >> isGNU [
	<category: 'identifying'>
	^self dialectName = #GNU
    ]

    Dialect class >> isSqueak [
	<category: 'identifying'>
	^self dialectName = #Squeak
    ]

    Dialect class >> isVisualAge [
	<category: 'identifying'>
	^self dialectName = #VisualAge
    ]

    Dialect class >> isVisualWorks [
	<category: 'identifying'>
	^self dialectName = #VisualWorks
    ]

    Dialect class >> garbageCollect [
	<category: 'general portability'>
	Dialect isGNU ifTrue: [^ObjectMemory globalGarbageCollect].
	Dialect isVisualWorks ifTrue: [^ObjectMemory quickGC].
	Dialect isVisualAge ifTrue: [^(self smalltalkAt: #System) collectGarbage].
	self error: 'not implemented yet'
    ]

    Dialect class >> instVarNameFor: attributeName [
	<category: 'general portability'>
	Dialect isGNU ifTrue: [^attributeName asSymbol].
	^attributeName asString
    ]

    Dialect class >> smalltalkAssociationAt: aName [
	<category: 'general portability'>
	self isVisualWorks ifTrue: [^aName asQualifiedReference].
	^Smalltalk associationAt: aName asSymbol
    ]

    Dialect class >> smalltalkAt: aName [
	<category: 'general portability'>
	^self smalltalkAt: aName ifAbsent: [self error: 'element not found']
    ]

    Dialect class >> smalltalkAt: aName ifAbsent: aBlock [
	<category: 'general portability'>
	self isVisualWorks ifTrue: [^aName asQualifiedReference value].
	^Smalltalk at: aName asSymbol ifAbsent: aBlock
    ]

    Dialect class >> tokensBasedOn: tokenString in: aString [
	<category: 'general portability'>
	self isGNU ifTrue: [^aString subStrings: tokenString first].
	self isVisualWorks ifTrue: [^aString tokensBasedOn: tokenString first].
	self isSqueak ifTrue: [^aString findTokens: tokenString].
	self isDolphin ifTrue: [^aString subStrings: tokenString].
	self error: 'not implemented yet'
    ]

    Dialect class >> coerceToDoublePrecisionFloat: aNumber [
	<category: 'numbers'>
	self isGNU ifTrue: [^aNumber asFloatD].
	self isVisualWorks ifTrue: [^aNumber asDouble].
	^aNumber
    ]

    Dialect class >> doublePrecisionFloatClass [
	<category: 'numbers'>
	self isGNU ifTrue: [^self smalltalkAt: #FloatD].
	self isVisualWorks ifTrue: [^self smalltalkAt: #Double].
	^Float
    ]

    Dialect class >> readFixedPointFrom: aString [
	<category: 'numbers'>
	self isVisualWorks 
	    ifTrue: [^(self smalltalkAt: #FixedPoint) readFrom: (ReadStream on: aString)].
	self isDolphin ifTrue: [^Number readFrom: (ReadStream on: aString , 's')].
	self isGNU 
	    ifTrue: 
		[^(Number readFrom: (ReadStream on: aString)) 
		    asScaledDecimal: aString size 
			    - (aString indexOf: $. ifAbsent: [aString size])].
	self error: 'not implemented'
    ]

    Dialect class >> unbindableClassNames [
	<category: 'binding'>
	self isVisualWorks 
	    ifTrue: [^#(#FixedPoint #LargePositiveInteger #LargeNegativeInteger)].
	^#()
    ]
]



Object subclass: ElementBuilder [
    | instance requiresPopulating key expression query fieldTranslations isExpired row |
    
    <category: 'Glorp-Queries'>
    <comment: '
This is the abstract superclass of builders. These assemble information, either primitive data or objects, from a database result set.

Subclasses must implement the following messages:
    building objects
    	buildObjectFrom:
    	findInstanceForRow:useProxy:
    selecting fields
    	fieldsFromMyPerspective

Instance Variables:
    expression	<MappingExpression>	The expression we''re mapping. e.g. if the query is reading people, this might be the expression corresponding to "each address", meaning that we build the address object related to the main Person instance by the given relationship. 
    fieldTranslations	<Array of: Integer>	 The translation of the field positions from where they are in the descriptor to where they are in the row we''re reading. This is done so we can read the rows efficiently, by index, rather than doing lots of dictionary lookups by name. If we''re doing a simple read, the translations will probably be a no-op, but if we read multiple objects, some of the fields will be in different positions than they are in our table definition.
    instance	<Object>	The thing we''re constructing.
    isExpired	<Boolean>	If our instance is in cache, we use that instead. However, if the instance has expired, then we do something different (most likely force a refresh) than if it''s still alive.
    key	<Object>	The key for this row. This is lazily computed, and "self" is used a special marker to indicate that it hasn''t been computed yet.
    query	<AbstractReadQuery>	the query that we''re building results for.
    requiresPopulating	<Boolean>	Do we need to populate the object. Will be false if the object was found in cache and hasn''t expired.
    row	<Array>	The database results. May actually be a result set row of some sort rather than an array, depending on the dialect, but should always respond to indexing protocol.

'>

    ElementBuilder class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    ElementBuilder class >> classFor: anExpression [
	<category: 'private'>
	^anExpression hasDescriptor 
	    ifTrue: [ObjectBuilder]
	    ifFalse: [DataElementBuilder]
    ]

    ElementBuilder class >> for: anExpression [
	<category: 'instance creation'>
	^(self classFor: anExpression) new expression: anExpression
    ]

    ElementBuilder class >> for: anExpression in: aQuery [
	<category: 'instance creation'>
	^((self classFor: anExpression) new)
	    expression: anExpression;
	    query: aQuery
    ]

    ElementBuilder class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    canCauseDuplicateRows [
	<category: 'accessing'>
	^false
    ]

    expression [
	<category: 'accessing'>
	^expression
    ]

    expression: anExpression [
	<category: 'accessing'>
	expression := anExpression
    ]

    fieldTranslations [
	<category: 'accessing'>
	^fieldTranslations
    ]

    fieldTranslations: aDictionary [
	<category: 'accessing'>
	fieldTranslations := aDictionary
    ]

    instance [
	<category: 'accessing'>
	^instance
    ]

    query [
	<category: 'accessing'>
	^query
    ]

    query: aQuery [
	<category: 'accessing'>
	query := aQuery
    ]

    requiresDistinct [
	<category: 'accessing'>
	^expression requiresDistinct
    ]

    row [
	<category: 'accessing'>
	^row
    ]

    row: anArray [
	"Since nil is a possible key value, use self as a special marker to indicate we haven't found the key yet"

	<category: 'accessing'>
	row == anArray ifFalse: [key := self].
	row := anArray
    ]

    session [
	<category: 'accessing'>
	^expression descriptor session
    ]

    system [
	<category: 'accessing'>
	^self session system
    ]

    hasFieldTranslations [
	<category: 'executing'>
	^self fieldTranslations notNil
    ]

    buildObjectFrom: anArray [
	<category: 'building objects'>
	self subclassResponsibility
    ]

    findInstanceForRow: aRow useProxy: useProxies [
	<category: 'building objects'>
	self subclassResponsibility
    ]

    knitResultIn: aSimpleQuery [
	"Connect up our built object with any other builders that use the same thing"

	<category: 'building objects'>
	^self
    ]

    registerObjectInUnitOfWork [
	"If there is a current unit of work, then we must register in it, after population because that way the state is already in place. The nil checks are mostly for safety during unit tests, as those conditions should never occur in real use"

	<category: 'building objects'>
	query isNil ifTrue: [^self].
	query session isNil ifTrue: [^self].
	query session register: instance
    ]

    fieldsFromMyPerspective [
	<category: 'selecting fields'>
	self subclassResponsibility
    ]

    translateFieldPosition: aDatabaseField [
	<category: 'translating fields'>
	fieldTranslations isNil ifTrue: [^aDatabaseField position].
	^fieldTranslations at: aDatabaseField
    ]

    valueOf: anExpression [
	<category: 'translating fields'>
	^expression valueInBuilder: self
    ]

    valueOfField: aField [
	"aField is either a database field, or a constant expression containing a non-varying value that isn't derived from the row"

	<category: 'translating fields'>
	aField class == ConstantExpression ifTrue: [^aField value].
	^self row atIndex: (self translateFieldPosition: aField)
    ]

    valueOfField: aField in: aRow [
	"Since the elementBuilder now holds the row, #valueOfField: is preferred protocol, but some things (e.g. ad hoc mapping blocks) might still be using this, so left for compatibility"

	<category: 'translating fields'>
	aField class == ConstantExpression ifTrue: [^aField value].
	^aRow atIndex: (self translateFieldPosition: aField)
    ]

    initialize [
	<category: 'initializing'>
	
    ]
]



Object subclass: GlorpSession [
    | system currentUnitOfWork cache accessor applicationData reusePreparedStatements |
    
    <category: 'Glorp-Core'>
    <comment: '
This class has not yet been commented.  The comment should state the purpose of the class, what messages are subclassResponsibility, and the type and purpose of each instance and class variable.  The comment should also explain any unobvious aspects of the implementation.

Instance Variables:

    system	<ClassOfVariable>	description of variable''s function
    currentUnitOfWork	<ClassOfVariable>	description of variable''s function
    cache	<ClassOfVariable>	description of variable''s function
    accessor	<ClassOfVariable>	description of variable''s function
    application	<ClassOfVariable>	application-specific data'>

    GlorpSession class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    GlorpSession class >> forSystem: aSystem [
	<category: 'instance creation'>
	^self new system: aSystem
    ]

    GlorpSession class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    expiredInstanceOf: aClass key: key [
	<category: 'private'>
	^cache expiredInstanceOf: aClass key: key
    ]

    markAsCurrentOfClass: aClass key: key [
	<category: 'private'>
	cache markAsCurrentOfClass: aClass key: key
    ]

    privateGetCache [
	<category: 'private'>
	^cache
    ]

    privateGetCurrentUnitOfWork [
	<category: 'private'>
	^currentUnitOfWork
    ]

    realObjectFor: anObject [
	"If this is a proxy, return the contents (if available). Otherwise, return nil"

	<category: 'private'>
	^self realObjectFor: anObject ifNone: [nil]
    ]

    realObjectFor: anObject ifNone: aBlock [
	"If this is a proxy, return the contents (if available). Otherwise, evalute the block"

	<category: 'private'>
	^anObject class == Proxy 
	    ifTrue: 
		[anObject isInstantiated ifTrue: [anObject getValue] ifFalse: [aBlock value]]
	    ifFalse: [anObject]
    ]

    sendPostFetchEventTo: anObject [
	<category: 'events'>
	anObject glorpPostFetch: self
    ]

    sendPostWriteEventTo: anObject [
	<category: 'events'>
	anObject glorpPostWrite: self
    ]

    sendPreWriteEventTo: anObject [
	<category: 'events'>
	anObject glorpPreWrite: self
    ]

    delete: anObject [
	<category: 'api/queries'>
	"Get the real object, instantiating if necessary"

	| realObject |
	realObject := anObject yourself.
	self hasUnitOfWork 
	    ifTrue: [currentUnitOfWork delete: realObject]
	    ifFalse: 
		[self beginUnitOfWork.
		currentUnitOfWork delete: realObject.
		self commitUnitOfWork]
    ]

    execute: aQuery [
	<category: 'api/queries'>
	| preliminaryResult |
	preliminaryResult := aQuery executeIn: self.
	^aQuery readsOneObject 
	    ifTrue: [self filterDeletionFrom: preliminaryResult]
	    ifFalse: [self filterDeletionsFrom: preliminaryResult]
    ]

    hasExpired: anObject [
	<category: 'api/queries'>
	^cache hasExpired: anObject
    ]

    readManyOf: aClass [
	<category: 'api/queries'>
	^self execute: (Query returningManyOf: aClass)
    ]

    readManyOf: aClass where: aBlock [
	<category: 'api/queries'>
	^self execute: (Query returningManyOf: aClass where: aBlock)
    ]

    readOneOf: aClass where: aBlock [
	<category: 'api/queries'>
	^self execute: (Query returningOneOf: aClass where: aBlock)
    ]

    refresh: anObject [
	<category: 'api/queries'>
	| exp query realObject descriptor |
	realObject := self realObjectFor: anObject ifNone: [^self].
	descriptor := self descriptorFor: realObject.
	descriptor isNil 
	    ifTrue: [self error: 'Cannot refresh an object with no descriptor'].
	exp := descriptor primaryKeyExpressionFor: realObject.
	query := Query returningOneOf: realObject class where: exp.
	query shouldRefresh: true.
	^self execute: query
    ]

    accessor [
	<category: 'accessing'>
	^accessor
    ]

    accessor: aDatabaseAccessor [
	<category: 'accessing'>
	accessor := aDatabaseAccessor.
	system isNil ifFalse: [system platform: accessor platform]
    ]

    applicationData [
	<category: 'accessing'>
	^applicationData
    ]

    applicationData: anObject [
	<category: 'accessing'>
	applicationData := anObject
    ]

    platform [
	<category: 'accessing'>
	^self system platform
    ]

    reusePreparedStatements: aBoolean [
	<category: 'accessing'>
	reusePreparedStatements := aBoolean
    ]

    system [
	<category: 'accessing'>
	^system
    ]

    copy [
	<category: 'copying'>
	^self shallowCopy postCopy
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	self initializeCache.
	currentUnitOfWork := nil.
	accessor := accessor copy
    ]

    descriptorFor: aClassOrInstance [
	<category: 'api'>
	^system descriptorFor: aClassOrInstance
    ]

    hasDescriptorFor: aClass [
	<category: 'api'>
	^system hasDescriptorFor: aClass
    ]

    register: anObject [
	<category: 'api'>
	| realObject |
	currentUnitOfWork isNil ifTrue: [^self].
	realObject := self realObjectFor: anObject ifNone: [^self].
	(self isNew: realObject) 
	    ifTrue: [currentUnitOfWork registerAsNew: realObject]
	    ifFalse: [currentUnitOfWork register: realObject]
    ]

    registerAsNew: anObject [
	<category: 'api'>
	currentUnitOfWork isNil ifTrue: [^self].
	currentUnitOfWork registerAsNew: anObject
    ]

    system: aSystem [
	<category: 'api'>
	aSystem session: self.
	accessor isNil ifFalse: [aSystem platform: accessor currentLogin database].
	system := aSystem
    ]

    filterDeletionFrom: anObject [
	<category: 'read/write'>
	self hasUnitOfWork ifFalse: [^anObject].
	(currentUnitOfWork willDelete: anObject) ifTrue: [^nil].
	^anObject
    ]

    filterDeletionsFrom: aCollection [
	"This will need to change if we have cursored collections"

	<category: 'read/write'>
	self hasUnitOfWork ifFalse: [^aCollection].
	currentUnitOfWork hasPendingDeletions ifFalse: [^aCollection].
	^aCollection reject: [:each | currentUnitOfWork willDelete: each]
    ]

    writeRow: aDatabaseRow [
	<category: 'read/write'>
	| command |
	aDatabaseRow shouldBeWritten ifFalse: [^self].
	aDatabaseRow preWriteAssignSequencesUsing: self.
	command := self commandForRow: aDatabaseRow.
	self reusePreparedStatements 
	    ifTrue: [accessor executeCommandReusingPreparedStatements: command]
	    ifFalse: [accessor executeCommand: command].
	aDatabaseRow postWriteAssignSequencesUsing: self
    ]

    commandForRow: aDatabaseRow [
	<category: 'internal/writing'>
	aDatabaseRow forDeletion 
	    ifTrue: 
		[^DeleteCommand 
		    forRow: aDatabaseRow
		    useBinding: self useBinding
		    platform: self platform].
	^(self shouldInsert: aDatabaseRow) 
	    ifTrue: 
		[^InsertCommand 
		    forRow: aDatabaseRow
		    useBinding: self useBinding
		    platform: self platform]
	    ifFalse: 
		[^UpdateCommand 
		    forRow: aDatabaseRow
		    useBinding: self useBinding
		    platform: self platform]
    ]

    createDeleteRowsFor: anObject in: rowMap [
	"Create records for rows that require deletion"

	<category: 'internal/writing'>
	(self descriptorFor: anObject) createDeleteRowsFor: anObject in: rowMap
    ]

    createRowsFor: anObject in: rowMap [
	<category: 'internal/writing'>
	| descriptor |
	descriptor := self descriptorFor: anObject class.
	descriptor isNil ifFalse: [descriptor createRowsFor: anObject in: rowMap]
    ]

    shouldInsert: aDatabaseRow [
	<category: 'internal/writing'>
	^(self cacheContainsObjectForRow: aDatabaseRow) not
    ]

    tablesInCommitOrder [
	<category: 'internal/writing'>
	^(TableSorter for: system allTables) sort
    ]

    cacheAt: aKey forClass: aClass ifNone: failureBlock [
	<category: 'caching'>
	^cache 
	    lookupClass: aClass
	    key: aKey
	    ifAbsent: failureBlock
    ]

    cacheAt: keyObject put: valueObject [
	<category: 'caching'>
	^cache at: keyObject insert: valueObject
    ]

    cacheContainsObjectForClass: aClass key: aKey [
	"Just test containment, don't return the result or trigger anything due to expiration"

	<category: 'caching'>
	^cache containsObjectForClass: aClass key: aKey
    ]

    cacheContainsObjectForRow: aDatabaseRow [
	<category: 'caching'>
	^self cacheContainsObjectForClass: aDatabaseRow owner class
	    key: aDatabaseRow primaryKey
    ]

    cacheLookupForClass: aClass key: aKey [
	<category: 'caching'>
	^self 
	    cacheAt: aKey
	    forClass: aClass
	    ifNone: [nil]
    ]

    cacheLookupObjectForRow: aDatabaseRow [
	<category: 'caching'>
	^self cacheLookupForClass: aDatabaseRow owner class
	    key: aDatabaseRow primaryKey
    ]

    cacheRemoveObject: anObject [
	<category: 'caching'>
	| key |
	key := (self descriptorFor: anObject) primaryKeyFor: anObject.
	cache 
	    removeClass: anObject class
	    key: key
	    ifAbsent: []
    ]

    hasExpired: aClass key: key [
	<category: 'caching'>
	^cache hasExpired: aClass key: key
    ]

    hasObjectExpiredOfClass: aClass withKey: key [
	<category: 'caching'>
	^cache hasObjectExpiredOfClass: aClass withKey: key
    ]

    isRegistered: anObject [
	<category: 'caching'>
	currentUnitOfWork isNil ifTrue: [^false].
	^currentUnitOfWork isRegistered: anObject
    ]

    lookupRootClassFor: aClass [
	<category: 'caching'>
	| descriptor |
	descriptor := self system descriptorFor: aClass.
	^descriptor notNil 
	    ifTrue: [descriptor typeMappingRootDescriptor describedClass]
	    ifFalse: [aClass]
    ]

    isNew: anObject [
	"When registering, do we need to add this object to the collection of new objects? New objects are treated specially when computing what needs to be written, since we don't have their previous state"

	"This will break for composite keys (Really? Why? Do we need to test that if the key is a collection with a nil value, rather than just nil?)"

	<category: 'testing'>
	| key descriptor |
	(currentUnitOfWork isRegistered: anObject) ifTrue: [^false].
	descriptor := self descriptorFor: anObject.
	descriptor isNil ifTrue: [^false].
	"For embedded values we assume that they are not new. This appears to work. I can't really justify it."
	self needsWork: 'cross your fingers'.
	descriptor mapsPrimaryKeys ifFalse: [^false].
	key := descriptor primaryKeyFor: anObject.
	key isNil ifTrue: [^true].
	^(self cacheContainsObjectForClass: anObject class key: key) not
    ]

    isUninstantiatedProxy: anObject [
	<category: 'testing'>
	^anObject class == Proxy and: [anObject isInstantiated not]
    ]

    reusePreparedStatements [
	<category: 'testing'>
	^reusePreparedStatements and: [self useBinding]
    ]

    useBinding [
	<category: 'testing'>
	^self platform useBinding
    ]

    beginTransaction [
	<category: 'api/transactions'>
	accessor beginTransaction
    ]

    beginUnitOfWork [
	<category: 'api/transactions'>
	self hasUnitOfWork ifTrue: [self error: 'Cannot nest units of work yet'].
	currentUnitOfWork := UnitOfWork new.
	currentUnitOfWork session: self
    ]

    commitTransaction [
	<category: 'api/transactions'>
	accessor commitTransaction
    ]

    commitUnitOfWork [
	<category: 'api/transactions'>
	self isInTransaction 
	    ifTrue: [currentUnitOfWork commit]
	    ifFalse: [self inTransactionDo: [currentUnitOfWork commit]].
	currentUnitOfWork := nil
    ]

    hasUnitOfWork [
	<category: 'api/transactions'>
	^currentUnitOfWork notNil
    ]

    inTransactionDo: aBlock [
	<category: 'api/transactions'>
	| alreadyInTransaction |
	
	[alreadyInTransaction := self isInTransaction.
	alreadyInTransaction ifFalse: [self beginTransaction].
	aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
	alreadyInTransaction ifFalse: [self commitTransaction]] 
		ifCurtailed: [alreadyInTransaction ifFalse: [self rollbackTransaction]]
    ]

    inUnitOfWorkDo: aBlock [
	<category: 'api/transactions'>
	
	[self beginUnitOfWork.
	aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
	self commitUnitOfWork] 
		ifCurtailed: [self rollbackUnitOfWork]
    ]

    isInTransaction [
	<category: 'api/transactions'>
	^accessor isInTransaction
    ]

    rollbackTransaction [
	<category: 'api/transactions'>
	accessor doCommand: [accessor rollbackTransaction] ifError: [:ex | ]
    ]

    rollbackUnitOfWork [
	<category: 'api/transactions'>
	currentUnitOfWork abort.
	currentUnitOfWork := nil
    ]

    transact: aBlock [
	"Evaluate aBlock inside a unit of work. Start a database transaction at the beginning and commit it at the end. If we don' terminate normally, roll everything back.  This might more consistently be  called inUnitOfWorkWithTransactionDo:, but that's too verbose"

	<category: 'api/transactions'>
	| alreadyInTransaction |
	
	[
	[alreadyInTransaction := self isInTransaction.
	alreadyInTransaction ifFalse: [self beginTransaction].
	self beginUnitOfWork.
	aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
	self commitUnitOfWork.
	alreadyInTransaction ifFalse: [self commitTransaction]] 
		ifCurtailed: [self rollbackUnitOfWork]] 
		ifCurtailed: [alreadyInTransaction ifFalse: [self rollbackTransaction]]
    ]

    initialize [
	<category: 'initialize'>
	reusePreparedStatements := true.
	self initializeCache
    ]

    initializeCache [
	<category: 'initialize'>
	cache := CacheManager forSession: self
    ]

    reset [
	<category: 'initialize'>
	self initializeCache.
	accessor reset.
	currentUnitOfWork := nil
    ]

    virtualCollectionOf: aClass [
	<category: 'virtual collections'>
	^GlorpVirtualCollection on: aClass in: self
    ]
]



Object subclass: TableSorter [
    | orderedTables tables visitedTables |
    
    <category: 'Glorp-Queries'>
    <comment: nil>

    TableSorter class >> for: tables [
	<category: 'instance creation'>
	| sorter |
	sorter := self new.
	tables do: [:each | sorter addTable: each].
	^sorter
    ]

    TableSorter class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    TableSorter class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    addTable: aTable [
	<category: 'accessing'>
	tables add: aTable
    ]

    hasBeenVisited: aTable [
	<category: 'accessing'>
	^visitedTables includes: aTable
    ]

    markVisited: aTable [
	<category: 'accessing'>
	visitedTables add: aTable
    ]

    sort [
	<category: 'sorting'>
	orderedTables := OrderedCollection new: tables size.
	tables do: [:each | self visit: each].
	^orderedTables
    ]

    visit: aTable [
	"The essential bit of topological sort. Visit each node in post-order, traversing dependencies, based on foreign key constraints to database-generated fields."

	<category: 'sorting'>
	(self hasBeenVisited: aTable) ifTrue: [^self].
	self markVisited: aTable.
	self visitDependentTablesFor: aTable.
	orderedTables add: aTable
    ]

    visitDependentTablesFor: aTable [
	<category: 'sorting'>
	aTable foreignKeyConstraints do: 
		[:eachConstraint | 
		| fieldFromOtherTable |
		fieldFromOtherTable := eachConstraint targetField.
		self visit: fieldFromOtherTable table]
    ]

    initialize [
	<category: 'initializing'>
	tables := OrderedCollection new: 100.
	visitedTables := IdentitySet new: 100
    ]
]



Mapping subclass: DictionaryMapping [
    | keyMapping valueMapping |
    
    <category: 'Glorp-Mappings'>
    <comment: '
This allows us to map a dictionary into tables. This breaks down into many cases.
String->Object
Object->Object
with representation either like a 1-many or like a many-many with information in the link table. The general idea is that we represent this as a compound mapping that can describe how the key maps and how the values maps. 

Instance Variables:

    keyMapping	<ClassOfVariable>	description of variable''s function
    valueMapping	<ClassOfVariable>	description of variable''s function'>

    DictionaryMapping class >> attributeName: aSymbol keyMapping: keyMapping valueMapping: valueMapping [
	<category: 'instance creation'>
	^(self new)
	    attributeName: aSymbol;
	    keyMapping: keyMapping;
	    valueMapping: valueMapping
    ]

    DictionaryMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    keyMapping: aMapping [
	<category: 'accessing'>
	keyMapping := aMapping
    ]

    valueMapping: aMapping [
	<category: 'accessing'>
	valueMapping := aMapping
    ]
]



Object subclass: Tracing [
    | base allTracings retrievalExpressions alsoFetchExpressions |
    
    <category: 'Glorp-Queries'>
    <comment: '
A tracing is a collection of expressions representing the graph of other objects which
are to be read at the same time as the root object.

Instance Variables:

    base	<Expression>	The base expression representing the root object. Same as the parameter to the query block
    allTracings	<Collection of: Expression>	The expressions representing each of the associated objects. e.g. base accounts, base amount serviceCharge .
    alsoFetchExpressions	<(Collection of: GlorpExpression)>	Objects to also retrieve, but not included in the result set, just knitted together with the other related objects.
    retrievalExpressions	<(Collection of: GlorpExpression)>	Objects to also retrieve, and to include in teh result set

'>

    Tracing class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    Tracing class >> for: aQuery [
	<category: 'instance creation'>
	^self new base: aQuery criteria ultimateBaseExpression
    ]

    Tracing class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    addExpression: anExpression [
	<category: 'accessing'>
	self addExpression: anExpression andDo: [:ignore | ]
    ]

    addExpression: anExpression andDo: aBlock [
	<category: 'accessing'>
	| exp |
	exp := anExpression asGlorpExpressionOn: base.
	(allTracings includes: exp) 
	    ifFalse: 
		[allTracings add: exp.
		aBlock value: exp]
    ]

    additionalExpressions [
	<category: 'accessing'>
	| all |
	alsoFetchExpressions isEmpty ifTrue: [^retrievalExpressions].
	all := OrderedCollection new.
	all addAll: self retrievalExpressions.
	all addAll: self alsoFetchExpressions.
	^all
    ]

    allTracings [
	<category: 'accessing'>
	^allTracings
    ]

    alsoFetchExpressions [
	<category: 'accessing'>
	^alsoFetchExpressions
    ]

    base [
	<category: 'accessing'>
	^base
    ]

    base: anExpression [
	<category: 'accessing'>
	base := anExpression
    ]

    retrievalExpressions [
	<category: 'accessing'>
	^retrievalExpressions
    ]

    setup [
	"We have been put into a query. If we aren't to trace anything else, trace the base"

	<category: 'setup'>
	retrievalExpressions isEmpty 
	    ifTrue: 
		[allTracings add: base.
		retrievalExpressions add: base]
    ]

    updateBase: aBaseExpression [
	"Make sure we have the same base as the query"

	<category: 'setup'>
	| transformed |
	transformed := IdentityDictionary new.
	base == aBaseExpression ifTrue: [^self].
	base := aBaseExpression.
	allTracings := allTracings collect: 
			[:each | 
			| new |
			new := each asGlorpExpressionOn: base.
			transformed at: each put: new.
			new].
	retrievalExpressions := retrievalExpressions 
		    collect: [:each | transformed at: each].
	alsoFetchExpressions := alsoFetchExpressions 
		    collect: [:each | transformed at: each]
    ]

    alsoFetch: anExpression [
	"Add the expression as something which will be explicitly retrieved and knit together with other results, but NOT included in the result list"

	<category: 'api'>
	self addExpression: anExpression
	    andDo: [:exp | alsoFetchExpressions add: exp]
    ]

    retrieve: anExpression [
	"Add the expression as something which will be explicitly retrieved and knit together with other results, but NOT included in the result list"

	<category: 'api'>
	self addExpression: anExpression
	    andDo: [:exp | retrievalExpressions add: exp]
    ]

    initialize [
	<category: 'initialize'>
	base := BaseExpression new.
	allTracings := OrderedCollection new: 2.
	retrievalExpressions := Set new: 3.
	alsoFetchExpressions := Set new: 3
    ]

    tracesThrough: aMapping [
	<category: 'querying'>
	^aMapping isStoredInSameTable
    ]
]



Object subclass: RowMap [
    | rowDictionary |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: nil>

    RowMap class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    RowMap class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    adjustForMementos: objects [
	<category: 'private/mapping'>
	^self
    ]

    collectionMementoFor: aCollection [
	<category: 'private/mapping'>
	^aCollection
    ]

    dictionaryClassRequiredForKeysOfType: aClass [
	<category: 'private/mapping'>
	^(aClass == RowMapKey or: [aClass == MultipleRowMapKey]) 
	    ifTrue: [Dictionary]
	    ifFalse: [IdentityDictionary]
    ]

    reverseLookup: anObject [
	<category: 'private/mapping'>
	^anObject
    ]

    rowsForKey: aKey [
	"Return a collection of all rows for any table which are keyed by aKey"

	<category: 'private/mapping'>
	| rowsForKey |
	rowsForKey := OrderedCollection new: 5.
	rowDictionary do: 
		[:each | 
		| row |
		row := each at: aKey ifAbsent: [nil].
		row isNil ifFalse: [rowsForKey add: row]].
	^rowsForKey
    ]

    subMapForTable: aTable [
	<category: 'private/mapping'>
	^self subMapForTable: aTable withKey: nil
    ]

    subMapForTable: aTable ifAbsent: aBlock [
	<category: 'private/mapping'>
	^rowDictionary at: aTable ifAbsent: aBlock
    ]

    subMapForTable: aTable withKey: anObject [
	<category: 'private/mapping'>
	^rowDictionary at: aTable
	    ifAbsentPut: [(self dictionaryClassRequiredForKeysOfType: anObject class) new]
    ]

    tables [
	<category: 'private/mapping'>
	^rowDictionary keys
    ]

    addRow: aRow forTable: aTable withKey: aKey [
	<category: 'lookup'>
	| submap |
	submap := self subMapForTable: aTable withKey: aKey.
	^submap at: aKey put: aRow
    ]

    findOrAddRowForTable: aTable withKey: aKey [
	<category: 'lookup'>
	| submap |
	submap := self subMapForTable: aTable withKey: aKey.
	^submap at: aKey
	    ifAbsentPut: [DatabaseRow newForTable: aTable withOwner: aKey]
    ]

    includesRowForTable: aTable withKey: aKey [
	<category: 'lookup'>
	(self subMapForTable: aTable ifAbsent: [^false]) at: aKey
	    ifAbsent: [^false].
	^true
    ]

    rowForTable: aTable withKey: aKey [
	<category: 'lookup'>
	^(self subMapForTable: aTable) at: aKey
    ]

    rowForTable: aTable withKey: aKey ifAbsent: aBlock [
	<category: 'lookup'>
	^(self subMapForTable: aTable) at: aKey ifAbsent: aBlock
    ]

    numberOfEntries [
	<category: 'counting'>
	^rowDictionary inject: 0 into: [:sum :each | sum + each size]
    ]

    numberOfEntriesForTable: aTable [
	<category: 'counting'>
	^(self subMapForTable: aTable) size
    ]

    keysAndValuesDo: aBlock [
	<category: 'iterating'>
	self tables 
	    do: [:each | (self subMapForTable: each) keysAndValuesDo: aBlock]
    ]

    objects [
	<category: 'iterating'>
	| objects |
	objects := IdentitySet new.
	self tables do: [:each | objects addAll: (self subMapForTable: each) keys].
	^objects
    ]

    objectsAndRowsDo: aTwoArgumentBlock [
	<category: 'iterating'>
	rowDictionary 
	    do: [:eachObjectToRowDictionary | eachObjectToRowDictionary keysAndValuesDo: aTwoArgumentBlock]
    ]

    objectsAndRowsForTable: aTable do: aTwoArgumentBlock [
	<category: 'iterating'>
	^(self subMapForTable: aTable) keysAndValuesDo: aTwoArgumentBlock
    ]

    rowsDo: aBlock [
	<category: 'iterating'>
	self tables do: [:each | self rowsForTable: each do: aBlock]
    ]

    rowsForTable: aTable do: aBlock [
	<category: 'iterating'>
	^(self subMapForTable: aTable) do: aBlock
    ]

    additiveDifferencesFrom: aRowMap into: differencesMap [
	<category: 'set operations'>
	self objectsAndRowsDo: 
		[:object :row | 
		| correspondingRow |
		correspondingRow := aRowMap 
			    rowForTable: row table
			    withKey: object
			    ifAbsent: [DatabaseRow new].
		(row equals: correspondingRow) 
		    ifFalse: 
			[differencesMap 
			    addRow: (row withAllFieldsIn: correspondingRow)
			    forTable: row table
			    withKey: object]]
    ]

    differenceFrom: aRowMap [
	<category: 'set operations'>
	| differencesMap |
	differencesMap := RowMap new.
	self additiveDifferencesFrom: aRowMap into: differencesMap.
	self subtractiveDifferencesFrom: aRowMap into: differencesMap.
	^differencesMap
    ]

    subtractiveDifferencesFrom: aRowMap into: differencesMap [
	"Figure out which things are in aRowMap but not in us. These should be flagged as delete rows"

	<category: 'set operations'>
	aRowMap objectsAndRowsDo: 
		[:object :row | 
		| adjustedObject |
		adjustedObject := aRowMap reverseLookup: object.
		self 
		    rowForTable: row table
		    withKey: adjustedObject
		    ifAbsent: 
			[row forDeletion: true.
			differencesMap 
			    addRow: row
			    forTable: row table
			    withKey: adjustedObject]]
    ]

    isEmpty [
	<category: 'tests'>
	self rowsDo: [:each | ^false].
	^true
    ]

    notEmpty [
	<category: 'tests'>
	^self isEmpty not
    ]

    initialize [
	<category: 'initialize/release'>
	rowDictionary := IdentityDictionary new
    ]
]



Object subclass: DatabaseType [
    | name platform typeString |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: nil>

    DatabaseType class >> instance [
	<category: 'instance creation'>
	^super new
    ]

    DatabaseType class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    DatabaseType class >> padToTwoDigits: anInteger [
	<category: 'printing'>
	| string |
	string := anInteger printString.
	^string size = 1 ifTrue: ['0' , string] ifFalse: [string]
    ]

    DatabaseType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    hasParameters [
	"Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"

	<category: 'testing'>
	^false
    ]

    hasSequence [
	<category: 'testing'>
	^false
    ]

    isGenerated [
	<category: 'testing'>
	^false
    ]

    isStringType [
	"Return true if the type of values this stores are strings"

	<category: 'testing'>
	^false
    ]

    isVariable [
	<category: 'testing'>
	^false
    ]

    isVariableWidth [
	"Return true if this type allows varying length data within a particular instance. e.g., this is true for a varchar, but false for a fixed size character field"

	<category: 'testing'>
	^false
    ]

    platform [
	<category: 'SQL'>
	^platform
    ]

    platform: aDatabasePlatform [
	<category: 'SQL'>
	platform := aDatabasePlatform
    ]

    postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow [
	<category: 'SQL'>
	
    ]

    postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'SQL'>
	
    ]

    preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'SQL'>
	
    ]

    print: aValue on: aStream [
	<category: 'SQL'>
	aValue glorpPrintSQLOn: aStream
    ]

    printCollection: aCollection on: aStream [
	<category: 'SQL'>
	aCollection glorpPrintSQLOn: aStream for: self
    ]

    typeString [
	<category: 'SQL'>
	^typeString
    ]

    precision: anInteger [
	<category: 'accessing'>
	^self 
	    error: self class name asString , ' is not a variable precision type.'
    ]

    scale: anInteger [
	<category: 'accessing'>
	^self error: self class name asString , ' is not a variable scale type.'
    ]

    size: anInteger [
	<category: 'accessing'>
	^self error: self class name asString , ' is not a variable sized type.'
    ]

    typeString: aString [
	<category: 'accessing'>
	typeString := aString
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    initializeForField: aDatabaseField in: aDescriptorSystem [
	<category: 'initialize'>
	
    ]

    converterForStType: aClass [
	<category: 'converting'>
	^self platform nullConverter
    ]

    impliedSmalltalkType [
	"Return the Smalltalk type which most commonly corresponds to our database type. By default, Object if we don't have any more specific information."

	<category: 'converting'>
	^Object
    ]
]



DatabaseType subclass: TimeStampType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    TimeStampType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    converterForStType: aClass [
	<category: 'converting'>
	^self platform converterNamed: #timestamp
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Dialect timestampClass
    ]

    print: aValue on: aStream [
	<category: 'SQL'>
	aStream nextPutAll: (self platform printTimestamp: aValue for: self)
    ]
]



DatabaseType subclass: InMemorySequenceDatabaseType [
    | representationType |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    InMemorySequenceDatabaseType class [
	| Count |
	
    ]

    InMemorySequenceDatabaseType class >> next [
	<category: 'accessing'>
	Count isNil ifTrue: [Count := 0].
	Count := Count + 1.
	^Count
    ]

    InMemorySequenceDatabaseType class >> reset [
	<category: 'accessing'>
	Count := 0
    ]

    InMemorySequenceDatabaseType class >> representedBy: dbType [
	<category: 'instance creation'>
	^super new representedBy: dbType
    ]

    InMemorySequenceDatabaseType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Integer
    ]

    representedBy: dbType [
	<category: 'initialize-release'>
	representationType := dbType
    ]

    isGenerated [
	<category: 'testing'>
	^true
    ]

    preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'SQL'>
	aDatabaseRow at: aDatabaseField put: self class next
    ]

    typeString [
	<category: 'SQL'>
	^representationType typeString
    ]
]



DatabaseType subclass: AbstractNumericType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    AbstractNumericType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Number
    ]
]



DatabaseType subclass: AbstractStringType [
    | width |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    AbstractStringType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    hasParameters [
	"Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"

	<category: 'testing'>
	^true
    ]

    isStringType [
	<category: 'testing'>
	^true
    ]

    width [
	<category: 'accessing'>
	^width
    ]

    width: anInteger [
	<category: 'accessing'>
	width := anInteger
    ]

    converterForStType: aClass [
	<category: 'converting'>
	(aClass includesBehavior: Boolean) 
	    ifTrue: [^self platform converterNamed: #booleanToStringTF].
	(aClass includesBehavior: Symbol) 
	    ifTrue: [^self platform converterNamed: #symbolToString].
	width isNil 
	    ifFalse: 
		[(aClass includesBehavior: String) 
		    ifTrue: [^self platform converterNamed: #stringToString]].
	^super converterForStType: aClass
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^String
    ]
]



Object subclass: DatabaseRow [
    | table contents shouldBeWritten owner forDeletion |
    
    <category: 'Glorp-Database'>
    <comment: '
This represents the data to be written out to a row. Database rows are normally stored in a rowmap, keyed according to their table and the object that did the primary writes to them. We expect that that''s only one object, although embedded values are an exception to that.

Instance Variables:

    table	<DatabaseTable>	The table holding the data
    contents	<IdentityDictionary>	Holds the fields with their values, indirectly through FieldValueWrapper instances.
    shouldBeWritten	<Boolean>	Normally true, but can be set false to suppress writing of a particular row. Used with embedded value mappings, where we create their row, unify it with the parent row, and suppress writing of the original row.
    owner	<Object>	The primary object that wrote into this row, would also be the key into the rowmap.'>

    DatabaseRow class [
	| missingFieldIndicator |
	
    ]

    DatabaseRow class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    DatabaseRow class >> newForTable: aTable [
	<category: 'instance creation'>
	^self new table: aTable
    ]

    DatabaseRow class >> newForTable: aTable withOwner: anObject [
	<category: 'instance creation'>
	^(self new)
	    table: aTable;
	    owner: anObject
    ]

    DatabaseRow class >> missingFieldIndicator [
	<category: 'private'>
	missingFieldIndicator == nil ifTrue: [missingFieldIndicator := Object new].
	^missingFieldIndicator
    ]

    DatabaseRow class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    fieldsAndValidValuesDo: aBlock [
	"If iterating over fields and values, we include wrappers with no value assigned yet. This might or might not be what we want. This one just iterates over ones with actual values"

	<category: 'initializing'>
	self isEmpty ifTrue: [^self].
	table fields do: 
		[:each | 
		| value |
		value := self at: each ifAbsent: [self class missingFieldIndicator].
		value == self class missingFieldIndicator 
		    ifFalse: [aBlock value: each value: value]]
    ]

    fieldsAndValuesDo: aBlock [
	<category: 'initializing'>
	table fields do: 
		[:each | 
		aBlock value: each
		    value: (self at: each ifAbsent: [self class missingFieldIndicator])]
    ]

    initialize [
	<category: 'initializing'>
	contents := IdentityDictionary new.
	shouldBeWritten := true.
	forDeletion := false
    ]

    postWriteAssignSequencesUsing: aSession [
	<category: 'sequencing'>
	self table fields do: 
		[:each | 
		(self hasValueFor: each) 
		    ifFalse: 
			[each type 
			    postWriteAssignSequenceValueFor: each
			    in: self
			    using: aSession]]
    ]

    preWriteAssignSequencesUsing: aSession [
	<category: 'sequencing'>
	self table fields do: 
		[:each | 
		(self hasValueFor: each) 
		    ifFalse: 
			[each type 
			    preWriteAssignSequenceValueFor: each
			    in: self
			    using: aSession]]
    ]

    hasValueFor: aField [
	<category: 'querying'>
	^(self wrapperAt: aField ifAbsent: [^false]) hasValue
    ]

    shouldBeWritten [
	<category: 'querying'>
	^shouldBeWritten
    ]

    fieldsDo: aBlock [
	<category: 'enumerating'>
	contents keysDo: [:each | aBlock value: each]
    ]

    fieldValuesDo: aBlock [
	<category: 'enumerating'>
	contents do: aBlock
    ]

    keysAndValuesDo: aBlock [
	<category: 'enumerating'>
	contents 
	    keysAndValuesDo: [:eachKey :eachValue | aBlock value: eachKey value: eachValue contents]
    ]

    at: aField [
	<category: 'accessing'>
	^self at: aField ifAbsent: [self error: 'missing field']
    ]

    at: aField ifAbsent: absentBlock [
	<category: 'accessing'>
	^(self wrapperAt: aField ifAbsent: [^absentBlock value]) contents
    ]

    at: aField put: aValue [
	"For generated fields, we expect the real value to be provided later by the database, so don't write a nil value"

	<category: 'accessing'>
	| wrapper |
	aValue isGlorpExpression 
	    ifTrue: [self error: 'cannot store expressions in rows'].
	aField table == self table ifFalse: [self error: 'Invalid table'].
	wrapper := contents at: aField ifAbsentPut: [FieldValueWrapper new].
	(aValue isNil and: [aField isGenerated]) 
	    ifFalse: [wrapper contents: aValue].
	^wrapper
    ]

    atFieldNamed: aString [
	<category: 'accessing'>
	| field |
	field := table fieldNamed: aString.
	^self at: field
    ]

    atFieldNamed: aString put: anObject [
	<category: 'accessing'>
	| field |
	field := table fieldNamed: aString.
	^self at: field put: anObject
    ]

    fields [
	<category: 'accessing'>
	^contents keys
    ]

    forDeletion [
	<category: 'accessing'>
	^forDeletion
    ]

    forDeletion: aBoolean [
	<category: 'accessing'>
	forDeletion := aBoolean
    ]

    includesField: aField [
	<category: 'accessing'>
	^contents includesKey: aField
    ]

    nonGeneratedFieldsWithValues [
	"Return a list of our fields that a) are not generated or b) have values. That is, exclude values we expect the database to generate"

	<category: 'accessing'>
	| result |
	result := OrderedCollection new: contents size.
	self fieldsAndValidValuesDo: 
		[:field :value | 
		(value notNil or: [field isGenerated not]) ifTrue: [result add: field]].
	^result
    ]

    nonPrimaryKeyFields [
	<category: 'accessing'>
	| result |
	result := OrderedCollection new: contents size.
	self fieldsDo: [:field | field isPrimaryKey ifFalse: [result add: field]].
	^result
    ]

    numberOfFields [
	<category: 'accessing'>
	^contents size
    ]

    owner [
	<category: 'accessing'>
	^owner
    ]

    owner: anObject [
	<category: 'accessing'>
	owner := anObject
    ]

    primaryKey [
	<category: 'accessing'>
	self table primaryKeyFields isEmpty ifTrue: [^nil].
	^self table hasCompositePrimaryKey 
	    ifTrue: [self table primaryKeyFields collect: [:each | self at: each]]
	    ifFalse: [self at: self table primaryKeyFields first]
    ]

    table [
	"Private - Answer the value of the receiver's ''table'' instance variable."

	<category: 'accessing'>
	^table
    ]

    wrapperAt: aField [
	<category: 'accessing'>
	^self wrapperAt: aField ifAbsent: [self error: 'Field not found']
    ]

    wrapperAt: aField ifAbsent: aBlock [
	<category: 'accessing'>
	^contents at: aField ifAbsent: aBlock
    ]

    wrapperAt: aField put: aWrapper [
	"Slightly wacky code to try and run faster"

	<category: 'accessing'>
	| old inserted |
	inserted := false.
	old := contents at: aField
		    ifAbsentPut: 
			[inserted := true.
			aWrapper].
	inserted not and: [old == aWrapper ifTrue: [^self]].
	inserted ifFalse: [contents at: aField put: aWrapper].
	aWrapper isNowContainedBy: self and: aField
    ]

    equalityStringForField: aDatabaseField [
	<category: 'printing'>
	| stream |
	stream := WriteStream on: (String new: 50).
	self printEqualityStringForField: aDatabaseField on: stream.
	^stream contents
    ]

    printEqualityStringForField: aDatabaseField on: aStream [
	"Get around PostgreSQL bug.  Qualified names cannot appear in SET expression."

	<category: 'printing'>
	aDatabaseField printNameOn: aStream withParameters: #().
	aStream nextPutAll: ' = '.
	self printValueOfField: aDatabaseField on: aStream
    ]

    printEqualityTemplateForField: aDatabaseField on: aCommand [
	"Get around PostgreSQL bug.  Qualified names cannot appear in SET expression."

	<category: 'printing'>
	| bind |
	aDatabaseField printNameOn: aCommand withParameters: #().
	aCommand nextPutAll: ' = '.
	bind := aCommand canBind: (self at: aDatabaseField) to: aDatabaseField type.
	bind 
	    ifTrue: [aCommand nextPutAll: '?']
	    ifFalse: [self printValueOfField: aDatabaseField on: aCommand]
    ]

    printEqualityTemplateForField: aDatabaseField on: aStream withBinding: aBoolean [
	"Get around PostgreSQL bug.  Qualified names cannot appear in SET expression."

	<category: 'printing'>
	aDatabaseField printNameOn: aStream withParameters: #().
	aStream nextPutAll: ' = '.
	aBoolean 
	    ifTrue: [aStream nextPutAll: '?']
	    ifFalse: [self printValueOfField: aDatabaseField on: aStream]
    ]

    printFieldNamesOn: aWriteStream [
	<category: 'printing'>
	GlorpHelper 
	    do: [:each | aWriteStream nextPutAll: each name]
	    for: self table fields
	    separatedBy: [aWriteStream nextPutAll: ',']
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream 
	    nextPutAll: '(' , (table name isNil ifTrue: [''] ifFalse: [table name]) 
		    , ')'.
	aStream nl.
	contents keysAndValuesDo: 
		[:eachField :eachWrapper | 
		aStream nextPutAll: '    '.
		eachField printOn: aStream.
		aStream nextPutAll: '->'.
		eachWrapper printOn: aStream.
		aStream nl]
    ]

    printPrimaryKeyStringOn: aStream [
	"If there is no primary key (i.e. this is a link table) use all the values that we have"

	<category: 'printing'>
	| fields |
	fields := table primaryKeyFields isEmpty 
		    ifTrue: [contents keys]
		    ifFalse: [table primaryKeyFields].
	GlorpHelper 
	    do: [:eachField | self printEqualityStringForField: eachField on: aStream]
	    for: fields
	    separatedBy: [aStream nextPutAll: ' AND ']
    ]

    printPrimaryKeyTemplateOn: aStream [
	"If there is no primary key (i.e. this is a link table) use all the values that we have"

	<category: 'printing'>
	| fields |
	fields := table primaryKeyFields isEmpty 
		    ifTrue: [contents keys]
		    ifFalse: [table primaryKeyFields].
	GlorpHelper 
	    do: [:eachField | self printEqualityTemplateForField: eachField on: aStream]
	    for: fields
	    separatedBy: [aStream nextPutAll: ' AND ']
    ]

    printValueOfField: aDatabaseField on: aWriteStream [
	<category: 'printing'>
	aDatabaseField type print: (self at: aDatabaseField) on: aWriteStream
    ]

    shouldBeWritten: aBoolean [
	<category: 'configuring'>
	shouldBeWritten := aBoolean
    ]

    table: anObject [
	"Private - Set the value of the receiver's ''table'' instance variable to the argument, anObject."

	<category: 'configuring'>
	table := anObject
    ]

    withAllFieldsIn: aRow [
	"aRow represents our original state. Make sure that we have all the fields in aRow, using nil values for any that are missing. This is needed if, e.g. we have been removed from a 1-many relationship, so we don't get a value generated for our foreign key, but we should still write it as a nil. We have to distinguish this from the case of a value that simply hasn't changed."

	<category: 'configuring'>
	aRow isEmpty ifTrue: [^self].
	self numberOfFields = table fields size ifTrue: [^self].
	aRow fieldsAndValidValuesDo: 
		[:eachField :eachValue | 
		(self includesField: eachField) ifFalse: [self at: eachField put: nil]]
    ]

    equals: aRow [
	<category: 'testing'>
	self fieldsAndValuesDo: 
		[:eachField :eachWrapper | 
		| otherValue |
		otherValue := aRow at: eachField
			    ifAbsent: [self class missingFieldIndicator].
		eachWrapper = otherValue ifFalse: [^false]].
	^true
    ]

    isEmpty [
	<category: 'testing'>
	^contents isEmpty
    ]
]



DatabaseType subclass: TimeType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    TimeType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    print: aValue on: aStream [
	<category: 'SQL'>
	aStream nextPutAll: (self platform printTime: aValue for: self)
    ]

    converterForStType: aClass [
	<category: 'conversion-times'>
	^self platform converterNamed: #time
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Time
    ]
]



AbstractNumericType subclass: NumericType [
    | precision scale |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    NumericType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    typeString [
	<category: 'SQL'>
	| w |
	platform supportsVariableSizedNumerics ifFalse: [^typeString].
	w := WriteStream on: String new.
	w nextPutAll: typeString.
	precision isNil 
	    ifFalse: 
		[w nextPutAll: '(' , precision printString.
		scale isNil ifFalse: [w nextPutAll: ',' , scale printString].
		w nextPutAll: ')'].
	^w contents
    ]

    precision: anInteger [
	<category: 'accessing'>
	precision := anInteger
    ]

    scale: anInteger [
	<category: 'accessing'>
	scale := anInteger
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	typeString := 'numeric'
    ]

    hasParameters [
	"Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"

	<category: 'testing'>
	^true
    ]
]



Object subclass: Query [
    | session criteria prepared expectedRows collectionType |
    
    <category: 'Glorp-Queries'>
    <comment: nil>

    Query class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    Query class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    Query class >> readManyOf: aClass [
	"readManyOf: and returningManyOf: are synonyms. This now seems more natural to me, to be consistent with session API"

	<category: 'instance creation'>
	^self returningManyOf: aClass where: nil
    ]

    Query class >> readManyOf: aClass where: criteria [
	<category: 'instance creation'>
	^self returningManyOf: aClass where: criteria
    ]

    Query class >> readOneOf: aClass where: criteria [
	<category: 'instance creation'>
	^self returningOneOf: aClass where: criteria
    ]

    Query class >> returningManyOf: aClass [
	<category: 'instance creation'>
	^self returningManyOf: aClass where: nil
    ]

    Query class >> returningManyOf: aClass where: criteria [
	"Backward-compatibility, since we changed the class name."

	<category: 'instance creation'>
	^SimpleQuery returningManyOf: aClass where: criteria
    ]

    Query class >> returningOneOf: aClass where: criteria [
	"Backward-compatibility, since we changed the class name."

	<category: 'instance creation'>
	^SimpleQuery returningOneOf: aClass where: criteria
    ]

    collectionType [
	"Note that queries default the collection type to array, while mappings default to OrderedCollection. I think it makes sense"

	<category: 'accessing'>
	collectionType isNil ifTrue: [collectionType := Array].
	^collectionType
    ]

    collectionType: aClass [
	<category: 'accessing'>
	collectionType := aClass
    ]

    expectedRows [
	"How many rows do we think it's likely this query will bring back. Used for tweaking things like block factor"

	<category: 'accessing'>
	^expectedRows isNil 
	    ifTrue: [expectedRows := self readsOneObject ifTrue: [1] ifFalse: [100]]
	    ifFalse: [expectedRows]
    ]

    expectedRows: anInteger [
	"How many rows do we think it's likely this query will bring back. Used for tweaking things like block factor"

	<category: 'accessing'>
	expectedRows := anInteger
    ]

    readsOneObject [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    session [
	<category: 'accessing'>
	^session
    ]

    session: aSession [
	<category: 'accessing'>
	session := aSession
    ]

    AND: anExpression [
	"Allow you to send AND: or OR: directly to a query to build up a query dynamically without needing to mess with the criteria explicitly"

	<category: 'convenience'>
	criteria := (anExpression 
		    asGlorpExpressionOn: criteria ultimateBaseExpression) AND: criteria
    ]

    OR: anExpression [
	"Allow you to send AND: or OR: directly to a query to build up a query dynamically without needing to mess with the criteria explicitly"

	<category: 'convenience'>
	criteria := (anExpression 
		    asGlorpExpressionOn: criteria ultimateBaseExpression) OR: criteria
    ]

    executeIn: aSession [
	<category: 'executing'>
	^self executeWithParameters: #() in: aSession
    ]

    executeWithParameters: parameterArray in: aSession [
	<category: 'executing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialize'>
	prepared := false
    ]

    postCopy [
	<category: 'copying'>
	prepared := false.
	criteria := criteria rebuildOn: BaseExpression new
    ]
]



Object subclass: FieldUnifier [
    | fields fieldsWithRows objects rows rowMap |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: '
This is a "Method Object" whose purpose is to set up a constraint in the row map between two field values. It''s called a Unifier because the constraints are reminiscent of Prolog-type unification, although much less general (and simpler to implement). There''s no ability to backtrack, and if we ever encounter a contradiction among constraints we throw an exception.  Essentially we just implement it by adding a layer of indirection. Rows can contain wrappers for values. If two or more values are constrained to be the same, we make sure they use the same (identical) wrapper. Then setting the value on one of the fields sets it on all of them.  The only reason this is tricky at all is the "or more" case, because we may need to merge if we discover constraints in the order e.g. a=b, c=d, a=c.

Instance Variables:
    fields	<SequenceableCollection>	
    fieldsWithRows	<SequenceableCollection>	I forget right now  :-)
    objects	<Object>	the persistent objects that are keys into the rowmap
    rowMap	<RowMap>	
    rows	<Collection>	

'>

    FieldUnifier class >> unifyFields: fields correspondingTo: objects in: aRowMap [
	"We are given fields and objects corresponding to an object relationships. So, e.g. if a Person has a Car, and the table PERSON.CAR_ID should equal CAR.ID, then we will have (PERSON.CAR_ID, CAR.ID) and (aPerson, aCar). Establish in our rowmap that these two fields are equal."

	<category: 'instance creation'>
	((self new)
	    fields: fields;
	    objects: objects;
	    rowMap: aRowMap) unify
    ]

    FieldUnifier class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    calculateRows [
	<category: 'unifying'>
	rows := OrderedCollection new: fields size.
	fieldsWithRows := OrderedCollection new: fields size.
	fields with: objects
	    do: 
		[:eachField :eachObject | 
		eachObject isNil 
		    ifFalse: 
			[fieldsWithRows add: eachField.
			rows 
			    add: (rowMap findOrAddRowForTable: eachField table withKey: eachObject)]]
    ]

    convertValueToDatabaseForm: aValue [
	"Just a placeholder right now"

	<category: 'unifying'>
	^aValue
    ]

    findExistingWrappersIfNone: aBlock [
	<category: 'unifying'>
	| allWrappers |
	allWrappers := IdentitySet new: 5.
	fieldsWithRows with: rows
	    do: 
		[:eachField :eachRow | 
		| wrapper |
		wrapper := eachRow wrapperAt: eachField ifAbsent: [nil].
		wrapper isNil ifFalse: [allWrappers add: wrapper]].
	^allWrappers isEmpty ifTrue: [aBlock value] ifFalse: [allWrappers asArray]
    ]

    findWrapperToUseFrom: aWrapperCollection [
	<category: 'unifying'>
	| wrappersWithValues winner |
	wrappersWithValues := aWrapperCollection select: [:each | each hasValue].
	wrappersWithValues size > 1 
	    ifTrue: 
		[(wrappersWithValues 
		    allSatisfy: [:each | each contents = wrappersWithValues first contents]) 
			ifFalse: [self error: 'Conflicting values in rows']].
	winner := wrappersWithValues size = 1 
		    ifTrue: [wrappersWithValues at: 1]
		    ifFalse: [aWrapperCollection first].
	^winner
    ]

    handleConstantCase [
	"It may turn out that the first field is really a constant value. If so, just set it rather than establishing a constraint"

	<category: 'unifying'>
	| value field row |
	value := self convertValueToDatabaseForm: (fields at: 1).
	field := fields at: 2.
	row := rowMap findOrAddRowForTable: field table withKey: (objects at: 2).
	row at: field put: value value
    ]

    unify [
	<category: 'unifying'>
	| wrappers |
	self isReallyJustAConstant ifTrue: [^self handleConstantCase].
	rowMap adjustForMementos: objects.
	self calculateRows.
	wrappers := self 
		    findExistingWrappersIfNone: [Array with: FieldValueWrapper new].
	self unifyWrappers: wrappers
    ]

    unifyWrappers: aWrapperCollection [
	<category: 'unifying'>
	| winner |
	winner := self findWrapperToUseFrom: aWrapperCollection.
	aWrapperCollection do: 
		[:eachWrapper | 
		eachWrapper == winner 
		    ifFalse: 
			[eachWrapper containedBy keysAndValuesDo: 
				[:eachRow :eachListOfFields | 
				eachListOfFields 
				    do: [:eachField | eachRow wrapperAt: eachField put: winner]]]].
	fieldsWithRows with: rows
	    do: [:eachField :eachRow | eachRow wrapperAt: eachField put: winner]
    ]

    isConstant: anObject [
	<category: 'testing'>
	^(anObject class == DatabaseField) not
    ]

    isReallyJustAConstant [
	"Return true if what we're being asked to handle includes a constant value, so it doesn't require a constraint at all, just setting a value. We know that constants are only permissible as the source field entry"

	<category: 'testing'>
	^self isConstant: fields first
    ]

    fields [
	<category: 'accessing'>
	^fields
    ]

    fields: anObject [
	<category: 'accessing'>
	fields := anObject
    ]

    objects [
	<category: 'accessing'>
	^objects
    ]

    objects: anObject [
	<category: 'accessing'>
	objects := anObject
    ]

    rowMap [
	<category: 'accessing'>
	^rowMap
    ]

    rowMap: anObject [
	<category: 'accessing'>
	rowMap := anObject
    ]
]



Object subclass: Descriptor [
    | describedClass tables multipleTableCriteria mappings system mappedFields cachePolicy typeResolver mapsPrimaryKeys |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    Descriptor class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    Descriptor class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    addMapping: aMapping [
	<category: 'accessing'>
	mappings add: aMapping.
	aMapping descriptor: self.
	aMapping updateUseDirectAccess.
	mappedFields := nil
    ]

    addMultipleTableCriteria: anExpression [
	<category: 'accessing'>
	self multipleTableCriteria add: anExpression
    ]

    addTable: aDatabaseTable [
	<category: 'accessing'>
	tables add: aDatabaseTable
    ]

    allMappingsForField: aField [
	"Return all of the mappings that use this field"

	<category: 'accessing'>
	^mappings select: [:each | each mappedFields includes: aField]
    ]

    cachePolicy [
	<category: 'accessing'>
	cachePolicy isNil ifTrue: [^system cachePolicy].
	^cachePolicy
    ]

    cachePolicy: aCachePolicy [
	<category: 'accessing'>
	cachePolicy := aCachePolicy
    ]

    describedClass [
	"Private - Answer the value of the receiver's ''describedClass'' instance variable."

	<category: 'accessing'>
	^describedClass
    ]

    describedClass: anObject [
	"Private - Set the value of the receiver's ''describedClass'' instance variable to the argument, anObject."

	<category: 'accessing'>
	describedClass := anObject
    ]

    directMappingForField: aField [
	"Return a single, direct mapping for this field. There may conceivably be more than one, but they all have to agree, so it shouldn't matter as far as the value. There may also be none."

	<category: 'accessing'>
	^mappings 
	    detect: [:each | each isRelationship not and: [each mappedFields includes: aField]]
	    ifNone: [nil]
    ]

    fieldsForSelectStatement [
	<category: 'accessing'>
	| myFields inheritedFields |
	myFields := self mappedFields.
	inheritedFields := self typeResolver fieldsForSelectStatement.
	^inheritedFields isEmpty 
	    ifTrue: [myFields]
	    ifFalse: [myFields , inheritedFields]
    ]

    initialize [
	<category: 'accessing'>
	mappings := OrderedCollection new.
	tables := OrderedCollection new: 1
    ]

    mappedFields [
	"Return all the fields that are mapped, in the order that they occur in the table."

	<category: 'accessing'>
	mappedFields isNil 
	    ifTrue: 
		[| fieldSet |
		fieldSet := IdentitySet new: mappings size.
		mappings do: [:each | fieldSet addAll: each mappedFields].
		mappedFields := OrderedCollection new.
		tables do: 
			[:each | 
			each fields 
			    do: [:eachField | (fieldSet includes: eachField) ifTrue: [mappedFields add: eachField]]]].
	^mappedFields
    ]

    mappingForAttributeNamed: aSymbol [
	<category: 'accessing'>
	^mappings detect: [:each | each attributeName == aSymbol] ifNone: [nil]
    ]

    multipleTableCriteria [
	<category: 'accessing'>
	multipleTableCriteria isNil 
	    ifTrue: [multipleTableCriteria := OrderedCollection new: 1].
	^multipleTableCriteria
    ]

    primaryTable [
	<category: 'accessing'>
	^tables first
    ]

    session [
	<category: 'accessing'>
	^system session
    ]

    system [
	<category: 'accessing'>
	^system
    ]

    system: anObject [
	<category: 'accessing'>
	system := anObject
    ]

    table [
	<category: 'accessing'>
	^tables first
    ]

    table: aDatabaseTable [
	<category: 'accessing'>
	tables add: aDatabaseTable
    ]

    tables [
	<category: 'accessing'>
	^tables
    ]

    typeMapping [
	<category: 'accessing'>
	^mappings detect: [:each | each isTypeMapping]
	    ifNone: 
		[| mapping |
		mapping := IdentityTypeMapping new.
		self addMapping: mapping.
		mapping]
    ]

    typeMapping: aMapping [
	<category: 'accessing'>
	self addMapping: aMapping
    ]

    typeResolver [
	<category: 'accessing'>
	typeResolver isNil ifTrue: [IdentityTypeResolver new register: self].
	^typeResolver
    ]

    typeResolver: anObject [
	<category: 'accessing'>
	typeResolver := anObject
    ]

    computeMapsPrimaryKeys [
	<category: 'testing'>
	| primaryKeyFields |
	primaryKeyFields := self primaryTable primaryKeyFields.
	primaryKeyFields isEmpty ifTrue: [^false].
	primaryKeyFields 
	    do: [:each | (self mappedFields includes: each) ifFalse: [^false]].
	^true
    ]

    isTypeMappingRoot [
	<category: 'testing'>
	^self typeResolver isTypeMappingRoot: self
    ]

    mapsPrimaryKeys [
	<category: 'testing'>
	mapsPrimaryKeys isNil 
	    ifTrue: [mapsPrimaryKeys := self computeMapsPrimaryKeys].
	^mapsPrimaryKeys
    ]

    supportsOrdering [
	<category: 'testing'>
	typeResolver isNil ifTrue: [^true].
	^typeResolver class ~= HorizontalTypeResolver
    ]

    createDeleteRowFor: anObject table: aTable in: aRowMap [
	"Create records for rows that require deletion"

	<category: 'mapping'>
	aTable primaryKeyFields do: 
		[:each | 
		(self directMappingForField: each) mapFromObject: anObject
		    intoRowsIn: aRowMap]
    ]

    createDeleteRowsFor: anObject in: aRowMap [
	"Create records for rows that require deletion"

	<category: 'mapping'>
	anObject class == self describedClass 
	    ifFalse: [self error: 'wrong descriptor for this object'].
	self tables do: 
		[:eachTable | 
		self 
		    createDeleteRowFor: anObject
		    table: eachTable
		    in: aRowMap.
		(aRowMap rowForTable: eachTable withKey: anObject) forDeletion: true].
	"It's possible that we might not have any direct mapping for a secondary table's primary keys, so
	 allow the multiple table criteria to specify them if that's the only one. If they're not, then they don't do any harm"
	self multipleTableCriteria do: 
		[:each | 
		each 
		    mapFromSource: anObject
		    andTarget: anObject
		    intoRowsIn: aRowMap]
    ]

    createRowsFor: anObject in: aRowMap [
	<category: 'mapping'>
	anObject class == self describedClass 
	    ifFalse: [self error: 'wrong descriptor for this object'].
	mappings do: [:each | each mapFromObject: anObject intoRowsIn: aRowMap].
	self multipleTableCriteria do: 
		[:each | 
		each 
		    mapFromSource: anObject
		    andTarget: anObject
		    intoRowsIn: aRowMap]
    ]

    mappings [
	<category: 'mapping'>
	^ReadStream on: mappings
    ]

    populateObject: anObject inBuilder: anElementBuilder [
	"Answer an object using the values for the specified fields."

	<category: 'mapping'>
	mappings 
	    do: [:each | each mapObject: anObject inElementBuilder: anElementBuilder]
    ]

    primaryKeyExpressionFor: anObject [
	<category: 'mapping'>
	| expression |
	anObject class == describedClass 
	    ifFalse: [self error: 'Wrong descriptor for this object'].
	expression := nil.
	self primaryKeyMappings do: 
		[:each | 
		| clause |
		clause := each expressionFor: anObject.
		expression := clause AND: expression].
	^expression
    ]

    primaryKeyFor: anObject [
	<category: 'mapping'>
	| result |
	anObject class == describedClass 
	    ifFalse: [self error: 'Wrong descriptor for this object'].
	result := self primaryKeyMappings 
		    collect: [:each | each getValueFrom: anObject].
	^result size = 1 ifTrue: [result at: 1] ifFalse: [result]
    ]

    primaryKeyMappings [
	<category: 'mapping'>
	^self primaryTable primaryKeyFields 
	    collect: [:each | self directMappingForField: each]
    ]

    readBackNewRowInformationFor: anObject in: aRowMap [
	<category: 'mapping'>
	anObject class == self describedClass 
	    ifFalse: [self error: 'wrong descriptor for this object'].
	mappings 
	    do: [:each | each readBackNewRowInformationFor: anObject fromRowsIn: aRowMap]
    ]

    describedConcreteClassFor: row withBuilder: builder [
	"Lookup the class that is represented by the row when there is a possibility
	 of this row representing any class within a hierarchy."

	<category: 'internal'>
	^self typeResolver 
	    describedConcreteClassFor: row
	    withBuilder: builder
	    descriptor: self
    ]

    readBackNewRowInformationFor: anObject [
	<category: 'internal'>
	
    ]

    referencedIndependentObjectsFrom: anObject do: aBlock [
	<category: 'internal'>
	mappings do: 
		[:each | 
		(each referencedIndependentObjectsFrom: anObject) 
		    do: [:eachReferencedObject | aBlock value: eachReferencedObject]]
    ]

    referencedIndependentObjectsWithMappingsFrom: anObject do: aBlock [
	<category: 'internal'>
	mappings do: 
		[:each | 
		(each referencedIndependentObjectsFrom: anObject) 
		    do: [:eachReferencedObject | aBlock value: eachReferencedObject value: each]]
    ]

    classesRequiringIndependentQueries [
	<category: 'type resolution'>
	^self typeResolver 
	    classesRequiringIndependentQueriesFor: self describedClass
    ]

    typeMappingRoot [
	<category: 'type resolution'>
	^self typeResolver typeMappingRoot
    ]

    typeMappingRootDescriptor [
	<category: 'type resolution'>
	^self typeResolver typeMappingRootDescriptor
    ]

    allDescribedConcreteClasses [
	<category: 'type mapping'>
	^self typeMapping allDescribedConcreteClasses
    ]

    registerTypeResolver: aResolver [
	<category: 'type mapping'>
	self registerTypeResolver: aResolver abstract: false
    ]

    registerTypeResolver: aResolver abstract: shouldBeAbstract [
	<category: 'type mapping'>
	shouldBeAbstract ifFalse: [self beAbstract].
	aResolver register: self
    ]

    typeMappingCriteriaIn: base [
	<category: 'type mapping'>
	| r l |
	r := ConstantExpression for: self typeMapping keys.
	l := FieldExpression forField: self typeMapping field basedOn: base.
	^l in: r
    ]

    defaultTracing [
	<category: 'tracing'>
	^Tracing new
    ]

    setupTracing: aTracing [
	"Find all the other objects that need to be read when this one is read"

	<category: 'tracing'>
	self trace: aTracing context: aTracing base
    ]

    trace: aTracing context: anExpression [
	"For each mapping, check if the relationship is involved in the set of things
	 to be read"

	<category: 'tracing'>
	mappings do: [:each | each trace: aTracing context: anExpression]
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPutAll: '('.
	describedClass printOn: aStream.
	aStream nextPutAll: ')'
    ]
]



DatabaseType subclass: DateType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DateType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    print: aValue on: aStream [
	<category: 'SQL'>
	aStream nextPutAll: (self platform printDate: aValue for: self)
    ]

    converterForStType: aClass [
	<category: 'converting'>
	^self platform converterNamed: #date
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Date
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	typeString := 'date'
    ]
]



CachePolicy subclass: TimedExpiryCachePolicy [
    | timeout |
    
    <category: 'Glorp-Core'>
    <comment: '
This implements a cache that notes that an object is stale after some amount of time since it has been read.

Instance Variables:
    timeout	<Integer>	The time in seconds until we note an object as needing refreshing.

'>

    TimedExpiryCachePolicy class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    cacheEntryFor: anObject [
	<category: 'wrap/unwrap'>
	^Array with: self totalSeconds with: anObject
    ]

    contentsOf: aCacheEntry [
	<category: 'wrap/unwrap'>
	^aCacheEntry at: 2
    ]

    hasExpired: aCacheEntry [
	<category: 'wrap/unwrap'>
	^self totalSeconds - (aCacheEntry at: 1) >= timeout
    ]

    markEntryAsCurrent: aCacheEntry in: aCache [
	<category: 'wrap/unwrap'>
	aCacheEntry at: 1 put: self totalSeconds
    ]

    timeout [
	<category: 'accessing'>
	^timeout
    ]

    timeout: anInteger [
	<category: 'accessing'>
	timeout := anInteger
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	timeout := 300
    ]

    totalSeconds [
	<category: 'utility'>
	^Dialect totalSeconds
    ]
]



Query subclass: AbstractReadQuery [
    | resultClass readsOneObject returnProxies shouldRefresh ordering tracing absentBlock |
    
    <category: 'Glorp-Queries'>
    <comment: nil>

    AbstractReadQuery class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    AbstractReadQuery class >> returningManyOf: aClass [
	<category: 'instance creation'>
	^self new 
	    initResultClass: aClass
	    criteria: nil
	    singleObject: false
    ]

    AbstractReadQuery class >> returningManyOf: aClass where: criteria [
	<category: 'instance creation'>
	^self new 
	    initResultClass: aClass
	    criteria: criteria
	    singleObject: false
    ]

    AbstractReadQuery class >> returningOneOf: aClass where: criteria [
	<category: 'instance creation'>
	^self new 
	    initResultClass: aClass
	    criteria: criteria
	    singleObject: true
    ]

    executeWithParameters: parameterArray in: aSession [
	<category: 'executing'>
	| cacheHit |
	session := aSession.
	self requiresFullQuery 
	    ifTrue: [^self asFullQuery executeWithParameters: parameterArray in: aSession].
	self checkValidity.
	self setUpCriteria.
	self hasTracing 
	    ifFalse: 
		["We only need to do the cache hit if we're a simple query without a parent. How do we tell, better than not having been given a tracing?"

		cacheHit := self checkCacheWithParameters: parameterArray.
		cacheHit isNil ifFalse: [^cacheHit]].
	self setupTracing.
	^self readFromDatabaseWithParameters: parameterArray
    ]

    setUpCriteria [
	<category: 'executing'>
	criteria := criteria 
		    asGlorpExpressionForDescriptor: (session descriptorFor: resultClass).
	ordering isNil 
	    ifFalse: 
		[ordering := ordering collect: 
				[:each | 
				(self expressionBlockFor: each) 
				    asGlorpExpressionOn: criteria ultimateBaseExpression]].
	tracing isNil 
	    ifFalse: [tracing updateBase: criteria ultimateBaseExpression]
    ]

    validateCriteria [
	<category: 'executing'>
	criteria isPrimaryKeyExpression 
	    ifFalse: [criteria do: [:each | each validate]]
    ]

    absentBlock [
	<category: 'accessing'>
	absentBlock == nil ifTrue: [^[nil]].
	^absentBlock
    ]

    baseExpression [
	<category: 'accessing'>
	^criteria ultimateBaseExpression
    ]

    criteria [
	<category: 'accessing'>
	^criteria
    ]

    defaultTracing [
	<category: 'accessing'>
	| defaultTracing |
	defaultTracing := Tracing new.
	defaultTracing base: criteria ultimateBaseExpression.
	^defaultTracing
    ]

    descriptor [
	<category: 'accessing'>
	^session descriptorFor: resultClass
    ]

    readsOneObject [
	<category: 'accessing'>
	^readsOneObject
    ]

    readsOneObject: aBoolean [
	<category: 'accessing'>
	readsOneObject := aBoolean
    ]

    resultClass [
	<category: 'accessing'>
	^resultClass
    ]

    returnProxies [
	<category: 'accessing'>
	^returnProxies
    ]

    returnProxies: aBoolean [
	<category: 'accessing'>
	returnProxies := aBoolean
    ]

    shouldRefresh [
	<category: 'accessing'>
	^shouldRefresh
    ]

    shouldRefresh: aBoolean [
	<category: 'accessing'>
	shouldRefresh := aBoolean
    ]

    tracing [
	<category: 'accessing'>
	tracing isNil ifTrue: [tracing := self defaultTracing].
	^tracing
    ]

    tracing: aTracing [
	<category: 'accessing'>
	tracing := aTracing.
	tracing updateBase: criteria ultimateBaseExpression.
	tracing setup
    ]

    checkValidity [
	<category: 'validation'>
	resultClass isBehavior 
	    ifFalse: [self error: 'resultClass must be a class'].
	(ordering notNil and: [self descriptor supportsOrdering not]) 
	    ifTrue: 
		[self error: 'The descriptor for ' , self resultClass name 
			    , ' does not support ordering in queries']
    ]

    hasTracing [
	"Return true if we've given this query a tracing already"

	<category: 'testing'>
	^false
    ]

    expressionBlockFor: anOrderingCriteria [
	"Allow us to use symbols interchangeably with simple blocks for ordering, so
	 #firstName is equivalent to [:each | each firstName]. Also, allow chains of symbols, so #(owner firstName)"

	<category: 'ordering'>
	anOrderingCriteria isGlorpExpression ifTrue: [^anOrderingCriteria].

	"Sometimes the inability to portably and efficiently test this sort of thing gets on my nerves. Note that if you step through this expression (F6) in VW 7.1 it won't work."
	"anOrderingCriteria is a block ..."
	anOrderingCriteria class == [] class ifTrue: [^anOrderingCriteria].
	anOrderingCriteria isSymbol 
	    ifTrue: [^[:each | each perform: anOrderingCriteria]].

	"otherwise, we assume it's a collection of symbols, the only other valid case"
	anOrderingCriteria 
	    do: [:each | each isSymbol ifFalse: [self error: 'invalid ordering criteria']].
	^
	[:each | 
	anOrderingCriteria inject: each
	    into: [:sum :eachExpression | sum perform: eachExpression]]
    ]

    orderBy: aBlock [
	<category: 'ordering'>
	ordering isNil 
	    ifTrue: [ordering := Array with: aBlock]
	    ifFalse: [ordering := ordering , (Array with: aBlock)]
    ]

    ordering [
	<category: 'ordering'>
	^ordering
    ]

    setOrdering: aCollection [
	<category: 'ordering'>
	ordering := aCollection
    ]

    alsoFetch: anExpression [
	<category: 'specifying retrievals'>
	self tracing alsoFetch: anExpression
    ]

    retrieve: anExpression [
	<category: 'specifying retrievals'>
	self tracing retrieve: anExpression
    ]

    checkCacheWithParameters: aDictionary [
	<category: 'caching'>
	| primaryKey |
	readsOneObject ifFalse: [^nil].
	self shouldRefresh ifTrue: [^nil].
	primaryKey := self primaryKeyFrom: aDictionary.
	primaryKey isNil ifTrue: [^nil].
	"If it's expired, make sure we do the read but still refresh"
	(session hasExpired: resultClass key: primaryKey) 
	    ifTrue: 
		[self shouldRefresh: true.
		^nil].
	^session 
	    cacheAt: primaryKey
	    forClass: resultClass
	    ifNone: [nil]
    ]

    primaryKeyFrom: aDictionary [
	"Construct a primary key from the given parameters."

	<category: 'caching'>
	aDictionary isEmpty ifTrue: [^nil].
	^self criteria primaryKeyFromDictionary: aDictionary
    ]

    setupTracing [
	<category: 'tracing'>
	self tracing setup.
	self tracing additionalExpressions do: 
		[:each | 
		each hasDescriptor 
		    ifTrue: [each descriptor trace: self tracing context: each]]
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	returnProxies := false.
	shouldRefresh := false
    ]

    initResultClass: aClass criteria: theCriteria singleObject: aBoolean [
	<category: 'initialize'>
	resultClass := aClass.
	criteria := (theCriteria isNil 
		    or: [theCriteria = true or: [theCriteria = false]]) 
			ifTrue: [EmptyExpression on: theCriteria]
			ifFalse: [theCriteria asGlorpExpression].
	readsOneObject := aBoolean
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	session isNil ifFalse: [self setUpCriteria]
    ]
]



AbstractReadQuery subclass: ReadQuery [
    
    <category: 'Glorp-Queries'>
    <comment: '
This represents a general read query. By general we mean that it might require more than one trip to the database. It computes a "tracing" indicating which groups of objects can be read simultaneously, then constructs a group of corresponding SimpleQuery instances and executes them.'>

    ReadQuery class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    readFromDatabaseWithParameters: anArray [
	<category: 'accessing'>
	| col |
	col := OrderedCollection new.
	self descriptor classesRequiringIndependentQueries do: 
		[:aClass | 
		| simpleQuery result |
		simpleQuery := self asSimpleQueryFor: aClass.
		result := simpleQuery readFromDatabaseWithParameters: anArray.
		simpleQuery readsOneObject 
		    ifTrue: [col add: result]
		    ifFalse: [col addAll: result]].
	^col
    ]

    asSimpleQueryFor: aClass [
	<category: 'converting'>
	"Rebuild the expression, because this means a full query is being split into multiple sub-queries, e.g. for an inheritance read. The expression may get prepared differently in each case (e.g. table aliases), so we can't share"

	| newQuery newCriteria |
	newCriteria := criteria rebuildOn: BaseExpression new.
	newQuery := SimpleQuery new 
		    initResultClass: aClass
		    criteria: newCriteria
		    singleObject: readsOneObject.
	newQuery session: session.
	newQuery returnProxies: self returnProxies.
	newQuery shouldRefresh: self shouldRefresh.
	newQuery setOrdering: ordering.
	newQuery collectionType: collectionType.
	newQuery setUpCriteria.
	newQuery tracing: tracing.
	newQuery expectedRows: expectedRows.
	^newQuery
    ]

    requiresFullQuery [
	<category: 'testing'>
	^false
    ]
]



Object subclass: Join [
    | sources targets base |
    
    <category: 'Glorp-Queries'>
    <comment: '
This is a specialized variety of expression that is more constrained and is used for defining relationships. It has two main purposes
 - ease of construction: Relationships are normally defined by field to field equality expressions (my foreign key field = his primary key field). These are more tedious to create via block expressions, so this provides a simpler syntax.
 - constrained semantics. These define both read and write for the relationship, so fully general expressions won''t work (most notably, relations other than equality are hard to write). Using a primaryKeyExpression ensures that we satisfy these constraints.

I''m not completely sure this class is a good idea. It makes for an annoying assymetry between different kinds of expressions. This is especially notable now that we allow sources to be constants. It''s possible that all we need is an expression constructor that generates real expressions, but with more convenient syntax and ensuring that the constraints are met.

Note that although these are typically fk=pk, it''s allowed to be the other way around -- i.e. our object-level relationships can be the opposite of the way the fk''s "point" in the database.

Instance Variables:
    base	<BaseExpression>	The base on which we are built. Mostly used if we want to convert this into a real expression.
    sources	<SequenceableCollection of: (DatabaseField | ConstantExpression)> The source fields (typically the foreign keys)
    targets	<SequenceableCollection of: DatabaseField> The target fields (typically the targets of the foreign keys)

'>

    Join class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    Join class >> from: aField to: anotherField [
	<category: 'instance creation'>
	^self new addSource: aField target: anotherField
    ]

    Join class >> from: from1Field to: to1Field from: from2Field to: to2Field [
	<category: 'instance creation'>
	^(self new)
	    addSource: from1Field target: to1Field;
	    addSource: from2Field target: to2Field
    ]

    Join class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    additionalExpressions [
	<category: 'preparing'>
	^#()
    ]

    additionalExpressionsIn: aQuery [
	<category: 'preparing'>
	^#()
    ]

    allTablesToPrint [
	<category: 'preparing'>
	^targets inject: Set new
	    into: 
		[:sum :each | 
		sum add: each table.
		sum]
    ]

    prepareIn: aQuery [
	"Do nothing."

	<category: 'preparing'>
	aQuery criteria: self asGeneralGlorpExpression.
	aQuery criteria prepareIn: aQuery
    ]

    sourceForTarget: aField [
	<category: 'preparing'>
	| index |
	index := targets indexOf: aField.
	index = 0 ifTrue: [^nil].
	^sources at: index
    ]

    initialize [
	<category: 'initialize'>
	sources := OrderedCollection new: 2.
	targets := OrderedCollection new: 2.
	base := BaseExpression new
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'converting'>
	| sourceFieldExpression targetFieldExpression completeExpression |
	completeExpression := nil.
	sources with: targets
	    do: 
		[:sourceField :targetField | 
		sourceFieldExpression := source getField: sourceField.
		targetFieldExpression := target getField: targetField.
		completeExpression := (sourceFieldExpression equals: targetFieldExpression) 
			    AND: completeExpression].
	^completeExpression
    ]

    asGeneralGlorpExpression [
	"Convert this to a 'normal' expression representing the same information"

	<category: 'converting'>
	| main clause |
	main := nil.
	sources with: targets
	    do: 
		[:eachSource :eachTarget | 
		| srcExp targetExp |
		srcExp := self sourceExpressionFor: eachSource.
		targetExp := self targetExpressionFor: eachTarget.
		"Reversing the order is important because the source is the parameter, and sql won't accept '27 = FOO'"
		clause := targetExp equals: srcExp.
		main := main == nil ifTrue: [clause] ifFalse: [main AND: clause]].
	^main
    ]

    isConstant: aTarget [
	"The target can be either a constant (which gets turned into a ConstantExpression) or (usually) a DatabaseField, representing a parameter to the query"

	<category: 'converting'>
	^(aTarget class == DatabaseField) not
    ]

    sourceExpressionFor: source [
	<category: 'converting'>
	^(self isConstant: source) 
	    ifTrue: [source]
	    ifFalse: [base getParameter: source]
    ]

    targetExpressionFor: eachTarget [
	<category: 'converting'>
	^(self isConstant: eachTarget) 
	    ifTrue: [eachTarget]
	    ifFalse: [(base getTable: eachTarget table) getField: eachTarget]
    ]

    allSourceFields [
	<category: 'accessing'>
	^sources
    ]

    allTables [
	<category: 'accessing'>
	^(targets collect: [:each | each table]) asSet
    ]

    base: aBaseExpression [
	<category: 'accessing'>
	base := aBaseExpression
    ]

    hasDescriptor [
	<category: 'accessing'>
	^false
    ]

    numberOfParameters [
	<category: 'accessing'>
	^sources size
    ]

    targetKeys [
	<category: 'accessing'>
	^targets
    ]

    ultimateBaseExpression [
	<category: 'accessing'>
	^base
    ]

    printOn: aStream [
	<category: 'printing'>
	sources with: targets
	    do: 
		[:source :target | 
		aStream nextPut: $(.
		source printSQLOn: aStream withParameters: #().
		aStream nextPutAll: ' = '.
		target printSQLOn: aStream withParameters: #().
		aStream nextPutAll: ') ']
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	1 to: sources size
	    do: 
		[:i | 
		| eachTarget eachSource sourceValue |
		eachTarget := targets at: i.
		eachSource := sources at: i.
		eachTarget printSQLOn: aStream withParameters: aDictionary.
		sourceValue := (self isConstant: eachSource) 
			    ifTrue: [eachSource value]
			    ifFalse: [aDictionary at: eachSource].
		sourceValue isNil 
		    ifTrue: [aStream nextPutAll: ' IS NULL ']
		    ifFalse: 
			[aStream nextPutAll: ' = '.
			sourceValue printOn: aStream].
		i = targets size ifFalse: [aStream nextPutAll: ' AND ']]
    ]

    primaryKeyFromDictionary: aDictionary [
	"Given a set of parameters, return a primary key suitable for retrieving our target. Return either a value for the key, nil for no key found, or a CompositeKey for compound keys."

	"| key |
	 sources size = 1 ifTrue: [^aDictionary at: sources first ifAbsent: [nil]].
	 
	 key := CompositeKey forTable: self primaryTable.
	 self fieldsDo: [:eachSource :eachTarget |  |eachValue |
	 eachValue := aDictionary at: eachSource ifAbsent: [^nil].
	 key at: eachTarget put: eachValue].
	 ^key isComplete ifTrue: [key] ifFalse: [nil]."

	"Bad, bad move to try to make this work at least temporarily"

	<category: 'primary keys'>
	^aDictionary at: sources first ifAbsent: [nil]
    ]

    isPrimaryKeyExpression [
	<category: 'testing'>
	^true
    ]

    addSource: aField target: anotherField [
	<category: 'api'>
	| value |
	value := (self isConstant: aField) 
		    ifTrue: [ConstantExpression for: aField]
		    ifFalse: [aField].
	sources add: value.
	(self isConstant: anotherField) 
	    ifTrue: 
		[self 
		    error: 'You are attempting to set a constant value as the target of a relationship. I suspect you want to set it on the source instead'].
	targets add: anotherField
    ]

    asGlorpExpression [
	<category: 'api'>
	^self
    ]

    asGlorpExpressionForDescriptor: aDescriptor [
	<category: 'api'>
	base descriptor: aDescriptor
    ]

    mapFromSource: sourceObject andTarget: targetObject intoRowsIn: aRowMap [
	<category: 'api'>
	sources with: targets
	    do: 
		[:eachSourceField :eachTargetField | 
		FieldUnifier 
		    unifyFields: (Array with: eachSourceField with: eachTargetField)
		    correspondingTo: (Array with: sourceObject with: targetObject)
		    in: aRowMap]
    ]

    fieldsDo: aBlock [
	<category: 'iterating'>
	sources with: targets do: aBlock
    ]
]



FunctionExpression subclass: InfixFunction [
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    InfixFunction class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    convertedStValueOf: anObject [
	"This assumes that functions that do conversions have already had their effect in the database, and all we're concerned with is the fundamental data type conversion"

	<category: 'As yet unclassified'>
	^base convertedStValueOf: anObject
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	aStream
	    nextPutAll: function;
	    nextPut: $(.
	base printSQLOn: aStream withParameters: aDictionary.
	aStream nextPut: $)
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: function , '('.
	base printOn: aStream.
	aStream nextPutAll: ')'
    ]

    rebuildOn: aBaseExpression [
	<category: 'preparing'>
	| rebuilt |
	rebuilt := self copy.
	rebuilt base: (base rebuildOn: aBaseExpression).
	rebuilt function: function.
	^rebuilt
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	base do: aBlock skipping: aSet.
	aBlock value: self
    ]
]



Collection subclass: GlorpVirtualCollection [
    | query session realObjects |
    
    <category: 'GlorpQueries'>
    <comment: '
This represents a virtual collection, i.e. one that we haven''t really read into memory yet. It responds to a reasonable subset of collection protocol, and will read the elements into memory only when necessary. So, e.g. a select: operation takes a query block, and is equivalent to AND:ing that query block to the main query.

To create a virtual collection, ask the session for one. e.g. session virtualCollectionOf: AClass.

This is an initial version which will read in the objects fairly eagerly. An optimization might be to defer certain types of operations depending on whether the block can be evaluated into SQL or not. e.g.
  collect: [:each | each name]
can be turned into a retrieve: operation. But 
  collect: [:each | each printString]
cannot. We could try to check the block for operations like collect: and detect:, deferring the point at which the objects will be read in.

Handling of ordering is also a little bit funny. The blocks we like for ordering aren''t compatible with sortedCollection type blocks. It''d be nice to be more compatible.

'>

    GlorpVirtualCollection class >> on: aClass in: aSession [
	<category: 'instance creation'>
	^self new on: aClass in: aSession
    ]

    orderBy: aBlockOrExpression [
	<category: 'accessing'>
	query orderBy: aBlockOrExpression
    ]

    size [
	<category: 'accessing'>
	^self realObjects size
    ]

    collect: aBlock [
	<category: 'enumerating'>
	^self realObjects collect: aBlock
    ]

    do: aBlock [
	<category: 'enumerating'>
	self realObjects do: aBlock
    ]

    reject: aBlock [
	<category: 'enumerating'>
	^self copy AND: [:each | (aBlock value: each) not]
    ]

    select: aBlock [
	<category: 'enumerating'>
	^self isInstantiated 
	    ifTrue: [self realObjects select: aBlock]
	    ifFalse: [self copy AND: aBlock]
    ]

    postCopy [
	<category: 'copying'>
	query := query copy.
	realObjects := nil
    ]

    isEmpty [
	<category: 'testing'>
	^self realObjects isEmpty
    ]

    isInstantiated [
	<category: 'testing'>
	^realObjects notNil
    ]

    AND: aBlock [
	<category: 'private'>
	query AND: aBlock
    ]

    readOnlyError [
	<category: 'private'>
	self error: 'Virtual collections are read-only'
    ]

    realObjects [
	<category: 'private'>
	realObjects isNil ifTrue: [realObjects := session execute: query].
	^realObjects
    ]

    add: newObject [
	<category: 'adding'>
	self readOnlyError
    ]

    on: aClass in: aSession [
	<category: 'initialize-release'>
	query := Query returningManyOf: aClass.
	session := aSession
    ]

    printOn: aStream [
	<category: 'printing'>
	self isInstantiated 
	    ifTrue: [super printOn: aStream]
	    ifFalse: 
		[aStream nextPutAll: 'a virtual collection of '.
		query notNil ifTrue: [aStream nextPutAll: query resultClass name]]
    ]

    remove: oldObject ifAbsent: anExceptionBlock [
	<category: 'removing'>
	self readOnlyError
    ]
]



Object subclass: TypeResolver [
    | members system |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    TypeResolver class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    fieldsForSelectStatement [
	"Return fields that are needed in a select statement - i.e. return all inherited fields that are part of the tables we are already selecting for this object"

	<category: 'type resolution'>
	^#()
    ]

    typeMappingRootDescriptor [
	<category: 'type resolution'>
	self subclassResponsibility
    ]

    addMember: aDescriptor [
	<category: 'accessing'>
	members isNil ifTrue: [members := OrderedCollection new].
	members add: aDescriptor
    ]

    classesRequiringIndependentQueriesFor: aClass [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    describedConcreteClassFor: row withBuilder: builder descriptor: aDescriptor [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    system [
	<category: 'accessing'>
	^system
    ]

    system: anObject [
	<category: 'accessing'>
	system := anObject
    ]

    register: aDescriptor [
	<category: 'registering'>
	^self register: aDescriptor abstract: false
    ]

    register: aDescriptor abstract: abstract [
	<category: 'registering'>
	self system: aDescriptor system.
	self addMember: aDescriptor.
	aDescriptor typeResolver: self
    ]

    describedClasses [
	<category: 'other'>
	^members collect: [:each | each describedClass]
    ]
]



TypeResolver subclass: BasicTypeResolver [
    | concreteMembers subclassDescriptorsBuilt rootDescriptor rootClass |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    BasicTypeResolver class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    allDescribedConcreteClasses [
	<category: 'private'>
	self subclassDescriptorsBuilt ifFalse: [self forceSubclassDescriptorLoads].
	^self concreteMembers collect: [:each | each describedClass]
    ]

    forceSubclassDescriptorLoads [
	<category: 'private'>
	self rootClass allSubclassesDo: [:each | self system descriptorFor: each].
	subclassDescriptorsBuilt := true
    ]

    concreteMembers [
	<category: 'accessing'>
	^concreteMembers isNil 
	    ifTrue: [concreteMembers := OrderedCollection new]
	    ifFalse: [concreteMembers]
    ]

    rootClass [
	<category: 'accessing'>
	^rootClass
    ]

    rootClass: anObject [
	<category: 'accessing'>
	rootClass := anObject
    ]

    rootDescriptor [
	<category: 'accessing'>
	^rootDescriptor isNil 
	    ifTrue: [rootDescriptor := self system descriptorFor: self rootClass]
	    ifFalse: [rootDescriptor]
    ]

    subclassDescriptorsBuilt [
	<category: 'accessing'>
	^subclassDescriptorsBuilt isNil 
	    ifTrue: [subclassDescriptorsBuilt := false]
	    ifFalse: [subclassDescriptorsBuilt]
    ]

    typeMappingRootDescriptor [
	<category: 'type resolution'>
	^self rootDescriptor
    ]

    rootDescriptor: anObject [
	<category: 'other'>
	rootDescriptor := anObject
    ]

    register: aDescriptor abstract: abstract [
	<category: 'registering'>
	super register: aDescriptor abstract: abstract.
	abstract ifFalse: [self concreteMembers add: aDescriptor]
    ]
]



TypeResolver subclass: IdentityTypeResolver [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    IdentityTypeResolver class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    describedConcreteClassFor: aRow withBuilder: builder descriptor: aDescriptor [
	<category: 'accessing'>
	^aDescriptor describedClass
    ]

    typeMappingRootDescriptor [
	<category: 'accessing'>
	^members first
    ]

    classesRequiringIndependentQueriesFor: aClass [
	<category: 'type resolution'>
	^Array with: aClass
    ]
]



GlorpExpression subclass: ExpressionGroup [
    | children |
    
    <category: 'Glorp-Expressions'>
    <comment: '
This isn''t really an expression, in that it can never occur due to parsing. It''s a way of grouping several expressions together so that we can process them together, essentially making sure that the iteration methods will loop over all the expressions, but only do each node once, even if it occurs in multiple expressions.  This is used in processing order expressions to figure out what tables and join expressions we need.

Because it is only used in transient ways, it probably doesn''t implement all the required operations for normal expression usage.
'>

    ExpressionGroup class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    ExpressionGroup class >> with: anExpression [
	<category: 'instance creation'>
	^self new add: anExpression
    ]

    add: anExpression [
	<category: 'accessing'>
	children add: anExpression
    ]

    addAll: anExpressionCollection [
	<category: 'accessing'>
	anExpressionCollection isNil ifTrue: [^self].
	children addAll: anExpressionCollection
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	children := OrderedCollection new
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	children do: [:each | each do: aBlock skipping: aSet].
	aBlock value: self
    ]
]



Object subclass: AttributeAccessor [
    | attributeName lastClassUsed attributeIndex useDirectAccess |
    
    <category: 'Glorp-Core'>
    <comment: nil>

    AttributeAccessor class >> newForAttributeNamed: aString [
	<category: 'instance creation'>
	^(self new)
	    attributeName: aString;
	    yourself
    ]

    AttributeAccessor class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    getValueFrom: anObject [
	<category: 'get/set'>
	self useDirectAccess ifTrue: [^self directGetValueFrom: anObject].
	^anObject perform: self attributeName
    ]

    setValueIn: anObject to: aValue [
	<category: 'get/set'>
	self useDirectAccess ifTrue: [^self directSetValueIn: anObject to: aValue].
	^anObject perform: (self attributeName , ':') asSymbol with: aValue
    ]

    attributeName [
	<category: 'accessing'>
	^attributeName
    ]

    attributeName: anObject [
	<category: 'accessing'>
	attributeName := anObject
    ]

    useDirectAccess [
	<category: 'accessing'>
	useDirectAccess isNil ifTrue: [useDirectAccess := true].
	^useDirectAccess
    ]

    useDirectAccess: anObject [
	<category: 'accessing'>
	useDirectAccess := anObject
    ]

    directGetValueFrom: anObject [
	<category: 'private'>
	| index |
	index := self instVarIndexIn: anObject.
	index = 0 ifTrue: [self raiseInvalidAttributeError].
	^anObject instVarAt: index
    ]

    directSetValueIn: anObject to: aValue [
	<category: 'private'>
	| index |
	index := self instVarIndexIn: anObject.
	index = 0 ifTrue: [self raiseInvalidAttributeError].
	^anObject instVarAt: index put: aValue
    ]

    instVarIndexIn: anObject [
	<category: 'private'>
	| soughtName |
	(lastClassUsed == anObject class and: [attributeIndex notNil]) 
	    ifTrue: [^attributeIndex].
	lastClassUsed := anObject class.
	soughtName := Dialect instVarNameFor: attributeName.
	attributeIndex := lastClassUsed allInstVarNames indexOf: soughtName.
	^attributeIndex
    ]

    raiseInvalidAttributeError [
	<category: 'private'>
	self error: 'Invalid attribute'
    ]
]



Mapping subclass: ConditionalMapping [
    | conditionalField conditionalMethod cases otherwiseCase conditionalFieldMapping |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    ConditionalMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    controlsTables [
	<category: 'testing'>
	self error: 'What should we do here?'
    ]

    isRelationship [
	<category: 'testing'>
	^false
    ]

    conditionalField: aField [
	<category: 'accessing'>
	conditionalField := aField
    ]

    conditionalFieldMapping [
	<category: 'accessing'>
	^conditionalFieldMapping
    ]

    conditionalFieldMapping: aMapping [
	"This is a write-only mapping for the conditional field value, which writes out the result of performing the conditional method"

	<category: 'accessing'>
	conditionalFieldMapping := aMapping
    ]

    conditionalMethod: aSymbol [
	<category: 'accessing'>
	conditionalMethod := aSymbol
    ]

    descriptor: aDescriptor [
	<category: 'accessing'>
	super descriptor: aDescriptor.
	cases do: [:each | each value descriptor: aDescriptor].
	otherwiseCase descriptor: aDescriptor.
	conditionalFieldMapping isNil 
	    ifFalse: [conditionalFieldMapping descriptor: aDescriptor]
    ]

    mappedFields [
	<category: 'accessing'>
	| all |
	all := OrderedCollection new.
	conditionalFieldMapping isNil 
	    ifTrue: [all add: conditionalField]
	    ifFalse: [all addAll: conditionalFieldMapping mappedFields].
	cases do: [:each | all addAll: each value mappedFields].
	^all
    ]

    applicableMappingForObject: anObject [
	<category: 'mapping'>
	| conditionalValue |
	conditionalValue := self conditionalValueFor: anObject.
	^cases 
	    detect: [:each | self descriptor system perform: each key with: conditionalValue]
	    ifNone: [otherwiseCase]
    ]

    applicableMappingForRow: anArray in: anElementBuilder [
	<category: 'mapping'>
	| rowValue |
	rowValue := anElementBuilder valueOfField: conditionalField in: anArray.
	cases do: 
		[:each | 
		(self descriptor system perform: each key with: rowValue) 
		    ifTrue: [^each value]].
	^otherwiseCase
    ]

    conditionalValueFor: anObject [
	<category: 'mapping'>
	^anObject perform: conditionalMethod
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	<category: 'mapping'>
	readOnly ifTrue: [^self].
	(self applicableMappingForObject: anObject) mapFromObject: anObject
	    intoRowsIn: aRowMap.
	conditionalFieldMapping isNil ifTrue: [^self].
	conditionalFieldMapping 
	    mapFromObject: (self conditionalValueFor: anObject)
	    intoRowsIn: aRowMap
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	<category: 'mapping'>
	(self applicableMappingForRow: anElementBuilder row in: anElementBuilder) 
	    mapObject: anObject
	    inElementBuilder: anElementBuilder
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	| allReferencedObjects |
	allReferencedObjects := OrderedCollection new.
	cases do: 
		[:each | 
		allReferencedObjects 
		    addAll: (each value referencedIndependentObjectsFrom: anObject)].
	^allReferencedObjects
    ]

    if: conditionSelector then: aMapping [
	<category: 'conditions'>
	cases add: (Association key: conditionSelector value: aMapping)
    ]

    otherwise: aMapping [
	<category: 'conditions'>
	otherwiseCase := aMapping
    ]

    trace: aTracing context: anExpression [
	"To make a join, we need to look at all of our possible cases"

	<category: 'conditions'>
	conditionalFieldMapping isNil 
	    ifFalse: [conditionalFieldMapping trace: aTracing context: anExpression].
	cases do: [:each | each value trace: aTracing context: anExpression]
    ]

    initialize [
	<category: 'initialize/release'>
	super initialize.
	cases := OrderedCollection new
    ]
]



DatabaseType subclass: BooleanType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    BooleanType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    converterForStType: aClass [
	<category: 'converting'>
	(aClass includesBehavior: Boolean) 
	    ifTrue: [^self platform converterNamed: #booleanToBoolean].
	^self platform nullConverter
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Boolean
    ]
]



RowMap subclass: RowMapForMementos [
    | correspondenceMap |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: '
This is a specialized version of RowMap for creating rowmaps out of the mementos in the undo/correspondence map. When doing partial writes we create a rowmap for the current state of the objects, then a rowmap for the original state, and difference the two.

The tricky part is that the mementos refer back to the original objects, so when we establish unification constraints between rows, they would establish them to original objects. This is wrong, and not trivial to debug.

So this rowmap keeps the correspondence map and knows that it has to compensate and get the memento for any related objects.
'>

    RowMapForMementos class >> withCorrespondenceMap: aDictionary [
	<category: 'instance creation'>
	^self new correspondenceMap: aDictionary
    ]

    RowMapForMementos class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    adjustForMementos: objects [
	"We may be being passed row map keys that refer to originals when they should refer to mementos. Fix.This is horribly ugly."

	<category: 'api'>
	1 to: objects size
	    do: 
		[:i | 
		| possibleRowMapKey |
		possibleRowMapKey := objects at: i.
		possibleRowMapKey class == RowMapKey 
		    ifTrue: [objects at: i put: (self adjustRowMapKey: possibleRowMapKey)]].
	^objects
    ]

    adjustRowMapKey: aRowMapKey [
	<category: 'api'>
	| key1 key2 newRowMapKey |
	newRowMapKey := aRowMapKey copy.
	key1 := aRowMapKey key1.
	newRowMapKey key1: (correspondenceMap at: key1 ifAbsent: [key1]).
	key2 := aRowMapKey key2.
	newRowMapKey key2: (correspondenceMap at: key2 ifAbsent: [key2]).
	^newRowMapKey
    ]

    findOrAddRowForTable: aTable withKey: aKey [
	<category: 'api'>
	| mementoKey |
	mementoKey := correspondenceMap at: aKey ifAbsent: [aKey].
	^super findOrAddRowForTable: aTable withKey: mementoKey
    ]

    reverseAdjustRowMapKey: aRowMapKey [
	<category: 'api'>
	| key1 key2 newRowMapKey |
	newRowMapKey := aRowMapKey copy.
	key1 := aRowMapKey key1.
	newRowMapKey key1: (correspondenceMap keyAtValue: key1).
	key2 := aRowMapKey key2.
	newRowMapKey key2: (correspondenceMap keyAtValue: key2).
	^newRowMapKey
    ]

    rowForTable: aTable withKey: aKey ifAbsent: aBlock [
	<category: 'api'>
	| correspondingObject |
	correspondingObject := aKey class == RowMapKey 
		    ifTrue: [self adjustRowMapKey: aKey]
		    ifFalse: [correspondenceMap at: aKey ifAbsent: [nil]].
	^super 
	    rowForTable: aTable
	    withKey: correspondingObject
	    ifAbsent: aBlock
    ]

    collectionMementoFor: aCollection [
	<category: 'private/mapping'>
	aCollection glorpIsCollection ifFalse: [^aCollection].
	^correspondenceMap at: aCollection
    ]

    originalObjectFor: anObject [
	<category: 'private/mapping'>
	^correspondenceMap at: anObject
    ]

    reverseLookup: anObject [
	<category: 'private/mapping'>
	anObject class == RowMapKey 
	    ifTrue: [^self reverseAdjustRowMapKey: anObject].
	^correspondenceMap keyAtValue: anObject
    ]

    objectsAndRowsDo1: aTwoArgumentBlock [
	"For a memento map, use the original objects, not the mementos"

	<category: 'iterating'>
	rowDictionary do: 
		[:eachObjectToRowDictionary | 
		eachObjectToRowDictionary keysAndValuesDo: 
			[:eachKey :eachValue | 
			aTwoArgumentBlock value: (self originalObjectFor: eachKey) value: eachValue]]
    ]

    correspondenceMap: anObject [
	<category: 'accessing'>
	correspondenceMap := anObject
    ]
]



Object subclass: DatabaseField [
    | table name isPrimaryKey position type isNullable isUnique |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DatabaseField class >> named: aString [
	<category: 'instance creation'>
	^self error: 'type needed'
    ]

    DatabaseField class >> named: aString type: dbType [
	<category: 'instance creation'>
	^(super new initialize)
	    name: aString;
	    type: dbType
    ]

    DatabaseField class >> new [
	<category: 'instance creation'>
	^self error: 'dbType needed'
    ]

    DatabaseField class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    asConstraintReferenceString [
	<category: 'printing'>
	^table name , ' (' , self name , ')'
    ]

    printForConstraintNameOn: aStream maxLength: maxLength [
	<category: 'printing'>
	| constraintName |
	constraintName := table name , '_' , name.
	constraintName size > maxLength 
	    ifTrue: [constraintName := constraintName copyFrom: 1 to: maxLength].
	aStream nextPutAll: constraintName
    ]

    printNameOn: aStream withParameters: anArray [
	<category: 'printing'>
	aStream nextPutAll: self name
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'Field'.
	aStream
	    nextPutAll: '(';
	    nextPutAll: (table isNil ifTrue: [''] ifFalse: [table name]);
	    nextPutAll: '.';
	    nextPutAll: name;
	    nextPutAll: ')'
    ]

    printQualifiedSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	aStream nextPutAll: self qualifiedName	"self name"
    ]

    printSQLOn: aStream withParameters: anArray [
	<category: 'printing'>
	aStream nextPutAll: self qualifiedName	"self name"
    ]

    printUnqualifiedSQLOn: aStream withParameters: anArray [
	<category: 'printing'>
	aStream nextPutAll: self name
    ]

    initialize [
	<category: 'initializing'>
	isPrimaryKey := false.
	isNullable := true.
	isUnique := false
    ]

    postInitializeIn: aDescriptorSystem [
	"Any initialization that has to be delayed until we're in the table"

	<category: 'initializing'>
	type initializeForField: self in: aDescriptorSystem
    ]

    impliedSmalltalkType [
	"Return the default Smalltalk type corresponding to our database type"

	<category: 'accessing'>
	^self type impliedSmalltalkType
    ]

    name [
	"Private - Answer the value of the receiver's ''name'' instance variable."

	<category: 'accessing'>
	^name
    ]

    name: anObject [
	"Private - Set the value of the receiver's ''name'' instance variable to the argument, anObject."

	<category: 'accessing'>
	name := anObject
    ]

    position [
	<category: 'accessing'>
	^position
    ]

    position: anObject [
	<category: 'accessing'>
	position := anObject
    ]

    table [
	"Private - Answer the value of the receiver's ''table'' instance variable."

	<category: 'accessing'>
	^table
    ]

    table: anObject [
	"Private - Set the value of the receiver's ''table'' instance variable to the argument, anObject."

	<category: 'accessing'>
	table := anObject
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    typeString [
	<category: 'database'>
	^type typeString
    ]

    asGlorpExpression [
	<category: 'converting'>
	^ParameterExpression forField: self basedOn: nil
    ]

    asGlorpExpressionOn: anExpression [
	<category: 'converting'>
	^ParameterExpression forField: self basedOn: anExpression
    ]

    converterForStType: aClass [
	<category: 'converting'>
	^self type converterForStType: (aClass isBehavior 
		    ifTrue: [aClass]
		    ifFalse: [aClass class])
    ]

    isGenerated [
	<category: 'testing'>
	^type isGenerated
    ]

    isNullable [
	<category: 'testing'>
	^isNullable
    ]

    isPrimaryKey [
	"Private - Answer the value of the receiver's ''isPrimaryKey'' instance variable."

	<category: 'testing'>
	^isPrimaryKey
    ]

    isUnique [
	<category: 'testing'>
	^isUnique
    ]

    beNullable: aBoolean [
	<category: 'configuring'>
	self isPrimaryKey ifFalse: [isNullable := aBoolean]
    ]

    bePrimaryKey [
	<category: 'configuring'>
	isPrimaryKey := true.
	isNullable := false.
	self table isNil ifFalse: [self table addAsPrimaryKeyField: self]
    ]

    isUnique: aBoolean [
	<category: 'configuring'>
	isUnique := aBoolean
    ]

    type: aDatabaseType [
	<category: 'configuring'>
	type := aDatabaseType
    ]

    qualifiedName [
	<category: 'querying'>
	^table isNil 
	    ifTrue: [self name]
	    ifFalse: [self table qualifiedName , '.' , self name]
    ]
]



AbstractStringType subclass: CharType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    CharType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    typeString [
	<category: 'SQL'>
	^'char(' , width printString , ')'
    ]

    isVariableWidth [
	<category: 'testing'>
	^false
    ]
]



ProtoObject subclass: MessageArchiver [
    | myMessage myReceiver |
    
    <comment: nil>
    <category: 'Glorp-Expressions'>

    MessageArchiver class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    MessageArchiver class >> receiver: aMessageCollector message: aMessage [
	<category: 'instance creation'>
	^self new receiver: aMessageCollector message: aMessage
    ]

    = anObject [
	"Needed because VA's abtObservableWrapper implements =. Should be portable."

	<category: 'doesNotUnderstand'>
	^MessageArchiver receiver: self
	    message: (Message selector: #= arguments: (Array with: anObject))
    ]

    basicDoesNotUnderstand: aMessage [
	"Invoke this to avoid infinite recursion in the case of internal errors. We want a dialect-independent way of getting a walkback window, so we'll invoke it against a different object"

	<category: 'doesNotUnderstand'>
	(Array with: self) doesNotUnderstand: aMessage
    ]

    doesNotUnderstand: aMessage [
	<category: 'doesNotUnderstand'>
	| sel |
	sel := aMessage selector.
	sel == #doesNotUnderstand: ifTrue: [self basicDoesNotUnderstand: aMessage].
	(sel size >= 8 and: [(sel copyFrom: 1 to: 8) = 'perform:']) 
	    ifTrue: 
		[^self get: aMessage arguments first
		    withArguments: (aMessage arguments copyFrom: 2 to: aMessage arguments size)].
	^MessageArchiver receiver: self message: aMessage
    ]

    isGlorpExpression [
	<category: 'testing'>
	^false
    ]

    asText [
	<category: 'debugging'>
	^self basicPrintString asText
    ]

    basicPrintString [
	<category: 'debugging'>
	^self printString
    ]

    class [
	<category: 'debugging'>
	^MessageArchiver
    ]

    halt [
	"Support this so that we can debug inside query blocks. For portability, send it to a different object so that we don't have to care how halt is implemented"

	<category: 'debugging'>
	(Array with: self) halt
    ]

    inspect [
	"Not exactly the intended semantics, but should be portable"

	<category: 'debugging'>
	(Array with: self) inspect
    ]

    inspectorClasses [
	"Answer a sequence of inspector classes that can represent the receiver in an
	 inspector. The first page in the array is the one used by default in a new inspector."

	<category: 'debugging'>
	^Array with: (Dialect smalltalkAt: 'Tools.Trippy.BasicInspector')
    ]

    inspectorExtraAttributes [
	<category: 'debugging'>
	^#()
    ]

    inspectorSize [
	<category: 'debugging'>
	^2
    ]

    printOn: aStream [
	<category: 'debugging'>
	aStream nextPutAll: self printString
    ]

    printString [
	"Hard-code this for maximum dialect portability"

	<category: 'debugging'>
	^'a MessageArchiver'
    ]

    privateGlorpMessage [
	<category: 'private/accessing'>
	^myMessage
    ]

    privateGlorpReceiver [
	<category: 'private/accessing'>
	^myReceiver
    ]

    asGlorpExpression [
	<category: 'expression creation'>
	^self asGlorpExpressionOn: BaseExpression new
    ]

    asGlorpExpressionOn: aBaseExpression [
	<category: 'expression creation'>
	| arguments |
	myReceiver == nil ifTrue: [^aBaseExpression].
	arguments := myMessage arguments 
		    collect: [:each | each asGlorpExpressionOn: aBaseExpression].
	^(myReceiver asGlorpExpressionOn: aBaseExpression) get: myMessage selector
	    withArguments: arguments
    ]

    between: anObject and: anotherObject [
	<category: 'expression protocol'>
	^self > anObject & (self < anotherObject)
    ]

    get: aSymbol [
	<category: 'expression protocol'>
	^MessageArchiver receiver: self
	    message: (Message selector: aSymbol arguments: #())
    ]

    get: aSymbol withArguments: anArray [
	<category: 'expression protocol'>
	^MessageArchiver receiver: self
	    message: (Message selector: aSymbol arguments: anArray)
    ]

    receiver: aMessageCollector message: aMessage [
	<category: 'initialize'>
	myReceiver := aMessageCollector.
	myMessage := aMessage
    ]
]



Object subclass: MultipleRowMapKey [
    | keys |
    
    <category: 'GlorpUnitOfWork'>
    <comment: '
This is a special (and rarely needed) form of row map key that allows an arbitrary number of objects to participate in it.'>

    MultipleRowMapKey class >> new [
	"Answer a newly created and initialized instance."

	<category: 'instance creation'>
	^super new initialize
    ]

    MultipleRowMapKey class >> with: key1 with: key2 with: key3 [
	<category: 'instance creation'>
	^(self new)
	    addKey: key1;
	    addKey: key2;
	    addKey: key3;
	    yourself
    ]

    addKey: aKey [
	<category: 'accessing'>
	keys add: aKey
    ]

    keys [
	<category: 'accessing'>
	^keys
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'KEY('.
	self hash printOn: aStream.
	aStream nextPutAll: '):'.
	keys printOn: aStream
    ]

    = aRowMapKey [
	<category: 'comparing'>
	aRowMapKey class == self class ifFalse: [^false].
	aRowMapKey keys do: [:each | (keys includes: each) ifFalse: [^false]].
	^true
    ]

    hash [
	<category: 'comparing'>
	^keys inject: 0 into: [:sum :each | sum bitXor: each identityHash]
    ]

    initialize [
	<category: 'initialize-release'>
	keys := IdentitySet new
    ]
]



Object subclass: RowMapKey [
    | key1 key2 |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: '
This class serves as a key for a dictionary containing two sub-keys, where we want to be able to look up based on the identity of both sub-keys paired together. This is used primarily for many-to-many mappings indexing into rowmaps, where we want to key the row by the identity of the object that determines it, but there are two of them.

Instance Variables:

key1	<Object>	One sub-key.
key2	<Object>	The other sub-key.'''>

    RowMapKey class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    key1 [
	<category: 'accessing'>
	^key1
    ]

    key1: anObject [
	<category: 'accessing'>
	key1 := anObject
    ]

    key2 [
	<category: 'accessing'>
	^key2
    ]

    key2: anObject [
	<category: 'accessing'>
	key2 := anObject
    ]

    = aRowMapKey [
	<category: 'comparing'>
	aRowMapKey class == self class ifFalse: [^false].
	^(key1 == aRowMapKey key1 and: [key2 == aRowMapKey key2]) 
	    or: [key2 == aRowMapKey key1 and: [key1 == aRowMapKey key2]]
    ]

    hash [
	<category: 'comparing'>
	^key1 identityHash bitXor: key2 identityHash
    ]
]



GlorpExpression subclass: RelationExpression [
    | relation leftChild rightChild outerJoin |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    RelationExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    RelationExpression class >> named: aSymbol basedOn: anExpression withArguments: anArray [
	<category: 'instance creation'>
	^self new 
	    named: aSymbol
	    basedOn: anExpression
	    withArguments: anArray
    ]

    get: aSymbol withArguments: anArray [
	"We treat NOT as a function, so we have to check for functions here"

	<category: 'api'>
	| functionExpression |
	functionExpression := self getFunction: aSymbol withArguments: anArray.
	functionExpression isNil ifFalse: [^functionExpression].
	^anArray isEmpty 
	    ifTrue: [self error: 'Only binary relationships supported right now']
	    ifFalse: 
		[RelationExpression 
		    named: aSymbol
		    basedOn: self
		    withArguments: anArray]
    ]

    beOuterJoin [
	<category: 'accessing'>
	outerJoin := true
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^true
    ]

    isOuterJoin [
	<category: 'accessing'>
	outerJoin isNil ifTrue: [outerJoin := false].
	^outerJoin
    ]

    leftChild [
	<category: 'accessing'>
	^leftChild
    ]

    leftChild: anExpression [
	<category: 'accessing'>
	leftChild := anExpression
    ]

    outerJoin [
	<category: 'accessing'>
	outerJoin isNil ifTrue: [outerJoin := false].
	^outerJoin
    ]

    outerJoin: aBoolean [
	<category: 'accessing'>
	outerJoin := aBoolean
    ]

    relation [
	<category: 'accessing'>
	^relation
    ]

    relation: aSymbol [
	<category: 'accessing'>
	relation := aSymbol
    ]

    rightChild [
	<category: 'accessing'>
	^rightChild
    ]

    rightChild: anExpression [
	<category: 'accessing'>
	rightChild := anExpression
    ]

    canUseBinding [
	"Return true if we can use binding for our right child's value"

	<category: 'As yet unclassified'>
	^self expectsCollectionArgument not
    ]

    expectsCollectionArgument [
	<category: 'As yet unclassified'>
	^self relationsWithCollectionArguments includes: relation
    ]

    printForANSIJoinTo: aTableCollection on: aCommand [
	"Print ourselves as table JOIN otherTable USING (criteria). Return the table we joined"

	<category: 'As yet unclassified'>
	| table |
	self outerJoin 
	    ifTrue: [aCommand nextPutAll: ' LEFT OUTER JOIN ']
	    ifFalse: [aCommand nextPutAll: ' INNER JOIN '].
	table := self tablesForANSIJoin 
		    detect: [:each | (aTableCollection includes: each) not].
	aCommand nextPutAll: table sqlTableName.
	aCommand nextPutAll: ' ON '.
	self printSQLOn: aCommand withParameters: aCommand parameters.
	^table
    ]

    relationsWithCollectionArguments [
	<category: 'As yet unclassified'>
	^#(#IN)
    ]

    tablesForANSIJoin [
	"Which tables will we join. Assumes this is a single-level join"

	<category: 'As yet unclassified'>
	^self inject: Set new
	    into: 
		[:sum :each | 
		each tableForANSIJoin isNil ifFalse: [sum add: each tableForANSIJoin].
		sum]
    ]

    useBindingFor: aValue to: aType in: aCommand [
	"Return true if we can use binding for our right child's value, in the context of this command"

	<category: 'As yet unclassified'>
	aCommand useBinding ifFalse: [^false].
	self expectsCollectionArgument ifTrue: [^false].
	^aCommand canBind: aValue to: aType
    ]

    named: aSymbol basedOn: anExpression withArguments: anArray [
	<category: 'private/initializing'>
	| base right |
	outerJoin := false.
	relation := self operationFor: aSymbol.
	leftChild := anExpression.
	"The only time we don't expect anExpression to have a base is if it's a constant, in which case the other side should be a variable expression and thus have a base."
	base := anExpression canHaveBase 
		    ifTrue: [anExpression ultimateBaseExpression]
		    ifFalse: [anArray first ultimateBaseExpression].
	right := anArray first.
	rightChild := (right isGlorpExpression 
		    and: [right canHaveBase and: [right ultimateBaseExpression == base]]) 
			ifTrue: [right]
			ifFalse: [right asGlorpExpressionOn: base]
    ]

    operationFor: aSymbol [
	"Simple translation of operators"

	<category: 'private/initializing'>
	aSymbol == #AND: ifTrue: [^#AND].
	aSymbol == #& ifTrue: [^#AND].
	aSymbol == #OR: ifTrue: [^#OR].
	aSymbol == #| ifTrue: [^#OR].
	aSymbol == #~= ifTrue: [^#<>].
	aSymbol == #like: ifTrue: [^#LIKE].
	aSymbol == #ilike: ifTrue: [^#ILIKE].	"Case-insensitive variant of LIKE. Only supported on PostgreSQL at the moment"
	aSymbol == #in: ifTrue: [^#IN].
	^aSymbol
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	^leftChild canHaveBase 
	    ifTrue: [leftChild ultimateBaseExpression]
	    ifFalse: [rightChild ultimateBaseExpression]
    ]

    asIndependentJoins [
	<category: 'converting'>
	"If this is an ANDed clause, referring to two different tables split it into independent joins"

	relation == #AND ifFalse: [^Array with: self].
	"leftChild leftTableForANSIJoin == rightChild leftTableForANSIJoin ifTrue: [^Array with: self]."
	^(Array with: leftChild with: rightChild) inject: OrderedCollection new
	    into: 
		[:sum :each | 
		sum addAll: each asIndependentJoins.
		sum]
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: relation
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream
	    print: leftChild;
	    space;
	    nextPutAll: relation;
	    space;
	    print: rightChild
    ]

    printBasicSQLOn: aStream withParameters: aDictionary [
	<category: 'printing SQL'>
	aStream nextPut: $(.
	leftChild printSQLOn: aStream withParameters: aDictionary.
	self 
	    printComparisonTo: rightChild
	    withParameters: aDictionary
	    on: aStream.
	self printOracleOuterJoinOn: aStream.
	aStream nextPut: $)
    ]

    printComparisonTo: value withParameters: aDictionary on: aStream [
	"Horribly convoluted logic to handle the cases where the value might be a constant, an expression that results in a value (constant or parameter) or a regular expression, with the caveat that any value that turns out to be null has to be printed with IS NULL rather than = NULL."

	<category: 'printing SQL'>
	| translated |
	translated := self convertValueOf: value in: aDictionary.
	translated isGlorpExpression 
	    ifTrue: 
		[translated isEmptyExpression 
		    ifFalse: 
			[self printRelationOn: aStream.
			translated printSQLOn: aStream withParameters: aDictionary]]
	    ifFalse: [self printSimpleValueComparisonTo: translated on: aStream]
    ]

    printMicrosoftOuterJoinOn: aCommand [
	<category: 'printing SQL'>
	self isOuterJoin ifFalse: [^self].
	aCommand platform useMicrosoftOuterJoins 
	    ifTrue: [aCommand nextPutAll: '*']
    ]

    printOracleOuterJoinOn: aCommand [
	<category: 'printing SQL'>
	self isOuterJoin ifFalse: [^self].
	aCommand platform useOracleOuterJoins 
	    ifTrue: [aCommand nextPutAll: ' (+) ']
    ]

    printRelationOn: aStream [
	<category: 'printing SQL'>
	aStream space.
	self printMicrosoftOuterJoinOn: aStream.
	aStream
	    nextPutAll: self relation;
	    space
    ]

    printSimpleValueComparisonTo: value on: aStream [
	<category: 'printing SQL'>
	value isNil 
	    ifTrue: [self printWithNullOn: aStream]
	    ifFalse: 
		[self printRelationOn: aStream.
		self printValue: value on: aStream]
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing SQL'>
	self leftChild hasImpliedClauses 
	    ifTrue: 
		[| impliedClauses |
		impliedClauses := self leftChild allRelationsFor: self.
		impliedClauses outerJoin: self outerJoin.
		impliedClauses printSQLOn: aStream withParameters: aDictionary]
	    ifFalse: [self printBasicSQLOn: aStream withParameters: aDictionary]
    ]

    printValue: value on: aCommand [
	<category: 'printing SQL'>
	| type |
	type := self leftChild field type.
	(self 
	    useBindingFor: value
	    to: type
	    in: aCommand) ifTrue: [^aCommand nextPutAll: '?'].
	self expectsCollectionArgument 
	    ifTrue: [type printCollection: value on: aCommand]
	    ifFalse: [type print: value on: aCommand]
    ]

    printWithNullOn: aStream [
	<category: 'printing SQL'>
	aStream nextPutAll: ' IS '.
	self relation = #<> ifTrue: [aStream nextPutAll: 'NOT '].
	aStream nextPutAll: 'NULL'
    ]

    convertValueOf: anObject in: aDictionary [
	<category: 'iterating'>
	| translated convertedValue |
	translated := anObject isGlorpExpression 
		    ifTrue: [anObject valueIn: aDictionary]
		    ifFalse: [anObject].
	translated isGlorpExpression ifTrue: [^translated].
	convertedValue := self expectsCollectionArgument 
		    ifTrue: 
			[translated collect: [:each | self leftChild convertedDbValueOf: each]]
		    ifFalse: [self leftChild convertedDbValueOf: translated].
	^convertedValue
    ]

    do: aBlock skipping: aSet [
	<category: 'iterating'>
	| clauses |
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	leftChild hasImpliedClauses 
	    ifTrue: 
		[clauses := leftChild allRelationsFor: self.
		clauses do: [:each | each do: aBlock skipping: aSet]]
	    ifFalse: 
		[leftChild do: aBlock skipping: aSet.
		rightChild do: aBlock skipping: aSet.
		aBlock value: self]
    ]

    additionalExpressions [
	<category: 'preparing'>
	^#()
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	| left right |
	left := leftChild asExpressionJoiningSource: source toTarget: target.
	right := rightChild asExpressionJoiningSource: source toTarget: target.
	^(self class new)
	    relation: relation;
	    leftChild: left;
	    rightChild: right
    ]

    bindingIn: aCommand [
	<category: 'preparing'>
	^self convertValueOf: rightChild in: aCommand parameters
    ]

    hasBindableExpressionsIn: aCommand [
	"Return true if our right-child can be used for binding. We need to do this at this level because the expressions themselves don't know what type they'll be matched against"

	<category: 'preparing'>
	| translated |
	rightChild canBind ifFalse: [^false].
	translated := self convertValueOf: rightChild in: aCommand parameters.
	^self 
	    useBindingFor: translated
	    to: leftChild field type
	    in: aCommand
    ]

    rebuildOn: aBaseExpression [
	<category: 'preparing'>
	| expression |
	expression := (leftChild rebuildOn: aBaseExpression) get: relation
		    withArguments: (Array with: (rightChild rebuildOn: aBaseExpression)).
	self isOuterJoin ifTrue: [expression beOuterJoin].
	^expression
    ]
]



RelationExpression subclass: CollectionExpression [
    | myLocalBase myLocalExpression |
    
    <category: 'Glorp-Expressions'>
    <comment: '
This represents expressions on collection objects taking a block, which at the moment means just anySatisfy:

We treat this as a relation, but with the special properties that when we convert the right hand side into an expression we assume it''s a block and give it a base which is the left-hand side. Also, we don''t print this relation when printing SQL, we just print the right hand side.'>

    CollectionExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    printSQLOn: aStream withParameters: aDictionary [
	"Don't print the left child or ourselves, just the expression that is the right side.
	 e.g. aPerson addresses anySatisfy: [:each | each city='Ottawa'] prints as
	 where (address.city = 'Ottawa')
	 The relation 'aPerson addresses' will ensure that the join gets printed"

	<category: 'printing SQL'>
	rightChild printSQLOn: aStream withParameters: aDictionary
    ]

    named: aSymbol basedOn: anExpression withArguments: anArray [
	"Create ourselves based on anExpression. Our argument is expected to be a block operating on the elements of the receiver, i.e. the leftChild. e.g. leftChild anySatisfy: [...].
	 Turn the block into an expression, using a temporary base. Otherwise subclauses in the block will end up trying to use the ultimate base expression. This is ugly, but I can't think of a good alternative"

	<category: 'private/initializing'>
	relation := aSymbol.
	leftChild := anExpression.
	myLocalExpression := anArray first asGlorpExpressionOn: self myLocalBase.
	rightChild := myLocalExpression rebuildOn: leftChild
    ]

    myLocalBase [
	<category: 'accessing'>
	myLocalBase isNil ifTrue: [myLocalBase := BaseExpression new].
	^myLocalBase
    ]

    myLocalBase: anExpression [
	<category: 'accessing'>
	myLocalBase := anExpression
    ]

    rebuildOn: aBaseExpression [
	<category: 'preparing'>
	| expression |
	expression := (leftChild rebuildOn: aBaseExpression) get: relation
		    withArguments: (Array with: myLocalExpression).
	self isOuterJoin ifTrue: [expression beOuterJoin].
	^expression
    ]
]



BasicTypeResolver subclass: FilteredTypeResolver [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    FilteredTypeResolver class >> forRootClass: aClass [
	<category: 'instance creation'>
	^(self new)
	    rootClass: aClass;
	    yourself
    ]

    FilteredTypeResolver class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    register: aDescriptor keyedBy: aKey field: aField [
	<category: 'registering'>
	self register: aDescriptor abstract: false.
	aDescriptor typeMapping: (FilteredTypeMapping to: aField keyedBy: aKey)
    ]

    describedConcreteClassFor: row withBuilder: builder descriptor: aDescriptor [
	<category: 'type resolving'>
	^aDescriptor typeMapping describedConcreteClassFor: row
	    withBuilder: builder
    ]

    fieldsForSelectStatement [
	"Return fields that are needed in a select statement - i.e. return all inherited fields that are part of the tables we are already selecting for this object, but not in the main descriptor"

	<category: 'type resolving'>
	| fields rootFields |
	fields := OrderedCollection new.
	rootFields := self rootDescriptor mappedFields asSet.
	self concreteMembers do: 
		[:each | 
		each == self rootDescriptor 
		    ifFalse: 
			[each mappedFields 
			    do: [:eachSubField | (rootFields includes: eachSubField) ifFalse: [fields add: eachSubField]]]].
	^fields
    ]

    classesRequiringIndependentQueriesFor: aClass [
	<category: 'accessing'>
	^Array with: aClass
    ]
]



GlorpExpression subclass: ObjectExpression [
    | mappingExpressions requiresDistinct tableAliases fieldAliases |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    ObjectExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    aliasedTableFor: aDatabaseTable [
	<category: 'fields'>
	tableAliases isNil ifTrue: [^aDatabaseTable].
	aDatabaseTable isAliased ifTrue: [^aDatabaseTable].
	^tableAliases at: aDatabaseTable
    ]

    aliasedTableFor: aDatabaseTable ifAbsent: aBlock [
	<category: 'fields'>
	tableAliases isNil ifTrue: [^aBlock value].
	aDatabaseTable isAliased ifTrue: [^aDatabaseTable].
	^tableAliases at: aDatabaseTable ifAbsent: [aBlock value]
    ]

    aliasTable: aDatabaseTable to: aString [
	<category: 'fields'>
	| newTable |
	newTable := aDatabaseTable copy.
	newTable schema: ''.
	newTable name: aString.
	newTable parent: aDatabaseTable.
	self tableAliases at: aDatabaseTable put: newTable
    ]

    controlsTables [
	<category: 'fields'>
	self subclassResponsibility
    ]

    newFieldExpressionFor: aField [
	<category: 'fields'>
	^FieldExpression forField: aField basedOn: self
    ]

    translateField: aDatabaseField [
	<category: 'fields'>
	| newTable |
	newTable := self aliasedTableFor: aDatabaseField table.
	newTable == aDatabaseField table ifTrue: [^aDatabaseField].
	^self fieldAliases at: aDatabaseField
	    ifAbsentPut: 
		[| newField |
		newField := aDatabaseField copy.
		newField table: newTable]
    ]

    translateFields: anOrderedCollection [
	<category: 'fields'>
	^anOrderedCollection collect: [:each | self translateField: each]
    ]

    get: aSymbol [
	"Return the mapping expression corresponding to the named attribute"

	<category: 'api'>
	| reallyASymbol |
	reallyASymbol := aSymbol asSymbol.
	^mappingExpressions at: reallyASymbol
	    ifAbsentPut: [MappingExpression named: reallyASymbol basedOn: self]
    ]

    get: aSymbol withArguments: anArray [
	"Return the mapping expression corresponding to the named attribute"

	<category: 'api'>
	(#(#getTable: #getField: #parameter:) includes: aSymbol) 
	    ifTrue: [^self perform: aSymbol withArguments: anArray].
	^anArray isEmpty 
	    ifTrue: [self get: aSymbol]
	    ifFalse: 
		[RelationExpression 
		    named: aSymbol
		    basedOn: self
		    withArguments: anArray]
    ]

    getField: aField [
	<category: 'api'>
	| realField |
	realField := aField isString 
		    ifTrue: [self table fieldNamed: aField]
		    ifFalse: [aField].
	"This might be an expression, most notably a constant expression, in which case it either contains a string or a field"
	realField isGlorpExpression 
	    ifTrue: 
		[realField value isString 
		    ifTrue: [realField := self table fieldNamed: realField value]
		    ifFalse: [^realField]].
	^mappingExpressions at: realField
	    ifAbsentPut: [self newFieldExpressionFor: realField]
    ]

    getTable: aTable [
	"This can take a string, a constantExpression containing a string, or a table object"

	<category: 'api'>
	| realTable |
	realTable := aTable isString 
		    ifTrue: [self system tableNamed: aTable]
		    ifFalse: [aTable].	"This might be an expression, most notably a constant expression, in which case it either contains a string or a field"
	realTable isGlorpExpression 
	    ifTrue: 
		[realTable value isString 
		    ifTrue: [realTable := self system tableNamed: realTable value]
		    ifFalse: [realTable := realTable value]].
	^mappingExpressions at: realTable
	    ifAbsentPut: [TableExpression forTable: realTable basedOn: self]
    ]

    fieldAliases [
	<category: 'accessing'>
	fieldAliases isNil ifTrue: [fieldAliases := IdentityDictionary new].
	^fieldAliases
    ]

    requiresDistinct [
	<category: 'accessing'>
	^requiresDistinct
    ]

    requiresDistinct: aBoolean [
	<category: 'accessing'>
	requiresDistinct := aBoolean
    ]

    system [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    tableAliases [
	<category: 'accessing'>
	tableAliases isNil ifTrue: [tableAliases := IdentityDictionary new: 3].
	^tableAliases
    ]

    assignTableAliasesStartingAt: anInteger [
	<category: 'preparing'>
	| tableNumber |
	self controlsTables ifFalse: [^anInteger].
	tableNumber := anInteger.
	self tables do: 
		[:each | 
		self aliasTable: each to: 't' , tableNumber printString.
		tableNumber := tableNumber + 1].
	^tableNumber
    ]

    removeMappingExpression: anExpression [
	"Private. Normally you would never do this, but in the case of an anySatisfy: or allSatisfy: we want to have each of them as distinct joins, so we will remove the entry from the mappingExpression of the base, making sure that relationship will not be used for anything else. Since any/allSatisfy: is the only valid use of a collection relationship, we don't have to worry about whether it was used for something else earlier."

	<category: 'private/accessing'>
	mappingExpressions removeKey: anExpression name
    ]

    printTableAliasesOn: aStream [
	<category: 'printing'>
	self hasTableAliases 
	    ifTrue: 
		[aStream nextPutAll: ' '.
		tableAliases keysAndValuesDo: 
			[:eachKey :eachValue | 
			aStream nextPutAll: eachKey name , '->' , eachValue name , ' ']]
    ]

    hasTableAliases [
	<category: 'tests'>
	^tableAliases notNil
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	mappingExpressions := IdentityDictionary new.
	requiresDistinct := false
    ]
]



ObjectExpression subclass: TableExpression [
    | table base |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    TableExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    TableExpression class >> forTable: aDatabaseTable basedOn: aBaseExpression [
	<category: 'instance creation'>
	^(self new)
	    table: aDatabaseTable base: aBaseExpression;
	    yourself
    ]

    base [
	<category: 'accessing'>
	^base
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^true
    ]

    printsTable [
	<category: 'accessing'>
	^true
    ]

    table [
	<category: 'accessing'>
	^table
    ]

    ultimateBaseExpression [
	<category: 'accessing'>
	^base ultimateBaseExpression
    ]

    aliasedTableFor: aDatabaseTable [
	<category: 'preparing'>
	^self controlsTables 
	    ifTrue: [super aliasedTableFor: aDatabaseTable]
	    ifFalse: [base aliasedTableFor: aDatabaseTable]
    ]

    aliasedTableFor: aDatabaseTable ifAbsent: aBlock [
	<category: 'preparing'>
	^self controlsTables 
	    ifTrue: [super aliasedTableFor: aDatabaseTable ifAbsent: aBlock]
	    ifFalse: [base aliasedTableFor: aDatabaseTable ifAbsent: aBlock]
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	^target getTable: table
    ]

    controlsTables [
	"We can end up with a table expression built on top of a base that has the same table. If so, we don't count as controlling that table"

	<category: 'preparing'>
	base isNil ifTrue: [^true].
	base hasDescriptor ifFalse: [^true].
	^(base descriptor tables includes: table) not
    ]

    tables [
	<category: 'preparing'>
	^Array with: table
    ]

    tablesToPrint [
	<category: 'preparing'>
	self controlsTables ifFalse: [^#()].
	^Array with: (self aliasedTableFor: table)
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	table printSQLOn: aStream withParameters: #().
	self printTableAliasesOn: aStream
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	base printOn: aStream.
	aStream nextPut: $..
	table printSQLOn: aStream withParameters: #()
    ]

    table: aDatabaseTable base: aBaseExpression [
	<category: 'initialize/release'>
	table := aDatabaseTable.
	base := aBaseExpression
    ]

    rebuildOn: aBaseExpression [
	<category: 'As yet unclassified'>
	^aBaseExpression getTable: table
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree"

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	base do: aBlock skipping: aSet.
	aBlock value: self
    ]
]



ObjectExpression subclass: MappingExpression [
    | name base outerJoin |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    MappingExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    MappingExpression class >> named: aSymbol basedOn: anExpression [
	<category: 'instance creation'>
	^self new named: aSymbol basedOn: anExpression
    ]

    allRelationsFor: rootExpression [
	<category: 'As yet unclassified'>
	^self mapping allRelationsFor: rootExpression
    ]

    asOuterJoin [
	<category: 'As yet unclassified'>
	outerJoin := true
    ]

    convertedDbValueOf: anObject [
	<category: 'As yet unclassified'>
	^self mapping convertedDbValueOf: anObject
    ]

    convertedStValueOf: anObject [
	<category: 'As yet unclassified'>
	^self mapping convertedStValueOf: anObject
    ]

    valueInBuilder: anElementBuilder [
	<category: 'As yet unclassified'>
	^self mapping valueIn: anElementBuilder withFieldContextFrom: self base
    ]

    aliasedTableFor: aDatabaseTable [
	<category: 'fields'>
	^self controlsTables 
	    ifTrue: [super aliasedTableFor: aDatabaseTable]
	    ifFalse: [base aliasedTableFor: aDatabaseTable]
    ]

    aliasedTableFor: aDatabaseTable ifAbsent: aBlock [
	<category: 'fields'>
	^self controlsTables 
	    ifTrue: [super aliasedTableFor: aDatabaseTable ifAbsent: aBlock]
	    ifFalse: [base aliasedTableFor: aDatabaseTable ifAbsent: aBlock]
    ]

    controlsTables [
	<category: 'fields'>
	| mapping |
	mapping := self mapping.
	mapping isNil ifTrue: [^false].
	^mapping controlsTables
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^true
    ]

    descriptor [
	<category: 'accessing'>
	^self system descriptorFor: self mapping referenceClass
    ]

    field [
	<category: 'accessing'>
	| mapping |
	mapping := self mapping.
	mapping isNil 
	    ifTrue: 
		[self error: '"' , name , '" is not a mapped property name in ' 
			    , base descriptor describedClass name].
	mapping isRelationship 
	    ifTrue: 
		[self 
		    error: '"' , name 
			    , '" is not an attribute that resolves to a field in the mapped tables for ' 
				, base descriptor describedClass name].
	^base translateField: mapping field
    ]

    hasDescriptor [
	"Does the object that we describe have its own descriptor"

	<category: 'accessing'>
	^self mapping isRelationship
    ]

    mappedFields [
	<category: 'accessing'>
	| mapping |
	mapping := self mapping.
	mapping isNil 
	    ifTrue: 
		[self error: '"' , name , '" is not a mapped property name in ' 
			    , base descriptor describedClass name].
	mapping isRelationship 
	    ifTrue: 
		[self 
		    error: '"' , name 
			    , '" is not an attribute that resolves to a field in the mapped tables for ' 
				, base descriptor describedClass name].
	^self mapping mappedFields collect: [:each | base translateField: each]
    ]

    multipleTableExpressions [
	<category: 'accessing'>
	^self mapping multipleTableExpressionsFor: self
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    requiresDistinct: aBoolean [
	<category: 'accessing'>
	super requiresDistinct: aBoolean.
	base requiresDistinct: aBoolean
    ]

    sourceDescriptor [
	<category: 'accessing'>
	^base descriptor
    ]

    system [
	<category: 'accessing'>
	^base system
    ]

    table [
	<category: 'accessing'>
	self hasDescriptor 
	    ifTrue: [self error: 'trying to get a single table for a non-direct mapping'].
	^self field table
    ]

    tables [
	<category: 'accessing'>
	| set |
	self controlsTables ifFalse: [^#()].
	set := self descriptor tables asSet.
	^set
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: name.
	self printTableAliasesOn: aStream
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream
	    print: base;
	    nextPut: $.;
	    nextPutAll: name
    ]

    canBeUsedForRetrieve [
	"Return true if this is a valid argument for a retrieve: clause"

	<category: 'testing'>
	^self mapping canBeUsedForRetrieve
    ]

    canKnit [
	"Return true if, when building objects, we can knit the object corresponding to this expression to a related object. Roughly speaking, is this a mapping expression"

	<category: 'testing'>
	^true
    ]

    hasImpliedClauses [
	<category: 'testing'>
	^self mapping notNil and: [self mapping hasImpliedClauses]
    ]

    additionalExpressions [
	<category: 'preparing'>
	| exp |
	exp := self mapping joinExpressionFor: self.
	outerJoin ifTrue: [exp beOuterJoin].
	^self multipleTableExpressions 
	    , (exp isNil ifTrue: [#()] ifFalse: [Array with: exp])
    ]

    allRelationsFor: rootExpression do: aBlock andBetweenDo: anotherBlock [
	"We might have multiple clauses to print, depending on our mapping"

	<category: 'preparing'>
	self mapping 
	    allRelationsFor: rootExpression
	    do: aBlock
	    andBetweenDo: anotherBlock
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	| newBase |
	newBase := base asExpressionJoiningSource: source toTarget: target.
	^self class named: name basedOn: newBase
    ]

    fieldsForSelectStatement [
	<category: 'preparing'>
	^self mapping fieldsForSelectStatement
    ]

    rebuildOn: aBaseExpression [
	<category: 'preparing'>
	| expression |
	expression := (base rebuildOn: aBaseExpression) get: name.
	outerJoin ifTrue: [expression asOuterJoin].
	^expression
    ]

    tablesToPrint [
	<category: 'preparing'>
	self hasDescriptor ifFalse: [^#()].
	^self tables collect: [:each | self aliasedTableFor: each]
    ]

    translateField: aDatabaseField [
	<category: 'preparing'>
	| translatedField |
	translatedField := (self mapping 
		    translateFields: (Array with: aDatabaseField)) first.
	^super translateField: (translatedField isNil 
		    ifTrue: [aDatabaseField]
		    ifFalse: [translatedField])
    ]

    translateFields: anOrderedCollection [
	"Ugh. Unify these mechnisms"

	<category: 'preparing'>
	^super 
	    translateFields: (self mapping translateFields: anOrderedCollection)
    ]

    validate [
	<category: 'preparing'>
	self mapping isNil 
	    ifTrue: [self error: 'no mapping for ' , self printString]
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree"

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	base do: aBlock skipping: aSet.
	aBlock value: self
    ]

    base [
	<category: 'api'>
	^base
    ]

    get: aSymbol withArguments: anArray [
	<category: 'api'>
	| functionExpression |
	aSymbol == #anySatisfy: 
	    ifTrue: [^self anySatisfyExpressionWithArguments: anArray].
	aSymbol == #asOuterJoin ifTrue: [^self asOuterJoin].
	functionExpression := self getFunction: aSymbol withArguments: anArray.
	functionExpression isNil ifFalse: [^functionExpression].
	^super get: aSymbol withArguments: anArray
    ]

    named: aSymbol basedOn: anExpression [
	<category: 'private/initialization'>
	name := aSymbol.
	base := anExpression.
	outerJoin := false
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	^base ultimateBaseExpression
    ]

    anySatisfyExpressionWithArguments: anArray [
	<category: 'internal'>
	| newExpression |
	self base requiresDistinct: true.
	newExpression := CollectionExpression 
		    named: #anySatisfy:
		    basedOn: self
		    withArguments: anArray.
	self base removeMappingExpression: self.
	^newExpression
    ]

    mapping [
	<category: 'internal'>
	| descriptor |
	descriptor := self sourceDescriptor.
	descriptor isNil ifTrue: [^nil].
	^descriptor mappingForAttributeNamed: name
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing SQL'>
	self field printSQLOn: aStream withParameters: aDictionary
    ]
]



Object subclass: DescriptorSystem [
    | session platform descriptors tables sequences typeResolvers cachePolicy allClasses useDirectAccessForMapping |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    DescriptorSystem class >> forPlatform: dbPlatform [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    platform: dbPlatform
    ]

    DescriptorSystem class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    DescriptorSystem class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    databaseSequenceNamed: aString [
	<category: 'api'>
	^sequences at: aString asUppercase
	    ifAbsentPut: [platform newDatabaseSequenceNamed: aString]
    ]

    databaseSequenceNamed: aString ifAbsentPut: aBlock [
	<category: 'api'>
	^sequences at: aString asUppercase ifAbsentPut: aBlock
    ]

    descriptorFor: aClassOrObject [
	<category: 'api'>
	| theClass |
	aClassOrObject == Proxy 
	    ifTrue: 
		[self 
		    error: 'Cannot find descriptor for the class Proxy. Pass in the instance'].
	theClass := aClassOrObject isBehavior 
		    ifTrue: [aClassOrObject]
		    ifFalse: 
			[aClassOrObject class == Proxy 
			    ifTrue: [aClassOrObject getValue class]
			    ifFalse: [aClassOrObject class]].
	(self allClasses includes: theClass) ifFalse: [^nil].
	^descriptors at: theClass ifAbsentPut: [self newDescriptorFor: theClass]
    ]

    existingTableNamed: aString [
	<category: 'api'>
	^tables at: aString ifAbsent: [self error: 'missing table']
    ]

    flushAllClasses [
	<category: 'api'>
	allClasses := nil
    ]

    hasDescriptorFor: aClassOrObject [
	<category: 'api'>
	^(self descriptorFor: aClassOrObject) notNil
    ]

    tableNamed: aString [
	<category: 'api'>
	^tables at: aString asString
	    ifAbsent: 
		[| newTable |
		newTable := DatabaseTable new.
		newTable name: aString.
		tables at: aString put: newTable.
		self initializeTable: newTable.
		newTable]
    ]

    typeResolverFor: aClassOrObject [
	<category: 'api'>
	| theClass |
	aClassOrObject == Proxy 
	    ifTrue: 
		[self 
		    error: 'Cannot find type resolver for the class Proxy. Pass in the instance'].
	theClass := aClassOrObject isBehavior 
		    ifTrue: [aClassOrObject]
		    ifFalse: 
			[aClassOrObject class == Proxy 
			    ifTrue: [aClassOrObject getValue class]
			    ifFalse: [aClassOrObject class]].
	^typeResolvers at: theClass
	    ifAbsentPut: [self newTypeResolverFor: theClass]
    ]

    allClasses [
	<category: 'accessing'>
	allClasses isNil ifTrue: [allClasses := self constructAllClasses].
	^allClasses
    ]

    allDescriptors [
	<category: 'accessing'>
	^self allClasses collect: [:each | self descriptorFor: each]
    ]

    allSequences [
	<category: 'accessing'>
	sequences isEmpty ifFalse: [^sequences].
	self allTables do: 
		[:each | 
		each fields do: 
			[:eachField | 
			eachField type hasSequence 
			    ifTrue: 
				[sequences at: eachField type sequence name put: eachField type sequence]]].
	^sequences
    ]

    allTableNames [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    allTables [
	<category: 'accessing'>
	^self allTableNames collect: [:each | self tableNamed: each asString]
    ]

    cachePolicy [
	"Return the default cache policy that will be used for descriptors that don't specify their own policy"

	<category: 'accessing'>
	cachePolicy isNil ifTrue: [cachePolicy := CachePolicy default].
	^cachePolicy
    ]

    cachePolicy: aCachePolicy [
	<category: 'accessing'>
	cachePolicy := aCachePolicy
    ]

    constructAllClasses [
	<category: 'accessing'>
	^IdentitySet new
    ]

    defaultTracing [
	<category: 'accessing'>
	^Tracing new
    ]

    platform [
	<category: 'accessing'>
	^platform
    ]

    platform: dbPlatform [
	<category: 'accessing'>
	platform := dbPlatform
    ]

    session [
	<category: 'accessing'>
	^session
    ]

    session: anObject [
	<category: 'accessing'>
	session := anObject
    ]

    useDirectAccessForMapping [
	<category: 'accessing'>
	^useDirectAccessForMapping
    ]

    useDirectAccessForMapping: anObject [
	<category: 'accessing'>
	useDirectAccessForMapping := anObject
    ]

    setUpDefaults [
	"For systems that are configurable, set them up for testing configuration"

	<category: 'initialization'>
	
    ]

    initialize [
	<category: 'private'>
	descriptors := Dictionary new.
	tables := Dictionary new.
	typeResolvers := Dictionary new.
	sequences := Dictionary new.
	useDirectAccessForMapping := true
    ]

    initializeDescriptor: aDescriptor [
	<category: 'private'>
	| selector |
	selector := ('descriptorFor' , aDescriptor describedClass name , ':') 
		    asSymbol.
	(self respondsTo: selector) 
	    ifTrue: [self perform: selector with: aDescriptor]
	    ifFalse: 
		[aDescriptor describedClass glorpSetupDescriptor: aDescriptor
		    forSystem: self]
    ]

    initializeTable: newTable [
	<category: 'private'>
	self perform: ('tableFor' , newTable name , ':') asSymbol with: newTable.
	newTable postInitializeIn: self
    ]

    newDescriptorFor: aClass [
	<category: 'private'>
	| newDescriptor |
	(self allClasses includes: aClass) ifFalse: [^nil].
	newDescriptor := Descriptor new.
	newDescriptor system: self.
	newDescriptor describedClass: aClass.
	self initializeDescriptor: newDescriptor.
	^newDescriptor
    ]

    newTypeResolverFor: aClass [
	<category: 'private'>
	| selector |
	(self allClasses includes: aClass) ifFalse: [^nil].
	selector := ('typeResolverFor' , aClass name) asSymbol.
	^(self respondsTo: selector) 
	    ifTrue: [self perform: selector]
	    ifFalse: [aClass glorpTypeResolver]
    ]
]



DescriptorSystem subclass: DynamicDescriptorSystem [
    
    <category: 'Glorp-Mappings'>
    <comment: '
This is a descriptor system whose descriptors and tables are created dynamically rather than out of generated code. Note that identity is extremely important, so care is required to set these up properly.
'>

    DynamicDescriptorSystem class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    allClasses [
	<category: 'accessing'>
	^descriptors keys
    ]

    allTableNames [
	<category: 'accessing'>
	^tables keys
    ]

    privateDescriptorAt: aClass put: aDescriptor [
	"Normally you don't want to be setting tables explicitly, as it may defeat the identity management but it's here if needed"

	<category: 'private'>
	descriptors at: aClass put: aDescriptor
    ]

    privateTableAt: aString put: aTable [
	"Normally you don't want to be setting tables explicitly, as it may defeat the identity management but it's here if needed"

	<category: 'private'>
	tables at: aString put: aTable
    ]
]



BasicTypeResolver subclass: HorizontalTypeResolver [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    HorizontalTypeResolver class >> forRootClass: aClass [
	<category: 'instance creation'>
	^(self new)
	    rootClass: aClass;
	    yourself
    ]

    HorizontalTypeResolver class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    classesRequiringIndependentQueriesFor: aClass [
	<category: 'accessing'>
	^self allDescribedConcreteClasses 
	    select: [:each | each includesBehavior: aClass]
    ]

    describedConcreteClassFor: row withBuilder: builder descriptor: aDescriptor [
	<category: 'accessing'>
	^aDescriptor describedClass
    ]

    isTypeMappingRoot: aDescriptor [
	<category: 'testing'>
	^aDescriptor == rootDescriptor
    ]
]



AbstractNumericType subclass: AbstractIntegerType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    AbstractIntegerType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    converterForStType: aClass [
	<category: 'converting'>
	(aClass includesBehavior: Boolean) 
	    ifTrue: [^self platform converterNamed: #booleanToInteger].
	^self platform converterNamed: #numberToInteger
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Integer
    ]
]



AbstractIntegerType subclass: IntegerDatabaseType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    IntegerDatabaseType class >> LICENSE [
	<category: 'As yet unclassified'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    typeString [
	<category: 'SQL'>
	^'integer'
    ]
]



AbstractIntegerType subclass: SerialType [
    | generated sequence |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    SerialType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'SQL'>
	^sequence 
	    postWriteAssignSequenceValueFor: aDatabaseField
	    in: aDatabaseRow
	    using: aSession
    ]

    preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'SQL'>
	^sequence 
	    preWriteAssignSequenceValueFor: aDatabaseField
	    in: aDatabaseRow
	    using: aSession
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	generated := true
    ]

    initializeForField: aDatabaseField in: aDescriptorSystem [
	<category: 'initialize'>
	sequence isNil ifFalse: [^self].
	sequence := aDescriptorSystem 
		    databaseSequenceNamed: aDatabaseField table name , '_' 
			    , aDatabaseField name , '_SEQ'
    ]

    hasParameters [
	<category: 'accessing'>
	^true
    ]

    hasSequence [
	<category: 'accessing'>
	^true
    ]

    isGenerated [
	"answer if we should autogenerate a value for this type"

	<category: 'accessing'>
	^generated
    ]

    sequence [
	<category: 'accessing'>
	^sequence
    ]

    sequence: aDatabaseSequence [
	<category: 'accessing'>
	sequence := aDatabaseSequence
    ]
]



AbstractIntegerType subclass: SmallintDatabaseType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    SmallintDatabaseType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    typeString [
	<category: 'SQL'>
	^'smallint'
    ]
]



Object subclass: DatabaseAccessor [
    | connection currentLogin platform logging markLogEntriesWithTimestamp |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    LoggingEnabled := nil.

    DatabaseAccessor class >> classForThisPlatform [
	<category: 'instance creation'>
	Dialect isGNU ifTrue: [^Smalltalk Glorp DBIDatabaseAccessor].
	Dialect isSqueak ifTrue: [^Dialect smalltalkAt: #SqueakDatabaseAccessor].
	Dialect isVisualWorks 
	    ifTrue: [^Dialect smalltalkAt: #'Glorp.VWDatabaseAccessor'].
	Dialect isVisualAge ifTrue: [^Dialect smalltalkAt: #VA55DatabaseAccessor].
	Dialect isDolphin ifTrue: [^Dialect smalltalkAt: #DolphinDatabaseAccessor].
	self error: 'unknown dialect'
    ]

    DatabaseAccessor class >> forLogin: aLogin [
	<category: 'instance creation'>
	^self classForThisPlatform new currentLogin: aLogin
    ]

    DatabaseAccessor class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    DatabaseAccessor class >> loggingEnabled [
	<category: 'accessing'>
	LoggingEnabled isNil ifTrue: [LoggingEnabled := false].
	^LoggingEnabled
    ]

    DatabaseAccessor class >> loggingEnabled: aBoolean [
	<category: 'accessing'>
	LoggingEnabled := aBoolean
    ]

    DatabaseAccessor class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    numberOfPreparedStatements [
	<category: 'accessing'>
	^0
    ]

    createSequence: aDatabaseSequence ifError: aBlock [
	<category: 'executing'>
	self doCommand: [self executeSQLString: aDatabaseSequence creationString]
	    ifError: aBlock
    ]

    createTable: aGLORBDatabaseTable ifError: aBlock [
	"This method should be used to create a database table from aTable"

	<category: 'executing'>
	self doCommand: 
		[self executeSQLString: (self platform 
			    createTableStatementStringFor: aGLORBDatabaseTable)]
	    ifError: aBlock
    ]

    createTableFKConstraints: aGLORBDatabaseTable ifError: aBlock [
	"This method should be used to define foreign key constraints for a database table from aTable"

	<category: 'executing'>
	self doCommand: 
		[(self platform 
		    createTableFKContraintsStatementStringsFor: aGLORBDatabaseTable) 
			do: [:ea | self executeSQLString: ea]]
	    ifError: aBlock
    ]

    doCommand: aBlock [
	<category: 'executing'>
	^self doCommand: aBlock ifError: [:ex | self halt]
    ]

    doCommand: aBlock ifError: errorBlock [
	<category: 'executing'>
	^aBlock on: Exception do: errorBlock
    ]

    dropConstraint: aConstraint [
	<category: 'executing'>
	self doCommand: [self executeSQLString: aConstraint dropString]
	    ifError: [:ex | Transcript show: (ex messageText ifNil: [ex printString])]
    ]

    dropSequence: aSequence ifAbsent: aBlock [
	<category: 'executing'>
	self doCommand: [self executeSQLString: 'DROP SEQUENCE ' , aSequence name]
	    ifError: aBlock
    ]

    dropSequences: anArray [
	<category: 'executing'>
	anArray do: 
		[:each | 
		self dropSequence: each
		    ifAbsent: [:ex | Transcript show: (ex messageText ifNil: [ex printString])]]
    ]

    dropTable: aTable ifAbsent: aBlock [
	<category: 'executing'>
	self doCommand: [aTable dropFromAccessor: self] ifError: aBlock
    ]

    dropTableNamed: aString [
	<category: 'executing'>
	self executeSQLString: 'DROP TABLE ' , aString
    ]

    dropTableNamed: aString ifAbsent: aBlock [
	<category: 'executing'>
	self doCommand: [self executeSQLString: 'DROP TABLE ' , aString]
	    ifError: aBlock
    ]

    dropTables: anArray [
	"PostgreSQL drops foreign key constraints implicitly."

	<category: 'executing'>
	anArray do: [:each | each dropForeignKeyConstraintsFromAccessor: self].
	anArray do: 
		[:each | 
		self dropTable: each
		    ifAbsent: [:ex | Transcript show: (ex messageText ifNil: [ex printString])]]
    ]

    executeCommand: command [
	<category: 'executing'>
	^command useBinding 
	    ifTrue: 
		[self executeSQLString: command sqlString withBindings: command bindings]
	    ifFalse: [self executeSQLString: command sqlString]
    ]

    executeCommandReusingPreparedStatements: aCommand [
	"Not all platforms support this, so by default, just execute regularly. Subclasses may override"

	<category: 'executing'>
	self executeCommand: aCommand
    ]

    executeSQLString: aString [
	<category: 'executing'>
	self subclassResponsibility
    ]

    executeSQLString: aTemplateString withBindings: aBindingArray [
	<category: 'executing'>
	self subclassResponsibility
    ]

    externalDatabaseErrorSignal [
	<category: 'executing'>
	self subclassResponsibility
    ]

    connection [
	<category: 'accessing'>
	^connection
    ]

    connectionClass [
	<category: 'accessing'>
	^self connectionClassForLogin: currentLogin
    ]

    currentLogin [
	<category: 'accessing'>
	^currentLogin
    ]

    currentLogin: aLogin [
	<category: 'accessing'>
	currentLogin := aLogin
    ]

    platform [
	<category: 'accessing'>
	^currentLogin database
    ]

    log: aStringOrBlock [
	<category: 'logging'>
	self logging 
	    ifTrue: 
		[Transcript
		    show: (aStringOrBlock isString 
				ifTrue: [aStringOrBlock]
				ifFalse: [aStringOrBlock value]);
		    nl]
    ]

    logError: anErrorObject [
	<category: 'logging'>
	self log: anErrorObject printString
    ]

    logging [
	<category: 'logging'>
	logging isNil ifTrue: [logging := self class loggingEnabled].
	^logging
    ]

    logging: aBoolean [
	<category: 'logging'>
	logging := aBoolean
    ]

    login [
	<category: 'login'>
	| warning |
	self loginIfError: 
		[:ex | 
		warning := 'Unable to log in. Check login information in DatabaseLoginResource class methods'.
		Transcript
		    show: warning;
		    nl.
		self showDialog: warning.
		ex pass].
	"Just to help avoid confusion if someone thinks they're getting a login object back from this"
	^nil
    ]

    loginIfError: aBlock [
	<category: 'login'>
	self subclassResponsibility
    ]

    logout [
	<category: 'login'>
	^self subclassResponsibility
    ]

    showDialog: aString [
	<category: 'login'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initializing'>
	
    ]

    reset [
	<category: 'initializing'>
	
    ]

    copy [
	<category: 'copying'>
	^self shallowCopy postCopy
    ]

    postCopy [
	<category: 'copying'>
	
    ]
]



ElementBuilder subclass: DataElementBuilder [
    
    <category: 'Glorp-Queries'>
    <comment: '
This builds raw data items rather than persistent objects with descriptors. Used if we do something like 
  aQuery retrieve: [:each | each address streetName].
giving us back simple data objects.
This makes building them quite simple.'>

    DataElementBuilder class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    buildObjectFrom: anArray [
	<category: 'building objects'>
	self row: anArray.
	instance := self valueOf: expression
    ]

    findInstanceForRow: aRow useProxy: useProxies [
	<category: 'building objects'>
	^self
    ]

    fieldsForSelectStatement [
	<category: 'selecting fields'>
	^Array with: expression
    ]

    fieldsFromMyPerspective [
	<category: 'selecting fields'>
	^expression mappedFields
    ]
]



AbstractNumericType subclass: DoubleType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DoubleType class >> LICENSE [
	<category: 'As yet unclassified'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    converterForStType: aClass [
	<category: 'converting'>
	^self platform converterNamed: #numberToDouble
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Dialect doublePrecisionFloatClass
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	typeString := 'float8'
    ]
]



DatabaseConverter subclass: PluggableDatabaseConverter [
    | stToDb dbToSt |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    PluggableDatabaseConverter class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    dbToStConverter: aBlock [
	<category: 'accessing'>
	dbToSt := aBlock
    ]

    stToDbConverter: aBlock [
	<category: 'accessing'>
	stToDb := aBlock
    ]

    convert: anObject fromDatabaseRepresentationAs: aDatabaseType [
	<category: 'converting'>
	^dbToSt isNil ifTrue: [anObject] ifFalse: [dbToSt value: anObject]
    ]

    convert: anObject toDatabaseRepresentationAs: aDatabaseType [
	<category: 'converting'>
	^stToDb isNil ifTrue: [anObject] ifFalse: [stToDb value: anObject]
    ]
]



Object subclass: DatabasePlatform [
    | types converters useBinding reservedWords |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DatabasePlatform class [
	| converterRepository |
	
    ]

    UseBindingIfSupported := nil.

    DatabasePlatform class >> createLoginFromConnectionDictionary: aDict [
	<category: '*eoglorp'>
	self subclassResponsibility
    ]

    DatabasePlatform class >> loginWithConnectionDictionary: aDict [
	<category: '*eoglorp'>
	| platformClass |
	platformClass := self allSubclasses 
		    detect: [:cls | cls understandsConnectionDictionary: aDict].
	^platformClass isNil 
	    ifFalse: [platformClass createLoginFromConnectionDictionary: aDict]
	    ifTrue: [nil]
    ]

    DatabasePlatform class >> understandsConnectionDictionary: aDict [
	<category: '*eoglorp'>
	^false
    ]

    DatabasePlatform class >> useBindingIfSupported [
	<category: 'accessing'>
	UseBindingIfSupported isNil ifTrue: [UseBindingIfSupported := false].
	^UseBindingIfSupported
    ]

    DatabasePlatform class >> useBindingIfSupported: aBoolean [
	<category: 'accessing'>
	UseBindingIfSupported := aBoolean
    ]

    DatabasePlatform class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    canBind: aValue to: aType [
	<category: 'testing'>
	(Dialect unbindableClassNames includes: aValue class name) 
	    ifTrue: [^false].
	^true
    ]

    supportsANSIJoins [
	"Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"

	<category: 'testing'>
	^false
    ]

    supportsBinding [
	"Return true if this platform supports binding parameters rather than printing them as strings into the SQL statement"

	<category: 'testing'>
	^false
    ]

    supportsCaseInsensitiveLike [
	<category: 'testing'>
	^false
    ]

    useBinding [
	"Return true if we should use binding"

	<category: 'testing'>
	self supportsBinding ifFalse: [^false].
	useBinding isNil ifTrue: [useBinding := self class useBindingIfSupported].
	^useBinding
    ]

    useBinding: aBoolean [
	<category: 'testing'>
	useBinding := aBoolean
    ]

    useMicrosoftOuterJoins [
	"Return true if we use the Microsoft x *= y syntax for outer joins"

	<category: 'testing'>
	^false
    ]

    useOracleOuterJoins [
	"Return true if we use the old Oracle x = y (+) syntax for outer joins"

	<category: 'testing'>
	^false
    ]

    char [
	<category: 'types'>
	^self typeNamed: #char ifAbsentPut: [CharType new]
    ]

    char: anInteger [
	<category: 'types'>
	^self char width: anInteger
    ]

    character [
	<category: 'types'>
	^self char
    ]

    datetime [
	<category: 'types'>
	^self timestamp
    ]

    inMemorySequence [
	<category: 'types'>
	^self typeNamed: #inMemorySequence
	    ifAbsentPut: [InMemorySequenceDatabaseType representedBy: self int4]
    ]

    int4 [
	<category: 'types'>
	^self subclassResponsibility
    ]

    integer [
	<category: 'types'>
	^self typeNamed: #integer ifAbsentPut: [IntegerDatabaseType new]
    ]

    sequence [
	<category: 'types'>
	^self subclassResponsibility
    ]

    smallint [
	<category: 'types'>
	^self typeNamed: #smallint ifAbsentPut: [SmallintDatabaseType new]
    ]

    text [
	<category: 'types'>
	^self typeNamed: #text ifAbsentPut: [TextType new]
    ]

    timestamp [
	<category: 'types'>
	self subclassResponsibility
    ]

    typeNamed: aSymbol ifAbsentPut: aBlock [
	<category: 'types'>
	| type |
	type := self types at: aSymbol
		    ifAbsentPut: 
			[| newType |
			newType := aBlock value.
			newType platform: self].
	type hasParameters ifTrue: [type := type copy].
	^type
    ]

    types [
	<category: 'types'>
	types == nil ifTrue: [types := IdentityDictionary new].
	^types
    ]

    varChar [
	<category: 'types'>
	^self varchar
    ]

    varchar [
	<category: 'types'>
	^self subclassResponsibility
    ]

    varChar: anInt [
	<category: 'types'>
	^self varchar width: anInt
    ]

    varchar: anInt [
	<category: 'types'>
	^self varchar width: anInt
    ]

    createTableFKContraintsStatementStringsFor: aGLORPDatabaseTable [
	<category: 'services tables'>
	| commandString commands addString |
	commands := OrderedCollection new.
	commandString := 'alter table'.
	addString := 'add'.
	self capitalWritingOfSQLCommands 
	    ifTrue: 
		[commandString := commandString asUppercase.
		addString := addString asUppercase].
	self supportsConstraints 
	    ifTrue: 
		[aGLORPDatabaseTable foreignKeyConstraints do: 
			[:eachKeyField | 
			| sqlStatementStream |
			sqlStatementStream := WriteStream on: String new.
			sqlStatementStream
			    nextPutAll: commandString;
			    space.
			self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.
			sqlStatementStream
			    space;
			    nextPutAll: addString;
			    space;
			    nextPutAll: eachKeyField creationString.
			commands add: sqlStatementStream contents]].
	^commands
    ]

    createTableStatementStringFor: aGLORPDatabaseTable [
	"^<String> This method returns a string which can be used to create a database table ..."

	<category: 'services tables'>
	| sqlStatementStream tmpString |
	tmpString := 'create table'.
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
	    nextPutAll: (self capitalWritingOfSQLCommands 
			ifTrue: [tmpString asUppercase]
			ifFalse: [tmpString]);
	    space.
	self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.

	"Now print the columns specification for each field in the table ..."
	self printColumnsSpecificationFor: aGLORPDatabaseTable
	    on: sqlStatementStream.
	(self supportsConstraints 
	    and: [aGLORPDatabaseTable hasPrimaryKeyConstraints]) 
		ifTrue: 
		    [sqlStatementStream nextPutAll: ', '.
		    self printPrimaryKeyConstraintsOn: sqlStatementStream
			for: aGLORPDatabaseTable].
	sqlStatementStream nextPut: $).
	^sqlStatementStream contents
    ]

    dropTableStatementStringFor: aGLORPDatabaseTable [
	"^<String> This method returns a string which can be used to drop a database table ..."

	<category: 'services tables'>
	| sqlStatementStream tmpString |
	tmpString := 'drop table'.
	sqlStatementStream := WriteStream on: String new.
	sqlStatementStream
	    nextPutAll: (self capitalWritingOfSQLCommands 
			ifTrue: [tmpString asUppercase]
			ifFalse: [tmpString]);
	    space.
	self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.
	^sqlStatementStream contents
    ]

    nameForColumn: aColumnString [
	<category: 'services tables'>
	^aColumnString
    ]

    printDDLTableNameFor: aGLORBDatabaseTable on: sqlStatementStream [
	"This method just writes the name of a table to a stream"

	<category: 'services tables'>
	(aGLORBDatabaseTable schema asString isEmpty not 
	    and: [self prefixQualifierBeforeCreatingAndDeleting]) 
		ifTrue: 
		    [sqlStatementStream
			nextPutAll: (self capitalWritingOfCreatorName 
				    ifTrue: [aGLORBDatabaseTable creator asUppercase]
				    ifFalse: [aGLORBDatabaseTable creator]);
			nextPutAll: self prefixQualifierSeparatorString].
	sqlStatementStream nextPutAll: (self capitalWritingOfTableName 
		    ifTrue: [aGLORBDatabaseTable name asUppercase]
		    ifFalse: [aGLORBDatabaseTable name])
    ]

    printForeignKeyConstraintsOn: sqlStatementStream for: aGLORBDatabaseTable [
	"This method print the constraint specification on sqlStatementStream"

	<category: 'services tables'>
	| sepFlag |
	sepFlag := false.
	aGLORBDatabaseTable foreignKeyConstraints do: 
		[:eachKeyField | 
		sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
		sqlStatementStream nextPutAll: eachKeyField creationString.
		sepFlag := true]
    ]

    printPrimaryKeyConstraintsOn: sqlStatementStream for: aTable [
	"This method print the constraint specification on sqlStatementStream"

	<category: 'services tables'>
	| sepFlag |
	aTable primaryKeyFields isEmpty ifTrue: [^self].
	sqlStatementStream
	    nextPutAll: 'CONSTRAINT ';
	    nextPutAll: aTable primaryKeyConstraintName;
	    nextPutAll: ' PRIMARY KEY  ('.
	sepFlag := false.
	aTable primaryKeyFields do: 
		[:eachPrimaryKeyField | 
		sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
		sqlStatementStream nextPutAll: eachPrimaryKeyField name.
		sepFlag := true].
	sqlStatementStream nextPut: $).
	self primaryKeysAreAutomaticallyUnique ifTrue: [^self].
	sqlStatementStream
	    nextPutAll: ',';
	    nl;
	    nextPutAll: 'CONSTRAINT ';
	    nextPutAll: aTable primaryKeyUniqueConstraintName;
	    nextPutAll: ' UNIQUE  ('.
	sepFlag := false.
	aTable primaryKeyFields do: 
		[:eachPrimaryKeyField | 
		sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
		sqlStatementStream nextPutAll: eachPrimaryKeyField name.
		sepFlag := true].
	sqlStatementStream nextPut: $)
    ]

    validateTableName: tableNameString [
	"<Boolean> I return true, if the choosen tableNameString is valid for the platform"

	<category: 'services tables'>
	^tableNameString size <= self maxLengthOfTableName 
	    and: [(self predefinedKeywords includes: tableNameString asLowercase) not]
    ]

    padString: aString for: aType [
	<category: 'conversion-strings'>
	| padding |
	aString isNil ifTrue: [^nil].
	(self usesNullForEmptyStrings and: [aString isEmpty]) ifTrue: [^nil].
	aString size > aType width ifTrue: [^aString copyFrom: 1 to: aType width].
	aType isVariableWidth ifTrue: [^aString].
	padding := String new: aType width - aString size.
	padding atAllPut: 1 asCharacter.
	^aString , padding
    ]

    stringToStringConverter [
	<category: 'conversion-strings'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #padString:for:
	    fromDbToSt: #unpadString:for:
    ]

    stringToSymbol: aString for: aType [
	<category: 'conversion-strings'>
	^(self unpadString: aString for: aType) asSymbol
    ]

    symbolToString: aSymbol for: aType [
	<category: 'conversion-strings'>
	^self padString: aSymbol asString for: aType
    ]

    symbolToStringConverter [
	<category: 'conversion-strings'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #symbolToString:for:
	    fromDbToSt: #stringToSymbol:for:
    ]

    unpadString: aString for: aType [
	<category: 'conversion-strings'>
	aString isNil 
	    ifTrue: [^self usesNullForEmptyStrings ifTrue: [''] ifFalse: [nil]].
	^aType isVariableWidth 
	    ifTrue: [aString]
	    ifFalse: [(ReadStream on: aString) upTo: 1 asCharacter]
    ]

    areSequencesExplicitlyCreated [
	<category: 'constants'>
	self subclassResponsibility
    ]

    batchWriteStatementTerminatorString [
	"^<String> This statement return the string to be used to devide several statement during batch write ..."

	<category: 'constants'>
	^';'
    ]

    capitalWritingOfColumnName [
	"^<Boolean> This method returns true, if the dbms wants to have column
	 names written in capital letters"

	<category: 'constants'>
	^true
    ]

    capitalWritingOfCreatorName [
	"^<Boolean> This method returns true, if the dbms wants to have column
	 names written in capital letters"

	<category: 'constants'>
	^true
    ]

    capitalWritingOfDatabaseName [
	"^<Boolean>"

	<category: 'constants'>
	^true
    ]

    capitalWritingOfSQLCommands [
	"^<Boolean>"

	<category: 'constants'>
	^true
    ]

    capitalWritingOfTableName [
	"^<Boolean>"

	<category: 'constants'>
	^true
    ]

    columnNameSeparatorString [
	"^<String> This statement return the string to be used to devide several columns ..."

	<category: 'constants'>
	^','
    ]

    deleteViewWithTableSyntax [
	<category: 'constants'>
	^false
    ]

    hasSubtransaction [
	"^<Boolean> This method returns true, if the used dbms is able to execute multiple sql-statements
	 transferred via a command line transmitted from client to server - otherwise I return false"

	<category: 'constants'>
	^true
    ]

    initializeReservedWords [
	<category: 'constants'>
	reservedWords := Dictionary new
    ]

    maxLengthOfColumnName [
	"^<Integer> I return the max. length of a column name"

	<category: 'constants'>
	^18
    ]

    maxLengthOfDatabaseName [
	"^<Integer>I return the max. length of a database name"

	<category: 'constants'>
	^8
    ]

    maxLengthOfTableName [
	"^<Integer> I return the max. length of a table name"

	<category: 'constants'>
	^18
    ]

    maxSQLBufferLength [
	"^<Integer> I return the maximum length of a sql command stream"

	<category: 'constants'>
	^8192
    ]

    postfixTableNameBeforeDeleting [
	<category: 'constants'>
	^false
    ]

    prefixQualifierBeforeCreatingAndDeleting [
	<category: 'constants'>
	^true
    ]

    prefixQualifierSeparatorString [
	"^<String> This statement return the string to be used to separate the qualifier and the table/column name"

	<category: 'constants'>
	^'.'
    ]

    prefixTableNameBeforeDeleting [
	<category: 'constants'>
	^false
    ]

    primaryKeysAreAutomaticallyUnique [
	"Return false if, in addition to specifying something as a primary key, we must separately specify it as unique"

	<category: 'constants'>
	^false
    ]

    reservedWords [
	<category: 'constants'>
	reservedWords isNil ifTrue: [self initializeReservedWords].
	^reservedWords
    ]

    sqlTextForBeginTransaction [
	"comment"

	<category: 'constants'>
	^'BEGIN'
    ]

    sqlTextForDecimalAttributeType: length post: postLength [
	"^<String>"

	<category: 'constants'>
	^'DECIMAL(' , length asString , ',' , postLength asString , ')'
    ]

    sqlTextForDoubleAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^'FLOAT'
    ]

    sqlTextForDoubleLongIntegerAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^''
    ]

    sqlTextForFloatAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^'FLOAT'
    ]

    sqlTextForIntegerAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^'SMALLINT'
    ]

    sqlTextForLongIntegerAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^'INTEGER'
    ]

    sqlTextForNOTNULLAttributeConstraint [
	"^<String>"

	<category: 'constants'>
	^'NOT NULL'
    ]

    sqlTextForNOTNULLWithDefaultAttributeConstraint [
	"^<String>"

	<category: 'constants'>
	^'NOT NULL WITH DEFAULT'
    ]

    sqlTextForNOTUNIQUEAttributeConstraint [
	<category: 'constants'>
	^''
    ]

    sqlTextForNULLAttributeConstraint [
	"^<String>"

	<category: 'constants'>
	^'NULL'
    ]

    sqlTextForTextAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^'LONG'
    ]

    sqlTextForTimeAttributeType [
	"^<String>"

	<category: 'constants'>
	^'TIME'
    ]

    sqlTextForTimestampAttributeType [
	"^<String>"

	<category: 'constants'>
	^'TIMESTAMP'
    ]

    sqlTextForUNIQUEAttributeConstraint [
	<category: 'constants'>
	^'UNIQUE'
    ]

    sqlTextForVariableCharAttributeType: length [
	"^<String>"

	<category: 'constants'>
	^'VARCHAR(' , length asString , ')'
    ]

    sqlWildcardForMultipleCharacters [
	"^<String> This method returns the used wildcard string for multiple characters"

	<category: 'constants'>
	^'%'
    ]

    sqlWildcardForSingleCharacter [
	"^<String> This method returns the used wildcard string for single characters"

	<category: 'constants'>
	^'_'
    ]

    supportsConstraints [
	"Return true if we support integrity constraints"

	<category: 'constants'>
	^true
    ]

    supportsMillisecondsInTimes [
	<category: 'constants'>
	self subclassResponsibility
    ]

    supportsVariableSizedNumerics [
	"Return true if this platform can support numbers with a varying size and number of decimal places. Access, notably, doesn't seem to be able to"

	<category: 'constants'>
	^true
    ]

    usesNullForEmptyStrings [
	"Return true if this database is likely to use nil as an empty string value"

	<category: 'constants'>
	^false
    ]

    usesNullForFalse [
	"Return true if this database is likely to use nil as an empty string value"

	<category: 'constants'>
	^false
    ]

    convertToDouble: aNumber for: aType [
	<category: 'conversion-numbers'>
	aNumber isNil ifTrue: [^nil].
	^Dialect coerceToDoublePrecisionFloat: aNumber
    ]

    convertToFloat: aNumber for: aType [
	<category: 'conversion-numbers'>
	aNumber isNil ifTrue: [^nil].
	^aNumber asFloat
    ]

    convertToInteger: aNumber for: aType [
	<category: 'conversion-numbers'>
	^aNumber isNil ifTrue: [aNumber] ifFalse: [aNumber asNumber asInteger]
    ]

    numberToDoubleConverter [
	<category: 'conversion-numbers'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #convertToDouble:for:
	    fromDbToSt: #convertToDouble:for:
    ]

    numberToFloatConverter [
	<category: 'conversion-numbers'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #convertToFloat:for:
	    fromDbToSt: #convertToFloat:for:
    ]

    numberToIntegerConverter [
	<category: 'conversion-numbers'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #convertToInteger:for:
	    fromDbToSt: #convertToInteger:for:
    ]

    booleanToBooleanConverter [
	<category: 'conversion-boolean'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #convertBooleanToDBBoolean:for:
	    fromDbToSt: #convertDBBooleanToBoolean:for:
    ]

    booleanToIntegerConverter [
	<category: 'conversion-boolean'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #convertBooleanToInteger:for:
	    fromDbToSt: #convertIntegerToBoolean:for:
    ]

    booleanToStringTFConverter [
	<category: 'conversion-boolean'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #convertBooleanToTF:for:
	    fromDbToSt: #convertTFToBoolean:for:
    ]

    convertBooleanToDBBoolean: aBoolean for: aType [
	<category: 'conversion-boolean'>
	(self usesNullForFalse and: [aBoolean isNil]) ifTrue: [^false].
	^aBoolean
    ]

    convertBooleanToInteger: aBoolean for: aType [
	<category: 'conversion-boolean'>
	aBoolean isNil ifTrue: [^nil].
	^aBoolean ifTrue: [1] ifFalse: [0]
    ]

    convertBooleanToTF: aBoolean for: aType [
	<category: 'conversion-boolean'>
	aBoolean isNil ifTrue: [^aBoolean].
	^aBoolean ifTrue: ['T'] ifFalse: ['F']
    ]

    convertDBBooleanToBoolean: aBoolean for: aType [
	<category: 'conversion-boolean'>
	^aBoolean
    ]

    convertIntegerToBoolean: anInteger for: aType [
	<category: 'conversion-boolean'>
	anInteger isNil ifTrue: [^anInteger].
	anInteger = 1 ifTrue: [^true].
	anInteger = 0 ifTrue: [^false].
	self error: 'invalid boolean conversion'
    ]

    convertTFToBoolean: aString for: aType [
	<category: 'conversion-boolean'>
	aString isNil ifTrue: [^aString].
	aString = 'T' ifTrue: [^true].
	aString = 'F' ifTrue: [^false].
	self error: 'invalid boolean conversion'
    ]

    dateConverter [
	<category: 'conversion-times'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #nullConversion:for:
	    fromDbToSt: #readDate:for:	"#printDate:for:"
    ]

    printDate: aTimestamp isoFormatOn: stream [
	"Print the date as yyyy-mm-dd"

	<category: 'conversion-times'>
	| monthNumber dayOfMonth |
	aTimestamp isNil ifTrue: [^'NULL'].
	aTimestamp year printOn: stream.
	stream nextPut: $-.
	monthNumber := (Dialect isVisualWorks and: [aTimestamp class == Date]) 
		    ifTrue: [aTimestamp monthIndex]
		    ifFalse: [aTimestamp month].
	stream nextPutAll: (DatabaseType padToTwoDigits: monthNumber).
	stream nextPut: $-.
	dayOfMonth := aTimestamp class == Date 
		    ifTrue: [aTimestamp dayOfMonth]
		    ifFalse: [aTimestamp day].
	stream nextPutAll: (DatabaseType padToTwoDigits: dayOfMonth)
    ]

    printTime: aTimestamp isoFormatOn: stream [
	<category: 'conversion-times'>
	self 
	    printTime: aTimestamp
	    isoFormatOn: stream
	    milliseconds: self supportsMillisecondsInTimes
    ]

    printTime: aTimestamp isoFormatOn: stream milliseconds: aBoolean [
	"Print the time as hh:mm:ss.mmm"

	<category: 'conversion-times'>
	| ms |
	aTimestamp isNil ifTrue: [^nil].
	stream nextPutAll: (DatabaseType padToTwoDigits: aTimestamp hours).
	stream nextPut: $:.
	stream nextPutAll: (DatabaseType padToTwoDigits: aTimestamp minutes).
	stream nextPut: $:.
	stream nextPutAll: (DatabaseType padToTwoDigits: aTimestamp seconds).
	aBoolean ifFalse: [^self].
	ms := aTimestamp milliseconds.
	ms = 0 ifTrue: [^self].
	stream nextPut: $..
	ms < 100 ifTrue: [stream nextPut: $0].
	stream nextPutAll: (DatabaseType padToTwoDigits: ms)
    ]

    printTimestamp: aTimestamp for: aType [
	<category: 'conversion-times'>
	^'''' , aTimestamp printString , ''''
    ]

    readDate: anObject for: aType [
	"format '2003-03-13"

	<category: 'conversion-times'>
	anObject isNil ifTrue: [^nil].
	anObject class == Date ifTrue: [^anObject].
	anObject isString 
	    ifTrue: [^self readDateFromStream: (ReadStream on: anObject) for: aType].
	^anObject asDate
    ]

    readDateFromStream: aStream for: aType [
	"Seems like we get to do this ourselves, in a lowest common denominator kind of way. Translate into GMT if we've got a timezone."

	"assumes ISO format.
	 self readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.
	 self readTimestamp: '2003-03-03 19:29:28.337-05' for: nil
	 "

	<category: 'conversion-times'>
	| years months days |
	years := (aStream upTo: $-) asNumber.
	months := (aStream upTo: $-) asNumber.
	days := (aStream upTo: $ ) asNumber.
	^Dialect 
	    newDateWithYears: years
	    months: months
	    days: days
    ]

    readTime: anObject for: aType [
	"format 15:29:28.337-05  (timezone optional)"

	<category: 'conversion-times'>
	anObject isNil ifTrue: [^nil].
	anObject class == Time ifTrue: [^anObject].
	anObject isString 
	    ifTrue: [^self readTimeFromStream: (ReadStream on: anObject) for: aType].
	^anObject asTime
    ]

    readTimeFromStream: aStream for: aType [
	"Seems like we get to do this ourselves, in a lowest common denominator kind of way. Ignore timezones right now"

	"assumes ISO format.
	 self readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.
	 self readTimestamp: '2003-03-03 19:29:28.337-05' for: nil
	 "

	<category: 'conversion-times'>
	| hours minutes seconds milliseconds timeZoneOffset millisecondAccumulator |
	hours := (aStream upTo: $:) asNumber.
	minutes := (aStream upTo: $:) asNumber.
	seconds := (aStream next: 2) asNumber.
	aStream peek = $. 
	    ifTrue: 
		[aStream next.
		millisecondAccumulator := WriteStream on: String new.
		[aStream atEnd not and: [aStream peek isDigit]] 
		    whileTrue: [millisecondAccumulator nextPut: aStream next].
		milliseconds := millisecondAccumulator contents asNumber]
	    ifFalse: [milliseconds := 0].
	timeZoneOffset := aStream upToEnd asNumber.
	^Dialect 
	    newTimeWithHours: hours
	    minutes: minutes
	    seconds: seconds
	    milliseconds: milliseconds
	"^Dialect addSeconds: (timeZoneOffset * -1* 60 * 60) to: aTime."
    ]

    readTimestamp: anObject for: aType [
	"Seems like we get to do this ourselves, in a lowest common denominator kind of way. Translate into GMT if we've got a timezone."

	"assumes ISO format.
	 self readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.
	 self readTimestamp: '2003-03-03 19:29:28.337-05' for: nil"

	<category: 'conversion-times'>
	anObject isNil ifTrue: [^nil].
	anObject class == Dialect timestampClass ifTrue: [^anObject].
	anObject isString 
	    ifTrue: 
		[| stream |
		stream := ReadStream on: anObject.
		^self readTimestampFromStream: stream for: aType].
	^anObject asTimestamp
    ]

    readTimestampFromStream: aStream for: aType [
	<category: 'conversion-times'>
	| years months days hours minutes seconds millisecondAccumulator milliseconds timeZoneOffset |
	years := (aStream upTo: $-) asNumber.
	months := (aStream upTo: $-) asNumber.
	days := (aStream upTo: $ ) asNumber.
	hours := (aStream upTo: $:) asNumber.
	minutes := (aStream upTo: $:) asNumber.
	seconds := (aStream next: 2) asNumber.
	aStream peek = $. 
	    ifTrue: 
		[aStream next.
		millisecondAccumulator := WriteStream on: String new.
		[aStream atEnd not and: [aStream peek isDigit]] 
		    whileTrue: [millisecondAccumulator nextPut: aStream next].
		milliseconds := millisecondAccumulator contents asNumber]
	    ifFalse: [milliseconds := 0].
	timeZoneOffset := aStream upToEnd asNumber * 60 * 60.
	^Dialect 
	    newTimestampWithYears: years
	    months: months
	    days: days
	    hours: hours
	    minutes: minutes
	    seconds: seconds
	    milliseconds: milliseconds
	    offset: timeZoneOffset
    ]

    timeConverter [
	<category: 'conversion-times'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #nullConversion:for:
	    fromDbToSt: #readTime:for:	"#printTime:for:"
    ]

    timestampConverter [
	<category: 'conversion-times'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #nullConversion:for:
	    fromDbToSt: #readTimestamp:for:	"#printTimestamp:for:"
    ]

    converterNamed: aSymbol [
	<category: 'type converters'>
	^self converters at: aSymbol
	    ifAbsentPut: 
		[| converter |
		converter := self perform: (aSymbol , 'Converter') asSymbol.
		converter name: aSymbol]
    ]

    converters [
	<category: 'type converters'>
	converters isNil ifTrue: [converters := IdentityDictionary new].
	^converters
    ]

    predefinedKeywords [
	"
	 ^<OrderdCollection of: String> This method returns a list of preserved keyword, which should
	 not be used in database-, table or column names or any othe names in the platform system
	 "

	<category: 'general services'>
	^OrderedCollection new
    ]

    nullConversion: anObject for: aType [
	<category: 'conversion-null'>
	^anObject
    ]

    nullConverter [
	<category: 'conversion-null'>
	^DelegatingDatabaseConverter 
	    hostedBy: self
	    fromStToDb: #nullConversion:for:
	    fromDbToSt: #nullConversion:for:
    ]

    databaseSequenceClass [
	<category: 'sequences'>
	self subclassResponsibility
    ]

    newDatabaseSequenceNamed: aString [
	"Return a sequence of the type we use, with the given name"

	<category: 'sequences'>
	^self databaseSequenceClass named: aString
    ]

    printColumnsSpecificationFor: aGLORBDatabaseTable on: sqlStatementStream [
	<category: 'services columns'>
	aGLORBDatabaseTable fields isEmpty not 
	    ifTrue: 
		[| sepFlag |
		sqlStatementStream
		    space;
		    nextPut: $(.
		sepFlag := false.
		aGLORBDatabaseTable fields do: 
			[:eachGLORBDatabaseField | 
			sepFlag 
			    ifTrue: [sqlStatementStream nextPutAll: self columnNameSeparatorString].
			sqlStatementStream
			    nextPutAll: (self capitalWritingOfColumnName 
					ifTrue: [eachGLORBDatabaseField name asUppercase]
					ifFalse: [eachGLORBDatabaseField name]);
			    space;
			    nextPutAll: eachGLORBDatabaseField typeString;
			    space;
			    nextPutAll: (eachGLORBDatabaseField isNullable 
					ifTrue: [self sqlTextForNULLAttributeConstraint]
					ifFalse: [self sqlTextForNOTNULLAttributeConstraint]);
			    space;
			    nextPutAll: (eachGLORBDatabaseField isUnique 
					ifTrue: [self sqlTextForUNIQUEAttributeConstraint]
					ifFalse: [self sqlTextForNOTUNIQUEAttributeConstraint]).
			sepFlag := true]]
    ]
]



AbstractReadQuery subclass: SimpleQuery [
    | fields distinctFields builders joins |
    
    <category: 'Glorp-Queries'>
    <comment: '
This is a query that is directly executable. A single query might be more than we can do in a single database read, so we might have to break it down into simple queries. But at the moment we just break anything down into an equivalent single query.

Instance Variables:
    builders	<OrderedCollection of: ElementBuilder)>	The builders that will assemble the object from the row that this query returns.
    fields	<OrderedCollection of: DatabaseField>	The fields being selected.
    traceNodes	<Collection of: GlorpExpression>	 These describe the graph of the objects to be read, so we can specify customer, customer address and customer account all in one read.


'>

    SimpleQuery class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    buildObjectsFromRow: anArray [
	<category: 'executing'>
	| buildersThatReturnResults |
	builders 
	    do: [:each | each findInstanceForRow: anArray useProxy: self returnProxies].
	builders do: [:each | each buildObjectFrom: anArray].
	builders do: [:each | each knitResultIn: self].
	buildersThatReturnResults := builders 
		    select: [:each | tracing retrievalExpressions includes: each expression].
	buildersThatReturnResults do: 
		[:each | 
		each expression canBeUsedForRetrieve 
		    ifFalse: 
			[self error: 'illegal argument for #retrieve: ' , each printString 
				    , '. Use alsoFetch: instead']].
	^buildersThatReturnResults size = 1 
	    ifTrue: [buildersThatReturnResults first instance]
	    ifFalse: [buildersThatReturnResults collect: [:each | each instance]]
    ]

    buildObjectsFromRows: anArray [
	"Build the result list from the given rows, eliminating duplicates (which may be caused by joins)"

	<category: 'executing'>
	^self mightHaveDuplicateRows 
	    ifTrue: [self buildObjectsFromRowsRemovingDuplicates: anArray]
	    ifFalse: 
		[| result |
		result := (self collectionType new: anArray size) writeStream.
		anArray do: [:each | result nextPut: (self buildObjectsFromRow: each)].
		result contents]
    ]

    buildObjectsFromRowsRemovingDuplicates: anArray [
	<category: 'executing'>
	| resultSet results |
	resultSet := Set new: anArray size.
	results := (self collectionType new: anArray size) writeStream.
	anArray do: 
		[:each | 
		| row |
		row := self buildObjectsFromRow: each.
		(resultSet includes: row) 
		    ifFalse: 
			[results nextPut: row.
			resultSet add: row]].
	^results contents
    ]

    computeFields [
	<category: 'executing'>
	builders do: [:each | self computeFieldsFor: each]
    ]

    computeFieldsFor: anElementBuilder [
	<category: 'executing'>
	| translatedFields |
	translatedFields := self 
		    addFields: anElementBuilder fieldsForSelectStatement
		    returningTranslationForFields: anElementBuilder fieldsFromMyPerspective
		    distinct: anElementBuilder requiresDistinct.
	anElementBuilder fieldTranslations: translatedFields
    ]

    readFromDatabaseWithParameters: anArray [
	<category: 'executing'>
	| rows objects valueToReturn |
	rows := self rowsFromDatabaseWithParameters: anArray.
	objects := self buildObjectsFromRows: rows.
	objects do: [:each | session sendPostFetchEventTo: each].
	valueToReturn := readsOneObject 
		    ifTrue: 
			[objects isEmpty ifTrue: [self absentBlock value] ifFalse: [objects first]]
		    ifFalse: [self resultCollectionFor: objects].
	session register: valueToReturn.
	^valueToReturn
    ]

    resultCollectionFor: objects [
	<category: 'executing'>
	| results |
	collectionType isNil ifTrue: [^objects].
	collectionType == objects class ifTrue: [^objects].
	results := collectionType new: objects size.
	results addAll: objects.
	^results
    ]

    rowsFromDatabaseWithParameters: anArray [
	<category: 'executing'>
	self shortCircuitEmptyReturn ifTrue: [^#()].
	^session reusePreparedStatements 
	    ifTrue: 
		[session accessor 
		    executeCommandReusingPreparedStatements: (self sqlWith: anArray)]
	    ifFalse: [session accessor executeCommand: (self sqlWith: anArray)]
    ]

    setUpCriteria [
	<category: 'executing'>
	super setUpCriteria.
	self validateCriteria
    ]

    addJoin: anExpression [
	<category: 'preparing'>
	joins addAll: anExpression asIndependentJoins
    ]

    assignTableAliases [
	<category: 'preparing'>
	| tableNumber allExpressions |
	criteria isPrimaryKeyExpression ifTrue: [^self].
	tableNumber := 1.
	allExpressions := ExpressionGroup with: criteria.
	allExpressions addAll: ordering.
	allExpressions addAll: joins.
	builders do: [:each | allExpressions add: each expression].
	allExpressions do: 
		[:each | 
		"Assume that prepare is all-or-nothing. If any of these nodes has aliases, it means everything was already aliased, possibly in another query instance that shares our criterion"

		each hasTableAliases ifTrue: [^self].
		tableNumber := each assignTableAliasesStartingAt: tableNumber]
    ]

    fixJoins [
	<category: 'preparing'>
	| pseudoJoins realJoins |
	pseudoJoins := joins select: [:each | each tablesForANSIJoin size < 2].
	pseudoJoins do: [:each | criteria := each AND: criteria].
	realJoins := joins select: [:each | each tablesForANSIJoin size >= 2].
	joins := realJoins
    ]

    isPrepared [
	<category: 'preparing'>
	^prepared
    ]

    prepare [
	<category: 'preparing'>
	prepared ifTrue: [^self].
	self setUpCriteria.	"Just in case it hasn't already been done"
	self setupTracing.
	criteria prepareIn: self.
	self fixJoins.
	self assignTableAliases.
	self computeFields.
	prepared := true
    ]

    setupTracing [
	<category: 'preparing'>
	builders isNil ifFalse: [^self].	"Already been done"
	super setupTracing.
	builders := tracing allTracings asArray 
		    collect: [:each | ElementBuilder for: each in: self]
    ]

    traceExpressionInContextFor: anExpression [
	<category: 'preparing'>
	^anExpression rebuildOn: criteria ultimateBaseExpression
    ]

    hasTracing [
	"Return true if we've given this query a tracing already"

	<category: 'testing'>
	^builders notNil
    ]

    mightHaveDuplicateRows [
	<category: 'testing'>
	^builders anySatisfy: [:each | each canCauseDuplicateRows]
    ]

    requiresFullQuery [
	<category: 'testing'>
	^self descriptor classesRequiringIndependentQueries size > 1
    ]

    shortCircuitEmptyReturn [
	"If we have a literal false for criteria, we never need to go to the database"

	<category: 'testing'>
	^criteria class == EmptyExpression and: [criteria isFalse]
    ]

    useANSIJoins [
	<category: 'testing'>
	^self session platform supportsANSIJoins
    ]

    printANSITablesOn: aCommand [
	"Print ourselves using the JOIN... USING syntax. Note that we have to put the joins in the right order because we're not allowed to refer to tables not mentioned yet. Great syntax. Reminds me of Pascal. And so easy to deal with."

	<category: 'sql generation'>
	| printer |
	printer := JoinPrinter for: self.
	printer printJoinsOn: aCommand
    ]

    printCriteriaOn: aCommand [
	<category: 'sql generation'>
	self hasEmptyWhereClause 
	    ifFalse: 
		[aCommand
		    nl;
		    nextPutAll: ' WHERE '.
		criteria printSQLOn: aCommand withParameters: aCommand parameters]
    ]

    printJoinsOn: aCommand [
	<category: 'sql generation'>
	| noLeadIn |
	self platform supportsANSIJoins ifTrue: [^self].
	joins isEmpty ifTrue: [^self].
	noLeadIn := criteria isEmptyExpression.
	noLeadIn ifFalse: [aCommand nextPutAll: ' AND ('].
	GlorpHelper 
	    do: [:each | each printSQLOn: aCommand withParameters: aCommand parameters]
	    for: joins
	    separatedBy: [aCommand nextPutAll: ' AND '].
	noLeadIn ifFalse: [aCommand nextPut: $)]
    ]

    printNormalTablesOn: aCommand [
	<category: 'sql generation'>
	self printNormalTablesOn: aCommand excluding: #()
    ]

    printNormalTablesOn: aCommand excluding: aCollection [
	<category: 'sql generation'>
	| tablesToPrint |
	tablesToPrint := self tablesToPrint.
	aCollection do: [:each | tablesToPrint remove: each].
	GlorpHelper 
	    print: [:table | table sqlTableName]
	    on: aCommand
	    for: tablesToPrint
	    separatedBy: ', '.
	^tablesToPrint
    ]

    printOrderingOn: aStream [
	<category: 'sql generation'>
	ordering isNil ifTrue: [^self].
	aStream nextPutAll: ' ORDER BY '.
	GlorpHelper 
	    do: [:each | each printSQLOn: aStream withParameters: nil]
	    for: ordering
	    separatedBy: [aStream nextPutAll: ', ']
    ]

    printSelectFields: aCollection on: stream [
	<category: 'sql generation'>
	GlorpHelper 
	    print: 
		[:field | 
		field printSQLOn: stream withParameters: nil.
		'']
	    on: stream
	    for: aCollection
	    separatedBy: ', '
    ]

    printSelectFieldsOn: stream [
	<category: 'sql generation'>
	distinctFields notNil ifTrue: [stream nextPutAll: 'DISTINCT '].
	self printSelectFields: fields on: stream
    ]

    printTablesOn: aCommand [
	<category: 'sql generation'>
	aCommand
	    nl;
	    nextPutAll: ' FROM '.
	self useANSIJoins 
	    ifTrue: [self printANSITablesOn: aCommand]
	    ifFalse: [self printNormalTablesOn: aCommand]
    ]

    signature [
	<category: 'sql generation'>
	session useBinding ifFalse: [^''].
	^self sqlWith: Dictionary new
    ]

    sqlWith: aDictionary [
	<category: 'sql generation'>
	self prepare.
	^SelectCommand 
	    forQuery: self
	    parameters: aDictionary
	    useBinding: session useBinding
	    platform: session platform
    ]

    tablesToPrint [
	<category: 'sql generation'>
	| allTables base |
	base := criteria ultimateBaseExpression.
	"allTables :=  (fields collect: [:each | base aliasedTableFor: each table ifAbsent: [nil]]) asSet."
	allTables := (fields collect: [:each | each table]) asSet.
	allTables addAll: criteria allTablesToPrint.
	joins do: [:eachJoin | allTables addAll: eachJoin allTablesToPrint].
	ordering isNil 
	    ifFalse: [ordering do: [:each | allTables add: each field table]].
	self tracing allTracings 
	    do: [:each | allTables addAll: each allTablesToPrint].
	^allTables asSortedCollection
    ]

    builders [
	<category: 'accessing'>
	^builders
    ]

    criteria: anExpression [
	<category: 'accessing'>
	criteria := anExpression
    ]

    elementBuilderFor: anExpression [
	<category: 'accessing'>
	^builders detect: [:each | each expression == anExpression] ifNone: [nil]
    ]

    fields [
	<category: 'accessing'>
	^fields
    ]

    joins [
	<category: 'accessing'>
	^joins
    ]

    platform [
	<category: 'accessing'>
	^session system platform
    ]

    initResultClass: aClass criteria: theCriteria singleObject: aBoolean [
	<category: 'initialize'>
	super 
	    initResultClass: aClass
	    criteria: theCriteria
	    singleObject: aBoolean.
	prepared := false.
	fields := OrderedCollection new.
	joins := OrderedCollection new
    ]

    addDistinctField: aField [
	<category: 'fields'>
	distinctFields isNil ifTrue: [distinctFields := OrderedCollection new].
	distinctFields add: aField
    ]

    addFields: aliasedFields returningTranslationForFields: originalFields distinct: isDistinct [
	"The query has computed a set of fields the way the mappings see them, which are then transformed to account for field aliasing in embedded mappings. Add those to our collection, and set up the translation which knows which fields are at which index in the resulting row. If necessary, note that those fields are selected as distinct"

	<category: 'fields'>
	| translation |
	translation := IdentityDictionary new.
	aliasedFields with: originalFields
	    do: 
		[:aliased :original | 
		| position |
		position := fields indexOf: aliased.
		position = 0 
		    ifTrue: 
			[fields add: aliased.
			position := fields size.
			isDistinct ifTrue: [self addDistinctField: aliased]].
		translation at: original put: position].
	^translation
    ]

    hasEmptyWhereClause [
	"If we have regular where clause entries, or if we have joins that aren't going to be printed in the tables portion, then we're not empty"

	<category: 'As yet unclassified'>
	criteria isEmptyExpression ifFalse: [^false].
	self useANSIJoins ifTrue: [^true].
	^joins isEmpty
    ]

    asFullQuery [
	<category: 'converting'>
	| newQuery |
	newQuery := ReadQuery new 
		    initResultClass: resultClass
		    criteria: criteria
		    singleObject: readsOneObject.
	newQuery returnProxies: self returnProxies.
	newQuery shouldRefresh: self shouldRefresh.
	newQuery setOrdering: ordering.
	newQuery collectionType: collectionType.
	^newQuery
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	fields := OrderedCollection new.
	joins := OrderedCollection new.
	distinctFields := nil.
	builders := nil
    ]
]



Object subclass: FieldValueWrapper [
    | contents hasValue containedBy |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: nil>

    FieldValueWrapper class >> new [
	<category: 'public'>
	^super new initialize
    ]

    FieldValueWrapper class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    isNowContainedBy: aRow and: aField [
	<category: 'containing'>
	| thisRowsEntries shortCircuit |
	shortCircuit := false.
	thisRowsEntries := containedBy at: aRow
		    ifAbsentPut: 
			[shortCircuit := true.
			OrderedCollection with: aField].
	shortCircuit ifTrue: [^self].
	(thisRowsEntries includes: aField) ifFalse: [thisRowsEntries add: aField]
    ]

    containedBy [
	<category: 'public'>
	^containedBy
    ]

    contents [
	<category: 'public'>
	^contents
    ]

    contents: anObject [
	<category: 'public'>
	(hasValue and: [contents ~= anObject]) 
	    ifTrue: [self error: 'Inconsistent values in field'].
	contents := anObject.
	hasValue := true
    ]

    hasValue [
	<category: 'public'>
	^hasValue
    ]

    initialize [
	<category: 'public'>
	hasValue := false.
	containedBy := IdentityDictionary new
    ]

    printOn: aStream [
	<category: 'public'>
	aStream nextPutAll: '<<'.
	self hasValue ifTrue: [aStream print: contents].
	aStream nextPutAll: '>>'
    ]
]



ObjectExpression subclass: BaseExpression [
    | descriptor |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    BaseExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    additionalExpressions [
	<category: 'accessing'>
	| expressions |
	expressions := OrderedCollection new.
	descriptor typeMapping addTypeMappingCriteriaTo: expressions in: self.
	expressions addAll: self multipleTableExpressions.
	^expressions
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. We don't have a base, but we *are* a base, so return true"

	<category: 'accessing'>
	^true
    ]

    descriptor [
	<category: 'accessing'>
	^descriptor
    ]

    descriptor: aDescriptor [
	<category: 'accessing'>
	descriptor := aDescriptor
    ]

    hasDescriptor [
	<category: 'accessing'>
	^descriptor notNil
    ]

    multipleTableExpressions [
	<category: 'accessing'>
	^self descriptor multipleTableCriteria 
	    collect: [:each | each asExpressionJoiningSource: self toTarget: self]
    ]

    system [
	<category: 'accessing'>
	^descriptor system
    ]

    targetDescriptor [
	<category: 'accessing'>
	self halt
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	^source
    ]

    controlsTables [
	<category: 'preparing'>
	^true
    ]

    fieldsForSelectStatement [
	<category: 'preparing'>
	^descriptor mappedFields
    ]

    rebuildOn: aBaseExpression [
	<category: 'preparing'>
	^aBaseExpression
    ]

    tables [
	<category: 'preparing'>
	^descriptor tables
    ]

    tablesToPrint [
	"We derive the base's tables from the fields that are being selected, but make sure that at least the primary table is listed."

	<category: 'preparing'>
	^Array with: (self aliasedTableFor: descriptor primaryTable)
    ]

    className [
	<category: 'printing'>
	^'Base'
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self className;
	    nextPut: $(.
	self printTreeOn: aStream.
	aStream nextPut: $)
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	descriptor isNil 
	    ifTrue: 
		[aStream nextPutAll: 'Empty Base'.
		^self].
	aStream print: descriptor describedClass.
	self printTableAliasesOn: aStream
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream 
	    print: (descriptor isNil ifTrue: [nil] ifFalse: [descriptor describedClass])
    ]

    canBeUsedForRetrieve [
	"Return true if this is a valid argument for a retrieve: clause"

	<category: 'testing'>
	^true
    ]

    base [
	<category: 'api'>
	^nil
    ]

    getParameter: aDatabaseField [
	<category: 'api'>
	^ParameterExpression forField: aDatabaseField basedOn: self
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	^self
    ]
]



GlorpExpression subclass: ParameterExpression [
    | field base |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    ParameterExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    ParameterExpression class >> forField: aField basedOn: anObjectExpression [
	<category: 'instance creation'>
	^(self new)
	    field: aField base: anObjectExpression;
	    yourself
    ]

    base [
	<category: 'accessing'>
	^base
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^true
    ]

    field [
	<category: 'accessing'>
	^field
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	^base ultimateBaseExpression
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'Parameter('.
	self printTreeOn: aStream.
	aStream nextPut: $)
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	field printSQLOn: aStream withParameters: #()
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing'>
	self field type print: (self valueIn: aDictionary) on: aStream
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	field printSQLOn: aStream withParameters: #()
    ]

    valueIn: aDictionary [
	<category: 'printing'>
	^aDictionary at: field
    ]

    canBind [
	"Return true if this represents a value that can be bound into a prepared statement"

	<category: 'testing'>
	^true
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	^source getField: field
    ]

    field: aDatabaseField base: aBaseExpression [
	<category: 'initialize/release'>
	field := aDatabaseField.
	base := aBaseExpression
    ]

    rebuildOn: aBaseExpression [
	<category: 'As yet unclassified'>
	^aBaseExpression getParameter: field
    ]

    do: aBlock skipping: aSet [
	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	base do: aBlock skipping: aSet.
	aBlock value: self
    ]
]



Object subclass: CacheManager [
    | subCaches session |
    
    <category: 'Glorp-Core'>
    <comment: '
This is the entire cache for a session, consisting of multiple sub-caches, one per class.

Instance Variables:
    session	<Session>	The containing session.
    subCaches	<Dictionary from: Class to: Cache>	The per-class caches.

'>

    CacheManager class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    CacheManager class >> forSession: aSession [
	<category: 'instance creation'>
	^self new session: aSession
    ]

    CacheManager class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    cacheForClass: aClass [
	<category: 'initialize/release'>
	^subCaches at: aClass ifAbsentPut: [self makeCacheFor: aClass]
    ]

    initialize [
	<category: 'initialize/release'>
	subCaches := IdentityDictionary new: 100
    ]

    makeCacheFor: aClass [
	<category: 'initialize/release'>
	| rootClass cache |
	rootClass := session isNil 
		    ifTrue: [aClass]
		    ifFalse: [session lookupRootClassFor: aClass].
	cache := subCaches at: rootClass
		    ifAbsentPut: [Cache newFor: rootClass in: self].
	subCaches at: aClass put: cache.
	^cache
    ]

    release [
	<category: 'initialize/release'>
	subCaches do: [:each | each release]
    ]

    containsObjectForClass: aClass key: aKey [
	<category: 'querying'>
	| cache |
	cache := self cacheForClass: aClass.
	^cache includesKey: aKey
    ]

    hasExpired: anObject [
	<category: 'querying'>
	| key cache |
	key := (session descriptorFor: anObject) primaryKeyFor: anObject.
	cache := self cacheFor: anObject.
	cache isNil ifTrue: [^false].	"We have an uninstantiated proxy."
	^cache hasExpired: key
    ]

    hasExpired: aClass key: key [
	<category: 'querying'>
	| cache |
	cache := self cacheFor: aClass.
	^cache hasExpired: key
    ]

    hasObjectExpiredOfClass: aClass withKey: key [
	<category: 'querying'>
	| cache |
	cache := self cacheForClass: aClass.
	^cache hasExpired: key
    ]

    lookupClass: aClass key: aKey [
	<category: 'querying'>
	^self 
	    lookupClass: aClass
	    key: aKey
	    ifAbsent: [self error: 'cache miss']
    ]

    lookupClass: aClass key: aKey ifAbsent: failBlock [
	<category: 'querying'>
	| object |
	object := (self cacheForClass: aClass) at: aKey ifAbsent: failBlock.
	^(object isKindOf: aClass) ifTrue: [object] ifFalse: [failBlock value]
    ]

    lookupClass: aClass key: aKey ifAbsentPut: failBlock [
	<category: 'querying'>
	^(self cacheForClass: aClass) at: aKey ifAbsentPut: failBlock
    ]

    markAsCurrentOfClass: aClass key: key [
	<category: 'querying'>
	| cache |
	aClass == Proxy ifTrue: [^self].
	cache := self cacheForClass: aClass.
	cache markAsCurrentAtKey: key
    ]

    removeClass: aClass key: aKey [
	<category: 'querying'>
	^self 
	    removeClass: aClass
	    key: aKey
	    ifAbsent: [self error: 'Object not in cache']
    ]

    removeClass: aClass key: aKey ifAbsent: failBlock [
	<category: 'querying'>
	| cache |
	cache := self cacheForClass: aClass.
	(cache includesKey: aKey withClass: aClass) ifFalse: [^failBlock value].
	cache removeKey: aKey ifAbsent: [failBlock value]
    ]

    numberOfElements [
	<category: 'accessing'>
	^subCaches inject: 0 into: [:sum :each | sum + each numberOfElements]
    ]

    session [
	<category: 'accessing'>
	^session
    ]

    session: aSession [
	<category: 'accessing'>
	session := aSession
    ]

    system [
	<category: 'accessing'>
	^self session system
    ]

    cacheFor: anObject [
	"Get the cache for a particular object. Since this could conceivably be passed a proxy, check for that. The cache for an uninstantiated proxy is kind of ambiguous, treat it as nil.  This could also be a class"

	<category: 'private/caching'>
	| nonMetaClass |
	nonMetaClass := anObject isBehavior 
		    ifTrue: [anObject]
		    ifFalse: [anObject class].
	^nonMetaClass == Proxy 
	    ifTrue: 
		[anObject isInstantiated 
		    ifTrue: [self cacheFor: anObject getValue]
		    ifFalse: [nil]]
	    ifFalse: [self cacheForClass: nonMetaClass]
    ]

    expiredInstanceOf: aClass key: aKey [
	<category: 'private/caching'>
	^(self cacheForClass: aClass) expiredInstanceFor: aKey
    ]

    at: aKey insert: anObject [
	<category: 'adding'>
	| subCache |
	subCache := self cacheForClass: anObject class.
	subCache at: aKey ifAbsentPut: [anObject]
    ]
]



CachePolicy subclass: WeakVWCachePolicy [
    
    <category: 'Glorp-Core'>
    <comment: '
This is a cache policy that uses VisualWorks 7.x weak references (ephemerons) to store references to objects, letting them vanish if not referenced. It uses the numberOfElements inst var as an indicator of how many objects to keep hard references to, preventing objects from disappearing too quickly.

Instance Variables:
    
'>

    WeakVWCachePolicy class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    dictionaryClass [
	<category: 'accessing'>
	Dialect isGNU ifTrue: [^Dialect smalltalkAt: #WeakValueLookupTable].
	^Dialect smalltalkAt: #EphemeralValueDictionary ifAbsent: [Dictionary]
    ]

    numberOfReferencesToKeepAround [
	<category: 'accessing'>
	^numberOfElements
    ]

    newItemsIn: aCache [
	<category: 'initialize-release'>
	| items |
	items := super newItemsIn: aCache.
	items manager: aCache.
	^items
    ]

    collectionForExtraReferences [
	<category: 'expiry'>
	^FixedSizeQueue maximumSize: self numberOfReferencesToKeepAround
    ]

    markEntryAsCurrent: item in: aCache [
	<category: 'expiry'>
	aCache markEntryAsCurrent: item
    ]
]



TypeMapping subclass: IdentityTypeMapping [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    IdentityTypeMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    canBeTypeMappingParent [
	<category: 'testing'>
	^false
    ]

    isAbstract [
	<category: 'testing'>
	^false
    ]

    isTypeMappingRoot [
	<category: 'testing'>
	^true
    ]

    mappedFields [
	<category: 'mapping'>
	^#()
    ]

    trace: aTracing context: anExpression [
	"do nothing"

	<category: 'mapping'>
	
    ]
]



TypeMapping subclass: HorizontalTypeMapping [
    | mappedClass isAbstract |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    HorizontalTypeMapping class >> forClass: aClass [
	<category: 'instance creation'>
	^(self new)
	    mappedClass: aClass;
	    yourself
    ]

    HorizontalTypeMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    beAbstract [
	<category: 'accessing'>
	isAbstract := true
    ]

    isAbstract [
	<category: 'accessing'>
	^isAbstract isNil ifTrue: [isAbstract := false] ifFalse: [isAbstract]
    ]

    allDescribedConcreteClasses [
	<category: 'mapping'>
	| col |
	col := (OrderedCollection new)
		    add: self describedClass;
		    addAll: self describedClass allSubclasses;
		    yourself.
	self needsWork: 'This belongs in someone else''s responsibility'.
	^col 
	    select: [:each | (self system descriptorFor: each) typeMapping isAbstract not]
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	"do nothing"

	<category: 'mapping'>
	
    ]

    mappedFields [
	<category: 'mapping'>
	^#()
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	^#()
    ]

    trace: aTracing context: anExpression [
	<category: 'mapping'>
	^self
    ]

    mappedClass: aClass [
	<category: 'initializing'>
	mappedClass := aClass
    ]
]



Object subclass: UnitOfWork [
    | session transaction deletedObjects newObjects rowMap commitPlan deletePlan commitInProgress |
    
    <category: 'Glorp-UnitOfWork'>
    <comment: '
A UnitOfWork keeps track of objects which might potentially be modified and lets you roll them back or commit the changes into the database.

Instance Variables:
    newObjects	<IdentitySet of: Object>	The objects registered with this unit of work. newObjects is probably a bad name for this.
    session	<Session>	The session in which this is all taking place.
    transaction	<ObjectTransaction>	Keeps track of the original object state so that we can revert it.
    rowMap	<RowMap>	A holder for the rows when we are writing out changes.
    commitPlan	<(OrderedCollection of: DatabaseRow)>	The list of rows to be written, in order. Constructed by topological sorting the contents of the row map.

'>

    UnitOfWork class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    UnitOfWork class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    abort [
	<category: 'begin/commit/abort'>
	self reinitialize
    ]

    begin [
	<category: 'begin/commit/abort'>
	self reinitialize
    ]

    commit [
	<category: 'begin/commit/abort'>
	self preCommit.
	self writeRows.
	self postCommit
    ]

    createMementoRowMapFor: objects [
	"Create a rowmap for the objects whose state was already known. We subtract this from the rowmap of all known objects to get the rows that need to be written. New objects are also registered, so we only generate rows here for non-new objects"

	<category: 'begin/commit/abort'>
	| localRowMap |
	localRowMap := RowMapForMementos 
		    withCorrespondenceMap: self correspondenceMap.
	objects keysAndValuesDo: 
		[:original :memento | 
		(self newObjects includes: original) 
		    ifFalse: [session createRowsFor: memento in: localRowMap]].
	^localRowMap
    ]

    createRowMapFor: objects [
	<category: 'begin/commit/abort'>
	| localRowMap |
	localRowMap := RowMap new.
	objects do: [:each | session createRowsFor: each in: localRowMap].
	^localRowMap
    ]

    createRows [
	<category: 'begin/commit/abort'>
	self createRowsForPartialWrites
    ]

    createRowsForCompleteWrites [
	"reference implementation. not called from anywhere"

	<category: 'begin/commit/abort'>
	self 
	    registeredObjectsDo: [:eachObject | session createRowsFor: eachObject in: rowMap].
	self newObjects 
	    do: [:eachObject | session createRowsFor: eachObject in: rowMap].
	deletedObjects 
	    do: [:eachObject | session createDeleteRowsFor: eachObject in: rowMap]
    ]

    createRowsForPartialWrites [
	<category: 'begin/commit/abort'>
	| registeredObjectsRowMap mementoObjectsRowMap |
	registeredObjectsRowMap := self createRowMapFor: self registeredObjects.
	mementoObjectsRowMap := self createMementoRowMapFor: self mementoObjects.
	self newObjects 
	    do: [:eachObject | session createRowsFor: eachObject in: registeredObjectsRowMap].
	rowMap := registeredObjectsRowMap differenceFrom: mementoObjectsRowMap.
	deletedObjects 
	    do: [:eachObject | session createDeleteRowsFor: eachObject in: rowMap]
    ]

    isNewObject: each [
	<category: 'begin/commit/abort'>
	^self newObjects includes: each
    ]

    mementoObjects [
	"Warning: Excessive cleverness!!! The mementoObjects we want to iterate over are the values in the correspondenceMap dictionary. We were getting the values and returning them, but if all we need to do is iterate, then the dictionary itself works fine"

	<category: 'begin/commit/abort'>
	^self correspondenceMap
    ]

    postCommit [
	<category: 'begin/commit/abort'>
	self sendPostWriteNotification.
	self updateSessionCache.
	commitInProgress := false
    ]

    preCommit [
	<category: 'begin/commit/abort'>
	self registerTransitiveClosure.
	commitInProgress := true.
	self createRows.
	self validateRows.
	self buildCommitPlan.
	self sendPreWriteNotification
    ]

    registeredObjects [
	<category: 'begin/commit/abort'>
	^self correspondenceMap keys
    ]

    registerTransitiveClosure [
	"Look for new objects reachable from currently registered objects"

	<category: 'begin/commit/abort'>
	self 
	    registeredObjectsDo: [:eachObject | self registerTransitiveClosureFrom: eachObject]
    ]

    rollback [
	<category: 'begin/commit/abort'>
	self abort
    ]

    validateRows [
	"Perform basic validation. Right now, just test for equal named but non-identical tables, a sign of a malformed  system or other loss of identity"

	<category: 'begin/commit/abort'>
	| tables tableNames |
	tables := Set new.
	rowMap rowsDo: [:each | tables add: each table].
	tableNames := tables collect: [:each | each qualifiedName].
	tables asSet size = tableNames asSet size 
	    ifFalse: [self error: 'multiple table objects with the same name']
    ]

    privateGetRowMap [
	<category: 'private'>
	^rowMap
    ]

    privateGetTransaction [
	<category: 'private'>
	^transaction
    ]

    registerAsNew: anObject [
	<category: 'private'>
	anObject isNil ifTrue: [^nil].
	commitInProgress ifTrue: [self halt].	"Should not happen. Probably indicates that we're triggering proxies during the commit process"
	self newObjects add: anObject.
	self register: anObject.
	^anObject
    ]

    sendPostWriteNotification [
	<category: 'private'>
	self 
	    registeredObjectsDo: [:eachObject | session sendPostWriteEventTo: eachObject]
    ]

    sendPreWriteNotification [
	<category: 'private'>
	self 
	    registeredObjectsDo: [:eachObject | session sendPreWriteEventTo: eachObject]
    ]

    correspondenceMap [
	<category: 'accessing'>
	^transaction undoMap
    ]

    newObjects [
	<category: 'accessing'>
	newObjects isNil ifTrue: [newObjects := IdentitySet new].
	^newObjects
    ]

    numberOfRows [
	<category: 'accessing'>
	^commitPlan size + deletePlan size
    ]

    session [
	"Private - Answer the value of the receiver's ''session'' instance variable."

	<category: 'accessing'>
	^session
    ]

    session: anObject [
	"Private - Set the value of the receiver's ''session'' instance variable to the argument, anObject."

	<category: 'accessing'>
	session := anObject
    ]

    delete: anObject [
	<category: 'deletion'>
	deletedObjects add: anObject
    ]

    hasPendingDeletions [
	<category: 'deletion'>
	^deletedObjects isEmpty not
    ]

    willDelete: anObject [
	<category: 'deletion'>
	^deletedObjects includes: anObject
    ]

    addObject: eachObject toCacheKeyedBy: key [
	<category: 'private/mapping'>
	self session cacheAt: key put: eachObject
    ]

    addToCommitPlan: aRow [
	<category: 'private/mapping'>
	commitPlan add: aRow
    ]

    addToDeletePlan: aRow [
	<category: 'private/mapping'>
	deletePlan add: aRow
    ]

    buildCommitPlan [
	<category: 'private/mapping'>
	| tablesInCommitOrder |
	commitPlan := OrderedCollection new.
	deletePlan := OrderedCollection new.
	tablesInCommitOrder := session tablesInCommitOrder.
	tablesInCommitOrder do: 
		[:eachTable | 
		self rowsForTable: eachTable
		    do: 
			[:eachRow | 
			eachRow forDeletion 
			    ifTrue: [self addToDeletePlan: eachRow]
			    ifFalse: [self addToCommitPlan: eachRow]]]
    ]

    checkIfInstantiationRequiredFor: anObject mapping: eachMapping [
	"Sometimes we have to instantiate the targets if they weren't. Specifically, if there's a relationship where the target has a foreign key to us. e.g. if X has a 1-many to Y, and we don't instantiate the collection of Y, but then replace it with some other collection. The Y's keys have to be updated, so we need to make sure they're read"

	<category: 'private/mapping'>
	| original targetObject mapping |
	mapping := eachMapping applicableMappingForObject: anObject.
	mapping isRelationship ifFalse: [^false].
	original := self originalValueFor: anObject mapping: mapping.
	targetObject := mapping getValueFrom: anObject.
	original == targetObject ifTrue: [^false].
	original class == Proxy ifFalse: [^false].
	original isInstantiated ifTrue: [^false].
	original yourself.
	^true
    ]

    originalValueFor: anObject mapping: eachMapping [
	<category: 'private/mapping'>
	| memento |
	memento := transaction undoMap at: anObject.
	^eachMapping getValueFrom: memento
    ]

    readBackNewRowInformation [
	<category: 'private/mapping'>
	| changedObjects |
	changedObjects := rowMap objects.
	changedObjects do: 
		[:each | 
		| descriptor |
		descriptor := session descriptorFor: each class.
		descriptor isNil 
		    ifFalse: [descriptor readBackNewRowInformationFor: each in: rowMap]]
    ]

    registerTransitiveClosureFrom: anObject [
	<category: 'private/mapping'>
	| descriptor |
	anObject glorpIsCollection 
	    ifTrue: 
		[anObject do: [:each | session register: each].
		^self].
	descriptor := session descriptorFor: anObject class.
	descriptor isNil ifTrue: [^self].
	descriptor mappings 
	    do: [:eachMapping | self checkIfInstantiationRequiredFor: anObject mapping: eachMapping].
	descriptor referencedIndependentObjectsFrom: anObject
	    do: [:eachObject | session register: eachObject]
    ]

    updateSessionCache [
	<category: 'private/mapping'>
	rowMap keysAndValuesDo: 
		[:eachObject :eachRow | 
		eachRow shouldBeWritten 
		    ifTrue: [self updateSessionCacheFor: eachObject withRow: eachRow]].
	deletedObjects do: [:each | session cacheRemoveObject: each]
    ]

    updateSessionCacheFor: anObject withRow: aRow [
	<category: 'private/mapping'>
	| key |
	anObject class == RowMapKey ifTrue: [^self].	"Not cachable"
	key := aRow primaryKey.
	(session cacheContainsObjectForClass: anObject class key: key) 
	    ifFalse: [self addObject: anObject toCacheKeyedBy: key]
    ]

    writeRows [
	<category: 'private/mapping'>
	commitPlan do: [:eachRow | session writeRow: eachRow].
	deletePlan reverseDo: [:eachRow | session writeRow: eachRow].
	self readBackNewRowInformation
    ]

    isRegistered: anObject [
	<category: 'registering'>
	^transaction isRegistered: anObject
    ]

    register: anObject [
	<category: 'registering'>
	| realObject |
	commitInProgress ifTrue: [self halt].	"Should not happen. Probably indicates that we're triggering proxies during the commit process"
	realObject := transaction register: anObject.
	self registerTransitiveClosureFrom: realObject
    ]

    registeredObjectsDo: aBlock [
	<category: 'enumerating'>
	transaction registeredObjectsDo: 
		[:each | 
		(each glorpIsCollection or: [session hasDescriptorFor: each]) 
		    ifTrue: [aBlock value: each]]
    ]

    rowsForTable: aTable do: aBlock [
	<category: 'enumerating'>
	rowMap rowsForTable: aTable do: aBlock
    ]

    initialize [
	<category: 'initializing'>
	transaction := ObjectTransaction new.
	self reinitialize
    ]

    reinitialize [
	<category: 'initializing'>
	rowMap := RowMap new.
	commitInProgress := false.
	deletedObjects := IdentitySet new.
	transaction abort
    ]
]



Object subclass: ForeignKeyConstraint [
    | sourceField targetField name suffixExpression |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    ForeignKeyConstraint class >> sourceField: aDatabaseField targetField: anotherDatabaseField [
	<category: 'instance creation'>
	^self 
	    sourceField: aDatabaseField
	    targetField: anotherDatabaseField
	    suffixExpression: nil
    ]

    ForeignKeyConstraint class >> sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpression [
	<category: 'instance creation'>
	^(self new)
	    sourceField: aDatabaseField
		targetField: anotherDatabaseField
		suffixExpression: suffixExpression;
	    yourself
    ]

    ForeignKeyConstraint class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    sourceField: aDatabaseField targetField: anotherDatabaseField [
	<category: 'initializing'>
	self 
	    sourceField: aDatabaseField
	    targetField: anotherDatabaseField
	    suffixExpression: nil
    ]

    sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpressionString [
	<category: 'initializing'>
	self
	    sourceField: aDatabaseField;
	    targetField: anotherDatabaseField;
	    suffixExpression: suffixExpressionString
    ]

    name [
	<category: 'accessing'>
	name isNil ifTrue: [name := self generateName].
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    sourceField [
	<category: 'accessing'>
	^sourceField
    ]

    sourceField: anObject [
	<category: 'accessing'>
	sourceField := anObject
    ]

    suffixExpression [
	<category: 'accessing'>
	^suffixExpression
    ]

    suffixExpression: anObject [
	<category: 'accessing'>
	suffixExpression := anObject
    ]

    targetField [
	<category: 'accessing'>
	^targetField
    ]

    targetField: anObject [
	<category: 'accessing'>
	targetField := anObject
    ]

    creationString [
	<category: 'printing'>
	| ws |
	ws := WriteStream on: (String new: 50).
	ws
	    nextPutAll: 'CONSTRAINT ';
	    nextPutAll: self name;
	    nextPutAll: ' FOREIGN KEY (';
	    nextPutAll: sourceField name;
	    nextPutAll: ') REFERENCES ';
	    nextPutAll: targetField asConstraintReferenceString.
	self suffixExpression isNil 
	    ifFalse: 
		[ws
		    space;
		    nextPutAll: self suffixExpression].
	^ws contents
    ]

    dropString [
	<category: 'printing'>
	| ws |
	ws := WriteStream on: (String new: 50).
	^ws
	    nextPutAll: 'ALTER TABLE ';
	    nextPutAll: sourceField table sqlString;
	    nextPutAll: ' DROP CONSTRAINT ';
	    nextPutAll: self name;
	    contents
    ]

    generateName [
	<category: 'printing'>
	| stream |
	stream := WriteStream on: (String new: 100).
	sourceField printForConstraintNameOn: stream maxLength: 10.
	stream nextPutAll: '_TO_'.
	targetField printForConstraintNameOn: stream maxLength: 10.
	stream nextPutAll: '_REF'.
	^stream contents
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



AbstractStringType subclass: VarCharType [
    | typeName |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    VarCharType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    typeString [
	<category: 'accessing'>
	^self typeName , '(' , width printString , ')'
    ]

    typeName [
	<category: 'private'>
	^typeName
    ]

    typeName: aString [
	<category: 'private'>
	typeName := aString
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	typeName := 'varchar'
    ]

    isVariableWidth [
	"Return true if this type allows varying length data within a particular instance. e.g., this is true for a varchar, but false for a fixed size character field"

	<category: 'testing'>
	^true
    ]
]



ElementBuilder subclass: ObjectBuilder [
    
    <category: 'Glorp-Queries'>
    <comment: '
This builds full-blown persistent objects with descriptors. This is the most common type of builder.'>

    ObjectBuilder class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    fieldsForSelectStatement [
	<category: 'selecting fields'>
	^self 
	    fieldsFromThePerspectiveOfTheMainSelect: self fieldsFromMyPerspective
    ]

    fieldsFromMyPerspective [
	<category: 'selecting fields'>
	^query returnProxies 
	    ifTrue: [self descriptor table primaryKeyFields]
	    ifFalse: [self descriptor fieldsForSelectStatement]
    ]

    fieldsFromThePerspectiveOfTheMainSelect: aCollection [
	<category: 'selecting fields'>
	^expression translateFields: aCollection
    ]

    buildObjectFrom: anArray [
	<category: 'building objects'>
	self row: anArray.
	self requiresPopulating ifTrue: [self populateInstance].
	self session markAsCurrentOfClass: instance class key: self key
    ]

    buildProxy [
	<category: 'building objects'>
	| parameters |
	parameters := IdentityDictionary new.
	self descriptor primaryTable primaryKeyFields 
	    do: [:eachField | parameters at: eachField put: (self valueOfField: eachField)].
	instance := (self newProxy)
		    session: self session;
		    parameters: parameters.
	^self
    ]

    canBuild [
	"If we have a regular object with a nil primary key, or if we have an embedded object whose values are all nil, we can't build anything (probably due to an outer join)"

	<category: 'building objects'>
	^self descriptor mapsPrimaryKeys ifTrue: [self key notNil] ifFalse: [true]
    ]

    canCache [
	<category: 'building objects'>
	^self descriptor mapsPrimaryKeys
    ]

    findInstanceForRow: aRow useProxy: useProxies [
	<category: 'building objects'>
	instance := nil.
	self row: aRow.
	self canBuild ifFalse: [^self].
	self lookupCachedObject.
	instance isNil 
	    ifFalse: 
		[requiresPopulating := requiresPopulating | query shouldRefresh.
		^self].
	useProxies 
	    ifTrue: [self buildProxy]
	    ifFalse: 
		[requiresPopulating := true.
		instance := (expression descriptor describedConcreteClassFor: self row
			    withBuilder: self) basicNew.
		self canCache ifTrue: [self session cacheAt: self key put: instance]]
    ]

    knitResultIn: aSimpleQuery [
	"Connect up our built object with any other objects that reference it. Used if we retrieve more than one thing in the same query"

	<category: 'building objects'>
	| relatedBuilder |
	expression canKnit ifFalse: [^self].
	relatedBuilder := aSimpleQuery elementBuilderFor: expression base.
	relatedBuilder isNil 
	    ifFalse: 
		[expression mapping 
		    knit: relatedBuilder instance
		    to: self instance
		    in: self]
    ]

    lookupCachedObject [
	<category: 'building objects'>
	| resultClass |
	self canBuild ifFalse: [^self].
	self canCache 
	    ifTrue: 
		[resultClass := expression descriptor describedClass.
		(self session hasExpired: resultClass key: self key) 
		    ifTrue: 
			[instance := self session expiredInstanceOf: resultClass key: self key.
			requiresPopulating := true.
			isExpired := true]
		    ifFalse: 
			[instance := self session cacheLookupForClass: resultClass key: self key.
			requiresPopulating := instance isNil]]
    ]

    newProxy [
	"Create a proxy with a primary key query in which the parameters are the primary key fields"

	<category: 'building objects'>
	| whereExpression |
	whereExpression := Join new.
	self descriptor primaryTable primaryKeyFields 
	    do: [:eachField | whereExpression addSource: eachField target: eachField].
	^Proxy 
	    returningOneOf: query resultClass
	    where: whereExpression
	    in: self session
    ]

    populateInstance [
	<category: 'building objects'>
	key isNil ifTrue: [^self].
	(self system descriptorFor: instance) populateObject: instance
	    inBuilder: self
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPut: $(.
	expression printOn: aStream.
	aStream nextPut: $)
    ]

    canCauseDuplicateRows [
	<category: 'accessing'>
	^expression class == MappingExpression 
	    and: [expression mapping isToManyRelationship]
    ]

    descriptor [
	<category: 'accessing'>
	^expression descriptor
    ]

    instance: anObject [
	<category: 'accessing'>
	instance := anObject
    ]

    key [
	<category: 'accessing'>
	^self primaryKey
    ]

    primaryKey [
	"We use self as a special guard value to indicate that the value hasn't changed"

	<category: 'accessing'>
	key == self ifFalse: [^key].
	self canCache ifFalse: [^nil].
	key := self descriptor table primaryKeyFields 
		    collect: [:each | self valueOfField: each].
	key size = 1 ifTrue: [key := key first].
	^key
    ]

    requiresPopulating [
	<category: 'accessing'>
	^requiresPopulating and: [self returnProxies not]
    ]

    requiresPopulating: aBoolean [
	<category: 'accessing'>
	requiresPopulating := aBoolean
    ]

    returnProxies [
	<category: 'accessing'>
	^query returnProxies
    ]

    initialize [
	<category: 'initializing'>
	requiresPopulating := false.
	isExpired := false
    ]
]



AbstractStringType subclass: TextType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    TextType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	typeString := 'text'
    ]

    isVariableWidth [
	<category: 'testing'>
	^true
    ]
]



Object subclass: FixedSizeQueue [
    | maximumSize items |
    
    <category: 'Glorp-Core'>
    <comment: '
This is a fixed size queue of objects. It''s intended for keeping around a fixed number of references to objects in a weak dictionary. As such its API is rather limited (one method), and it''s write-only.

Instance Variables:
    items	<OrderedCollection>	The items in the queue
    maximumSize	<Integer>	How many items we''re allowed

'>

    FixedSizeQueue class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    FixedSizeQueue class >> maximumSize: anInteger [
	<category: 'instance creation'>
	^self basicNew maximumSize: anInteger
    ]

    FixedSizeQueue class >> new [
	<category: 'instance creation'>
	self error: 'must supply a size'
    ]

    FixedSizeQueue class >> new: anInteger [
	<category: 'instance creation'>
	^self maximumSize: anInteger
    ]

    add: anObject [
	<category: 'api'>
	items add: anObject.
	items size > maximumSize ifTrue: [items removeFirst]
    ]

    maximumSize [
	<category: 'accessing'>
	^maximumSize
    ]

    maximumSize: anInteger [
	<category: 'accessing'>
	maximumSize := anInteger.
	items := OrderedCollection new: maximumSize + 1
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: items size printString.
	aStream nextPut: $/.
	aStream nextPutAll: maximumSize printString.
	aStream nextPutAll: ')'
    ]
]



ProtoObject subclass: Proxy [
    | session query parameters value isInstantiated |
    
    <comment: nil>
    <category: 'Glorp-Queries'>

    Proxy class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    Proxy class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    Proxy class >> returningManyOf: aClass where: aBlock [
	<category: 'instance creation'>
	^self new query: (Query returningManyOf: aClass where: aBlock)
    ]

    Proxy class >> returningManyOf: aClass where: aBlock in: aSession [
	<category: 'instance creation'>
	^(self new)
	    query: (Query returningManyOf: aClass where: aBlock);
	    session: aSession
    ]

    Proxy class >> returningOneOf: aClass where: aBlock [
	<category: 'instance creation'>
	^self new query: (Query returningOneOf: aClass where: aBlock)
    ]

    Proxy class >> returningOneOf: aClass where: aBlock in: aSession [
	<category: 'instance creation'>
	^(self new)
	    query: (Query returningOneOf: aClass where: aBlock);
	    session: aSession
    ]

    isInstantiated [
	<category: 'testing'>
	^isInstantiated
    ]

    class [
	<category: 'accessing'>
	^Proxy
    ]

    parameters [
	<category: 'accessing'>
	^parameters
    ]

    parameters: aDictionary [
	<category: 'accessing'>
	parameters := aDictionary
    ]

    query [
	<category: 'accessing'>
	^query
    ]

    query: aQuery [
	<category: 'accessing'>
	query := aQuery
    ]

    session [
	<category: 'accessing'>
	^session
    ]

    session: aSession [
	<category: 'accessing'>
	session := aSession
    ]

    doesNotUnderstand: aMessage [
	<category: 'initialize'>
	^self getValue perform: aMessage selector withArguments: aMessage arguments
    ]

    initialize [
	<category: 'initialize'>
	isInstantiated := false
    ]

    glorpPostFetch: aSession [
	<category: 'notification'>
	
    ]

    getValue [
	<category: 'api'>
	isInstantiated ifTrue: [^value].
	parameters isNil ifTrue: [parameters := Dictionary new: 0].
	[value := query executeWithParameters: parameters in: session] 
	    ensure: [isInstantiated := true].
	^value
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPut: ${.
	isInstantiated 
	    ifTrue: [self getValue printOn: aStream]
	    ifFalse: 
		[aStream nextPutAll: 'uninstantiated '.
		query readsOneObject ifFalse: [aStream nextPutAll: 'collection of '].
		query resultClass printOn: aStream].
	aStream nextPut: $}
    ]

    printString [
	<category: 'printing'>
	| aStream |
	aStream := WriteStream on: (String new: 16).
	self printOn: aStream.
	^aStream contents
    ]
]



GlorpExpression subclass: EmptyExpression [
    | base value |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    EmptyExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    EmptyExpression class >> on: aValue [
	<category: 'instance creation'>
	^self new value: aValue
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree"

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	base do: aBlock skipping: aSet.
	aBlock value: self
    ]

    rebuildOn: aBaseExpression [
	<category: 'iterating'>
	| copy |
	copy := self copy.
	copy base: aBaseExpression.
	^copy
    ]

    AND: anExpression [
	<category: 'api'>
	anExpression isNil ifTrue: [^self].
	^anExpression
    ]

    OR: anExpression [
	<category: 'api'>
	anExpression isNil ifTrue: [^self].
	^anExpression
    ]

    base [
	<category: 'accessing'>
	^base
    ]

    base: aBaseExpression [
	<category: 'accessing'>
	base := aBaseExpression
    ]

    isFalse [
	<category: 'accessing'>
	^value not
    ]

    isTrue [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	"a value is expected to be nil, true, or false. we treat nil as true"

	<category: 'accessing'>
	value := aValue isNil ifTrue: [true] ifFalse: [aValue]
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	base isNil ifTrue: [base := BaseExpression new].
	^base
    ]

    canHaveBase [
	<category: 'testing'>
	^true
    ]

    isEmptyExpression [
	<category: 'testing'>
	^true
    ]

    printSQLOn: aCommand withParameters: aDictionary [
	<category: 'As yet unclassified'>
	^self
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'empty expression'
    ]
]



Mapping subclass: AdHocMapping [
    | fromDbMappingBlock toDbMappingBlock mappedFields |
    
    <category: 'Glorp-Mappings'>
    <comment: '
AdHocMapping is a configurable sort of mapping, done via two blocks.

The protocol for this is still ugly because the users will have to explicitly make use of the field positions, and probably need to use the elementBuilder''s translation. This should be automated.

'>

    AdHocMapping class >> forAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection [
	<category: 'instance creation'>
	^super new 
	    setAttribute: aSymbol
	    fromDb: fromBlock
	    toDb: toBlock
	    mappingFields: aFieldCollection
    ]

    AdHocMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    field [
	<category: 'mapping'>
	| fields |
	fields := self mappedFields.
	fields size = 1 
	    ifFalse: [self error: 'This mapping does not correspond to exactly one field'].
	^fields first
    ]

    mappedFields [
	<category: 'mapping'>
	^mappedFields
    ]

    mappedTables [
	<category: 'mapping'>
	^(self mappedFields collect: [:each | each table]) asSet
    ]

    referencedIndependentObjectsFrom: anObject [
	"Assumes that the only object this might affect is our primary attribute. That's probably valid. I think."

	<category: 'mapping'>
	| object otherDescriptor |
	object := self getValueFrom: anObject.
	otherDescriptor := self system descriptorFor: object.
	^otherDescriptor isNil ifTrue: [#()] ifFalse: [Array with: object]
    ]

    trace: aTracing context: anExpression [
	<category: 'mapping'>
	^self
    ]

    setAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection [
	<category: 'initialize/release'>
	self attributeName: aSymbol.
	fromDbMappingBlock := fromBlock.
	toDbMappingBlock := toBlock.
	mappedFields := aFieldCollection
    ]

    controlsTables [
	<category: 'testing'>
	^false
    ]

    hasImpliedClauses [
	"We may imply more than one clause, or a clause which is different from the one directly implied by the relationship"

	<category: 'testing'>
	^true
    ]

    isRelationship [
	"True when the mapping associates different persistent classes."

	<category: 'testing'>
	^false
    ]

    isStoredInSameTable [
	<category: 'testing'>
	^true
    ]

    allRelationsFor: rootExpression [
	"We may have multiple relationships."

	<category: 'printing SQL'>
	| tables rows result |
	tables := self mappedTables.
	rows := Dictionary new.
	tables do: [:each | rows at: each put: (DatabaseRow newForTable: each)].
	toDbMappingBlock value: rows value: rootExpression rightChild value.	"Assuming this is a constant"
	result := nil.
	rows do: 
		[:eachRow | 
		| table |
		table := rootExpression leftChild base getTable: eachRow table.
		eachRow fieldsAndValidValuesDo: 
			[:eachField :eachValue | 
			| newExp |
			newExp := (table getField: eachField) get: rootExpression relation
				    withArguments: (Array with: eachValue).
			result := newExp AND: result]].
	^result
    ]

    convertedDbValueOf: anObject [
	<category: 'printing SQL'>
	| tables rows |
	tables := self mappedTables.
	rows := Dictionary new.
	tables do: [:each | rows at: each put: (DatabaseRow newForTable: each)].
	toDbMappingBlock value: rows value: anObject.
	rows 
	    keysAndValuesDo: [:eachTable :eachRow | ^eachRow at: mappedFields first]
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	<category: 'public'>
	| value rows |
	readOnly ifTrue: [^self].
	value := self getValueFrom: anObject.
	rows := Dictionary new.
	descriptor tables do: 
		[:each | 
		rows at: each put: (aRowMap findOrAddRowForTable: each withKey: anObject)].
	toDbMappingBlock value: rows value: value
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	<category: 'public'>
	self setValueIn: anObject
	    to: (fromDbMappingBlock 
		    value: anElementBuilder row
		    value: anElementBuilder
		    value: BaseExpression new)
    ]

    valueIn: anElementBuilder withFieldContextFrom: anExpression [
	<category: 'As yet unclassified'>
	^fromDbMappingBlock 
	    value: anElementBuilder row
	    value: anElementBuilder
	    value: anExpression
    ]
]



Mapping subclass: ConstantMapping [
    | constantValue valueIsSession |
    
    <category: 'Glorp-Mappings'>
    <comment: '
Sometimes you just want a constant value to be set, either in the row, the object or both. And sometimes you just want a non-mapping (e.g. with a ConditionalMapping where one
of the conditions means "this isn''t mapped"). This mapping represents these situations.
It also handles the special case where it''s useful to have access to the session inside a
domain object, by allowing you to map it to an instance variable.

So far only the case of mapping to an inst var is implemented.

Instance Variables:
'>

    ConstantMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    constantValue [
	<category: 'accessing'>
	^constantValue
    ]

    constantValue: anObject [
	<category: 'accessing'>
	constantValue := anObject
    ]

    constantValueIn: aSession [
	<category: 'accessing'>
	^valueIsSession ifTrue: [aSession] ifFalse: [constantValue]
    ]

    constantValueIsSession [
	<category: 'accessing'>
	valueIsSession := true
    ]

    mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	<category: 'accessing'>
	^#()
    ]

    initialize [
	<category: 'initialize/release'>
	super initialize.
	valueIsSession := false
    ]

    getValueFrom: anObject [
	<category: 'api'>
	^constantValue
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	<category: 'mapping'>
	
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	<category: 'mapping'>
	| value |
	value := anElementBuilder isNil 
		    ifTrue: [constantValue]
		    ifFalse: [self constantValueIn: anElementBuilder session].
	self setValueIn: anObject to: value
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	^#()
    ]

    trace: aTracing context: anExpression [
	<category: 'mapping'>
	^self
    ]

    controlsTables [
	"Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

	<category: 'testing'>
	^false
    ]

    isRelationship [
	<category: 'testing'>
	^false
    ]
]



Mapping subclass: DirectMapping [
    | field converter |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    DirectMapping class >> from: attributeName to: field [
	<category: 'instance creation'>
	^self 
	    from: attributeName
	    type: field impliedSmalltalkType
	    to: field
    ]

    DirectMapping class >> from: attributeName type: aClass to: field [
	<category: 'instance creation'>
	^(self new)
	    attributeName: attributeName;
	    field: field;
	    setConverterBetween: aClass and: field
    ]

    DirectMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    convertValueToDatabaseForm: aValue [
	<category: 'mapping'>
	converter isNil ifTrue: [^aValue].
	^converter convertedDbValueOf: aValue
    ]

    expressionFor: anObject [
	"Return our expression using the object's values. e.g. if this was a direct mapping from id->ID and the object had id: 3, then return TABLE.ID=3"

	<category: 'mapping'>
	| value |
	value := attributeAccessor getValueFrom: anObject.
	^(BaseExpression new getField: field) get: #=
	    withArguments: (Array with: value)
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	<category: 'mapping'>
	| dbValue value row |
	readOnly ifTrue: [^self].
	value := self getValueFrom: anObject.
	dbValue := self convertedDbValueOf: value.
	row := aRowMap findOrAddRowForTable: self field table withKey: anObject.
	row at: field put: dbValue
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	<category: 'mapping'>
	| value |
	value := self valueInBuilder: anElementBuilder.
	self setValueIn: anObject to: value
    ]

    readBackNewRowInformationFor: anObject fromRowsIn: aRowMap [
	<category: 'mapping'>
	| value row |
	field isGenerated ifFalse: [^self].
	row := aRowMap findOrAddRowForTable: self field table withKey: anObject.
	value := self convertedStValueOf: (row at: field ifAbsent: [^self]).
	attributeAccessor setValueIn: anObject to: value
    ]

    trace: aTracing context: anExpression [
	<category: 'mapping'>
	^self
    ]

    valueIn: anElementBuilder withFieldContextFrom: anExpression [
	<category: 'mapping'>
	| dbValue |
	dbValue := anElementBuilder 
		    valueOfField: (anExpression translateField: field).
	^self convertedStValueOf: dbValue
    ]

    valueInBuilder: anElementBuilder [
	<category: 'mapping'>
	| dbValue |
	dbValue := anElementBuilder valueOfField: field.
	^self convertedStValueOf: dbValue
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing SQL'>
	self field printSQLOn: aStream withParameters: aDictionary
    ]

    convertedDbValueOf: stValue [
	<category: 'private'>
	^converter isNil 
	    ifTrue: [stValue]
	    ifFalse: 
		[converter convert: stValue toDatabaseRepresentationAs: self field type]
    ]

    convertedStValueOf: dbValue [
	<category: 'private'>
	^converter isNil 
	    ifTrue: [dbValue]
	    ifFalse: 
		[converter convert: dbValue fromDatabaseRepresentationAs: self field type]
    ]

    setConverterBetween: aClass and: aDbField [
	<category: 'initialize-release'>
	aClass isNil ifTrue: [^self].
	converter := field converterForStType: aClass
    ]

    controlsTables [
	"Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

	<category: 'testing'>
	^false
    ]

    isRelationship [
	"True when the mapping associates different persistent classes."

	<category: 'testing'>
	^false
    ]

    isStoredInSameTable [
	<category: 'testing'>
	^true
    ]

    mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	<category: 'testing'>
	^Array with: self field
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'enumerating'>
	^#()
    ]

    converter [
	<category: 'accessing'>
	^converter
    ]

    converter: aDatabaseConverter [
	<category: 'accessing'>
	converter := aDatabaseConverter
    ]

    field [
	"Private - Answer the value of the receiver's ''field'' instance variable."

	<category: 'accessing'>
	^field
    ]

    field: anObject [
	"Private - Set the value of the receiver's ''field'' instance variable to the argument, anObject."

	<category: 'accessing'>
	field := anObject
    ]
]



Object subclass: DatabaseCommand [
    | useBinding stream sqlString platform |
    
    <category: 'Glorp-Core'>
    <comment: nil>

    DatabaseCommand class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    DatabaseCommand class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    bindings [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    blockFactor [
	<category: 'accessing'>
	^5	"A reasonable default if we don't know"
    ]

    parameterFields [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    parameterTypeSignature [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    platform [
	<category: 'accessing'>
	^platform
    ]

    platform: aDatabasePlatform [
	<category: 'accessing'>
	platform := aDatabasePlatform
    ]

    signature [
	<category: 'accessing'>
	^self sqlString , self parameterTypeSignature
    ]

    sqlString [
	<category: 'accessing'>
	sqlString isNil 
	    ifTrue: 
		[stream := WriteStream on: (String new: 100).
		self printSQL.
		sqlString := stream contents.
		stream := nil].
	^sqlString
    ]

    useBinding [
	<category: 'accessing'>
	^useBinding
    ]

    useBinding: aBoolean [
	<category: 'accessing'>
	useBinding := aBoolean
    ]

    nl [
	<category: 'stream behaviour'>
	stream nl
    ]

    nextPut: aCharacter [
	<category: 'stream behaviour'>
	stream nextPut: aCharacter
    ]

    nextPutAll: aString [
	<category: 'stream behaviour'>
	stream nextPutAll: aString
    ]

    space [
	<category: 'stream behaviour'>
	stream space
    ]

    printSQL [
	<category: 'executing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initializing'>
	
    ]

    canBind: aValue to: aType [
	<category: 'testing'>
	useBinding ifFalse: [^false].
	^self platform canBind: aValue to: aType
    ]
]



DatabaseCommand subclass: SelectCommand [
    | query parameters boundExpressions blockFactor |
    
    <category: 'Glorp-Core'>
    <comment: nil>

    SelectCommand class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    SelectCommand class >> forQuery: aQuery parameters: aDictionary [
	<category: 'instance creation'>
	^(self new)
	    query: aQuery;
	    parameters: aDictionary;
	    yourself
    ]

    SelectCommand class >> forQuery: aQuery parameters: aDictionary useBinding: aBoolean platform: aDatabasePlatform [
	<category: 'instance creation'>
	^(self new)
	    query: aQuery;
	    parameters: aDictionary;
	    useBinding: aBoolean;
	    platform: aDatabasePlatform;
	    yourself
    ]

    bindings [
	<category: 'accessing'>
	boundExpressions isNil ifTrue: [^#()].
	^boundExpressions collect: [:each | each bindingIn: self]
    ]

    blockFactor [
	<category: 'accessing'>
	blockFactor isNil ifTrue: [blockFactor := query expectedRows].
	^blockFactor
    ]

    findBoundExpressions [
	<category: 'accessing'>
	self useBinding ifFalse: [^nil].
	boundExpressions := OrderedCollection new.
	query joins , (Array with: query criteria) do: 
		[:eachBigExpression | 
		boundExpressions addAll: (eachBigExpression 
			    select: [:eachIndividualExpressionNode | eachIndividualExpressionNode hasBindableExpressionsIn: self])]
    ]

    parameters [
	<category: 'accessing'>
	^parameters
    ]

    parameters: aDictionary [
	<category: 'accessing'>
	parameters := aDictionary
    ]

    parameterTypeSignature [
	<category: 'accessing'>
	| result |
	result := WriteStream on: String new.
	parameters do: [:each | result nextPutAll: each class name].
	^result contents
    ]

    printSQL [
	<category: 'accessing'>
	stream nextPutAll: 'SELECT '.
	query printSelectFieldsOn: self.
	self findBoundExpressions.
	query printTablesOn: self.
	query printCriteriaOn: self.
	query printJoinsOn: self.
	query printOrderingOn: self
    ]

    query [
	<category: 'accessing'>
	^query
    ]

    query: aQuery [
	<category: 'accessing'>
	query := aQuery
    ]

    canBind: aValue to: aType [
	<category: 'testing'>
	aValue isNil ifTrue: [^false].
	^super canBind: aValue to: aType
    ]
]



DatabaseCommand subclass: RowBasedCommand [
    | row |
    
    <category: 'Glorp-Core'>
    <comment: nil>

    RowBasedCommand class >> LICENSE [
	<category: 'As yet unclassified'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    RowBasedCommand class >> forRow: aDatabaseRow useBinding: aBoolean platform: aDatabasePlatform [
	<category: 'instance creation'>
	^(self new)
	    row: aDatabaseRow;
	    useBinding: aBoolean;
	    platform: aDatabasePlatform;
	    yourself
    ]

    bindings [
	<category: 'accessing'>
	| bound |
	bound := OrderedCollection new.
	self parameterFields do: 
		[:each | 
		(self canBind: (row at: each) to: each type) 
		    ifTrue: [bound add: (row at: each)]].
	^bound asArray
    ]

    parameterTypeSignature [
	<category: 'accessing'>
	| result |
	result := WriteStream on: String new.
	row 
	    keysAndValuesDo: [:eachKey :eachValue | result nextPutAll: eachValue class name].
	^result contents
    ]

    row [
	<category: 'accessing'>
	^row
    ]

    row: anObject [
	<category: 'accessing'>
	row := anObject
    ]
]



RowBasedCommand subclass: DeleteCommand [
    
    <category: 'Glorp-Core'>
    <comment: nil>

    DeleteCommand class >> LICENSE [
	<category: 'As yet unclassified'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    blockFactor [
	<category: 'accessing'>
	^1
    ]

    parameterFields [
	<category: 'accessing'>
	| fields |
	fields := row table primaryKeyFields.
	fields isEmpty ifTrue: [fields := row fields].
	^fields asArray
    ]

    printSQL [
	<category: 'accessing'>
	self nextPutAll: 'DELETE FROM '.
	row table printSQLOn: self withParameters: #().
	self nextPutAll: ' WHERE '.
	row printPrimaryKeyTemplateOn: self
    ]
]



RowBasedCommand subclass: UpdateCommand [
    
    <category: 'Glorp-Core'>
    <comment: nil>

    UpdateCommand class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    blockFactor [
	<category: 'accessing'>
	^1
    ]

    parameterFields [
	<category: 'accessing'>
	^row nonPrimaryKeyFields asArray , row table primaryKeyFields asArray
    ]

    printSQL [
	<category: 'accessing'>
	self nextPutAll: 'UPDATE '.
	row table printSQLOn: self withParameters: #().
	self nextPutAll: ' SET '.
	GlorpHelper 
	    do: [:field | row printEqualityTemplateForField: field on: self]
	    for: row nonPrimaryKeyFields
	    separatedBy: [self nextPut: $,].
	self nextPutAll: ' WHERE '.
	row printPrimaryKeyTemplateOn: self
    ]
]



RowBasedCommand subclass: InsertCommand [
    
    <category: 'Glorp-Core'>
    <comment: nil>

    InsertCommand class >> LICENSE [
	<category: 'As yet unclassified'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    parameterFields [
	<category: 'accessing'>
	| unsortedFields |
	unsortedFields := row nonGeneratedFieldsWithValues.
	^row table fields select: [:each | unsortedFields includes: each]
    ]

    printSQL [
	<category: 'accessing'>
	| fields |
	self nextPutAll: 'INSERT INTO '.
	row table printSQLOn: self withParameters: #().
	fields := row nonGeneratedFieldsWithValues.
	self nextPutAll: ' ('.
	GlorpHelper 
	    do: [:each | self nextPutAll: (platform nameForColumn: each name)]
	    for: fields
	    separatedBy: [self nextPutAll: ','].
	self nextPutAll: ') '.
	self nextPutAll: ' VALUES ('.
	GlorpHelper 
	    do: 
		[:each | 
		(self canBind: (row at: each) to: each type) 
		    ifTrue: [self nextPut: $?]
		    ifFalse: [row printValueOfField: each on: self]]
	    for: fields
	    separatedBy: [self nextPutAll: ','].
	self nextPutAll: ')'
    ]
]



Object subclass: DatabaseSequence [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    DatabaseSequence class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    DatabaseSequence class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    DatabaseSequence class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    creationString [
	<category: 'sequencing'>
	^'Creation string unspecified for this type of sequence'
    ]

    postWriteAssignSequenceValueFor: aField in: aRow [
	<category: 'sequencing'>
	self subclassResponsibility
    ]

    postWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'sequencing'>
	self subclassResponsibility
    ]

    preWriteAssignSequenceValueFor: aField in: aRow [
	<category: 'sequencing'>
	self subclassResponsibility
    ]

    preWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'sequencing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialize/release'>
	
    ]
]



DatabaseSequence subclass: NamedSequence [
    | name |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    NamedSequence class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]
]



DatabaseSequence subclass: TableBasedSequence [
    | sequenceTableName |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    TableBasedSequence class >> default [
	<category: 'defaults'>
	^self new sequenceTableName: 'SEQUENCE'
    ]

    TableBasedSequence class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    sequenceTableName [
	"Private - Answer the value of the receiver's ''sequenceTableName'' instance variable."

	<category: 'accessing'>
	^sequenceTableName
    ]

    sequenceTableName: aString [
	<category: 'accessing'>
	sequenceTableName := aString
    ]
]



NamedSequence subclass: SQLServerSequence [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    SQLServerSequence class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession [
	<category: 'sequencing'>
	aDatabaseRow at: aDatabaseField
	    put: ((aSession accessor executeSQLString: 'SELECT @@IDENTITY') first 
		    atIndex: 1)
    ]

    preWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'sequencing'>
	
    ]
]



DatabaseSequence subclass: JustSelectTheMaximumSequenceValueAndAddOne [
    | tableName |
    
    <category: 'Glorp-Database'>
    <comment: '
This is a sequence that just does a select max(primaryKeyFieldName) for the table in question and adds one to it. This is, um, less-than-perfectly efficient, and I''m not at all clear that it''ll work for a multi-user system. But it''s what Store does on SQL Server, so we''d like to be able to mimic it.

Instance Variables:
    tableName	<DatabaseTable>	the table we sequence.'>

    JustSelectTheMaximumSequenceValueAndAddOne class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    postWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'other'>
	self subclassResponsibility
    ]

    preWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'other'>
	"I repeat: ick"

	| stream rows value |
	stream := WriteStream on: (String new: 50).
	stream nextPutAll: 'SELECT MAX('.
	aField printSQLOn: stream withParameters: #().
	stream nextPutAll: ') FROM '.
	aRow table printSQLOn: stream withParameters: #().
	rows := aSession accessor executeSQLString: stream contents.
	value := rows first first isNil ifTrue: [1] ifFalse: [rows first first + 1].
	aRow at: aField put: value
    ]
]



DatabaseSequence subclass: NullSequence [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    Singleton := nil.

    NullSequence class >> default [
	<category: 'defaults'>
	^self new
    ]

    NullSequence class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    NullSequence class >> new [
	<category: 'instance creation'>
	Singleton isNil ifTrue: [Singleton := self basicNew].
	^Singleton
    ]

    postWriteAssignSequenceValueFor: aField in: aRow [
	<category: 'sequencing'>
	
    ]

    postWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'sequencing'>
	
    ]

    preWriteAssignSequenceValueFor: aField in: aRow [
	<category: 'sequencing'>
	
    ]

    preWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'public'>
	
    ]
]



DatabaseSequence subclass: InMemorySequence [
    | count |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    InMemorySequence class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    InMemorySequence class >> default [
	<category: 'defaults'>
	^self new
    ]

    preWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'public'>
	aRow at: aField put: (count := count + 1)
    ]

    postWriteAssignSequenceValueFor: aField in: aRow [
	<category: 'sequencing'>
	
    ]

    postWriteAssignSequenceValueFor: aField in: aRow using: aSession [
	<category: 'sequencing'>
	
    ]

    preWriteAssignSequenceValueFor: aField in: aRow [
	<category: 'sequencing'>
	aRow at: aField put: (count := count + 1)
    ]

    initialize [
	<category: 'initialize/release'>
	super initialize.
	count := 0
    ]
]



Object subclass: Cache [
    | items policy mainCache extraReferences |
    
    <category: 'Glorp-Core'>
    <comment: '
This is the per-class cache of instances read from the database.

Instance Variables:
    items	<Dictionary from: Object to: Object>	The cached items, keyed by their primary key values
    policy	<CachePolicy>	The settings for this cache.

'>

    Cache class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    Cache class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    Cache class >> newFor: aClass in: aCacheManager [
	<category: 'instance creation'>
	| newCache descriptor |
	descriptor := aCacheManager session isNil 
		    ifFalse: [aCacheManager system descriptorFor: aClass].
	newCache := Cache new.
	newCache mainCache: aCacheManager.
	descriptor isNil 
	    ifTrue: [newCache cachePolicy: CachePolicy default]
	    ifFalse: [newCache cachePolicy: descriptor cachePolicy].
	^newCache
    ]

    basicAt: anObject ifAbsent: aBlock [
	<category: 'private'>
	^items at: anObject ifAbsent: aBlock
    ]

    do: aBlock [
	<category: 'private'>
	items do: aBlock
    ]

    expiredInstanceFor: key [
	"Return the expired instance. Used for refreshing so that we don't recursively try and refresh when we get the instance to be refreshed"

	<category: 'private'>
	| item value |
	item := self basicAt: key
		    ifAbsent: [self error: 'No expired instance found'].
	value := policy contentsOf: item.
	(self hasItemExpired: item) 
	    ifFalse: [self error: 'No expired instance found'].
	^value
    ]

    markAsCurrentAtKey: key [
	<category: 'private'>
	| item |
	item := self basicAt: key ifAbsent: [^false].
	^policy markEntryAsCurrent: item in: self
    ]

    markEntryAsCurrent: anItem [
	"The policy has told us to mark an item as current. This is only really useful for weak policies, which tell us to keep an additional pointer to the object in a (presumably) fixed-size collection"

	<category: 'private'>
	extraReferences isNil ifFalse: [extraReferences add: anItem]
    ]

    at: key ifAbsent: aBlock [
	<category: 'lookup'>
	| item value |
	item := self basicAt: key ifAbsent: [^aBlock value].
	value := policy contentsOf: item.
	(self hasItemExpired: item) 
	    ifTrue: 
		[policy 
		    takeExpiryActionForKey: key
		    withValue: value
		    in: self.
		(items includesKey: key) ifFalse: [^aBlock value]].
	^value
    ]

    at: key ifAbsentPut: aBlock [
	<category: 'lookup'>
	| item |
	item := self at: key ifAbsent: [nil].
	^item isNil 
	    ifTrue: 
		[| newItem |
		newItem := policy cacheEntryFor: aBlock value.
		self markEntryAsCurrent: newItem.
		items at: key put: newItem]
	    ifFalse: 
		[self markEntryAsCurrent: item.
		item]
    ]

    hasExpired: key [
	<category: 'lookup'>
	| item |
	item := self basicAt: key ifAbsent: [^false].
	^self hasItemExpired: item
    ]

    hasItemExpired: anItem [
	<category: 'lookup'>
	^(policy hasExpired: anItem) 
	    and: [(mainCache session isRegistered: (policy contentsOf: anItem)) not]
    ]

    includesKey: key [
	"Return true if we include the object. Don't listen to any expiry policy"

	<category: 'lookup'>
	self basicAt: key ifAbsent: [^false].
	^true
    ]

    includesKey: key withClass: aClass [
	"Return true if we include the object, and it matches our class. Don't listen to any expiry policy"

	<category: 'lookup'>
	| item value |
	item := self basicAt: key ifAbsent: [^false].
	value := policy contentsOf: item.
	^value isKindOf: aClass
    ]

    removeKey: key ifAbsent: aBlock [
	<category: 'lookup'>
	^items removeKey: key ifAbsent: aBlock
    ]

    cachePolicy: aCachePolicy [
	<category: 'accessing'>
	policy := aCachePolicy.
	self initializeCache
    ]

    mainCache [
	<category: 'accessing'>
	^mainCache
    ]

    mainCache: aCacheManager [
	<category: 'accessing'>
	mainCache := aCacheManager
    ]

    numberOfElements [
	<category: 'accessing'>
	^items size
    ]

    session [
	<category: 'accessing'>
	^mainCache session
    ]

    mournKeyOf: anEphemeron [
	<category: 'finalization'>
	policy 
	    takeExpiryActionForKey: anEphemeron key
	    withValue: anEphemeron value
	    in: self
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    initializeCache [
	<category: 'initialize'>
	items := policy newItemsIn: self.
	extraReferences := policy collectionForExtraReferences
    ]

    release [
	<category: 'initialize'>
	policy release: self.
	extraReferences := nil
    ]
]



AbstractNumericType subclass: FloatType [
    
    <category: 'Glorp-Database'>
    <comment: nil>

    FloatType class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    converterForStType: aClass [
	<category: 'converting'>
	^self platform converterNamed: #numberToFloat
    ]

    impliedSmalltalkType [
	<category: 'converting'>
	^Float
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	typeString := 'float4'
    ]
]



Object subclass: GlorpPreparedStatement [
    | signature statement |
    
    <category: 'Glorp-Database'>
    <comment: nil>

    GlorpPreparedStatement class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    GlorpPreparedStatement class >> new [
	"Answer a newly created and initialized instance."

	<category: 'instance creation'>
	^super new initialize
    ]

    signature [
	<category: 'accessing'>
	^signature
    ]

    signature: aString [
	<category: 'accessing'>
	signature := aString
    ]

    statement [
	<category: 'accessing'>
	^statement
    ]

    statement: aStatementHandle [
	<category: 'accessing'>
	statement := aStatementHandle
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    glorpNoticeOfExpiryIn: aSession [
	<category: 'As yet unclassified'>
	statement isNil 
	    ifFalse: 
		[| stmt |
		stmt := statement.
		statement := nil.
		stmt dismiss]
    ]
]



GlorpExpression subclass: FieldExpression [
    | field base |
    
    <category: 'Glorp-Expressions'>
    <comment: nil>

    FieldExpression class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    FieldExpression class >> forField: aField basedOn: anObjectExpression [
	<category: 'instance creation'>
	^(self new)
	    field: aField base: anObjectExpression;
	    yourself
    ]

    base [
	<category: 'accessing'>
	^base
    ]

    basicField [
	<category: 'accessing'>
	^field
    ]

    canHaveBase [
	"Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."

	<category: 'accessing'>
	^true
    ]

    field [
	<category: 'accessing'>
	^base translateField: field
    ]

    ultimateBaseExpression [
	<category: 'navigating'>
	^base ultimateBaseExpression
    ]

    asExpressionJoiningSource: source toTarget: target [
	"Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
	 Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get
	 (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
	 The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

	<category: 'preparing'>
	| newTarget |
	newTarget := (target tables includes: field table) 
		    ifTrue: [target]
		    ifFalse: [base asExpressionJoiningSource: source toTarget: target].
	^newTarget getField: field
    ]

    tables [
	<category: 'preparing'>
	^base tables
    ]

    tablesToPrint [
	<category: 'preparing'>
	^#()
    ]

    printOnlySelfOn: aStream [
	<category: 'printing'>
	base printsTable 
	    ifTrue: [field printUnqualifiedSQLOn: aStream withParameters: #()]
	    ifFalse: [field printSQLOn: aStream withParameters: #()]
    ]

    printTreeOn: aStream [
	<category: 'printing'>
	base printOn: aStream.
	aStream nextPut: $..
	base printsTable 
	    ifTrue: [field printUnqualifiedSQLOn: aStream withParameters: #()]
	    ifFalse: [field printSQLOn: aStream withParameters: #()]
    ]

    convertedDbValueOf: anObject [
	"We don't do any conversion"

	<category: 'As yet unclassified'>
	^anObject
    ]

    rebuildOn: aBaseExpression [
	<category: 'As yet unclassified'>
	^(base rebuildOn: aBaseExpression) getField: field
    ]

    tableForANSIJoin [
	<category: 'As yet unclassified'>
	^self field table
    ]

    printSQLOn: aStream withParameters: aDictionary [
	<category: 'printing SQL'>
	self field printSQLOn: aStream withParameters: aDictionary
    ]

    field: aField base: anObjectExpression [
	<category: 'initializing'>
	field := aField.
	base := anObjectExpression
    ]

    do: aBlock skipping: aSet [
	"Iterate over the expression tree"

	<category: 'iterating'>
	(aSet includes: self) ifTrue: [^self].
	aSet add: self.
	base do: aBlock skipping: aSet.
	aBlock value: self
    ]

    get: aSymbol withArguments: anArray [
	<category: 'api'>
	| functionExpression |
	functionExpression := self getFunction: aSymbol withArguments: anArray.
	functionExpression isNil ifFalse: [^functionExpression].
	anArray isEmpty 
	    ifTrue: [self error: 'Field expressions do not have attributes'].
	^RelationExpression 
	    named: aSymbol
	    basedOn: self
	    withArguments: anArray
    ]
]



Mapping subclass: RelationshipMapping [
    | referenceClass mappingCriteria shouldProxy query |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    RelationshipMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    allTables [
	<category: 'accessing'>
	mappingCriteria isNil ifTrue: [^#()].
	^mappingCriteria allTables
    ]

    mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	<category: 'accessing'>
	^self mappingCriteria allSourceFields
    ]

    mappingCriteria [
	"Private - Answer the value of the receiver's ''mappingCriteria'' instance variable."

	<category: 'accessing'>
	^mappingCriteria
    ]

    mappingCriteria: anObject [
	"Private - Set the value of the receiver's ''mappingCriteria'' instance variable to the argument, anObject."

	<category: 'accessing'>
	mappingCriteria := anObject
    ]

    referenceClass [
	"Private - Answer the value of the receiver's ''referenceClass'' instance variable."

	<category: 'accessing'>
	^referenceClass
    ]

    referenceClass: aClass [
	"Private - Set the value of the receiver's ''referenceClass'' instance variable to the argument, anObject."

	<category: 'accessing'>
	aClass isBehavior ifFalse: [self error: 'reference class must be a class'].
	referenceClass := aClass
    ]

    referenceDescriptor [
	<category: 'accessing'>
	^self system descriptorFor: self referenceClass
    ]

    shouldProxy [
	<category: 'accessing'>
	^shouldProxy
    ]

    shouldProxy: aBoolean [
	<category: 'accessing'>
	shouldProxy := aBoolean
    ]

    controlsTables [
	"Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

	<category: 'testing'>
	^true
    ]

    isRelationship [
	"True when the mapping associates different persistent classes."

	<category: 'testing'>
	^true
    ]

    isStoredInSameTable [
	<category: 'testing'>
	^false
    ]

    initialize [
	<category: 'initializing'>
	super initialize.
	shouldProxy := true
    ]

    buildQuery [
	<category: 'mapping'>
	self subclassResponsibility
    ]

    extendedMappingCriteria [
	<category: 'mapping'>
	^mappingCriteria
    ]

    isValidTarget: anObject [
	<category: 'mapping'>
	^anObject class == Proxy 
	    ifTrue: [anObject isInstantiated]
	    ifFalse: 
		["anObject notNil"

		true]
    ]

    knit: ourObject to: anotherObject in: anObjectBuilder [
	"Set up the relationship from our object to another one, indicated by our mapping"

	<category: 'mapping'>
	
    ]

    mapFromObject: anObject intoRowsIn: aRowMap [
	"Our target is a collection. The tricky bit is that if we're building rows into a RowMapForMementos, then the collection we contain isn't the one we want to use. We want the old version. Ask the row map to give it to us. If it's a normal row map, we'll just get the same thing back"

	<category: 'mapping'>
	| target mementoizedTarget |
	readOnly ifTrue: [^self].
	target := self getValueFrom: anObject.
	target := self session realObjectFor: target ifNone: [^self].
	(self isValidTarget: target) 
	    ifTrue: 
		[mementoizedTarget := aRowMap collectionMementoFor: target.
		self 
		    mapFromObject: anObject
		    toTarget: mementoizedTarget
		    puttingRowsIn: aRowMap]
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	<category: 'mapping'>
	| parameters |
	parameters := IdentityDictionary new.
	mappingCriteria fieldsDo: 
		[:eachSource :eachTarget | 
		parameters at: eachSource put: (anElementBuilder valueOfField: eachSource)].
	self setValueIn: anObject
	    to: (self shouldProxy 
		    ifTrue: 
			[(self newProxy)
			    session: descriptor session;
			    parameters: parameters]
		    ifFalse: [self query executeWithParameters: parameters in: descriptor session])
    ]

    query [
	<category: 'mapping'>
	query isNil ifTrue: [self buildQuery].
	^query
    ]

    joinExpressionFor: targetExpression [
	"We're looking for the object represented by this mapping, and we know the object represented by its source. Use our mapping criteria to construct a join that traverses that instance of this relationship"

	<category: 'preparing'>
	| sourceExpression |
	sourceExpression := targetExpression base.
	^self extendedMappingCriteria asExpressionJoiningSource: sourceExpression
	    toTarget: targetExpression
    ]

    multipleTableExpressionsFor: anExpression [
	<category: 'preparing'>
	^self referenceDescriptor multipleTableCriteria 
	    collect: [:each | each asExpressionJoiningSource: anExpression toTarget: anExpression]
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'api'>
	^self getValueFrom: anObject
    ]

    trace: aTracing context: anExpression [
	"Currently we don't trace relationships across tables, so all we do here
	 is accumulate the list of embedded mappings"

	<category: 'processing'>
	| newContext |
	(aTracing tracesThrough: self) ifFalse: [^self].
	newContext := anExpression get: attributeName.
	aTracing addExpression: newContext.
	self referenceDescriptor trace: aTracing context: newContext
    ]

    newProxy [
	<category: 'proxies'>
	| proxy |
	proxy := Proxy new.
	proxy query: self query.
	^proxy
    ]
]



RelationshipMapping subclass: OneToOneMapping [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    OneToOneMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    buildQuery [
	<category: 'mapping'>
	query := Query returningOneOf: referenceClass where: mappingCriteria.
	^query
    ]

    knit: ourObject to: anotherObject in: anObjectBuilder [
	"Set up the relationship from our object to another one, indicated by our mapping"

	<category: 'mapping'>
	self setValueIn: ourObject to: anotherObject
    ]

    mapFromObject: anObject toTarget: target puttingRowsIn: aRowMap [
	<category: 'mapping'>
	mappingCriteria 
	    mapFromSource: anObject
	    andTarget: target
	    intoRowsIn: aRowMap
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'mapping'>
	^Array with: (self getValueFrom: anObject)
    ]
]



OneToOneMapping subclass: EmbeddedValueOneToOneMapping [
    | fieldTranslation |
    
    <category: 'Glorp-Mappings'>
    <comment: '
This represents a one-to-one mapping in which the referenced object is stored as part of the same table as the containing object.
'''>

    EmbeddedValueOneToOneMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    joinExpressionFor: targetExpression [
	"We're looking for the object represented by this mapping, and we know the object represented by its source. Use our mapping criteria to construct a join that traverses that instance of this relationship.
	 Embedded values never induce a join."

	<category: 'preparing'>
	^nil
    ]

    defaultTransformationExpressionFor: aDescriptor [
	"If there's no transformation, get all the mapped fields from the other descriptor and construct a transformation of each onto itself. This lets us unify the fields in my row with the fields in its row"

	<category: 'transformations'>
	| fields transform |
	fields := IdentitySet new.
	aDescriptor mappings do: [:each | fields addAll: each mappedFields].
	transform := Join new.
	fields do: [:each | transform addSource: each target: each].
	^transform
    ]

    hasTransformation [
	<category: 'transformations'>
	^false
    ]

    transformationExpression [
	<category: 'transformations'>
	^self hasFieldTranslation 
	    ifTrue: [fieldTranslation]
	    ifFalse: [self defaultTransformationExpressionFor: self referenceDescriptor]
    ]

    fieldsForSelectStatement [
	"Return a collection of fields that this mapping will read from a row"

	"Return nothing, because our sub-objects will take care of adding their own fields, translated correctly through us."

	<category: 'internal'>
	^#()
    ]

    mappedFields [
	"Return a collection of fields that this mapping will write into any of the containing object's rows"

	<category: 'internal'>
	fieldTranslation isNil ifFalse: [^fieldTranslation allSourceFields].
	^self referenceDescriptor mappedFields
    ]

    controlsTables [
	"Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

	<category: 'testing'>
	^false
    ]

    isStoredInSameTable [
	<category: 'testing'>
	^true
    ]

    shouldProxy [
	<category: 'testing'>
	^false
    ]

    fieldTranslation [
	<category: 'accessing'>
	^fieldTranslation
    ]

    fieldTranslation: aPrimaryKeyExpression [
	<category: 'accessing'>
	fieldTranslation := aPrimaryKeyExpression
    ]

    hasFieldTranslation [
	<category: 'accessing'>
	^fieldTranslation notNil
    ]

    mapFromObject: anObject toTarget: target puttingRowsIn: aRowMap [
	<category: 'mapping'>
	self transformationExpression 
	    mapFromSource: anObject
	    andTarget: target
	    intoRowsIn: aRowMap.
	(aRowMap rowsForKey: target) do: [:each | each shouldBeWritten: false]
    ]

    mapObject: anObject inElementBuilder: anElementBuilder [
	<category: 'mapping'>
	"If the object already has a value in my slot, then this it got a cache hit, the embedded value was carried along for the ride, and we don't need to assign anything"

	| myTraceNode myBuilder |
	(self getValueFrom: anObject) isNil ifFalse: [^self].	"Otherwise, we need to look up the trace node that corresponds to this mapping, and get its instance"
	myTraceNode := anElementBuilder expression get: attributeName.
	myBuilder := anElementBuilder query elementBuilderFor: myTraceNode.
	self setValueIn: anObject to: myBuilder instance
    ]

    translateFields: anOrderedCollection [
	<category: 'mapping'>
	fieldTranslation isNil ifTrue: [^anOrderedCollection].
	^anOrderedCollection 
	    collect: [:each | fieldTranslation sourceForTarget: each]
    ]
]



RelationshipMapping subclass: ToManyMapping [
    | orderBy shouldWriteTheOrderField collectionType |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    add: anObject to: aCollection [
	<category: 'mapping'>
	| newCollection |
	aCollection class == Array ifFalse: [^aCollection add: anObject].
	newCollection := aCollection , (Array with: anObject).
	self setValueIn: 3 to: newCollection
    ]

    add: anObject to: aCollection in: ourObject [
	"If this is an array we can't just add to it, we must concatenate and re-set the value"

	<category: 'mapping'>
	| newCollection |
	aCollection class == Array ifFalse: [^aCollection add: anObject].
	newCollection := aCollection , (Array with: anObject).
	self setValueIn: ourObject to: newCollection
    ]

    knit: ourObject to: anotherObject in: anObjectBuilder [
	"Set up the relationship from our object to another one, indicated by our mapping. If our instance ends up added to a collection, set the instance in the builder to be the collection so that it's the entire collection taht gets returned."

	<category: 'mapping'>
	| collection |
	collection := self getValueFrom: ourObject.
	(collection class == Proxy and: [collection isInstantiated not]) 
	    ifTrue: 
		[collection := self newCollection.
		self setValueIn: ourObject to: collection.
		self 
		    add: anotherObject
		    to: collection
		    in: ourObject.
		^self].
	(collection includes: anotherObject) 
	    ifFalse: 
		[self 
		    add: anotherObject
		    to: collection
		    in: ourObject]
    ]

    newCollection [
	<category: 'mapping'>
	^self collectionType new
    ]

    collectionType [
	<category: 'api'>
	collectionType isNil ifTrue: [collectionType := OrderedCollection].
	^collectionType
    ]

    collectionType: aClass [
	<category: 'api'>
	collectionType := aClass
    ]

    orderBy [
	<category: 'api'>
	^orderBy
    ]

    orderBy: aBlockOrSelector [
	<category: 'api'>
	orderBy isNil ifTrue: [orderBy := OrderedCollection new].
	orderBy add: aBlockOrSelector
    ]

    referencedIndependentObjectsFrom: anObject [
	<category: 'api'>
	| collection |
	collection := super referencedIndependentObjectsFrom: anObject.
	collection == nil ifTrue: [^#()].
	^Array with: collection
    ]

    shouldWriteTheOrderField [
	<category: 'api'>
	^shouldWriteTheOrderField
    ]

    shouldWriteTheOrderField: aBoolean [
	<category: 'api'>
	shouldWriteTheOrderField := aBoolean
    ]

    writeTheOrderField [
	<category: 'api'>
	shouldWriteTheOrderField := true
    ]

    orderField [
	<category: 'private/expressions'>
	^(orderBy first 
	    asGlorpExpressionOn: (BaseExpression new descriptor: self descriptor)) 
		field
    ]

    initialize [
	<category: 'initialize/release'>
	super initialize.
	shouldWriteTheOrderField := false
    ]

    isToManyRelationship [
	<category: 'testing'>
	^true
    ]
]



ToManyMapping subclass: OneToManyMapping [
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    OneToManyMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    buildQuery [
	<category: 'mapping'>
	query := Query returningManyOf: referenceClass where: mappingCriteria.
	orderBy isNil ifFalse: [orderBy do: [:each | query orderBy: each]].
	query collectionType: self collectionType.
	^query
    ]

    mapFromObject: anObject toTarget: aCollection puttingRowsIn: aRowMap [
	<category: 'mapping'>
	| index |
	aCollection isNil ifTrue: [^self].
	index := 1.
	aCollection do: 
		[:each | 
		(self isValidTarget: each) 
		    ifTrue: 
			[mappingCriteria 
			    mapFromSource: anObject
			    andTarget: each
			    intoRowsIn: aRowMap.
			shouldWriteTheOrderField 
			    ifTrue: 
				[FieldUnifier 
				    unifyFields: (Array with: (ConstantExpression new value: index)
					    with: self orderField)
				    correspondingTo: (Array with: each with: each)
				    in: aRowMap].
			index := index + 1]]
    ]
]



ToManyMapping subclass: ManyToManyMapping [
    | relevantLinkTableFields rowMapKeyConstructorBlock |
    
    <category: 'Glorp-Mappings'>
    <comment: nil>

    ManyToManyMapping class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    buildQuery [
	<category: 'mapping'>
	| criteria |
	criteria := mappingCriteria asGeneralGlorpExpression.
	query := Query returningManyOf: referenceClass where: criteria.
	query joins 
	    add: (self expressionFromLinkToReferenceTableWithBase: query baseExpression).
	orderBy isNil ifFalse: [orderBy do: [:each | query orderBy: each]].
	query collectionType: self collectionType.
	^query
    ]

    extendedMappingCriteria [
	"In order to do a many-to-many read we need more information than just the write, we need to know
	 the relationship to the other table. Construct that based on the table information"

	<category: 'mapping'>
	| generalMappingCriteria base |
	generalMappingCriteria := mappingCriteria asGeneralGlorpExpression.
	base := generalMappingCriteria ultimateBaseExpression.
	^generalMappingCriteria 
	    AND: (self expressionFromLinkToReferenceTableWithBase: base)
    ]

    mapFromObject: anObject toTarget: aCollection puttingRowsIn: aRowMap [
	<category: 'mapping'>
	| reverseMappingCriteria index |
	reverseMappingCriteria := self 
		    primaryKeyExpressionFromLinkToReferenceTable.	"This is interesting. We could test if we're writing the ordering into a field, and if we are assume this is sequenceable and iterate differently. But it actually seems easier to just use do: and maintain a separate index"
	index := 1.
	aCollection do: 
		[:each | 
		(self isValidTarget: each) 
		    ifTrue: 
			[| rowMapKey |
			rowMapKey := self rowMapKeyForSource: anObject target: each.
			mappingCriteria 
			    mapFromSource: anObject
			    andTarget: rowMapKey
			    intoRowsIn: aRowMap.
			reverseMappingCriteria 
			    mapFromSource: rowMapKey
			    andTarget: each
			    intoRowsIn: aRowMap.
			shouldWriteTheOrderField 
			    ifTrue: 
				[| keyForOrdering |
				keyForOrdering := self orderField table == self linkTable 
					    ifTrue: [rowMapKey]
					    ifFalse: [each].
				FieldUnifier 
				    unifyFields: (Array with: (ConstantExpression new value: index)
					    with: self orderField)
				    correspondingTo: (Array with: keyForOrdering with: keyForOrdering)
				    in: aRowMap].
			index := index + 1]]
    ]

    rowMapKeyForSource: each target: anObject [
	<category: 'mapping'>
	^rowMapKeyConstructorBlock isNil 
	    ifTrue: 
		[(RowMapKey new)
		    key1: anObject;
		    key2: each]
	    ifFalse: [rowMapKeyConstructorBlock value: each value: anObject]
    ]

    constraints [
	<category: 'private/expressions'>
	| referenceKeys linkTable referenceTables allConstraints relevantConstraints |
	referenceKeys := mappingCriteria targetKeys asOrderedCollection.
	linkTable := referenceKeys first table.
	"If we haven't been told the relevant link table fields, assume we can find them by looking at all the ones that aren't the ones from our source to the link, and all the rest will be from the link to the target"
	allConstraints := linkTable foreignKeyConstraints.
	relevantConstraints := relevantLinkTableFields isNil 
		    ifTrue: 
			[allConstraints reject: [:each | referenceKeys includes: each sourceField]]
		    ifFalse: 
			[allConstraints 
			    select: [:each | relevantLinkTableFields includes: each sourceField]].

	"Validate that we can handle this case"
	referenceTables := (relevantConstraints 
		    collect: [:each | each targetField table]) asSet.
	referenceTables size > 1 
	    ifTrue: [self error: 'Cannot handle this general a case'].
	referenceTables size = 0 
	    ifTrue: 
		[self 
		    error: 'No tables found. Did you set up foreign key references in the table definitions?'].
	^relevantConstraints
    ]

    expressionFromLinkToReferenceTableWithBase: base [
	"Unfortunately we can't just convert the primary key expression into our expression, because that would generate targets as parameters, and we want both to be fields"

	<category: 'private/expressions'>
	| expression |
	expression := nil.
	self constraints do: 
		[:each | 
		| src target |
		src := (base getTable: each sourceField table) getField: each sourceField.
		target := (base getTable: each targetField table) 
			    getField: each targetField.
		expression := expression isNil 
			    ifTrue: [src equals: target]
			    ifFalse: [expression AND: (src equals: target)]].
	^expression
    ]

    linkTable [
	<category: 'private/expressions'>
	| referenceKeys |
	referenceKeys := mappingCriteria targetKeys asOrderedCollection.
	^referenceKeys first table
    ]

    primaryKeyExpressionFromLinkToReferenceTable [
	"Generate the inverse mapping expression, i.e. the one connecting the link table to the reference table, using the foreign key constraints."

	<category: 'private/expressions'>
	| expression |
	expression := Join new.
	self constraints 
	    do: [:each | expression addSource: each sourceField target: each targetField].
	^expression
    ]

    constructRowMapKeyAs: aBlock [
	"Give us the opportunity to construct a custom row map key. This is useful if you need to force two relationships to share a link table entry"

	<category: 'api'>
	rowMapKeyConstructorBlock := aBlock
    ]

    relevantLinkTableFields: aCollection [
	<category: 'api'>
	relevantLinkTableFields := aCollection
    ]
]



SequenceableCollection extend [

    atIndex: anInteger [
	"For compatibility with Dolphin and VA data base rows."

	<category: 'accessing'>
	^self at: anInteger
    ]

]



Time extend [

    glorpPadToTwoDigits: anInteger [
	<category: 'printing'>
	| string |
	string := anInteger printString.
	^string size = 1 ifTrue: ['0' , string] ifFalse: [string]
    ]

    glorpPrintSQLOn: aStream [
	"Print as 24 hour time"

	<category: 'printing'>
	aStream
	    nextPut: $';
	    nextPutAll: (self glorpPadToTwoDigits: self hours);
	    nextPut: $:;
	    nextPutAll: (self glorpPadToTwoDigits: self minutes);
	    nextPut: $:;
	    nextPutAll: (self glorpPadToTwoDigits: self seconds);
	    nextPut: $'
    ]

]



UndefinedObject extend [

    glorpPrintSQLOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'NULL'
    ]

]



Date extend [

    glorpPrintSQLOn: aStream [
	"Print the date in ISO format. 'yyyy-mm-dd'  Don't rely on any dialect-specific formatting or padding mechanisms"

	<category: 'printing'>
	| monthString dayString |
	aStream
	    nextPut: $';
	    print: self year;
	    nextPut: $-.
	monthString := self monthIndex printString.
	monthString size = 1 ifTrue: [aStream nextPut: $0].
	aStream nextPutAll: monthString.
	aStream nextPut: $-.
	dayString := self dayOfMonth printString.
	dayString size = 1 ifTrue: [aStream nextPut: $0].
	aStream nextPutAll: dayString.
	aStream nextPut: $'
    ]

]



Object extend [

    asGlorpExpression [
	<category: 'glorp'>
	^Glorp.ConstantExpression for: self
    ]

    asGlorpExpressionOn: anExpression [
	<category: 'glorp'>
	^self asGlorpExpression
    ]

    glorpIsCollection [
	<category: 'glorp'>
	^false
    ]

    glorpPostFetch: aSession [
	<category: 'glorp'>
	
    ]

    glorpPostWrite: aSession [
	<category: 'glorp'>
	
    ]

    glorpPreWrite: aSession [
	<category: 'glorp'>
	
    ]

    glorpPrintSQLOn: aStream [
	<category: 'glorp'>
	self printOn: aStream
    ]

    isGlorpExpression [
	<category: 'glorp'>
	^false
    ]

    needsWork: aString [
	<category: 'glorp'>
	^self
    ]

    todo [
	"marker"

	<category: 'glorp'>
	
    ]

]



ByteArray extend [

    glorpIsCollection [
	"For our purposes, these aren't collections, but rather a simple database type"

	<category: 'testing'>
	^false
    ]

]



ReadStream extend [

    collect: aBlock [
	<category: 'Not categorized'>
	| newStream |
	newStream := WriteStream on: collection species new.
	[self atEnd] whileFalse: [newStream nextPut: (aBlock value: self next)].
	^newStream contents
    ]

]



String extend [

    glorpIsCollection [
	"For our purposes, these aren't collections, but rather a simple database type"

	<category: 'glorp'>
	^false
    ]

    glorpPrintSQLOn: aStream [
	<category: 'glorp'>
	| requireEscape |
	requireEscape := #($' $" $\).
	aStream nextPut: $'.
	1 to: self size
	    do: 
		[:i | 
		(requireEscape includes: (self at: i)) ifTrue: [aStream nextPut: $\].
		aStream nextPut: (self at: i)].
	aStream nextPut: $'
    ]

]



Collection extend [

    glorpIsCollection [
	<category: 'testing'>
	^true
    ]

    glorpPrintSQLOn: aStream [
	<category: 'glorp'>
	aStream nextPut: $(.
	Glorp.GlorpHelper 
	    do: [:each | each glorpPrintSQLOn: aStream]
	    for: self
	    separatedBy: [aStream nextPutAll: ', '].
	aStream nextPut: $)
    ]

    glorpPrintSQLOn: aStream for: aType [
	<category: 'glorp'>
	aStream nextPut: $(.
	Glorp.GlorpHelper 
	    do: [:each | aType print: each on: aStream]
	    for: self
	    separatedBy: [aStream nextPutAll: ', '].
	aStream nextPut: $)
    ]

    glorpRegisterCollectionInternalsIn: anObjectTransaction [
	"Explicitly register any internal structures (e.g. a VW identity dictionary's valueArray) with the transaction. Assume we can safely register everything inside the collection reflectively. The obvious exceptions would be dependents and sortblocks. This is a cheat, and for peculiar cases you'll need to override this in the subclass"

	<category: 'glorp'>
	| names |
	names := self class allInstVarNames.
	(1 to: names size) do: 
		[:index | 
		(#('dependents' 'sortBlock') includes: (names at: index)) 
		    ifFalse: [anObjectTransaction register: (self instVarAt: index)]]
    ]

]



Eval [
    Glorp.FunctionExpression initialize
]

