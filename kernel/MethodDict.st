"======================================================================
|
|   MethodDictionary Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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





IdentityDictionary subclass: MethodDictionary [
    | mutex |

    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'I am similar to an IdentityDictionary, except that removal and
rehashing operations inside my instances look atomic to the
interpreter.'>

    mutex [
       <category: 'initialization'>

       mutex isNil ifFalse: [ ^ mutex ].
       ^ [ mutex isNil ifTrue: [ mutex := Semaphore forMutualExclusion ].
	   mutex ] valueWithoutPreemption
    ]

    at: key put: value [
       "Store value as associated to the given key"

       <category: 'adding'>
       self mutex critical: [
           | index |
           index := self findIndex: key.
           (self primAt: index) isNil 
               ifTrue: 
                   [self incrementTally ifTrue: [index := self findIndex: key].
                   self primAt: index put: key]
               ifFalse: [(self valueAt: index) discardTranslation].
           self valueAt: index put: value.
           Behavior flushCache].
       ^value
    ]

    remove: anAssociation [
	"Remove anAssociation's key from the dictionary"

	"The interpreter might be using this MethodDictionary while
	 this method is running!!  Therefore we perform the removal
	 in a copy, and then atomically become that copy"


       <category: 'removing'>
       | copy result |
       self mutex critical: [
           (self includesKey: anAssociation key) 
               ifFalse: [SystemExceptions.NotFound signalOn: anAssociation key what: 'key'].
           copy := self copy.
           result := copy dangerouslyRemove: anAssociation.
           self become: copy.
           Behavior flushCache].
       ^result
    ]

    removeKey: anElement ifAbsent: aBlock [
	"Remove the passed key from the dictionary, answer the result of
	 evaluating aBlock if it is not found"

	"The interpreter might be using this MethodDictionary while
	 this method is running!!  Therefore we perform the removal
	 in a copy, and then atomically become that copy"


       <category: 'removing'>
       | copy result |
       self mutex critical: [
           (self includesKey: anElement) ifFalse: [^aBlock value].
           copy := self copy.
           result := copy dangerouslyRemoveKey: anElement.
           self become: copy.
           Behavior flushCache].
       ^result
    ]

    rehash [
	"Rehash the receiver"

	"The interpreter might be using this MethodDictionary while
	 this method is running!!  Therefore we create a copy that
	 has correct hashing (it is built on the fly), then atomically
        become that copy"

       <category: 'rehashing'>
       self mutex critical: [ self growBy: 0 ]
    ]

    dangerouslyRemove: anAssociation [
	"This is not really dangerous.  But if normal removal
	 were done WHILE a MethodDictionary were being used, the
	 system might crash.  So instead we make a copy, then do
	 this operation (which is NOT dangerous in a copy that is
	 not being used), and then use the copy after the removal."

	<category: 'private methods'>
	| association |
	association := super remove: anAssociation.
	association value discardTranslation.
	^association
    ]

    dangerouslyRemoveKey: anElement [
	"This is not really dangerous.  But if normal removal
	 were done WHILE a MethodDictionary were being used, the
	 system might crash.  So instead we make a copy, then do
	 this operation (which is NOT dangerous in a copy that is
	 not being used), and then use the copy after the removal."

	<category: 'private methods'>
	| value |
	value := super removeKey: anElement
		    ifAbsent: [self error: 'synchronization problem?'].
	value discardTranslation.
	^value
    ]
]

