"======================================================================
|
|   DeferredVariableBinding Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



LookupKey subclass: DeferredVariableBinding [
    | class defaultDictionary association path |
    
    <category: 'Language-Data types'>
    <comment: 'I represent a binding to a variable that is not tied to a particular
dictionary until the first access.  Then, lookup rules for global variables
in the scope of a given class are used.'>

    DeferredVariableBinding class >> path: anArray class: aClass defaultDictionary: aDictionary [
	"As with #key:class:defaultDictionary:, but accepting an array
	 of symbols, representing a namespace path, instead."
	<category: 'basic'>
	^(self key: anArray first)
	    class: aClass;
	    defaultDictionary: aDictionary;
	    path: anArray allButFirst;
	    yourself
    ]

    DeferredVariableBinding class >> key: aSymbol class: aClass defaultDictionary: aDictionary [
	"Answer a binding that will look up aSymbol as a variable in
	 aClass's environment at first access.  See #resolveBinding's
	 comment for aDictionary's meaning."
	<category: 'basic'>
	^(self key: aSymbol)
	    class: aClass;
	    defaultDictionary: aDictionary;
	    yourself
    ]

    value [
	"Answer a new instance of the receiver with the given key and value"

	<category: 'basic'>
	association isNil 
	    ifTrue: [association := self resolvePathFrom: self resolveBinding].
	^association value
    ]

    value: anObject [
	"Answer a new instance of the receiver with the given key and value"

	<category: 'basic'>
	association isNil 
	    ifTrue: [association := self resolvePathFrom: self resolveBinding].
	association value: anObject
    ]

    path [
	"Answer the path followed after resolving the first key."

	<category: 'basic'>
	^path
    ]

    class: aClass [
	<category: 'private'>
	class := aClass
    ]

    defaultDictionary: aDictionary [
	<category: 'private'>
	defaultDictionary := aDictionary
    ]

    path: anArray [
	<category: 'private'>
	path := anArray isEmpty ifTrue: [nil] ifFalse: [anArray]
    ]

    resolvePathFrom: assoc [
	"Given the resolution of the first key, resolve the rest of the path.
	 The final element might be put in Undeclared, the ones in the middle
	 instead must exist."

	<category: 'private'>
	| pathAssoc |
	path isNil ifTrue: [^assoc].
	pathAssoc := assoc.
	1 to: path size - 1
	    do: [:each | pathAssoc := pathAssoc value associationAt: (path at: each)].
	^pathAssoc value associationAt: path last
	    ifAbsent: 
		[Undeclared
		    at: path last put: nil;
		    associationAt: path last]
    ]

    resolveBinding [
	"Look for a pool dictionary of class that includes the key.  If not found,
	 add the variable to the defaultDictionary.  If already bound, reuse the
	 bound that was found on the previous lookup."

	<category: 'private'>
	"See if a previous access has created the binding."

	| assoc |
	assoc := defaultDictionary associationAt: self key ifAbsent: [nil].
	assoc isNil ifFalse: [^assoc].

	"Look for the binding in the class environment."
	class allSharedPoolDictionariesDo: 
		[:env | 
		assoc := env hereAssociationAt: self key ifAbsent: [nil].
		assoc isNil ifFalse: [^assoc]].

	"Create it as a temporary."
	defaultDictionary at: self key ifAbsentPut: [nil].
	^defaultDictionary associationAt: self key
    ]

    printOn: aStream [
	"Put on aStream some Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream nextPut: ${.
	aStream nextPutAll: self key.
	self path isNil 
	    ifFalse: 
		[self path do: 
			[:each | 
			aStream
			    nextPut: $.;
			    nextPutAll: each]].
	aStream nextPut: $}
    ]

    storeOn: aStream [
	"Put on aStream some Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream nextPut: $#.
	self printOn: aStream
    ]
]

