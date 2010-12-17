Command subclass: OpenSenderCommand [

    item [
        <category: 'menu item'>

        ^ 'Senders'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>N'
    ]

    selection [
        <category: 'focus checking'>

        target isNil ifTrue: [^nil].

        ((target browserHasFocus not and: [target hasSelection])
            or: [ target sourceCodeWidgetHasFocus ])
                ifTrue: [^target selectedMethodSymbol].

        ^target state hasSelectedMethod
                ifTrue: [ target state selector ]
                ifFalse: [ nil ]
    ]

    valid [
        <category: 'checking'>

        ^ target launcher notNil or: [ self selection notNil ]
    ]

    execute [
        <category: 'command'>

        | selection |
        selection := self selection.
        selection isNil ifTrue: [ ^ target launcher showHideSender ].
	target launcher showSenderOn: selection
    ]
]

