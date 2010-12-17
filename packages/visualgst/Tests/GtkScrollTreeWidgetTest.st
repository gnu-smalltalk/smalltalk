TestCase subclass: GtkScrollTreeWidgetTest [

    testAccessing [
	<category: 'testing'>

	| widget |
	widget := GtkScrollTreeWidget basicNew.
	widget treeView: 123.
	self assert: widget treeView = 123
    ]

    testPopupConnection [
	<category: 'testing'>

        | widget |
        widget := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'aString'}}.
    ]
]

