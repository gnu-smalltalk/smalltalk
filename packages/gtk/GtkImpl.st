GtkTextBuffer extend [

    insertAtEnd: aString [
        <category: 'accessing'>

        self insert: self getEndIter text: aString
    ]
]


GtkAlignment class extend [
    new [
	<category: 'instance creation'>
        ^self new: 0 yalign: 0 xscale: 1 yscale: 1
    ]
]


GdkDrawable extend [

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 window.  The context is invalidated after aBlock returns."

	<category: 'accessing'>
	| context |
	[ aBlock value: (context := Cairo.CairoContext context: self cairoCreate) ]
	    ensure: [ context isNil ifFalse: [ context release ] ]
    ]

]

GtkWidget extend [

    getSizeRequest [
	"Answer the size the widget has requisitioned."

	<category: 'accessing'>
	| requisition |
	requisition := GTK.GtkRequisition new.
	self sizeRequest: requisition.
	^requisition asPoint
    ]

]



GtkMessageDialog class extend [

    new: parent flags: flags type: type buttons: buttons message: message [
	<category: 'instance creation'>
	^self 
	    new: parent
	    flags: flags
	    type: type
	    buttons: buttons
	    messageFormat: '%s'
	    varargs: {message}
    ]

    new: parent flags: flags type: type buttons: buttons message: message tip: tip [
	<category: 'instance creation'>
	^self 
	    newWithMarkup: parent
	    flags: flags
	    type: type
	    buttons: buttons
	    messageFormat: '<big><b>%s</b></big>

%s'
	    varargs: {message. tip}
    ]

    newWithMarkup: parent flags: flags type: type buttons: buttons message: message [
	<category: 'instance creation'>
	^self 
	    newWithMarkup: parent
	    flags: flags
	    type: type
	    buttons: buttons
	    messageFormat: (message copyReplaceAll: '%' with: '%%')
	    varargs: #()
    ]
]



GtkRequisition class extend [

    fromPoint: point [
	<category: 'instance creation'>
	| ba |
	ba := (CShortType arrayType: 2) new.
	ba at: 0 put: point x.
	ba at: 1 put: point y.
	^(ba castTo: self type)
	    addToBeFinalized;
	    yourself
    ]

]



GtkRequisition extend [

    x [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 0
    ]

    y [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 1
    ]

    asPoint [
	<category: 'conversion'>
	^
	{self width value.
	self height value}
    ]

]



GdkRectangle class extend [

    fromRectangle: rect [
	<category: 'instance creation'>
	| ba |
	ba := (CShortType arrayType: 4) new.
	ba at: 0 put: rect left.
	ba at: 1 put: rect top.
	ba at: 2 put: rect width.
	ba at: 3 put: rect height.
	^(ba castTo: self type)
	    addToBeFinalized;
	    yourself
    ]

]



GdkRectangle extend [

    left [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 0
    ]

    top [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 1
    ]

    right [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 0) + (ba at: 2)
    ]

    bottom [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 1) + (ba at: 3)
    ]

    width [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 2
    ]

    height [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^ba at: 3
    ]

    origin [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 0) @ (ba at: 1)
    ]

    extent [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 2) @ (ba at: 3)
    ]

    corner [
	<category: 'accessing'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^((ba at: 0) + (ba at: 2)) @ ((ba at: 1) + (ba at: 3))
    ]

    asRectangle [
	<category: 'conversion'>
	| ba |
	ba := self castTo: (CShortType arrayType: 4).
	^(ba at: 0) @ (ba at: 1) extent: (ba at: 2) @ (ba at: 3)
    ]

]



GtkTreeIter class extend [

    Prototype := nil.

    gcNew [
	^self type gcNew
    ]

    new [
	<category: 'instance creation'>
        Prototype isNil ifTrue: [ Prototype := self type gcNew ].
	^Prototype copy
	    addToBeFinalized;
	    yourself
    ]

]



GtkTextIter class extend [

    Prototype := nil.

    gcNew [
	^self type gcNew
    ]

    new [
	<category: 'instance creation'>
        Prototype isNil ifTrue: [ Prototype := self type gcNew ].
	^Prototype copy
	    addToBeFinalized;
	    yourself
    ]

]



GtkTreeModel extend [

    getIter: path [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	^(self getIter: iter path: path) ifTrue: [iter] ifFalse: [nil]
    ]

    getIterFirst [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self getIterFirst: iter.
	^iter
    ]

    iterChildren: parent [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self iterChildren: iter parent: parent.
	^iter
    ]

    iterNthChild: parent n: n [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self 
	    iterNthChild: iter
	    parent: parent
	    n: n.
	^iter
    ]

    iterParent: child [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self iterParent: iter child: child.
	^iter
    ]

]



GtkTreeSelection extend [

    getSelected [
	<category: 'accessing'>
	| has iter |
	iter := GTK.GtkTreeIter new.
	has := self getSelected: nil iter: iter.
	^has ifTrue: [iter] ifFalse: [nil]
    ]

]



GtkListStore extend [

    insert: anInteger [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self insert: iter position: anInteger.
	^iter
    ]

    insertBefore: sibling [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self insertBefore: iter sibling: sibling.
	^iter
    ]

    insertAfter: sibling [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self insertAfter: iter sibling: sibling.
	^iter
    ]

    prepend [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self prepend: iter.
	^iter
    ]

    append [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self append: iter.
	^iter
    ]

]



GtkTextBuffer extend [

    setText: aString [
	"Set my contents"

	<category: 'accessing'>
	self setText: aString len: aString size
    ]

    insertAtCursor: aString [
	"Insert aString at the curser."

	<category: 'accessing'>
	self insertAtCursor: aString len: aString size
    ]

    getBounds [
	"Answer my entire contents."

	<category: 'accessing'>
	| start end |
	start := GTK.GtkTextIter new.
	end := GTK.GtkTextIter new.
	self getBounds: start end: end.
	^
	{start.
	end}
    ]

    getIterAtMark: mark [
	"Answer an iterator for mark"

	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTextIter new.
	self getIterAtMark: iter mark: mark.
	^iter
    ]

    getSelectionBounds [
	"Answer my selection bounds"

	<category: 'accessing'>
	| start end |
	start := GTK.GtkTextIter new.
	end := GTK.GtkTextIter new.
	self getSelectionBounds: start end: end.
	^
	{start.
	end}
    ]

    getIterAtLine: line [
	"Answer an iterator at the beginning of line."

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self getIterAtLine: result lineNumber: line.
	^result
    ]

    getIterAtLineOffset: lineNumber charOffset: charOffset [
	"Answer an iterator at offset in me."

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self 
	    getIterAtLineOffset: result
	    lineNumber: lineNumber
	    charOffset: charOffset.
	^result
    ]

    getStartIter [
	"Answer a start iterator."

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self getStartIter: result.
	^result
    ]

    getEndIter [
	"Answer an end iterator"

	<category: 'accessing'>
	| result |
	result := GTK.GtkTextIter new.
	self getEndIter: result.
	^result
    ]

    insert: iter text: aString [
	"Insert aString at the insertion point."

	<category: 'accessing'>
	self 
	    insert: iter
	    text: aString
	    len: aString size
    ]

]



Gtk class extend [
    | loop |

    mainQuit [
	<category: 'event loop'>
        GLib.GMainLoop mainQuit
    ]

    main [
	"Main loop implementation.  Same as gtk_main, but it splits
         g_main_context_run in two threads so that Smalltalk processes
         run.  Like gtk_main, it is ended with Gtk>>#mainQuit."

	<category: 'event loop'>
	GLib.GMainLoop main
    ]

]



GtkAccelGroup class extend [

    acceleratorParse: accelerator [
	<category: 'C call-outs'>

	| cAccKey cAccMod |
	cAccKey := CInt gcValue: 0.
	cAccMod := CInt gcValue: 0.
	GTK.Gtk acceleratorParse: accelerator acceleratorKey: cAccKey acceleratorMods: cAccMod.
	^ {cAccKey value. cAccMod value}
    ]

    acceleratorGroup: aGtkAccelGroup accelerator: aString path: aPathString [
	<category: 'C call-outs'>

	| result |
	result := self acceleratorParse: aString.
	GTK.GtkAccelMap addEntry: aPathString accelKey: result first accelMods: result second
    ]
]


GtkAccelGroup extend [

    append: anArray [
        <category: 'accessing'>

        anArray do: [ :each |
            self class
                acceleratorGroup: self
                accelerator: each first
                path: each second ]
    ]
]



GtkButton class extend [

    label: aString onPressedSend: aSymbol to: anObject [
    <category: 'instance creation'>

    ^ (GTK.GtkButton newWithLabel: aString)
        connectSignal: 'pressed' to: anObject selector: aSymbol userData: nil;
        yourself
    ]
]


GTK.GtkDialog extend [
    run [
        <category: 'services'>

        | signals loop answer modal destroyed |
        modal := self getModal.
        self setModal: true.
        destroyed := false.
        signals := {
            self
                connectSignal: 'response'
                to: [ :dialog :integer | answer := integer. loop quit ]
                selector: #value:value:.

            self
                connectSignal: 'unmap'
                to: loop
                selector: #quit.

            self
                connectSignal: 'delete_event'
                to: [ answer := Gtk gtkResponseDeleteEvent. loop quit. true ]
                selector: #value.

            self
                connectSignal: 'destroy'
                to: [ destroyed := true ]
                selector: #value }.

        loop := GLib.GMainLoop pushMainLoop.
        [self show. loop run] ensure: [loop pop].
        destroyed ifFalse: [
            self setModal: modal.
            signals do: [ :each | self disconnectSignal: each ] ].
        ^answer
    ]
]


GTK.GtkFileChooserDialog class extend [

    for: aGtkFileChooserAction title: aString parent: aGtkWidget button: aGtkStock  [
        <category: 'instance creation'>

        ^ self
            new: aString
            parent: aGtkWidget
            action: aGtkFileChooserAction
            varargs: {GTK.Gtk gtkStockCancel.
                    GTK.Gtk gtkResponseCancel.
                    aGtkStock.
                    GTK.Gtk gtkResponseAccept.
                    nil}
    ]

    save: aString parent: aGtkWidget [
        <category: 'instance creation'>

        ^ self
            for: GTK.Gtk gtkFileChooserActionSave
            title: aString
            parent: aGtkWidget
            button: GTK.Gtk gtkStockSave
    ]

    load: aString parent: aGtkWidget [
        <category: 'instance creation'>

        ^ self
            for: GTK.Gtk gtkFileChooserActionOpen
            title: aString
            parent: aGtkWidget
            button: GTK.Gtk gtkStockOpen
    ]

    selectFolder: aString parent: aGtkWidget [
        <category: 'instance creation'>

        ^ self
            for: GTK.Gtk gtkFileChooserActionSelectFolder
            title: aString
            parent: aGtkWidget
            button: GTK.Gtk gtkStockOpen    
    ]
]


GTK.GtkListStore extend [

    appendItem: anArray [
	<category: 'accessing'>
   
	| iter |
	iter := self append.
	self at: iter put: anArray.
	^ iter
    ]

    prependItem: anArray [
        <category: 'accessing'>

        | iter |
        iter := self prepend.
        self at: iter put: anArray.
        ^ iter
    ]

    itersDo: aBlock [
	<category: 'accessing'>

	| iter |
	((iter := self getIterFirst) isNil or: [ (self iterIsValid: iter) not ] ) ifTrue: [ ^ nil ].
	aBlock value: iter.
	[ self iterNext: iter ] whileTrue: [ aBlock value: iter ]
    ]
   
    do: aBlock [
	<category: 'accessing'>

	self itersDo: [ :iter |
	    aBlock value: (self at: iter) value: iter ]
    ]

    lastIter [
	<category: 'accessing'>

	| lastIter iter path |
	iter := lastIter := GTK.GtkTreeIter new.
	path := GTK.GtkTreePath newFirst.
	[ self getIter: iter path: path ] whileTrue: [
	    lastIter := iter.
	    iter := GTK.GtkTreeIter new.
            path next ].
	^ lastIter
    ]
]


GTK.GtkMenuItem class extend [

    menuItem: aString connectTo: anObject selector: aSymbol userData: userData [
	<category: 'instance creation'>

	^ (self newWithLabel: aString)
	    connectSignal: 'activate' to: anObject selector: aSymbol userData: userData;
	    yourself
    ]

    menuItem: aString connectTo: anObject selector: aSymbol [
        <category: 'instance creation'>

        ^ self menuItem: aString connectTo: anObject selector: aSymbol userData: nil 
    ]

    menuItem: aString accelPath: anAccelPathString [
	<category: 'instance creation'>

	^ (self newWithLabel: aString)
	    setAccelPath: anAccelPathString;
	    yourself
    ]

    menuItem: aString accelPath: anAccelPathString connectTo: anObject selector: aSymbol [
        <category: 'instance creation'>

        ^ (self menuItem: aString accelPath: anAccelPathString)
            connectSignal: 'activate' to: anObject selector: aSymbol userData: nil;
            yourself
    ]
]


GTK.GtkMenu extend [

    appendSeparator [
    <category: 'accessing'>

    self append: GTK.GtkMenuItem new
    ]

    appendMenuItems: anArray [
    <category: 'accessing'>

    anArray do: [ :each |
        self append: 
	(each isEmpty 
	    ifTrue: [ GTK.GtkMenuItem new ]
	    ifFalse: [ (GTK.GtkMenuItem newWithLabel: (each at: 1))
		connectSignal: 'activate' to: (each at: 2) selector: (each at: 3) userData: nil;
		yourself ]) ]
    ]
]


GTK.GtkScrolledWindow class extend [

    withChild: aGtkWidget [
    <category: 'instance creation'>

    ^ (GTK.GtkScrolledWindow new: nil vadjustment: nil)
        add: aGtkWidget;
        setPolicy: GTK.Gtk gtkPolicyAutomatic vscrollbarPolicy: GTK.Gtk gtkPolicyAutomatic;
        yourself
    ]
]


GTK.GtkTextBuffer extend [

    text [
    <category: 'accessing'>

    ^ self getText: self getStartIter end: self getEndIter includeHiddenChars: false
    ]

    applyTagByName: aSymbol startOffset: aStartInteger endOffset: anEndInteger [
    <category: 'accessing'>

    | end start |
    start := GTK.GtkTextIter new.
        end := GTK.GtkTextIter new.
        self getIterAtOffset: start charOffset: aStartInteger.
        self getIterAtOffset: end charOffset: anEndInteger.
        self applyTagByName: aSymbol start: start end: end
    ]

    getIterAtOffset: offset [
    <category: 'accessing'>

    | result |
    result := GTK.GtkTextIter new.
    self getIterAtOffset: result charOffset: offset.
    ^ result
    ]

    iterOfSelectedText [
        <category: 'text accessing'>

        | iter |
        self getHasSelection
                ifTrue: [ iter := self getSelectionBounds ifNil: [ ^ self ].
                        (iter at: 1) getOffset > ((iter at: 2) getOffset)
                            ifTrue: [ iter swap: 1 with: 2 ] ]
                ifFalse: [ iter := {self getStartIter. self getEndIter} ].
        ^ iter
    ]

    selectedText [
        <category: 'text accessing'>

        | iter |
        iter := self iterOfSelectedText.
        ^ self getText: (iter at: 1) end: (iter at: 2) includeHiddenChars: false
    ]
]


GTK.GtkTreeModel extend [

    at: aGtkTreeIter [
        <category: 'accessing'>

        | values |
        aGtkTreeIter ifNil: [ ^ nil ].
        values := OrderedCollection new.
        0 to: self getNColumns - 1 do: [ :column |
            values add: (self at: aGtkTreeIter column: column) ].
        ^ values
    ]

    at: aGtkTreeIter column: anInteger [
        <category: 'accessing'>

        ^ self getOop: aGtkTreeIter column: anInteger
    ]

    at: aGtkTreeIter column: anInteger put: anObject [
        <category: 'accessing'>

        self setOop: aGtkTreeIter column: anInteger value: anObject
    ]

    at: aGtkTreeIter put: anArray [
        <category: 'accessing'>

        1 to: anArray size do: [ :i |
            self at: aGtkTreeIter column: i - 1 put: (anArray at: i) ]
    ]

    at: aGtkTreeIter do: aBlock [
	<category: 'accessing'>

	(self at: aGtkTreeIter) do: aBlock
    ]

    itersDo: aBlock iter: aGtkTreeIter [
	<category: 'accessing'>

	| childIter |
	childIter := GTK.GtkTreeIter new.
	aBlock value: aGtkTreeIter.
	(self iterChildren: childIter parent: aGtkTreeIter) ifTrue: [ self itersDo: aBlock iter: childIter ].
	[ self iterNext: aGtkTreeIter ] whileTrue: [
	    aBlock value: aGtkTreeIter.
            (self iterChildren: childIter parent: aGtkTreeIter) ifTrue: [ self itersDo: aBlock iter: childIter ] ]
    ]

    itersDo: aBlock [
	<category: 'accessing'>

	| iter child |
	((iter := self getIterFirst) isNil or: [ (self iterIsValid: iter) not ] ) ifTrue: [ ^ nil ].
	self itersDo: aBlock iter: iter
    ]

    do: aBlock [
        <category: 'accessing'>

        self itersDo: [ :iter |
            aBlock value: (self at: iter) value: iter ]
    ]
]


GTK.GtkTreeStore extend [

    itersDo: aBlock iter: aGtkTreeIter [
	<category: 'accessing'>

	| childIter |
	childIter := GTK.GtkTreeIter new.
	aBlock value: aGtkTreeIter.
	(self iterChildren: childIter parent: aGtkTreeIter) ifTrue: [ self itersDo: aBlock iter: childIter ].
	[ self iterNext: aGtkTreeIter ] whileTrue: [
	    aBlock value: aGtkTreeIter.
            (self iterChildren: childIter parent: aGtkTreeIter) ifTrue: [ self itersDo: aBlock iter: childIter ] ]
    ]

    itersDo: aBlock [
	<category: 'accessing'>

	| iter child |
	((iter := self getIterFirst) isNil or: [ (self iterIsValid: iter) not ] ) ifTrue: [ ^ nil ].
	self itersDo: aBlock iter: iter
    ]

    do: aBlock [
        <category: 'accessing'>

        self itersDo: [ :iter |
            aBlock value: (self at: iter) value: iter ]
    ]

    appendItem: anArray [
	<category: 'accessing'>

	^ self append: nil item: anArray
    ]

    append: aGtkTreeIter item: anArray [
	<category: 'accessing'>

        | iter |
        iter := GTK.GtkTreeIter new.
        self 
	    append: iter parent: aGtkTreeIter;
	    at: iter put: anArray.
	^ iter
    ]
]


GTK.GtkTreeView class extend [

    newWith: aGtkModel columns: anArray [
        <category: 'user interface'>

        | view |
        view := self new.
	view setModel: aGtkModel.
	anArray keysAndValuesDo: [ :i :each || col render |
	    col := (GtkTreeViewColumn new)
		    packStart: (render := each key = 'text' ifFalse: [ GTK.GtkCellRendererPixbuf new ] ifTrue: [ GTK.GtkCellRendererText new ]) expand: true;
		    addAttribute: render attribute: each key column: i - 1;
		    yourself.
	    each value isEmpty ifFalse: [ col setTitle: each value ].
	    view insertColumn: col position: -1 ].
	^ view
    ]

    newWith: aGtkModel pack: anArray title: aString [
        <category: 'user interface'>

        | view col |
        view := self new.
	view setModel: aGtkModel.
	col := GtkTreeViewColumn new.
	anArray keysAndValuesDo: [ :i :each || render |
	    col
		packStart: (render := each = 'text' ifFalse: [ GTK.GtkCellRendererPixbuf new ] ifTrue: [ GTK.GtkCellRendererText new ]) expand: each = 'text';
		addAttribute: render attribute: each column: i - 1 ].
	col setTitle: aString.
	view insertColumn: col position: -1.
	^ view
    ]

    newWithTextColumn: aGtkModel title: aString [
        <category: 'user interface'>

        | view col render |
        view := self new
	    setModel: aGtkModel;
	    yourself.
        col := (GtkTreeViewColumn new)
	    packStart: (render := GTK.GtkCellRendererText new) expand: true;
	    addAttribute: render attribute: 'text' column: 0;
	    setTitle: aString;
	    yourself.
        view insertColumn: col position: -1.
    ^ view
    ]

    newWithSortedTextColumn: aGtkModel title: aString [
    <category: 'instance creation'>

        | view col render |
        view := self new
                    setModel: aGtkModel;
                    yourself.
        col := (GtkTreeViewColumn new)
                packStart: (render := GtkCellRendererText new) expand: true;
                addAttribute: render attribute: 'text' column: 0;
                setTitle: aString;
                setSortIndicator: true;
                setSortColumnId: 0;
                setSortOrder: Gtk gtkSortAscending;
                yourself.
        view
            insertColumn: col position: -1.
    ^ view
    ]
]

GTK.GtkTreeView extend [

    hasSelectedItem [
	<category: 'accessing'>

	^ self getSelection getSelected isNil not
    ]

    numberOfItems [
	<category: 'accessing'>

	^ self getModel iterNChildren: nil
    ]

    selectedIter [
	<category: 'accessing'>

	^ self getSelection getSelected
    ]

    selectedIndex [
	<category: 'accessing'>

	self hasSelectedItem ifFalse: [ self error: 'Nothing is selected' ].
	^ (self getModel getPath: self selectedIter) getIndices value + 1
    ]
]


GTK.GtkToolButton class extend [
    newFromStock: icon label: aString [ 
        ^(self newFromStock: icon)
	    setLabel: aString;
	    yourself
    ]
]
