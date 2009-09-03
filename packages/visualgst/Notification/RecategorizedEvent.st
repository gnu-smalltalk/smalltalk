AbstractEvent subclass: RecategorizedEvent [
    | oldCategory |

    oldCategory [
	<category: 'accessing'>

	^ oldCategory
    ]

    oldCategory: aCategoryName [
	<category: 'accessing'>

	oldCategory := aCategoryName
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Recategorized'
    ]

    isRecategorized [
	<category: 'testing'>

	^ true
    ]

    RecategorizedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Recategorized
    ]

    RecategorizedEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self classKind with: self methodKind
    ]

    RecategorizedEvent class >> class: aClass category: cat oldCategory: oldName [
	<category: 'instance creation'>

	^ (self class: aClass category: cat) oldCategory: oldName
    ]

    RecategorizedEvent class>> method: aMethod protocol: prot class: aClass oldProtocol: oldName [
	<category: 'instance creation'>

	^ (self method: aMethod protocol: prot class: aClass) oldCategory: oldName
    ]
]
