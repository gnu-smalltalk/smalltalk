"======================================================================
|
|   GDBM tests declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



TestCase subclass: GDBMTest [
    
    <comment: nil>
    <category: 'Examples-Modules'>

    data [
	<category: 'creating test files'>
	^
	{'fred' -> 'Fred Flintstone'.
	'wilma' -> 'Wilma Flintstone'}
    ]

    setUp [
	<category: 'creating test files'>
	self cInterfaceSetup.
	self stInterfaceSetup
    ]

    tearDown [
	<category: 'creating test files'>
	(File exists: 'test-c.gdbm') ifTrue: [File remove: 'test-c.gdbm'].
	(File exists: 'test-st.gdbm') ifTrue: [File remove: 'test-st.gdbm']
    ]

    cInterfaceSetup [
	<category: 'creating test files'>
	| database key value |
	(File exists: 'test-c.gdbm') ifTrue: [File remove: 'test-c.gdbm'].
	database := GDBM 
		    open: 'test-c.gdbm'
		    blockSize: 1024
		    flags: 2
		    mode: 438
		    fatalFunc: nil.	"write/create"
	self data do: 
		[:each | 
		key := DatumStruct fromString: each key.
		value := DatumStruct fromString: each value.
		database 
		    at: key
		    put: value
		    flag: 1.	"replace"
		key free.
		value free].
	database close
    ]

    stInterfaceSetup [
	<category: 'creating test files'>
	| database |
	(File exists: 'test-st.gdbm') ifTrue: [File remove: 'test-st.gdbm'].
	database := Database 
		    writeCreate: 'test-st.gdbm'
		    blockSize: 1024
		    mode: 438.
	self data do: [:each | database at: each key put: each value].
	database close
    ]

    doTestCInterfaceAt: name [
	<category: 'testing (low-level)'>
	| database key value |
	database := GDBM 
		    open: name
		    blockSize: 1024
		    flags: 0
		    mode: 438
		    fatalFunc: nil.	"read"
	value := database at: (DatumStruct fromString: 'wilma').
	self assert: value asString = 'Wilma Flintstone'.
	value free.
	value := database at: (DatumStruct fromString: 'barney').
	self assert: value dPtr value isNil.
	self assert: value asString = ''.
	value free.
	database close
    ]

    doTestCInterfaceWalkKeys: name [
	<category: 'testing (low-level)'>
	| database newItem item value result |
	database := GDBM 
		    open: name
		    blockSize: 1024
		    flags: 0
		    mode: 438
		    fatalFunc: nil.	"read"
	result := SortedCollection sortBlock: [:a :b | a key <= b key].
	item := database firstKey.
	[item dPtr value notNil] whileTrue: 
		[value := database at: item.
		result add: item asString -> value asString.
		value free.
		newItem := database nextKey: item.
		item free.
		item := newItem].
	item free.
	database close.
	self assert: (result at: 1) = ('fred' -> 'Fred Flintstone').
	self assert: (result at: 2) = ('wilma' -> 'Wilma Flintstone')
    ]

    doTestCInterfaceAfter: name [
	<category: 'testing (low-level)'>
	| database newItem item value result |
	database := GDBM 
		    open: name
		    blockSize: 1024
		    flags: 0
		    mode: 438
		    fatalFunc: nil.	"read"
	result := OrderedCollection new.
	item := database firstKey.
	[item dPtr value notNil] whileTrue: 
		[result add: item asString -> nil.
		newItem := database nextKey: item.
		result last 
		    value: (newItem dPtr value ifNotNil: [:ignored | newItem asString]).
		item free.
		item := newItem].
	item free.
	database close.
	self assert: (result at: 1) value = (result at: 2) key.
	self assert: (result at: 2) value isNil
    ]

    doTestAt: name [
	<category: 'testing (high-level)'>
	| database |
	database := Database 
		    read: name
		    blockSize: 1024
		    mode: 438.
	self assert: (database at: 'wilma') = 'Wilma Flintstone'.
	self assert: (database at: 'barney' ifAbsent: [nil]) isNil.
	database close
    ]

    doTestKeysAndValuesDo: name [
	<category: 'testing (high-level)'>
	| database newItem item value result |
	database := Database 
		    read: name
		    blockSize: 1024
		    mode: 438.
	result := SortedCollection sortBlock: [:a :b | a key <= b key].
	database keysAndValuesDo: [:item :value | result add: item -> value].
	database close.
	self assert: (result at: 1) = ('fred' -> 'Fred Flintstone').
	self assert: (result at: 2) = ('wilma' -> 'Wilma Flintstone')
    ]

    doTestAfter: name [
	<category: 'testing (high-level)'>
	| database newItem item value result |
	database := Database 
		    read: name
		    blockSize: 1024
		    mode: 438.
	result := OrderedCollection new.
	database 
	    keysAndValuesDo: [:item :value | result add: item -> (database after: item)].
	database close.
	self assert: (result at: 1) value = (result at: 2) key.
	self assert: (result at: 2) value isNil
    ]

    testCInterfaceAt [
	<category: 'testing'>
	self doTestCInterfaceAt: 'test-c.gdbm'.
	self doTestCInterfaceAt: 'test-st.gdbm'
    ]

    testCInterfaceWalkKeys [
	<category: 'testing'>
	self doTestCInterfaceWalkKeys: 'test-c.gdbm'.
	self doTestCInterfaceWalkKeys: 'test-st.gdbm'
    ]

    testCInterfaceAfter [
	<category: 'testing'>
	self doTestCInterfaceAfter: 'test-c.gdbm'.
	self doTestCInterfaceAfter: 'test-st.gdbm'
    ]

    testAt [
	<category: 'testing'>
	self doTestAt: 'test-c.gdbm'.
	self doTestAt: 'test-st.gdbm'
    ]

    testKeysAndValuesDo [
	<category: 'testing'>
	self doTestKeysAndValuesDo: 'test-c.gdbm'.
	self doTestKeysAndValuesDo: 'test-st.gdbm'
    ]

    testAfter [
	<category: 'testing'>
	self doTestAfter: 'test-c.gdbm'.
	self doTestAfter: 'test-st.gdbm'
    ]
]

