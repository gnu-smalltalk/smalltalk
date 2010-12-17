GtkConcreteWidget subclass: GtkVariableTrackerWidget [
    | model object widget |

    GtkVariableTrackerWidget class >> on: anObject [
	<category: 'instance creation'>

	^ self new
		initialize;
		object: anObject;
		yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildListView
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	self refresh
    ]

    buildListView [
	<category: 'user interface'>

        widget := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Variable'}. {GtkColumnTextType title: 'Value'}}.
        widget connectToWhenPopupMenu: (WorkspaceVariableMenus on: self).
        widget treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: widget treeView getModel)
                                        contentsBlock: [ :each | {each asString. (object instVarNamed: each) displayString} ].
        ^ widget mainWidget
    ]

    refresh [
	<category: 'user interface'>

	model
	    item: object class allInstVarNames;
	    refresh
    ]

    targetObject [
        <category: 'evaluation'>

        ^ object instVarNamed: self selectedValue
    ]

    hasSelectedValue [
        <category: 'smalltalk event'>

        ^widget treeView hasSelectedValue
    ]

    selectedValue [
        <category: 'smalltalk event'>

        ^widget treeView selection
    ]

    inspectIt: anObject [
        <category: 'smalltalk event'>

        GtkInspector openOn: anObject
    ]

    deleteVariable [
	<category: 'event'>

	| ivar |
	widget treeView hasSelectedValue ifFalse: [ ^ self ].
	ivar := self selectedValue.
	model remove: ivar.
	object class removeInstVarName: ivar.
    ]
]

