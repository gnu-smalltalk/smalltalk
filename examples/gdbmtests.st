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

TestCase subclass: #GDBMTest
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!GDBMTest methodsFor: 'creating test files'!

data
    ^{ 'fred'->'Fred Flintstone'. 'wilma'->'Wilma Flintstone'}!

setUp
    self cInterfaceSetup.
    self stInterfaceSetup!

tearDown
    (File exists: 'test-c.gdbm') ifTrue: [ File remove: 'test-c.gdbm' ].
    (File exists: 'test-st.gdbm') ifTrue: [ File remove: 'test-st.gdbm' ]!

cInterfaceSetup
    | database key value |
    (File exists: 'test-c.gdbm') ifTrue: [ File remove: 'test-c.gdbm' ].
    database := GDBM open: 'test-c.gdbm' blockSize: 1024 flags: 2 "write/create"
		    mode: 8r666 fatalFunc: nil.

    self data do: [ :each |
        key := DatumStruct fromString: each key.
        value := DatumStruct fromString: each value.
        database at: key put: value flag: 1 "replace".
        key free.
        value free ].

    database close!

stInterfaceSetup
    | database |
    (File exists: 'test-st.gdbm') ifTrue: [ File remove: 'test-st.gdbm' ].
    database := Database writeCreate: 'test-st.gdbm' blockSize: 1024 mode: 8r666.
    self data do: [ :each | database at: each key put: each value ].
    database close
! !

!GDBMTest methodsFor: 'testing (low-level)'!

doTestCInterfaceAt: name
    | database key value |
    database := GDBM open: name blockSize: 1024 flags: 0 "read"
		    mode: 8r666 fatalFunc: nil.

    value := (database at: (DatumStruct fromString: 'wilma')).
    self assert: value asString = 'Wilma Flintstone'.
    value free.

    value := (database at: (DatumStruct fromString: 'barney')).
    self assert: value dPtr value isNil.
    self assert: value asString = ''.
    value free.

    database close.
!

doTestCInterfaceWalkKeys: name
    | database newItem item value result |
    database := GDBM open: name blockSize: 1024 flags: 0 "read"
		     mode: 8r666 fatalFunc: nil.

    result := SortedCollection sortBlock: [ :a :b | a key <= b key ].
    item := database firstKey.
    [ item dPtr value notNil ] 
	whileTrue: [
	    value := database at: item.
	    result add: item asString->value asString.
	    value free.

	    newItem := database nextKey: item.
	    item free.
	    item := newItem ].

    item free.
    database close.
    self assert: (result at: 1) = ('fred'->'Fred Flintstone').
    self assert: (result at: 2) = ('wilma'->'Wilma Flintstone').
!

doTestCInterfaceAfter: name
    | database newItem item value result |
    database := GDBM open: name blockSize: 1024 flags: 0 "read"
                     mode: 8r666 fatalFunc: nil.

    result := OrderedCollection new.
    item := database firstKey.
    [ item dPtr value notNil ] 
        whileTrue: [
            result add: item asString->nil.
            newItem := database nextKey: item.
            result last value: (newItem dPtr value
                 ifNotNil: [ :ignored | newItem asString ]).

            item free.
            item := newItem ].

    item free.
    database close.
    self assert: (result at: 1) value = (result at: 2) key.
    self assert: (result at: 2) value isNil
! !

!GDBMTest methodsFor: 'testing (high-level)'!

doTestAt: name
    | database |
    database := Database read: name blockSize: 1024 mode: 8r666.
    self assert: (database at: 'wilma') = 'Wilma Flintstone'.
    self assert: (database at: 'barney' ifAbsent: [ nil ]) isNil.
    database close.
!

doTestKeysAndValuesDo: name
    | database newItem item value result |
    database := Database read: name blockSize: 1024 mode: 8r666.

    result := SortedCollection sortBlock: [ :a :b | a key <= b key ].
    database keysAndValuesDo: [ :item :value | result add: item->value ].
    database close.

    self assert: (result at: 1) = ('fred'->'Fred Flintstone').
    self assert: (result at: 2) = ('wilma'->'Wilma Flintstone').
!

doTestAfter: name
    | database newItem item value result |
    database := Database read: name blockSize: 1024 mode: 8r666.

    result := OrderedCollection new.
    database keysAndValuesDo: [ :item :value |
	result add: item->(database after: item) ].
    database close.

    self assert: (result at: 1) value = (result at: 2) key.
    self assert: (result at: 2) value isNil
! !

!GDBMTest methodsFor: 'testing'!

testCInterfaceAt
    self doTestCInterfaceAt: 'test-c.gdbm'.
    self doTestCInterfaceAt: 'test-st.gdbm'!

testCInterfaceWalkKeys
    self doTestCInterfaceWalkKeys: 'test-c.gdbm'.
    self doTestCInterfaceWalkKeys: 'test-st.gdbm'!

testCInterfaceAfter
    self doTestCInterfaceAfter: 'test-c.gdbm'.
    self doTestCInterfaceAfter: 'test-st.gdbm'!

testAt
    self doTestAt: 'test-c.gdbm'.
    self doTestAt: 'test-st.gdbm'!

testKeysAndValuesDo
    self doTestKeysAndValuesDo: 'test-c.gdbm'.
    self doTestKeysAndValuesDo: 'test-st.gdbm'!

testAfter
    self doTestAfter: 'test-c.gdbm'.
    self doTestAfter: 'test-st.gdbm'! !
