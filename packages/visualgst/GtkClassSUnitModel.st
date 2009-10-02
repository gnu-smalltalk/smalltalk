GtkClassModel subclass: GtkClassSUnitModel [

    addEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
	super addEvent: anEvent
    ]

    refreshModel [
        <category: 'events'>

        self gtkModel clear.
        TestCase subclassesDo: [ :each |
            self appendClass: each to: nil ]
    ]
]

