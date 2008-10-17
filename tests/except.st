"======================================================================
|
|   Benchmark for exception handling
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

Notification subclass: MyException [
    <category: 'testing'>

    MyException class [
	| count |

	count [ ^count ]
	increment [ count := count + 1 ]
	initialize [ count := 0 ]
    ]
]
	
MyException subclass: LoException [ ]
Eval [ LoException initialize ]

MyException subclass: HiException [ ]
Eval [ HiException initialize ]

SmallInteger extend [
    someFunction [
	^self hiFunction
    ]
	
    hiFunction [
	^[ self loFunction ] on: HiException do: [ :ex | ex class increment ]
    ]
	
    loFunction [
	^[ self blowup ] on: LoException do: [ :ex | ex class increment ]
    ]
	
    blowup [
	^(self odd ifTrue: [ HiException ] ifFalse: [ LoException ])
		signal: self
    ]
]

Eval [
    | n |
    n := Smalltalk arguments isEmpty
	    ifTrue: [ 50000 ]
	    ifFalse: [ 1 max: Smalltalk arguments first asInteger ].
    
    1 to: n do: [ :each | each someFunction ].
    ('Exceptions: HI=%1 / LO=%2' % { HiException count. LoException count })
	displayNl
]
