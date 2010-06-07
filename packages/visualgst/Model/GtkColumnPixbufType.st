GtkColumnType subclass: GtkColumnPixbufType [

    GtkColumnPixbufType class >> kind [
	<category: 'accessing'>

	^ GTK.GdkPixbuf getType
    ]

    GtkColumnPixbufType class >> kindName [
        <category: 'accessing'>

        ^ 'pixbuf'
    ]

    GtkColumnPixbufType class >> cellRenderer [
        <category: 'accessing'>

        ^ GTK.GtkCellRendererPixbuf
    ]
]

