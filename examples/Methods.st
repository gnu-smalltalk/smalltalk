"======================================================================
|
|   Examples of CompiledMethod subclasses
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2007 Free Software Foundation, Inc.
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

"Inspired by example code from idst-5.7, by Ian Piumarta"


CompiledMethod subclass: #InterpretedMethod
    instanceVariableNames: 'bytecodes'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-VM'!

!InterpretedMethod class methodsFor: 'testing'!

test
    "InterpretedMethod test"
    | b |
    b := Behavior new.
    b superclass: Object.
    b interpretedMethodAt: #testInterp1 put: #(#push 3 #push 4 #add #return).
    b interpretedMethodAt: #testInterp2 put: #(#push 6 #push 7 #mul #return).
    Transcript show: '3 + 4 = '. b new testInterp1 printNl.
    Transcript show: '6 * 7 = '. b new testInterp2 printNl.

    b interpretedMethodAt: #testInterp1 put: #(#push 3 #push 4 #mul #return).
    b interpretedMethodAt: #testInterp2 put: #(#push 6 #push 7 #add #return).
    Transcript show: '3 * 4 = '. b new testInterp1 printNl.
    Transcript show: '6 + 7 = '. b new testInterp2 printNl!

!InterpretedMethod class methodsFor: 'instance creation'!

numArgs: args bytecodes: bc
    ^(self numArgs: args) bytecodes: bc; yourself! !

!InterpretedMethod methodsFor: 'executing'!

bytecodes: anArray
    bytecodes := anArray!

valueWithReceiver: rec withArguments: args
    | stack pc insn a b |
    pc := 0.
    stack := OrderedCollection new.
    stack addLast: rec.
    stack addAllLast: args.
    [
	insn := bytecodes at: (pc := pc + 1).
	insn == #push   ifTrue: [
	    stack addLast: (bytecodes at: (pc := pc + 1)) ].
	insn == #add    ifTrue: [
	    a := stack removeLast.
	    b := stack removeLast.
	    stack addLast: a + b ].
	insn == #mul    ifTrue: [
	    a := stack removeLast.
	    b := stack removeLast.
	    stack addLast: a * b ].
	insn == #return ifTrue: [^stack last]
    ] repeat! !


!Behavior methodsFor: 'methods'!

interpretedMethodAt: aSelector put: bytecodes
    ^self
	addSelector: aSelector
	withMethod: (InterpretedMethod numArgs: aSelector numArgs bytecodes: bytecodes)
! !


CompiledMethod subclass: #ForwardingMethod
    instanceVariableNames: 'destClass destSelector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-VM'!

!ForwardingMethod class methodsFor: 'testing'!

test
    | foo bar |
    foo := Behavior new.
    foo superclass: Object.
    foo compile: 'one: a [ (''foo one'' -> a) printNl ]'.
    foo compile: 'two: a [ (''foo two'' -> a) printNl. self one: a ]'.

    bar := Behavior new.
    bar superclass: Object.
    bar compile: 'one: a [ (''bar one'' -> a) printNl ]'.
    bar addSelector: #two: withMethod: (ForwardingMethod to: foo -> #two:).

    foo new two: 1.
    bar new two: 2! !

!ForwardingMethod class methodsFor: 'instance creation'!

to: anAssociation
    ^(self numArgs: anAssociation value numArgs)
	destClass: anAssociation key;
	destSelector: anAssociation value;
	yourself!


!ForwardingMethod methodsFor: 'forwarding'!

destClass
    ^destClass!

destSelector
    ^destSelector!

destClass: anObject
    destClass := anObject!

destSelector: aSymbol
    destSelector := aSymbol!

valueWithReceiver: rec withArguments: args
    | method |
    method := destClass lookupSelector: destSelector.
    ^method isNil 
	ifTrue: [
	    rec doesNotUnderstand:
	    	(Message selector: self selector arguments: args) ] 
	ifFalse: [
	    rec perform: method withArguments: args ]! !

CompiledMethod subclass: #MethodWrapper
    instanceVariableNames: 'method methodClass selector'
    classVariableNames: 'WrapperList'
    poolDictionaries: ''
    category: 'Examples-VM'!

!MethodWrapper class methodsFor: 'testing'!

readdWrappersAfter: aWrapper
    | all index toAdd |
    all := self wrappersFor: aWrapper basicMethod.
    index := all identityIndexOf: aWrapper.
    toAdd := all copyFrom: index + 1.
    all empty.
    toAdd do: [ :each | each install ]
!

recordWrapper: aWrapper
    (self wrappersFor: aWrapper basicMethod) addLast: aWrapper
!

wrappersFor: aMethod
    WrapperList isNil ifTrue: [ WrapperList := IdentityDictionary new ].
    ^WrapperList at: aMethod ifAbsentPut: [ OrderedCollection new ]
! !

!MethodWrapper methodsFor: 'wrapping'!

beforeMethod
!

afterMethod
!

valueWithReceiver: rec withArguments: args
    self beforeMethod.
    ^[ rec perform: method withArguments: args ]
	ensure: [ self afterMethod ]
! !

!CompiledCode methodsFor: 'installing'!

basicMethod
    ^self
! !

!MethodWrapper methodsFor: 'installing'!

basicMethod
    ^method basicMethod
!

install
    method := self methodClass lookupSelector: selector.
    method isNil ifTrue: [ self error: 'cannot find method' ].
    self methodClass methodDictionary at: selector put: self.
    self class recordWrapper: self.
!

uninstall
    method methodClass == self methodClass
	ifTrue: [ self methodDictionary at: selector put: method ]
	ifFalse: [ self methodDictionary removeKey: selector ifAbsent: [] ].
    self class readdWrappersAfter: self.
    method := nil.
!

isInstalled
    ^method notNil
!

methodClass
    ^methodClass
!

methodDictionary
    ^methodClass methodDictionary
!

methodClass: aClass
    methodClass := aClass
!

selector: aSymbol
    selector := aSymbol
! !

!MethodWrapper class methodsFor: 'instance creation'!

on: aSymbol in: aClass
    ^(self numArgs: aSymbol numArgs)
	selector: aSymbol;
	methodClass: aClass;
	yourself! !

MethodWrapper subclass: #WrapperExample
    instanceVariableNames: 'text'
    classVariableNames: 'WrapperList'
    poolDictionaries: ''
    category: 'Examples-VM'!

!WrapperExample class methodsFor: 'installing'!

test
    | a b |
    a := WrapperExample on: #asArray in: String.
    b := WrapperExample on: #asArray in: String.

    (a isInstalled->b isInstalled) printNl.
    (String includesSelector: #asArray) printNl.

    a install: 'wrapper1'.
    (a isInstalled->b isInstalled) printNl.
    (String includesSelector: #asArray) printNl.
    'abc' asArray.

    b install: 'wrapper2'.
    (a isInstalled->b isInstalled) printNl.
    (String includesSelector: #asArray) printNl.
    'abc' asArray.

    a uninstall.
    (a isInstalled->b isInstalled) printNl.
    (String includesSelector: #asArray) printNl.
    'abc' asArray.

    b uninstall.
    (a isInstalled->b isInstalled) printNl.
    (String includesSelector: #asArray) printNl.
    'abc' asArray.
! !

!WrapperExample methodsFor: 'installing'!

install: aString
    text := aString.
    self install
!

beforeMethod
    ('before ', text) printNl
!

afterMethod
    ('after ', text) printNl
! !

InterpretedMethod test!
ForwardingMethod test!
WrapperExample test!

