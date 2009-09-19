GtkClassModel subclass: GtkClassSUnitModel [

    GtkClassSUnitModel class >> addEvent: anEvent [
        <category: 'model event'>

        | model parentIter parent |
        model := self current at: anEvent item environment ifAbsent: [ ^ self ].
        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        parentIter := model findIterInAClass: anEvent item superclass ifAbsent: [ nil ].
        model append: parentIter column: 0 value: anEvent item name
    ]

    refreshModel [
        <category: 'events'>

        self model clear.
        TestCase subclassesDo: [ :each |
            self appendClass: each to: nil ]
    ]
]

