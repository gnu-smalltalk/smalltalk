GtkConcreteWidget subclass: GtkMethodWidget [
    | browser model methodTree class category |

    GtkMethodWidget >> on: aClass withCategory: aCategory [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    class: aClass withCategory: aCategory;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self 
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #method change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeEvent:'
    ]

    browser [
	<category: 'accessing'>

	^ browser
    ]

    browser: anObject [
	<category: 'accessing'>

	browser := anObject.
    ]

    category [
	<category: 'accessing'>

	^ category
    ]

    category: aString [
	<category: 'accessing'>

	category := aString.
	self classOrMeta methodDictionary ifNil: [ 
		model clear. 
		^ self].
	model 
	    item: ((self classOrMeta methodDictionary select: [ :each | self category = '*' or: [ each methodCategory = self category ] ]) 
												    asArray sort: [ :a :b | a selector <= b selector ]);
	    refresh
    ]

    classOrMeta [
	<category: 'accessing'>

	^ class
    ]

    class: aClass withCategory: aString [
	<category: 'accessing'>

	class := aClass.
	self category: aString
    ]

    gtkModel [
	^ methodTree treeView getModel
    ]

    emptyModel [
        <category: 'accessing'>

	self clear
    ]

    clear [
        <category: 'accessing'>

	model clear
    ]

    includesCategory: aSymbol [
        <category: 'testing'>

        self category = '*' ifTrue: [ ^ true ].
        (self category = 'still unclassified' and: [ aSymbol isNil ]) ifTrue: [ ^ true ].
        ^ self category = aSymbol
    ]

    buildTreeView [
        <category: 'user interface'>
    
	methodTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Methods'}}.
        methodTree connectToWhenPopupMenu: (MethodMenus on: self).
	methodTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(model := GtkListModel on: methodTree treeView getModel)
					contentsBlock: [ :each | {each methodViewIcon. each selector asString} ].
	^ methodTree mainWidget
    ]

    hasSelectedTestMethod [
	<category: 'button event'>

	self ifNoSelection: [ ^ false ].
	^ (self classOrMeta inheritsFrom: TestCase)
	    and: [ self selectedMethodSymbol startsWith: 'test' ]
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	methodTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    launcher [
	<category: 'accessing'>

	^ browser ifNotNil: [ browser launcher ]
    ]

    browserHasFocus [
	<category: 'accessing'>

	^ true
    ]

    sourceCodeWidgetHasFocus [
	<category: 'accessing'>

	^ false
    ]

    classOrMeta [
	<category: 'accessing'>

	^ class
    ]

    selectedCategory [
	<category: 'accessing'>

	^ category = '*' 
	    ifTrue: [ nil ]
	    ifFalse: [ category ]
    ]

    hasSelectedMethod [
	<category: 'testing'>

	^ methodTree treeView hasSelectedItem
    ]

    ifNoSelection: aBlock [
        <category: 'testing'>

        self hasSelectedMethod ifFalse: aBlock
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        ^ self selectedMethod selector
    ]

    selectedMethod [
	<category: 'accessing'>

	self ifNoSelection: [ self error: 'nothing is selected' ].
        ^ methodTree treeView selection 
    ]

    selectAMethod: aSymbol [
        <category: 'item selection'>

	methodTree treeView select: (self classOrMeta methodDictionary at: aSymbol)
    ]

    sourceCode [
	<category: 'accessing'>

	self ifNoSelection: [ self error: 'Nothing is selected' ].
	^ (self classOrMeta compiledMethodAt: self selectedMethodSymbol) methodRecompilationSourceString
    ]

    state [
        <category: 'testing'>

        self ifNoSelection: [ ^ BrowserState new ].
        ^ MethodState with: self selectedMethod
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ self includesCategory: anEvent item methodCategory ] ) ifFalse: [ ^ self ].
        model append: anEvent item
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ self includesCategory: anEvent item methodCategory ]) ifFalse: [ ^ self ].
        model remove: anEvent item
    ]
]

