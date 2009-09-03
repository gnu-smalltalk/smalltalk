BrowserState subclass: MethodState [

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
]

