GtkTextWidget subclass: GtkSourceCodeWidget [
    | browser codeText saveWidget |

    initialize [
	<category: 'initialization'>

	super initialize.
	self initializeHighlighter
    ]

    initializeHighlighter [
	<category: 'initialization'>

	(self buffer)
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
            connectSignal: 'activate' to: self selector: #browseSenders.
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
            connectSignal: 'activate' to: self selector: #acceptIt userData: nil.
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

	^ self buffer text
    ]

    namespaceDefinition: aString [
	<category: 'accessing'>

	self emptyStack.
	self codeText: aString. 
	self buffer setText: (self codeText)
    ]

    classDefinition: aString [
	<category: 'accessing'>

	self emptyStack.
	self codeText: aString. 
	self buffer setText: (self codeText)
    ]

    sourceCode: aString [
	<category: 'accessing'>

	self emptyStack.
	self codeText: aString. 
	self buffer setText: (self codeText).
	self parseSource: aString ifParsed: [ :node | SyntaxHighlighter highlight: node in: self buffer ]
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

    connectSignals [
        <category: 'initialization'>

	super connectSignals.
        (self buffer)
	    connectSignal: 'changed' to: self selector: #'changed' userData: nil
    ]

    buildWidget [
	<category: 'user interface'>
	
        ^ (GTK.GtkFrame new: 'Code')
            add: super buildWidget;
            yourself
    ]

    changed [
	<category: 'buffer changed'>

	| node text |
	(text := self buffer text) = '' ifTrue: [ ^ self ].
	self parseSource: text ifParsed: [ :node | SyntaxHighlighter highlight: node in: self buffer ]
    ]

    state [
	<category: 'state'>

        ^browser state
    ]

    packPluginsInto: vbox [
	<category: 'user interface'>
        vbox
            packStart: ((saveWidget := GtkSaveTextWidget on: self)  mainWidget) expand: false fill: false padding: 0.
        super packPluginsInto: vbox
    ]

    showSave: aString [
        <category: 'user interface'>

        saveWidget label: aString.
	saveWidget showAll
    ]

    postInitialize [
        <category: 'initialize'>

        super postInitialize.
        saveWidget mainWidget hide
    ]

    acceptIt [
	<category: 'buffer events'>

	browser acceptIt
    ]

    compileError: aString line: line [
	<category: 'class event'>

        self showSave: aString
    ]

    cancel [
	<category: 'buffer events'>

	self clearUndo.
        saveWidget hideAll.
	self buffer setText: self codeText
    ]

    doIt [
        <category: 'smalltalk event'>

        ^ browser doIt
    ]

    debugIt [
        <category: 'smalltalk event'>

        ^ browser debugIt
    ]

    inspectIt [
        <category: 'smalltalk event'>

        ^ browser inspectIt
    ]

    printIt [
        <category: 'smalltalk event'>

        ^ browser printIt
    ]

    codeSaved [
	<category: 'accessing'>

        saveWidget hideAll.
	self textSaved
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
	<category: 'method'>

        | iters stream parser node |
	stream := self sourceCode readStream.
        iters := self buffer getSelectionBounds.
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

    sourceCodeWidgetHasFocus [
	<category: 'browse'>

	^ true
    ]

    browserHasFocus [
	<category: 'browse'>

	^ false
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

	self buffer
            createTag: aSymbol varargs: anArray
    ]

    applyTag: aSymbol forLine: anInteger [
	<category: 'text buffer'>

	| start end |
	start := self buffer getIterAtLine: anInteger - 1.
	end := self buffer getIterAtLine: anInteger.
	self buffer applyTagByName: aSymbol start: start end: end
    ]
]

