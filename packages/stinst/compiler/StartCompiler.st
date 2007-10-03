"======================================================================
|
|   Smalltalk in Smalltalk compiler - code to enable the compiler
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2006 Free Software Foundation, Inc.
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


Object subclass: #STParserScanner
       instanceVariableNames: 'parser scanner unusedTokens'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STParserScanner comment:
'I provide RBScanner''s important protocols for use in another Parser
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
	See #unusedTokens:.'
!

STParsingDriver subclass: #STEvaluationDriver
       instanceVariableNames: 'curCategory curClass curCompilerClass evalFor lastResult method'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STEvaluationDriver comment:
'I am an STParsingDriver that compiles code that you file in.'!

!STParserScanner class methodsFor: 'instance creation'!

overscanFrom: aParser scanning: aScanner
    "Answer a new instances that treats aParser's implicit scanner
     token sequence as my own."
    ^self new parser: aParser scanner: aScanner; yourself
! !

!STParserScanner methodsFor: 'accessing'!

atEnd
    ^unusedTokens isEmpty
	ifTrue: [scanner atEnd]
	ifFalse: [unusedTokens first isMemberOf: RBToken]
!

next
    ^unusedTokens isEmpty
	ifTrue: [scanner next]
	ifFalse: [unusedTokens removeFirst]
!

getComments
    ^scanner getComments
!

stream
    ^scanner stream
!

stripSeparators
    "I don't know why RBParser sends this, but here it is."
    ^scanner stripSeparators
!

unusedTokens: tokens
    "Make `tokens' a list that should be reread by any parser that
     takes control of the effective token stream."
    unusedTokens addAllFirst: tokens.
! !

!STParserScanner methodsFor: 'private'!

unusedTokens
    "Information used by a parser to (re)set its internal state."
    ^unusedTokens
!

parser: aParser scanner: aScanner
    parser := aParser.
    scanner := aScanner.
    unusedTokens := OrderedCollection new: 2.
! !

!RBParser methodsFor: 'accessing'!

unusedTokens
    "Answer the tokens I have read from the scanner but not
     processed."
    ^{currentToken. nextToken} copyWithout: nil
!

releaseScannerTo: aBlock
    "Invoke aBlock with my effective scanner, during which that
     scanner can be owned by a different parser.  After aBlock exits,
     I assume that I own the scanner's token stream again.  Answer
     aBlock's result.

     If you read tokens from the scanner, but don't use them, you must
     push them back on with #unusedTokens:."
    | delegateScanner |
    delegateScanner := STParserScanner overscanFrom: self scanning: scanner.
    delegateScanner unusedTokens: self unusedTokens.
    ^[aBlock value: delegateScanner]
	ensure: [| unused |
		 unused := delegateScanner unusedTokens.
		 currentToken := unused at: 1 ifAbsent: [nil].
		 nextToken := unused at: 2 ifAbsent: [nil].
		 unused size > 2 ifTrue:
		     [SystemExceptions.InvalidValue
			  signalOn: unused
			  reason: 'too many enqueued tokens']]
! !

!STEvaluationDriver class methodsFor: 'accessing'!

methodsFor: aString parsingWith: parser compiler: compilerClass class: aClass
    "Search the current context stack for another evaluation driver,
     copy its error block and scanner to a new instance of `parser',
     and compile the method definition list following the #methodsFor:
     invocation implied by this message that was just read by that
     other evaluation driver/parser.  Answer the new instance of
     myself.

     If the outer driver's parser is the same, just reuse that
     driver/parser combo instead."
    | ctx driver |
    ctx := thisContext.
    [ ctx selector == #evaluate: ] whileFalse: [
	ctx := ctx parentContext.

	ctx isNil ifTrue: [
	    ^aClass
	        basicMethodsFor: aString
	        ifTrue: compilerClass ~~ STFakeCompiler
        ]
    ].

    "Optimization where #evaluatorClass is left alone: If the outer
     parser has the same class as the parser I will create, change the
     outer driver to #compile: for my arguments."
    (parser isNil or: [ctx receiver parser isMemberOf: parser])
	ifTrue: [^ctx receiver methodsFor: aString
			       compiler: compilerClass
			       class: aClass; yourself].

    driver := self new.
    driver methodsFor: aString
	   compiler: compilerClass
	   class: aClass.
    ctx receiver parser releaseScannerTo: [:scanner | | parseProc |
	(parseProc := parser new)
	    errorBlock: ctx receiver errorBlock;
	    scanner: scanner;
	    driver: driver;
	    parseMethodDefinitionList.
	scanner unusedTokens: parseProc unusedTokens].
    ^driver
! !

!STEvaluationDriver methodsFor: 'accessing'!

evalFor: anObject
    evalFor := anObject
!

result
    ^lastResult
!

methodsFor: aString compiler: compilerClass class: aClass
    curCategory := aString.
    curClass := aClass.
    curCompilerClass := compilerClass
! !

!STEvaluationDriver methodsFor: 'overrides'!

compile: node
    method := curCompilerClass
	compile: node
	for: curClass
	classified: curCategory
	parser: self.
!

endMethodList
    curClass := nil
!

evaluate: node
    | method |
    method := evalFor class compilerClass
	compile: node
	asMethodOf: evalFor class
	classified: nil
	parser: self
	environment: Namespace current.

    [ lastResult := evalFor perform: method ] valueWithUnwind.
    ^curClass notNil
!

record: string
    "Transcript nextPutAll: string; nl"
! !

!Smalltalk.Behavior methodsFor: 'compiling'!

compilerClass
    "This method is present for symmetry with #parserClass.  It
     specifies the class that will be used to compile the parse
     nodes into bytecodes."
    ^STInST.STCompiler
!

evaluatorClass
    "Answer the class to be used by an STEvaluationDriver to parse
     method definition chunks for this class, and by my own evaluating
     methods to parse expressions.

     In the former case, an instance of the class will be created and
     sent #parseMethodDefinitionList, or the same will be done with
     the currently active parser (the one that parsed the doit that
     sent #methodsFor:, which cannot be so easily changed in the
     current framework) if this method answers nil."
    ^STInST.GSTFileInParser
!

parserClass
    "Answer the class to be used by my method-compiling methods to
     parse methods for delivery to my #compilerClass."
    ^STInST.RBParser
! !



"Final definitions to start the compiler..."

!Smalltalk.Stream methodsFor: 'file-in'!

fileIn
    [
	STInST.STSymbolTable nowInsideFileIn.
	STInST.STEvaluationDriver new
	    parseSmalltalkStream: self
	    with: STInST.GSTFileInParser ]

	    ensure: [ STInST.STSymbolTable nowOutsideFileIn ]
! !

!Smalltalk.Behavior methodsFor: 'compiling'!

evalString: aString to: anObject
    ^STInST.STEvaluationDriver new
	parseSmalltalk: aString with: self evaluatorClass
!

evalString: aString to: anObject ifError: aBlock
    ^STInST.STEvaluationDriver new
	parseSmalltalk: aString
	with: self evaluatorClass
	errorBlock: [ :l :m |
	    ^aBlock value: 'a Smalltalk String' value: l value: m.
	]
!

compile: code
    "Compile code as method source, which may be a stream, a parse
     node, or anything that responds to #asString.  If there are
     parsing errors, answer nil.  Else, answer a CompiledMethod, the
     result of compilation."
    ^self compile: code ifError: [:f :l :m | nil]
!

compile: code ifError: block
    "Compile code as method source, which may be a stream, a parse
     node, or anything that responds to #asString.  If there are
     parsing errors, invoke exception block, 'block' passing file
     name, line number and error.  Answer a CompiledMethod, the result
     of compilation."
    (self compilerClass canCompile: code)
	ifTrue: [| dummyParser |
		 dummyParser := self parserClass new.
		 dummyParser errorBlock: [:m :l |
		     ^block value: 'a Smalltalk %1' % {code class}
			    value: l - 1 value: m].
		 ^self compilerClass
		     compile: code for: self
		     classified: nil parser: dummyParser].
    (code isKindOf: WriteStream)
    	ifTrue: [ ^self primCompile: code readStream ifError: block ].
    (code isKindOf: Stream)
    	ifTrue: [ ^self primCompile: code ifError: block ].

    ^self primCompile: code asString ifError: block
!

primCompile: aString
    "Compile aString, which should be a string or stream, as a method
     for my instances, installing it in my method dictionary.  Signal
     an error if parsing or compilation fail, otherwise answer the
     resulting CompiledMethod."
    | parser source |
    source := aString isString
	ifTrue: [ aString ]
	ifFalse: [ source := aString contents ].
    parser := self parserClass new.
    parser initializeParserWith: source type: #on:errorBlock:.

    ^self compilerClass
	compile: (parser parseMethod: source)
	for: self
	classified: nil
	parser: parser
!

primCompile: aString ifError: aBlock
    | parser source |
    source := aString isString
	ifTrue: [ aString ]
	ifFalse: [ source := aString contents ].

    parser := self parserClass new.
    parser errorBlock: [ :m :l |
		    ^aBlock value: 'a Smalltalk ', aString class printString
			value: l - 1 value: m ].
    parser initializeParserWith: source type: #on:errorBlock:.

    ^self compilerClass
	compile: (parser parseMethod: source)
	for: self
	classified: nil
	parser: parser
!

basicMethodsFor: category ifTrue: condition
    "Compile the following code inside the receiver, with the given category,
     if condition is true; else ignore it - included just to be sure"
    <primitive: VMpr_Behavior_methodsForIfTrue>
    ^self primitiveFailed
!

methodsFor: aString
    self methodsFor: aString ifTrue: true
!

methodsFor: aString ifTrue: realCompile
    ^STInST.STEvaluationDriver
	methodsFor: aString
	parsingWith: self evaluatorClass
	compiler: (realCompile
	    ifTrue: [ self compilerClass ]
	    ifFalse: [ STInST.STFakeCompiler ])
	class: self
! !
