Object subclass: HistoryStack [

    | previousStack nextStack browser |

    initialize: aGtkClassBrowserWidget [
	<category: 'initialization'>

	previousStack := OrderedCollection new.
	nextStack := OrderedCollection new.
	browser := aGtkClassBrowserWidget
    ]

    clear [
	<category: 'stack'>

	previousStack empty.
	nextStack empty
    ]

    push: aClass [
	<category: 'stack'>

	nextStack empty.
	(previousStack isEmpty not and: [ previousStack first == aClass ]) ifTrue: [ ^ self ].
	previousStack addFirst: aClass
    ]

    previous [
	<category: 'undo-redo'>

	previousStack size <= 1 ifTrue: [ ^ self ].

	nextStack addFirst: previousStack removeFirst.
	browser selectANamespace: previousStack first environment.
	browser updateClass: previousStack first.
    ]

    next [
        <category: 'undo-redo'>

	nextStack isEmpty ifTrue: [ ^ self ].

	browser selectANamespace: nextStack first environment.
        browser updateClass: nextStack first.
        previousStack addFirst: nextStack removeFirst.
    ]
]

