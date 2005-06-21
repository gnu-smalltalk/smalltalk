"======================================================================
|
|   Class Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005
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


ClassDescription subclass: #Class
		 instanceVariableNames: 'name comment category environment classVariables sharedPools securityPolicy pragmaHandlers'
		 classVariableNames: ''
		 poolDictionaries: ''
		 category: 'Language-Implementation'
!

Class comment: 
'I am THE class object.  My instances are the classes of the system.
I provide information commonly attributed to classes: namely, the
class name, class comment (you wouldn''t be reading this if it
weren''t for me), a list of the instance variables of the class, and
the class category.' !


!Class methodsFor: 'accessing instances and variables'!

name
    "Answer the class name"
    ^name
!

comment
    "Answer the class comment"
    ^comment
!

comment: aString
    "Change the class name"
    comment := aString
!

environment
    ^environment
!

environment: aNamespace
    "Set the receiver's environment to aNamespace and recompile everything"
    environment := aNamespace.
    self asClass compileAll; compileAllSubclasses.
    self asMetaclass compileAll; compileAllSubclasses.
!

category
    "Answer the class category"
    ^category
!

category: aString
    "Change the class category to aString"
    category := aString
!

superclass: aClass
    (aClass isNil and: [ self superclass notNil ])
	ifTrue: [ self initializeAsRootClass ].
    super superclass: aClass.
! !



!Class methodsFor: 'accessing instances and variables'!

addClassVarName: aString
    "Add a class variable with the given name to the class pool dictionary"
    | sym |
    sym := aString asClassPoolKey.

    (self classPool includesKey: sym)
        ifTrue: [ SystemExceptions.AlreadyDefined signalOn: aString ].

    self classPool at: sym put: nil
!

bindingFor: aString
    "Answer the variable binding for the class variable with the
     given name"
    | sym |
    sym := aString asClassPoolKey.
    ^self classPool associationAt: sym
!

removeClassVarName: aString
    "Removes the class variable from the class, error if not present, or
     still in use."
    | sym |
    sym := aString asClassPoolKey.
    (classVariables notNil and: [classVariables includesKey: sym])
    	ifFalse: [ SystemExceptions.NotFound signalOn: aString what: 'class variable' ].

    classVariables removeKey: sym.
    self asClass compileAll; compileAllSubclasses.
    self asMetaclass compileAll; compileAllSubclasses.
!

classPool
    "Answer the class pool dictionary"
    classVariables isNil
	ifTrue: [ classVariables := BindingDictionary new environment: self ].
    ^classVariables
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"
    ^classVariables notNil
	ifTrue: [ classVariables keys ]
	ifFalse: [ Set new ].
!

allClassVarNames
    "Answer the names of the variables in the receiver's class pool dictionary
     and in each of the superclasses' class pool dictionaries"
    | superVarNames |
    superVarNames :=  self classVarNames.
    self allSuperclasses do: [ :each |
	superVarNames addAll: each classVarNames].
    ^superVarNames.  
!

addSharedPool: aDictionary
    "Add the given shared pool to the list of the class' pool dictionaries"
    (sharedPools includes: aDictionary)
    	ifFalse: [ sharedPools := sharedPools copyWith: aDictionary ]
!

removeSharedPool: aDictionary
    "Remove the given dictionary to the list of the class' pool dictionaries"
    sharedPools := sharedPools copyWithout: aDictionary
!

sharedPools
    "Return the names of the shared pools defined by the class"
    | s |
    s := Set new.
    sharedPools notNil ifTrue: [
	self environment associationsDo: [ :each |
	    (sharedPools identityIncludes: each value)
		ifTrue: [ s add: each key ]
	]
    ].
    ^s
!

initializeAsRootClass
    "Perform special initialization reserved to root classes."
    self registerHandler: [ :method :ann |
        method
            rewriteAsCCall: (ann arguments at: 1)
            returning: (ann arguments at: 2)
            args: (ann arguments at: 3) ]
        forPragma: #cCall:returning:args:.
    self registerHandler: [ :method :ann |
        method
            rewriteAsAsyncCCall: (ann arguments at: 1)
            args: (ann arguments at: 2) ]
        forPragma: #asyncCCall:args:.
!

initialize			"redefined in children (?)"
    ^self
! !


!Class methodsFor: 'testing'!

= aClass
    "Returns true if the two class objects are to be considered equal."
    "^(aClass isKindOf: Class) and: [name = aClass name]"
    ^self == aClass
! !



!Class methodsFor: 'instance creation - alternative'!

categoriesFor: method are: categories
    "Don't use this, it is only present to file in from IBM Smalltalk"
    (self >> method) methodCategory: (categories at: 1)
!

subclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	subclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

subclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	subclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
!

variableSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	variableSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

variableSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	variableSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
!

variableByteSubclass: classNameString classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	variableByteSubclass: classNameString
	instanceVariableNames: ''
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

variableByteSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	variableByteSubclass: classNameString
	instanceVariableNames: ''
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
!

variableLongSubclass: classNameString classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	variable: #uint subclass: classNameString
	instanceVariableNames: ''
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

variableLongSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	variable: #uint subclass: classNameString
	instanceVariableNames: ''
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
! !


!Class methodsFor: 'instance creation'!

extend
    "Redefine a version of the receiver in the current namespace.  Note:
    this method can bite you in various ways when sent to system classes;
    read the section on namespaces in the manual for some examples of the
    problems you can encounter."

    | method |
    method := self kindOfSubclass,
	'instanceVariableNames:classVariableNames:poolDictionaries:category:'.

    ^self
        perform: method asSymbol
        withArguments: {self name asSymbol. ''. ''. ''. 'Extensions'}
!

subclass: classNameString
    instanceVariableNames: stringInstVarNames
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryNameString
    "Define a fixed subclass of the receiver with the given name, instance
     variables, class variables, pool dictionaries and category. If the
     class is already defined, if necessary, recompile everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].
    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	  environment: Namespace current
	  subclassOf: self
	  instanceVariableNames: stringInstVarNames
	  shape: nil
	  classVariableNames: stringOfClassVarNames
	  poolDictionaries: stringOfPoolNames
	  category: categoryNameString
!

variableSubclass: classNameString
    instanceVariableNames: stringInstVarNames
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryNameString
    "Define a variable pointer subclass of the receiver with the given
     name, instance variables, class variables, pool dictionaries and
     category. If the class is already defined, if necessary, recompile
     everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].
    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	  environment: Namespace current
	  subclassOf: self
	  instanceVariableNames: stringInstVarNames
	  shape: #pointer
	  classVariableNames: stringOfClassVarNames
	  poolDictionaries: stringOfPoolNames
	  category: categoryNameString
!

variable: shape subclass: classNameString
    instanceVariableNames: stringInstVarNames
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryNameString
    "Define a variable pointer subclass of the receiver with the given
     name, instance variables, class variables, pool dictionaries and
     category. If the class is already defined, if necessary, recompile
     everything needed.  The shape can be one of #byte #int8 #short #ushort
     #int #uint #float #int64 #uint64 #double or #pointer."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: shape
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
!


variableWordSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    "Define a word variable subclass of the receiver with the given
     name, instance variables (must be ''), class variables, pool
     dictionaries and category. If the class is already defined, if
     necessary, recompile everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: (CSymbols.CLongSize = 4 ifTrue: [ #uint ] ifFalse: [ #uint64 ])
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
!

variableByteSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    "Define a byte variable subclass of the receiver with the given
     name, instance variables (must be ''), class variables, pool
     dictionaries and category. If the class is already defined, if
     necessary, recompile everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    shape: #byte
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
! !



!Class methodsFor: 'printing'!

article
    "Answer an article (`a' or `an') which is ok for the receiver's name"
    | name |
    name := self name.
    ^(name at: 1) isVowel ifTrue: [ 'an' ] ifFalse: [ 'a' ].
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPutAll: (self nameIn: Smalltalk)
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    aStream nextPutAll: (self nameIn: Smalltalk)
! !


!Class methodsFor: 'security'!

policy
    ^securityPolicy
!

policy: aSecurityPolicy
    securityPolicy := aSecurityPolicy withOwner: self
! !


!Class methodsFor: 'pragmas'!

registerHandler: aBlock forPragma: pragma
    pragmaHandlers isNil ifTrue: [ pragmaHandlers := IdentityDictionary new ].
    pragmaHandlers at: pragma put: aBlock
!

pragmaHandlerFor: aSymbol
    | handler |
    pragmaHandlers isNil ifFalse: [
	handler := self pragmaHandlers at: aSymbol ifAbsent: [ nil ]
	handler isNil ifFalse: [ ^handler ].
    ].
    self superclass isNil ifFalse: [
        ^self superclass pragmaHandlerFor: aSymbol
    ].
    ^nil
! !


!Class methodsFor: 'private'!

classInstanceVariableNames: stringClassInstVarNames
    self class instanceVariableNames: stringClassInstVarNames
!

setClassVariables: aDictionary
    classVariables := aDictionary.
!

setName: aString
    name := aString.
!

setEnvironment: aNamespace
    environment := aNamespace.
!

setSharedPools: anArray
    "Private - Set the receiver's shared pools to be those in anArray"
    sharedPools := anArray
!

sharedPoolDictionaries
    "Return the shared pools (not the names!) defined by the class"
    ^sharedPools
!

metaclassFor: classNameString
    "Create a Metaclass object for the given class name. The metaclass
     is a subclass of the receiver's metaclass"
    | className class |
    className := classNameString asGlobalKey.
    class := Namespace current hereAt: className ifAbsent: [ nil ].

    ^(class isNil or: [ class isClass not ])
	ifTrue: [ Metaclass subclassOf: self class ]
	ifFalse: [ class class ]
! !


!Class methodsFor: 'testing functionality'!

asClass
    ^self
!

isClass
    ^true
! !


!Class methodsFor: 'filing'!

fileOutHeaderOn: aFileStream
    "Write date and time stamp to aFileStream"
    | now |
    aFileStream nextPutAll: '"Filed out from ';
	nextPutAll: Smalltalk version;
	nextPutAll: ' on '.
    now := Date dateAndTimeNow.
    aFileStream print: now asDate;
	nextPutAll:  '  ';
	print: now asTime;
	nextPutAll: '"!

'!

fileOutDeclarationOn: aFileStream
    "File out class definition to aFileStream"
    | aSet printFormattedSet superclassName |
    self isMetaclass ifTrue: [ ^self].

    printFormattedSet := [ 
	aFileStream nextPutAll: ''''. 
	(aSet isEmpty) not ifTrue: [
	    aSet do: [ :element |
		aFileStream nextPutAll: element; space ]. 
	    aFileStream nextPutAll: ''''.
	].
    ].

    superclassName := self superclass isNil
	ifTrue: [ 'nil' ]
	ifFalse: [ self superclass nameIn: self environment ].

    aFileStream
	nextPutAll: superclassName; space;
	nextPutAll: self kindOfSubclass; space;
	store: name asSymbol.

    aFileStream nl; tab; nextPutAll: 'instanceVariableNames: '.
	((aSet := self instVarNames ) isEmpty)
	    ifTrue:[aFileStream nextPutAll: '''''']
	    ifFalse: printFormattedSet.

    aFileStream nl; tab; nextPutAll: 'classVariableNames: '.
	(aSet := self classVarNames) isEmpty
	    ifTrue:[aFileStream nextPutAll: '''''']
	    ifFalse: printFormattedSet.

    aFileStream nl; tab; nextPutAll: 'poolDictionaries: '.
	(aSet := self sharedPools) isEmpty
	    ifTrue:[aFileStream nextPutAll: '''''']
	    ifFalse: printFormattedSet.

    aFileStream nl; tab; nextPutAll: 'category: ';
	store: category;
	nextPut: $!;
	nl; nl;
	print: self;
	nextPutAll: ' comment: ';
	nl;
	store: self comment;
	nextPut: $!;
	nl; nl.

    ((aSet := self class instVarNames) isEmpty)
	ifTrue:[ ^self ].

    aFileStream print: self class; nextPutAll: ' instanceVariableNames: '.
    printFormattedSet value.
    aFileStream nextPut: $!; nl; nl.
!

fileOutOn: aFileStream
    "File out complete class description:  class definition, class and
     instance methods"

    self fileOutHeaderOn: aFileStream. 
    self fileOutDeclarationOn: aFileStream.
    self fileOutMethodsOn: aFileStream.
    self fileOutInitializeOn: aFileStream!

fileOutInitializeOn: aFileStream
    (self class includesSelector: #initialize) ifTrue: [
	aFileStream nl; print: self; nextPutAll: ' initialize!'.
    ]!

fileOutMethodsOn: aFileStream
    "File out instance methods of the receiver."

    self class collectCategories do:
	[ :category | self class fileOutCategory: category toStream: aFileStream ].

    self collectCategories do:
	[ :category | self fileOutCategory: category toStream: aFileStream ].

    aFileStream nl
! !


!Class methodsFor: 'saving and loading'!

binaryRepresentationVersion
    "Answer a number >= 0 which represents the current version of the
     object's representation.  The default implementation answers
     zero."
    ^0
!

nonVersionedInstSize
    "Answer the number of instance variables that the class used to have
     when objects were stored without using a VersionableObjectProxy.
     The default implementation answers the current instSize."
    ^self instSize
!

convertFromVersion: version withFixedVariables: fixed
			    indexedVariables: indexed
			    for: anObjectDumper

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

    | object |
    object := self isFixed
	ifTrue: [ self basicNew ]
	ifFalse: [ self basicNew: indexed size ].

    fixed
	from: 1
	to: (fixed size min: self instSize)
	keysAndValuesDo: [ :i :obj | object instVarAt: i put: obj ].

    (self isFixed or: [ indexed isNil ]) ifTrue: [ ^object ].

    indexed keysAndValuesDo: [ :i :obj | object basicAt: i put: obj ].
    ^object! !


!Class class methodsFor: 'initialize'!

initialize
    "Perform the special initialization of root classes."
    self subclassesDo: [ :each | each instanceClass initializeAsRootClass ]
! !

