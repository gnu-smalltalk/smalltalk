SimpleWorkspaceMenus subclass: WorkspaceMenus [

    WorkspaceMenus class >> menus [

	^ super menus, {MenuSeparator.
			WorkspaceVariableCommand}
    ]
]
