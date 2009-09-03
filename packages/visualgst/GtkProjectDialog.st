Object subclass: GtkProjectDialog [
    | dialog hasPressedOk nameEntry namespace selectedNamespace namespaceEntry workspace |

    GtkProjectDialog class >> open [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	hasPressedOk := false.
	dialog := GTK.GtkDialog newWithButtons: 'New Project' parent: nil flags: 0 varargs: {nil}.
	self buildCentralWidgetOn: dialog.
	dialog runBlockingAndDo: [ :dlg :res |
		res = GTK.Gtk gtkResponseNo 
		    ifTrue: [ dlg destroy ]
		    ifFalse: [ namespace hasSelectedNamespace 
				    ifTrue: [ hasPressedOk := true.
					    selectedNamespace := namespace selectedNamespace.
					    dlg destroy ] ] ]
    ]

    hasPressedOk [
	<category: 'testing'>

	^ hasPressedOk
    ]

    result [
	<category: 'accessing'>

	namespace selectedNamespace.
	^ (Project new)
	    name: nameEntry getText;
	    namespace: selectedNamespace;
	    workspace: workspace getText;
	    yourself
    ]

    buildProjectName [
        <category:'user interface'>

        | hbox |
        hbox := GTK.GtkHBox new: false spacing: 0.
        ^ hbox
            packStart: (GTK.GtkLabel new: 'Name :') expand: false fill: true padding: 0;
            packStart: (nameEntry := GTK.GtkEntry new) expand: false fill: true padding: 0;
	    showAll;
            yourself
    ]

    buildWorkspacePath [
        <category: 'user interface'>

        | hbox |
        hbox := GTK.GtkHBox new: false spacing: 0.
        ^ hbox
            packStart: (GTK.GtkLabel new: 'Workspace Path :') expand: false fill: true padding: 0;
            packStart: (workspace := GTK.GtkEntry new) expand: false fill: true padding: 0;
	    showAll;
            yourself
    ]

    buildNamespaceCreator [
	<category: 'user interface'>

	| hbox |
	hbox := GTK.GtkHBox new: false spacing: 0.
	^ hbox
            packStart: (GTK.GtkLabel new: 'Namespace :') expand: false fill: true padding: 0;
            packStart: (namespaceEntry := GTK.GtkEntry new) expand: false fill: true padding: 0;
            showAll;
            yourself
    ]

    buildNamespace [
	<category: 'user interface'>

	| vbox |
	vbox := GTK.GtkVBox new: false spacing: 0.

	namespace := (GtkNamespaceWidget new)
			initialize;
			yourself.

	^ vbox
	    packStart: self buildNamespaceCreator expand: false fill: true padding: 0;
	    packStart: namespace mainWidget expand: true fill: true padding: 0;
	    showAll;
	    yourself
    ]

    buildCentralWidgetOn: aGtkDialog [
	<category: 'user interface'>

	aGtkDialog
	    addButton: 'Yes' responseId: GTK.Gtk gtkResponseYes;
	    addButton: 'No' responseId: GTK.Gtk gtkResponseNo.

	(aGtkDialog getVBox) 
	    add: self buildProjectName;
	    add: self buildWorkspacePath;
	    add: self buildNamespace
    ]
]

