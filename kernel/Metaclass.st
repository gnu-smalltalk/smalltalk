"======================================================================
|
|   Metaclass Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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
| 330, Boston, MA 02111-1307, USA.  
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
! !


!Metaclass methodsFor: 'basic'!

instanceVariableNames: classInstVarNames

    "Set the class-instance variables for the receiver to be those
     in classInstVarNames"

    | variableArray variableString |
    variableString := self superclass instanceVariableString,
	classInstVarNames.
    variableArray := self parseVariableString: variableString.

    1 to: variableArray size do:
	[ :i | variableArray at: i put: (variableArray at: i) asSymbol ].

    "If instance variables change, update  instance variables and
     instance spec of the class and all its subclasses "

    variableArray = self allInstVarNames ifTrue: [ ^self ].

    self
	updateInstanceVars: variableArray 
	variable: false
	words: false
	pointers: true.

    "If no variable has been removed, no need to recompile"
    (self allInstVarNames allSatisfy: [ :each | variableArray includes: each ])
	ifTrue: [ ^self ].
	
    Transcript nextPutAll: 'Recompiling classes...'; nl.
    self compileAll.
    self compileAllSubclasses
!

name: newName
    environment: aNamespace
    subclassOf: superclass
    instanceVariableNames: stringOfInstVarNames
    variable: variableBoolean
    words: wordBoolean
    pointers: pointerBoolean
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryName

    "Private - create a full featured class and install it, or change an
     existing one"

    | aClass variableString variableArray sharedPoolNames poolName poolDict 
      className classVarDict  needToRecompileMetaclasses needToRecompileClasses |

    "Initialize a metaclass"

    className := newName asSymbol.
    aClass := aNamespace hereAt: className ifAbsent: [ nil ].
    aClass isNil ifTrue: [
	^self newMeta: className
	    environment: aNamespace
	    subclassOf: superclass
	    instanceVariableNames: stringOfInstVarNames
	    variable: variableBoolean
	    words: wordBoolean
	    pointers: pointerBoolean
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryName
    ].

    needToRecompileMetaclasses := false.

    (aClass isVariable & aClass isBits) ifTrue: [
	(variableBoolean not | pointerBoolean) ifTrue: [
	    SystemExceptions.MutationError signal: 'Cannot change non-pointer subclass to pointer subclass'
	].
	aClass isWords ~~ wordBoolean ifTrue: [
	    SystemExceptions.MutationError signal: 'Cannot change representation of non-pointer subclass'
	]
    ].

    "Inherit instance variables from parent"
    variableString := superclass notNil 
	ifTrue: [ superclass instanceVariableString, stringOfInstVarNames ]
	ifFalse: [ stringOfInstVarNames ].

    variableArray := self parseVariableString: variableString.
    1 to: variableArray size do:
	[ :i | variableArray at: i put: (variableArray at: i) asSymbol ].

    "If instance or indexed variables change, update 
     instance variables and instance spec of the class and all its subclasses "

    (needToRecompileClasses := variableArray ~= aClass allInstVarNames
	| (aClass environment ~~ aNamespace)) 

	| (aClass isVariable ~~ variableBoolean)
	| (aClass isWords ~~ wordBoolean )
	| (aClass isPointers ~~ pointerBoolean)
	    ifTrue: [
	        aClass instanceCount > 0 ifTrue: [ ObjectMemory globalGarbageCollect ].
		aClass
		    updateInstanceVars: variableArray 
		    variable: variableBoolean
		    words: wordBoolean
		    pointers: pointerBoolean
	    ].

   needToRecompileMetaclasses := aClass environment ~~ aNamespace.
		
   classVarDict := self
	parse: stringOfClassVarNames
	toDictionary: (BindingDictionary new environment: aClass; yourself).

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

    sharedPoolNames := self parsePools: stringOfPoolNames in: aNamespace.
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
    instanceVariableNames: stringOfInstVarNames
    variable: variableBoolean
    words: wordBoolean
    pointers: pointerBoolean
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryName

    "Private - create a full featured class and install it"

    | aClass variableString variableArray sharedPoolNames poolName poolDict
      classVarDict |

    sharedPoolNames := self parsePools: stringOfPoolNames in: aNamespace.
    aClass := self new.
    instanceClass := aClass.
    aNamespace at: className put: aClass.
    aClass superclass: superclass.
    aClass setName: className.
    superclass notNil
	ifTrue: [
	    "Inherit instance variables from parent"
	    variableString := superclass instanceVariableString.
	    superclass addSubclass: aClass
	]
	ifFalse: [ variableString := '' ].

    variableString := variableString , stringOfInstVarNames.
    variableArray := self parseVariableString: variableString.
    1 to: variableArray size do:
	[ :i | variableArray at: i put: (variableArray at: i) asSymbol ].

   classVarDict := self
	parse: stringOfClassVarNames
	toDictionary: (BindingDictionary new environment: aClass; yourself).

    Behavior flushCache.
    ^aClass
	setEnvironment: aNamespace;
	setInstanceVariables: variableArray;
	setInstanceSpec: variableBoolean
	    words: wordBoolean
	    pointers: pointerBoolean
	    instVars: variableArray size;
	setClassVariables: classVarDict;
	setSharedPools: sharedPoolNames;
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

parseVariableString: aString
    | stream tokens |
    stream := TokenStream on: aString.
    tokens := stream contents.
    "Smalltalk verboseExecTracing: true."
    tokens do: [ :token | self validateIdentifier: token ].
    "Smalltalk verboseExecTracing: false."
    ^tokens
!

parsePools: aString in: aNamespace
    | stream tokens |
    stream := TokenStream on: aString.
    tokens := stream contents.
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
