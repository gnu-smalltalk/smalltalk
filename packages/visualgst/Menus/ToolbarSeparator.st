Command subclass: ToolbarSeparator [

    buildToolItem [
        <category: 'build'>

        ^ GTK.GtkSeparatorToolItem new show;
		yourself
    ]
]

