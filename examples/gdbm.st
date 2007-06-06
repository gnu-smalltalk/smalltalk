"======================================================================
|
|   Smalltalk wrapper to GDBM
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2001 Free Software Foundation, Inc.
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



Object subclass: #Database
	instanceVariableNames: 'gdbm'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Modules'
!
    
"     GDBM_FILE gdbm_open(name, block_size, flags, mode, fatal_func);	"

!Database class methodsFor: 'opening'!

read: fileName blockSize: size mode: modeInt
    ^self new
        open: fileName blockSize: size flags: 0 mode: modeInt
!

write: fileName blockSize: size mode: modeInt
    ^self new
        open: fileName blockSize: size flags: 1 mode: modeInt
!

writeCreate: fileName blockSize: size mode: modeInt
    ^self new
        open: fileName blockSize: size flags: 2 mode: modeInt
!

new: fileName blockSize: size mode: modeInt
    ^self new
        open: fileName blockSize: size flags: 3 mode: modeInt
! !

!Database methodsFor: 'opening'!

open: fileName blockSize: size flags: flags mode: modeInt
    self addToBeFinalized.
    gdbm := GDBM
	open: fileName
	blockSize: size
	flags: flags
	mode: modeInt
	fatalFunc: nil
! !

!Database methodsFor: 'closing'!

close
    gdbm close.
    gdbm := nil
!

finalize
    gdbm isNil ifFalse: [ self close ]
! !

!Database methodsFor: 'accessing'!

keyDatum: key
    ^DatumStruct fromString: key
!

valueDatum: value
    ^DatumStruct fromString: value
!

getKey: key
    ^key asString
!
 
getValue: value
    ^value asString
! !

!Database methodsFor: 'accessing'!

at: key
    ^self at: key ifAbsent: [ self error: 'key not found' ]
!

at: key ifAbsent: aBlock
    | value datum |
    datum := self keyDatum: key.
    value := gdbm at: datum.
    ^[
	value dPtr value isNil
	    ifTrue: [ aBlock value ]
	    ifFalse: [ self getValue: value ].
    ] ensure: [
	value free.
	datum free
    ]
!

at: key put: value
    | datumValue datumKey |
    datumKey := self keyDatum: key.
    [
	datumValue := self valueDatum: value.
	gdbm at: datumKey put: datumValue flag: 1.
	datumValue free.
    ] ensure: [
	datumKey free.
    ].
    ^value
!

includesKey: key
    | value datum |
    datum := self keyDatum: key.
    value := gdbm at: datum.
    ^[ value dPtr value notNil ] ensure: [
	value free.
	datum free
    ]
!

removeKey: key
    ^self removeKey: key ifAbsent: [ self error: 'key not found' ]
!

removeKey: key ifAbsent: aBlock
    | datumKey present |
    datumKey := self keyDatum: key.
    present := (gdbm removeKey: datumKey) == 0.
    datumKey free.
    ^present
	ifTrue: [ aBlock value ]
	ifFalse: [ key ]
! !

!Database methodsFor: 'database operations'!

reorganize
    gdbm reorganize
! !

!Database methodsFor: 'enumerating'!

first
    | datumKey result |
    datumKey := gdbm firstKey.
    ^[ self getKey: datumKey ] ensure: [ datumKey free ]
!

keysAndValuesDo: aBlock
    | item value newItem |
    item := gdbm firstKey.
    [[ item dPtr value notNil ] 
	whileTrue: [
	    value := gdbm at: item.
	    [ aBlock
		value: (self getKey: item)
		value: (self getValue: value)
	    ] ensure: [
		value free
	    ].

	    newItem := gdbm nextKey: item.
	    item free.
	    item := newItem ].
    ] ensure: [
        item free
    ]
!

keysDo: aBlock
    | item newItem |
    item := gdbm firstKey.
    [
	[ item dPtr value notNil ] whileTrue: [
	    aBlock value: (self getKey: item).
	    newItem := gdbm nextKey: item.
	    item free.
	    item := newItem ].
    ] ensure: [
	item free
    ]
!

after: key
    | datumKey datumNext result |
    datumKey := self keyDatum: key.
    datumNext := gdbm nextKey: datumKey.

    ^[
	datumNext dPtr value isNil
	    ifTrue: [ nil ]
	    ifFalse: [ self getKey: datumNext ]
    ] ensure: [
	datumNext free.
	datumKey free
    ]
! !


