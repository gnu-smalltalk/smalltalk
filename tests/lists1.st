"======================================================================
|
|   Benchmark for OrderedCollections (2)
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
    test [
        | a b sum |
        b := OrderedCollection new: self.
        a := (1 to: self) asOrderedCollection.
        [ a isEmpty ] whileFalse: [
    	    b addLast: a removeLast ].

        ('%1 %2' % { b at: 1. b at: 2 }) displayNl.

        b := b reverse.
        (b includes: 0) printNl.
        (b includes: self) printNl.

        a := b select: [ :each | each < (self // 2) ].
    
        (a copyFrom: 1 to: (10 min: a size))
    	    do: [ :each | each print ]
	    separatedBy: [ Transcript space ].

        Transcript nl.

        sum := a inject: 0 into: [ :old :each |
	    each < 1000 ifTrue: [ old + each ] ifFalse: [ old ] ].
	
        sum printNl.
        a := a, b.

        ('%1 %2' % { a size. a last }) displayNl
    ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 100000 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

    n test
]
