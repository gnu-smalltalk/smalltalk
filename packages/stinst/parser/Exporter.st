"======================================================================
|
|   Class fileout support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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
        self fileOutHeader.
        self fileOutDeclaration: [ self fileOutMethods ].
        completeFileOut
	        ifFalse: [ self fileOutInitialize ]
    ]
      
    fileOutSelectors: selectors classSelectors: classSelectors [
        self fileOutHeader.
        self fileOutDeclaration: [
            classSelectors do: [ :each | self fileOutSource: each class: true ].
            selectors do: [ :each | self fileOutSource: each class: false ].
        ]
    ]

    fileOutHeader [
        | now |
        outStream 
            nextPutAll: '"Filed out from ';
            nextPutAll: Smalltalk version;
            nextPutAll: ' on '.
            
        now := Date dateAndTimeNow.
        
        outStream
            print: now asDate;
            space;
            print: now asTime;
            nextPutAll: '"';
            nl; nl
    ]
    
    printFormattedSet: aSet [
        aSet isNil ifTrue: [ ^self ].
        aSet do: [ :element | outStream nextPutAll: element ]
            separatedBy: [ outStream space ]
    ]
    
    fileOutDeclaration: aBlock [
        (completeFileOut and: [ outClass environment ~= self defaultNamespace ])
	    ifFalse: [ ^self fileOutClassBody: aBlock ].
        
        outStream nextPutAll: 'Namespace current: ';
                  store: outClass environment;
                  nextPutAll: ' ['; nl; nl.
                  
	self fileOutClassBody: aBlock.
        outStream nextPut: $]; nl; nl.
    ]
    
    fileOutClassBody: aBlock [
	completeFileOut
	    ifTrue: [ self fileOutClassDeclaration: aBlock ]
	    ifFalse: [ self fileOutClassExtension: aBlock ].
    ]
    
    fileOutClassExtension: aBlock [
        outStream nextPutAll: (outClass asClass name).
        
        (outClass isMetaclass)
            ifTrue:  [ outStream nextPutAll: ' class extend ['; nl ]
            ifFalse: [ outStream nextPutAll: ' extend ['; nl ].
            
        aBlock value.
        
        outStream nl; nextPut: $]; nl; nl.
    ]

    fileOutClassDeclaration: aBlock [
        | aSet superclassName |
        
        outClass isMetaclass ifTrue: [ ^outClass ].
        
        superclassName := outClass superclass isNil
            ifTrue: [ 'nil' ]
            ifFalse: [ outClass superclass nameIn: outClass environment ].
        
        outStream
            nextPutAll: superclassName; space;
	        nextPutAll: 'subclass: ';
            nextPutAll: outClass name; space;
            nextPut: $[; nl; space: 4. 
        
        "instance variables"
        (outClass instVarNames isEmpty) ifFalse: [
            outStream nextPut: $|; space.
            self printFormattedSet: outClass instVarNames.
            outStream space; nextPut: $|; nl; space: 4
        ].
            
	    "shape"
	    (outClass shape notNil)
	        ifTrue: [ (outClass superclass isNil not)
	    	    ifTrue: [ outStream nl; space: 4;
	    	      		  nextPutAll: '<shape: ';
				          store: outClass shape;
				          nextPut: $> ] ].
				          
		"sharedPools"
        (aSet := outClass sharedPools) do: [ :element | 
            outStream nl; space: 4; nextPutAll: '<import: '.
            outStream nextPutAll: element.
            outStream nextPutAll: '>' ].

	    "category and comment"  	
	outStream nl.
	outClass classPragmas do: [ :selector |
            outStream space: 4;
		  nextPut: $<;
		  nextPutAll: selector;
		  nextPutAll: ': '.
	    (outClass perform: selector) storeLiteralOn: outStream.
	    outStream  nextPut: $>; nl ].
	    
        "class instance varriables"            
        outClass asMetaclass instVarNames isEmpty
            ifFalse: [ outStream nl; space: 4; nextPutAll: outClass name;
                       nextPutAll: ' class ['; nl; tab.
                       outStream nextPut: $|; space.
                       self printFormattedSet: outClass asMetaclass instVarNames.
                       outStream space; nextPut: $|; nl; tab.
                       outStream nl; space: 4; nextPut: $]; nl ].
         
        "class variables"
        ((aSet := outClass classVarNames) isEmpty)
            ifFalse: [
                outStream nl.
                aSet do: [ :var | outStream space: 4; nextPutAll: var; nextPutAll: ' := nil.'; nl ] ].

        aBlock value.
                       
        outStream nextPut: $]; nl; nl.
    ]

    fileOutMethods [            
        outClass asMetaclass collectCategories do:
            [ :category | self fileOutCategory: category class: true ].
                
        outClass asMetaclass selectors isEmpty ifFalse: [ outStream nl ].
        
        outClass collectCategories do: 
            [ :category | self fileOutCategory: category class: false ]
    ]
    
    fileOutCategory: category class: isClass [
        | methods theClass |

	theClass := isClass
	    ifTrue: [ outClass asMetaclass ]
	    ifFalse: [ outClass ].
        
        methods := theClass selectors select: 
                    [ :selector | (theClass compiledMethodAt: selector) 
                                    methodCategory = category ].
        
        methods asSortedCollection
	    do: [ :selector | self fileOutSource: selector class: isClass ]
    ]
    
    fileOutSource: selector class: isClass [
        | class |
        
        outStream nl; nextPutAll: '    '.
        class := isClass 
                    ifTrue: [ outStream nextPutAll: outClass name; nextPutAll: ' class >> '.
                              outClass asMetaclass ]
                    ifFalse: [ outClass ].
        outStream
	    nextPutAll: (class >> selector) methodRecompilationSourceString;
	    nl.
    ]

    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        nextPutAll: 'Eval [ ';
                        print: outClass; 
                        nextPutAll: ' initialize ]'; nl. ]
    ]
]

FileOutExporter subclass: FormattingExporter [
    
    <comment: 'This class in addition to FileOutExporter, uses an RBFormatter
               to pretty print the body of every method.'>
               
    fileOutHeader [ ]
    fileOutInitialize [ ]

    fileOutSource: selector class: isClass [
        | class source |
        outStream nl; nextPutAll: '    '.
        class := isClass 
                    ifTrue: [
			outStream
			    nextPutAll: outClass name;
			    nextPutAll: ' class >> '.
                        outClass asMetaclass ]
                    ifFalse: [ outClass ].
                    
	source := (class compiledMethodAt: selector) methodFormattedSourceString.
        outStream nextPutAll: source; nl.
    ]
]

Behavior extend [
    parseNodeAt: selector [
	"Available only when the Parser package is loaded--Answer an
	 RBMethodNode that compiles to my method named by selector."
        ^(self compiledMethodAt: selector) methodParseNode
    ]
]

CompiledMethod extend [
    methodFormattedSourceString [
        "Answer the method source code as a string, formatted using
	 the RBFormatter.  Requires package Parser."

        <category: 'compiling'>
	^STInST.RBFormatter new
		      initialIndent: 1;
                      format: self methodParseNode.
    ]

    methodParseNode [
        "Answer the parse tree for the receiver, or nil if there is an
         error.  Requires package Parser."

        <category: 'compiling'>
	^self parserClass
            parseMethod: self methodSourceString
            category: self methodCategory
	    onError: [ :message :position | ^nil ]
    ]

    parserClass [
	"Answer a parser class, similar to Behavior>>parserClass, that
	 can parse my source code.  Requires package Parser."
        <category: 'compiling'>
	^self isOldSyntax
	    ifTrue: [ STInST.RBParser ]
	    ifFalse: [ STInST.RBBracketedMethodParser ]
    ]
]

Class extend [
    fileOutDeclarationOn: aFileStream [
	"File out class definition to aFileStream.  Requires package Parser."
	<category: 'filing'>
        (STInST.FileOutExporter on: self to: aFileStream)
            fileOutDeclaration: [ ]
    ]

    fileOutOn: aFileStream [
	"File out complete class description:  class definition, class and
	 instance methods.  Requires package Parser."
	<category: 'filing'>
        STInST.FileOutExporter fileOut: self to: aFileStream
    ]
]

ClassDescription extend [
    fileOutSelector: aSymbol toStream: aFileStream [
        "File out all the methods belonging to the method category,
	 category, to aFileStream.  Requires package Parser."
	
        STInST.FileOutExporter fileOutSelector: aSymbol of: self to: aFileStream
    ]

    fileOutCategory: category toStream: aFileStream [
        "File out all the methods belonging to the method category,
	 category, to aFileStream.  Requires package Parser."
	
        STInST.FileOutExporter fileOutCategory: category of: self to: aFileStream
    ]
]

RBParser subclass: RBBracketedMethodParser [
    skipToken: tokenValue [
        (currentToken value = tokenValue)
            ifTrue: [self step. ^true]
            ifFalse: [^false]
    ]

    skipExpectedToken: tokenValue [
        (self skipToken: tokenValue)
            ifFalse: [self parserError: ('expected ' , tokenValue asSymbol)]
    ]

    parseMethodInto: methodNode [
        <category: 'private-parsing'>
        self skipExpectedToken: $[.
	super parseMethodInto: methodNode.
        self skipExpectedToken: $].
        ^methodNode
    ]
]


