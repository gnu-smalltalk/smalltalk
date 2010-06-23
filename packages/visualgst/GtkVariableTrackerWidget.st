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

        widget := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Variable'}. {GtkColumnTextType title: 'Value'}})
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
                            yourself.
        widget getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: widget getModel)
                                        contentsBlock: [ :each | {each asString. (object instVarNamed: each) displayString} ].
        ^ GTK.GtkScrolledWindow withChild: widget
    ]

    refresh [
	<category: 'user interface'>

	model
	    item: object class allInstVarNames;
	    refresh
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Inspect a variable'. self. #inspectVariable}.
            {'Delete a variable'. self. #deleteVariable}.
            {'Set a variable to nil'. self. #nilVariable}}.
        menu attachToWidget: widget detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    targetObject [
        <category: 'evaluation'>

        ^ object instVarNamed: widget selection
    ]

    inspectIt: anObject [
        <category: 'smalltalk event'>

        GtkInspector openOn: anObject
    ]

    inspectVariable [
	<category: 'event'>

	widget hasSelectedItem ifFalse: [ ^ self ].
	InspectItCommand on: self
    ]

    deleteVariable [
	<category: 'event'>

	| ivar |
	widget hasSelectedItem ifFalse: [ ^ self ].
	ivar := widget selection.
	model remove: ivar.
	object class removeInstVarName: ivar.
    ]

    nilVariable [
	<category: 'event'>

	widget hasSelectedItem ifFalse: [ ^ self ].
	object instVarNamed: widget selection put: nil
    ]
]

