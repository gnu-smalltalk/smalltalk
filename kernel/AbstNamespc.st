"======================================================================
|
|   AbstractNamespace Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002
| Free Software Foundation, Inc.
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


BindingDictionary variableSubclass: #AbstractNamespace
	   instanceVariableNames: 'name subspaces'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Language-Implementation'
!

AbstractNamespace comment: 
'I am a special form of dictionary.  Classes hold on
an instance of me; it is called their `environment''. ' !


!AbstractNamespace class methodsFor: 'instance creation'!

new
    "Disabled - use #new to create instances"
    SystemExceptions.WrongMessageSent signalOn: #new useInstead: #new:
!

primNew: parent name: spaceName
    "Private - Create a new namespace with the given name and parent, and
     add to the parent a key that references it."
    (parent at: spaceName ifAbsent: [ nil ]) isNamespace
	ifTrue: [ ^parent at: spaceName asGlobalKey ].

    ^parent
        at: spaceName asGlobalKey
        put: ((super new: 32)
		setSuperspace: parent;
		name: spaceName asSymbol;
		yourself)
! !


!AbstractNamespace methodsFor: 'copying'!

whileCurrentDo: aBlock
    "Evaluate aBlock with the current namespace set to the receiver.
     Answer the result of the evaluation."
    | oldCurrent |
    oldCurrent := Namespace current.
    Namespace current: self.
    ^aBlock ensure: [ Namespace current: oldCurrent ]
! !


!AbstractNamespace methodsFor: 'copying'!

copyEmpty: newSize
    "Answer an empty copy of the receiver whose size is newSize"
    ^(super copyEmpty: newSize)
        name: self name;
        setSubspaces: self subspaces;
        yourself
! !


!AbstractNamespace methodsFor: 'accessing'!

allAssociations
    "Answer a Dictionary with all of the associations in the receiver
    and each of its superspaces (duplicate keys are associated to the
    associations that are deeper in the namespace hierarchy)"
    | allAssociations value |
    allAssociations := Dictionary new.
    self withAllSuperspaces reverseDo: [ :each |
	1 to: each primSize do: [ :index |
	    value := each primAt: index.
	    value isNil ifFalse: [ allAssociations add: value copy ]
	].
    ].
    ^allAssociations
!

allBehaviorsDo: aBlock
    "Evaluate aBlock once for each class and metaclass in the namespace."
    Behavior withAllSubclassesDo: [ :subclass |
	(subclass isClass) | (subclass isMetaclass) ifFalse: [
	    subclass allInstancesDo: [ :each |
	        each environment == self
		    ifTrue: [ aBlock value: each ]
	    ]
	]
    ].
    "Special case classes and metaclasses because #allInstancesDo: is very
     slow - the less we use it, the better it is."
    Class allSubclassesDo: [ :eachMeta |
	eachMeta environment == self
	    ifTrue: [ aBlock value: eachMeta; value: eachMeta instanceClass ]
    ]
!

allClassesDo: aBlock
    "Evaluate aBlock once for each class in the namespace."
    Class allSubclassesDo: [ :eachMeta |
	eachMeta environment == self
	    ifTrue: [ aBlock value: eachMeta instanceClass ]
    ]
!

allClassObjectsDo: aBlock
    "Evaluate aBlock once for each class and metaclass in the namespace."
    Class allSubclassesDo: [ :eachMeta |
	eachMeta environment == self
	    ifTrue: [ aBlock value: eachMeta; value: eachMeta instanceClass ]
    ]
!

allMetaclassesDo: aBlock
    "Evaluate aBlock once for each metaclass in the namespace."
    Class allSubclassesDo: [ :eachMeta |
	eachMeta environment == self
	    ifTrue: [ aBlock value: eachMeta ]
    ]
!

classAt: aKey
    "Answer the value corrisponding to aKey if it is a class. Fail
     if either aKey is not found or it is associated to something different
     from a class."
    ^self classAt: aKey ifAbsent: 
	[ SystemExceptions.NotFound signalOn: aKey what: 'class' ]
!

classAt: aKey ifAbsent: aBlock
    "Answer the value corrisponding to aKey if it is a class. Evaluate
     aBlock and answer its result if either aKey is not found or it is
     associated to something different from a class."
    | class |
    class := self at: aKey asGlobalKey ifAbsent: [ ^aBlock value ].
    class isClass ifFalse: [ ^aBlock value ].
    ^class
! !


!AbstractNamespace methodsFor: 'overrides for superspaces'!

definedKeys
    "Answer a kind of Set containing the keys of the receiver"
    | aSet value |
    aSet := self keysClass new: tally * 4 // 3.
    1 to: self primSize do: [ :index |
        value := self primAt: index.
        value isNil ifFalse: [ aSet add: value key ]
    ].
    ^aSet
!

definesKey: key
    "Answer whether the receiver defines the given key. `Defines'
    means that the receiver's superspaces, if any, are not considered."
    ^super includesKey: key
!

hereAt: key ifAbsent: aBlock
    "Return the value associated to the variable named as specified
    by `key' *in this namespace*. If the key is not found search will
    *not* be carried on in superspaces and aBlock will be immediately
    evaluated."
    ^super at: key ifAbsent: aBlock
!

hereAt: key
    "Return the value associated to the variable named as specified
    by `key' *in this namespace*. If the key is not found search will
    *not* be carried on in superspaces and the method will fail."
    ^self hereAt: key
	ifAbsent: [ SystemExceptions.NotFound signalOn: key what: 'key' ]
!

inheritedKeys
    "Answer a Set of all the keys in the receiver and its superspaces"
    self subclassResponsibility
!

set: key to: newValue
    "Assign newValue to the variable named as specified by `key'.
    This method won't define a new variable; instead if the key
    is not found it will search in superspaces and raising an
    error if the variable cannot be found in any of the superspaces.
    Answer newValue."
    ^self set: key to: newValue
	ifAbsent: [ SystemExceptions.NotFound signalOn: key what: 'key' ]
!

set: key to: newValue ifAbsent: aBlock
    "Assign newValue to the variable named as specified by `key'.
    This method won't define a new variable; instead if the key
    is not found it will search in superspaces and evaluate
    aBlock if it is not found. Answer newValue."

    self subclassResponsibility
!

values
    "Answer a Bag containing the values of the receiver"
    | aBag value |
    aBag := Bag new: tally.
    1 to: self primSize do: [ :index |
        value := self primAt: index.
        value isNil ifFalse: [ aBag add: value value ]
    ].
    ^aBag
! !



!AbstractNamespace methodsFor: 'namespace hierarchy'!

addSubspace: aSymbol
    "Add aNamespace to the set of the receiver's subspaces"
    ^Namespace primNew: self name: aSymbol
!

allSubassociationsDo: aBlock
    "Invokes aBlock once for every association in each of the receiver's
     subspaces."
    self allSubspacesDo:
    	[ :subspace | subspace associationsDo: aBlock ]
!

allSubspacesDo: aBlock
    "Invokes aBlock for all subspaces, both direct and indirect."
    self subspaces notNil
	ifTrue: [ self subspaces do: [ :space | aBlock value: space.
					    space allSubspacesDo: aBlock ]
		      ]
!

allSubspaces
    "Answer the direct and indirect subspaces of the receiver in a Set"
    | aSet |
    aSet := Set new.
    self allSubspacesDo: [ :subspace | aSet add: subspace ].
    ^aSet
!

allSuperspaces
    "Answer all the receiver's superspaces in a collection"
    | supers |
    supers := OrderedCollection new.
    self allSuperspacesDo:
    	[ :superspace | supers addLast: superspace ].
    ^supers
!

allSuperspacesDo: aBlock
    "Evaluate aBlock once for each of the receiver's superspaces"
    | space |
    space := self.
    [ space := space superspace.
      space notNil ] whileTrue: [ aBlock value: space ]
!

includesClassNamed: aString
    "Answer whether the receiver or any of its superspaces include the
     given class -- note that this method (unlike #includesKey:) does not
     require aString to be interned and (unlike #includesGlobalNamed:) only
     returns true if the global is a class object."
    | possibleClass |
    possibleClass := Symbol 
        hasInterned: aString
        ifTrue: [ :aSymbol | self at: aSymbol ifAbsent: [nil] ].
        
    ^possibleClass isClass
!

includesGlobalNamed: aString
    "Answer whether the receiver or any of its superspaces include the
     given key -- note that this method (unlike #includesKey:) does not
     require aString to be interned but (unlike #includesClassNamed:)
     returns true even if the global is not a class object."
    Symbol 
        hasInterned: aString
        ifTrue: [ :aSymbol | self at: aSymbol ifPresent: [ :value | ^true] ].

    ^false
!

inheritsFrom: aNamespace
    "Answer whether aNamespace is one of the receiver's direct and
     indirect superspaces"
    | space |
    space := self.
    [ space := space superspace.
      space == aNamespace ifTrue: [ ^true ].
      space notNil ] whileTrue
!

selectSubspaces: aBlock
    "Return a Set of subspaces of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSubspacesDo: [ :subspace | (aBlock value: subspace)
    	    	    	    	    	    ifTrue: [ aSet add: subspace ] ].
    ^aSet
!

selectSuperspaces: aBlock
    "Return a Set of superspaces of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSuperspacesDo: [ :superspace | (aBlock value: superspace)
    	    	    	    	    	    ifTrue: [ aSet add: superspace ] ].
    ^aSet
!

siblings
    "Answer all the other children of the same namespace as the receiver."
    self subclassResponsibility
!

siblingsDo: aBlock
    "Evaluate aBlock once for each of the other root namespaces,
    passing the namespace as a parameter."
    self subclassResponsibility
!

superspace
    "Answer the receiver's superspace."
    ^environment!

superspace: aNamespace
    "Set the superspace of the receiver to be 'aNamespace'.  Also
     adds the receiver as a subspace of it."

    | oldSuperspace newSuperspace root |
    oldSuperspace := self superspace.
    newSuperspace := aNamespace.

    oldSuperspace == newSuperspace ifTrue: [ ^self ].	"don't need to change anything"
    
    oldSuperspace isNil
	ifTrue: [
	    oldSuperspace := Smalltalk.
	    self become: ((Namespace basicNew: self primSize) copyAllFrom: self).
	]
	ifFalse: [
	    oldSuperspace subspaces remove: self.
	].
  
    newSuperspace isNil
	ifTrue: [
	    newSuperspace := Smalltalk.
	    self become: ((AbstractNamespace basicNew: self primSize) copyAllFrom: self).
	]
	ifFalse: [
	    aNamespace subspaces add: self
	].

    environment := aNamespace.

    newSuperspace
	add: (oldSuperspace remove: self name asGlobalKey -> nil).

    self do: [ :each |
	each isClass ifTrue: [
	    each recompileAll.
	    each class recompileAll.
	]
    ].
    self allSubassociationsDo: [ :assoc |
	assoc value isClass ifTrue: [
	    assoc value recompileAll.
	    assoc value class recompileAll.
	]
    ].
!

subspaces
    "Answer the receiver's direct subspaces"
    subspaces isNil ifTrue: [ subspaces := IdentitySet new ].
    ^subspaces
!

subspacesDo: aBlock
    "Invokes aBlock for all direct subspaces."
    self subspaces do: aBlock
!

withAllSubspaces
    "Answer a Set containing the receiver together with its direct and
     indirect subspaces"
    | aSet |
    aSet := Set with: self.
    aSet addAll: self allSubspaces.
    ^aSet
!

withAllSubspacesDo: aBlock
    "Invokes aBlock for the receiver and all subclasses, both direct
     and indirect."
    aBlock value: self.
    self subspaces do: [ :subspace |
	aBlock value: subspace.
	subspace allSubspacesDo: aBlock
    ]
!

withAllSuperspaces
    "Answer the receiver and all of its superspaces in a collection"
    | supers |
    supers := OrderedCollection with: self.
    self allSuperspacesDo:
    	[ :superspace | supers addLast: superspace ].
    ^supers
!

withAllSuperspacesDo: aBlock
    "Invokes aBlock for the receiver and all superspaces, both direct
     and indirect."
    | space |
    space := self.
    [ aBlock value: space.
      space := space superspace.
      space notNil ] whileTrue
! !


!AbstractNamespace methodsFor: 'printing'!

nameIn: aNamespace
    "Answer Smalltalk code compiling to the receiver when the current
     namespace is aNamespace"
    self subclassResponsibility
!

name
    "Answer the receiver's name"
    ^name
!

name: aSymbol
    "Change the receiver's name to aSymbol"
    name := aSymbol
!

printOn: aStream
    "Print a representation of the receiver"
    aStream nextPutAll: self name
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver"
    self subclassResponsibility
! !


!AbstractNamespace methodsFor: 'private'!

setSuperspace: newSuperspace
    self environment: newSuperspace.
    self environment subspaces add: self.
!

setSubspaces: newSubspaces
    subspaces := newSubspaces
!

removeSubspace: aNamespace
    self subspaces remove: aNamespace.
    aNamespace setSuperspace: nil
! !


!AbstractNamespace methodsFor: 'testing'!

isNamespace
    ^true
!

isSmalltalk
    ^false
! !
