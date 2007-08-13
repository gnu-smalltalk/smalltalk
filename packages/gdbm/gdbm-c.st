"======================================================================
|
|   GDBM declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2005 Free Software Foundation, Inc.
| Written by Steve Byrne.
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



CObject variableWordSubclass: #GDBM
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Modules'
!
    
CStruct subclass: #DatumStruct
	declaration: #(		"typedef struct {	"
	    (#dPtr (#ptr #char))"	char *dptr;	"
	    (#dSize #int)	"	int   dsize;	"
	)			"      } datum;		"
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-GDBM'
!


!DatumStruct class methodsFor: 'instance creation'!

fromString: aString
    | obj strObj len |
    obj := self new.
    len := aString size.
    obj dSize value: len.
    obj dPtr value: (aString asCData: CCharType).
    obj addToBeFinalized.
    ^obj
! !


!DatumStruct methodsFor: 'accessing'!

asString
    | len ptr str |
    len := self dSize value.
    ptr := self dPtr value.
    str := String new: len.
    1 to: len do: 
	[ :i | str at: i put: (ptr at: i - 1) ].
    ^str
!

free
    self removeToBeFinalized.
    self dPtr value free.
    super free
! !


!GDBM class methodsFor: 'C call-outs'!

open: fileName blockSize: size flags: flags
    mode: modeInt fatalFunc: funcAddr

    "GDBM_FILE gdbm_open(name, block_size, flags, mode, fatal_func);"
    <cCall: 'gdbm_open' returning: #{GDBM}
	args: #(#string #int #int #int #cObject)>! !

!GDBM methodsFor: 'C call-outs'!

close
    "void gdbm_close(dbf);"
    <cCall: 'gdbm_close' returning: #int args: #(#self)>
!

at: key put: value flag: aFlag
    "int gdbm_store(dbf, key, content, flag);"
    <cCall: 'gdbm_store' returning: #int args: #(#self #cObject #cObject #int)>
!

at: key
    "datum gdbm_fetch(dbf, key);"
    <cCall: 'gdbm_fetch' returning: #{DatumStruct} args: #(#self #cObject)>
!

removeKey: key
    "int gdbm_delete(dbf, key);"
    <cCall: 'gdbm_delete' returning: #long args: #(#self #cObject)>
!

firstKey
    "datum gdbm_firstkey(dbf);"
    <cCall: 'gdbm_firstkey' returning: #{DatumStruct} args: #(#self)>
!

nextKey: afterDatum
    "datum gdbm_nextkey(dbf, key);"
    <cCall: 'gdbm_nextkey' returning: #{DatumStruct} args: #(#self #cObject)>
!

reorganize
    "int gdbm_reorganize(dbf);"
    <cCall: 'gdbm_reorganize' returning: #int args: #(#self)>
! !

