"======================================================================
|
|   Benchmark for object instantiation
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


ValueHolder subclass: NthValueHolder [
    | counter maxCounter |
	
    ValueHolder >> activate [ self value: self value not ]

    maxCounter: anInteger [
	maxCounter := anInteger
    ]

    value: anObject [
	super value: anObject.
	counter := 0
    ]

    activate [
	(counter := counter + 1) >= maxCounter
		ifTrue: [ super activate ]
    ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 1 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

    val := true.
    toggle := ValueHolder with: val.
    5 timesRepeat: [ toggle activate value printNl ].
    n timesRepeat: [ toggle := ValueHolder with: true ].

    Transcript nl.

    val := true.
    ntoggle := NthValueHolder with: val.
    ntoggle maxCounter: 3.
    8 timesRepeat: [ ntoggle activate value printNl ].
    n timesRepeat: [ (ntoggle := NthValueHolder with: true) maxCounter: 3 ]
]
