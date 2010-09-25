AbstractFinder subclass: ClassFinder [
    | class |

    ClassFinder class >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    class: aClass;
	    yourself
    ]

    class: aClass [
	<category: 'accessing'>

	class := aClass
    ]

    displayString [
	<category: 'printing'>

	^ class displayString
    ]

    element [
	<category: 'accessing'>

	^ class
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

	aGtkClassBrowserWidget 
	    selectANamespace: class environment;
	    selectAClass: class asClass
    ]
]

