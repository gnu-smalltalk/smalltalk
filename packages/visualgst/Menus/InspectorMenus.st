MenuBuilder subclass: InspectorMenus [

    InspectorMenus class >> menus [

	^ {InspectItemCommand.
        MenuSeparator.
        InspectorDiveCommand.
        InspectorBackCommand}
    ]
]
