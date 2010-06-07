GtkBrowserWrapper subclass: GtkImplementor [

    windowTitle [
        ^ 'Implementors'
    ]

    aboutTitle [
        ^ 'About Implementors'
    ]

    resultSelected [
	<category: 'events'>

	| selectedIter selectedString |
	(selectedIter := resultTree selectedIter) ifNil: [ ^ self ].
	selectedString := (self resultModel getOop: selectedIter column: 0).

	(resultArray at: selectedString) updateBrowser: classBrowserWidget.
    ]
]

