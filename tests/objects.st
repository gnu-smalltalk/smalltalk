"======================================================================
|
|   Test special objects
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1999, 2000, 2001, 2002, 2007, 2008, 2009 Free Software Foundation.
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

Object subclass: ObjectsTest [
    | name survive |

    Messages := nil.

    ObjectsTest class [
	testCompaction [
	    Messages := SortedCollection new.
	    ObjectMemory compact.
	    Messages do: [ :each | each displayNl ]
	]

	testFinalize [
	    | test |
	    self new name: 'a' survive: false.
	    self new name: 'b' survive: true.
	    self new name: 'c' survive: false.
	    self testCompaction.
	    self testCompaction.
	    self testCompaction.
	]

	testWeak [
	    | a |
	    a := Array new: 1.
	    a makeWeak.
	    a at: 1 put: Object new.
	    ObjectMemory compact.
	    ^(a at: 1) isNil
	]
    ]

    name: aString survive: aBoolean [
        name := aString.
        survive := aBoolean.
        self addToBeFinalized
    ]

    finalize [
        survive ifTrue: [
            Messages add: name, ' finalized, surviving'.
            survive := false.
            self addToBeFinalized.
	    ^self
        ].
        Messages add: name, ' finalized'
    ]
]

Eval [ ObjectsTest testFinalize ]
Eval [ ObjectsTest testWeak ]


Eval [

    | a b |
    a := WeakArray new: 5.
    a at: 1 put: 'abc'.
    a at: 2 put: Object new.
    a at: 4 put: nil.
    a at: 5 put: 1.
    b := a copy.
    a printNl.
    b printNl.
    ObjectMemory compact.
    a printNl.
    b printNl.
    ((1 to: 5) collect: [ :each | a isAlive: each ]) printNl.
    1 to: 5 do: [ :index | a clearGCFlag: index ].
    ((1 to: 5) collect: [ :each | a isAlive: each ]) printNl.
    ((1 to: 5) collect: [ :each | b isAlive: each ]) printNl

]


"Test lightweight class"

Eval [
 	Test := Behavior new.
	Transcript nextPutAll: 'New instance of Behavior created'; nl.

 	Test superclass: Object.
	Transcript nextPutAll: 'Superclass assigned'; nl.

 	Test compile: 'new [ ^super new ]'.
	Transcript nextPutAll: 'First method compiled'; nl.

 	Test compile: 'printTestMessage	[ ''test message'' printNl ]'.
	Transcript nextPutAll: 'Second method compiled'; nl.

 	t := Test new.
	Transcript nextPutAll: 'Instance created'; nl.

 	t printTestMessage.
 	t printNl.
	Transcript nextPutAll: 'Well it seems to work fine'; nl
]

"Test becomeForward"

Eval [
    a := Behavior new superclass: Object.
    a compile: 'foo [ ^1 ]'.
    b := Behavior new superclass: Object.
    b compile: 'foo [ ^2 ]'.
    o := a new.
    a become: b.
    o foo
]

Eval [
    "This uses global (Association) variables."
    a := 'a' copy.
    (a becomeForward: 'b') printNl.
    a
]

Eval [
    "This uses local (stack) variables."
    | a b |
    a := Object new.
    b := 5.
    a becomeForward: b.
    a printNl
]
