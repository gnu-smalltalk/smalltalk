"======================================================================
|
|   ProcessEnvironment Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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



Namespace current: Kernel [

LookupKey subclass: ProcessVariable [
    <category: 'Language-Processes'>
    <comment: 'I represent a proxy for a thread-local variable defined
for a process.  Requesting the value will return the thread-local
setting for the current process.'>

    environment [
	<category: 'accessing'>
	^Processor activeProcess
    ]

    value [
	<category: 'accessing'>
	^Processor activeProcess environment at: self key ifAbsent: [ nil ]
    ]

    value: anObject [
	<category: 'accessing'>
	Processor activeProcess environment at: self key put: anObject
    ]
]

]

Object subclass: ProcessEnvironment [
    <category: 'Language-Processes'>
    <comment: 'I represent a proxy for thread-local variables defined for
Smalltalk processes.  Associations requested to me retrieve the thread-local
value for the current process.  For now, I don''t provide the full protocol of
a Dictionary; in particular the iteration protocol is absent.'>

    ProcessEnvironment class [
	| uniqueInstance |

	uniqueInstance [
	    "Return the singleton instance of ProcessEnvironment."
	    <category: 'singleton'>
	    uniqueInstance isNil ifTrue: [ uniqueInstance := self basicNew ].
	    ^uniqueInstance
	]

	new [
	    <category: 'disabled'>
	    self shouldNotImplement
	]
    ]

    add: newObject [
        "Add the newObject association to the receiver"

        <category: 'accessing'>
        ^Processor activeProcess environment add: newObject
    ]

    at: key put: value [
        "Store value as associated to the given key"

        <category: 'accessing'>
        ^Processor activeProcess environment at: key put: value
    ]

    at: key [
        "Answer the value associated to the given key. Return nil if the key
         is not found"

        <category: 'accessing'>
        ^Processor activeProcess environment at: key ifAbsent: [nil]
    ]

    at: key ifAbsent: aBlock [
        "Answer the value associated to the given key, or the result of evaluating
         aBlock if the key is not found"

        <category: 'accessing'>
        ^Processor activeProcess environment at: key ifAbsent: aBlock
    ]

    at: key ifAbsentPut: aBlock [
        "Answer the value associated to the given key, setting it to
	 the result of evaluating aBlock if the key is not found."

        <category: 'accessing'>
        ^Processor activeProcess environment at: key ifAbsentPut: aBlock
    ]

    at: key ifPresent: aBlock [
        "Answer the value associated to the given key, or the result of evaluating
         aBlock if the key is not found"

        <category: 'accessing'>
        ^Processor activeProcess environment at: key ifPresent: aBlock
    ]

    associationAt: key ifAbsent: aBlock [
        "Answer the value associated to the given key, or the result of evaluating
         aBlock if the key is not found"

        <category: 'accessing'>
        ^Kernel.ProcessVariable key: key
    ]

    associationAt: key [
        "Answer the value associated to the given key, or the result of evaluating
         aBlock if the key is not found"

        <category: 'accessing'>
        ^Kernel.ProcessVariable key: key
    ]

    keys [
        "Answer a kind of Set containing the keys of the receiver"

        <category: 'accessing'>
        ^Processor activeProcess environment keys
    ]

    includesKey: key [
        "Answer whether the receiver contains the given key"

        <category: 'dictionary testing'>
        ^Processor activeProcess environment includesKey: key
    ]

    removeAllKeys: keys [
        "Remove all the keys in keys, without raising any errors"

        <category: 'dictionary removing'>
        keys do: [:key | self removeKey: key ifAbsent: []]
    ]

    removeAllKeys: keys ifAbsent: aBlock [
        "Remove all the keys in keys, passing the missing keys as parameters
         to aBlock as they're encountered"

        <category: 'dictionary removing'>
        keys do: [:key | self removeKey: key ifAbsent: [aBlock value: key]]
    ]

    remove: anAssociation [
        "Remove anAssociation's key from the dictionary"

        <category: 'dictionary removing'>
	^Processor activeProcess environment removeKey: anAssociation key
	    ifAbsent: []
    ]

    remove: anAssociation ifAbsent: aBlock [
        "Remove anAssociation's key from the dictionary"

        <category: 'dictionary removing'>
	^Processor activeProcess environment removeKey: anAssociation key
	    ifAbsent: aBlock
    ]

    removeKey: aSymbol [
        "Remove the aSymbol key from the dictionary"

        <category: 'dictionary removing'>
	^Processor activeProcess environment removeKey: aSymbol ifAbsent: []
    ]

    removeKey: aSymbol ifAbsent: aBlock [
        "Remove the aSymbol key from the dictionary"

        <category: 'dictionary removing'>
	^Processor activeProcess environment removeKey: aSymbol ifAbsent: aBlock
    ]
]
