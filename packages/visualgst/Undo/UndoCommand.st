Object subclass: UndoCommand [
    | description |

    description [
	<category: 'accessing'>

	^ self subclassResponsibility 
    ]

    undo [
	<category: 'events'>

	self subclassResponsibility
    ]

    redo [
	<category: 'events'>

	self subclassResponsibility 
    ]
]

