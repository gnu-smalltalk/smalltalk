Object subclass: BrowserState [
    | browser state |

    BrowserState class >> on: aGtkClassBrowserWidget with: aState [
	<category: 'instance creation'>

	^ self new
	    on: aGtkClassBrowserWidget with: aState
    ]

    on: aGtkClassBrowserWidget with: aState [
	<category: 'initialize-release'>

	browser := aGtkClassBrowserWidget.
	state := aState
    ]

    saveSource [
	<category: 'events'>

	self subclassResponsibility
    ]

    displayString [
        <category: 'printing'>

        ^ state displayString
    ]
]

