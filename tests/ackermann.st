"======================================================================
|
|   Benchmark for message sending and integer ops
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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Integer extend [
    ack: n [
        self = 0 ifTrue: [ ^n + 1 ].
        n = 0 ifTrue: [ ^self - 1 ack: 1 ].
        ^self - 1 ack: (self ack: n - 1)
    ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 4 ]
	ifFalse: [ Smalltalk arguments first asInteger ].
	
    ('Ack(3,%1): %2' bindWith: n with: (3 ack: n)) displayNl

]
