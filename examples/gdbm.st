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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
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
    gdbm isNil ifFalse: [ gdbm close ]
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


!Database class methodsFor: 'testing'!

test
    | database key value |
    database := self writeCreate: 'test.gdbm' blockSize: 1024
		    mode: 8r666.

    database at: 'fred' put: 'Fred Flintstone'.
    database at: 'wilma' put: 'Wilma Flintstone'.
    database close.

    database := self read: 'test.gdbm' blockSize: 1024
		    mode: 8r666.

    (database at: 'wilma') printNl.
    (database at: 'barney' ifAbsent: [ nil ]) printNl.

    database close.
!

test2
    | database newItem item value |
    database := self read: 'test.gdbm' blockSize: 1024
		     mode: 8r666.

    database keysAndValuesDo: [ :item :value |
	Transcript nextPutAll: item;
		nextPutAll: '  ';
		nextPutAll: value;
		nl.
    ].

    database close.
!

test3
    | database newItem item value |
    database := self read: 'test.gdbm' blockSize: 1024
		     mode: 8r666.

    database keysDo: [ :item |
	Transcript nextPutAll: item;
		nextPutAll: '  ';
		display: (database after: item);
		nl.
    ].

    database close.
! !

