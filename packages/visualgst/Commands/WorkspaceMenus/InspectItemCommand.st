InspectItCommand subclass: InspectItemCommand [

    item [

	^ 'Inspect variable'
    ]

    valid [
	<category: 'command'>

        ^ target hasSelectedValue
    ]
]

