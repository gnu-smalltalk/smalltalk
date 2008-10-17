"======================================================================
|
|   Benchmark for OrderedCollections
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003, 2007, 2008  Free Software Foundation.
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

SmallInteger extend [

    testLists [
	| li1 li2 li3 |
	li1 := (1 to: self) asOrderedCollection.
	li2 := li1 copy.
	li3 := OrderedCollection new.
	[ li2 isEmpty ] whileFalse: [
		li3 addLast: li2 removeFirst
	].
	[ li3 isEmpty ] whileFalse: [
		li2 addLast: li3 removeLast
	].
	li1 := li1 reverse.
	li1 size = self ifFalse: [ self frob ].
	li1 = li2 ifFalse: [ self frob ].
	^li1 size
    ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 1 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

    n timesRepeat: [ result := 10000 testLists ].
    result displayNl
]
