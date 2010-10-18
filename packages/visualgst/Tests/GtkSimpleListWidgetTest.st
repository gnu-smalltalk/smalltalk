TestCase subclass: GtkSimpleListWidgetTest [

    testInstanceCreation [
	<category: 'testing'>

	| widget |
	widget := GtkSimpleListWidget named: 'foo'.
	self assert: widget treeView isNil not
    ]
]

