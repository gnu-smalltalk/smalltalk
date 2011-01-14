BrowserState subclass: ClassState [

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self classOrMeta
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ true
    ]

    namespace [
	<category: 'accessing'>

	^ state environment
    ]

    classOrMeta [
	<category: 'accessing'>

	^ state
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

        aGtkClassBrowserWidget 
                        updateClassOfCategory: self classOrMeta asClass;
                        source: (ClassHeaderSource on: self classOrMeta asClass).
    ]
]

