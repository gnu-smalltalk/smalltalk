BrowserState subclass: NamespaceState [

    | classCategory |

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self namespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    classCategory: aCategory [
	<category: 'accessing'>

	classCategory := aCategory
    ]

    classCategory [
	<category: 'accessing'>

	^ classCategory
    ]

    namespace [
	<category: 'accessing'>

	^ state
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>
   
	aGtkClassBrowserWidget 
			updateNamespaceOfClass: self namespace classCategory: self classCategory;
			source: (NamespaceHeaderSource on: self namespace).
    ]
]

