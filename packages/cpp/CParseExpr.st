"======================================================================
|
|   C expression parser and tree builder, part of the C header parser.
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

"Build expression trees for C"

"left or right recursive,
<delimiter or separator>
<include delim>
<next level parser>
<optional>
"

"key:
<node name> <left or right> <next node name> <delimiters>
"

Object subclass: #CExpressionParser
       instanceVariableNames: 'stream'
       classVariableNames: ''
       poolDictionaries: 'CToks'
       category: nil
! 


!CExpressionParser class methodsFor: 'instance creation'!

onStream: aStream
    ^self new init: aStream
! !


!CExpressionParser methodsFor: 'hacks r us'!

parseExpression
    ^self commaExpression
!

conditionalExpression
    | anExpr sym colonExpr |
    anExpr _ self corExpression.
    sym _ stream peek.
    sym == QuestionTok
	ifTrue: 
	    [ stream next.
	      anExpr _ ConditionalNode left: anExpr op: sym.
	      colonExpr _ ColonNode left: self corExpression.
	      sym _ stream peek.
	      sym == ColonTok
		  ifFalse: [ ^self error: 'expected '':''' ].
	      stream next.
	      colonExpr op: sym; right: self conditionalExpression.
	      anExpr right: colonExpr ].
    ^anExpr
!

unaryExpression
    "Parse a unary expression.  Binds right to left.
     First check for it being a prefix."
    | sym expr result |
    sym _ stream peek.
    "oneof - + ~ ! * & -- ++
     not in pp context: sizeof (cast)"

    (self isSimpleUnaryOp: sym)
	ifTrue: [ ^self parseSimpleUnaryExpression ].
    
    sym value = 'sizeof'
	ifTrue: [ ^self parseSizeof ].
    "!!! Ignoring casts for right now"
    sym class = OpenParenTok 
	ifTrue: [ "^self tryParsingCast" ].

    "Here we've made it through, so it must be a primary expression
     that we're after"
    
    expr _ self primaryExpression.
	      
    "now check for trailing, one of ++ or --"
    [ sym _ stream peek.
      sym notNil and: [ (sym value = '--' ) | (sym value = '++') ] ]
	whileTrue: 
	    [ sym value = '--'
		     ifTrue: [ expr _ PostDecrementNode expr: expr 
							op: stream next ]
		     ifFalse: [expr _ PostIncrementNode expr: expr 
							op: stream next ].
	      ].
    ^expr
!
	
isSimpleUnaryOp: anOperator
    ^#('-' '+' '~' '!' '*' '&' '--' '++') includes: anOperator value
!

parseSimpleUnaryExpression
    "Must be - + ~ ! * & -- ++"
    | sym value expr |
    sym _ stream next.
    value _ sym value.
    value = '-' ifTrue: [ ^UMinusNode op: sym expr: self unaryExpression ].
    value = '+' ifTrue: [ ^UPlusNode op: sym expr: self unaryExpression ].
    value = '~' ifTrue: [ ^BitInvertNode op: sym expr: self unaryExpression ].
    value = '!' ifTrue: [ ^LogicalComplementNode op: sym expr: self unaryExpression ].
    value = '*' ifTrue: [ ^DereferenceNode op: sym expr: self unaryExpression ].
    value = '&' ifTrue: [ ^AddressOfNode op: sym expr: self unaryExpression ].
    value = '--' ifTrue: [ ^PreIncrementNode op: sym expr: self unaryExpression ].
    value = '++' ifTrue: [ ^PreDecrementNode op: sym expr: self unaryExpression ].
    ^self error: 'Unhandled case in parseSimpleUnaryExpression'
!


	      
primaryExpression
    "can be one of <literal>,
     '(' <expression> ')'
     <primaryExpression> '(' <optional expression list> ')'
     <primaryExpression> '[' <expression> ']'
     <primaryExpression> '->' | '.' <primaryExpression>
     "
    | sym expr usedIt |
    sym _ stream peek.
    sym == OpenParenTok
	ifTrue:
	    [ stream next.	"gobble '('"
	      " !!! Where is casting handled"
	      expr _ self parseExpression.
	      expr printNl.
	      sym _ stream next.
	      sym printNl.
	      sym == CloseParenTok
		  ifFalse: [ ^self error: 'expecting '')''']. ]
	ifFalse: [ 
    "###should be sure to exclude comments if they could be in the stream"
		   (sym isKindOf: CValueToken)
		       ifFalse: [ ^self error: 'expecting literal value' ].
		   stream next.	"gobble the literal"
		   expr _ sym. ].
    [ sym _ stream peek.
      usedIt _ false.
      sym == OpenParenTok
	  ifTrue: [ expr _ self parseFunctionCall: expr.
		    usedIt _ true ].
      sym == OpenBracketTok
	  ifTrue: [ expr _ self parseSubscript: expr.
		    usedIt _ true ].
      (sym class == CBinaryOperatorToken and:
	   [ (sym value = '.') | (sym value = '->') ]) 
	  ifTrue: [ expr _ self parseStructureReference: expr.
		    usedIt _ true ].
      usedIt ] whileTrue: [ ].
    ^expr
!
	      
       
    
commaExpression
    ^self recurseRight: CommaNode
	  into: #assignExpression delimitedBy: ',' 
!


assignExpression
    ^self recurseRight: #AssignNode
	  into: #conditionalExpression 
	  delimitedBy: #('=' '*=' '/=' '%=' 
			     '+=' '-=' 
			     '&=' '^=' '|=' 
			     '>>=' '<<=')
!

corExpression
    ^self recurseLeft: CorNode
	  into: #candExpression delimitedBy: '||'
!

candExpression
    ^self recurseLeft: CandNode
	  into: #bitorExpression delimitedBy: '&&'
!

bitorExpression
    ^self recurseLeft: BitorNode
	  into: #bitxorExpression delimitedBy: '|'
!

bitxorExpression
    ^self recurseLeft: BitxorNode
	  into: #bitandExpression delimitedBy: '^'
!

bitandExpression
    ^self recurseLeft: BitandNode
	  into: #eqExpression delimitedBy: '&'
!

eqExpression
    ^self recurseLeft: EqNode
	  into: #relationExpression delimitedBy: #('==' '!=')
!

relationExpression
    ^self recurseLeft: RelationNode
	  into: #shiftExpression delimitedBy: #('>' '>=' '<' '<=')
!

shiftExpression
    ^self recurseLeft: ShiftNode
	  into: #addExpression delimitedBy: #('<<' '>>')
!

addExpression
    ^self recurseLeft: AddNode
	  into: #multExpression delimitedBy: #('+' '-')
!

multExpression
    ^self recurseLeft: MultNode
	  into: #unaryExpression delimitedBy: #('*' '/' '%')
!


recurseLeft: nodeClass into: builderMethod delimitedBy: delimiters
    | expr delim |
    expr _ self perform: builderMethod.
    [ delim _ stream peek.
      self inDelimiterSet: delim set: delimiters ]
	whileTrue: 
	    [ stream next.	"gobble it"
	      expr _ nodeClass left: expr op: delim 
			       right: (self perform: builderMethod) ].
    ^expr
!

recurseRight: nodeClass into: builderMethod delimitedBy: delimiters
    | expr delim |
    expr _ self perform: builderMethod.
    delim _ stream peek.
    (self inDelimiterSet: delim set: delimiters)
	ifTrue: 
	    [ stream next.	"gobble it"
	      expr _ nodeClass left: expr op: delim 
			       right: (self recurseRight: nodeClass
					    into: builderMethod 
					    delimitedBy: delimiters) ].
    ^expr
!

inDelimiterSet: delimiter set: delimiterSet
    delimiter isNil ifTrue: [ ^false ].
    (delimiterSet class == Array)
	ifTrue: [ ^delimiterSet includes: delimiter value ]
	ifFalse: [ ^delimiterSet = delimiter value ]
! !



!CExpressionParser methodsFor: 'private'!

init: aStream
    stream _ aStream
! !



"Keep this around just in case"
"foo _ #(
    comma right assign ',' 
    assign right conditional ('=' '*=' '/=' '%=' '+=' '-=' '&=' '^=' '|=' '>>=' '<<=')
    ""handle conditional directly with code""
    cor left cand '||'
    cand left bitor '&&'
    bitor left bitxor '|'
    bitxor left bitand '^'
    bitand left eq '&'
    eq left relation ('==' '!=')
    relation left shift ('>' '>= '<' '<=')
    shift left add ('<<' '>>')
    add left mult ('+' '-')
    mult left unary ('*' '/' '%')
    ""handle unary specially""

)!
"
