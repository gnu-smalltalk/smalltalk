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

    initializeHistory [
	<category: 'initialize-release'>

	historyUpdate := true.
	history := HistoryStack new
		    initialize: self;
		    yourself
    ]

    initialize [
	<category: 'initialize-release'>

	| vpaned |
	state := NamespaceState on: self with: Smalltalk.
	classHierarchyUpdate := false.
	checkCode := true.
	vpaned := GTK.GtkVPaned new.

	self mainWidget: vpaned.
	self initializeHistory.
 
	vpaned
	    pack1: self buildBrowser resize: true shrink: false;
	    pack2: self buildCodeView resize: true shrink: true ;
	    showAll
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

	self checkCodeWidget.
	aSmallInteger = 0 
	    ifTrue: [
		iMethodWidget hasSelectedMethod 
		    ifTrue: [ codeWidget sourceCode: iMethodWidget sourceCode ]
		    ifFalse: [ codeWidget clearCode ] ]
	    ifFalse: [
                cMethodWidget hasSelectedMethod
                    ifTrue: [ codeWidget sourceCode: cMethodWidget sourceCode ]
                    ifFalse: [ codeWidget clearCode ] ]
    ]

    onNamespaceChanged [
	<category: 'events'>

	| namespace |
	self checkCodeWidget.
	namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	namespace := namespaceWidget selectedNamespace.
	classWidget namespace: namespace category: namespaceWidget selectedCategory.

	classHierarchyUpdate ifFalse: [ classHierarchyWidget emptyModel ].
	iCategoryWidget emptyModel.
	cCategoryWidget emptyModel.
	iMethodWidget emptyModel.
	cMethodWidget emptyModel.
	codeWidget namespaceDefinition: (NamespaceSource on: namespace).
	state := NamespaceState on: self with: namespace
    ]

    onClassChanged [
	<category: 'events'>

        | aClass |
	self checkCodeWidget.
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	aClass := classWidget selectedClass.
	classHierarchyUpdate ifFalse: [ classHierarchyWidget classOrMeta: aClass ].
	iCategoryWidget classOrMeta: aClass.
	cCategoryWidget classOrMeta: aClass class.
	iCategoryWidget unselectAll.
        cCategoryWidget unselectAll.

	historyUpdate ifTrue: [ history push: aClass ].

	iMethodWidget emptyModel.
        cMethodWidget emptyModel.
	codeWidget classDefinition: (ClassSource displayHeaderOf: aClass).
	state := ClassState on: self with: aClass
    ]

    onClassHierarchyChanged [
	<category: 'events'>

	| aClass |
	self checkCodeWidget.
	classHierarchyWidget hasSelectedClass ifFalse: [ ^ self ].
	classHierarchyUpdate := true.
        aClass := classHierarchyWidget selectedClass.
	namespaceWidget selectANamespace: aClass environment.
	classWidget selectAClass: aClass.
	classHierarchyUpdate := false
    ]

    onInstanceSideCategoryChanged [
	<category: 'events'>

	| category |
	self checkCodeWidget.
	iCategoryWidget hasSelectedCategory ifFalse: [ ^ self ].
	iMethodWidget class: classWidget selectedClass withCategory: iCategoryWidget selectedCategory.

	codeWidget clearCode.
	state := CategoryState on: self with: classWidget selectedClass -> iCategoryWidget selectedCategory
    ]

    onClassSideCategoryChanged [
	<category: 'events'>

	self checkCodeWidget.
	cCategoryWidget hasSelectedCategory ifFalse: [ ^ self ].
	cMethodWidget class: classWidget selectedClass class withCategory: cCategoryWidget selectedCategory.

	codeWidget clearCode.
	state := CategoryState on: self with: classWidget selectedClass class -> cCategoryWidget selectedCategory
    ]

    onInstanceSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidget.
	iMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	method := iMethodWidget selectedMethod.
	codeWidget sourceCode: iMethodWidget sourceCode.
	state := MethodState on: self with: classWidget selectedClass -> method
    ]

    onClassSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidget.
	cMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	method := cMethodWidget selectedMethod.
	codeWidget sourceCode: cMethodWidget sourceCode.
	state := MethodState on: self with: classWidget selectedClass class -> method
    ]

    undoStack [
	<category: 'accessings'>

	^ self class undoStack
    ]

    cancel [
	<category: 'edit events'>

	codeWidget hasFocus 
	    ifTrue: [ codeWidget cancel ]
	    ifFalse: [ self undoStack undo ]
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

        | categoryWidget |
	namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	categoryWidget := self viewedCategoryWidget.
        categoryWidget hasSelectedCategory ifFalse: [ ^ self acceptClassDefinition ].
	self newMethod
    ]
    
    acceptClassDefinitionOn: aNamespace [
	<category: 'class event'>

	codeWidget codeSaved.
        Namespace current: aNamespace.
        ^ (ReadStream on: codeWidget sourceCode) fileIn
    ]

    acceptClassDefinition [
	<category: 'class event'>

	^ self 
	    acceptClassDefinitionOn: (namespaceWidget hasSelectedNamespace
					ifTrue: [ namespaceWidget selectedNamespace ]
					ifFalse: [ Smalltalk ]).
    ]

    acceptClassDefinitionForState: aState [
        <category: 'class event'>

        ^ self acceptClassDefinitionOn: aState namespace 
    ]

    fileoutNamespace [
	<category: 'namespace events'>

	namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	FileoutNamespaceCommand on: namespaceWidget selectedNamespace
    ]

    fileoutNamespace: aDirectory [
	<category: 'namespace events'>

	| namespace stream |
	namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	namespace := namespaceWidget selectedNamespace.
	self fileoutNamespace: namespace on: (File name: aDirectory) / namespace name
    ]

    fileoutNamespace: aNamespace on: aDirectory [
	<category: 'namespace events'>

	| stream |
	aDirectory exists ifFalse: [ aDirectory createDirectory ].
	stream := FileStream open: (aDirectory / 'self.st') asString mode: FileStream write.
	(NamespaceSource write: aNamespace on: stream)
                header.
	aNamespace do: [ :each |
	    (each isNil not and: [ each isClass and: [ each environment = aNamespace ] ])
		    ifTrue: [ stream := FileStream open: (aDirectory / ((each name asString) , '.st')) asString mode: FileStream write.
			    (ClassSource write: each on: stream)
				source ] ].
	aNamespace allSubspacesDo: [ :space |
            | dir |
            dir := (aDirectory / space name).
	    self fileoutNamespace: space on: dir ]
    ]

    hasSelectedNamespace [
	<category: 'testing'>

	^ namespaceWidget hasSelectedNamespace
    ]

    selectedNamespace [
	<category: 'testing'>

	^ namespaceWidget selectedNamespace
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

	namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	GtkInspector openOn: namespaceWidget selectedNamespace
    ]

    fileoutClass [
	<category: 'class events'>
    
        classWidget hasSelectedClass ifFalse: [ ^ self ].
	FileoutClassCommand on: classWidget selectedClass
    ]

    fileoutClass: aFile [
        <category: 'class events'>

        | class stream |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        class := classWidget selectedClass.
        stream := FileStream open: aFile mode: FileStream write.
        (ClassSource write: class on: stream)
	    source
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

    hasSelectedClass [
	<category: 'accessing'>

	^ classWidget hasSelectedClass
    ]

    selectedClass [
	<category: 'accessing'>

	^ classWidget selectedClass
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

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	GtkInspector openOn: classWidget selectedClass
    ]

    classOrMetaSelected [
	<category: 'class accessing'>

	| class |
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	class := classWidget selectedClass.
	^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ class ]
            ifFalse: [ class class ]	
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

        | categoryWidget |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        categoryWidget := self viewedCategoryWidget.
        categoryWidget hasSelectedCategory ifFalse: [ ^ self ].
	FileoutCategoryCommand on: self classOrMetaSelected categorized: categoryWidget selectedCategory
    ]

    fileoutCategory: aFile [
        <category: 'category events'>

        | categoryWidget stream |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        categoryWidget := self viewedCategoryWidget.
        categoryWidget hasSelectedCategory ifFalse: [ ^ self ].
	stream := FileStream open: aFile mode: FileStream write.
	(CategorySource write: categoryWidget selectedCategory of: self classOrMetaSelected on: stream)
	    source
    ]

    hasSelectedCategory [
	<category: 'testing'>
	
	^ self viewedCategoryWidget hasSelectedCategory
    ]

    selectedCategory [
	<category: 'accessing'>

	^ self viewedCategoryWidget selectedCategory
    ]

    newCategory [
        <category: 'category events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	AddCategoryCommand on: self
    ]

    renameCategory [
        <category: 'category events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	RenameCategoryCommand on: self
    ]

    deleteCategory [
        <category: 'category events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	DeleteCategoryCommand on: self
    ]

    inspectCategory [
        <category: 'category events'>

    ]

    viewedMethodWidget [
         <category: 'category events'>

        ^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ iMethodWidget ]
            ifFalse: [ cMethodWidget ]
   ]

    viewedMethodModel [
        <category: 'category events'>

        ^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ GtkMethodModel currentOn: classWidget selectedClass withCategory: iCategoryWidget selectedCategory ]
            ifFalse: [ GtkMethodModel currentOn: classWidget selectedClass class withCategory: cCategoryWidget selectedCategory ]
    ]

    hasSelectedMethod [
	<category: 'testing'>

	^ self viewedMethodWidget hasSelectedMethod
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

	^ self viewedMethodWidget selectedMethodSymbol
    ]

    sourceCode [
	<category: 'accessing'>

	^ codeWidget sourceCode
    ]

    newMethod [
	<category: 'method events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	AddMethodCommand on: self.
    ]

    deleteMethod [
	<category: 'method events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	DeleteMethodCommand on: self
    ]

    inspectMethod [
	<category: 'method events'>

	| methodWidget |
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	methodWidget := self viewedMethodWidget.
        GtkInspector openOn: methodWidget selectedMethod
    ]

    fileoutMethod [
	<category: 'method events'>

        | methodWidget stream |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        methodWidget := self viewedMethodWidget.
	FileoutMethodCommand on: methodWidget selectedMethod
    ]

    fileoutMethod: aFile [
	<category: 'method events'>

        | methodWidget stream |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        methodWidget := self viewedMethodWidget.
        stream := FileStream open: aFile mode: FileStream write.
        (MethodSource write: methodWidget selectedMethod on: stream)
            source
    ]

    selectANamespace: aNamespace [
	<Category: 'selection'>

	namespaceWidget selectANamespace: aNamespace.
        classWidget namespace: aNamespace.

        classHierarchyWidget emptyModel.
        iCategoryWidget emptyModel.
        cCategoryWidget emptyModel.
        iMethodWidget emptyModel.
        cMethodWidget emptyModel.
        codeWidget namespaceDefinition: (NamespaceSource on: aNamespace)
    ]

    selectAClass: aClass [
	<category: 'selection'>

        classWidget selectAClass: aClass.
	classHierarchyWidget classOrMeta: aClass.
        iCategoryWidget classOrMeta: aClass.
        cCategoryWidget classOrMeta: aClass class.

        iMethodWidget emptyModel.
        cMethodWidget emptyModel
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

	aMethodWidget selectAMethod: aSelector asString
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

    doIt [
	<category: 'smalltalk event'>

	| class |
	classWidget hasSelectedClass ifFalse: [ ^ self ].

	class := classWidget selectedClass.

	codeWidget 
	    object: class;
	    doIt
    ]

    debugIt [
	<category: 'smalltalk event'>

        | class |
        classWidget hasSelectedClass ifFalse: [ ^ self ].

        class := classWidget selectedClass.

        codeWidget
            object: class;
            debugIt
    ]

    inspectIt [
	<category: 'smalltalk event'>

        | class |
        classWidget hasSelectedClass ifFalse: [ ^ self ].

        class := classWidget selectedClass.

        codeWidget
            object: class;
	    inspectIt
    ]

    printIt [
	<category: 'smalltalk event'>

        | class |
        classWidget hasSelectedClass ifFalse: [ ^ self ].

        class := classWidget selectedClass.

        codeWidget
            object: class;
            printIt
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
   
    selectedText [
	<category: 'text editing'>

	^ codeWidget selectedText
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
                                message: 'Save the code before exiting?'
                                tip: 'If you do not save, your changes to %1 will be lost...' % {self stateString}.

        dialog
            addButton: 'Cancel' responseId: 0;
            addButton: 'Save' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]

    stateString [
	<category: 'accessing'>

	^ state displayString
    ]

    saveCode [
	<category: 'text saving'>

	state saveSource
    ]

    codeSaved [
	<category: 'code saved'>

	codeWidget codeSaved
    ]

    close [
	<category: 'user interface'>

	self checkCodeWidget
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]
]

