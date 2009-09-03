GtkClassModel subclass: GtkClassSUnitModel [

    refreshModel [
        <category: 'events'>

        self model clear.
        TestCase subclassesDo: [ :each |
            self appendClass: each to: nil ]
    ]
]

