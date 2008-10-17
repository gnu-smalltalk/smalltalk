"======================================================================
|
|   GNUPlot bindings, expression trees
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

GPObject subclass: GPExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define plotted functions.'>

    precedence [
	self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'printing'>
	self class printOn: aStream.
	aStream nextPut: $(.
	self displayAsOperandOn: aStream.
	aStream nextPut: $)
    ]
 
    displayPrologOn: aStream into: defs [
    ]
 
    displayAsOperandOn: aStream [
	<category: 'printing'>
    ]

    displayOn: aStream [
	<category: 'printing'>
	aStream nextPut: $(.
	self displayAsOperandOn: aStream.
	aStream nextPut: $).
    ]

    printOperand: aGPExpression on: aStream [
	<category: 'printing'>
	aGPExpression precedence < self precedence
	     ifTrue: [ aStream nextPut: $( ].
	aGPExpression displayAsOperandOn: aStream.
	aGPExpression precedence < self precedence
	     ifTrue: [ aStream nextPut: $) ]
    ]

    Object >> asGPExpression [
	<category: 'conversion'>
	^GNUPlot.GPLiteralExpression on: self
    ]

    asGPExpression [
	<category: 'conversion'>
	^self
    ]

    coerce: aNumber [
	<category: 'mixed computation'>
	^aNumber asGPExpression
    ]

    generality [
	<category: 'mixed computation'>
	^1000
    ]

    + expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #+ prec: -4 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    - expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #- prec: -4 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    * expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #* prec: -3 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    / expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #/ prec: -3 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    raisedTo: expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: '**' prec: -1 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    raisedToInteger: expr [
	<category: 'mixed computation'>
	^self raisedTo: expr
    ]

    bitInvert [
	<category: 'mixed computation'>
	^GPUnaryOpExpression new
	    op: '~' expr: self
    ]

    negated [
	<category: 'mixed computation'>
	^GPUnaryOpExpression new
	    op: #- expr: self
    ]

    squared [
	<category: 'mixed computation'>
	^self raisedTo: 2
    ]

    abs [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'abs' expr: self
    ]

    sign [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'sgn' expr: self
    ]

    round [
	<category: 'mixed computation'>
	^(self + 0.5) truncated
    ]

    truncated [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'int' expr: self
    ]

    ceiling [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'ceil' expr: self
    ]

    floor [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'floor' expr: self
    ]

    ln [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'log' expr: self
    ]

    log [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'log10' expr: self
    ]

    exp [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'exp' expr: self
    ]

    arcTanh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'atanh' expr: self
    ]

    arcCosh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'acosh' expr: self
    ]

    arcSinh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'asinh' expr: self
    ]

    tanh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'tanh' expr: self
    ]

    cosh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'cosh' expr: self
    ]

    sinh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'sinh' expr: self
    ]

    arcTan [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'atan' expr: self
    ]

    arcCos [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'acos' expr: self
    ]

    arcSin [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'asin' expr: self
    ]

    tan [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'tan' expr: self
    ]

    cos [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'cos' expr: self
    ]

    sin [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'sin' expr: self
    ]
]

GPExpression subclass: GPUnaryExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    | op expr |
    displayAsOperandOn: aStream [
	aStream nextPutAll: op.
	self printOperand: expr on: aStream.
    ]
 
    displayPrologOn: aStream into: defs [
	expr displayPrologOn: aStream into: defs
    ]

    op: operandSymbol expr: exprExpr [
	op := operandSymbol.
	expr := exprExpr
    ]
]

GPUnaryExpression subclass: GPUnaryOpExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    precedence [
	^-2
    ]
]

GPUnaryExpression subclass: GPFunctionExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    precedence [
	^1
    ]
]

GPFunctionExpression subclass: GPFitExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and represent functions fitted to a data source.'>

    | source function expr params |
    GPFunctionExpression class >>
	name: aString source: aSource function: aBlock variable: expr [
	^self new
	    op: aString expr: expr;
	    source: aSource asGPDataSource function: aBlock;
	    yourself
    ]

    source: aSource function: aBlock [
	"Use variables from A on as parameters"
	params := (1 to: aBlock argumentCount) collect: [ :i |
	    GPVariableExpression on: (Character digitValue: i + 9) ].

	function := aBlock valueWithArguments: params.
	source := aSource
    ]

    displayPrologOn: aStream into: defs [
	(defs includes: self) ifTrue: [ ^self ].
	defs add: self.
	super displayPrologOn: aStream into: defs.

	"f(x)=a*x+b"
	self displayAsOperandOn: aStream.
	aStream
	     nextPut: $=;
	     display: function;
	     nl;
	     nextPutAll: 'fit '.
	
	"fit f(x) 'filename' using 1:2 via A,B"
	self displayAsOperandOn: aStream.
	aStream
	    space;
	    display: source;
	    nextPutAll: ' using 1:2 via '.

	params
	    do: [ :each | each displayAsOperandOn: aStream ]
	    separatedBy: [ aStream nextPut: $, ].

	aStream nl.
	source printDataOn: aStream.
	aStream nl.
    ]
]

GPExpression subclass: GPBinaryExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    | op prec lhs rhs |
    precedence [
	^prec
    ]

    displayAsOperandOn: aStream [
	self printOperand: lhs on: aStream.
	aStream nextPutAll: op.
	self printOperand: rhs on: aStream.
    ]
 
    displayPrologOn: aStream into: defs [
	lhs displayPrologOn: aStream into: defs.
	rhs displayPrologOn: aStream into: defs
    ]

    op: operandSymbol prec: precedence lhs: lhsExpr rhs: rhsExpr [
	op := operandSymbol.
	prec := precedence.
	lhs := lhsExpr.
	rhs := rhsExpr
    ]
]

GPExpression subclass: GPCondExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    | cond trueBranch falseBranch |

    GPCondExpression class >> condition: condExpr ifTrue: trueExpr ifFalse: falseExpr [
	^self new
	    condition: condExpr ifTrue: trueExpr ifFalse: falseExpr;
	    yourself
    ]

    precedence [
	^-10
    ]

    displayAsOperandOn: aStream [
	self printOperand: cond on: aStream.
	aStream nextPut: $?.
	self printOperand: trueBranch on: aStream.
	aStream nextPut: $:.
	self printOperand: falseBranch on: aStream.
    ]
 
    displayPrologOn: aStream into: defs [
	cond displayPrologOn: aStream into: defs.
	trueBranch displayPrologOn: aStream into: defs.
	falseBranch displayPrologOn: aStream into: defs
    ]

    condition: condExpr ifTrue: trueExpr ifFalse: falseExpr [
	cond := condExpr.
	trueBranch := trueExpr value.
	falseBranch := falseExpr value
    ]
]

GPExpression subclass: GPPrimaryExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    precedence [
	^0
    ]
]

GPPrimaryExpression subclass: GPColumnRef [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and refer to columns of external data sets.'>

    | column |
    GPColumnRef class >> column: anInteger [
	<category: 'instance creation'>
	^self new column: anInteger
    ]

    column [
	<category: 'accessing'>
	^column
    ]

    column: aString [
	<category: 'private - initialization'>
	column := aString
    ]

    displayAsOperandOn: aStream [
	<category: 'printing'>
	aStream nextPut: $$.
	column printOn: aStream
    ]

    displayOn: aStream [
	<category: 'printing'>
	column printOn: aStream
    ]

    valid [
	<category: 'building'>
	^GPColumnRefValidExpression column: self column
    ]

    ifValid: validBlock ifNotValid: invalidBlock [
	<category: 'building'>
	^GPCondExpression
	    condition: self valid
	    ifTrue: validBlock
	    ifFalse: invalidBlock
    ]
]

GPPrimaryExpression subclass: GPColumnRefValidExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and refer to columns of external data sets.'>

    | column |
    GPColumnRefValidExpression class >> column: anInteger [
	<category: 'instance creation'>
	^self new column: anInteger
    ]

    column [
	<category: 'accessing'>
	^column
    ]

    column: aString [
	<category: 'private - initialization'>
	column := aString
    ]

    displayAsOperandOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'valid('.
	column printOn: aStream.
	aStream nextPut: $).
    ]

    displayOn: aStream [
	<category: 'printing'>
	column printOn: aStream
    ]
]

GPPrimaryExpression subclass: GPLiteralExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and usually refer to numeric values.'>

    | object |
    GPLiteralExpression class >> on: anObject [
	<category: 'instance creation'>
	^self new object: anObject
    ]

    object [
	<category: 'accessing'>
	^object
    ]

    object: aString [
	<category: 'private - initialization'>
	object := aString
    ]

    displayAsOperandOn: aStream [
	<category: 'printing'>
	object displayOn: aStream
    ]
]

UndefinedObject extend [
    asGPExpression [
	^GNUPlot.GPLiteralExpression on: '(1/0)'
    ]
]

GPLiteralExpression subclass: GPVariableExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and refer to independent variables.'>

    fit: source to: aBlock name: aString [
	^GPFitExpression
	    name: aString
	    source: source asGPDataSource
	    function: aBlock
	    variable: self
    ]
]

