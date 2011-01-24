"======================================================================
|
|   Class Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005,2006,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



ClassDescription subclass: Class [
    | name comment category environment classVariables sharedPools securityPolicy pragmaHandlers |
    
    <category: 'Language-Implementation'>
    <comment: 'I am THE class object.  My instances are the classes of the system.
I provide information commonly attributed to classes: namely, the
class name, class comment (you wouldn''t be reading this if it
weren''t for me), a list of the instance variables of the class, and
the class category.'>

    Class class >> allPoolDictionaries: list except: inWhite do: aBlock [
        "Invoke aBlock with each of the result of combining the list
	 of pools using a topological sort, preferring dependent to
	 prerequisite, and then left to right.  Any pool that is
	 already in inWhite will not be answered."
        <category: 'private'>
        | white grey order descend |
	list isEmpty ifTrue: [ ^self ].

	white := inWhite copy.
        grey := IdentitySet new: list size.
        order := OrderedCollection new: list size.
        descend := [:pool |
            (white includes: pool) ifFalse:
                [(grey includes: pool) ifTrue:
                     [^SystemExceptions.InvalidValue
                          signalOn: list
                          reason: 'includes circular dependency'].

                "#allSuperspaces is not available on all pools"
                grey add: pool.
                pool allSuperspaces reverseDo: descend.
                order addFirst: pool.
                white add: pool]].
        list reverseDo: descend.
        order do: aBlock
    ]

    Class class >> initialize [
	"Perform the special initialization of root classes."

	<category: 'initialize'>
	self subclassesDo: [:each | each instanceClass initializeAsRootClass]
    ]

    name [
	"Answer the class name"

	<category: 'accessing instances and variables'>
	^name
    ]

    comment [
	"Answer the class comment"

	<category: 'accessing instances and variables'>
	^comment
    ]

    comment: aString [
	"Change the class name"

	<category: 'accessing instances and variables'>
	comment := aString
    ]

    environment [
	<category: 'accessing instances and variables'>
	^environment
    ]

    environment: aNamespace [
	"Set the receiver's environment to aNamespace and recompile everything"

	<category: 'accessing instances and variables'>
	environment := aNamespace.
	(self asClass)
	    compileAll;
	    compileAllSubclasses.
	(self asMetaclass)
	    compileAll;
	    compileAllSubclasses
    ]

    category [
	"Answer the class category"

	<category: 'accessing instances and variables'>
	^category
    ]

    category: aString [
	"Change the class category to aString"

	<category: 'accessing instances and variables'>
	category := aString
    ]

    superclass: aClass [
	"Set the receiver's superclass."
	<category: 'accessing instances and variables'>
	(aClass isNil and: [self superclass notNil]) 
	    ifTrue: [self initializeAsRootClass].
	super superclass: aClass
    ]

    addClassVarName: aString [
	"Add a class variable with the given name to the class pool dictionary."

	<category: 'accessing instances and variables'>
	| sym |
	sym := aString asClassPoolKey.
	(self classPool includesKey: sym) 
	    ifFalse: [self classPool at: sym put: nil].
	^self classPool associationAt: sym
    ]

    addClassVarName: aString value: valueBlock [
	"Add a class variable with the given name to the class pool dictionary,
	 and evaluate valueBlock as its initializer."

	<category: 'accessing instances and variables'>
	^(self addClassVarName: aString)
	    value: valueBlock value;
	    yourself
    ]

    bindingFor: aString [
	"Answer the variable binding for the class variable with the
	 given name"

	<category: 'accessing instances and variables'>
	| sym |
	sym := aString asClassPoolKey.
	^self classPool associationAt: sym
    ]

    removeClassVarName: aString [
	"Removes the class variable from the class, error if not present, or
	 still in use."

	<category: 'accessing instances and variables'>
	| sym |
	sym := aString asClassPoolKey.
	(classVariables notNil and: [classVariables includesKey: sym]) 
	    ifFalse: [SystemExceptions.NotFound signalOn: aString what: 'class variable'].
	classVariables removeKey: sym.
	(self asClass)
	    compileAll;
	    compileAllSubclasses.
	(self asMetaclass)
	    compileAll;
	    compileAllSubclasses
    ]

    classPool [
	"Answer the class pool dictionary"

	<category: 'accessing instances and variables'>
	classVariables isNil 
	    ifTrue: [classVariables := BindingDictionary new environment: self].
	^classVariables
    ]

    classVarNames [
	"Answer the names of the variables in the class pool dictionary"

	<category: 'accessing instances and variables'>
	^classVariables notNil ifTrue: [classVariables keys] ifFalse: [Set new]
    ]

    allClassVarNames [
	"Answer the names of the variables in the receiver's class pool dictionary
	 and in each of the superclasses' class pool dictionaries"

	<category: 'accessing instances and variables'>
	| superVarNames |
	superVarNames := self classVarNames.
	self allSuperclasses 
	    do: [:each | superVarNames addAll: each classVarNames].
	^superVarNames
    ]

    addSharedPool: aDictionary [
	"Add the given shared pool to the list of the class' pool dictionaries"

	<category: 'accessing instances and variables'>
	sharedPools ifNil: [sharedPools := #()].
	(sharedPools includes: aDictionary) 
	    ifFalse: [sharedPools := sharedPools copyWith: aDictionary]
    ]

    removeSharedPool: aDictionary [
	"Remove the given dictionary to the list of the class' pool dictionaries"

	<category: 'accessing instances and variables'>
	sharedPools ifNil: [sharedPools := #()].
	sharedPools := sharedPools copyWithout: aDictionary
    ]

    sharedPools [
	"Return the names of the shared pools defined by the class"

	<category: 'accessing instances and variables'>
	| s |
	s := Set new.
	(sharedPools notNil and: [sharedPools notEmpty])
	    ifTrue: 
		[self environment associationsDo: 
			[:each | 
			(sharedPools identityIncludes: each value) ifTrue: [s add: each key]]].
	^s
    ]

    classPragmas [
	"Return the pragmas that are written in the file-out of this class."

	<category: 'accessing instances and variables'>
	^#(#category #comment)
    ]

    initializeAsRootClass [
	"Perform special initialization reserved to root classes."

	<category: 'accessing instances and variables'>
	self 
	    registerHandler: [:method :ann | method rewriteAsCCall: (ann arguments at: 1) for: self]
	    forPragma: #cCall:.
	self registerHandler: 
		[:method :ann | 
		method 
		    rewriteAsCCall: (ann arguments at: 1)
		    returning: (ann arguments at: 2)
		    args: (ann arguments at: 3)]
	    forPragma: #cCall:returning:args:.
	self registerHandler: 
		[:method :ann | 
		method rewriteAsAsyncCCall: (ann arguments at: 1)
		    args: (ann arguments at: 2)]
	    forPragma: #asyncCCall:args:
    ]

    initialize [
	"redefined in children (?)"

	<category: 'accessing instances and variables'>
	^self
    ]

    = aClass [
	"Returns true if the two class objects are to be considered equal."

	"^(aClass isKindOf: Class) and: [name = aClass name]"

	<category: 'testing'>
	^self == aClass
    ]

    categoriesFor: method are: categories [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	self >> method methodCategory: (categories at: 1)
    ]

    subclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^self 
	    subclass: classNameString
	    instanceVariableNames: stringInstVarNames
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category'
    ]

    subclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^(self 
	    subclass: classNameString
	    instanceVariableNames: stringInstVarNames
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category')
	    classInstanceVariableNames: stringClassInstVarNames;
	    yourself
    ]

    variableSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^self 
	    variableSubclass: classNameString
	    instanceVariableNames: stringInstVarNames
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category'
    ]

    variableSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^(self 
	    variableSubclass: classNameString
	    instanceVariableNames: stringInstVarNames
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category')
	    classInstanceVariableNames: stringClassInstVarNames;
	    yourself
    ]

    variableByteSubclass: classNameString classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^self 
	    variableByteSubclass: classNameString
	    instanceVariableNames: ''
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category'
    ]

    variableByteSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^(self 
	    variableByteSubclass: classNameString
	    instanceVariableNames: ''
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category')
	    classInstanceVariableNames: stringClassInstVarNames;
	    yourself
    ]

    variableLongSubclass: classNameString classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^self 
	    variable: #uint
	    subclass: classNameString
	    instanceVariableNames: ''
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category'
    ]

    variableLongSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames [
	"Don't use this, it is only present to file in from IBM Smalltalk"

	<category: 'instance creation - alternative'>
	^(self 
	    variable: #uint
	    subclass: classNameString
	    instanceVariableNames: ''
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: 'no category')
	    classInstanceVariableNames: stringClassInstVarNames;
	    yourself
    ]

    extend [
	"Redefine a version of the receiver in the current namespace.  Note:
	 this method can bite you in various ways when sent to system classes;
	 read the section on namespaces in the manual for some examples of the
	 problems you can encounter."

	<category: 'instance creation'>
	| method |
	method := self kindOfSubclass 
		    , 'instanceVariableNames:classVariableNames:poolDictionaries:category:'.
	^self perform: method asSymbol
	    withArguments: 
		{self name asSymbol.
		''.
		''.
		''.
		'Extensions'}
    ]

    inheritShape [
	"Answer whether subclasses will have by default the same shape as
	 this class.  The default is false."
	<category: 'instance creation'>
	^false
    ]

    subclass: classNameString environment: aNamespace[
	"Define a subclass of the receiver with the given name within
	 aNamespace.  If the class is already defined, don't modify its
	 instance or class variables but still, if necessary, recompile
	 everything needed."

	<category: 'instance creation'>
	| meta |
	KernelInitialized ifFalse: [^aNamespace at: classNameString].
	meta := self metaclassFor: classNameString.
	^meta 
	    name: classNameString
	    environment: aNamespace
	    subclassOf: self
    ]

    subclass: classNameString [
	"Define a subclass of the receiver with the given name.  If the class
	 is already defined, don't modify its instance or class variables
	 but still, if necessary, recompile everything needed."

	<category: 'instance creation'>
        ^self subclass: classNameString environment: Namespace current
    ]
    
    subclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames category: categoryNameString [
	"Define a fixed subclass of the receiver with the given name, instance
	 variables, class variables, pool dictionaries and category. If the
	 class is already defined, if necessary, recompile everything needed."

	<category: 'instance creation'>
	| meta |
	KernelInitialized 
	    ifFalse: [^(Smalltalk at: classNameString) category: categoryNameString].
	meta := self metaclassFor: classNameString.
	^meta 
	    name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: (self inheritShape ifTrue: [ #inherit ])
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
    ]

    variableSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames category: categoryNameString [
	"Define a variable pointer subclass of the receiver with the given
	 name, instance variables, class variables, pool dictionaries and
	 category. If the class is already defined, if necessary, recompile
	 everything needed."

	<category: 'instance creation'>
	| meta |
	KernelInitialized 
	    ifFalse: [^(Smalltalk at: classNameString) category: categoryNameString].
	meta := self metaclassFor: classNameString.
	^meta 
	    name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: #pointer
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
    ]

    variable: shape subclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames category: categoryNameString [
	"Define a variable subclass of the receiver with the given name,
	 shape, instance variables, class variables, pool dictionaries and
	 category. If the class is already defined, if necessary, recompile
	 everything needed.  The shape can be one of #byte #int8 #character
	 #short #ushort #int #uint #int64 #uint64 #utf32 #float #double or
	 #pointer."

	<category: 'instance creation'>
	| meta |
	KernelInitialized 
	    ifFalse: [^(Smalltalk at: classNameString) category: categoryNameString].
	meta := self metaclassFor: classNameString.
	^meta 
	    name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: shape
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
    ]

    variableWordSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames category: categoryNameString [
	"Define a word variable subclass of the receiver with the given
	 name, instance variables (must be ''), class variables, pool
	 dictionaries and category. If the class is already defined, if
	 necessary, recompile everything needed."

	<category: 'instance creation'>
	| meta |
	KernelInitialized 
	    ifFalse: [^(Smalltalk at: classNameString) category: categoryNameString].
	meta := self metaclassFor: classNameString.
	^meta 
	    name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: #word
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
    ]

    variableByteSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames category: categoryNameString [
	"Define a byte variable subclass of the receiver with the given
	 name, instance variables (must be ''), class variables, pool
	 dictionaries and category. If the class is already defined, if
	 necessary, recompile everything needed."

	<category: 'instance creation'>
	| meta |
	KernelInitialized 
	    ifFalse: [^(Smalltalk at: classNameString) category: categoryNameString].
	meta := self metaclassFor: classNameString.
	^meta 
	    name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: #byte
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
    ]

    article [
	"Answer an article (`a' or `an') which is ok for the receiver's name"

	<category: 'printing'>
	| name |
	name := self name.
	^(name at: 1) isVowel ifTrue: ['an'] ifFalse: ['a']
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream nextPutAll: (self nameIn: Smalltalk)
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'printing'>
	aStream nextPutAll: (self nameIn: Smalltalk)
    ]

    securityPolicy [
	<category: 'security'>
	^securityPolicy
    ]

    securityPolicy: aSecurityPolicy [
	<category: 'security'>
	securityPolicy := aSecurityPolicy withOwner: self
    ]

    check: aPermission [
	<category: 'security'>
	self securityPolicy isNil ifTrue: [^self isUntrusted not].
	^self securityPolicy check: aPermission
    ]

    registerHandler: aBlock forPragma: pragma [
	"While compiling methods, on every encounter of the pragma
	 with the given name, call aBlock with the CompiledMethod and
	 an array of pragma argument values."
	<category: 'pragmas'>
	pragmaHandlers isNil ifTrue: [pragmaHandlers := IdentityDictionary new].
	pragmaHandlers at: pragma put: aBlock
    ]

    pragmaHandlerFor: aSymbol [
	"Answer the (possibly inherited) registered handler for pragma
	 aSymbol, or nil if not found."
	<category: 'pragmas'>
	| handler |
	pragmaHandlers isNil 
	    ifFalse: 
		[handler := pragmaHandlers at: aSymbol ifAbsent: [nil].
		handler isNil ifFalse: [^handler]].
	self superclass isNil 
	    ifFalse: [^self superclass pragmaHandlerFor: aSymbol].
	^nil
    ]

    classInstanceVariableNames: stringClassInstVarNames [
	<category: 'private'>
	self class instanceVariableNames: stringClassInstVarNames
    ]

    setClassVariables: aDictionary [
	<category: 'private'>
	classVariables := aDictionary
    ]

    setName: aString [
	<category: 'private'>
	name := aString
    ]

    setEnvironment: aNamespace [
	<category: 'private'>
	environment := aNamespace
    ]

    setSharedPools: anArray [
	"Private - Set the receiver's shared pools to be those in anArray"

	<category: 'private'>
	sharedPools := anArray ifNil: [#()]
    ]

    sharedPoolDictionaries [
	"Return the shared pools (not the names!) defined by the class"

	<category: 'private'>
	^sharedPools ifNil: [#()]
    ]

    allSharedPoolDictionariesDo: aBlock [
        "Answer the shared pools visible from methods in the metaclass,
         in the correct search order."

        self allSharedPoolDictionariesDo: aBlock overrideEnvironment: nil
    ]

    allSharedPoolDictionariesDo: aBlock overrideEnvironment: aNamespace [
        "Answer the shared pools visible from methods in the class,
         in the correct search order.  The receiver's environment is
         temporarily replaced with aNamespace"

        | superclassSpaces env |
        env := aNamespace.
        self withAllSuperclassesDo: [:behavior || classSpaces |
	    aBlock value: behavior classPool.

	    "Extract the spaces of this class from superclassSpaces into
	     classSpaces..."
            superclassSpaces isNil
		ifTrue: [classSpaces := IdentitySet new.
                         (env ifNil: [behavior environment])
                             withAllSuperspacesDo: [:each | classSpaces add: each]]
		ifFalse: [classSpaces := superclassSpaces].

	    "... and visit them."
            behavior
                allLocalSharedPoolDictionariesExcept: classSpaces
                do: aBlock.

	    "Collect those spaces that have to be skipped in the search."
	    superclassSpaces := IdentitySet new.
	    behavior superclass ifNotNil: [:superclass |
		superclass environment withAllSuperspacesDo: [ :each |
		    superclassSpaces add: each ]].

	    "Now proceed with the `natural' (non-imported spaces)."
            behavior environment withAllSuperspacesDo: [:each |
                (superclassSpaces includes: each) ifFalse:
		    [aBlock value: each.
		     "also visit the namespace shared pools"
		     Class allPoolDictionaries: each sharedPoolDictionaries
			   except: classSpaces
			   do: aBlock]].

            env := nil]
    ]

    allLocalSharedPoolDictionariesExcept: inWhite do: aBlock [
        "Answer the result of combining the list of pools imported
	 into the receiver using a topological sort, preferring dependent
	 to prerequisite, and then left to right.  Any pool that is
	 already in inWhite will not be answered."
        <category: 'private'>
	Class allPoolDictionaries: self sharedPoolDictionaries
	      except: inWhite do: aBlock
    ]

    metaclassFor: classNameString [
	"Create a Metaclass object for the given class name. The metaclass
	 is a subclass of the receiver's metaclass"

	<category: 'private'>
	| className class |
	className := classNameString asGlobalKey.
	class := Namespace current hereAt: className ifAbsent: [nil].
        class isNamespace ifTrue: [ self error: 'Class name %1 conflicts with the name of its namespace' % {classNameString asString} ].
	^(class isNil or: [class isClass not]) 
	    ifTrue: [Metaclass subclassOf: self class]
	    ifFalse: [class class]
    ]

    asClass [
	<category: 'testing functionality'>
	^self
    ]

    isClass [
	<category: 'testing functionality'>
	^true
    ]

    fileOutDeclarationOn: aFileStream [
	"File out class definition to aFileStream.  Requires package Parser."

	<category: 'filing'>
	self notYetImplemented
    ]

    fileOutOn: aFileStream [
	"File out complete class description:  class definition, class and
	 instance methods.  Requires package Parser."

	<category: 'filing'>
	self notYetImplemented
    ]

    binaryRepresentationVersion [
	"Answer a number >= 0 which represents the current version of the
	 object's representation.  The default implementation answers
	 zero."

	<category: 'saving and loading'>
	^0
    ]

    nonVersionedInstSize [
	"Answer the number of instance variables that the class used to have
	 when objects were stored without using a VersionableObjectProxy.
	 The default implementation answers the current instSize."

	<category: 'saving and loading'>
	^self instSize
    ]

    convertFromVersion: version withFixedVariables: fixed indexedVariables: indexed for: anObjectDumper [
	"This method is called if a VersionableObjectProxy is attached to
	 a class.  It receives the version number that was stored for the
	 object (or nil if the object did not use a VersionableObjectProxy),
	 the fixed instance variables, the indexed instance variables,
	 and the ObjectDumper that has read the object.
	 The default implementation ignores the version and simply fills
	 in an instance of the receiver with the given fixed and indexed
	 instance variables (nil if the class instances are of fixed size).
	 If instance variables were removed from the class, extras are
	 ignored; if the class is now fixed and used to be indexed,
	 indexed is not used."

	<category: 'saving and loading'>
	| object |
	object := self isFixed 
		    ifTrue: [self basicNew]
		    ifFalse: [self basicNew: indexed size].
	fixed 
	    from: 1
	    to: (fixed size min: self instSize)
	    keysAndValuesDo: [:i :obj | object instVarAt: i put: obj].
	(self isFixed or: [indexed isNil]) ifTrue: [^object].
	indexed keysAndValuesDo: [:i :obj | object basicAt: i put: obj].
	^object
    ]
]

