AbstractEvent subclass: RenamedEvent [
    | newName oldName |

    newName [
	<category: 'accessing'>

	^ newName
    ]

    newName: aName [
	<category: 'accessing'>

	newName := aName
    ]

    oldName [
	<category: 'accessing'>

	^ oldName
    ]

    oldName: aName [
	<category: 'accessing'>

	oldName := aName
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Renamed'
    ]

    isRenamed [
	<category: 'testing'>

	^true
    ]

    RenamedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Renamed
    ]

    RenamedEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self categoryKind with: self protocolKind
    ]

    RenamedEvent class >> classCategoryRenamedFrom: anOldClassCategoryName to: aNewClassCategoryName [
	<category: 'instance creation'>

	^ (self classCategory: anOldClassCategoryName) oldName: anOldClassCategoryName; newName: aNewClassCategoryName
    ]

    RenamedEvent class >> class: aClass category: cat oldName: oldName newName: newName [
	<category: 'instance creation'>

	^ (self class: aClass category: cat) oldName: oldName; newName: newName
    ]
]

