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


FileOutExporter subclass: OldSyntaxExporter [
    <comment: 'This class is responsible for filing out 
               a given class on a given stream'>
    
    printFormattedSet: aSet [
        outStream nextPut: $'.
        aSet isNil ifTrue: [ ^self ].
        aSet do: [ :element | outStream nextPutAll: element ]
            separatedBy: [ outStream space ].
        outStream nextPut: $'.
    ]
    
    fileOutDeclaration: aBlock [
        (completeFileOut and: [ outClass environment ~= self defaultNamespace ])
	    ifFalse: [ ^self fileOutClassBody: aBlock ].
        
        outStream nextPutAll: 'Namespace current: ';
                  store: outClass environment;
		  nextPut: $!; nl; nl.
                  
	self fileOutClassBody: aBlock.
        outStream nextPutAll: 'Namespace current: Smalltalk!'; nl; nl.
    ]
    
    fileOutClassExtension: aBlock [
        aBlock value.
        outStream nl.
    ]

    fileOutComment [
	outStream
            print: outClass;
            nextPutAll: ' comment: ';
            nl;
            print: outClass comment;
            nextPut: $!;
            nl; nl.
    ] 

    fileOutSelectors: selectors classSelectors: classSelectors [
        self fileOutDeclaration: [
            self fileOutSource: classSelectors class: outClass asMetaclass.
            self fileOutSource: selectors class: outClass.
        ]
    ]

    fileOutClassDeclaration: aBlock [
        | superclassName |
    
        superclassName := outClass superclass isNil
            ifTrue: [ 'nil' ]
            ifFalse: [ outClass superclass nameIn: outClass environment ].
    
        outStream
            nextPutAll: superclassName; space;
            nextPutAll: outClass kindOfSubclass; space;
            store: outClass name asSymbol.
    
        outStream nl; tab; nextPutAll: 'instanceVariableNames: '.
        self printFormattedSet: outClass instVarNames.

        outStream nl; tab; nextPutAll: 'classVariableNames: '.
        self printFormattedSet: outClass classVarNames.

        outStream nl; tab; nextPutAll: 'poolDictionaries: '.
        self printFormattedSet: outClass sharedPools.

        outStream nl; tab; nextPutAll: 'category: ';
            print: outClass category;
            nextPut: $!;
            nl; nl.

	self fileOutComment.

        outClass asMetaclass instVarNames isEmpty ifFalse: [
            outStream print: outClass asMetaclass; nextPutAll: ' instanceVariableNames: '.
            self printFormattedSet: outClass asMetaclass instVarNames.
	    outStream nextPut: $!; nl; nl].
	aBlock value.
        outStream nl.
    ]

    fileOutMethods [            
        outClass asMetaclass collectCategories do:
            [ :category | self fileOutCategory: category class: true ].
        
        outClass collectCategories do: 
            [ :category | self fileOutCategory: category class: false ]
    ]

    fileOutCategory: category class: aBoolean [
        | methods class |

        class := aBoolean ifTrue: [ outClass asMetaclass ] ifFalse: [ outClass ].
        methods := class selectors select: [ :selector |
            (class compiledMethodAt: selector) methodCategory = category ].

	self fileOutSource: methods class: class.
    ]

    fileOutSource: selectors class: aClass [
	| categories catSB methodSB |
	catSB := [ :a :b | (a key ifNil: ['~~']) < (b key ifNil: ['~~']) ].
	methodSB := [ :a :b | a selector < b selector ].

	categories := Dictionary new.
	selectors do: [ :each || method |
	    method := aClass >> each.
	    (categories
		at: method methodCategory
		ifAbsentPut: [SortedCollection sortBlock: methodSB]) add: method].

	(categories associations asSortedCollection: catSB) do: [ :each |
	    self fileOutCategory: each key methods: each value class: aClass ]
    ]

    fileOutCategory: aString methods: methods class: aClass [
        methods isEmpty ifTrue: [ ^self ].
        outStream
	     nextPut: $!; print: aClass;
             nextPutAll: ' methodsFor: ';
             print: aString;
             nextPut: $!.

        methods do: [ :method |
	    outStream nl.
	    self fileOutChunk: (self oldSyntaxSourceCodeFor: method) ].

        outStream nextPutAll: ' !'; nl; nl
    ]

    fileOutChunk: aString [
        outStream
            nl;
            nextPutAll: aString;
            nextPut: $!
    ]

    oldSyntaxSourceCodeFor: aMethod [
	| source cat |
	aMethod isOldSyntax ifTrue: [ ^aMethod methodSourceString ].
	source := aMethod methodSourceString.
	source := source copyReplacingRegex: '\s*\[\s*(.*[\S\n])' with: '
	%1'.
	source := source copyReplacingRegex: '\s*]\s*$' with: '
'.
	cat := aMethod methodCategory printString escapeRegex.
        ^source
	    copyReplacingAllRegex: ('(?m:^)\s*<category: ', cat, '>\s*
')
	    with: ''.
    ]

    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        print: outClass; 
                        nextPutAll: ' initialize!'; nl. ]
    ]
]

