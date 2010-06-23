GtkConcreteWidget subclass: GtkClassBrowserWidget [
    GtkClassBrowserWidget class [ | Undo | ]

    | checkCode namespaceWidget classWidget classHierarchyWidget classHierarchyUpdate iCategoryWidget iMethodWidget cCategoryWidget cMethodWidget classAndInstanceSide codeWidget history historyUpdate state |

    GtkClassBrowserWidget class >> title [
	<category: 'accessing'>

	^ 'Gtk class browser'
    ]

    GtkClassBrowserWidget class >> undoStack [
	<category: 'accessing'>

        ^ Undo ifNil: [ Undo := (UndoStack new)
				    initialize;
				    yourself ]
    ]

    buildBrowser [

	^ GTK.GtkHPaned new
	    pack1: self buildCategoryClassesAndHierarchy resize: true shrink: false;
	    pack2: self buildProtocolAndMethod resize: true shrink: false;
	    showAll;
	    yourself
    ]

    buildCategoryAndClass [

	^ GTK.GtkHPaned new
	    pack1: self buildNamespaceView resize: true shrink: false;
            pack2: self buildClassView resize: true shrink: false;
	    showAll;
	    yourself
    ]

    buildClassBrowser [

	^ GTK.GtkHPaned new
            pack1: self buildClassCategoryView resize: true shrink: false;
            pack2: self buildClassMethodView resize: true shrink: false;
	    showAll;
	    yourself
    ]

    buildInstanceBrowser [

	^ GTK.GtkHPaned new
	    pack1: self buildInstanceCategoryView resize: true shrink: false;
	    pack2: self buildInstanceMethodView resize: true shrink: false;
	    showAll;
	    yourself
    ]

    buildProtocolAndMethod [

	^ classAndInstanceSide := (GTK.GtkNotebook new)
	    appendPage: self buildInstanceBrowser tabLabel: (GTK.GtkLabel new: 'Instance');
	    appendPage: self buildClassBrowser tabLabel: (GTK.GtkLabel new: 'Class');
	    showAll;
	    setCurrentPage: 0;
	    connectSignal: 'switch-page' to: self selector: #'classInstanceSwitchOn:page:number:' userData: nil;
	    yourself
    ]

    buildCategoryClassesAndHierarchy [

	^ (GTK.GtkNotebook new)
	    appendPage: self buildCategoryAndClass tabLabel: (GTK.GtkLabel new: 'Class');
	    appendPage: self buildHierarchy tabLabel: (GTK.GtkLabel new: 'Hierarchy');
	    showAll;
	    setCurrentPage: 0;
	    connectSignal: 'switch-page' to: self selector: #'namespaceHierarchySwitchOn:page:number:' userData: nil;
	    yourself
    ]

    buildNamespaceView [
	<category: 'user interface'>

	namespaceWidget := GtkCategorizedNamespaceWidget showAll
				whenSelectionChangedSend: #onNamespaceChanged to: self;
				yourself.

	^ namespaceWidget mainWidget
    ]

    buildClassView [
	<category: 'user interface'>

	classWidget := GtkCategorizedClassWidget showAll
			    whenSelectionChangedSend: #onClassChanged to: self;
			    yourself.

	^ classWidget mainWidget
    ]

    buildCodeView [
	<category: 'user interface'>

	codeWidget := GtkSourceCodeWidget showAll 
			parentWindow: self parentWindow;
			browser: self;
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

    buildInstanceCategoryView [
        <category: 'user interface'>

        iCategoryWidget := GtkCategoryWidget showAll
                            whenSelectionChangedSend: #onInstanceSideCategoryChanged to: self;
                            yourself.

        ^ iCategoryWidget mainWidget
    ]

    buildClassCategoryView [
	<category: 'user interface'>

	cCategoryWidget := GtkCategoryWidget showAll
			    whenSelectionChangedSend: #onClassSideCategoryChanged to: self;
			    yourself.

	^ cCategoryWidget mainWidget
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

    buildBrowserPaned [
        <category: 'user interface'>

	^ GTK.GtkVPaned new
	    pack1: self buildBrowser resize: true shrink: false;
	    pack2: self buildCodeView resize: true shrink: true ;
	    showAll;
	    yourself
    ]

    initializeHistory [
	<category: 'initialize-release'>

	historyUpdate := true.
	history := HistoryStack new
		    initialize: self;
		    yourself
    ]

    initialize [
	<category: 'initialize-release'>

	state := NamespaceState on: self with: Smalltalk.
	classHierarchyUpdate := false.
	checkCode := true.

	self 
	    initializeHistory;
	    mainWidget: self buildBrowserPaned
    ]

    postInitialize [
	<category: 'initialize'>

	codeWidget postInitialize
    ]

    updateHistory: aClass [
	<category: 'history'>

        historyUpdate ifTrue: [
                        GtkLauncher addHistory: aClass.
                        history push: aClass ]

    ]

    grabFocus [
	<category: 'user interface'>

	namespaceWidget mainWidget grabFocus
    ]

    namespaceHierarchySwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	aSmallInteger = 0 ifTrue: [ classHierarchyWidget classOrMeta: classWidget selectedClass ].
    ]

    classInstanceSwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    aSmallInteger = 0 
		ifTrue: [
		    iMethodWidget hasSelectedMethod 
			ifTrue: [ codeWidget sourceCode: iMethodWidget sourceCode ]
			ifFalse: [ codeWidget clear ] ]
		ifFalse: [
		    cMethodWidget hasSelectedMethod
			ifTrue: [ codeWidget sourceCode: cMethodWidget sourceCode ]
			ifFalse: [ codeWidget clear ] ] ]
    ]

    onNamespaceChanged [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    | namespace |
	    namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	    namespace := namespaceWidget selectedNamespace.
	    classWidget namespace: namespace category: namespaceWidget selectedCategory fullname.

	    classHierarchyUpdate ifFalse: [ classHierarchyWidget emptyModel ].
	    iCategoryWidget clear.
	    cCategoryWidget clear.
	    iMethodWidget clear.
	    cMethodWidget clear.
	    codeWidget namespaceDefinition: (NamespaceSource on: namespace).
	    state := NamespaceState on: self with: namespace ]
    ]

    onClassChanged [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    | aClass |
	    classWidget hasSelectedClass ifFalse: [ ^ self ].
	    aClass := classWidget selectedClass.
	    classHierarchyUpdate ifFalse: [ classHierarchyWidget classOrMeta: aClass ].
	    iCategoryWidget classOrMeta: aClass.
	    cCategoryWidget classOrMeta: aClass class.
	    iCategoryWidget unselectAll.
	    cCategoryWidget unselectAll.

	    self updateHistory: aClass.

	    iMethodWidget emptyModel.
	    cMethodWidget emptyModel.
	    codeWidget classDefinition: (ClassSource displayHeaderOf: aClass).
	    state := ClassState on: self with: aClass ]
    ]

    onClassHierarchyChanged [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    | aClass |
	    classHierarchyWidget hasSelectedClass ifFalse: [ ^ self ].
	    classHierarchyUpdate := true.
	    aClass := classHierarchyWidget selectedClass.
	    namespaceWidget selectedNamespace ~= classHierarchyWidget selectedClass environment
						    ifTrue: [ namespaceWidget selectANamespace: aClass environment ]
						    ifFalse: [ namespaceWidget selectedCategory ~= aClass classCategory 
											ifTrue: [ namespaceWidget selectANamespace: aClass environment ] ].
	    classWidget selectAClass: aClass class.
	    classHierarchyUpdate := false ]
    ]

    onInstanceSideCategoryChanged [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    iCategoryWidget hasSelectedCategory ifFalse: [ ^ self ].
	    iMethodWidget class: classWidget selectedClass withCategory: iCategoryWidget selectedCategory.

	    codeWidget clear.
	    state := CategoryState on: self with: classWidget selectedClass -> iCategoryWidget selectedCategory ]
    ]

    onClassSideCategoryChanged [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    cCategoryWidget hasSelectedCategory ifFalse: [ ^ self ].
	    cMethodWidget class: classWidget selectedClass class withCategory: cCategoryWidget selectedCategory.

	    codeWidget clear.
	    state := CategoryState on: self with: classWidget selectedClass class -> cCategoryWidget selectedCategory ]
    ]

    onInstanceSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidgetAndUpdate: [
	    iMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	    method := iMethodWidget selectedMethod.
	    codeWidget sourceCode: iMethodWidget sourceCode.
	    state := MethodState on: self with: method ]
    ]

    onClassSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidgetAndUpdate: [
	    cMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	    method := cMethodWidget selectedMethod.
	    codeWidget sourceCode: cMethodWidget sourceCode.
	    state := MethodState on: self with: method ]
    ]

    undoStack [
	<category: 'accessings'>

	^ self class undoStack
    ]

    cancel [
	<category: 'edit events'>

	codeWidget hasFocus ifTrue: [ ^codeWidget cancel ]
    ]

    undo [
	<category: 'edit events'>

	codeWidget hasFocus 
	    ifTrue: [ codeWidget undo ]
	    ifFalse: [ self undoStack undo ]
    ]

    redo [
	<category: 'edit events'>

        codeWidget hasFocus
            ifTrue: [ codeWidget redo ]
            ifFalse: [ self undoStack redo ]
    ]

    acceptIt [
	<category: 'smalltalk events'>

        AcceptItCommand on: self
    ]

    fileoutNamespace [
	<category: 'namespace events'>

	FileoutNamespaceCommand on: self
    ]

    newNamespace [
	<category: 'namespace events'>

	AddNamespaceCommand on: self
    ]

    renameNamespace [
	<category: 'namespace events'>

	RenameNamespaceCommand on: self
    ]

    deleteNamespace [
	<category: 'namespace events'>

	DeleteNamespaceCommand on: self
    ]

    inspectNamespace [
	<category: 'namespace events'>

	InspectNamespaceCommand on: self
    ]

    fileoutClass [
	<category: 'class events'>
    
	FileoutClassCommand on: classWidget
    ]

    extractNamespaceFrom: aNamespace [
	<category: 'namespace as directory'>

	| list namespace |
	namespace := aNamespace.
	list := OrderedCollection new.
	[ namespace isNil ] whileFalse: [
            list addFirst: namespace displayString.
            namespace := namespace superspace ].
	^ list
    ]

    newClass [
	<category: 'class events'>
	
	AddClassCommand on: self
    ]

    renameClass [
	<category: 'class events'>

	RenameClassCommand on: self
    ]

    deleteClass [
	<category: 'class events'>

	DeleteClassCommand on: self
    ]

    inspectClass [
	<category: 'class events'>

	InspectClassCommand on: self
    ]

    viewedCategoryWidget [
         <category: 'category events'>

        ^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ iCategoryWidget ]
            ifFalse: [ cCategoryWidget ]
   ]

    viewedCategoryModel [
	<category: 'category events'>

	^ self viewedCategoryWidget model 
    ]

    fileoutCategory [
        <category: 'category events'>

	self viewedCategoryWidget fileoutCategory
    ]

    newCategory [
        <category: 'category events'>

	AddCategoryCommand on: self
    ]

    renameCategory [
        <category: 'category events'>

	RenameCategoryCommand on: self
    ]

    viewedMethodWidget [
         <category: 'category events'>

        ^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ iMethodWidget ]
            ifFalse: [ cMethodWidget ]
   ]

    sourceCode [
	<category: 'accessing'>

	^ codeWidget sourceCode
    ]

    compileError: aString line: line [
        <category: 'method events'>

        codeWidget compileError: aString line: line
    ]

    newMethod [
	<category: 'method events'>

	AcceptItCommand on: self.
    ]

    deleteMethod [
	<category: 'method events'>

	DeleteMethodCommand on: self
    ]

    inspectMethod [
	<category: 'method events'>

	InspectMethodCommand on: self
    ]

    fileoutMethod [
	<category: 'method events'>

	FileoutMethodCommand on: self
    ]

    selectANamespace: aNamespace [
	<Category: 'selection'>

	namespaceWidget selectANamespace: aNamespace.
        classWidget namespace: aNamespace.

        classHierarchyWidget emptyModel.
        iCategoryWidget clear.
        cCategoryWidget clear.
        iMethodWidget clear.
        cMethodWidget clear.
        codeWidget namespaceDefinition: (NamespaceSource on: aNamespace)
    ]

    selectAClass: aClass [
	<category: 'selection'>

        classWidget selectAClass: aClass class.
	classHierarchyWidget classOrMeta: aClass class.
        iCategoryWidget classOrMeta: aClass.
        cCategoryWidget classOrMeta: aClass class.

        iMethodWidget clear.
        cMethodWidget clear
    ]

    select: aSelector in: aMethodWidget withCategory: aCategoryWidget [
	<category: 'selection'>

        | class |
	aSelector isNil ifFalse: [
            class := classWidget selectedClass.

            class := (class selectors includes: aSelector) ifFalse: [ class class ] ifTrue: [ class ].
	    aCategoryWidget
		classOrMeta: class;
		selectACategory: (class compiledMethodAt: aSelector) methodCategory.
            aMethodWidget
                class: class withCategory: (class compiledMethodAt: aSelector) methodCategory ].

	aMethodWidget selectAMethod: aSelector
    ]

    selectAnInstanceMethod: aSelector [
        <category: 'selection'>

	self select: aSelector in: iMethodWidget withCategory: iCategoryWidget.
	classAndInstanceSide setCurrentPage: 0
    ]

    selectAClassMethod: aSelector [
	<category: 'selection'>

	self select: aSelector in: cMethodWidget withCategory: cCategoryWidget.
	classAndInstanceSide setCurrentPage: 1
    ]

    targetObject [
        <category: 'target'>

        ^state classOrMeta
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

	DoItCommand on: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand on: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand on: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand on: self
    ]

    forward [
	<category: 'history events'>

	history next
    ]

    back [
	<category: 'history events'>

	history previous
    ]

    updateClass: aClass [
	<category: 'history events'>

	historyUpdate := false.
	self selectAClass: aClass.
	historyUpdate := true.
    ]

    sourceCodeWidgetHasFocus [
	<category: 'testing'>

	^ parentWindow getFocus address = codeWidget textview address
    ]

    copy [
        <category: 'text editing'>

	codeWidget copy
    ]

    cut [
        <category: 'text editing'>

	codeWidget cut
    ]

    paste [
        <category: 'text editing'>

	codeWidget paste
    ]

    selectAll [
        <category: 'text editing'>

	codeWidget selectAll
    ]
 
    hasSelection [
	<category:'text testing'>

	^ codeWidget hasSelection
    ]
 
    selectedMethodSymbol [
        <category: 'text editing'>

        ^codeWidget selectedMethodSymbol
    ]

    selectedText [
	<category: 'text editing'>

	^ codeWidget selectedText
    ]

    doNotCheckCode [
	<category: 'text editing'>

	checkCode := false
    ]

    checkCodeWidgetAndUpdate: aBlock [
        <category: 'text editing'>

        self saveCodeOr: [ aBlock value. self clearUndo ]
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
                                message: 'Accept changes before exiting?'
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

    state [
	<category: 'accessing'>

	^ state
    ]

    clearUndo [
	<category: 'code saved'>

	codeWidget clearUndo
    ]

    codeSaved [
	<category: 'code saved'>

	codeWidget codeSaved
    ]

    close [
	<category: 'user interface'>

	self checkCodeWidgetAndUpdate: []
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    showFind [
	<category: 'user interface'>

	codeWidget showFind
    ]

    showReplace [
	<category: 'user interface'>

	codeWidget showReplace
    ]
]

