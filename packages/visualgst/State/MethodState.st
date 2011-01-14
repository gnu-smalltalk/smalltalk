BrowserState subclass: MethodState [

    printOn: aStream [
	<category: 'printing'>

	aStream print: state
    ]

    namespace [
        <category: 'accessing'>

        ^ self classOrMeta environment
    ]

    classOrMeta [
        <category: 'accessing'>

        ^ state methodClass
    ]

    selector [
        <category: 'accessing'>

        ^ state selector
    ]

    method [
        <category: 'accessing'>

        ^ state method
    ]

    category [
        <category: 'accessing'>

        ^ state methodCategory
    ]

    selectedCategory [
        <category: 'accessing'>

        ^ self category
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ true
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

        aGtkClassBrowserWidget source: (BrowserMethodSource on: self method).
    ]
]

