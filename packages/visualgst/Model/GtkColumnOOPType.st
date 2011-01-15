GtkColumnType subclass: GtkColumnOOPType [

    GtkColumnOOPType class >> kind [
	<category: 'accessing'>

	^ GLib.GType oopType
    ]

    GtkColumnOOPType class >> kindName [
        <category: 'accessing'>

        ^ self error: 'OOP type should not be displayed'
    ]

    GtkColumnOOPType class >> cellRenderer [
        <category: 'accessing'>

        ^ self error: 'OOP type has no cell renderer'
    ]
]

