"======================================================================
|
|   GNU Smalltalk syntax parser
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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

STInST.STFileInParser subclass: GSTFileInParser [
    | taggee class currentDeclaration |

    parseStatements [
        | returnPosition statements node |
	"Skip temporaries."
        (currentToken isBinary and: [currentToken value == #|]) 
	    ifTrue: [ self step. self parseArgs. self step ].
        (currentToken isBinary and: [currentToken value == #||]) 
	    ifTrue: [ self step ].

        (currentToken isSpecial and: [currentToken value == $!]) 
	    ifTrue: [ ^RBSequenceNode statements: #() ].

        node := (currentToken isSpecial and: [currentToken value == $^]) 
            ifTrue: [returnPosition := currentToken start.  
                     self step.
                     RBReturnNode return: returnPosition value: self parseAssignment]
            ifFalse: [self parseAssignment].

        self addCommentsTo: node.
        ^RBSequenceNode statements: { node }
    ]

    parseDoits [
        "Parses the stuff to be executed until a closed bracket."

        <category: 'private-parsing'>
        | node |

        [self atEnd ifTrue: [^false].
        (currentToken isSpecial and: [currentToken value == $]])
	    ifTrue: [^false].

        node := self parseDoit.
        scanner stripSeparators.
        self evaluate: node]
                whileFalse:
                    [(currentToken isSpecial and: [currentToken value == $!])
                        ifTrue: [self step]].
        ^true
    ]

    parseDoit [
	| node |
	(taggee notNil and: [currentToken value = #<]) ifTrue:
	    [self parseClassTag. ^nil].
	node := super parseDoit.
        (currentToken isSpecial and: [ self skipToken: $[ ])
            ifTrue: [self parseDeclaration: node statements first. ^nil].

        currentToken isSpecial ifTrue: [ self skipToken: $. ].
	^node
    ]

    parseDeclaration: node [
        | decl |
	currentDeclaration := node parent.
        decl := node.
        decl isReturn ifTrue: [ decl := decl value ].
        decl isMessage ifTrue: [
            (decl selectorParts first value = 'subclass:')
                ifTrue: [self parseClass: decl. ^self].
            
            (decl selectorParts first value = 'extend')
                ifTrue: [self parseClassExtension: decl. ^self].
                
            ((decl receiver name = 'Namespace') 
                and: [decl selectorParts first value = 'current:' ])
                    ifTrue: [self parseNamespace: decl. ^self]].
        
        decl isVariable 
            ifTrue: [(decl name = 'Eval') 
                        ifTrue: [self parseEval. ^self]].
        
        self parserError: 'expected Eval, Namespace or class definition'
    ]
    
    parseEval [
        | stmts |
        stmts := self parseStatements: false.
        self skipExpectedToken: $].
        self evaluate: stmts.
    ]
    
    parseNamespace: node [   
        | namespace fullNamespace newNamespace |
        namespace := RBVariableNode
	    named: self driver currentNamespace name asString.
        fullNamespace := RBVariableNode
	    named: (self driver currentNamespace nameIn: Smalltalk).

	newNamespace := node arguments first name asSymbol.
	(self driver currentNamespace includesKey: newNamespace)
	    ifFalse: [
	        self evaluateMessageOn: namespace
	             selector: #addSubspace:
	             argument: node arguments first name asSymbol ].
           
        self evaluateStatement: node.       
	taggee := RBVariableNode named:
	    (self driver currentNamespace nameIn: Smalltalk).
        self parseDoits.
        self skipExpectedToken: $].

        "restore previous namespace"
	taggee := fullNamespace.
        node parent: nil.
        node arguments: { fullNamespace }.
        self evaluateStatement: node
    ]

    parseClassExtension: node [
        class := node receiver.
        self parseClassBody: true.
        class := nil
    ]
    
    parseClass: node [ 
        self evaluateMessageOn: (node receiver)
             selector: #subclass:environment:
             arguments: {node arguments first name asSymbol.
                         self driver currentNamespace}.
             
        class := node arguments first.
        self parseClassBody: false.
        class := nil.
    ]
    
    parseClassBody: extend [
	| addInstVars oldTaggee |
	oldTaggee := taggee.
	taggee := class.
	addInstVars := extend.
        [ self skipToken: $] ] whileFalse: [
	    addInstVars := self
		parseClassBodyElement: addInstVars
		withinExtend: extend ].
	taggee := oldTaggee.
    ]
    
    parseClassBodyElement: addInstVars withinExtend: extend [
        | node classNode |

	"drop comments"
        scanner getComments.
        
        "look for class tag"
        (currentToken value = #< and: [self nextToken isKeyword])
            ifTrue: [self parseClassTag. ^addInstVars].
        
        "look for class variable"
        (currentToken isIdentifier and: [self nextToken isAssignment])
            ifTrue: [self parseClassVariable. ^addInstVars].
            
        "class side"
        ((currentToken isIdentifier 
            and: [self nextToken isIdentifier])
            and: [self nextToken value = 'class'])
                ifTrue: [classNode := RBVariableNode identifierToken: currentToken.
                         self step.
    
                         (classNode = class)
                            ifTrue: ["look for class method"
                                     (self nextToken value = #>>)
                                        ifTrue: [self step. self step.
                                                 self parseMethodSourceOn: (self makeClassOf: classNode). 
                                                 ^addInstVars ].
                                            
                                     "look for metaclass"
                                     (self nextToken value = $[)
                                        ifTrue: [self parseMetaclass: extend.
                                                 ^addInstVars ].
                                        
                                     self parserError: 'invalid class body element'].
                          
                         "look for overriding class method"
                         self step.
                         (currentToken value = #>>)
                            ifTrue: ["TODO: check that classNode is a superclass of the current class"
                                     self step.
                                     self parseMethodSourceOn: (self makeClassOf: classNode).
                                     ^addInstVars]. 
                          
                          self parserError: 'invalid class body element' ].
                        
        "look for overriding method"
        (currentToken isIdentifier and: [self nextToken value = #>>])
            ifTrue: ["check that classNode is a superclass of the current class!!!"    
                     classNode := RBVariableNode identifierToken: currentToken.
                     self step. self step.
                     self parseMethodSourceOn: classNode.
                     ^addInstVars].
               
        node := self parseMessagePattern.
        
        "look for method"
        (self skipToken: $[)
            ifTrue: [self parseMethodSource: node. ^addInstVars].
        
        "look for instance variables"
        (node selectorParts first value = #|)
            ifTrue: [self parseInstanceVariables: node add: addInstVars. ^true].
            
        self parserError: 'invalid class body element'
    ]
    
    parseClassTag [
        | selector argument stmt |
        
        self skipExpectedToken: #<.
        
        (currentToken isKeyword)
            ifTrue: [selector := currentToken value asSymbol. self step]
            ifFalse: [self parserError: 'expected keyword'].
        
        argument := self parsePrimitiveObject.
        self skipExpectedToken: #>.
        
        stmt := RBMessageNode
    	             receiver: taggee
    	             selector: selector
    	             arguments: { argument }.
        self evaluateStatement: stmt.
    ]
    
    parseClassVariable [ 
        | node stmt name |
        
        node := self parseAssignment.
        node isAssignment
            ifFalse: [self parserError: 'expected assignment'].
        
        (self skipToken: $.) ifFalse: [
	    (currentToken value = $]) ifFalse: [
		self parserError: 'expected . or ]']].

        name := RBLiteralNode value: (node variable name asSymbol).
        node := self makeSequenceNode: node value.
        node := RBBlockNode body: node.
        
        stmt := RBMessageNode 
                receiver: class
                selector: #addClassVarName:value:
                arguments: { name . node }.

        self evaluateStatement: stmt.
    ]
    
    parseMetaclass: extend [
        | tmpClass |     
        
        self step. self step.
        tmpClass := class.
        class := self makeClassOf: class.
        self parseClassBody: extend.
        class := tmpClass
    ]
    
    parseMethodSource: patternNode [
        self parseMethodSource: patternNode on: class
    ]
    
    parseMethodSourceOn: classNode [
        | patternNode |
	"Drop comments before the message pattern"
        patternNode := self parseMessagePattern.
        self skipExpectedToken: $[.
        self parseMethodSource: patternNode on: classNode.
    ]
    
    parseMethodSource: patternNode on: classNode [
        | methodNode start stop |
        
        start := patternNode selectorParts first start - 1.
        methodNode := self parseMethodInto: patternNode.
        stop := currentToken start - 1.
        self skipExpectedToken: $].
        methodNode := self addSourceFrom: start to: stop to: methodNode.
        
        self evaluateMessageOn: classNode
             selector: #methodsFor:
             argument: nil.
        
        self compile: methodNode.
	self endMethodList.
    ]
    
    parseInstanceVariables: node add: addThem [
        | vars |
            
	vars := addThem
	    ifTrue: [
	        (self resolveClass: class) instVarNames
		    fold: [ :a :b | a, ' ', b ] ]
	    ifFalse: [ '' ].

        vars := vars, ' ', (node arguments at: 1) name.
        [currentToken isIdentifier]
            whileTrue: [vars := vars , ' ' , currentToken value.
        
                        self step ].       

        self skipExpectedToken: #|.
        self evaluateMessageOn: class 
             selector: #instanceVariableNames:
             argument: vars.
    ]
    
    evaluateMessageOn: rec selector: sel arguments: argSymbols [
        | stmt |
          
        stmt := RBMessageNode
            receiver: rec
            selector: sel
            arguments: (argSymbols collect: [:each | RBLiteralNode value: each]).
	    	    
        self evaluateStatement: stmt.
    ]
    
    evaluateMessageOn: rec selector: sel argument: argSymbol [
        self evaluateMessageOn: rec selector: sel arguments: { argSymbol }
    ]
    
    evaluateStatement: node [
	^self evaluate: (self makeSequenceNode: node)
    ]
    
    evaluate: seq [
	| emptySeq |
	(currentDeclaration notNil and: [ currentDeclaration comments notEmpty ])
	    ifTrue: [
		seq parent isNil
		    ifTrue: [
			seq comments: currentDeclaration comments.
			seq parent: currentDeclaration parent ]
		    ifFalse: [
			emptySeq := self makeSequenceNode.
			emptySeq comments: currentDeclaration comments.
			emptySeq parent: currentDeclaration parent.
			super evaluate: emptySeq ] ].
	currentDeclaration := nil.
        ^super evaluate: seq
    ]

    makeSequenceNode [
        | seq |
	seq := RBSequenceNode
            leftBar: nil
            temporaries: #()
            rightBar: nil.
        seq periods: #().
        seq statements: #().
	^seq
    ]
    
    makeSequenceNode: stmt [
        ^self makeSequenceNode statements: { stmt }.
    ]
    
    makeClassOf: node [
        ^RBMessageNode
    	    receiver: node
    	    selector: #class
    	    arguments: #()
    ]

    skipToken: tokenValue [
        (currentToken value = tokenValue)
            ifTrue: [self step. ^true]
            ifFalse: [^false]
    ]
    
    skipExpectedToken: tokenValue [
        (self skipToken: tokenValue)
            ifFalse: [self parserError: ('expected ' , tokenValue asSymbol)]
    ]
]
