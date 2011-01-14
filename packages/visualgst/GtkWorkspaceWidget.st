GtkTextWidget subclass: GtkWorkspaceWidget [

    | variableWidget variableTracker object |
    
    initialize [
	<category: 'intialization'>

	variableTracker := (WorkspaceVariableTracker new)
				initialize;
				yourself.
	object := variableTracker objectClass new.
	super initialize.
	self connectToWhenPopupMenu: (WorkspaceMenus on: self)
    ]

    postInitialize [
        <category: 'initialize'>

	variableWidget hideAll.
	super postInitialize
    ]

    buildWidget [
        <category: 'user interface'>

        ^ (GTK.GtkHPaned new)
		    add1: (variableWidget := GtkVariableTrackerWidget on: object) mainWidget;
		    add2: super buildWidget;
                    yourself
    ]

    object: anObject [
	<category: 'evaluation'>

        variableTracker := nil.
        object := anObject.
    ]

    targetObject [
	<category: 'evaluation'>

        ^ object
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>

	| text nodes |
        variableTracker isNil ifTrue: [^self].
	text := self selectedText.
	nodes := STInST.RBParser parseExpression: text onError: [ :s :p | self error: s ].
	variableTracker visitNode: nodes
    ]

    afterEvaluation [
        <category: 'smalltalk event'>

	variableWidget refresh
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    showIVar [
	<category: 'smalltalk event'>

	variableWidget mainWidget getVisible 
		ifFalse: [ variableWidget showAll ]
		ifTrue: [ variableWidget hideAll ].
    ]
]
