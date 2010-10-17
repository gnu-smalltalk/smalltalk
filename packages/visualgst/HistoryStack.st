Object subclass: HistoryStack [

    | previousStack nextStack browser |

    initialize: aGtkClassBrowserWidget [
	<category: 'initialization'>

	previousStack := OrderedCollection new.
	nextStack := OrderedCollection new.
	browser := aGtkClassBrowserWidget.
    ]

    clear [
	<category: 'stack'>

        previousStack empty.
        nextStack empty.
    ]

    current [
	<category: 'stack'>
        ^previousStack isEmpty ifTrue: [ nil ] ifFalse: [ previousStack first ]
    ]

    push: aClass [
	<category: 'stack'>

	(aClass isNil or: [self current == aClass]) ifTrue: [ ^ self ].
	nextStack empty.
	previousStack addFirst: aClass
    ]

    size [
        <category: 'iteration'>

        ^nextStack size + previousStack size
    ]

    do: aBlock [
        <category: 'iteration'>

        nextStack reverseDo: aBlock.
        previousStack do: aBlock.
    ]

    selectedIndex [
	<category: 'undo-redo'>

        ^nextStack size + 1
    ]

    selectItem: anInteger [
	<category: 'undo-redo'>

        | n |
        (anInteger between: 1 and: self size)
            ifFalse: [self error: 'index out of range'].

        [ self selectedIndex < anInteger ] whileTrue: [
            nextStack addFirst: previousStack removeFirst ].
        [ self selectedIndex > anInteger ] whileTrue: [
            previousStack addFirst: nextStack removeFirst ].

        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]

    previous [
	<category: 'undo-redo'>

	previousStack size <= 1 ifTrue: [ ^ self ].

	nextStack addFirst: previousStack removeFirst.
        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]

    next [
        <category: 'undo-redo'>

	nextStack isEmpty ifTrue: [ ^ self ].

	previousStack addFirst: nextStack removeFirst.
        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]
]

