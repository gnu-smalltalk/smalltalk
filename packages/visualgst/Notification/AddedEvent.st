AbstractEvent subclass: AddedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Added'
    ]

    isAdded [
	<category: 'testing'>

	^ true
    ]

    AddedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Added
    ]

    AddedEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
    ]
]

