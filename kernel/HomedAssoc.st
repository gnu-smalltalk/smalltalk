"======================================================================
|
|   HomedAssociation Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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



Association subclass: HomedAssociation [
    | environment |
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent know about their parent namespace, which
is of use when implementing weak collections and finalizations.'>

    HomedAssociation class >> key: aKey value: aValue environment: aNamespace [
	"Answer a new association with the given key and value"

	<category: 'basic'>
	^(self key: aKey value: aValue) environment: aNamespace
    ]

    environment [
	"Answer the namespace in which I live."

	<category: 'accessing'>
	^environment
    ]

    environment: aNamespace [
	"Set the namespace in which I live to be aNamespace."

	<category: 'accessing'>
	environment := aNamespace
    ]

    storeOn: aStream [
	"Put on aStream some Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream nextPut: $(.
	aStream store: self class.
	aStream nextPutAll: ' key: '.
	self key storeOn: aStream.
	aStream nextPutAll: ' value: '.
	self value storeOn: aStream.
	aStream nextPutAll: ' environment: '.
	self environment storeOn: aStream.
	aStream nextPut: $)
    ]

    mourn [
	"This message is sent to the receiver when the object is made ephemeron
	 (which is common when HomedAssociations are used by a WeakKeyDictionary
	 or a WeakSet).  The mourning of the object's key is first of all demanded
	 to the environment (which will likely remove the object from itself), and
	 then performed as usual by clearing the key and value fields."

	<category: 'finalization'>
	self environment mourn: self.
	super mourn
    ]
]

