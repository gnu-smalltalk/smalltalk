Command subclass: DeleteItemCommand [

    item [

	^ 'Delete variable'
    ]

    valid [
	<category: 'command'>

        ^ target hasSelectedItem
    ]

    execute [
	<category: 'command'>

        target deleteVariable.
    ]
]

