AbstractFinder subclass: MethodFinder [
    | class selector |

    MethodFinder class >> on: aClass with: aSelector [
	<category: 'instance creation'>

	^ (self new)
	    on: aClass with: aSelector;
	    yourself
    ]

    on: aClass with: aSelector [
	<category: 'accessing'>

	class := aClass.
	selector := aSelector
    ]

    displayString [
	<category: 'printing'>

	^ class displayString, ' >> ', selector displayString
    ]

    element [
        <category: 'accessing'>

        ^ selector 
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

	aGtkClassBrowserWidget
	    selectANamespace: class environment;
	    selectAClass: class asClass.
	class isClass 
	    ifTrue: [ aGtkClassBrowserWidget selectAnInstanceMethod: selector ]
	    ifFalse: [ aGtkClassBrowserWidget selectAClassMethod: selector  ]
    ]
]

