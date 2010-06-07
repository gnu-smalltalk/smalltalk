GtkColumnType subclass: GtkColumnTextType [

    GtkColumnTextType class >> kind [
	<category: 'accessing'>

	^ GTK.GValue gTypeString
    ]

    GtkColumnTextType class >> kindName [
        <category: 'accessing'>

        ^ 'text'
    ]

    GtkColumnTextType class >> cellRenderer [
        <category: 'accessing'>

        ^ GTK.GtkCellRendererText
    ]
]

