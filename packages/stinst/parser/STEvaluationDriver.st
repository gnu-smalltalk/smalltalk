"======================================================================
|
|   Smalltalk in Smalltalk compiler - STParsingDriver that evaluates code
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2006,2007,2008, 2009 Free Software Foundation, Inc.
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



Object subclass: STParserScanner [
    | parser scanner unusedTokens |
    
    <category: 'System-Compiler'>
    <comment: 'I provide RBScanner''s important protocols for use in another Parser
by extracting tokens from a scanner owned by a particular parser.  In
other words, by giving me to another parser, you can subcontract
parsing from one parser to the other.

My main purpose is to account for lookahead tokens, so they are not
hidden from other objects trying to work with a RBParser''s scanner.

    parser
	The parser I come from.
    scanner
	Said parser''s real scanner.
    unusedTokens
	See #unusedTokens:.'>

    STParserScanner class >> overscanFrom: aParser scanning: aScanner [
	"Answer a new instances that treats aParser's implicit scanner
	 token sequence as my own."

	<category: 'instance creation'>
	^(self new)
	    parser: aParser scanner: aScanner;
	    yourself
    ]

    atEnd [
	<category: 'accessing'>
	^unusedTokens isEmpty 
	    ifTrue: [scanner atEnd]
	    ifFalse: [unusedTokens first isMemberOf: RBToken]
    ]

    next [
	<category: 'accessing'>
	^unusedTokens isEmpty 
	    ifTrue: [scanner next]
	    ifFalse: [unusedTokens removeFirst]
    ]

    getComments [
	<category: 'accessing'>
	^scanner getComments
    ]

    stream [
	<category: 'accessing'>
	^scanner stream
    ]

    stripSeparators [
	"I don't know why RBParser sends this, but here it is."

	<category: 'accessing'>
	^scanner stripSeparators
    ]

    unusedTokens: tokens [
	"Make `tokens' a list that should be reread by any parser that
	 takes control of the effective token stream."

	<category: 'accessing'>
	unusedTokens addAllFirst: tokens
    ]

    unusedTokens [
	"Information used by a parser to (re)set its internal state."

	<category: 'private'>
	^unusedTokens
    ]

    parser: aParser scanner: aScanner [
	<category: 'private'>
	parser := aParser.
	scanner := aScanner.
	unusedTokens := OrderedCollection new: 2
    ]
]


STParsingDriver subclass: STEvaluationDriver [
    | curCategory curClass curCompilerClass evalFor lastResult method |
    
    <comment: 'I am an STParsingDriver that compiles code that you file in.'>
    <category: 'System-Compiler'>

    STEvaluationDriver class >> methodsFor: aString parsingWith: parser compiler: compilerClass class: aClass [
	"Search the current context stack for another evaluation driver,
	 copy its error block and scanner to a new instance of `parser',
	 and compile the method definition list following the #methodsFor:
	 invocation implied by this message that was just read by that
	 other evaluation driver/parser.  Answer the new instance of
	 myself.
	 
	 If the outer driver's parser is the same, just reuse that
	 driver/parser combo instead."

	<category: 'accessing'>
	| ctx driver |
	ctx := thisContext.
	[ctx selector == #evaluate:] whileFalse: 
		[ctx := ctx parentContext.
		ctx isNil 
		    ifTrue: 
			[^aClass basicMethodsFor: aString ifTrue: compilerClass ~~ STFakeCompiler]].

	"Optimization where #evaluatorClass is left alone: If the outer
	 parser has the same class as the parser I will create, change the
	 outer driver to #compile: for my arguments."
	(parser isNil or: [ctx receiver parser isMemberOf: parser]) 
	    ifTrue: 
		[^(ctx receiver)
		    methodsFor: aString
			compiler: compilerClass
			class: aClass;
		    yourself].
	driver := self new.
	driver 
	    methodsFor: aString
	    compiler: compilerClass
	    class: aClass.
	ctx receiver parser releaseScannerTo: 
		[:scanner | 
		| parseProc |
		(parseProc := parser new)
		    errorBlock: ctx receiver errorBlock;
		    scanner: scanner;
		    driver: driver;
		    parseMethodDefinitionList.
		scanner unusedTokens: parseProc unusedTokens].
	^driver
    ]

    evalFor: anObject [
	<category: 'accessing'>
	evalFor := anObject
    ]

    result [
	<category: 'accessing'>
	^lastResult
    ]

    methodsFor: aString compiler: compilerClass class: aClass [
	<category: 'accessing'>
	curCategory := aString.
	curClass := aClass.
	curCompilerClass := compilerClass
    ]

    compile: node [
	<category: 'overrides'>
	method := curCompilerClass 
		    compile: node
		    for: curClass
		    classified: curCategory
		    parser: self.
	^method
    ]

    endMethodList [
	<category: 'overrides'>
	curClass := nil
    ]

    evaluate: node [
	<category: 'overrides'>
	| method |
	method := evalFor class compilerClass 
		    compile: node
		    asMethodOf: evalFor class
		    classified: nil
		    parser: self
		    environment: Namespace current.
	[lastResult := evalFor perform: method] valueWithUnwind.
	^curClass notNil
    ]

    record: string [
	"Transcript nextPutAll: string; nl"

	<category: 'overrides'>
	
    ]
]



RBParser extend [

    unusedTokens [
	"Answer the tokens I have read from the scanner but not
	 processed."

	<category: 'accessing'>
	^
	{currentToken.
	nextToken} copyWithout: nil
    ]

    releaseScannerTo: aBlock [
	"Invoke aBlock with my effective scanner, during which that
	 scanner can be owned by a different parser.  After aBlock exits,
	 I assume that I own the scanner's token stream again.  Answer
	 aBlock's result.
	 
	 If you read tokens from the scanner, but don't use them, you must
	 push them back on with #unusedTokens:."

	<category: 'accessing'>
	| delegateScanner |
	delegateScanner := STParserScanner overscanFrom: self scanning: scanner.
	delegateScanner unusedTokens: self unusedTokens.
	^[aBlock value: delegateScanner] ensure: 
		[| unused |
		unused := delegateScanner unusedTokens.
		currentToken := unused at: 1 ifAbsent: [nil].
		nextToken := unused at: 2 ifAbsent: [nil].
		unused size > 2 
		    ifTrue: 
			[SystemExceptions.InvalidValue signalOn: unused
			    reason: 'too many enqueued tokens']]
    ]

]


Behavior extend [

    compilerClass [
	"Return the class that will be used to compile the parse
	 nodes into bytecodes."

	<category: 'compiling'>
	^STInST.STCompiler
    ]

]
