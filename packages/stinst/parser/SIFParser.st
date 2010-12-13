"======================================================================
|
|   SIF input parser
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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


STFileInParser subclass: #SIFFileInParser
    instanceVariableNames: 'lastClass'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

!SIFFileInParser methodsFor: 'parsing'!

parseMethodDefinitionList
    "Methods are defined one by one in SIF."
    | method |
    method := self compile: self parseMethodFromFile.
    method isNil ifFalse: [ method noteOldSyntax ].
    self endMethodList
! !

!SIFFileInParser methodsFor: 'evaluating'!

evaluate: node
    "Convert some SIF messages to GNU Smalltalk file-out syntax.
     This avoids that the STParsingDriver need to know about other
     dialects."
    | stmt |
    node statements size == 0 ifTrue: [ ^false ].
    node statements size == 1 ifFalse: [ ^self error: 'invalid SIF' ].

    stmt := node statements first.
    stmt isReturn ifTrue: [ stmt := stmt value ].
    stmt isMessage ifFalse: [ ^super evaluate: node ].
    stmt selector == #interchangeVersion: ifTrue: [ ^false ].

    stmt selector == #named:superclass:indexedInstanceVariables:instanceVariableNames:classVariableNames:sharedPools:classInstanceVariableNames: ifTrue: [
	lastClass := self evaluateClass: stmt.
	^false ].

    stmt selector == #key:value: ifTrue: [
	lastClass isNil
	    ifFalse: [ self evaluateAnnotation: stmt to: lastClass ].
	^false ].

    stmt selector == #classMethod ifTrue: [
	lastClass := nil.
	self evaluateClassMethod: stmt.
	^true ].

    stmt selector == #method ifTrue: [
	lastClass := nil.
	self evaluateMethod: stmt.
	^true ].

    (stmt selector == #initializerFor:) ifTrue: [
	lastClass := nil.
	self evaluateInitializer: stmt.
	^false ].

    (stmt selector == #initializer) ifTrue: [
	lastClass := nil.
	self evaluateGlobalInitializer: stmt.
	^false ].

    (stmt selector == #variable: or: [ stmt selector == #constant: ]) ifTrue: [
	lastClass := nil.
	self evaluatePoolDefinition: stmt.
	^false ].

    stmt selector == #named: ifTrue: [
	lastClass := nil.
	self evaluatePool: stmt.
	^false ].

    self error: 'invalid SIF'
!

evaluateStatement: stmt
    driver evaluate: (RBSequenceNode new
			temporaries: #();
			statements: { stmt })
!

evaluateClass: stmt
    "Convert `Class named: ...' syntax to GNU Smalltalk file-out syntax."
    | name superclass shape ivn cvn sp civn newStmt newClass |
    name := stmt arguments at: 1.
    superclass := stmt arguments at: 2.
    shape := stmt arguments at: 3.
    ivn := stmt arguments at: 4.
    cvn := stmt arguments at: 5.
    sp := stmt arguments at: 6.
    civn := stmt arguments at: 7.

    shape value = #none
	ifTrue: [ shape := RBLiteralNode value: nil ].
    shape value = #object
	ifTrue: [ shape := RBLiteralNode value: #pointer ].

    newStmt := RBMessageNode
		receiver: (RBVariableNode named: superclass value)
		selector: #variable:subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
		arguments: {
			shape. RBLiteralNode value: name value asSymbol.
			ivn. cvn. sp. RBLiteralNode value: nil }.
    self evaluateStatement: newStmt.

    newClass := RBVariableNode named: name value.
    newStmt := RBMessageNode
	    receiver: (self makeClassOf: newClass)
	    selector: #instanceVariableNames:
	    arguments: { civn }.
    self evaluateStatement: newStmt.

    ^newClass!

makeClassOf: node
    ^RBMessageNode
	receiver: node
	selector: #class
	arguments: #()!

evaluateAnnotation: stmt to: object
    "Convert `Annotation key: ...' syntax to GNU Smalltalk file-out syntax."
    | key value selector newStmt |
    key := stmt arguments at: 1.
    value := stmt arguments at: 2.
    key value = 'package' ifTrue: [ selector := #category: ].
    key value = 'category' ifTrue: [ selector := #category: ].
    key value = 'comment' ifTrue: [ selector := #comment: ].
    selector isNil ifFalse: [
        newStmt := RBMessageNode
	    receiver: object
	    selector: selector
	    arguments: { value }.
        self evaluateStatement: newStmt ]!

evaluateClassMethod: stmt
    "Convert `Foo classMethod' syntax to GNU Smalltalk file-out syntax."
    stmt receiver: (self makeClassOf: stmt receiver).
    self evaluateMethod: stmt!

evaluateMethod: stmt
    "Convert `Foo method' syntax to GNU Smalltalk file-out syntax."
    | newStmt |
    newStmt := RBMessageNode
	receiver: stmt receiver
	selector: #methodsFor:
	arguments: { RBLiteralNode value: nil }.
    self evaluateStatement: newStmt!

evaluateInitializer: stmt
    "Convert `Foo initializerFor: Bar' syntax to GNU Smalltalk file-out syntax."
    self
	evaluateInitializerFor: stmt arguments first value
	in: stmt receiver!

evaluateGlobalInitializer: stmt
    "Convert `Foo initializer' syntax to GNU Smalltalk file-out syntax."
    | node |
    stmt receiver name = 'Global' ifTrue: [
	node := self parseDoit.
        scanner stripSeparators.
        self step.
	^super evaluate: node ].

    self
	evaluateInitializerFor: stmt receiver name
	in: (RBVariableNode named: 'Smalltalk')!

evaluateInitializerFor: key in: receiver
    | position node arg newStmt |
    position := currentToken start.
    node := RBOptimizedNode
                left: position
                body: self parseDoit
                right: currentToken start.

    scanner stripSeparators.
    self step.
    newStmt := RBMessageNode
	    receiver: receiver
	    selector: #at:put:
	    arguments: { RBLiteralNode value: key asSymbol. node }.
    self evaluateStatement: newStmt!
    
evaluatePoolDefinition: stmt
    "Convert `Foo variable:/constant: ...' syntax to GNU Smalltalk file-out
     syntax."
    | receiver key newStmt |
    receiver := stmt receiver.
    receiver name = 'Global' ifTrue: [ receiver := RBVariableNode named: 'Smalltalk' ].
    key := RBLiteralNode value: stmt arguments first value asSymbol.

    newStmt := RBMessageNode
	    receiver: receiver
	    selector: #at:put:
	    arguments: { key. RBLiteralNode value: nil }.

    self evaluateStatement: newStmt!

evaluatePool: stmt
    "Convert `Pool named: ...' syntax to GNU Smalltalk file-out syntax."
    | key newStmt |
    key := RBLiteralNode value: stmt arguments first value asSymbol .
    newStmt := RBMessageNode
	    receiver: (RBVariableNode named: 'Smalltalk')
	    selector: #addSubspace:
	    arguments: { key }.

    self evaluateStatement: newStmt!
! !

!SIFFileInParser methodsFor: 'private-parsing'!

scannerClass
    "We need a special scanner to convert the double-bangs in strings
     to single bangs.  Unlike in GNU Smalltalk, all bangs must be
     `escaped' in Squeak."
    ^SqueakFileInScanner! !

