BrowserState subclass: MethodState [

    printOn: aStream [
	<category: 'printing'>

	aStream print: state value
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

        ^ state value methodCategory
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

	AddMethodCommand on: self.
    ]

    codeSaved [

	browser codeSaved
    ]
]

