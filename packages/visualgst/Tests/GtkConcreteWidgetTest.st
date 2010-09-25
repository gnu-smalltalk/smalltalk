TestCase subclass: GtkConcreteWidgetTest [

    | show |

    showAll [

	show := true
    ]

    hideAll [

	show := false
    ]

    getVisible [
	
	^ false
    ]

    testAbstractWidget [
	<category: 'testing'>

	self should: [ GtkAbstractConcreteWidget new hideAll. true ]
    ]

    testConcreteWidget [
	<category: 'testing'>

	| widget |
	widget := GtkConcreteWidget parentWindow: #foo.
	self assert: widget parentWindow = #foo.
	widget mainWidget: self.
	self assert: widget mainWidget = self.
	widget showAll.
	self assert: show.
	widget hideAll.
	self assert: show not.
	self assert: widget isVisible not.
	self should: [ widget grabFocus. true ].
	self should: [ widget close. true].
    ]
]

