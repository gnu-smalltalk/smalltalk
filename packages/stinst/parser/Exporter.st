"======================================================================
|
|   Class fileout support
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


Object subclass: FileOutExporter [
    | outClass outStream completeFileOut defaultNamespace |
    
    <comment: 'This class is responsible for filing out 
               a given class on a given stream'>
    
    DefaultExporter := nil.

    FileOutExporter class >> defaultExporter [
        ^DefaultExporter ifNil: [ NewSyntaxExporter ]
    ]

    FileOutExporter class >> defaultExporter: aClass [
        DefaultExporter := aClass
    ]

    FileOutExporter class >> on: aClass to: aStream [    
        ^super new initializeWith: aClass and: aStream.
    ]

    FileOutExporter class >> fileOut: aClass to: aStream [    
        (self on: aClass to: aStream) fileOut
    ]

    FileOutExporter class >> fileOut: aClass toFile: aString [    
        | aStream |
        aStream := FileStream open: aString mode: FileStream write.
        [ (self on: aClass to: aStream) fileOut ]
            ensure: [ aStream close ]
    ]
    
    FileOutExporter class >> fileOutCategory: aString of: aClass to: aStream [
	| methods exporter |
        methods := aClass selectors select: [ :selector |
            (aClass compiledMethodAt: selector) methodCategory = aString ].
        exporter := self on: aClass asClass to: aStream.
        exporter completeFileOut: false.
	aClass isClass
	    ifTrue: [ exporter fileOutSelectors: methods classSelectors: #() ]
	    ifFalse: [ exporter fileOutSelectors: #() classSelectors: methods ]
    ]
    
    FileOutExporter class >> fileOutSelector: aSymbol of: aClass to: aStream [
	| exporter |
        exporter := self on: aClass asClass to: aStream.
        exporter completeFileOut: false.
	aClass isClass
	    ifTrue: [ exporter fileOutSelectors: {aSymbol} classSelectors: #() ]
	    ifFalse: [ exporter fileOutSelectors: #() classSelectors: {aSymbol} ]
    ]
    
    initializeWith: aClass and: aStream [
        outClass := aClass.
        outStream := aStream.
	completeFileOut := true.
    ]

    completeFileOut [
        ^completeFileOut
    ]

    completeFileOut: aBoolean [
        completeFileOut := aBoolean.
    ]

    defaultNamespace [
	defaultNamespace isNil 
	    ifTrue: [ defaultNamespace := Namespace current ].
        ^defaultNamespace
    ]

    defaultNamespace: aNamespace [
        defaultNamespace := aNamespace.
    ]

    fileOut [                   
        self fileOutDeclaration: [ self fileOutMethods ].
        completeFileOut
	        ifFalse: [ self fileOutInitialize ]
    ]
      
    fileOutSelectors: selectors classSelectors: classSelectors [
	self subclassResponsibility
    ]

    fileOutDeclaration: aBlock [
	self subclassResponsibility
    ]
    
    fileOutClassBody: aBlock [
	completeFileOut
	    ifTrue: [ self fileOutClassDeclaration: aBlock ]
	    ifFalse: [ self fileOutClassExtension: aBlock ].
    ]
    
    fileOutClassExtension: aBlock [
	self subclassResponsibility
    ]

    fileOutClassDeclaration: aBlock [
	self subclassResponsibility
    ]

    fileOutMethods [            
	self subclassResponsibility
    ]
    
    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        nextPutAll: 'Eval [ ';
                        print: outClass; 
                        nextPutAll: ' initialize ]'; nl. ]
    ]
]

