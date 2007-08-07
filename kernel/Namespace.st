"======================================================================
|
|   Namespace Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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


AbstractNamespace variableSubclass: #Namespace
	   instanceVariableNames: ''
	   classVariableNames: 'Current'
	   poolDictionaries: ''
	   category: 'Language-Implementation'
!

Namespace comment: 
'I am a Namespace that has a super-namespace.' !


!Namespace class methodsFor: 'initialization'!

initialize
    "This actually is not needed, the job could be done in dict.c
     (function namespace_new).  But I'm lazy and I prefer to rely
     on the Smalltalk implementation of IdentitySet."

    self allInstancesDo: [ :each |
	each superspace isNil ifTrue: [ each setSuperspace: Smalltalk ].
	each superspace subspaces add: each ]! !


!Namespace class methodsFor: 'disabling instance creation'!

new
    "Disabled - use #addSubspace: to create instances"
    SystemExceptions.WrongMessageSent signalOn: #new useInstead: #addSubspace:
!

new: size
    "Disabled - use #addSubspace: to create instances"
    SystemExceptions.WrongMessageSent signalOn: #new: useInstead: #addSubspace:
! !


!Namespace methodsFor: 'accessing'!

inheritedKeys
    "Answer a Set of all the keys in the receiver and its superspaces"
    ^self keys
	removeAll: self definedKeys
	ifAbsent: [ :each | self error: 'synchronization problem?' ];

	yourself
! !


!Namespace methodsFor: 'overrides for superspaces'!

associationsDo: aBlock
    "Pass each association in the namespace to aBlock"
    self allAssociations associationsDo: aBlock
!

at: key ifPresent: aBlock
    "If aKey is absent from the receiver and all its superspaces,
     answer nil. Else, evaluate aBlock passing the associated value
     and answer the result of the invocation"

    | index space |
    space := self.
    [
	index := space findIndexOrNil: key.
	index isNil
    ]   whileTrue: [
	space := space superspace.
	space isNil ifTrue: [ ^nil ].
    ].
    ^aBlock value: (space primAt: index) value
!

associationAt: key ifAbsent: aBlock
    "Return the key/value pair associated to the variable named as
    specified by `key'. If the key is not found search will be
    brought on in superspaces, finally evaluating aBlock if the
    variable cannot be found in any of the superspaces."
    | index space |
    space := self.
    [
	index := space findIndexOrNil: key.
	index isNil
    ]   whileTrue: [
	space := space superspace.
	space isNil ifTrue: [ ^aBlock value ].
    ].
    ^space primAt: index
!

at: key ifAbsent: aBlock
    "Return the value associated to the variable named as specified
    by `key'. If the key is not found search will be brought on in
    superspaces, finally evaluating aBlock if the variable cannot be
    found in any of the superspaces."
    | index space |
    space := self.
    [
	index := space findIndexOrNil: key.
	index isNil
    ]   whileTrue: [
	space := space superspace.
	space isNil ifTrue: [ ^aBlock value ].
    ].
    ^(space primAt: index) value
!

do: aBlock
    "Pass each value in the namespace to aBlock"
    self allAssociations do: aBlock
!

includesKey: key
    "Answer whether the receiver or any of its superspaces contain
     the given key"
    | index space |
    space := self.
    [
	index := space findIndexOrNil: key.
	index isNil
    ]   whileTrue: [
	space := space superspace.
	space isNil ifTrue: [ ^false ].
    ].
    ^true
!

keysAndValuesDo: aBlock
    "Pass to aBlock each of the receiver's keys and values, in two
     separate parameters"
    self allAssociations keysAndValuesDo: aBlock
!

keysDo: aBlock
    "Pass to aBlock each of the receiver's keys"
    self keys do: aBlock
!

set: key to: newValue ifAbsent: aBlock
    "Assign newValue to the variable named as specified by `key'.
    This method won't define a new variable; instead if the key
    is not found it will search in superspaces and evaluate
    aBlock if it is not found. Answer newValue."
    | index space |
    space := self.
    [
	index := space findIndexOrNil: key.
	index isNil
    ]   whileTrue: [
	space := space superspace.
	space isNil ifTrue: [ ^aBlock value ].
    ].
    (space primAt: index) value: newValue.
    ^newValue
!

size
    "Answer the number of keys in the receiver and each of its superspaces"
    ^super size + self superspace size
! !



!Namespace methodsFor: 'namespace hierarchy'!

siblings
    "Answer all the other namespaces that inherit from the receiver's
    superspace."
    ^self superspace subspaces copy
	remove: self;
	yourself
!

siblingsDo: aBlock
    "Evaluate aBlock once for each of the other namespaces that inherit
    from the receiver's superspace, passing the namespace as a parameter."
    self superspace subspaces do: [ :space |
	space == self ifFalse: [ aBlock value: space ]
    ]
! !


!Namespace methodsFor: 'printing'!

nameIn: aNamespace
    "Answer Smalltalk code compiling to the receiver when the current
     namespace is aNamespace"

    | reference |
    reference := aNamespace at: self name asGlobalKey ifAbsent: [ nil ].
    reference == self ifTrue: [ ^self name asString ].
    ^(self superspace nameIn: aNamespace), '.', self name
!

printOn: aStream in: aNamespace
    "Print on aStream some Smalltalk code compiling to the receiver
     when the current namespace is aNamespace"

    | reference |
    reference := aNamespace at: self name asGlobalKey ifAbsent: [ nil ].
    reference == self ifFalse: [
	self superspace printOn: aStream in: aNamespace.
	aStream nextPut: $.
    ].

    aStream nextPutAll: self name
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver"
    | result name |
    name := self name.
    name isNil ifTrue: [ self error: 'cannot print unnamed namespace' ].
    
    self superspace storeOn: aStream.
    aStream nextPut: $.; nextPutAll: name
! !
!Namespace class methodsFor: 'accessing'!

current
    "Answer the current namespace"
    Current isNil ifTrue: [ Current := Smalltalk ].
    ^Current
!

current: aNamespaceOrClass
    "Set the current namespace to be aNamespace or, if it is a class,
     its class pool (the Dictionary that holds class variables)."
    "The primitive call is needed to inform the compiler"
    | namespace |
    <primitive: VMpr_Namespace_setCurrent>
    namespace := aNamespaceOrClass isClass
	ifTrue: [ aNamespaceOrClass classPool ]
	ifFalse: [ aNamespaceOrClass ].

    (namespace isKindOf: Dictionary)
	ifTrue: [ Current := namespace ]
	ifFalse: [
	    SystemExceptions.WrongClass
		signalOn: aNamespaceOrClass
		mustBe: { Dictionary. Class } ].
! !


