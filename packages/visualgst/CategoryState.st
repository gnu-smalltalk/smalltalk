BrowserState subclass: CategoryState [

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self classOrMeta;
	    nextPutAll: ' (';
	    display: self category;
	    nextPut: $)
    ]

    namespace [
	<category: 'accessing'>

	^ state key environment
    ]

    classOrMeta [
	<category: 'accessing'>

	^ state key
    ]

    category [
	<category: 'accessing'>

	^ state value
    ]

    selectedCategory [
	<category: 'accessing'>

	^ self category
    ]

    classOrMetaSelected [
        <category: 'accessing'>

        ^ self classOrMeta
    ]

    sourceCode [
	<category: 'accessing'>

	^ browser sourceCode
    ]

    saveSource [
	<category: 'events'>

	AddMethodCommand on: self
    ]

    displayString [
	<category: 'printing'>

	^ self classOrMeta displayString
    ]

    codeSaved [

        browser codeSaved
    ]
]

