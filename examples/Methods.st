"======================================================================
|
|   Examples of CompiledMethod subclasses
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
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
    foo compile: 'one: a      (''foo one'' -> a) printNl'.
    foo compile: 'two: a      (''foo two'' -> a) printNl. self one: a'.

    bar := Behavior new.
    bar superclass: Object.
    bar compile: 'one: a      (''bar one'' -> a) printNl'.
    bar addSelector: #two: withMethod: (ForwardingMethod to: foo -> #two:).

    foo new two: 1.
    bar new two: 2! !

!ForwardingMethod class methodsFor: 'instance creation'!

to: anAssociation
    ^(self numArgs: anAssociation value numArgs)
	destClass: anAssociation key;
	destSelector: anAssociation value;
	yourself!


!Behavior methodsFor: 'forwarding'!

boundCompiledMethodAt: aSelector
    | class method |
    class := self.
    [
	method := class compiledMethodAt: aSelector ifAbsent: [ nil ].
	method isNil ifFalse: [ ^method ].
	class := class superclass.
	class isNil ifTrue: [ ^nil ] ] repeat! !

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
    method := destClass boundCompiledMethodAt: destSelector.
    ^method isNil 
	ifTrue: [
	    rec doesNotUnderstand:
	    	(Message selector: self selector arguments: args) ] 
	ifFalse: [
	    rec perform: method withArguments: args ]! !

InterpretedMethod test!
ForwardingMethod test!
