Command subclass: FileoutCategoryCommand [

    execute [
	<category: 'command'>
    ]

    fileoutCategory: aFile [
        <category: 'class events'>

        | categoryWidget stream |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        categoryWidget := self viewedCategoryWidget.
        categoryWidget hasSelectedCategory ifFalse: [ ^ self ].
        stream := FileStream open: aFile mode: FileStream write.
        (CategorySource write: categoryWidget selectedCategory of: self classOrMetaSelected on: stream)
            source
    ]
]

