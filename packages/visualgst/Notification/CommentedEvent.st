AbstractEvent subclass: CommentedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Commented'
    ]

    isCommented [
	<category: 'testing'>

	^ true
    ]

    CommentedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Commented
    ]

    CommentedEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self classKind
    ]
]
