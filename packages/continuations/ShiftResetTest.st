"======================================================================
|
|   Delimited continuations tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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






"Mindbending fun."

Object subclass: Monad [
    Monad class >> do: aBlock [
	^[
	    | monad |
	    monad := self new.
	    monad lift: (aBlock cull: monad) ] reset
    ]

    bind: anObject [
	^[ :k | self bind: anObject with: k ] shift
    ]

    bind: anObject with: k [
	self subclassResponsibility
    ]

    lift: anObject [
	self subclassResponsibility
    ]
]

Monad subclass: AbstractAmbMonad [
    Fail := Object new.
    AbstractAmbMonad class >> fail [ ^Fail ]

    oneOf: anArray [ ^self bind: anArray ]
    valueOfOneOf: aBlockArray [ ^(self oneOf: aBlockArray) value ]
]

AbstractAmbMonad subclass: AmbMonad [
    bind: anObject with: k [ ^anObject gather: k ]
    lift: anObject [ ^anObject == Fail ifTrue: [ #() ] ifFalse: [ {anObject} ] ]
]

AbstractAmbMonad subclass: AnyMonad [
    bind: anObject with: k [ ^anObject anySatisfy: k ]
    lift: anObject [ ^anObject ~~ Fail ]
]

AbstractAmbMonad subclass: CountMonad [
    bind: anObject with: k [ ^(anObject collect: k) fold: [ :a :b | a + b ] ]
    lift: anObject [ ^anObject == Fail ifTrue: [ 0 ] ifFalse: [ 1 ] ]
]

Array extend [
    queensCheck [
        | x y size |
        1 to: self size
            do:
                [:i |
                x := self at: i.
                1 to: i - 1
                    do:
                        [:j |
                        y := self at: j.
                        x = y ifTrue: [ ^false ].
                        (x - y) abs = (i - j) abs ifTrue: [ ^false ]].
        ].
	^true
    ]
]

TestCase subclass: ShiftResetTest [
    testSimple [
	self should: [1 + [:k | 3] shift] raise: Error.
	self assert: (1 + [3] reset) = 4.
	self assert: (1 + [2 * [:k | k value: 3 ] shift] reset) = 7.
	self assert: (1 + [2 * [:k | k value: (k value: 3) ] shift] reset) = 13
    ]

    testNumbers [
	| block |
	block := [ :amb | 
	    | a b c d |
	    d := amb oneOf: #(0 64 128 192).
	    c := amb oneOf: #(0 16 32 48).
	    b := amb oneOf: #(0 4 8 12).
	    a := amb oneOf: #(0 1 2 3).
	    a + b + c + d ].
	self assert: (AmbMonad do: block) size = (CountMonad do: block)
    ]

    testAny [
	| result |
	result := 3 to: 5 collect: [ :size |
	    AnyMonad do: [ :amb || board |
	        board := 1 to: size collect: [:a | amb oneOf: (1 to: size)].
	        board queensCheck
		    ifTrue: [ board ]
		    ifFalse: [ AmbMonad fail ]] ].
	self deny: result first.
	self assert: result second.
	self assert: result third
    ]

    testCount [
	| result |
	result := 3 to: 5 collect: [ :size |
	    CountMonad do: [ :amb || board |
	        board := 1 to: size collect: [:a | amb oneOf: (1 to: size)].
	        board queensCheck
		    ifTrue: [ board ]
		    ifFalse: [ AmbMonad fail ]] ].
	self assert: result first = 0.
	self assert: result second = 2.
	self assert: result third = 10
    ]

]
