"======================================================================
|
|   Regression tests for class mutation
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003, 2007, 2008  Free Software Foundation.
| Written by Paolo Bonzini.
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

Object subclass: A [
    | var1 |
    var1 [ ^var1 ]
    var1: a [ var1 := a ]

    printOn: aStream [
        aStream
	    nextPutAll: self class name;
	    nextPut: $(.

        self class allInstVarNames keysAndValuesDo: [ :i :each |
	    aStream
	        nextPutAll: each;
	        nextPut: $: ;
	        print: (self instVarAt: i);
	        space
        ].

        aStream nextPut: $)
    ]
]

A subclass: B [ |var2|
    var2 [ ^var2 ]
    var2: a [ var2 := a ]
]

A class extend [
    | instance |

    instance [
        instance isNil ifTrue: [ instance := self new ].
        ^instance
    ]
]


Eval [
    A instance var1: 1.
    A instance printNl.

    B instance var1: 0.
    B instance var2: 2.
    B instance printNl.

    A addInstVarName: #var2.
    B instance var2 printNl.
    B instance printNl.

    A removeInstVarName: #var2.
    B instance var2 printNl.
    B instance printNl.

    "Now make B's var2 point to A's"
    A addInstVarName: #var2.
    B removeInstVarName: #var2.
    B instance var2 printNl.
    B instance printNl
]


"Now, test using #subclass: to create classes."

Eval [ Association subclass: #C ]
Eval [ C instSize = C allInstVarNames size ]
Eval [ (C allInstVarNames -> C sharedPools) printNl ]

Eval [ Object subclass: #C instanceVariableNames: 'a' classVariableNames: '' poolDictionaries: 'SystemExceptions' category: 'foo' ]
Eval [ C instSize = C allInstVarNames size ]
Eval [ (C allInstVarNames -> C sharedPools) printNl ]

Eval [ Array subclass: #C ]
Eval [ C instSize = C allInstVarNames size ]
Eval [ (C allInstVarNames -> C sharedPools) printNl ]

Eval [ Association subclass: #C ]
Eval [ C instSize = C allInstVarNames size ]
Eval [ (C allInstVarNames -> C sharedPools) printNl ]

Eval [ Object subclass: #C instanceVariableNames: '' classVariableNames: 'Foo' poolDictionaries: 'SystemExceptions' category: 'foo' ]
Eval [ C instSize = C allInstVarNames size ]
Eval [ (C classPool keys asArray -> C allInstVarNames -> C sharedPools) printNl ]

Eval [ Association subclass: #C ]
Eval [ (C classPool keys asArray -> C allInstVarNames -> C sharedPools) printNl ]

Eval [ Object variableSubclass: #C instanceVariableNames: '' classVariableNames: 'Foo' poolDictionaries: 'SystemExceptions' category: 'foo' ]
Eval [ C instSize = C allInstVarNames size ]
Eval [ (C shape -> C classPool keys asArray -> C allInstVarNames -> C sharedPools) printNl ]

Eval [ Association subclass: #C ]
Eval [ (C shape -> C classPool keys asArray -> C allInstVarNames -> C sharedPools) printNl ]

Eval [ C class compile: 'foo [ ^MutationError ]' ]
Eval [ C foo == SystemExceptions.MutationError ]

"Test mutating the class when the new superclass has additional class-instance
 variables"
CObject subclass: CFoo [ ]
CStruct subclass: CFoo [ ]
Eval [ CFoo environment printNl ]

"Test adding variables with multiple |...| blocks or with extend."
Object subclass: Foo [ | a | ]
Foo subclass: Bar [ | xyz | ]
Foo subclass: Bar [ | b | | c | ]
Eval [ Bar allInstVarNames printNl ]
Foo extend [ | d | ]
Eval [ Bar allInstVarNames printNl ]
Eval [ Foo allInstVarNames printNl ]

"Test moving to an upper superclass, but preserving instance variables
 because they are specified in the instanceVariableNames: keyword."
Association subclass: Blah [ ]
Eval [
    | blah |
    blah := Blah new.
    blah value: 'abc'.
    Object
	subclass: #Blah
	instanceVariableNames: 'key value'
	classVariableNames: ''
	poolDictionaries: ''
	category: ''.

    blah instVarAt: 2
]
