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


STParsingDriver subclass: #STEvaluationDriver
       instanceVariableNames: 'curCategory curClass curCompilerClass evalFor lastResult method'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STEvaluationDriver comment:
'I am an STParsingDriver that compiles code that you file in.'!

!STEvaluationDriver class methodsFor: 'accessing'!

methodsFor: aString compiler: compilerClass class: aClass
    | ctx |
    ctx := thisContext.
    [ ctx selector == #evaluate: ] whileFalse: [
	ctx := ctx parentContext.

	ctx isNil ifTrue: [
	    ^aClass
	        basicMethodsFor: aString
	        ifTrue: compilerClass ~~ STFakeCompiler
        ]
    ].

    self == ctx receiver class ifTrue: [
	^ctx receiver
	    methodsFor: aString
	    compiler: compilerClass
	    class: aClass
    ].

    "Create a new parser and invoke it.  It will eat the text from 
     the current parser, which will be automagically fooled..."
    ^self new
	errorBlock: ctx receiver errorBlock;
	scanner: ctx receiver scanner;

	methodsFor: aString
	compiler: compilerClass
	class: aClass;

	parseMethodDefinitionList;
	yourself
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
    "This method is present for symmetry with #parserClass.  It
     specifies the class that will be used to drive evaluation
     of Smalltalk source code."
    ^STInST.STFileInParser
!

parserClass
    "This method specifies which class will be used by an
     STEvaluationDriver to parse method definition chunk.  An instance of
     the class will be created and sent #parseMethodDefinitionList,
     or the same will be done with the currently active parser
     (the one that parsed the doit that sent #methodsFor:) if
     this method answers nil."
    ^STInST.RBParser
! !



"Final definitions to start the compiler..."

!Smalltalk.Stream methodsFor: 'file-in'!

fileIn
    [
	STInST.STSymbolTable nowInsideFileIn.
	STInST.STEvaluationDriver new
	    parseSmalltalkStream: self
	    with: STInST.STFileInParser ]

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

compileString: aString
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

compileString: aString ifError: aBlock
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
    self evaluatorClass
	methodsFor: aString
	compiler: (realCompile
	    ifTrue: [ self compilerClass ]
	    ifFalse: [ STInST.STFakeCompiler ])
	class: self
! !
