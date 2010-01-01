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

PackageLoader fileInPackage: #Parser.

STInST.OldSyntaxExporter class extend [
    emitEval: aBlock to: aStream for: namespace [
        namespace isNil
            ifFalse: [ aStream nextPutAll: 'Namespace current: ';
		       store: namespace; nextPut: $!; nl ].

	aBlock value.
        aStream nextPut: $!; nl; nl.
    ]
]

STInST.SqueakSyntaxExporter class extend [
    emitEval: aBlock to: aStream for: namespace [
	aBlock value.
	aStream nextPut: $!; nl; nl.
    ]
]

STInST.NewSyntaxExporter class extend [
    emitEval: aBlock to: aStream for: namespace [
        namespace isNil
            ifTrue: [ aStream nextPutAll: 'Eval' ]
            ifFalse: [ aStream nextPutAll: 'Namespace current: ';
		       store: namespace ].

	    aStream nextPutAll: ' ['.
	    aBlock value.
            aStream nl; nextPut: $]; nl; nl.
    ]
]


Object subclass: EmittedEntity [  
    emitTo: aStream filteredBy: aBlock [
        self subclassResponsibility
    ]
]

EmittedEntity subclass: EmittedComments [
    | comments |
    EmittedComments class >> comments: aCollection source: aString [
	^self new comments: (aCollection collect: [ :c |
	    aString copyFrom: c first to: c last ])
    ]

    emitTo: outStream filteredBy: aBlock [
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
	(aClass superclass notNil and: [
	    aClass superclass isDefined not ]) ifTrue: [
	        Warning signal:
		    ('superclass %1 is undefined' % {aClass superclass}) ].
        ^super new initializeWithClass: aClass complete: true
    ]
    
    EmittedClass class >> forExtension: aClass [
	aClass isDefined ifFalse: [
	    Warning signal:
		('extensions for undefined class %1' % {aClass}) ].
        ^super new initializeWithClass: aClass complete: false
    ]
    
    initializeWithClass: aClass complete: aBoolean [
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
	
    emitTo: aStream filteredBy: aBlock [ 
	(aBlock value: class)
	    ifFalse: [
	        Notification signal: ('Skipping %1' % {class}).
		^self ].

        Notification signal: ('Converting %1...' % {class}).
        (STInST.FileOutExporter defaultExporter on: class to: aStream)
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
        statements := OrderedCollection new
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
    
    emitTo: aStream filteredBy: aBlock [
	statements isEmpty ifTrue: [ ^self ].
	STInST.FileOutExporter defaultExporter
	    emitEval: [
		| formatter |
		formatter := STInST.RBFormatter new.
		formatter indent: 1 while: [
		    formatter indent.
	            aStream nextPutAll: (formatter formatAll: statements) ]]
	    to: aStream
	    for: namespace.
    ]
]



STInST.STClassLoader subclass: SyntaxConverter [
    | stuffToEmit classesToEmit createdNamespaces filter outStream rewriter |
    
    <comment: 'A class loader that creates a set of "EmittedEntity"
    based on the contents of the given file being loaded.
    When the contents of the file are loaded, the responsibilty of 
    emitting code using the new syntax belongs to those various 
    entities that have been constructed.'>
    
    
    SyntaxConverter class >> convertSqueakStream: in to: out [
        <category: 'instance creation'>
        ^self convertStream: in with: STInST.SqueakFileInParser to: out
    ]
    
    SyntaxConverter class >> convertSIFStream: in to: out [
        <category: 'instance creation'>
        ^self convertStream: in with: STInST.SIFFileInParser to: out
    ]
    
    SyntaxConverter class >> convertStream: in to: out [
        <category: 'instance creation'>
        ^self convertStream: in with: STInST.STFileInParser to: out
    ]
    
    SyntaxConverter class >> convertStream: in with: aParserClass to: out [
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
	    stuffToEmit add: (EmittedComments comments: node comments source: node source) ].

        ^super evaluate: rewritten
    ]
    
    addRule: searchString [
	| tree rule |
	tree := RBParser parseRewriteExpression: searchString.
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
	    and: [ (stuffToEmit last isKindOf: EmittedEval)
	    and: [ stuffToEmit last namespace = evalNamespace ]].

	^lastIsEval
	    ifTrue: [ stuffToEmit last ]
	    ifFalse: [ stuffToEmit add: (EmittedEval new namespace: evalNamespace) ]
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
        emittedClass := EmittedClass forClass: class.
    
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
            and: [ (stuffToEmit last isKindOf: EmittedClass) and: [ stuffToEmit last forClass = aClass ] ])                
                ifTrue: [ stuffToEmit last addMethod: aMethod ]
                ifFalse: [ stuffToEmit add: ((EmittedClass forExtension: currentClass) addMethod: aMethod) ]            
    ]
]


String extend [
   asFilterOn: aBlock through: valueBlock [
	| regex |
	self first = $+ ifTrue: [
	    regex := self allButFirst asRegex.
	    ^[ :obj | (aBlock value: obj)
			 or: [ (valueBlock value: obj) ~ regex ] ] ].

	self first = $- ifTrue: [
	    regex := self allButFirst asRegex.
	    ^[ :obj | (aBlock value: obj)
			 and: [ ((valueBlock value: obj) ~ regex) not ] ] ].

	regex := self asRegex.
	^[ :obj | (aBlock value: obj) and: [ (valueBlock value: obj) ~ regex ] ]
    ]
]


Eval [ 
    | helpString inFile outFile quiet verbose converter filter parser
	args inFormats outFormats |
    args := OrderedCollection new.
    parser := STInST.STFileInParser.
    quiet := false.
    verbose := false.
    outFile := nil.
    filter := [ :class | true ].
    converter := SyntaxConverter new.
    STInST.FileOutExporter defaultExporter: STInST.FormattingExporter.
    outFormats := Dictionary from: {
	'gst2' -> STInST.OldSyntaxExporter.
	'gst' -> STInST.FormattingExporter.
	'squeak' -> STInST.SqueakSyntaxExporter.
    }.
    inFormats := Dictionary from: {
	'gst2' -> STInST.STFileInParser.
	'gst' -> STInST.GSTFileInParser.
	'squeak' -> STInST.SqueakFileInParser.
	'sif' -> STInST.SIFFileInParser
    }.
    
    helpString :=
'Usage:
    gst-convert [OPTION]... [INFILE [OUTFILE]]
    gst-convert [OPTION]... -o|--output OUTFILE INFILES

Options:
    -q, --quiet               don''t show any message
    -v, --verbose             print extra information while processing
    -f, --format=FORMAT       convert from given input format (supported
                              formats are %1)
    -F, --output-format=FORMAT convert to given output format (supported
                              formats are %2)
    -C, --class=REGEX         convert only classes matching REGEX
    -C, --class=+REGEX        in addition, convert classes matching REGEX
    -C, --class=-REGEX        do not convert classes matching REGEX
    -c, --category=REGEX      convert only classes whose category matches REGEX
    -c, --category=+REGEX     in addition, convert those whose category
                              matches REGEX
    -c, --category=-REGEX     do not convert classes whose category
                              matches REGEX
    -r, --rule=''CODE->REPL''   look for CODE and replace it with REPL

    -o, --output OUTFILE      concatenate multiple input files into a single
                              converted output file
        --help                display this message and exit
        --version             print version information and exit

' % {inFormats keys asSortedCollection fold: [ :a :b | a, ', ', b ].
     outFormats keys asSortedCollection fold: [ :a :b | a, ', ', b ]}.

    Smalltalk
        arguments: '-h|--help --version -q|--quiet -v|-V|--verbose -r|--rule:
		    -C|--class: -c|--category: -f|--format: -o|--output:
		    -F|--output-format: -I|--image-file: --kernel-directory:'
        do: [ :opt :arg |
	    opt = 'help' ifTrue: [
	        helpString displayOn: stdout.
	        ObjectMemory quit: 0 ].

	    opt = 'version' ifTrue: [
	        ('gst-convert - %1' % {Smalltalk version}) displayNl.
	        ObjectMemory quit: 0 ].

	    opt = 'quiet' ifTrue: [
		quiet := true.
		verbose := false ].

	    opt = 'verbose' ifTrue: [
		quiet := false.
		verbose := true ].

	    opt = 'output' ifTrue: [
		outFile isNil ifFalse: [
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ].
		outFile := arg ]. 

	    opt = 'rule' ifTrue: [
		converter addRule: arg ].

	    opt = 'class' ifTrue: [
		[ 'a' ~ arg ] on: Error do: [ :ex |
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ].

		filter := arg
		    asFilterOn: filter
		    through: [ :class | class asClass nameIn: Smalltalk ] ].

	    opt = 'category' ifTrue: [
		[ 'a' ~ arg ] on: Error do: [ :ex |
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ].

		filter := arg
		    asFilterOn: filter
		    through: [ :class | class category ifNil: [ '' ] ] ].

	    opt = 'output-format' ifTrue: [
		STInST.FileOutExporter defaultExporter:
		    (outFormats at: arg ifAbsent: [
		        helpString displayOn: stderr.
		        ObjectMemory quit: 1 ]) ].

	    opt = 'format' ifTrue: [
		parser := inFormats at: arg ifAbsent: [
		    helpString displayOn: stderr.
		    ObjectMemory quit: 1 ] ].

	    opt isNil ifTrue: [
		args addLast: arg ].
        ]

        ifError: [
            helpString displayOn: stderr.
            ObjectMemory quit: 1 ].

    [
        outFile isNil
	    ifTrue: [
	        args size > 2 ifTrue: [
	            helpString displayOn: stderr.
	            ObjectMemory quit: 1 ].

	        inFile := (args size = 0 or: [ args first = '-' ])
		    ifTrue: [ stdin ]
		    ifFalse: [ FileStream open: args first mode: FileStream read ].
	        outFile := (args size <= 1 or: [ args last = '-' ])
		    ifTrue: [ stdout ]
		    ifFalse: [ FileStream open: args last mode: FileStream write ] ]
	    ifFalse: [
		args := args collect: [ :f |
		    f = '-'
			ifTrue: [ stdin ]
			ifFalse: [ FileStream open: f mode: FileStream read ] ].
		inFile := args fold: [ :a :b | a, b ].

	        outFile := outFile = '-'
		    ifTrue: [ stdout ]
		    ifFalse: [ FileStream open: outFile mode: FileStream write ] ].

	converter filter: filter.
	converter
	    convertStream: inFile
	    with: parser
	    to: outFile.

	inFile close.
	outFile close
    ]
	on: Notification do: [ :ex |
	    verbose ifTrue: [ stderr nextPutAll: 'gst-convert: ', ex messageText; nl; flush ].
	    ex resume ]
	on: Warning do: [ :ex |
	    quiet ifFalse: [ stderr nextPutAll: 'gst-convert: warning: ', ex messageText; nl; flush ].
	    ex resume ]
	on: Error do: [ :ex |
	    stderr nextPutAll: 'gst-convert: error: ', ex messageText; nl; flush.
	    outFile = stdout ifFalse: [
	        outFile close.

		"TODO: don't do this on non-regular files.  It will make
		 /dev/null disappear if you run gst-convert as root (which
		 you shouldn't)."
		[ (File name: outFile name) remove ] on: Error do: [ :ex | ] ].
	    "ex pass." ObjectMemory quit: 1 ].
]
