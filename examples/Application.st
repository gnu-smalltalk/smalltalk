"======================================================================
|
|   Experimental ENVY-like Applications
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
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

Object subclass: #SubApplication
	 instanceVariableNames: 'parent subApplications extendedClasses definedClasses prerequisites'
	 classVariableNames: 'Applications'
	 poolDictionaries: ''
	 category: nil
!

SubApplication subclass: #Application
	 instanceVariableNames: ''
	 classVariableNames: ''
	 poolDictionaries: ''
	 category: nil
!

!SubApplication class methodsFor: 'obtaining instances'!

applications
    Applications isNil ifTrue: [ Applications := IdentityDictionary new ].
    ^Applications
!

new
    ^self error:
'Use #create: and #createSubApplication: to obtain a new instance,
#instance to get existing ones'
!

instance
    ^Applications at: self
! !

!SubApplication methodsFor: 'delegating'!

fileOutOn: aStream
    ^self instance fileOutOn: aStream
! !

!SubApplication methodsFor: 'creating new subapplications'!

createSubApplication: name
     | class |
     class := SubApplication subclass: name
	     instanceVariableNames: ''
	     classVariableNames: ''
	     poolDictionaries: ''
	     category: nil.

    self defineClass: class.
    ^(self class applications at: class put: class basicNew)
	initializeParent: self
! !

!SubApplication methodsFor: 'accessing'!

addPrerequisite: aClass
    ^self addPrerequisite: aClass ifAbsentFileIn: nil
!

addPrerequisite: aClass ifAbsentFileIn: aFile
    aFile notNil ifTrue: [
	FileStream fileIn: aFile ifMissing: aClass
    ].
    Smalltalk classAt: aClass ifAbsent: [ ^self error: 'Prerequisite not loaded' ].
    ^prerequisites at: aClass put: aFile.
!

checkPrerequisites
    prerequisites keysAndValuesDo: [ :class :file |
	file notNil ifTrue: [
	    FileStream fileIn: file ifMissing: class
	].
	Smalltalk classAt: class ifAbsent: [ ^self error: 'Prerequisite not loaded' ]
    ]
!

defineClass: aClass
    aClass category: self name.
    ^definedClasses add: aClass
!

defines: aClass
    ^definedClasses includes: aClass
!

extendClass: aClass
    ^extendedClasses add: aClass
!

extends: aClass
    ^extendedClasses includes: aClass
!

extensions
    "Answer the category to be used for extensions belonging to this Application"
    ^'Extensions-', self className
!

name
    ^self class name
!

parent
    ^parent
!

removePrerequisite: aClass
    ^prerequisites removeKey: aClass
!

removePrerequisite: aClass ifAbsent: aBlock
    ^prerequisites removeKey: aClass ifAbsent: aBlock
! !

!SubApplication methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: 'Application ';
	print: self class name
!

storeOn: aStream
    aStream
	store: self class name;
	nextPutAll: ' instance'
! !

!SubApplication methodsFor: 'enumerating'!

allSubApplications
    | result |
    result := Set new.
    self allSubApplicationsDo: [ :each | result add: each ].
    ^result
!

allSubApplicationsDo: aBlock
    self subApplications do: [ :each |
	each withAllSubApplicationsDo: aBlock
    ]
!

comment
    ^self class comment
!

comment: aString
    self class comment: aString
!

definedClassesDo: aBlock
    definedClasses do: aBlock
!

extendedClassesDo: aBlock
    extendedClasses do: aBlock
!

subApplicationsDo: aBlock
    subApplications do: aBlock
!

subApplications
    ^subApplications copy
!

withAllSubApplications
    ^self allSubApplications
	add: self;
	yourself
!

withAllSubApplicationsDo: aBlock
    aBlock value: self.
    subApplications do: [ :each |
	each withAllSubApplicationsDo: aBlock
    ]
! !

!SubApplication methodsFor: 'filing out'!

fileOutOn: aStream
    "File out in this order:
	- class declaration
	- prerequisites
	- #wasLoaded method
	- definition for defined classes
	- methods for defined classes
	- methods for extended classes
	- definition of subapplications
	- calls to methods in the application object"

    aStream
	nextPutAll: self definition;
	nl.

    prerequisites keysAndValuesDo: [ :class :file |
	aStream
	    tab;
	    nextPutAll: 'addPrerequisite: ';
	    print: class;
	    nextPutAll: ' ifAbsentFileIn: ';
	    store: file;
	    nextPut: $;
	    nl
    ].
    aStream tab; nextPutAll: 'yourself!'; nl; nl.

    self class includesSelector: #wasLoaded ifTrue: [
	self class fileOutSelector: #wasLoaded on: aStream
    ].

    self fileOutClassesOn: aStream.

    extendedClasses do: [ :each |
	each fileOutCategory: self extensions on: aStream
    ]

    self subApplicationsDo: [ :each |
	each instance fileOutOn: aStream
    ].

    aStream store: self.
    definedClasses do: [ :each |
	aStream
	    nl; tab; nextPutAll: 'definesClass: ';
	    print: each;
	    nextPut: $;
    ].
    extendedClasses do: [ :each |
	aStream
	    nl; tab; nextPutAll: 'extendsClass: ';
	    print: each;
	    nextPut: $;
    ].
    aStream
	nl; tab;
	nextPutAll:
	    (self parent isNil ifTrue: [ 'wasLoaded!' ] ifFalse: [ 'yourself!' ]);
	nl.
!

!SubApplication methodsFor: 'events'!

wasLoaded
    self checkPrerequisites.
    self definedClassesDo: [ :each |
	(each class includesSelector: #initialize)
	    ifTrue: [ each initialize ]
    ].
    self allSubApplicationsDo: [:each | each wasLoaded ]
!

wasRemoved
! !

!SubApplication methodsFor: 'removing from the image'!

removeClass: aClass
    (self extends: aClass) ifTrue: [
	aClass removeCategory: 'Extensions-', self name.
	^self
    ].
    aClass subclasses isEmpty ifFalse: [
	^self error: 'cannot remove class with defined subclasses'
    ].
    (self defines: aClass) ifTrue: [
	aClass superclass removeSubclass: aClass .
	Smalltalk removeKey: aClass
    ].
!

remove
    self allSubApplicationsDo: [:each |
	each remove.
	definedClasses remove: each
    ].
    "Use reverseDo: to go depth-first"
    self orderedDefinedClasses reverseDo: [ :each |
	each superclass removeSubclass: each.
	Smalltalk removeKey: each
    ].
    self extendedClassesDo: [ :each |
	each removeCategory: 'Extensions-', self name
    ].
    self wasRemoved.
    self class superclass removeSubclass: self class
!

unbindClass: aClass
    definedClasses remove: aClass ifAbsent: [
	extendedClasses remove: aClass ifAbsent: [
	    ^self error: 'class not found in Application'
	]
    ].
    ^aClass
! !

!SubApplication methodsFor: 'private'!

compareClasses: a and: b
    | c d |
    a value = b value ifFalse: [ ^a value < b value ].

    c := a key superclass.
    d := b key superclass.
    ^(c == d) | c isNil | d isNil
	ifFalse: [ c name < d name ]
	ifTrue: [ a key name < b key name ]
!

declaration
    ^'(%2 createSubApplication: #%1)' bindWith: self name with: self parent storeString
!

fileOutClassesOn: aStream
    self orderedDefinedClasses
	do: [ :each | each fileOutDeclarationOn:       aStream ];
	do: [ :each | self fileOutMethodsFor: each on: aStream ]

!

fileOutMethodsFor: aClass on: aStream
    | categories |
    categories := Set new.
    aClass methodDictionary notNil ifTrue: [
	aClass methodDictionary do: [ :method |
	    categories add: method methodCategory.
	]
    ].
    categories do: [ :category |
	('Extensions-*' match: category) ifFalse: [
	    aClass fileOutCategory: category toStream: aStream
	]
    ]
    aStream nl; nl.
!

orderedDefinedClasses
    | classes orderedClasses nextClass |
    classes := definedClasses reject: [ :each | each isKindOf: SubApplication ].
    orderedClasses := WriteStream on: (Array new: classes size).
    [ classes isEmpty ] whileFalse: [
	nextClass := classes anyOne.
	self
	    orderClasses: classes
	    startingAt: nextClass
	    orderOn: orderedClasses
	    level: nextClass allSuperclasses size
    ].
    orderedClasses := orderedClasses contents asSortedCollection: [ :a :b |
	self compareClasses: a and: b
    ].
    ^orderedClasses collect: [ :each | each key ]
!

orderClasses: classes startingAt: aClass orderOn: aStream level: level
    | classesLeft |
    (classes includes: aClass superclass) ifTrue: [
	self
	    orderClasses: classes
	    startingAt: aClass superclass
	    orderOn: aStream
	    level: level - 1
    ].
    classesLeft remove: aClass.
    aStream nextPut: (aClass -> level)
!

initializeParent: anApplicationOrNil
    prerequisites := IdentityDictionary new: 8.
    extendedClasses := Set new.
    definedClasses := Set new.
    parent := anApplicationOrNil.
! !

!Application class methodsFor: 'creating new applications'!

create: name
     | class |
     class := Application subclass: name
	     instanceVariableNames: ''
	     classVariableNames: ''
	     poolDictionaries: ''
	     category: nil.

    ^(self applications at: class put: class basicNew)
	initializeParent: nil
!

!Application methodsFor: 'private'!

declaration
    ^'(Application create: #%1)' bindWith: self name
! !
