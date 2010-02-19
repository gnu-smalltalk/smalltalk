GtkConcreteWidget subclass: GtkInspectorBrowserWidget [
    | checkCode namespaceWidget classHierarchyWidget classHierarchyUpdate iCategoryWidget iMethodWidget cCategoryWidget cMethodWidget codeWidget state |

    GtkInspectorBrowserWidget class >> title [
	<category: 'accessing'>

	^ 'Gtk class browser'
    ]

    buildBrowser [

	^ GTK.GtkHPaned new
	    pack1: self buildHierarchy resize: true shrink: false;
	    pack2: self buildProtocolAndMethod resize: true shrink: false;
	    showAll;
	    yourself
    ]

    buildClassBrowser [

	^ GTK.GtkHPaned new
            pack1: self buildClassMethodView resize: true shrink: false;
	    showAll;
	    yourself
    ]

    buildInstanceBrowser [

	^ GTK.GtkHPaned new
	    pack1: self buildInstanceMethodView resize: true shrink: false;
	    showAll;
	    yourself
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

	codeWidget := (GtkSourceCodeWidget new)
			initialize;
			browser: self;
			showAll;
			yourself.
    
	^ codeWidget mainWidget
    ]

    buildHierarchy [
	<category: 'user interface'>

	classHierarchyWidget := (GtkClassHierarchyWidget new)
				    initialize;
				    whenSelectionChangedSend: #onClassHierarchyChanged to: self;
				    showAll;
				    yourself.

	^ classHierarchyWidget mainWidget
    ]

    buildClassMethodView [
	<category: 'user interface'>

	cMethodWidget := (GtkMethodWidget new)
			    initialize;
			    whenSelectionChangedSend: #onClassSideMethodChanged to: self;
			    showAll;
			    yourself.

	^ cMethodWidget mainWidget
    ]

    buildInstanceMethodView [
        <category: 'user interface'>

        iMethodWidget := (GtkMethodWidget new)
                            initialize;
                            whenSelectionChangedSend: #onInstanceSideMethodChanged to: self;
                            showAll;
                            yourself.

        ^ iMethodWidget mainWidget
    ]

    initialize [
	<category: 'initialize-release'>

	| vpaned |
	classHierarchyUpdate := false.
	checkCode := true.
	vpaned := GTK.GtkVPaned new.
	state := NamespaceState on: self with: Smalltalk.
	self mainWidget: vpaned.
    
	vpaned
	    pack1: self buildBrowser resize: true shrink: false;
	    pack2: self buildCodeView resize: true shrink: true ;
	    showAll
    ]

    classInstanceSwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	self checkCodeWidget.
	aSmallInteger = 0 
	    ifTrue: [
		iMethodWidget hasSelectedMethod 
		    ifTrue: [ codeWidget sourceCode: iMethodWidget sourceCode ]
		    ifFalse: [ codeWidget sourceCode: '' ] ]
	    ifFalse: [
                cMethodWidget hasSelectedMethod
                    ifTrue: [ codeWidget sourceCode: cMethodWidget sourceCode ]
                    ifFalse: [ codeWidget sourceCode: '' ] ]
    ]

    onClassHierarchyChanged [
	<category: 'events'>

	| aClass |
	self checkCodeWidget.
	classHierarchyWidget hasSelectedClass ifFalse: [ ^ self ].
	classHierarchyUpdate := true.
        aClass := classHierarchyWidget selectedClass.

        iMethodWidget class: aClass withCategory: '*'.
        cMethodWidget class: aClass class withCategory: '*'.

        codeWidget sourceCode: ''.
	state := CategoryState on: self with: classHierarchyWidget selectedClass -> '*' 
    ]

    onInstanceSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidget.
	iMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	method := iMethodWidget selectedMethod.
	codeWidget sourceCode: iMethodWidget sourceCode.
	state := MethodState on: self with: classHierarchyWidget selectedClass -> method
    ]

    onClassSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidget.
	cMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	method := cMethodWidget selectedMethod.
	codeWidget sourceCode: cMethodWidget sourceCode.
	state := MethodState on: self with: classHierarchyWidget selectedClass class -> method
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

    checkCodeWidget [
        <category: 'text editing'>

        checkCode ifFalse: [ checkCode := true. ^ self ].
        self hasChanged ifFalse: [ codeWidget clearUndo. ^ self ].
        self saveCodeOnSave: [ self saveCode ].
        codeWidget clearUndo
    ]

    saveCodeOnSave: saveEvent [
        <category: 'saving'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: self parentWindow
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Save changes to this method?'
                                tip: 'If you do not save, your changes to %1 will be lost...' % {self stateString}.

        dialog
            addButton: 'Cancel' responseId: 0;
            addButton: 'Save' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    stateString [
	<category: 'text editing'>

	^ state displayString
    ]

    saveCode [
        <category: 'text saving'>

        state saveSource
    ]

    sourceCode [
	<category: 'accessing'>

	^ codeWidget sourceCode
    ]

    codeSaved [
	<category: 'code saved'>

	codeWidget codeSaved
    ]
]

