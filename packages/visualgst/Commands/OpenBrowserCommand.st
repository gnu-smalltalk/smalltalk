Command subclass: OpenBrowserCommand [

    defaultDestination [
	<category: 'parsing'>

        ^ self namespace->nil
    ]

    namespace [
        ^ target state namespace ifNil: [ Smalltalk ]
    ]

    extractNamespaceAndClassFrom: aString [
	<category: 'parsing'>

	| node token start |
	[ node := STInST.RBParser parseExpression: aString ] on: Error do: [ ^ self defaultDestination ].
	node isVariable ifFalse: [ ^ self defaultDestination ].

        start := self namespace.
        (node name subStrings: $.) do: [ :each |
            start := start at: each asSymbol ifAbsent: [ ^ self checkDestination: start ] ].
        ^ self checkDestination: start
    ]

    checkDestination: anObject [
	<category: 'parsing'>

        anObject isClass ifTrue: [ ^ anObject environment -> anObject ].
        anObject isNamespace ifTrue: [ ^ anObject -> nil ].
        ^ self defaultDestination
    ]

    extractFromSelection [
	<category: 'parsing'>

	| result |
        target hasSelection
                ifTrue: [ result := self extractNamespaceAndClassFrom: target selectedText]
                ifFalse: [ result := self defaultDestination ].
	^ result
    ]

    selection [
	<category: 'accessing'>

        target isNil ifTrue: [^ self defaultDestination].

        ((target browserHasFocus not or: [ target sourceCodeWidgetHasFocus ])
            and: [target hasSelection])
                ifTrue: [ ^ self extractNamespaceAndClassFrom: target selectedText ].

	^ target state hasSelectedClass
                ifTrue: [ target state namespace -> target state classOrMeta asClass ]
                ifFalse: [ self defaultDestination ]
    ]
]

