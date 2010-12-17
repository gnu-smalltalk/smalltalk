ClassCommand subclass: AddCategoryCommand [

    item [

	^ 'Add a category'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Add a category' text: 'Name of the category'.
        dlg hasPressedOk: [ 
            self addCategory: dlg result onWidget: target viewedCategoryWidget ]

    ]

    addCategory: category onWidget: categoryWidget [
	<category: 'events'>

	category = '*' ifTrue: [ ^GtkLauncher displayError: 'Can''t create a * category' ].
	(categoryWidget classOrMeta methodDictionary ifNil: [ false ] ifNotNil: [ :each | each includes: category asString ] ) ifFalse: [
	    SystemChangeNotifier root categoryAdded: category asString inClass: categoryWidget classOrMeta ].
	categoryWidget selectACategory: category asString
    ]
]
