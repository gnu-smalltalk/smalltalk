"======================================================================
|
|   Smalltalk in Smalltalk compiler - code to enable the compiler
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


Behavior extend [

    evaluatorClass [
	"Answer the class to be used by an STEvaluationDriver to parse
	 method definition chunks for this class, and by my own evaluating
	 methods to parse expressions.
	 
	 In the former case, an instance of the class will be created and
	 sent #parseMethodDefinitionList, or the same will be done with
	 the currently active parser (the one that parsed the doit that
	 sent #methodsFor:, which cannot be so easily changed in the
	 current framework) if this method answers nil."

	<category: 'compiling'>
	^STInST.GSTFileInParser
    ]

    parserClass [
	"Answer the class used by to parse methods passed to #compile:."

	<category: 'compiling'>
	^STInST.RBBracketedMethodParser
    ]

]



Stream extend [

    fileInLine: lineNum file: aFile at: charPosInt [
	<category: 'file-in'>
	
	([charPosInt = self position] on: Error do: [ :ex | ex return: true ])
	     ifFalse: [self notYetImplemented].

	[STInST.STSymbolTable nowInsideFileIn.
	STInST.STEvaluationDriver new parseSmalltalkStream: self
	    with: STInST.GSTFileInParser] 
		ensure: [STInST.STSymbolTable nowOutsideFileIn]
    ]

    fileInLine: lineNum file: aFile fileName: aString at: charPosInt [
	<category: 'file-in'>
	
        ^self fileInLine: lineNum file: aFile at: charPosInt 
    ]

]



Behavior extend [

    evalString: aString to: anObject [
	<category: 'compiling'>
	^STInST.STEvaluationDriver new parseSmalltalk: aString
	    with: self evaluatorClass
    ]

    evalString: aString to: anObject ifError: aBlock [
	<category: 'compiling'>
	^STInST.STEvaluationDriver new 
	    parseSmalltalk: aString
	    with: self evaluatorClass
	    onError: 
		[:m :l | 
		^aBlock 
		    value: 'a Smalltalk String'
		    value: l
		    value: m]
    ]

    compile: code [
	"Compile code as method source, which may be a stream, a parse
	 node, or anything that responds to #asString.  If there are
	 parsing errors, answer nil.  Else, answer a CompiledMethod, the
	 result of compilation."

	<category: 'compiling'>
	^self compile: code ifError: [:f :l :m | nil]
    ]

    compile: code ifError: block [
	"Compile code as method source, which may be a stream, a parse
	 node, or anything that responds to #asString.  If there are
	 parsing errors, invoke exception block, 'block' passing file
	 name, line number and error.  Answer a CompiledMethod, the result
	 of compilation."

	<category: 'compiling'>
	(self compilerClass canCompile: code) 
	    ifTrue: 
		[| dummyParser |
		dummyParser := self parserClass new.
		dummyParser errorBlock: 
			[:m :l | 
			^block 
			    value: 'a Smalltalk %1' % {code class}
			    value: l - 1
			    value: m].
		^self compilerClass 
		    compile: code
		    for: self
		    classified: nil
		    parser: dummyParser].
	(code isKindOf: WriteStream) 
	    ifTrue: [^self primCompile: code readStream ifError: block].
	(code isKindOf: Stream) ifTrue: [^self primCompile: code ifError: block].
	^self primCompile: code asString ifError: block
    ]

    primCompile: aString [
	"Compile aString, which should be a string or stream, as a method
	 for my instances, installing it in my method dictionary.  Signal
	 an error if parsing or compilation fail, otherwise answer the
	 resulting CompiledMethod."

	<category: 'compiling'>
	| parser source |
	source := aString isString 
		    ifTrue: [aString]
		    ifFalse: [source := aString contents].
	parser := self parserClass new.
	parser initializeParserWith: source type: #on:errorBlock:.
	^self compilerClass 
	    compile: (parser parseMethod: source)
	    for: self
	    classified: nil
	    parser: parser
    ]

    primCompile: aString ifError: aBlock [
	<category: 'compiling'>
	| parser source |
	source := aString isString 
		    ifTrue: [aString]
		    ifFalse: [source := aString contents].
	parser := self parserClass new.
	parser errorBlock: 
		[:m :l | 
		^aBlock 
		    value: 'a Smalltalk ' , aString class printString
		    value: l - 1
		    value: m].
	parser initializeParserWith: source type: #on:errorBlock:.
	^self compilerClass 
	    compile: (parser parseMethod: source)
	    for: self
	    classified: nil
	    parser: parser
    ]

    basicMethodsFor: category ifTrue: condition [
	"Compile the following code inside the receiver, with the given category,
	 if condition is true; else ignore it - included just to be sure"

	<category: 'compiling'>
	<primitive: VMpr_Behavior_methodsForIfTrue>
	^self primitiveFailed
    ]

    methodsFor: aString [
	<category: 'compiling'>
	self methodsFor: aString ifTrue: true
    ]

    methodsFor: aString ifTrue: realCompile [
	<category: 'compiling'>
	^STInST.STEvaluationDriver 
	    methodsFor: aString
	    parsingWith: self evaluatorClass
	    compiler: (realCompile 
		    ifTrue: [self compilerClass]
		    ifFalse: [STInST.STFakeCompiler])
	    class: self
    ]

]

