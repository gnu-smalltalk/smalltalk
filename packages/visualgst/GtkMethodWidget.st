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
	^ methodTree getModel
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
    
	methodTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Methods'}})
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
                            yourself.
	methodTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(model := GtkListModel on: methodTree getModel)
					contentsBlock: [ :each | {each methodViewIcon. each selector asString} ].
	^ GTK.GtkScrolledWindow withChild: methodTree
    ]

    hasSelectedTestMethod [
	<category: 'button event'>

	self hasSelectedMethod ifFalse: [^false].
	^ (self classOrMeta inheritsFrom: TestCase)
	    and: [ self selectedMethodSymbol startsWith: 'test' ]
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
	self hasSelectedTestMethod ifTrue: [
            menu appendMenuItems: {{'Run test'. self. #runTest}} ].
        menu appendMenuItems: {{'Browse senders'. self. #browseSenders}.
	    {'Browse implementors'. self. #browseImplementors}.
	    {}.
            {'Delete method'. self. #deleteMethod}.
            {}.
            {'Inspect method'. self. #inspectMethod}.
            {}.
            {'File out method'. self. #fileoutMethod}}.
        menu attachToWidget: methodTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	methodTree getSelection
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

	^ methodTree hasSelectedItem
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        ^ self selectedMethod selector
    ]

    selectedMethod [
	<category: 'accessing'>

	self hasSelectedMethod ifFalse: [ ^ self error: 'nothing is selected' ].
        ^ methodTree selection 
    ]

    selectAMethod: aSymbol [
        <category: 'item selection'>

	methodTree select: (self classOrMeta methodDictionary at: aSymbol)
    ]

    sourceCode [
	<category: 'accessing'>

	self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
	^ (self classOrMeta compiledMethodAt: self selectedMethodSymbol) methodRecompilationSourceString
    ]

    state [
        <category: 'testing'>

        self hasSelectedMethod ifFalse: [ ^ BrowserState new ].
        ^ MethodState with: self selectedMethod
    ]

    deleteMethod [
        <category: 'method events'>

        DeleteMethodCommand on: self
    ]

    inspectMethod [
        <category: 'method events'>

	InspectMethodCommand on: self
    ]

    browseSenders [
        <category: 'method events'>

	OpenSenderCommand on: self
    ]

    browseImplementors [
        <category: 'method events'>

	OpenImplementorCommand on: self
    ]

    runTest [
        <category: 'method events'>

	RunTestCommand on: self
    ]

    fileoutMethod [
        <category: 'method events'>

	FileoutMethodCommand on: self
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

