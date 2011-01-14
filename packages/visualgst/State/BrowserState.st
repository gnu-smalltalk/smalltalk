Object subclass: BrowserState [
    | state |

    BrowserState class >> on: aBrowser with: aState [
	<category: 'instance creation'>

	^ self new
	    state: aState
    ]

    BrowserState class >> with: aState [
	<category: 'instance creation'>

	^ self new
	    state: aState
    ]

    state: aState [
	<category: 'initialize-release'>

	state := aState
    ]

    displayString [
        <category: 'printing'>

        ^ state displayString
    ]

    hasSelection [
	<category: 'testing'>

	^ ((self hasSelectedNamespace bitOr: self hasSelectedClass) bitOr: self hasSelectedCategory) bitOr: self hasSelectedMethod
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ false
    ]

    category [
        <category: 'accessing'>

        ^ nil
    ]

    method [
        <category: 'accessing'>

        ^ nil
    ]

    namespace [
        <category: 'accessing'>

        ^ nil
    ]

    classOrMeta [
        <category: 'accessing'>

        ^ nil
    ]

    classCategory [
        <category: 'accessing'>

        ^ ClassCategory extractClassCategory: self classOrMeta
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

    ]
]

