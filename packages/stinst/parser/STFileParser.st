"======================================================================
|
|   Smalltalk in Smalltalk file-in driver
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2006,2007,2008,2009 Free Software Foundation, Inc.
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


RBParser subclass: STFileParser [
    | driver |
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    STFileParser class >> parseSmalltalk: aString with: aDriver [
	<category: 'accessing'>
	^self 
	    parseSmalltalk: aString
	    with: aDriver
	    onError: nil
    ]

    STFileParser class >> parseSmalltalk: aString with: aDriver onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #on:errorBlock:.
	parser driver: aDriver.
	^parser parseSmalltalk
    ]

    STFileParser class >> parseSmalltalkStream: aStream with: aDriver [
	<category: 'accessing'>
	^self 
	    parseSmalltalkStream: aStream
	    with: aDriver
	    onError: nil
    ]

    STFileParser class >> parseSmalltalkStream: aStream with: aDriver onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWithStream: aStream type: #on:errorBlock:.
	parser driver: aDriver.
	^parser parseSmalltalk
    ]

    driver [
	<category: 'accessing'>
	^driver
    ]

    driver: aSTParsingDriver [
	<category: 'accessing'>
	driver := aSTParsingDriver.
	driver parser: self
    ]

    parseSmalltalk [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    compile: node [
	<category: 'overridable - parsing file-ins'>
	^driver compile: node
    ]

    endMethodList [
	<category: 'overridable - parsing file-ins'>
	driver endMethodList
    ]

    resolveClass: node [
	<category: 'overridable - parsing file-ins'>
	self evaluate: node.
	^self result
    ]

    evaluate: node [
	"This should be overridden because its result affects the parsing
	 process: true means 'start parsing methods', false means 'keep
	 evaluating'."

	<category: 'overridable - parsing file-ins'>
	^node notNil and: [node statements size > 0 and: [driver evaluate: node]]
    ]

    parseStatements [
	<category: 'utility'>
	(currentToken isSpecial and: [currentToken value == $!]) 
	    ifTrue: [^RBSequenceNode statements: #()].
	^self parseStatements: false
    ]

    parseDoit [
	<category: 'utility'>
	| node start stop comments |
	comments := scanner getComments.
	start := comments isNil 
		    ifTrue: [currentToken start - 1]
		    ifFalse: [comments first first - 1].
	tags := nil.
	node := self parseStatements.
        node addReturn.
	node comments isNil 
	    ifTrue: [node comments: comments]
	    ifFalse: [comments isNil ifFalse: [node comments: node comments , comments]].

	"One -1 accounts for base-1 vs. base-0 (as above), the
	 other drops the bang because we have a one-token lookahead."
	stop := currentToken start - 2.
	^self 
	    addSourceFrom: start
	    to: stop
	    to: node
    ]

    addSourceFrom: start to: stop to: node [
	<category: 'utility'>
	| method source |
	node isMethod 
	    ifTrue: [method := node]
	    ifFalse: 
		[method := RBMethodNode selectorParts: #() arguments: #().
		node parent: method].
	source := MappedSourceCode on: scanner from: start to: stop.
	method source: source.
	^node
    ]
]



Object subclass: STParsingDriver [
    | parser |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    parseSmalltalk: aString with: aParserClass [
	<category: 'starting the parsing'>
	^aParserClass parseSmalltalk: aString with: self
    ]

    parseSmalltalk: aString with: aParserClass onError: aBlock [
	<category: 'starting the parsing'>
	^aParserClass 
	    parseSmalltalk: aString
	    with: self
	    onError: aBlock
    ]

    parseSmalltalkStream: aStream with: aParserClass [
	<category: 'starting the parsing'>
	^aParserClass parseSmalltalkStream: aStream with: self
    ]

    parseSmalltalkStream: aStream with: aParserClass onError: aBlock [
	<category: 'starting the parsing'>
	^aParserClass 
	    parseSmalltalkStream: aStream
	    with: self
	    onError: aBlock
    ]

    parseSmalltalkFileIn: aFilename with: aParserClass [
	<category: 'starting the parsing'>
	^self 
	    parseSmalltalkFileIn: aFilename
	    with: aParserClass
	    onError: nil
    ]

    parseSmalltalkFileIn: aFilename with: aParserClass onError: aBlock [
	<category: 'starting the parsing'>
	| parser file |
	file := FileStream open: aFilename mode: FileStream read.
	
	[self 
	    parseSmalltalkStream: file
	    with: aParserClass
	    onError: aBlock] 
		ensure: [file close]
    ]

    errorBlock [
	<category: 'accessing'>
	^parser errorBlock
    ]

    parserWarning: aString [
	<category: 'accessing'>
	parser parserWarning: aString
    ]

    parserError: aString [
	<category: 'accessing'>
	parser parserError: aString
    ]

    parser [
	<category: 'accessing'>
	^parser
    ]

    parser: aSTFileParser [
	<category: 'accessing'>
	parser := aSTFileParser
    ]

    result [
	"return self by default"

	<category: 'overridable - parsing file-ins'>
	^self
    ]

    compile: node [
	"do nothing by default"

	<category: 'overridable - parsing file-ins'>
	^nil
    ]

    endMethodList [
	"do nothing by default"

	<category: 'overridable - parsing file-ins'>
	
    ]

    evaluate: node [
	"This should be overridden because its result affects the parsing
	 process: true means 'start parsing methods', false means 'keep
	 evaluating'. By default, always answer false."

	<category: 'overridable - parsing file-ins'>
	^false
    ]

    currentNamespace [
	<category: 'overridable - parsing file-ins'>
	^Namespace current
    ]
]



STFileParser subclass: STFileInParser [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    parseSmalltalk [
	<category: 'private-parsing'>
	[self parseDoits] whileTrue: [self parseMethodDefinitionList].
        self atEnd ifFalse: [self parserError: 'doit expected'].
	^driver result
    ]

    scannerClass [
	<category: 'private-parsing'>
	^STFileScanner
    ]

    parseDoits [
	"Parses the stuff to be executed until a
	 ! <class expression> methodsFor: <category string> !"

	<category: 'private-parsing'>
	| node |
	
	[self atEnd ifTrue: [^false].
	node := self parseDoit.
	scanner stripSeparators.
	self evaluate: node] 
		whileFalse: 
		    [(currentToken isSpecial and: [currentToken value == $!]) 
			ifTrue: [self step]].
	^true
    ]

    parseMethodFromFile [
	<category: 'private-parsing'>
	| node source start stop |
	start := currentToken start - 1.
	tags := nil.
	node := self parseMethod.
	node comments: (node comments select: [:each | each last >= start]).

	"One -1 accounts for base-1 vs. base-0 (as above), the
	 other drops the bang because we have a one-token lookahead."
	stop := currentToken start - 2.
	node := self 
		    addSourceFrom: start
		    to: stop
		    to: node.
	scanner stripSeparators.
	self step.	"gobble method terminating bang"
	^node
    ]

    parseMethodDefinitionList [
	"Called after first !, expecting a set of bang terminated
	 method definitions, followed by a bang"

	<category: 'private-parsing'>
	| method |

	self step.	"gobble doit terminating bang"
	[scanner atEnd or: [currentToken isSpecial and: [currentToken value == $!]]] 
	    whileFalse: [
		method := self compile: self parseMethodFromFile.
		method isNil ifFalse: [method noteOldSyntax]].
	scanner stripSeparators.
	self step.
	self endMethodList
    ]
]



RBScanner subclass: STFileScanner [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    next [
	<category: 'accessing'>
	| token |
	buffer reset.
	tokenStart := stream position.
	characterType == #eof ifTrue: [^RBToken start: tokenStart + 1].	"The EOF token should occur after the end of input"
	token := self scanToken.
	(token isSpecial and: [token value == $!]) ifFalse: [self stripSeparators].
	^token
    ]
]



PositionableStream extend [

    name [
	"Answer a string that represents what the receiver is streaming on"

	<category: 'compiling'>
	^'(%1 %2)' % 
		{self species article.
		self species name}
    ]


    segmentFrom: startPos to: endPos [
	"Answer an object that, when sent #asString, will yield the result
	 of sending `copyFrom: startPos to: endPos' to the receiver"

	<category: 'compiling'>
	^self copyFrom: startPos to: endPos
    ]

]


Stream extend [

    segmentFrom: startPos to: endPos [
	"Answer an object that, when sent #asString, will yield the result
	 of sending `copyFrom: startPos to: endPos' to the receiver"

	<category: 'compiling'>
	^nil
    ]

]

FileStream extend [

    segmentFrom: startPos to: endPos [
	"Answer an object that, when sent #asString, will yield the result
	 of sending `copyFrom: startPos to: endPos' to the receiver"

	<category: 'compiling'>
	self isPipe ifTrue: [^nil].
	^FileSegment 
	    on: self file
	    startingAt: startPos
	    for: endPos - startPos + 1
    ]

]

MappedCollection subclass: MappedSourceCode [
    <comment: 'This class is a hack.  It allows the positions in the tokens
and in the comments to be file-based, while at the same time only the source
code of the method is kept in memory.'>
    <category: 'Refactory-Parser'>

    | sourceCode |

    MappedSourceCode class >> on: aScanner from: start to: stop [
	<category: 'instance creation'>
	| collection coll sourceCode |
	collection := aScanner stream copyFrom: start to: stop.
	coll := self collection: collection map: (1 - start to: stop).
	sourceCode := (aScanner stream segmentFrom: start to: stop)
			ifNil: [collection].
	coll sourceCode: sourceCode.
	^coll
    ]

    asString [
	<category: 'conversion'>
	^self domain asString
    ]

    asSourceCode [
	<category: 'conversion'>
	^sourceCode
    ]

    sourceCode: anObject [
	<category: 'private - initialization'>
	sourceCode := anObject
    ]
]

Object extend [
    asSourceCode [
	<category: 'private-compilation'>
	^self
    ]
]

