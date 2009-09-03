AbstractEvent subclass: DoItEvent [
    | context |

    context [
	<category: 'accessing'>

	^ context
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'DoIt'
    ]

    isDoIt [
	<category: 'testing'>

	^ true
    ]

    context: aContext [
	<category: 'private-accessing'>

	context := aContext
    ]

    DoItEvent class >> changeKind [
	<category: 'accessing'>

	^ #DoIt
    ]

    DoItEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self expressionKind
    ]

    DoItEvent class >> expression: stringOrStream context: aContext [
	<category: 'instance creation'>

	| instance |
	instance := self item: stringOrStream kind: AbstractEvent expressionKind.
	instance context: aContext.
	^ instance
    ]
]

