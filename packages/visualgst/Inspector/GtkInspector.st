GtkMainWindow subclass: GtkInspector [
    | object notebookWidget inspectorWidget browserWidget workspaceWidget |

    GtkInspector class >> openOn: anObject [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    object: anObject;
	    showAll;
	    yourself
    ]

    object: anObject [
	<category: 'accessor'>

	| objectClass |
	object := anObject.
	objectClass := object isClass ifTrue: [ object ] ifFalse: [ object class ].
	self title: 'Inspector on ', objectClass article, ' ', objectClass name.
	inspectorWidget object: object.
	workspaceWidget object: object.
	browserWidget
	    selectAClass: objectClass
    ]

    initialize [
	<category: 'initialization'>
	
	super initialize.
	self
	    title: 'Inspector';
	    createMenus;
	    createToolbar;
	    createStatusBar;
	    centralWidget: self buildCentralWidget
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	| trWidget wkWidget |
	notebookWidget := GTK.GtkNotebook new.
	trWidget := self buildInspectorView.
	wkWidget := self buildBrowserWidget mainWidget.
	^ notebookWidget
	    appendPage: trWidget tabLabel: (GTK.GtkLabel new: 'Basic');
	    appendPage: wkWidget tabLabel: (GTK.GtkLabel new: 'Methods');
	    showAll;
	    setCurrentPage: 0;
	    yourself
    ]

    buildInspectorView [
	<category: 'user interface'>

	^ GTK.GtkVPaned new
            pack1: self buildInspectorWidget mainWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: false shrink: true;
            yourself
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ inspectorWidget := (GtkInspectorWidget new)
				initialize;
				showAll;
				yourself
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkInspectorSourceWidget new)
				initialize;
				showAll;
				yourself
    ]

    buildBrowserWidget [
	<category: 'user interface'>

	^ browserWidget := (GtkInspectorBrowserWidget new)
	    initialize;
	    showAll;
	    yourself
    ]

    createEditMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cut' connectTo: self selector: #cut.
	    GTK.GtkMenuItem menuItem: 'Copy' connectTo: self selector: #copy.
	    GTK.GtkMenuItem menuItem: 'Paste' connectTo: self selector: #paste.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Select all' connectTo: self selector: #selectAll}
    ]

    createFileMenus [
	<category: 'user interface'>

	self accelGroup append: {{'<Control>O'. '<GtkInspector>/File/Open'}.
            {'<Control><Shift>S'. '<GtkInspector>/File/SaveAs'}.
            {'<Control>Q'. '<GtkInspector>/File/Close'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkInspector>/File/Open' connectTo: self selector: #open.
	    GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #saveImage.
	    GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkInspector>/File/SaveAs' connectTo: self selector: #saveImageAs.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
	    GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkInspector>/File/Close' connectTo: self selector: #close}
    ]

    createMenus [
	<category: 'user interface'>

	self addMenuItem: 'File' withSubmenu: self createFileMenus.
	self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Smalltalk' withSubmenu: self createToolsMenus.
    ]

    createStatusBar [
	<category: 'user interface'>

	self statusMessage: 'Gtk Inspector'
    ]

    createToolbar [
	<category: 'user interface'>

	self
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-new');
	    appendSeparator;
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-save');
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-save-as');
	    appendSeparator;
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-cut');
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-copy');
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-paste');
	    appendSeparator;
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-execute')
    ]

    createToolsMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: 
	    {GTK.GtkMenuItem menuItem: 'Browser' connectTo: self selector: #classBrowser.
	    GTK.GtkMenuItem menuItem: 'Workspace' connectTo: self selector: #workspace.
	    GTK.GtkMenuItem menuItem: 'Inspector' connectTo: self selector: #gtkInspector.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'SmallZilla' connectTo: self selector: #squeakzilla}
    ]
]

