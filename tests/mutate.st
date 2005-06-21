"======================================================================
|
|   Regression tests for class mutation
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003  Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #A
	instanceVariableNames: 'var1'
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

A subclass: #B
	instanceVariableNames: 'var2'
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

A class instanceVariableNames: 'instance'!

!A class methodsFor: 'testing'!

instance
    instance isNil ifTrue: [ instance := self new ].
    ^instance! !

!A methodsFor: 'testing'!

printOn: aStream
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

    aStream nextPut: $)! !

!A methodsFor: 'testing'!

var1
    ^var1!

var1: a
    var1 := a! !

!B methodsFor: 'testing'!

var2
    ^var2!

var2: a
    var2 := a! !

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
B instance printNl!
