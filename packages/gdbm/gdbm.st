"======================================================================
|
|   Smalltalk wrapper to GDBM
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2001,2007 Free Software Foundation, Inc.
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



Object subclass: Database [
    | gdbm |
    
    <category: 'Examples-Modules'>
    <comment: nil>

    Database class >> read: fileName blockSize: size mode: modeInt [
	<category: 'opening'>
	^self new 
	    open: fileName
	    blockSize: size
	    flags: 0
	    mode: modeInt
    ]

    Database class >> write: fileName blockSize: size mode: modeInt [
	<category: 'opening'>
	^self new 
	    open: fileName
	    blockSize: size
	    flags: 1
	    mode: modeInt
    ]

    Database class >> writeCreate: fileName blockSize: size mode: modeInt [
	<category: 'opening'>
	^self new 
	    open: fileName
	    blockSize: size
	    flags: 2
	    mode: modeInt
    ]

    Database class >> new: fileName blockSize: size mode: modeInt [
	<category: 'opening'>
	^self new 
	    open: fileName
	    blockSize: size
	    flags: 3
	    mode: modeInt
    ]

    open: fileName blockSize: size flags: flags mode: modeInt [
	<category: 'opening'>
	self addToBeFinalized.
	gdbm := GDBM 
		    open: fileName
		    blockSize: size
		    flags: flags
		    mode: modeInt
		    fatalFunc: nil
    ]

    close [
	<category: 'closing'>
	gdbm close.
	gdbm := nil
    ]

    finalize [
	<category: 'closing'>
	gdbm isNil ifFalse: [self close]
    ]

    keyDatum: key [
	<category: 'accessing'>
	^DatumStruct fromString: key
    ]

    valueDatum: value [
	<category: 'accessing'>
	^DatumStruct fromString: value
    ]

    getKey: key [
	<category: 'accessing'>
	^key asString
    ]

    getValue: value [
	<category: 'accessing'>
	^value asString
    ]

    at: key [
	<category: 'accessing'>
	^self at: key ifAbsent: [self error: 'key not found']
    ]

    at: key ifAbsent: aBlock [
	<category: 'accessing'>
	| value datum |
	datum := self keyDatum: key.
	value := gdbm at: datum.
	^
	[value dPtr value isNil 
	    ifTrue: [aBlock value]
	    ifFalse: [self getValue: value]] 
		ensure: 
		    [value free.
		    datum free]
    ]

    at: key put: value [
	<category: 'accessing'>
	| datumValue datumKey |
	datumKey := self keyDatum: key.
	
	[datumValue := self valueDatum: value.
	gdbm 
	    at: datumKey
	    put: datumValue
	    flag: 1.
	datumValue free] 
		ensure: [datumKey free].
	^value
    ]

    includesKey: key [
	<category: 'accessing'>
	| value datum |
	datum := self keyDatum: key.
	value := gdbm at: datum.
	^[value dPtr value notNil] ensure: 
		[value free.
		datum free]
    ]

    removeKey: key [
	<category: 'accessing'>
	^self removeKey: key ifAbsent: [self error: 'key not found']
    ]

    removeKey: key ifAbsent: aBlock [
	<category: 'accessing'>
	| datumKey present |
	datumKey := self keyDatum: key.
	present := (gdbm removeKey: datumKey) == 0.
	datumKey free.
	^present ifTrue: [aBlock value] ifFalse: [key]
    ]

    reorganize [
	<category: 'database operations'>
	gdbm reorganize
    ]

    first [
	<category: 'enumerating'>
	| datumKey result |
	datumKey := gdbm firstKey.
	^[self getKey: datumKey] ensure: [datumKey free]
    ]

    keysAndValuesDo: aBlock [
	<category: 'enumerating'>
	| item value newItem |
	item := gdbm firstKey.
	
	[[item dPtr value notNil] whileTrue: 
		[value := gdbm at: item.
		[aBlock value: (self getKey: item) value: (self getValue: value)] 
		    ensure: [value free].
		newItem := gdbm nextKey: item.
		item free.
		item := newItem]] 
		ensure: [item free]
    ]

    keysDo: aBlock [
	<category: 'enumerating'>
	| item newItem |
	item := gdbm firstKey.
	
	[[item dPtr value notNil] whileTrue: 
		[aBlock value: (self getKey: item).
		newItem := gdbm nextKey: item.
		item free.
		item := newItem]] 
		ensure: [item free]
    ]

    after: key [
	<category: 'enumerating'>
	| datumKey datumNext result |
	datumKey := self keyDatum: key.
	datumNext := gdbm nextKey: datumKey.
	^[datumNext dPtr value isNil ifTrue: [nil] ifFalse: [self getKey: datumNext]] 
	    ensure: 
		[datumNext free.
		datumKey free]
    ]
]

