"======================================================================
|
|   Benchmark for message sending
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003  Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"

!ValueHolder methodsFor: 'testing'!

activate
    self value: self value not! !

ValueHolder subclass: #NthValueHolder
	instanceVariableNames: 'counter maxCounter'
	classVariableNames: ''
	poolDictionaries: ''
	category: nil!
	
!NthValueHolder methodsFor: 'testing'!

maxCounter: anInteger
	maxCounter := anInteger!

value: anObject
	super value: anObject.
	counter := 0!

activate
	(counter := counter + 1) >= maxCounter
		ifTrue: [ super activate ]! !

| n val toggle ntoggle |
n := Smalltalk arguments isEmpty
	ifTrue: [ 100000 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

val := true.
toggle := ValueHolder with: val.
n timesRepeat: [ val := toggle activate value ].
val displayNl.

val := true.
ntoggle := NthValueHolder with: val.
ntoggle maxCounter: 3.
n timesRepeat: [ val := ntoggle activate value ].
val displayNl! !
