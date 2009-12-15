GtkConcreteWidget subclass: GtkSourceCodeWidget [
    | browser codeText codeBuffer codeView object |

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildCodeView.
	self initializeHighlighter
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

        | menuitem symbol |

	symbol := self selectedMethodSymbol.
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Browse senders'.
        menuitem
	    setSensitive: symbol notNil;
            show;
            connectSignal: 'activate' to: self selector: #browseSenders userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Browse implementors'.
        menuitem
	    setSensitive: symbol notNil;
            show;
            connectSignal: 'activate' to: self selector: #browseImplementors userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Accept'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #accept userData: nil.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Cancel'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #cancel userData: nil.
        aGtkMenu append: menuitem.
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
	self codeText: aString. 
	codeBuffer setText: aString
    ]

    classDefinition: aString [
	<category: 'accessing'>

	codeView emptyStack.
	self codeText: aString. 
	codeBuffer setText: aString
    ]

    clearCode [
	<category: 'accessing'>

	codeBuffer setText: ''
    ]

    sourceCode: aString [
	<category: 'accessing'>

	codeView emptyStack.
	self codeText: aString. 
	codeBuffer setText: aString.
	self parseSource: aString ifParsed: [ :node | SyntaxHighlighter highlight: node in: codeBuffer ]
    ]

    parseSource: aString ifParsed: aOneArgBlock [
	<category: 'parsing'>

	| node parser |
	parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | ^ self ];
                    initializeParserWith: aString type: #'on:errorBlock:';
                    yourself.
        [ node := parser parseMethod ] on: Error do: [ :ex | stderr print: ex messageText; nl; print: ex signalingContext; nl; nl. ^ self ].
	^ aOneArgBlock value: node
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
	self parseSource: text ifParsed: [ :node | SyntaxHighlighter highlight: node in: codeBuffer ]
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

    accept [
	<category: 'buffer events'>

	browser acceptIt
    ]

    cancel [
	<category: 'buffer events'>

	self clearUndo.
	codeBuffer setText: self codeText
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

    selectedText [
        <category: 'text accessing'>

        ^ codeView getBuffer selectedText
    ]

    textview [
	<category: 'accessing'>

	^ codeView
    ]

    codeSaved [
	<category: 'accessing'>

	codeView textSaved
    ]

    codeText [
	<category: 'accessing'>

	^ codeText ifNil: [ codeText := '' ]
    ]

    codeText: aString [
	<category: 'accessing'>

	codeText := aString copy
    ]

    browser: aGtkClassBrowserWidget [
	<category: 'accessing'>

	browser := aGtkClassBrowserWidget
    ]

    selectedMethodSymbol [
        | iters stream parser node |
	stream := self sourceCode readStream.
        iters := codeBuffer getSelectionBounds.
        parser := STInST.RBBracketedMethodParser new.
        parser errorBlock: [:message :position | ^nil].
        parser 
            scanner: (parser scannerClass on: stream errorBlock: parser errorBlock).
        node := parser parseMethod body.
        node := node bestNodeFor:
	    (iters first getOffset + 1 to: iters second getOffset + 1).
        [node isNil ifTrue: [^nil].
	node isMessage] whileFalse: 
                [node := node parent].
        ^node selector
    ]

    browseSenders [
	<category: 'browse'>

	OpenSenderCommand on: self
    ]

    browseImplementors [
	<category: 'browse'>

	OpenImplementorCommand on: self
    ]

    appendTag: aSymbol description: anArray [
	<category: 'text buffer'>

	codeBuffer
            createTag: aSymbol varargs: anArray
    ]

    applyTag: aSymbol forLine: anInteger [
	<category: 'text buffer'>

	| start end |
	start := codeBuffer getIterAtLine: anInteger - 1.
	end := codeBuffer getIterAtLine: anInteger.
	codeBuffer applyTagByName: aSymbol start: start end: end
    ]

]

