"======================================================================
|
|   Metaclass Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005
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


ClassDescription subclass: #Metaclass
		 instanceVariableNames: 'instanceClass'
		 classVariableNames: ''
		 poolDictionaries: ''
		 category: 'Language-Implementation'
!

Metaclass comment: 
'I am the root of the class hierarchy.  My instances are metaclasses, one for
each real class.  My instances have a single instance, which they hold
onto, which is the class that they are the metaclass of.  I provide methods
for creation of actual class objects from metaclass object, and the creation
of metaclass objects, which are my instances.  If this is confusing to you,
it should be...the Smalltalk metaclass system is strange and complex.' !


!Metaclass class methodsFor: 'instance creation'!

subclassOf: superMeta
    "Answer a new metaclass representing a subclass of superMeta"

    | newMeta |
    newMeta := self new.
    newMeta superclass: superMeta.
    superMeta addSubclass: newMeta.
    newMeta initMetaclass: superMeta.
    ^newMeta
! !



!Metaclass methodsFor: 'delegation'!

addClassVarName: aString
    "Add a class variable with the given name to the class pool dictionary"
    
    ^self instanceClass addClassVarName: aString
!

removeClassVarName: aString
    "Removes the class variable from the class, error if not present, or
     still in use."

    ^self instanceClass removeClassVarName: aString
!

name
    "Answer the class name - it has none, actually"
    ^nil
!

category
    "Answer the class category"
    ^self asClass category
!

comment
    "Answer the class comment"
    ^self asClass comment
!

environment
    "Answer the namespace in which the receiver is implemented"
    ^self asClass environment
!

classPool
    "Answer the class pool dictionary"

    ^self instanceClass classPool
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"

    ^self instanceClass classVarNames
!

debuggerClass
    "Answer the debugger class that was set in the instance class"

    ^self instanceClass debuggerClass
!

allClassVarNames
    "Answer the names of the variables in the receiver's class pool dictionary
     and in each of the superclasses' class pool dictionaries"

    ^self instanceClass allClassVarNames
!

addSharedPool: aDictionary
    "Add the given shared pool to the list of the class' pool dictionaries"

    ^self instanceClass addSharedPool: aDictionary
!

removeSharedPool: aDictionary
    "Remove the given dictionary to the list of the class' pool dictionaries"

    ^self instanceClass removeSharedPool: aDictionary
!

sharedPools
    "Return the names of the shared pools defined by the class"

    ^self instanceClass sharedPools
!

allSharedPools
    "Return the names of the shared pools defined by the class and any of
     its superclasses"

    ^self instanceClass allSharedPools
!

pragmaHandlerFor: aSymbol
    ^self instanceClass pragmaHandlerFor: aSymbol
! !


!Metaclass methodsFor: 'basic'!

name: className
    environment: aNamespace
    subclassOf: superclass

    "Private - create a full featured class and install it, or change the
     superclass or shape of an existing one; instance variable names,
     class variable names and pool dictionaries are left untouched."

    | aClass |

    "Look for an existing metaclass"
    aClass := aNamespace hereAt: className ifAbsent: [ nil ].
    aClass isNil ifTrue: [
	^self newMeta: className
	    environment: aNamespace
	    subclassOf: superclass
	    instanceVariableArray: superclass allInstVarNames
	    shape: nil
	    classPool: BindingDictionary new
	    poolDictionaries: #()
	    category: nil
    ].

    ^self name: className
	environment: aNamespace
	subclassOf: superclass
	instanceVariableArray: superclass allInstVarNames, aClass instVarNames
	shape: aClass shape
	classPool: aClass classPool
	poolDictionaries: aClass sharedPoolDictionaries
	category: aClass category
!

name: newName
    environment: aNamespace
    subclassOf: superclass
    instanceVariableNames: stringOfInstVarNames
    shape: shape
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryName

    "Private - parse the instance and class variables, and the pool
     dictionaries, then create the class."

    | variableArray classVarDict sharedPoolNames |

    "Inherit instance variables from parent"
    variableArray := self parseInstanceVariableString: stringOfInstVarNames.
    variableArray := superclass notNil 
	ifTrue: [ superclass allInstVarNames, variableArray ]
	ifFalse: [ variableArray ].

    classVarDict := self
	parse: stringOfClassVarNames
	toDictionary: (BindingDictionary new).

    sharedPoolNames := self
	parsePools: stringOfPoolNames
	in: aNamespace.

    ^self
	name: newName asSymbol
	environment: aNamespace
	subclassOf: superclass
	instanceVariableArray: variableArray
	shape: shape
	classPool: classVarDict
	poolDictionaries: sharedPoolNames
	category: categoryName
!

name: className
    environment: aNamespace
    subclassOf: superclass
    instanceVariableArray: variableArray
    shape: shape
    classPool: classVarDict
    poolDictionaries: sharedPoolNames
    category: categoryName

    "Private - create a full featured class and install it, or change an
     existing one"

    | aClass realShape needToRecompileMetaclasses needToRecompileClasses |
    realShape := shape == #word
        ifTrue: [ CSymbols.CLongSize = 4 ifTrue: [ #uint ] ifFalse: [ #uint64 ] ]
        ifFalse: [ shape ].

    "Look for an existing metaclass"
    aClass := aNamespace hereAt: className ifAbsent: [ nil ].
    aClass isNil ifTrue: [
	^self newMeta: className
	    environment: aNamespace
	    subclassOf: superclass
	    instanceVariableArray: variableArray
	    shape: realShape
	    classPool: classVarDict
	    poolDictionaries: sharedPoolNames
	    category: categoryName
    ].

    (aClass isVariable & realShape notNil) ifTrue: [
	aClass shape == realShape ifFalse: [
	    SystemExceptions.MutationError
		signal: 'Cannot change shape of variable class' ]
    ].

    superclass isUntrusted & self class isUntrusted not ifTrue: [
	SystemExceptions.MutationError signal: 'Cannot move trusted class below untrusted superclass'
    ].

   needToRecompileMetaclasses := false.
   aClass classPool isNil 
       ifTrue: [ aClass setClassVariables: classVarDict ]
       ifFalse: [
	    classVarDict keysDo: [ :key |
		 (aClass classPool includesKey: key)
		     ifFalse: [ aClass addClassVarName: key ]
	    ]. 

	    aClass classPool keys do: [ :aKey |
		 (classVarDict includesKey: aKey)
		     ifFalse: [
			 aClass removeClassVarName: aKey.
			 needToRecompileMetaclasses := true
		     ]
	    ]
	].

    "If instance or indexed variables change, update 
     instance variables and instance spec of the class and all its subclasses "

    (needToRecompileClasses := variableArray ~= aClass allInstVarNames
	| needToRecompileMetaclasses) 
	| (aClass shape ~~ realShape)
	    ifTrue: [
	        aClass instanceCount > 0
		    ifTrue: [ ObjectMemory globalGarbageCollect ].
		aClass
		    updateInstanceVars: variableArray 
		    shape: realShape
	    ].

    aClass sharedPoolDictionaries isNil 
	ifTrue: [ aClass setSharedPools: sharedPoolNames ]
	ifFalse: [
	    sharedPoolNames do: [ :dict |
		(aClass sharedPoolDictionaries includes: dict)
		    ifFalse: [ aClass addSharedPool: dict ]
	    ].

	    aClass sharedPoolDictionaries copy do: [ :dict |
		(sharedPoolNames includes: dict)
		    ifFalse: [
			aClass removeSharedPool: dict.
			needToRecompileMetaclasses := true
		    ]
	    ]
	].

    (aClass superclass ~~ superclass) ifTrue: [
	"Fix references between classes..."
	aClass superclass removeSubclass: aClass.
	superclass addSubclass: aClass.
	aClass superclass: superclass.
	needToRecompileClasses := true.

	"...and between metaclasses..."
	self superclass removeSubclass: self.
	superclass class addSubclass: self.
	self superclass: superclass class.
	needToRecompileMetaclasses := true.
    ].

    aClass category: categoryName.

    "Please note that I need to recompile the classes in this sequence;
    otherwise, the same error is propagated to each selector which is compiled
    after an error is detected even though there are no further compilation 
    errors. Apparently, there is a bug in the primitive compileString.  This
    can be cleaned up later"
	 
    (needToRecompileClasses | needToRecompileMetaclasses)
	ifTrue: [
	    Transcript nextPutAll: 'Recompiling classes...'; nl.
	    aClass compileAll.
	    needToRecompileMetaclasses
		ifTrue: [ aClass class compileAll ].

	    aClass compileAllSubclasses.
	    needToRecompileMetaclasses
		ifTrue: [ aClass class compileAllSubclasses ]
       ].

    Behavior flushCache.
    ^aClass
!


newMeta: className
    environment: aNamespace
    subclassOf: superclass
    instanceVariableArray: arrayOfInstVarNames
    shape: shape
    classPool: classVarDict
    poolDictionaries: sharedPoolNames
    category: categoryName

    "Private - create a full featured class and install it"

    | aClass |

    aClass := self new.
    classVarDict environment: aClass.
    instanceClass := aClass.
    aNamespace at: className put: aClass.
    superclass isNil
	ifFalse: [ superclass addSubclass: aClass ].

    Behavior flushCache.
    ^aClass
        superclass: superclass;
        setName: className;
	setEnvironment: aNamespace;
	setInstanceVariables: arrayOfInstVarNames;
	setInstanceSpec: shape
	    instVars: arrayOfInstVarNames size;
	setClassVariables: classVarDict;
	setSharedPools: sharedPoolNames;
        makeUntrusted: superclass isUntrusted;
	category: categoryName;
	yourself
! !



!Metaclass methodsFor: 'accessing'!

primaryInstance
    "Answer the only instance of the metaclass - present for compatibility"
    ^instanceClass
!

soleInstance
    "Answer the only instance of the metaclass - present for compatibility"
    ^instanceClass
!

instanceClass
    "Answer the only instance of the metaclass"
    ^instanceClass
! !




!Metaclass methodsFor: 'printing'!

nameIn: aNamespace
    "Answer the class name when the class is referenced from aNamespace."
    ^self instanceClass nameIn: aNamespace
!

printOn: aStream in: aNamespace
    "Print on aStream the class name when the class is referenced from
     aNamespace."
    instanceClass printOn: aStream in: aNamespace.
    aStream nextPutAll: ' class'
!

printOn: aStream
    "Print a represention of the receiver on aStream"
    instanceClass printOn: aStream.
    aStream nextPutAll: ' class'
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    instanceClass storeOn: aStream.
    aStream nextPutAll: ' class'
! !



!Metaclass methodsFor: 'private'!

initMetaclass: superclass
    instanceVariables := superclass allInstVarNames.
    instanceSpec := superclass instanceSpec
!

parsePools: aString in: aNamespace
    | tokens |
    tokens := aString subStrings asArray.
    ^tokens collect: [ :poolName |
	(poolName substrings: $.) inject: aNamespace into: [ :namespace :key |
	    self validateIdentifier: key.
	    namespace
	        at: key asGlobalKey
	        ifAbsent: [ SystemExceptions.NotFound signalOn: poolName what: 'pool' ]
	]
    ].
!

parse: aString toDictionary: dict
    | tokenArray |
    tokenArray := self parseVariableString: aString.
    tokenArray do:
    	[ :element | dict at: element asSymbol put: nil ].
    ^dict
!

growClassInstance
    | newClass numInstVars |
    newClass := self new.
    numInstVars := self instSize.
    numInstVars printNl.
    1 to: numInstVars - 1 do:
	[ :i | newClass instVarAt: i put: 
		   (instanceClass instVarAt: i) ].

    instanceClass become: newClass.
! !

!Metaclass methodsFor: 'testing functionality'!

asClass
    ^instanceClass
!

isMetaclass
    ^true
! !


!Metaclass methodsFor: 'filing'!

fileOutOn: aFileStream
    "File out complete class description:  class definition, class and
     instance methods"

    instanceClass fileOutOn: aFileStream
! !
