MenuBuilder subclass: ToolsMenus [

    ToolsMenus class >> menus [

	| menu |
	menu := {OpenSenderCommand.
		OpenImplementorCommand.
                OpenSUnitCommand.
		OpenPackageBuilderCommand.
		MenuSeparator.
		OpenBottomPaneCommand} asOrderedCollection.

        GtkWebView hasWebkit ifTrue: [ menu := menu, {MenuSeparator.
            OpenAssistantCommand.
            MenuSeparator.
            OpenWebBrowserCommand} ].

        ^menu
    ]
]
