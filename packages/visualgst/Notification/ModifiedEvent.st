AbstractEvent subclass: ModifiedEvent [
    | oldItem |

    oldItem [
	<category: 'accessing'>

	^ oldItem
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Modified'
    ]

    printOn: aStream [
	<category: 'printing'>

        super printOn: aStream.
	aStream
	    nextPutAll: ' oldItem: ';
	    print: oldItem
    ]

    isModified [
	<category: 'testing'>

	^ true
    ]

    oldItem: anItem [
	<category: 'private-accessing'>

	oldItem := anItem
    ]

    ModifiedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Modified
    ]

    ModifiedEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
    ]

    ModifiedEvent class >> classDefinitionChangedFrom: oldClass to: newClass [
	<category: 'instance creation'>

	^ ModifiedClassDefinitionEvent classDefinitionChangedFrom: oldClass to: newClass
    ]

    ModifiedEvent class >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self method: newMethod selector: aSymbol class: aClass.
	instance oldItem: oldMethod.
	^ instance
    ]

    ModifiedEvent class >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor [
	<category: 'instance creation'>

        | instance |
	instance := self method: newMethod selector: aSymbol class: aClass requestor: requestor.
	instance oldItem: oldMethod.
	^ instance
    ]
]

