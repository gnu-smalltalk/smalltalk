AbstractEvent subclass: ReorganizedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Reorganized'
    ]

    isReorganized [
	<category: 'testing'>

	^ true
    ]

    ReorganizedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Reorganized
    ]

    supportedKinds [
	<category: 'accessing'>

	^ Array with: self classKind
    ]
]

