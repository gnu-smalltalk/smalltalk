"======================================================================
|
|   Benchmark for message sending and integer ops
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

Integer extend [
    ack: n [
        self = 0 ifTrue: [ ^n + 1 ].
        n = 0 ifTrue: [ ^self - 1 ack: 1 ].
        ^self - 1 ack: (self ack: n - 1)
    ]

    ackIt: nn [
	| n |
	^[
	    | m stack |
	    m := self. n := nn.
	    stack := OrderedCollection new.
	    [ m = 0
		ifTrue: [
		    n := n + 1.
		    m := stack removeLast ]
		ifFalse: [
		    n = 0
			ifTrue: [
			    m := m - 1.
			    n := 1 ]
			ifFalse: [
			    stack addLast: m - 1.
			    n := n - 1 ] ]
	    ] repeat
	] on: Error do: [ :ex | ex return: n ]
    ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 4 ]
	ifFalse: [ Smalltalk arguments first asInteger ].
	
    ('Ack(3,%1): %2' % { n. (3 ack: n) }) displayNl.
]
