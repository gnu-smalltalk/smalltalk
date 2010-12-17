GtkConcreteWidget subclass: GtkInspectorBrowserWidget [
    | checkCode namespaceWidget classHierarchyWidget classHierarchyUpdate iCategoryWidget iMethodWidget cCategoryWidget cMethodWidget codeWidget state |

    GtkInspectorBrowserWidget class >> title [
	<category: 'accessing'>

	^ 'Gtk class browser'
    ]

    postInitialize [
	<category: 'initialization'>

	codeWidget postInitialize
    ]

    buildBrowser [

	^ GTK.GtkHPaned addAll: {self buildHierarchy. self buildProtocolAndMethod}
    ]

    buildClassBrowser [

	^ GTK.GtkHPaned addAll: {self buildClassMethodView}
    ]

    buildInstanceBrowser [

	^ GTK.GtkHPaned addAll: {self buildInstanceMethodView}
    ]

    buildProtocolAndMethod [

	^  (GTK.GtkNotebook new)
	    appendPage: self buildInstanceBrowser tabLabel: (GTK.GtkLabel new: 'Instance');
	    appendPage: self buildClassBrowser tabLabel: (GTK.GtkLabel new: 'Class');
	    showAll;
	    setCurrentPage: 0;
	    connectSignal: 'switch-page' to: self selector: #'classInstanceSwitchOn:page:number:' userData: nil;
	    yourself
    ]

    buildCodeView [
	<category: 'user interface'>

	codeWidget := (GtkSourceCodeWidget parentWindow: self parentWindow)
			browser: self;
			showAll;
			yourself.
    
	^ codeWidget mainWidget
    ]

    buildHierarchy [
	<category: 'user interface'>

	classHierarchyWidget := GtkClassHierarchyWidget showAll
				    whenSelectionChangedSend: #onClassHierarchyChanged to: self;
				    yourself.

	^ classHierarchyWidget mainWidget
    ]

    buildClassMethodView [
	<category: 'user interface'>

	cMethodWidget := GtkMethodWidget showAll
			    whenSelectionChangedSend: #onClassSideMethodChanged to: self;
			    yourself.

	^ cMethodWidget mainWidget
    ]

    buildInstanceMethodView [
        <category: 'user interface'>

        iMethodWidget := GtkMethodWidget showAll 
                            whenSelectionChangedSend: #onInstanceSideMethodChanged to: self;
                            yourself.

        ^ iMethodWidget mainWidget
    ]

    initialize [
	<category: 'initialize-release'>

	classHierarchyUpdate := false.
	checkCode := true.
	state := NamespaceState on: self with: Smalltalk.
	self mainWidget: (GTK.GtkVPaned addAll: {self buildBrowser. self buildCodeView})
    ]

    classInstanceSwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    aSmallInteger = 0 
		ifTrue: [
		    iMethodWidget hasSelectedMethod 
			ifTrue: [ codeWidget source: (BrowserMethodSource on: iMethodWidget selectedMethod) ]
			ifFalse: [ codeWidget clear ] ]
		ifFalse: [
                    cMethodWidget hasSelectedMethod
                        ifTrue: [ codeWidget source: (BrowserMethodSource on: cMethodWidget selectedMethod) ]
                        ifFalse: [ codeWidget clear ] ] ]
    ]

    onClassHierarchyChanged [
	<category: 'events'>

	| aClass |
	self checkCodeWidgetAndUpdate: [
	    classHierarchyWidget hasSelectedClass ifFalse: [ ^ self ].
	    classHierarchyUpdate := true.
            aClass := classHierarchyWidget selectedClass.

            iMethodWidget class: aClass withCategory: '*'.
            cMethodWidget class: aClass class withCategory: '*'.

            codeWidget clear.
	    state := CategoryState on: self with: classHierarchyWidget selectedClass -> '*' ]
    ]

    onInstanceSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidgetAndUpdate: [
	    iMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	    method := iMethodWidget selectedMethod.
	    codeWidget source: (BrowserMethodSource on: method).
	    state := MethodState on: self with: method ]
    ]

    onClassSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidgetAndUpdate: [
	    cMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	    method := cMethodWidget selectedMethod.
	    codeWidget source: (BrowserMethodSource on: method).
	    state := MethodState on: self with: method ]
    ]

    selectAClass: aClass [
	<category: 'selection'>

	classHierarchyWidget classOrMeta: aClass.

	iMethodWidget class: aClass withCategory: '*'.
	cMethodWidget class: aClass class withCategory: '*'.
	state := CategoryState on: self with: aClass -> '*'
    ]

    selectAnInstanceMethod: aSelector [
        <category: 'selection'>

        | class |
        class := classHierarchyWidget selectedClass.

        class := (class selectors includes: aSelector) ifFalse: [ class class ] ifTrue: [ class ].
        iMethodWidget
            class: class withCategory: (class compiledMethodAt: aSelector) methodCategory.
	state := CategoryState on: self with: class -> '*'
    ]

    selectAClassMethod: aSelector [
	<category: 'selection'>

        | class |
        class := classHierarchyWidget selectedClass.

	class := (class selectors includes: aSelector) ifFalse: [ class class ] ifTrue: [ class ].
        cMethodWidget
            class: class withCategory: (class compiledMethodAt: aSelector) methodCategory.
	state := CategoryState on: self with: class -> '*'
    ]

    targetObject [
        <category: 'target'>

        ^self state classOrMeta
    ]

    doIt: object [
	<category: 'smalltalk event'>

	codeWidget doIt: object
    ]

    debugIt: object [
	<category: 'smalltalk event'>

        codeWidget debugIt: object
    ]

    inspectIt: object [
	<category: 'smalltalk event'>

        codeWidget inspectIt: object
    ]

    printIt: object [
	<category: 'smalltalk event'>

        codeWidget printIt: object
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    cancel [
        <category: 'buffer events'>

	codeWidget hasFocus ifTrue: [ codeWidget cancel ]
    ]

    undo [
        <category: 'buffer events'>

	codeWidget hasFocus ifTrue: [ codeWidget undo ]
    ]

    redo [
        <category: 'buffer events'>

	codeWidget hasFocus ifTrue: [ codeWidget redo ]
    ]

    copy [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget copy ]
    ]

    cut [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget cut ]
    ]

    paste [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget paste ]
    ]

    selectAll [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget selectAll ]
    ]

    doNotCheckCode [
        <category: 'text editing'>

        checkCode := false
    ]

    checkCodeWidgetAndUpdate: aBlock [
        <category: 'text editing'>

        self saveCodeOr: aBlock.
    ]

    saveCodeOr: dropBlock [
        <category: 'saving'>

        | dialog |
        checkCode ifFalse: [ checkCode := true. dropBlock value. ^ self ].
        self hasChanged ifFalse: [ dropBlock value. ^ self ].
        dialog := GTK.GtkMessageDialog
                                new: self parentWindow
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Accept changes to this method?'
                                tip: 'If you do not accept them, your changes to %1 will be lost...' % {self state}.

        dialog
            addButton: 'Drop' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Accept' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: [ self acceptIt ].
                res <= 1 ifTrue: dropBlock.
                dlg destroy ].
    ]

    acceptIt [
	<category: 'smalltalk events'>

        AcceptItCommand executeOn: self
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    state [
	<category: 'text editing'>

	^ state
    ]

    sourceCode [
	<category: 'accessing'>

	^ codeWidget sourceCode
    ]

    clearUndo [
	<category: 'code saved'>

	codeWidget clearUndo
    ]

    codeSaved [
	<category: 'code saved'>

	codeWidget codeSaved
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^ codeWidget selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        ^ codeWidget hasSelection
    ]

    hasChanged [
        <category: 'close events'>

        ^ codeWidget hasChanged
    ]
]

