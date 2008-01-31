"======================================================================
|
|   C expression node support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


Object subclass: #CExpressionNode
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CExpressionNode subclass: #CBinaryExpressionNode
       instanceVariableNames: 'left op right'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CExpressionNode subclass: #CPrefixUnaryExpressionNode
       instanceVariableNames: 'op expr'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CExpressionNode subclass: #CPostfixUnaryExpressionNode
       instanceVariableNames: 'expr op'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CExpressionNode class methodsFor: 'subclass creation'!

subclass: subclassName
    ^self subclass: subclassName
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! !



!CExpressionNode methodsFor: 'evaluation'!

evaluate
    ^self subclassResponsibility
!

isCValueTrue: value
    ^value ~= 0
!

boolToCValue: aBoolean
    ^aBoolean ifTrue: [ 1 ] ifFalse: [ 0 ]
! !


!CPrefixUnaryExpressionNode class methodsFor: 'instance creation'!

op: operator expr: anExpression
    ^self new op: operator expr: anExpression
! !


!CPrefixUnaryExpressionNode methodsFor: 'assignment'!

op: operator expr: anExpression
    op _ operator.
    expr _ anExpression
! !


CPrefixUnaryExpressionNode subclass: #UMinusNode!
CPrefixUnaryExpressionNode subclass: #UPlusNode!
CPrefixUnaryExpressionNode subclass: #BitInvertNode!
CPrefixUnaryExpressionNode subclass: #LogicalComplementNode
    "Why Dr. McCoy, you are indeed today looking every bit the splendid
     example of humanity at its finest"  
    "What's got into you, you pointed eared Vulcan?"!
CPrefixUnaryExpressionNode subclass: #DereferenceNode!
CPrefixUnaryExpressionNode subclass: #AddressOfNode!
CPrefixUnaryExpressionNode subclass: #SizeOfNode!
CPrefixUnaryExpressionNode subclass: #CastNode!
CPrefixUnaryExpressionNode subclass: #PreIncrementNode!
CPrefixUnaryExpressionNode subclass: #PreDecrementNode!

!UMinusNode methodsFor: 'evaluation'!

evaluate
    ^expr evaluate negated
! !


!UPlusNode methodsFor: 'evaluation'!

evaluate
    ^expr evaluate
! !


!BitInvertNode methodsFor: 'evaluation'!

evaluate
    ^expr evaluate bitInvert
! !


!LogicalComplementNode methodsFor: 'evaluation'!

evaluate
    (self isCValueTrue: (expr evaluate))
	ifTrue: [ ^0 ]
	ifFalse: [ ^1 ]
! !


!DereferenceNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot yet evaluate a dereference!'

! !


!AddressOfNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'AddressOf operation not yet supported!'

! !


!SizeOfNode methodsFor: 'evaluation'!

evaluate
    | value |
    (expr isKindOf: CExpressionNode)
	ifTrue: [ value _ expr evaluate.
		  ^self error: 'sizeof expressions not yet done!' 
		  ]
	ifFalse: [ "must be a type, so ask the type what its size is"
		   ^expr sizeOf ]
! !


!CastNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cast evaluation not yet supported!'

! !

!PreIncrementNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot evaluate a prefix increment!'

! !


!PreDecrementNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot evaluate a prefix decrement!'

! !





!CPostfixUnaryExpressionNode class methodsFor: 'instance creation'!

expr: anExpression op: operator
    ^self new expr: anExpression op: operator
! !


!CPostfixUnaryExpressionNode methodsFor: 'assignment'!

expr: anExpression op: operator
    expr _ anExpression.
    op _ operator.
! !


!CPostfixUnaryExpressionNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot evaluate a postfix unary operator currently!'
! !

CPostfixUnaryExpressionNode subclass: #PostIncrementNode!
CPostfixUnaryExpressionNode subclass: #PostDecrementNode!


!CBinaryExpressionNode class methodsFor: 'instance creation'!

left: leftExpr op: operator right: rightExpr
    ^self new left: leftExpr op: operator right: rightExpr
!

left: leftExpr op: operator 
    ^self new left: leftExpr; op: operator; yourself
! !


!CBinaryExpressionNode methodsFor: 'assignment'!

left: leftExpr op: operator right: rightExpr
    left _ leftExpr.
    op _ operator.
    right _ rightExpr
!

left: leftExpr
    left _ leftExpr
!

op: operator
    op _ operator
!

right: rightExpr
    right _ rightExpr
! !


CBinaryExpressionNode subclass: #CommaNode! 

CBinaryExpressionNode subclass: #AssignNode!
CBinaryExpressionNode subclass: #ConditionalNode!
CBinaryExpressionNode subclass: #ColonNode!
CBinaryExpressionNode subclass: #CorNode!
CBinaryExpressionNode subclass: #CandNode!
CBinaryExpressionNode subclass: #BitorNode!
CBinaryExpressionNode subclass: #BitandNode!
CBinaryExpressionNode subclass: #BitxorNode!
CBinaryExpressionNode subclass: #EqNode!
CBinaryExpressionNode subclass: #RelationNode!
CBinaryExpressionNode subclass: #ShiftNode!
CBinaryExpressionNode subclass: #AddNode!
CBinaryExpressionNode subclass: #MultNode!

!AssignNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'cannot assign in Smalltalk C expressions'
! !

!ConditionalNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    (self isCValueTrue: leftValue)
	ifTrue: [ ^right evaluateLeft ]
	ifFalse: [ ^right evaluateRight ] .
! !

!ColonNode methodsFor: 'evaluation'!

evaluateLeft
    ^left evaluate.
! 

evaluateRight
    ^right evaluate.
! !



!CorNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    (self isCValueTrue: leftValue)
	ifTrue: [ ^1 ].
    rightValue _ right evaluate.
    ^self boolToCValue: (self isCValueTrue: rightValue)
! !

!CandNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    (self isCValueTrue: leftValue)
	ifFalse: [ ^0 ].
    rightValue _ right evaluate.
    ^self boolToCValue: (self isCValueTrue: rightValue)
! !

!BitorNode methodsFor: 'evaluation'!

evaluate
    ^left evaluate bitOr: right evaluate
! !

!BitandNode methodsFor: 'evaluation'!

evaluate
    ^left evaluate bitAnd: right evaluate
! !

!BitxorNode methodsFor: 'evaluation'!

evaluate
    ^left evaluate bitXor: right evaluate
! !

!EqNode methodsFor: 'evaluation'!

evaluate
    | result |
    result _ left evaluate = right evaluate.
    op value = '!='
	ifTrue: [ result _ result not ].
    ^self boolToCValue: result
! !

!RelationNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    rightValue _ right evaluate.
    ^self boolToCValue: (leftValue perform: (op value asSymbol)
				   with: rightValue)
! !

!ShiftNode methodsFor: 'evaluation'!

evaluate
    | value shiftAmount |
    value _ left evaluate.
    shiftAmount _ right evaluate.
    op value = '>>'
	ifTrue: [ shiftAmount _ shiftAmount negated ].
    ^value bitShift: shiftAmount
    
! !

!AddNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    rightValue _ right evaluate.
    ^leftValue perform: (op value asSymbol)
	       with: rightValue
! !

!MultNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue opStr |
    leftValue _ left evaluate.
    rightValue _ right evaluate.
    opStr _ op value.
    opStr = '*' ifTrue: [ ^leftValue * rightValue ].
    opStr = '%' ifTrue: [ "??? not exactly sure about this, may have to do
			   more special casing"
			  ^leftValue \\ rightValue ].
    "must be / by this point"
    ((leftValue class isInteger)
	 and: [ rightValue class isInteger ])
	ifTrue: [ ^leftValue // rightValue ]
	ifFalse: [ ^leftValue / rightValue ]
! !


