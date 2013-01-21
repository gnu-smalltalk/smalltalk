"======================================================================
|
|   RootNamespace Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2007
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



AbstractNamespace subclass: RootNamespace [
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'I am a special form of dictionary.  Classes hold on
an instance of me; it is called their `environment''. '>

    RootNamespace class >> new: spaceName [
	"Create a new root namespace with the given name, and add to Smalltalk
	 a key that references it."

	<category: 'instance creation'>
	^Smalltalk at: spaceName asGlobalKey
	    put: ((super new: 24) name: spaceName asSymbol; yourself)
    ]

    inheritedKeys [
	"Answer a Set of all the keys in the receiver and its superspaces"

	<category: 'overrides for superspaces'>
	^Set new
    ]

    set: key to: newValue ifAbsent: aBlock [
	"Assign newValue to the variable named as specified by `key'.
	 This method won't define a new variable; instead if the key
	 is not found it will search in superspaces and evaluate
	 aBlock if it is not found. Answer newValue."

	<category: 'overrides for superspaces'>
	| index |
	index := self findIndexOrNil: key.
	index isNil ifTrue: [^aBlock value].
	(self primAt: index) value: newValue.
	^newValue
    ]

    siblings [
	"Answer all the other root namespaces"

	<category: 'namespace hierarchy'>
	^(RootNamespace allInstances asSet)
	    remove: self;
	    yourself
    ]

    siblingsDo: aBlock [
	"Evaluate aBlock once for each of the other root namespaces,
	 passing the namespace as a parameter."

	<category: 'namespace hierarchy'>
	RootNamespace allInstances asSet 
	    do: [:space | space == self ifFalse: [aBlock value: space]]
    ]

    printOn: aStream in: aNamespace [
	"Print on aStream some Smalltalk code compiling to the receiver
	 when the current namespace is aNamespace"

	<category: 'printing'>
	| reference |
	reference := aNamespace at: self name asGlobalKey ifAbsent: [nil].
	reference == self ifFalse: [aStream nextPutAll: 'Smalltalk.'].
	aStream nextPutAll: self name
    ]

    nameIn: aNamespace [
	"Answer Smalltalk code compiling to the receiver when the current
	 namespace is aNamespace"

	<category: 'printing'>
	| reference |
	reference := aNamespace at: self name asGlobalKey ifAbsent: [nil].
	^reference == self 
	    ifTrue: [self name asString]
	    ifFalse: ['Smalltalk.' , self name]
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver"

	<category: 'printing'>
	self name isNil ifTrue: [self error: 'cannot print unnamed namespace'].
	aStream
	    nextPutAll: 'Smalltalk.';
	    nextPutAll: self name
    ]
]

