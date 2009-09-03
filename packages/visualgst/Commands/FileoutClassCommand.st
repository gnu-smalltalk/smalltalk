Command subclass: FileoutClassCommand [

    execute [
	<category: 'command'>

        | class stream |
        classWidget hasSelectedClass ifFalse: [ ^ self ].
        class := classWidget selectedClass.
        stream := FileStream open: aFile mode: FileStream write.
        (ClassSource write: class on: stream)
            source
    ]
]

