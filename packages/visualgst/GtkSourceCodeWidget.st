GtkConcreteWidget subclass: GtkSourceCodeWidget [
    | codeBuffer codeView object |

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildCodeView.
	self 
	    initializeHighlighter;
	    initializeAccel
    ]

    initializeAccel [
	<category: 'initialization'>
	
	| group |
	group := GTK.GtkAccelGroup new
    ]

    initializeHighlighter [
	<category: 'initialization'>

	codeBuffer 
	    createTag: #classVar varargs: #('foreground' 'cyan4' nil);
	    createTag: #globalVar varargs: #('foreground' 'cyan4' nil);
	    createTag: #poolVar varargs: #('foreground' 'cyan4' nil);
	    createTag: #undeclaredVar varargs: #('foreground' 'red' nil);
	    createTag: #instanceVar varargs: #('foreground' 'black' nil);
	    createTag: #argumentVar varargs: #('foreground' 'black' nil);
	    createTag: #temporary varargs: #('foreground' 'black' nil);
	    createTag: #specialId varargs: #('foreground' 'grey50' nil);
	    createTag: #literal varargs: #('foreground' 'grey50' nil);
	    createTag: #temporaries varargs: #('foreground' 'magenta' nil);
	    createTag: #methodHeader varargs: #('foreground' 'magenta' nil);
	    createTag: #primitive varargs: #('foreground' 'magenta' nil);
	    createTag: #arguments varargs: #('foreground' 'magenta' nil);
	    createTag: #special varargs: #('foreground' 'magenta' nil);
	    createTag: #unaryMsg varargs: #('foreground' 'magenta4' nil);
	    createTag: #binaryMsg varargs: #('foreground' 'chocolate4' nil);
	    createTag: #keywordMsg varargs: #('foreground' 'NavyBlue' nil);
	    createTag: #comment varargs: #('foreground' 'SpringGreen4' nil)
    ]

    popupMenuOn: aGtkWidget menu: aGtkMenu [
        <category: 'events'>

        | menuitem |

        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Undo'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #undo userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Redo'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #redo userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Do It'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #doIt userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Print It'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #printIt userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Inspect It'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #inspectIt userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Debug It'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #debugIt userData: nil.
        aGtkMenu append: menuitem
    ]

    sourceCode [
	<category: 'accessing'>

	^ codeBuffer text
    ]

    namespaceDefinition: aString [
	<category: 'accessing'>

	codeView emptyStack.
	codeBuffer setText: aString
    ]

    classDefinition: aString [
	<category: 'accessing'>

	codeView emptyStack.
	codeBuffer setText: aString
    ]

    clearCode [
	<category: 'accessing'>

	codeBuffer setText: ''
    ]

    sourceCode: aString [
	<category: 'accessing'>

	| node |
	codeView emptyStack.
	codeBuffer setText: aString.
	node := self parseSource: aString.
	SyntaxHighlighter highlight: node in: codeBuffer
    ]

    parseSource: aString [
	<category: 'parsing'>

	| parser |
	parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | ^ self ];
                    initializeParserWith: aString type: #'on:errorBlock:';
                    yourself.
        ^ [ parser parseMethod ] on: Error do: [ :ex | stderr print: ex messageText; nl; print: ex signalingContext; nl; nl ]
    ]

    buildCodeView [
	<category: 'user interface'>

        codeView := (GtkTextWidget new)
			initialize;
			connectSignal: 'populate-popup' to: self selector: #'popupMenuOn:menu:' userData: nil;
			yourself.

	codeBuffer := codeView getBuffer.

	codeBuffer 
	    connectSignal: 'changed' to: self selector: #'changed' userData: nil.

        ^ (GTK.GtkFrame new: 'Code')
            add: (GTK.GtkScrolledWindow withChild: codeView);
            yourself
    ]

    changed [
	<category: 'buffer changed'>

	| node text |
	(text := codeBuffer text) = '' ifTrue: [ ^ self ].
	node := self parseSource: text.
	node == self ifTrue: [ ^ self ].
        SyntaxHighlighter highlight: node in: codeBuffer
    ]

    hasUndo [
	<category: 'testing'>

	^ codeView hasUndo
    ]

    hasChanged [
	<category: 'testing'>

	^ codeView hasChanged
    ]

    clearUndo [
	<category: 'buffer events'>

	codeView clearUndo
    ]

    undo [
	<category: 'buffer events'>

	codeView undo
    ]

    redo [
	<category: 'buffer events'>

	codeView redo
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject
    ]

    doIt [
        <category: 'smalltalk event'>

	^ Behavior
            evaluate: codeBuffer selectedText 
            to: object
            ifError: [ :fname :lineNo :errorString | self error: errorString ]
    ]


    debugIt [
        <category: 'smalltalk event'>

	object class
            compile: ('Doit [ ^ [ ', self selectedText , ' ] value ]')
            ifError:  [ :fname :lineNo :errorString |
                self error: errorString ].
        (GtkDebugger open)
            doItProcess: [ object perform: #Doit ] newProcess
    ]


    inspectIt [
        <category: 'smalltalk event'>

	GtkInspector openOn: self doIt
    ]


    printIt [
        <category: 'smalltalk event'>

	| iter start end result |
        iter := codeBuffer iterOfSelectedText second.
        result := ' ', (self doIt displayString), ' '.
        codeBuffer insertInteractive: iter text: result len: result size defaultEditable: true.
        start := codeBuffer getIterAtOffset: (iter getOffset - result size).
        end := codeBuffer getIterAtOffset: (iter getOffset).
        codeBuffer selectRange: start bound: end
    ]

    copy [
        <category: 'text editing'>

        codeView signalEmitByName: 'copy-clipboard' args: {}
    ]

    cut [
        <category: 'text editing'>

        codeView signalEmitByName: 'cut-clipboard' args: {}
    ]

    paste [
        <category: 'text editing'>

        codeView signalEmitByName: 'paste-clipboard' args: {}.
    ]

    selectAll [
        <category: 'text editing'>

        codeView signalEmitByName: 'select-all' args: {true}.
    ]

    textview [
	<category: 'accessing'>

	^ codeView
    ]

    codeSaved [
	<category: 'accessing'>

	codeView textSaved
    ]
]

