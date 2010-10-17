Command subclass: OpenImplementorCommand [

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

    precondition [
        <category: 'temporary'>
        "HACK!"

        ^target launcher notNil
    ]

    execute [
        <category: 'command'>

        | selection |
        selection := self selection.
        selection isNil ifTrue: [ ^ target launcher showHideImplementor ].
	target launcher showImplementorOn: selection
    ]
]
