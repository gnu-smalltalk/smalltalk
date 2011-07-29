"======================================================================
|
|   AbstractNamespace Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2007, 2008
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



BindingDictionary subclass: AbstractNamespace [
    | name subspaces sharedPools |
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'I am a special form of dictionary.  Classes hold on
an instance of me; it is called their `environment''. '>

    AbstractNamespace class >> new [
	"Disabled - use #new to create instances"

	<category: 'instance creation'>
	SystemExceptions.WrongMessageSent signalOn: #new useInstead: #new:
    ]

    AbstractNamespace class >> primNew: parent name: spaceName [
	"Private - Create a new namespace with the given name and parent, and
	 add to the parent a key that references it."

	<category: 'instance creation'>
	(parent at: spaceName ifAbsent: [nil]) isNamespace 
	    ifTrue: [^parent at: spaceName asGlobalKey].
	^parent at: spaceName asGlobalKey
	    put: ((super new: 24)
		    setSuperspace: parent;
		    name: spaceName asSymbol;
		    yourself)
    ]

    whileCurrentDo: aBlock [
	"Evaluate aBlock with the current namespace set to the receiver.
	 Answer the result of the evaluation."

	<category: 'copying'>
	| oldCurrent |
	oldCurrent := Namespace current.
	Namespace current: self.
	^aBlock ensure: [Namespace current: oldCurrent]
    ]

    copyEmpty: newSize [
	"Answer an empty copy of the receiver whose size is newSize"

	<category: 'copying'>
	^(super copyEmpty: newSize)
	    name: self name;
	    setSubspaces: self subspaces;
	    yourself
    ]

    allAssociations [
	"Answer a Dictionary with all of the associations in the receiver
	 and each of its superspaces (duplicate keys are associated to the
	 associations that are deeper in the namespace hierarchy)"

	<category: 'accessing'>
	| allAssociations value |
	allAssociations := Dictionary new.
	self withAllSuperspaces reverseDo: 
		[:each | 
		1 to: each primSize
		    do: 
			[:index | 
			value := each primAt: index.
			value isNil ifFalse: [allAssociations add: value copy]]].
	^allAssociations
    ]

    allBehaviorsDo: aBlock [
	"Evaluate aBlock once for each class and metaclass in the namespace."

	<category: 'accessing'>
	Behavior withAllSubclassesDo: 
		[:subclass | 
		subclass isClass | subclass isMetaclass 
		    ifFalse: 
			[subclass 
			    allInstancesDo: [:each | each environment == self ifTrue: [aBlock value: each]]]].
	"Special case classes and metaclasses because #allInstancesDo: is very
	 slow - the less we use it, the better it is."
	Class allSubclassesDo: 
		[:eachMeta | 
		eachMeta environment == self 
		    ifTrue: 
			[aBlock
			    value: eachMeta;
			    value: eachMeta instanceClass]]
    ]

    allClassesDo: aBlock [
	"Evaluate aBlock once for each class in the namespace."

	<category: 'accessing'>
	Class allSubclassesDo: 
		[:eachMeta | 
		eachMeta environment == self 
		    ifTrue: [aBlock value: eachMeta instanceClass]]
    ]

    allClassObjectsDo: aBlock [
	"Evaluate aBlock once for each class and metaclass in the namespace."

	<category: 'accessing'>
	Class allSubclassesDo: 
		[:eachMeta | 
		eachMeta environment == self 
		    ifTrue: 
			[aBlock
			    value: eachMeta;
			    value: eachMeta instanceClass]]
    ]

    allMetaclassesDo: aBlock [
	"Evaluate aBlock once for each metaclass in the namespace."

	<category: 'accessing'>
	Class allSubclassesDo: 
		[:eachMeta | 
		eachMeta environment == self ifTrue: [aBlock value: eachMeta]]
    ]

    classAt: aKey [
	"Answer the value corrisponding to aKey if it is a class. Fail
	 if either aKey is not found or it is associated to something different
	 from a class."

	<category: 'accessing'>
	^self classAt: aKey
	    ifAbsent: [SystemExceptions.NotFound signalOn: aKey what: 'class']
    ]

    classAt: aKey ifAbsent: aBlock [
	"Answer the value corrisponding to aKey if it is a class. Evaluate
	 aBlock and answer its result if either aKey is not found or it is
	 associated to something different from a class."

	<category: 'accessing'>
	| class |
	class := self at: aKey asGlobalKey ifAbsent: [^aBlock value].
	class isClass ifFalse: [^aBlock value].
	^class
    ]

    addSharedPool: aDictionary [
	"Import the given bindings for classes compiled with me as
	 environment."
	<category: 'compiling'>
	sharedPools isNil ifTrue: [^sharedPools := {aDictionary}].
	(sharedPools includes: aDictionary) ifFalse:
	    [sharedPools := sharedPools copyWith: aDictionary].
    ]

    import: aDictionary [
	"Import the given bindings for classes compiled with me as
	 environment."
	<category: 'compiling'>
	self addSharedPool: aDictionary
    ]

    removeSharedPool: aDictionary [
	"Remove aDictionary from my list of direct pools."
	<category: 'compiling'>
	sharedPools isNil ifFalse:
	    [sharedPools := sharedPools copyWithout: aDictionary]
    ]

    sharedPoolDictionaries [
	"Answer the shared pools (not names) imported for my classes."
	<category: 'compiling'>
	^sharedPools ifNil: [#()]
    ]

    inheritedKeys [
	"Answer a Set of all the keys in the receiver and its superspaces"

	<category: 'overrides for superspaces'>
	self subclassResponsibility
    ]

    set: key to: newValue [
	"Assign newValue to the variable named as specified by `key'.
	 This method won't define a new variable; instead if the key
	 is not found it will search in superspaces and raising an
	 error if the variable cannot be found in any of the superspaces.
	 Answer newValue."

	<category: 'overrides for superspaces'>
	^self 
	    set: key
	    to: newValue
	    ifAbsent: [SystemExceptions.NotFound signalOn: key what: 'key']
    ]

    set: key to: newValue ifAbsent: aBlock [
	"Assign newValue to the variable named as specified by `key'.
	 This method won't define a new variable; instead if the key
	 is not found it will search in superspaces and evaluate
	 aBlock if it is not found. Answer newValue."

	<category: 'overrides for superspaces'>
	self subclassResponsibility
    ]

    values [
	"Answer a Bag containing the values of the receiver"

	<category: 'overrides for superspaces'>
	| aBag value |
	aBag := Bag new: tally.
	1 to: self primSize
	    do: 
		[:index | 
		value := self primAt: index.
		value isNil ifFalse: [aBag add: value value]].
	^aBag
    ]

    addSubspace: aSymbol [
	"Create a namespace named aSymbol, add it to the receiver's
	 subspaces, and answer it."

	<category: 'namespace hierarchy'>
	^Namespace primNew: self name: aSymbol
    ]

    allSubassociationsDo: aBlock [
	"Invokes aBlock once for every association in each of the receiver's
	 subspaces."

	<category: 'namespace hierarchy'>
	self allSubspacesDo: [:subspace | subspace associationsDo: aBlock]
    ]

    allSubspacesDo: aBlock [
	"Invokes aBlock for all subspaces, both direct and indirect."

	<category: 'namespace hierarchy'>
	self subspaces notNil 
	    ifTrue: 
		[self subspaces do: 
			[:space | 
			aBlock value: space.
			space allSubspacesDo: aBlock]]
    ]

    allSubspaces [
	"Answer the direct and indirect subspaces of the receiver in a Set"

	<category: 'namespace hierarchy'>
	| aSet |
	aSet := Set new.
	self allSubspacesDo: [:subspace | aSet add: subspace].
	^aSet
    ]

    allSuperspacesDo: aBlock [
	"Evaluate aBlock once for each of the receiver's superspaces"

	<category: 'namespace hierarchy'>
	| space |
	space := self.
	
	[space := space superspace.
	space notNil] whileTrue: [aBlock value: space]
    ]

    includesClassNamed: aString [
	"Answer whether the receiver or any of its superspaces include the
	 given class -- note that this method (unlike #includesKey:) does not
	 require aString to be interned and (unlike #includesGlobalNamed:) only
	 returns true if the global is a class object."

	<category: 'namespace hierarchy'>
	| possibleClass |
	possibleClass := Symbol hasInterned: aString
		    ifTrue: [:aSymbol | self at: aSymbol ifAbsent: [nil]].
	^possibleClass isClass
    ]

    includesGlobalNamed: aString [
	"Answer whether the receiver or any of its superspaces include the
	 given key -- note that this method (unlike #includesKey:) does not
	 require aString to be interned but (unlike #includesClassNamed:)
	 returns true even if the global is not a class object."

	<category: 'namespace hierarchy'>
	Symbol hasInterned: aString
	    ifTrue: [:aSymbol | self at: aSymbol ifPresent: [:value | ^true]].
	^false
    ]

    removeSubspace: aSymbol [
	"Remove my subspace named aSymbol from the hierarchy."

	<category: 'namespace hierarchy'>
	| spaceName |
	spaceName := aSymbol asGlobalKey.	"as with primNew:name:"
	self subspaces remove: (self hereAt: spaceName)
	    ifAbsent: 
		[SystemExceptions.InvalidValue signalOn: aSymbol
		    reason: 'aSymbol must name a subspace'].
	^self removeKey: spaceName
    ]

    selectSubspaces: aBlock [
	"Return a Set of subspaces of the receiver satisfying aBlock."

	<category: 'namespace hierarchy'>
	| aSet |
	aSet := Set new.
	self 
	    allSubspacesDo: [:subspace | (aBlock value: subspace) ifTrue: [aSet add: subspace]].
	^aSet
    ]

    selectSuperspaces: aBlock [
	"Return a Set of superspaces of the receiver satisfying aBlock."

	<category: 'namespace hierarchy'>
	| aSet |
	aSet := Set new.
	self 
	    allSuperspacesDo: [:superspace | (aBlock value: superspace) ifTrue: [aSet add: superspace]].
	^aSet
    ]

    siblings [
	"Answer all the other children of the same namespace as the receiver."

	<category: 'namespace hierarchy'>
	self subclassResponsibility
    ]

    siblingsDo: aBlock [
	"Evaluate aBlock once for each of the other root namespaces,
	 passing the namespace as a parameter."

	<category: 'namespace hierarchy'>
	self subclassResponsibility
    ]

    superspace [
	"Answer the receiver's superspace."

	<category: 'namespace hierarchy'>
	^environment
    ]

    superspace: aNamespace [
	"Set the superspace of the receiver to be 'aNamespace'.  Also
	 adds the receiver as a subspace of it."

	<category: 'namespace hierarchy'>
	| oldSuperspace newSuperspace root |
	oldSuperspace := self superspace.
	newSuperspace := aNamespace.
	oldSuperspace == newSuperspace ifTrue: [^self].	"don't need to change anything"
	oldSuperspace isNil 
	    ifTrue: 
		[oldSuperspace := Smalltalk.
		self become: ((Namespace basicNew: self primSize) copyAllFrom: self)]
	    ifFalse: [oldSuperspace subspaces remove: self].
	newSuperspace isNil 
	    ifTrue: 
		[newSuperspace := Smalltalk.
		self 
		    become: ((AbstractNamespace basicNew: self primSize) copyAllFrom: self)]
	    ifFalse: [aNamespace subspaces add: self].
	environment := aNamespace.
	newSuperspace add: (oldSuperspace remove: self name asGlobalKey -> nil).
	self do: 
		[:each | 
		each isClass 
		    ifTrue: 
			[each compileAll.
			each class compileAll]].
	self allSubassociationsDo: 
		[:assoc | 
		assoc value isClass 
		    ifTrue: 
			[assoc value compileAll.
			assoc value class compileAll]]
    ]

    subspaces [
	"Answer the receiver's direct subspaces"

	<category: 'namespace hierarchy'>
	subspaces isNil ifTrue: [subspaces := IdentitySet new].
	^subspaces
    ]

    subspacesDo: aBlock [
	"Invokes aBlock for all direct subspaces."

	<category: 'namespace hierarchy'>
	self subspaces do: aBlock
    ]

    withAllSubspaces [
	"Answer a Set containing the receiver together with its direct and
	 indirect subspaces"

	<category: 'namespace hierarchy'>
	| aSet |
	aSet := Set with: self.
	aSet addAll: self allSubspaces.
	^aSet
    ]

    withAllSubspacesDo: aBlock [
	"Invokes aBlock for the receiver and all subclasses, both direct
	 and indirect."

	<category: 'namespace hierarchy'>
	aBlock value: self.
	self subspaces do: 
		[:subspace | 
		aBlock value: subspace.
		subspace allSubspacesDo: aBlock]
    ]

    nameIn: aNamespace [
	"Answer Smalltalk code compiling to the receiver when the current
	 namespace is aNamespace"

	<category: 'printing'>
	self subclassResponsibility
    ]

    name [
	"Answer the receiver's name"

	<category: 'printing'>
	^name
    ]

    name: aSymbol [
	"Change the receiver's name to aSymbol"

	<category: 'printing'>
	name := aSymbol
    ]

    printOn: aStream [
	"Print a representation of the receiver"

	<category: 'printing'>
	aStream nextPutAll: self name
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver"

	<category: 'printing'>
	self subclassResponsibility
    ]

    setSuperspace: newSuperspace [
	<category: 'private'>
	self environment: newSuperspace.
	self environment subspaces add: self
    ]

    setSubspaces: newSubspaces [
	<category: 'private'>
	subspaces := newSubspaces
    ]

    isNamespace [
	<category: 'testing'>
	^true
    ]

    isSmalltalk [
	<category: 'testing'>
	^false
    ]
]

