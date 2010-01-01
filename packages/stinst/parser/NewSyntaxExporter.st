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


FileOutExporter subclass: NewSyntaxExporter [
    <comment: 'This class is responsible for filing out 
               a given class on a given stream'>
    
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
      
    fileOutSelectors: selectors classSelectors: classSelectors [
        self fileOutDeclaration: [
            classSelectors do: [ :each | self fileOutSource: each class: true ].
            selectors do: [ :each | self fileOutSource: each class: false ].
        ]
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
    
    fileOutClassExtension: aBlock [
        outStream nextPutAll: (outClass asClass name).
        
        (outClass isMetaclass)
            ifTrue:  [ outStream nextPutAll: ' class extend ['; nl ]
            ifFalse: [ outStream nextPutAll: ' extend ['; nl ].
            
        aBlock value.
        
        outStream nl; nextPut: $]; nl; nl.
    ]

    fileOutClassDeclaration: aBlock [
        | aSet superclassName inheritedShape |
        
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
	inheritedShape := outClass superclass isNil
				ifTrue: [ nil ]
				ifFalse: [ outClass superclass shape ].
	outClass shape ~~
	    (outClass inheritShape ifTrue: [ inheritedShape ] ifFalse: [ nil ])
	    	ifTrue: [ outStream nl; space: 4;
	    	  		  nextPutAll: '<shape: ';
			          store: outClass shape;
			          nextPut: $> ].
				          
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
    
    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        nextPutAll: 'Eval [ ';
                        print: outClass; 
                        nextPutAll: ' initialize ]'; nl. ]
    ]
]

NewSyntaxExporter subclass: FormattingExporter [
    
    <comment: 'This class in addition to FileOutExporter, uses an RBFormatter
               to pretty print the body of every method.'>
               
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
