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
    | statements comments |
    
    <comment: 'This class is responsible for emitting a set of 
    statements that should be inside an Eval declaration.'>
    
    EmittedEval class >> new [
        ^super new initialize
    ]
    
    initialize [
        statements := STInST.OrderedSet new
    ]
    
    addStatement: aStatement [
        statements add: aStatement
    ] 
    
    emitTo: aStream [
        aStream nextPutAll: 'Eval ['; nl; space: 4.
        statements do: [ :each | self emitStatement: each To: aStream ]
                   separatedBy: [ aStream nextPut: $.; nl; space: 4 ].
        aStream nl; nextPut: $]; nl; nl.
    ]
    
    emitStatement: aStatement To: aStream [
	aStream nextPutAll: (STInST.RBFormatter new format: aStatement)
    ]
]


STInST.STClassLoader subclass: SyntaxConverter [
    | stuffToEmit classesToEmit inStream outStream |
    
    <comment: 'A class loader that creates a set of "EmittedEntity"
    based on the contents of the given file being loaded.
    When the contents of the file are loaded, the responsibilty of 
    emitting code using the new syntax belongs to those various 
    entities that have been constructed.'>
    
    
    SyntaxConverter class >> convertStream: in to: out [
        <catogory: 'instance creation'>
        ^super new initializeWithInStream: in withOutStream: out.
    ]
    
    initializeWithInStream: in withOutStream: out [
        <category: 'initialization'>
        super initializeParserWithStream: in type: #on:errorBlock:.
        stuffToEmit := OrderedSet new.
        classesToEmit := Dictionary new.
        inStream := in.
        outStream := out.
        
        self parseSmalltalk
    ]
    
    parseSmalltalk [
        <category: 'overrides'>
        
        | ret |
        
        ret := super parseSmalltalk.
        self doEmitStuff.        
        ^ret
    ]
    
    evaluate: node [
        <category: 'overrides'>

	"FIXME: there's a bug in RBParser.st"
	stuffToEmit isEmpty ifTrue: [
	     node comments do: 
	          [ :c | outStream
			     nextPutAll: 
			         (node source copyFrom: c first to: c last);
			     nl; nl ] ].

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
    
    unknown: node [
        <category: 'collecting entities'>
        
        | eval statement |

        (stuffToEmit size > 0)
            ifTrue: [ (stuffToEmit last isKindOf: EmittedEval)
                        ifFalse: [ stuffToEmit add: (EmittedEval new) ] ]
            ifFalse: [ stuffToEmit add: (EmittedEval new) ].
            
        eval := stuffToEmit last.
        eval addStatement: node.
     
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
