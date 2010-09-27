"======================================================================
|
|   Metaclass Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Steve Byrne, Brad Diller and Paolo Bonzini.
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



ClassDescription subclass: Metaclass [
    | instanceClass |
    
    <category: 'Language-Implementation'>
    <comment: 'I am the root of the class hierarchy.  My instances are metaclasses, one for
each real class.  My instances have a single instance, which they hold
onto, which is the class that they are the metaclass of.  I provide methods
for creation of actual class objects from metaclass object, and the creation
of metaclass objects, which are my instances.  If this is confusing to you,
it should be...the Smalltalk metaclass system is strange and complex.'>

    Metaclass class >> subclassOf: superMeta [
	"Answer a new metaclass representing a subclass of superMeta"

	<category: 'instance creation'>
	| newMeta |
	newMeta := self new.
	newMeta superclass: superMeta.
	superMeta addSubclass: newMeta.
	newMeta initMetaclass: superMeta.
	^newMeta
    ]

    addClassVarName: aString [
	"Add a class variable with the given name to the class pool dictionary"

	<category: 'delegation'>
	^self instanceClass addClassVarName: aString
    ]

    removeClassVarName: aString [
	"Removes the class variable from the class, error if not present, or
	 still in use."

	<category: 'delegation'>
	^self instanceClass removeClassVarName: aString
    ]

    name [
	"Answer the class name - it has none, actually"

	<category: 'delegation'>
	^nil
    ]

    allSharedPoolDictionariesDo: aBlock [
	"Answer the shared pools visible from methods in the metaclass,
	 in the correct search order."

	<category: 'delegation'>
	self asClass allSharedPoolDictionariesDo: aBlock
    ]

    category [
	"Answer the class category"

	<category: 'delegation'>
	^self asClass category
    ]

    comment [
	"Answer the class comment"

	<category: 'delegation'>
	^self asClass comment
    ]

    environment [
	"Answer the namespace in which the receiver is implemented"

	<category: 'delegation'>
	^self asClass environment
    ]

    classPool [
	"Answer the class pool dictionary"

	<category: 'delegation'>
	^self instanceClass classPool
    ]

    classVarNames [
	"Answer the names of the variables in the class pool dictionary"

	<category: 'delegation'>
	^self instanceClass classVarNames
    ]

    debuggerClass [
	"Answer the debugger class that was set in the instance class"

	<category: 'delegation'>
	^self instanceClass debuggerClass
    ]

    allClassVarNames [
	"Answer the names of the variables in the receiver's class pool dictionary
	 and in each of the superclasses' class pool dictionaries"

	<category: 'delegation'>
	^self instanceClass allClassVarNames
    ]

    addSharedPool: aDictionary [
	"Add the given shared pool to the list of the class' pool dictionaries"

	<category: 'delegation'>
	^self instanceClass addSharedPool: aDictionary
    ]

    removeSharedPool: aDictionary [
	"Remove the given dictionary to the list of the class' pool dictionaries"

	<category: 'delegation'>
	^self instanceClass removeSharedPool: aDictionary
    ]

    sharedPools [
	"Return the names of the shared pools defined by the class"

	<category: 'delegation'>
	^self instanceClass sharedPools
    ]

    allSharedPools [
	"Return the names of the shared pools defined by the class and any of
	 its superclasses"

	<category: 'delegation'>
	^self instanceClass allSharedPools
    ]

    pragmaHandlerFor: aSymbol [
	"Answer the (possibly inherited) registered handler for pragma
	 aSymbol, or nil if not found."
	<category: 'delegation'>
	^self instanceClass pragmaHandlerFor: aSymbol
    ]

    name: className environment: aNamespace subclassOf: theSuperclass [
	"Private - create a full featured class and install it, or change the
	 superclass or shape of an existing one; instance variable names,
	 class variable names and pool dictionaries are left untouched."

	<category: 'basic'>
	| aClass variableArray inheritedShape |
	variableArray := theSuperclass notNil 
		    ifTrue: [theSuperclass allInstVarNames]
		    ifFalse: [#()].

	"Look for an existing metaclass"
	aClass := aNamespace hereAt: className ifAbsent: [nil].
	aClass isNil 
	    ifTrue: 
		[^self 
		    newMeta: className
		    environment: aNamespace
		    subclassOf: theSuperclass
		    instanceVariableArray: variableArray
		    shape: (theSuperclass isNil
				ifTrue: [ nil ]
				ifFalse: [ theSuperclass inheritShape ifTrue: [ #inherit ] ])
		    classPool: BindingDictionary new
		    poolDictionaries: #()
		    category: nil].
	variableArray := variableArray , aClass instVarNames.
	^self 
	    name: className
	    environment: aNamespace
	    subclassOf: theSuperclass
	    instanceVariableArray: variableArray
	    shape: aClass shape
	    classPool: aClass classPool
	    poolDictionaries: aClass sharedPoolDictionaries
	    category: aClass category
    ]

    name: newName environment: aNamespace subclassOf: theSuperclass instanceVariableNames: stringOfInstVarNames shape: shape classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames category: categoryName [
	"Private - parse the instance and class variables, and the pool
	 dictionaries, then create the class."

	<category: 'basic'>
	"Inherit instance variables from parent"

	| variableArray classVarDict sharedPoolNames |
	variableArray := self parseInstanceVariableString: stringOfInstVarNames.
	variableArray := theSuperclass notNil 
		    ifTrue: [theSuperclass allInstVarNames , variableArray]
		    ifFalse: [variableArray].
	classVarDict := self parse: stringOfClassVarNames
		    toDictionary: BindingDictionary new.
	sharedPoolNames := self parsePools: stringOfPoolNames in: aNamespace.
	^self 
	    name: newName asSymbol
	    environment: aNamespace
	    subclassOf: theSuperclass
	    instanceVariableArray: variableArray
	    shape: shape
	    classPool: classVarDict
	    poolDictionaries: sharedPoolNames
	    category: categoryName
    ]

    name: className environment: aNamespace subclassOf: newSuperclass instanceVariableArray: variableArray shape: shape classPool: classVarDict poolDictionaries: sharedPoolNames category: categoryName [
	"Private - create a full featured class and install it, or change an
	 existing one"

	<category: 'basic'>
	| aClass realShape needToRecompileMetaclasses needToRecompileClasses |
	realShape := shape == #word 
		    ifTrue: [CSymbols.CLongSize = 4 ifTrue: [#uint] ifFalse: [#uint64]]
		    ifFalse: [shape].

	"Look for an existing metaclass"
	aClass := aNamespace hereAt: className ifAbsent: [nil].
	aClass isNil 
	    ifTrue: 
		[^self 
		    newMeta: className
		    environment: aNamespace
		    subclassOf: newSuperclass
		    instanceVariableArray: variableArray
		    shape: realShape
		    classPool: classVarDict
		    poolDictionaries: sharedPoolNames
		    category: categoryName].
	aClass isVariable & realShape notNil 
	    ifTrue: 
		[aClass shape == realShape 
		    ifFalse: 
			[SystemExceptions.MutationError 
			    signal: 'Cannot change shape of variable class']].
	newSuperclass isUntrusted & self class isUntrusted not 
	    ifTrue: 
		[SystemExceptions.MutationError 
		    signal: 'Cannot move trusted class below untrusted superclass'].
	needToRecompileMetaclasses := false.
	aClass classPool isNil 
	    ifTrue: [aClass setClassVariables: classVarDict]
	    ifFalse: 
		[classVarDict keysDo: 
			[:key | 
			(aClass classPool includesKey: key) ifFalse: [aClass addClassVarName: key]].
		aClass classPool keys do: 
			[:aKey | 
			(classVarDict includesKey: aKey) 
			    ifFalse: 
				[aClass removeClassVarName: aKey.
				needToRecompileMetaclasses := true]]].

	"If instance or indexed variables change, update
	 instance variables and instance spec of the class and all its subclasses"
	(needToRecompileClasses := variableArray ~= aClass allInstVarNames 
		    | needToRecompileMetaclasses) | (aClass shape ~~ realShape) 
	    ifTrue: 
		[aClass instanceCount > 0 ifTrue: [ObjectMemory globalGarbageCollect].
		aClass
		    updateInstanceVars: variableArray
		    superclass: newSuperclass
		    shape: realShape].

	"Now add/remove pool dictionaries.  FIXME: They may affect name binding,
	 so we should probably recompile everything if they change."
	aClass sharedPoolDictionaries isEmpty
	    ifTrue: [aClass setSharedPools: sharedPoolNames]
	    ifFalse: 
		[sharedPoolNames do: 
			[:dict | 
			(aClass sharedPoolDictionaries includes: dict) 
			    ifFalse: [aClass addSharedPool: dict]].
		aClass sharedPoolDictionaries copy do: 
			[:dict | 
			(sharedPoolNames includes: dict) 
			    ifFalse: 
				[aClass removeSharedPool: dict.
				needToRecompileMetaclasses := true]]].
	aClass superclass ~~ newSuperclass 
	    ifTrue: 
		["Mutate the class if the set of class-instance variables changes."

		self superclass allInstVarNames ~= newSuperclass class allInstVarNames 
		    ifTrue: 
			[aClass class
			    updateInstanceVars:
				newSuperclass class allInstVarNames,
				aClass class instVarNames
			    superclass: newSuperclass class
			    shape: aClass class shape].

		"Fix references between classes..."
		aClass superclass removeSubclass: aClass.
		newSuperclass addSubclass: aClass.
		aClass superclass: newSuperclass.
		needToRecompileClasses := true.

		"...and between metaclasses..."
		self superclass removeSubclass: self.
		newSuperclass class addSubclass: self.
		self superclass: newSuperclass class.
		needToRecompileMetaclasses := true].
	aClass category: categoryName.

	"Please note that I need to recompile the classes in this sequence;
	 otherwise, the same error is propagated to each selector which is compiled
	 after an error is detected even though there are no further compilation
	 errors. Apparently, there is a bug in the primitive #primCompile:.  This
	 can be cleaned up later"
	needToRecompileClasses | needToRecompileMetaclasses 
	    ifTrue: 
		[aClass compileAll.
		needToRecompileMetaclasses ifTrue: [aClass class compileAll].
		aClass compileAllSubclasses.
		needToRecompileMetaclasses ifTrue: [aClass class compileAllSubclasses]].
	Behavior flushCache.
	^aClass
    ]

    newMeta: className environment: aNamespace subclassOf: theSuperclass instanceVariableArray: arrayOfInstVarNames shape: shape classPool: classVarDict poolDictionaries: sharedPoolNames category: categoryName [
	"Private - create a full featured class and install it"

	<category: 'basic'>
	| aClass |
	aClass := self new.
	classVarDict environment: aClass.
	instanceClass := aClass.
	aNamespace at: className put: aClass.
	theSuperclass isNil ifFalse: [theSuperclass addSubclass: aClass].
	Behavior flushCache.
	^aClass
	    superclass: theSuperclass;
	    setName: className;
	    setEnvironment: aNamespace;
	    setInstanceVariables: arrayOfInstVarNames;
	    setInstanceSpec: shape instVars: arrayOfInstVarNames size;
	    setClassVariables: classVarDict;
	    setSharedPools: sharedPoolNames;
	    makeUntrusted: theSuperclass isUntrusted;
	    category: categoryName;
	    yourself
    ]

    primaryInstance [
	"Answer the only instance of the metaclass - present for compatibility"

	<category: 'accessing'>
	^instanceClass
    ]

    soleInstance [
	"Answer the only instance of the metaclass - present for compatibility"

	<category: 'accessing'>
	^instanceClass
    ]

    instanceClass [
	"Answer the only instance of the metaclass"

	<category: 'accessing'>
	^instanceClass
    ]

    nameIn: aNamespace [
	"Answer the class name when the class is referenced from aNamespace."

	<category: 'printing'>
	^self instanceClass nameIn: aNamespace
    ]

    printOn: aStream in: aNamespace [
	"Print on aStream the class name when the class is referenced from
	 aNamespace."

	<category: 'printing'>
	instanceClass printOn: aStream in: aNamespace.
	aStream nextPutAll: ' class'
    ]

    printOn: aStream [
	"Print a represention of the receiver on aStream"

	<category: 'printing'>
	instanceClass printOn: aStream.
	aStream nextPutAll: ' class'
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'printing'>
	instanceClass storeOn: aStream.
	aStream nextPutAll: ' class'
    ]

    initMetaclass: theSuperclass [
	<category: 'private'>
	instanceVariables := theSuperclass allInstVarNames.
	instanceSpec := theSuperclass instanceSpec
    ]

    parsePools: aString in: aNamespace [
	<category: 'private'>
	| tokens |
	tokens := aString subStrings asArray.
	^tokens collect: 
		[:poolName | 
		(poolName substrings: $.) inject: aNamespace
		    into: 
			[:namespace :key | 
			self validateIdentifier: key.
			namespace at: key asGlobalKey
			    ifAbsent: [SystemExceptions.NotFound signalOn: poolName what: 'pool']]]
    ]

    parse: aString toDictionary: dict [
	<category: 'private'>
	| tokenArray |
	tokenArray := self parseVariableString: aString.
	tokenArray do: [:element | dict at: element asSymbol put: nil].
	^dict
    ]

    growClassInstance [
	<category: 'private'>
	| newClass numInstVars |
	newClass := self new.
	numInstVars := self instSize.
	1 to: numInstVars - 1
	    do: [:i | newClass instVarAt: i put: (instanceClass instVarAt: i)].
	instanceClass become: newClass
    ]

    asClass [
	<category: 'testing functionality'>
	^instanceClass
    ]

    isMetaclass [
	<category: 'testing functionality'>
	^true
    ]

    fileOutOn: aFileStream [
	"File out complete class description:  class definition, class and
	 instance methods"

	<category: 'filing'>
	instanceClass fileOutOn: aFileStream
    ]
]

