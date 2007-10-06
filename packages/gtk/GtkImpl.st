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

    new [
	<category: 'instance creation'>
	^(self type new)
	    addToBeFinalized;
	    yourself
    ]

]



GtkTextIter class extend [

    new [
	<category: 'instance creation'>
	^(self type new)
	    addToBeFinalized;
	    yourself
    ]

]



GtkTreeModel extend [

    getIter: path [
	<category: 'accessing'>
	| iter |
	iter := GTK.GtkTreeIter new.
	self getIter: iter path: path.
	^iter
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

    main [
	"Main loop implementation.  Same as gtk_main, but it lets Smalltalk
	 processes run.  Like gtk_main, it is ended with Gtk>>#mainQuit."

	<category: 'event loop'>
	| sem |
	sem := Semaphore new.
	"This call is asynchronous, so it leaves us waiting on the #wait call just
	 below.  Our loop starts as soon as the next bytecode is executed,
	 because sem is asynchronously signalled by my_gtk_main."
	GTK.Gtk main: sem.
	sem wait.
	
	[GTK.Gtk mainIterationDo: false.
	GTK.Gtk shouldQuit] 
		whileFalse: [Processor yield]
    ]

]



"Finish initialization.  This will be done upon #returnFromSnapshot on
 subsequent image loads."



Eval [
    GLib registerAllTypes
]

