GtkClassModel subclass: GtkClassSUnitModel [

    GtkClassSUnitModel class >> addEvent: anEvent [
        <category: 'model event'>

        | parentIter parent |
        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        parentIter := self findIterInAClass: anEvent item superclass ifAbsent: [ nil ].
        self append: parentIter column: 0 value: anEvent item name
    ]

    refreshModel [
        <category: 'events'>

        self gtkModel clear.
        TestCase subclassesDo: [ :each |
            self appendClass: each to: nil ]
    ]
]

