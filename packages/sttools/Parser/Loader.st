"======================================================================
|
|   Smalltalk syntax conversion tool
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

STInST.STClassLoader subclass: Loader [
    | stuffToEmit classesToEmit createdNamespaces filter outStream rewriter |

    <category: 'STTools-Parser-Core'>
    <comment: 'A class loader that creates a set of "SourceEntity"
    based on the contents of the given file being loaded.
    When the contents of the file are loaded, the responsibilty of
    emitting code using the new syntax belongs to those various
    entities that have been constructed.

    TODO: Split the loading and converting'>


    Loader class >> convertSqueakStream: in to: out [
        <category: 'instance creation'>
        ^self convertStream: in with: STInST.SqueakFileInParser to: out
    ]

    Loader class >> convertSIFStream: in to: out [
        <category: 'instance creation'>
        ^self convertStream: in with: STInST.SIFFileInParser to: out
    ]

    Loader class >> convertStream: in to: out [
        <category: 'instance creation'>
        ^self convertStream: in with: STInST.STFileInParser to: out
    ]

    Loader class >> convertStream: in with: aParserClass to: out [
        <category: 'instance creation'>
        ^self new convertStream: in with: aParserClass to: out
    ]

    initialize [
        <category: 'initialization'>
	super initialize.
	filter := [ :class | [true] ].
        stuffToEmit := OrderedSet new.
        classesToEmit := Dictionary new.
        createdNamespaces := OrderedSet new.
    ]

    convertStream: in with: aParserClass to: out onError: aBlock [
        <category: 'operation'>
        self
	    outStream: out;
	    parseSmalltalkStream: in with: aParserClass onError: aBlock;
	    doEmitStuff.
    ]

    convertStream: in with: aParserClass to: out [
        <category: 'operation'>
        self
	    outStream: out;
	    parseSmalltalkStream: in with: aParserClass;
	    doEmitStuff.
    ]

    filter: aBlock [
        <category: 'accessing'>
        filter := aBlock.
    ]

    outStream: out [
        <category: 'accessing'>
        outStream := out.
    ]

    rewrite: node [
	^rewriter isNil
	    ifTrue: [ node ]
	    ifFalse: [ rewriter executeTree: node; tree ].
    ]

    evaluate: node [
        <category: 'overrides'>

	| rewritten |
	rewritten := self rewrite: node.
	node comments isEmpty ifFalse: [
	    stuffToEmit add: (SourceComments comments: node comments source: node source) ].

        ^super evaluate: rewritten
    ]

    addRule: searchString parser: aParserClass [
	| tree rule |
	tree := aParserClass parseRewriteExpression: searchString.
	tree isMessage ifFalse: [ self error: 'expected ->' ].
	tree selector = #-> ifFalse: [ self error: 'expected ->' ].
	rule := RBStringReplaceRule
	    searchForTree: tree receiver
	    replaceWith: tree arguments first.

	rewriter isNil ifTrue: [ rewriter := ParseTreeRewriter new ].
	rewriter addRule: rule
    ]

    compile: node [
        <category: 'collecting entities'>

        | rewritten method |

	rewritten := self rewrite: node.
        method := self defineMethod: rewritten.
        (classesToEmit includesKey: currentClass asClass)
            ifTrue: [ self addMethod: method toLoadedClass: currentClass ]
            ifFalse: [ self addMethod: method toExtensionClass: currentClass ].
	^method
    ]

    lastEval [
        <category: 'collecting entities'>

	| lastIsEval evalNamespace |

        evalNamespace := currentNamespace = self defaultNamespace
	    ifTrue: [ nil ]
	    ifFalse: [ currentNamespace ].

        lastIsEval := stuffToEmit notEmpty
	    and: [ (stuffToEmit last isKindOf: SourceEval)
	    and: [ stuffToEmit last namespace = evalNamespace ]].

	^lastIsEval
	    ifTrue: [ stuffToEmit last ]
	    ifFalse: [ stuffToEmit add: (SourceEval new namespace: evalNamespace) ]
    ]

    createNamespaces [
	createdNamespaces do: [ :each || stmt |
	    stmt := RBMessageNode
                receiver: (RBVariableNode named: (each superspace nameIn: self currentNamespace))
                selector: #addSubspace:
                arguments: { RBLiteralNode value: each name asSymbol }.
	    self lastEval addStatement: stmt
	].
	createdNamespaces := OrderedSet new
    ]

    unknown: node [
        <category: 'collecting entities'>

	self createNamespaces.
	self lastEval addStatement: node.
        ^false
    ]

    doSubclass: receiver selector: selector arguments: argumentNodes [
        <category: 'evaluating statements'>

        | class emittedClass |

	createdNamespaces remove: self currentNamespace ifAbsent: [ ].
	self createNamespaces.

        class := super defineSubclass: receiver
                       selector: selector
                       arguments: argumentNodes.

        Notification signal: ('Parsing %1' % {class}).
        emittedClass := SourceClass forClass: class.

        classesToEmit at: class put: emittedClass.
        stuffToEmit add: emittedClass.

        ^false
    ]

    doAddNamespace: receiver selector: selector arguments: argumentNodes [
	| ns |
	super doAddNamespace: receiver selector: selector arguments: argumentNodes.

        ns := (self resolveNamespace: receiver) at: argumentNodes first value.
	createdNamespaces add: ns.
	^false
    ]

    doEmitStuff [
        <category: 'emitting'>

        stuffToEmit
	    do: [ :each | each emitTo: outStream filteredBy: filter ]
	    separatedBy: [ outStream nl; nextPut: 12 asCharacter; nl ].
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
            and: [ (stuffToEmit last isKindOf: SourceClass) and: [ stuffToEmit last forClass = aClass ] ])
                ifTrue: [ stuffToEmit last addMethod: aMethod ]
                ifFalse: [ stuffToEmit add: ((SourceClass forExtension: currentClass) addMethod: aMethod) ]
    ]
]
