GtkWorkspaceWidget subclass: GtkTranscriptWidget [

    initialize [
	<category: 'initialization'>

	Transcript message: self->#update:.
	super initialize
    ]

    update: aString [
	<category: 'updating'>

	self buffer insertAtEnd: aString
    ]
]
