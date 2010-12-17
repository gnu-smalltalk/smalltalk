Command subclass: OpenWebBrowserCommand [

    item [
        <category: 'menu item'>

        ^ 'Smallzilla'
    ]

    execute [
        <category: 'command'>

	GtkWebBrowser open
    ]
]

