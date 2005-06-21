"======================================================================
|
|   Run-time parsable expression support (for plural forms)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002 Free Software Foundation, Inc.
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
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"

Object subclass: #RunTimeExpression
    instanceVariableNames: ''
    classVariableNames: 'Precedence Selectors'
    poolDictionaries: ''
    category: 'i18n-Messages'!

RunTimeExpression subclass: #RTEAlternativeNode
    instanceVariableNames: 'condition ifTrue ifFalse'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

RunTimeExpression subclass: #RTEBinaryNode
    instanceVariableNames: 'lhs op rhs'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

RunTimeExpression subclass: #RTELiteralNode
    instanceVariableNames: 'n'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

RunTimeExpression subclass: #RTEParameterNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

RunTimeExpression subclass: #RTENegationNode
    instanceVariableNames: 'child'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

!RunTimeExpression class methodsFor: 'initializing'!

initialize
    "Private - Initialize internal tables for the parser"
    Precedence := Dictionary new
	at: #'||' put: 1;
	at: #'&&' put: 2;
	at: #'==' put: 3;
	at: #'!=' put: 3;
	at: #'<' put: 4;
	at: #'>' put: 4;
	at: #'<=' put: 4;
	at: #'>=' put: 4;
	at: #'+' put: 5;
	at: #'-' put: 5;
	at: #'*' put: 6;
	at: #'/' put: 6;
	at: #'%' put: 6;
	yourself.

    Selectors := Dictionary new
	at: #'||' put: #bitOr:;
	at: #'&&' put: #bitAnd:;
	at: #'==' put: #=;
	at: #'!=' put: #~=;
	at: #'/' put: #//;
	at: #'%' put: #\\;
	yourself
! !

!RunTimeExpression class methodsFor: 'instance creation'!

on: aString
    "Compile aString and answer a RunTimeExpression"
    | expr stream |
    stream := ReadStream on: aString.
    expr := self parseExpression: stream.
    stream skipSeparators.
    stream atEnd ifFalse: [self error: 'expected operator' ].
    ^expr
!

!RunTimeExpression class methodsFor: 'compiling'!

parseExpression: stream
    "Private - Compile the expression in the stream"
    | lhs op rhs prec topPrec stack |
    lhs := self parseOperand: stream.
    lhs isNil ifTrue: [ self error: 'expected operand' ].

    stack := OrderedCollection new.
    topPrec := 9999999.
    [ (op := self parseOperator: stream) isNil or: [ op == #? ] ] whileFalse: [
	rhs := self parseOperand: stream.
	rhs isNil ifTrue: [ self error: 'expected operand' ].
	prec := Precedence at: op.

	[ stack notEmpty and: [ prec < topPrec ] ] whileTrue: [
	    "We ended a subexpression with higher precedence, which
	     is to become the RHS of the lower-precedence subexpression
	     (for example, 3+4*5+6 after reading the +6)"
	    topPrec := stack removeLast.
	    lhs := RTEBinaryNode
		lhs: stack removeLast
		op: stack removeLast
		rhs: lhs.
	].
	prec > topPrec ifTrue: [
	    "Wait, the old RHS is actually the LHS of a subexpression
	     with higher precedence.  Save the state on the stack and
	     reset the parser (for example 3+4*5+6 after reading *5:
	     lhs is 3+4, but 3+ is saved and 4 is the new LHS)."
	    stack add: lhs op; add: lhs lhs; add: topPrec.
	    lhs := lhs rhs.
	].
	lhs := RTEBinaryNode lhs: lhs op: op rhs: rhs.
	topPrec := prec.
    ].

    "Combine the LHS's that were saved on the stack."
    [ stack isEmpty ] whileFalse: [
	stack removeLast. "precedence"
	lhs := RTEBinaryNode
	    lhs: stack removeLast
	    op: stack removeLast
	    rhs: lhs.
    ].

    "Parse a ternary expression"
    op == #? ifTrue: [
	lhs := RTEAlternativeNode
	    condition: lhs
	    ifTrue: (self parseExpression: stream)
	    ifFalse: ((stream peekFor: $:)
		ifTrue: [ self parseExpression: stream ]
		ifFalse: [ self error: 'expected :' ]).
    ].

    ^lhs
!

parseOperator: stream
    "Answer a Symbol for an operator read from stream, or nil if something
     else is found."
    | c1 c2 |
    stream skipSeparators.
    c1 := stream peek.
    c1 isNil ifTrue: [ ^nil ].
    c1 == $n ifTrue: [ ^nil ].
    c1 == $( ifTrue: [ ^nil ].
    c1 isDigit ifTrue: [ ^nil ].

    c1 == $) ifTrue: [ ^nil ].
    c1 == $: ifTrue: [ ^nil ].

    c2 := stream next; peek.
    c2 isNil ifTrue: [ ^c1 asSymbol ].
    c2 isSeparator ifTrue: [ ^c1 asSymbol ].
    c2 == $n ifTrue: [ ^c1 asSymbol ].
    c2 == $! ifTrue: [ ^c1 asSymbol ].
    c2 == $( ifTrue: [ ^c1 asSymbol ].
    c2 isDigit ifTrue: [ ^c1 asSymbol ].

    c2 == $) ifTrue: [ ^self error: 'expected operand' ].
    c2 == $: ifTrue: [ ^self error: 'expected operand' ].
    stream next.
    ^(String with: c1 with: c2) asSymbol
!

parseOperand: stream
    "Parse an operand from the stream (i.e. an unary negation,
     a parenthesized subexpression, `n' or a number) and answer
     the corresponding parse node."
    | expr |
    stream skipSeparators.
    (stream peekFor: $!) ifTrue: [
        ^RTENegationNode child: (self parseOperand: stream)
    ].
    (stream peekFor: $() ifTrue: [
        expr := self parseExpression: stream.
        (stream peekFor: $)) ifFalse: [ self error: 'expected )' ].
	^expr
    ].
    (stream peekFor: $n) ifTrue: [
        ^RTEParameterNode new
    ].
    (stream peek notNil and: [ stream peek isDigit ]) ifTrue: [
	^RTELiteralNode parseFrom: stream
    ].
    ^nil
! !

!RunTimeExpression methodsFor: 'computing'!

value: parameter
    "Evaluate the receiver, and answer its value as an integer"
    | result |
    result := self send: parameter.
    result isInteger ifFalse: [
	result := result ifTrue: [ 1 ] ifFalse: [ 0 ]
    ].
    ^result
!

send: parameter
    self subclassResponsibility
! !

!RTEBinaryNode class methodsFor: 'compiling'!

lhs: lhs op: op rhs: rhs
    "Private - Create a node in the parse tree for the run-time expression,
     mapping s to a Smalltalk arithmetic selector"
    ^self new
	lhs: lhs
	op: op
	rhs: rhs
! !

!RTEBinaryNode methodsFor: 'compiling'!

lhs
    ^lhs
!

op
    ^op
!

rhs
    ^rhs
! !

!RTEBinaryNode methodsFor: 'computing'!

send: parameter
    "Private - Evaluate the receiver by evaluating both children
     and performing an arithmetic operation between them."
    ^(lhs value: parameter)
	perform: op
	with: (rhs value: parameter)
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPut: $(; print: lhs; nextPutAll: op; print: rhs; nextPut: $)
!

lhs: lhsNode op: aSymbol rhs: rhsNode
    "Initialize the children of the receiver and the operation
     to be done between them"
    lhs := lhsNode.
    op := (Selectors at: aSymbol ifAbsent: [ aSymbol ]).
    rhs := rhsNode.
! !

!RTEAlternativeNode class methodsFor: 'compiling'!

condition: cond ifTrue: trueNode ifFalse: falseNode
    "Private - Create a node in the parse tree for the run-time expression,
     mapping s to a Smalltalk arithmetic selector"
    ^self new condition: cond ifTrue: trueNode ifFalse: falseNode
! !

!RTEAlternativeNode methodsFor: 'computing'!

send: parameter
    "Evaluate the receiver by conditionally choosing one of its children
     and evaluating it"
    ^(condition value: parameter) = 0
	ifFalse: [ ifTrue value: parameter ]
	ifTrue: [ ifFalse value: parameter ]
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream
	print: condition;
	nextPut: $?;
	print: ifTrue;
	nextPut: $:;
	print: ifFalse
!

condition: condNode ifTrue: trueNode ifFalse: falseNode
    "Initialize the children of the receiver and the conditional expression
     to choose between them"
    condition := condNode.
    ifTrue := trueNode.
    ifFalse := falseNode
! !

!RTEParameterNode methodsFor: 'computing'!

send: parameter
    "Evaluate the receiver by answering the parameter"
    ^parameter
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPut: $n
! !

!RTELiteralNode class methodsFor: 'initializing'!

parseFrom: aStream
    "Parse a literal number from aStream and return a new node"
    | ch n |
    n := 0.
    [ (ch := aStream peek) notNil and: [ ch isDigit ] ]
	whileTrue: [ n := n * 10 + ch digitValue. aStream next ].
    ^self new n: n
!

!RTELiteralNode methodsFor: 'computing'!

send: parameter
    "Answer a fixed value, the literal encoded in the node"
    ^n
!

n: value
    "Set the value of the literal that the node represents"
    n := value
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream print: n
! !

!RTENegationNode class methodsFor: 'initializing'!

child: aNode
    "Answer a new node representing the logical negation of aNode"
    ^self new child: aNode
! !

!RTENegationNode methodsFor: 'computing'!

send: parameter
    "Evaluate the receiver by computing the child's logical negation"
    ^(child value: parameter) = 0 ifTrue: [ 1 ] ifFalse: [ 0 ]
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPut: $!; print: child
!

child: value
    "Set the child of which the receiver will compute the negation"
    child := value
! !

RunTimeExpression initialize!
