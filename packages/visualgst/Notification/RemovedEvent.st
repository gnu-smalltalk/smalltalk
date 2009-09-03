AbstractEvent subclass: RemovedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Removed'
    ]

    isRemoved [
	<category: 'testing'>

	^ true
    ]

    RemovedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Removed
    ]

    supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
    ]
]

