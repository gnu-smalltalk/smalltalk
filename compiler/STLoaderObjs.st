"======================================================================
|
|   Smalltalk proxy class loader -- auxiliary classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

STInST addSubspace: #STClassLoaderObjects!
Namespace current: STClassLoaderObjects!

Object subclass: #PseudoBehavior
        instanceVariableNames: 'subclasses loader'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

PseudoBehavior comment:
'This class represent a proxy for a class that is found by an
STClassLoader in the source code it parses.'!

PseudoBehavior subclass: #ProxyClass
        instanceVariableNames: 'proxy'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

ProxyClass comment:
'This class represent a proxy for a preexisting class that is found by an
STClassLoader as a superclass while parsing source code.  Proxying
preexisting classes is necessary to correctly augment their subclasses
with the new classes.'!

PseudoBehavior subclass: #LoadedBehavior
        instanceVariableNames: 'instVars superclass methods comment '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedBehavior comment:
'This class represent a proxy for a class object that is defined
by an STClassLoader.'!

LoadedBehavior subclass: #LoadedClass
        instanceVariableNames: 'name category sharedPools classVars class
				environment kind '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedBehavior comment:
'This class represent a proxy for a class whose source code is parsed
by an STClassLoader.'!

LoadedBehavior subclass: #LoadedMetaclass
        instanceVariableNames: 'instanceClass '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedBehavior comment:
'This class represent a proxy for a metaclass whose source code is parsed
by an STClassLoader.'!

Object subclass: #LoadedMethod
        instanceVariableNames: 'source category'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedMethod comment:
'This class represent a proxy for a method, containing the source code
that was parsed by an STClassLoader.'!

BindingDictionary variableSubclass: #PseudoNamespace
        instanceVariableNames: 'loader subspaces'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

PseudoNamespace comment:
'This class represent a proxy for a namespace that an STClassLoader finds
along the way.'!

PseudoNamespace variableSubclass: #LoadedNamespace
        instanceVariableNames: 'name'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

PseudoNamespace comment:
'This class represent a proxy for a namespace that is created by the
source code that an STClassLoader is parsing.'!

PseudoNamespace variableSubclass: #ProxyNamespace
        instanceVariableNames: 'proxy'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

ProxyNamespace comment:
'This class represent a proxy for a preexisting namespace that is
referenced by the source code that an STClassLoader is parsing.'!

!PseudoBehavior methodsFor: 'creating classes'!

variableByteSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	kind: 'variableByteSubclass:'
	loader: loader!
 
variableWordSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	kind: 'variableWordSubclass:'
	loader: loader!
 
variableSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	kind: 'variableSubclass:'
	loader: loader!
 
subclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	kind: 'subclass:'
	loader: loader!

!PseudoBehavior methodsFor: 'method dictionary services'!

selectors
    "Answer a Set of the receiver's selectors"
    ^self methodDictionary keys
!

allSelectors
    "Answer a Set of all the selectors understood by the receiver"
    | aSet |
    aSet := self selectors.
    self allSuperclassesDo:
        [ :superclass | aSet addAll: superclass selectors ].
    ^aSet
!

compiledMethodAt: selector
    "Return the compiled method associated with selector, from the local
    method dictionary.  Error if not found."
    ^self methodDictionary at: selector
!

includesSelector: selector
    "Return whether there is a compiled method associated with
    selector, from the local method dictionary."
    ^self methodDictionary includesKey: selector
!

sourceCodeAt: selector
    "Answer source code (if available) for the given compiledMethod"
    | source |
    source := (self compiledMethodAt: selector) methodSourceCode.
    source isNil ifTrue: [ '" *** SOURCE CODE NOT AVAILABLE *** "' copy ].
    ^source asString
!

>> selector
    "Return the compiled method associated with selector, from the local
    method dictionary.  Error if not found."
    ^self methodDictionary at: selector
! !


!PseudoBehavior methodsFor: 'navigating hierarchy'!

subclasses
    ^subclasses
!

addSubclass: aClass
    "Add aClass asone of the receiver's subclasses."
    subclasses isNil
        ifTrue: [ subclasses := Array new: 0 ]
        ifFalse: [ "remove old class if any"
                  subclasses := subclasses copyWithout: aClass ].
    subclasses := subclasses copyWith: aClass
!

removeSubclass: aClass
    "Remove aClass from the list of the receiver's subclasses"
    subclasses := subclasses copyWithout: aClass
!

allSubclassesDo: aBlock
    "Invokes aBlock for all subclasses, both direct and indirect."
    subclasses isNil ifTrue: [ ^self ].

    subclasses do: [ :class |
        aBlock value: class.
        class allSubclassesDo: aBlock
    ].
!

allSuperclassesDo: aBlock
    "Invokes aBlock for all superclasses, both direct and indirect."
    | class superclass |
    class := self.
    [ superclass := class superclass.
      class := superclass.
      superclass notNil ] whileTrue:
        [ aBlock value: superclass ]
!

withAllSubclassesDo: aBlock
    "Invokes aBlock for the receiver and all subclasses, both direct
     and indirect."
    aBlock value: self.
    self allSubclassesDo: aBlock.
!

withAllSuperclassesDo: aBlock
    "Invokes aBlock for the receiver and all superclasses, both direct
     and indirect."
    | class |
    class := self.
    [ aBlock value: class.
      class := class superclass.
      class notNil ] whileTrue
!

selectSubclasses: aBlock
    "Return a Set of subclasses of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSubclassesDo: [ :subclass | (aBlock value: subclass)
                                            ifTrue: [ aSet add: subclass ] ].
    ^aSet
!

selectSuperclasses: aBlock
    "Return a Set of superclasses of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSuperclassesDo: [ :superclass | (aBlock value: superclass)
                                            ifTrue: [ aSet add: superclass ] ].
    ^aSet
!

subclassesDo: aBlock
    "Invokes aBlock for all direct subclasses."
    subclasses isNil ifTrue: [ ^self ].
    subclasses do: aBlock
! !

!PseudoBehavior methodsFor: 'accessing'!

loader
    ^loader
!

allInstVarNames
    "Answer the names of the variables in the receiver's inst pool dictionary
     and in each of the superinstes' inst pool dictionaries"

    ^self superclass allInstVarNames, self instVarNames
!

allClassVarNames
    "Answer the names of the variables in the receiver's class pool dictionary
     and in each of the superclasses' class pool dictionaries"

    ^self asClass allClassVarNames
!

allSharedPools
    "Return the names of the shared pools defined by the class and any of
     its superclasses"

    ^self asClass allSharedPools
!

nameIn: aNamespace
    "Answer the class name when the class is referenced from aNamespace"
    ^self environment = aNamespace
	ifTrue: [ self printString ]
	ifFalse: [ (self environment nameIn: aNamespace), '.',
	  self printString ]
! !

!PseudoBehavior methodsFor: 'filing'!

fileOutOn: aFileStream
    "File out complete class description:  class definition, class and
     instance methods"

    self subclassResponsibility
!

fileOut: fileName
    "Open the given file and to file out a complete class description to it"

    | aFileStream  |
    aFileStream := FileStream open: fileName mode: FileStream write.

    Transcript nextPutAll: 'Filing out class to: '; nextPutAll: fileName.
    
    self fileOutOn: aFileStream. 
    aFileStream close.
!

fileOutCategory: categoryName to: fileName
    "File out all the methods belonging to the method category, categoryName,
     to the fileName file"

    | aFileStream |
    aFileStream := FileStream open: fileName mode: FileStream write.

    Transcript nextPutAll: 'Filing out a category to: '; nextPutAll: fileName.

    self fileOutCategory: categoryName toStream: aFileStream.
    aFileStream close
!
	
fileOutCategory: category toStream: aFileStream
    "File out all the methods belonging to the method category, categoryName,
     to aFileStream"

    | methods |
    self selectors isNil ifTrue: [ ^self ].

    aFileStream
	nextPut: $!;
	print: self;
	nextPutAll: ' methodsFor: ';
	store: category;
	nextPut: $!.

    methods := self selectors select: [ :selector |
	(self compiledMethodAt: selector) methodCategory = category
    ].

    methods asSortedCollection do: [ :selector |
	aFileStream
	    nextPutAll: '

';	    nextPutAll: (self sourceCodeAt: selector);
	    nextPut: $!
    ].
    aFileStream nextPutAll: ' !

'
!

fileOutSelector: selector to: fileName
    "File out the given selector to fileName"

    | aFileStream |
    aFileStream := FileStream open: fileName mode: FileStream write.

    Transcript nextPutAll: 'Filing out a selector to: '; nextPutAll: fileName.
    self fileOutHeaderOn: aFileStream.
    aFileStream nextPutAll: '!';
	print: self;
	nextPutAll: ' methodsFor: ';
	store: (self compiledMethodAt: selector) methodCategory;
	nextPut: $!;
	nl;
	nextPutAll: (self sourceCodeAt: selector) ;
	nextPutAll: '! !';
	close
! !


!PseudoBehavior methodsFor: 'private'!

collectCategories
    "Answer all the method categories, sorted by name"

    | categories |
    self methodDictionary isNil ifTrue: [ ^#() ].

    categories := Set new.
    self methodDictionary do:
	[ :method | categories add: (method methodCategory) ].

    ^categories asSortedCollection
! !

!PseudoBehavior methodsFor: 'abstract'!

asClass
    self subclassResponsibility
!

asMetaclass
    self subclassResponsibility
!

comment
    self subclassResponsibility
!

comment: aString
    self subclassResponsibility
!

environment
    self subclassResponsibility
!

kindOfSubclass
    self subclassResponsibility
!

sharedPools
    self subclassResponsibility
!

superclass
    self subclassResponsibility
!

methodDictionary
    self subclassResponsibility
! !

!PseudoBehavior methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: self name!
! !

!PseudoBehavior methodsFor: 'storing'!

storeOn: aStream
    aStream
	nextPutAll: self name!
! !

!PseudoBehavior methodsFor: 'initializing'!

initialize: aSTClassLoader
    self setSubclasses: OrderedCollection new.
    loader := aSTClassLoader
!

setSubclasses: classes
    subclasses := classes
! !

!ProxyClass class methodsFor: 'creating classes'!

on: aClass for: aSTClassLoader
    ^self new setProxy: aClass for: aSTClassLoader
! !

!ProxyClass methodsFor: 'delegation'!

= anObject
    ^self asClass == anObject 
	or: [ anObject class == self class
		 and: [ self asClass == anObject asClass ]
	]
!

hash
    ^proxy hash
!

asClass
    ^proxy
!

asMetaclass
    ^self asClass asMetaclass
!

isClass
    ^true
!

comment
    ^self asClass comment
!

comment: aString
    ^self asClass comment: aString
!

environment
    ^self asClass environment
!

kindOfSubclass
    ^self asClass kindOfSubclass
!

superclass
    ^self asClass superclass
!

methodDictionary
    ^self asClass methodDictionary
!

doesNotUnderstand: aMessage
    ^self asClass perform: aMessage
! !


!ProxyClass methodsFor: 'initializing'!

setProxy: aClass for: aSTClassLoader
    self initialize: aSTClassLoader.
    proxy := aClass.
    self setSubclasses: aClass subclasses copy.
! !

!LoadedBehavior methodsFor: 'accessing'!

instVarNames
    "Answer the names of the variables in the inst pool dictionary"

    ^instVars
!

superclass
    ^superclass
!

methodDictionary
    methods isNil ifTrue: [ methods := LookupTable new ].
    ^methods
! !

!LoadedMetaclass methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: self asClass name;
	nextPutAll: ' class'!
! !

!LoadedMetaclass methodsFor: 'accessing'!

isMetaclass
    ^true
!

instanceVariableNames: ivn
    instVars := (TokenStream on: ivn) contents.
!

asClass
    ^instanceClass
!

asMetaclass
    ^self
! !

!LoadedMetaclass methodsFor: 'delegation'!

name
    ^self asClass name
!

category
    "Answer the class category"
    ^self asClass category
!

comment
    "Answer the class comment"
    ^self asClass comment
!

comment: aString
    "Answer the class comment"
    ^self asClass comment: aString
!

environment
    "Answer the namespace in which the receiver is implemented"
    ^self asClass environment
!

kindOfSubclass
    ^'subclass:'
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"

    ^self asClass classVarNames
!

sharedPools
    "Return the names of the shared pools defined by the class"

    ^self asClass sharedPools
! !



!LoadedMetaclass methodsFor: 'filing'!

fileOutOn: aFileStream
    "File out complete class description:  class definition, class and
     instance methods"

    instanceClass fileOutOn: aFileStream
! !

!LoadedMetaclass methodsFor: 'initializing'!

for: aClass
    super initialize: aClass loader.
    instanceClass := aClass.
    instVars := Array new.
    superclass := aClass superclass class.
    superclass addSubclass: self
!

!LoadedClass class methodsFor: 'creating classes'!

superclass: sup name: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c kind: kind loader: loader
    ^self new
	superclass: sup name: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c kind: kind loader: loader
! !

!LoadedClass methodsFor: 'accessing'!

isClass
    ^true
!

asClass
    ^self
!

asMetaclass
    ^class
!

name
    "Answer the class name"
    ^name
!

category
    "Answer the class category"
    ^category
!

comment
    "Answer the class comment"
    ^comment
!

comment: aString
    "Set the class comment"
    comment := aString
!

environment
    "Answer the namespace in which the receiver is implemented"
    ^environment
!

kindOfSubclass
    ^kind
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"

    ^classVars
!

sharedPools
    "Return the names of the shared pools defined by the class"

    ^sharedPools
! !

!LoadedClass methodsFor: 'filing'!

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
    | aSet printFormattedSet |
    self isMetaclass ifTrue: [ ^self].

    printFormattedSet := [ 
	aFileStream nextPut: $'. 
	(aSet isEmpty) not ifTrue: [
	    aSet do: [ :element |
		aFileStream nextPutAll: element; space ]. 
	    aFileStream nextPut: $'.
	].
    ].

    aFileStream print: self superclass; space;
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

    ((aSet := self asMetaclass instVarNames) isEmpty)
	ifTrue:[ ^self ].

    aFileStream print: self asMetaclass; nextPutAll: ' instanceVariableNames: '.
    printFormattedSet value.
    aFileStream nextPut: $!; nl; nl.
!

fileOutOn: aFileStream
    "File out complete class description:  class definition, class and
     instance methods"

    self fileOutHeaderOn: aFileStream. 
    self fileOutDeclarationOn: aFileStream.

    self asMetaclass collectCategories do:
	[ :category | self asMetaclass fileOutCategory: category toStream: aFileStream ].

    self collectCategories do:
	[ :category | self fileOutCategory: category toStream: aFileStream ].

    (self asMetaclass includesSelector: #initialize) ifTrue: [
	aFileStream nl; print: self; nextPutAll: ' initialize!'.
    ].
    aFileStream nl
! !

!LoadedClass methodsFor: 'initializing'!

superclass: sup name: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c kind: k loader: loader
    self initialize: loader.
    superclass := sup.
    name := s.
    category := c.
    kind := k.
    environment := loader currentNamespace.
    class := LoadedMetaclass new for: self.
    instVars := (TokenStream on: ivn) contents.
    classVars := (TokenStream on: cvn) contents.
    sharedPools := (TokenStream on: pd) contents.
    superclass addSubclass: self.
    environment at: name put: self.
! !

!LoadedMethod class methodsFor: 'instance creation'!

category: category source: source
    ^self new category: category source: source
!

!LoadedMethod methodsFor: 'accessing'!

methodCategory
    ^category
!

methodSourceCode
    ^source
!

methodSourceString
    ^source asString
! !

!LoadedMethod methodsFor: 'initializing'!

category: c source: s
    category := c.
    source := s.
! !

!PseudoNamespace methodsFor: 'abstract'!

name
    self subclassResponsibility! !

!PseudoNamespace methodsFor: 'printing'!

nameIn: aNamespace
    "Answer Smalltalk code compiling to the receiver when the current
     namespace is aNamespace"

    | reference proxy |
    proxy := loader proxyForNamespace: aNamespace.
    reference := proxy at: self name asSymbol ifAbsent: [ nil ].
    self = reference ifTrue: [ ^self name ].
    ^(self superspace nameIn: aNamespace ), '.', self name
!

printOn: aStream
    aStream nextPutAll: (self nameIn: Namespace current)
! !

!PseudoNamespace methodsFor: 'storing'!

storeOn: aStream
    aStream nextPutAll: (self nameIn: Namespace current)
! !

!PseudoNamespace methodsFor: 'initializing'!

copyEmpty: newSize
    ^(super copyEmpty: newSize)
	setLoader: loader;
	yourself
!

setLoader: aSTClassLoader
    loader := aSTClassLoader
! !

!PseudoNamespace methodsFor: 'accessing'!

superspace
    ^self environment
!

setSuperspace: superspace
    self environment: superspace.
    self environment subspaces add: self
!

subspaces
    subspaces isNil ifTrue: [ subspaces := IdentitySet new ].
    ^subspaces
!

addSubspace: aSymbol
    ^LoadedNamespace name: aSymbol in: self for: loader
! !

!LoadedNamespace class methodsFor: 'instance creation'!

name: aSymbol in: aDictionary for: aSTClassLoader
    ^aDictionary at: aSymbol put: (self new
	name: aSymbol;
	setLoader: aSTClassLoader;
	environment: aDictionary;
	yourself)
! !
 
!LoadedNamespace methodsFor: 'accessing'!

at: key ifAbsent: aBlock
    "Return the value associated to the variable named as specified
    by `key'. If the key is not found search will be brought on in
    superspaces, finally evaluating aBlock if the variable cannot be
    found in any of the superspaces."
    | index space |
    space := self.
    [
	space at: key ifPresent: [ :value | ^value ].
	space := space superspace.
	space isNil 
    ] whileFalse.
    ^aBlock value
!

name
    ^name
!

name: aSymbol
    name := aSymbol
! !

!LoadedNamespace methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: 'LoadedNamespace[';
	nextPutAll: self name;
	nextPut: $]! !


!ProxyNamespace class methodsFor: 'accessing'!

on: aDictionary for: aSTClassLoader
    | instance superspace subspaceProxy |
    instance := self new
	setLoader: aSTClassLoader;
	setProxy: aDictionary;
	yourself.

    "Link the instance to itself."
    instance
	at: aDictionary name asSymbol put: instance.

    "Create proxies for the superspaces and for links to the
     subspaces"
    aDictionary superspace isNil ifFalse: [
	superspace := aDictionary superspace.
	instance
	    setSuperspace: (aSTClassLoader proxyForNamespace: superspace).

	subspaceProxy := instance.
	[ superspace isNil ] whileFalse: [
	    superspace := aSTClassLoader proxyForNamespace: superspace.
	    superspace
		at: subspaceProxy name asSymbol put: subspaceProxy.
	    instance
		at: superspace name asSymbol put: superspace.
	    subspaceProxy := superspace.
	    superspace := superspace superspace
	].
    ].

    ^instance
! !

!ProxyNamespace methodsFor: 'initializing'!

copyEmpty: newSize
    ^(super copyEmpty: newSize)
	setProxy: proxy;
	yourself
!

setProxy: aDictionary
    proxy := aDictionary!
! !

!ProxyNamespace methodsFor: 'accessing'!

= anObject
    ^anObject == self proxy or: [
	anObject class == self class and: [
	    self proxy == anObject proxy ]]
!

hash
    ^proxy hash
!

proxy
    ^proxy
!

at: aKey
    ^super at: aKey ifAbsent: [
	proxy at: aKey ]!

at: aKey ifAbsent: aBlock
    ^super at: aKey ifAbsent: [
	proxy at: aKey ifAbsent: aBlock ]!

at: aKey ifAbsentPut: aBlock
    ^super at: aKey ifAbsent: [
	proxy at: aKey ifAbsent: [
	    self at: aKey put: aBlock value ]]!

at: aKey ifPresent: aBlock
    | result |
    result := super at: aKey ifAbsent: [
	proxy at: aKey ifAbsent: [ ^nil ] ].
    ^aBlock value: result!

name
    "Answer the receiver's name"
    ^proxy name
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPutAll: self classNameString , '[', proxy name, '] (' ; nl.
    self myKeysAndValuesDo:
    	[ :key :value | aStream tab;
		   print: key;
		   nextPutAll: '->';
		   print: value;
		   nl ].
    aStream nextPut: $)
!

do: aBlock
    super do: aBlock.
    proxy do: aBlock!

keysAndValuesDo: aBlock
    super keysAndValuesDo: aBlock.
    proxy keysAndValuesDo: aBlock!

myKeysAndValuesDo: aBlock
    super keysAndValuesDo: aBlock!

associationsDo: aBlock
    super associationsDo: aBlock.
    proxy associationsDo: aBlock!

keysDo: aBlock
    super keysDo: aBlock.
    proxy keysDo: aBlock!

includesKey: aKey
    ^(super includesKey: aKey) or: [
	proxy includesKey: aKey ]! !

Namespace current: STInST!
