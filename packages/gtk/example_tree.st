"======================================================================
|
|   Smalltalk Gtk+ bindings examples
|
 ======================================================================"


PackageLoader fileInPackage: 'GTK'.


Namespace current: GTK [

Object subclass: TreeExample [
    | window treeView treeModel button tree entries selection |
    
    <category: nil>
    <comment: nil>

    closeClicked: aSender [
	<category: 'event handling'>
	window destroy
    ]

    destroy: aSender [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    selectionChangedCallback: aSender [
	<category: 'event handling'>
	| it i |
	treeView getSelection getMode = Gtk gtkSelectionSingle ifFalse: [^self].
	it := GtkTreeIter type new.
	selection := (treeView getSelection getSelected: nil iter: it) 
		    ifTrue: [entries at: (tree getOop: it column: 0)]
		    ifFalse: [nil].
	('Selection: ' , selection printString) printNl
    ]

    rowActivatedCallback: aSender [
	<category: 'event handling'>
	'Row activated!' printNl
    ]

    defaultExpand [
	<category: 'window layout'>
	"Expand all root nodes"

	| it |
	it := GtkTreeIter type new.
	tree iterChildren: it parent: nil.
	it isNil ifTrue: [^self].
	
	[treeView expandToPath: (tree getPath: it).
	tree iterNext: it] whileTrue
    ]

    open [
	<category: 'window layout'>
	"Visual components"

	| vbox frame scroll col rend typs |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window setTitle: 'Tree Example'.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:
	    userData: nil.
	window setBorderWidth: 10.
	vbox := GtkVBox new: false spacing: 9.
	vbox setBorderWidth: 2.
	window add: vbox.
	frame := GtkFrame new: nil.
	vbox 
	    packStart: frame
	    expand: true
	    fill: true
	    padding: 0.
	scroll := GtkScrolledWindow new: nil vadjustment: nil.
	frame add: scroll.
	scroll setPolicy: Gtk gtkPolicyAutomatic
	    vscrollbarPolicy: Gtk gtkPolicyAutomatic.
	treeView := GtkTreeView new.
	scroll add: treeView.
	treeView getSelection 
	    connectSignal: 'changed'
	    to: self
	    selector: #selectionChangedCallback:
	    userData: nil.
	treeView 
	    connectSignal: 'row-activated'
	    to: self
	    selector: #rowActivatedCallback:
	    userData: nil.
	button := GtkButton newWithLabel: 'Close'.
	button 
	    connectSignal: 'clicked'
	    to: self
	    selector: #closeClicked:
	    userData: nil.
	vbox 
	    packStart: button
	    expand: false
	    fill: false
	    padding: 0.

	"typs := (CArrayCType elementType: CIntType numberOfElements: 3) new.
	 typs
	 at: 0 put: (GValue typeFromName: 'gint');
	 at: 1 put: (GValue typeFromName: 'gchararray');
	 at: 2 put: (GValue typeFromName: 'gchararray').
	 
	 tree := GtkTreeStore newv: 3 types: typs."
	tree := GtkTreeStore new: 3
		    varargs: 
			{GValue gTypeInt.
			GValue gTypeString.
			GValue gTypeString}.

	"TreeStore"
	col := GtkTreeViewColumn new.
	treeView insertColumn: col position: -1.	"-1 => append"
	col setTitle: 'Class'.
	col packStart: (rend := GtkCellRendererText new) expand: true.
	col 
	    addAttribute: rend
	    attribute: 'text'
	    column: 1.
	col 
	    addAttribute: rend
	    attribute: 'foreground'
	    column: 2.
	treeView setModel: tree.

	"Display"
	window setDefaultSize: 300 height: 500.
	window showAll
    ]

    topLevelNodes [
	<category: 'window layout'>
	| cls |
	cls := Array 
		    streamContents: [:stream | Smalltalk allClassesDo: [:each | stream nextPut: each]].
	^cls 
	    select: [:each | each superclass isNil or: [each superclass environment ~= Smalltalk]]
    ]

    getChildNodesFor: aNode [
	<category: 'window layout'>
	aNode isNil ifTrue: [^self topLevelNodes].
	aNode isClass 
	    ifTrue: [^aNode subclasses select: [:each | each environment = Smalltalk]].
	^nil
    ]

    getColumnValuesFor: aNode [
	<category: 'window layout'>
	^aNode isClass 
	    ifTrue: 
		[
		{aNode name ifNil: ['<unnamed>'].
		aNode subclasses size > 1 ifTrue: ['blue'] ifFalse: ['black']}]
	    ifFalse: 
		[
		{aNode printString.
		'gray'}]
    ]

    buildNode: aNode atIter: aIter [
	<category: 'window layout'>
	| nds cols lbl it n |
	nds := self getChildNodesFor: aNode.
	nds isNil ifTrue: [^self].
	cols := OrderedCollection new: nds size.
	nds do: [:nd | cols add: nd -> (self getColumnValuesFor: nd)].

	"Sort by first column"
	cols := cols 
		    asSortedCollection: [:a :b | (a value at: 1) <= (b value at: 1)].
	cols do: 
		[:each | 
		n := entries size + 1.
		it := GtkTreeIter type new.
		tree append: it parent: aIter.
		tree 
		    setOop: it
		    column: 0
		    value: n.
		each value doWithIndex: 
			[:col :i | 
			tree 
			    setOop: it
			    column: i
			    value: col].
		entries at: n put: each key.
		self buildNode: each key atIter: it]
    ]

    buildTree [
	<category: 'window layout'>
	entries := Dictionary new.	"entries is the reverse lookup"
	self buildNode: nil atIter: nil
    ]
]

]



Namespace current: GTK [
    TreeExample new open buildTree defaultExpand.
    Gtk main
]

