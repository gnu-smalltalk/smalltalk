"======================================================================
|
|   Smalltalk syntax conversion tool
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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

PackageLoader fileInPackage: #Parser.

Object subclass: EmittedEntity [  
    emitTo: aStream [
        self subclassResponsibility
    ]
]

EmittedEntity subclass: EmittedComments [
    | comments |
    EmittedComments class >> comments: aCollection source: aString [
	^self new comments: (aCollection collect: [ :c |
	    aString copyFrom: c first to: c last ])
    ]

    emitTo: outStream [
	comments do: [ :c | outStream nextPutAll: c; nl; nl ]
    ]

    comments: anArray [
	comments := anArray
   ]
]

EmittedEntity subclass: EmittedClass [
    | class methodsToEmit classMethodsToEmit isComplete |
    
    <comment: 'This class is responsible for emitting a class 
    by using a FormattingExporter.'>
    
    EmittedClass class >> forClass: aClass [        
        ^super new initializeWithClass: aClass extension: true
    ]
    
    EmittedClass class >> forExtension: aClass [
        ^super new initializeWithClass: aClass extension: false
    ]
    
    initializeWithClass: aClass extension: aBoolean [
        class := aClass.
        methodsToEmit := STInST.OrderedSet new.
	classMethodsToEmit := STInST.OrderedSet new.
	isComplete := aBoolean
    ]

    forClass [ 
        ^class
    ]
    
    addMethod: aMethod [
        methodsToEmit add: aMethod selector asSymbol.
    ]

    addClassMethod: aMethod [
	classMethodsToEmit add: aMethod selector asSymbol.
    ]
	
    emitTo: aStream [ 
        (STInST.FormattingExporter on: class to: aStream)
            completeFileOut: isComplete;
            fileOutSelectors: methodsToEmit classSelectors: classMethodsToEmit.
    ]
]

EmittedEntity subclass: EmittedEval [
    | statements comments namespace |
    
    <comment: 'This class is responsible for emitting a set of 
    statements that should be inside an Eval declaration.'>
    
    EmittedEval class >> new [
        ^super new initialize
    ]
    
    initialize [
        statements := STInST.OrderedCollection new
    ]
    
    namespace [ 
	^namespace
    ]

    namespace: aNamespace [ 
	namespace := aNamespace
    ]

    addStatement: aStatement [
        statements add: aStatement
    ] 
    
    emitTo: aStream [
	| formatter |
	statements isEmpty ifTrue: [ ^self ].
	namespace isNil
            ifTrue: [ aStream nextPutAll: 'Eval' ]
            ifFalse: [ aStream nextPutAll: 'Namespace current: ';
			store: namespace ].

	aStream nextPutAll: ' ['.
	formatter := STInST.RBFormatter new.
	formatter indent: 1 while: [
	    formatter indent.
            aStream nextPutAll: (formatter formatAll: statements).
	].
        aStream nl; nextPut: $]; nl; nl.
    ]
]


STInST.STClassLoader subclass: SyntaxConverter [
    | stuffToEmit classesToEmit outStream |
    
    <comment: 'A class loader that creates a set of "EmittedEntity"
    based on the contents of the given file being loaded.
    When the contents of the file are loaded, the responsibilty of 
    emitting code using the new syntax belongs to those various 
    entities that have been constructed.'>
    
    
    SyntaxConverter class >> convertSqueakStream: in to: out [
        <catogory: 'instance creation'>
        ^self convertStream: in with: STInST.SqueakFileInParser to: out
    ]
    
    SyntaxConverter class >> convertStream: in to: out [
        <catogory: 'instance creation'>
        ^self convertStream: in with: STInST.STFileInParser to: out
    ]
    
    SyntaxConverter class >> convertStream: in with: aParserClass to: out [
        <catogory: 'instance creation'>
        ^self new
	    outStream: out;
	    parseSmalltalkStream: in with: aParserClass;
	    doEmitStuff.        
    ]
    
    initialize [
        <category: 'initialization'>
	super initialize.
        stuffToEmit := OrderedSet new.
        classesToEmit := Dictionary new.
    ]

    outStream: out [
        outStream := out.
    ]
    
    evaluate: node [
        <category: 'overrides'>

	node comments isEmpty ifFalse: [
	    stuffToEmit add: (EmittedComments comments: node comments source: node source) ].

        ^super evaluate: node
    ]
    
    compile: node [
        <category: 'collecting entities'>
        
        | method |

        method := self defineMethod: node.                
        (classesToEmit includesKey: currentClass asClass)
            ifTrue: [ self addMethod: method toLoadedClass: currentClass ]
            ifFalse: [ self addMethod: method toExtensionClass: currentClass ]
    ]
    
    lastEval [
        <category: 'collecting entities'>

	| lastIsEval evalNamespace |

        evalNamespace := currentNamespace = self defaultNamespace
	    ifTrue: [ nil ]
	    ifFalse: [ currentNamespace ].

        lastIsEval := stuffToEmit notEmpty
	    and: [ (stuffToEmit last isKindOf: EmittedEval)
	    and: [ stuffToEmit last namespace = evalNamespace ]].

	^lastIsEval
	    ifTrue: [ stuffToEmit last ]
	    ifFalse: [ stuffToEmit add: (EmittedEval new namespace: evalNamespace) ]
    ]

    unknown: node [
        <category: 'collecting entities'>
        
	self lastEval addStatement: node.
        ^false
    ]
    
    doSubclass: receiver selector: selector arguments: argumentNodes [
        <category: 'evaluating statements'>
        
        | class emittedClass |
        
        class := super defineSubclass: receiver 
                       selector: selector 
                       arguments: argumentNodes.        
                            
        emittedClass := EmittedClass forClass: class.
    
        classesToEmit at: class put: emittedClass.
        stuffToEmit add: emittedClass.
        
        ^false
    ]
    
    doEmitStuff [
        <category: 'emitting'>

        stuffToEmit do: [ :each | each emitTo: outStream ].
        stuffToEmit := OrderedSet new.
        classesToEmit := Dictionary new
    ]
    
    addMethod: aMethod toLoadedClass: aClass [
        <category: 'collecting entities'>

        (aClass isMetaclass)
            ifTrue: [ (classesToEmit at: currentClass asClass) addClassMethod: aMethod ]
            ifFalse: [ (classesToEmit at: currentClass) addMethod: aMethod ]
    ]
    
    addMethod: aMethod toExtensionClass: aClass [
        <category: 'collecting entities'>

        ((stuffToEmit size > 0)
            and: [ (stuffToEmit last isKindOf: EmittedClass) and: [ stuffToEmit last forClass = aClass ] ])                
                ifTrue: [ stuffToEmit last addMethod: aMethod ]
                ifFalse: [ stuffToEmit add: ((EmittedClass forExtension: currentClass) addMethod: aMethod) ]            
    ]
]


Eval [ 

    args := Smalltalk arguments.
    
    inFile := FileStream open: (args at: 1) mode: FileStream read.
    outFile := FileStream open: (args at: 2) mode: FileStream write.
    
    SyntaxConverter convertStream: inFile to: outFile.
    inFile close.
    outFile close
]
