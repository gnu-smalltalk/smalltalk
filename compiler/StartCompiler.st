"======================================================================
|
|   Smalltalk in Smalltalk compiler - code to enable the compiler
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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


Namespace current: STInST!

RBParser subclass: #STFileInParser
       instanceVariableNames: 'curCategory curClass curCompilerClass evalFor lastResult method'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STFileInParser comment:
'I am a STParser that compiles code that you file in.'!

!STFileInParser class methodsFor: 'accessing'!

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

!STFileInParser methodsFor: 'accessing'!

evalFor: anObject
    evalFor := anObject
!

lastResult
    ^lastResult
!

result
    "This is what #parseSmalltalk answers"
    ^method
!

methodsFor: aString compiler: compilerClass class: aClass
    curCategory := aString.
    curClass := aClass.
    curCompilerClass := compilerClass
! !

!STFileInParser methodsFor: 'overrides'!

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
    method := STCompiler
	compile: node
	asMethodOf: evalFor class
	classified: nil
	parser: self.

    [ lastResult := evalFor perform: method ] valueWithUnwind.
    ^curClass notNil
!

record: string
    "Transcript nextPutAll: string; nl"
! !

Namespace current: Smalltalk!

!Behavior methodsFor: 'compiling'!

compilerClass
    "This method is present for symmetry with #parserClass.  It
     specifies the class that will be used to compile the parse
     nodes into bytecodes."
    ^STInST.STCompiler
!

parserClass
    "This method specifies which class will be used by an
     STFileInParser to parse method definition chunk.  An instance of
     the class will be created and sent #parseMethodDefinitionList,
     or the same will be done with the currently active parser
     (the one that parsed the doit that sent #methodsFor:) if
     this method answers nil."
    ^STInST.STFileInParser
! !



"Final definitions to start the compiler..."

!FileStream methodsFor: 'file-in'!

fileIn
    STInST.STSymbolTable nowInsideFileIn.
    STInST.STFileInParser parseSmalltalkStream: self.
    STInST.STSymbolTable nowOutsideFileIn.
! !

!Behavior methodsFor: 'compiling'!

evalString: aString to: anObject
    ^STInST.STFileInParser new
	errorBlock: nil;
	initializeParserWith: aString type: #on:errorBlock:;
	evalFor: anObject;
	parseSmalltalk;
	lastResult
!

evalString: aString to: anObject ifError: aBlock
    ^STInST.STFileInParser new
	errorBlock: [ :l :m |
	    ^aBlock value: 'a Smalltalk String' value: l value: m.
	];
	initializeParserWith: aString type: #on:errorBlock:;
	evalFor: anObject;
	parseSmalltalk;
	lastResult
!

compileString: aString
    | codeWithHeader |
    codeWithHeader := '!%1 methodsFor: nil!%2! !'
	bindWith: self printString
	with: aString.

    ^STInST.STFileInParser parseSmalltalk: codeWithHeader
!

compileString: aString ifError: aBlock
    | codeWithHeader |
    codeWithHeader := '!%1 methodsFor: nil!
%2! !'
	bindWith: self name
	with: aString.

    ^STInST.STFileInParser
	parseSmalltalk: codeWithHeader
	onError: [ :f :l :m |
	    ^aBlock value: 'a Smalltalk String' value: l - 1 value: m.
	]
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
    self parserClass
	methodsFor: aString
	compiler: (realCompile
	    ifTrue: [ self compilerClass ]
	    ifFalse: [ STInST.STFakeCompiler ])
	class: self
! !
