GtkTextPluginWidget subclass: GtkFindWidget [
    | entry matchCase next previous lastPosition |

    buildEntry [
	<category: 'user interface'>

	^ entry := GTK.GtkEntry new
			connectSignal: 'activate' to: self selector: #keyPressed;
			yourself
    ]

    buildPreviousButton [
	<category: 'user interface'>

        ^ previous := GTK.GtkButton previousButton
			connectSignal: 'clicked' to: self selector: #previousPressed;
			yourself
    ]

    buildNextButton [
        <category: 'user interface'>

        ^ next := GTK.GtkButton nextButton
			connectSignal: 'clicked' to: self selector: #keyPressed;
			yourself
    ]

    buildMatchCaseButton [
        <category: 'user interface'>

	^ matchCase := GTK.GtkCheckButton newWithLabel: 'match case'
    ]

    hBox [
	<category: 'user interface'>

	^ super hBox
	    packStart: (GTK.GtkLabel new: 'Find:') expand: false fill: false padding: 2;
	    packStart: self buildEntry expand: false fill: false padding: 15;
	    packStart: self buildPreviousButton expand: false fill: false padding: 0; 
	    packStart: self buildNextButton expand: false fill: false padding: 0;
	    packStart: self buildMatchCaseButton expand: false fill: false padding: 0;
	    yourself
    ]

    grabFocus [
	<category: 'focus'>

	entry grabFocus
    ]

    searchFrom: anInteger [
	<category: 'text searching'>

	^ textWidget text indexOf: entry getText matchCase: matchCase getActive startingAt: anInteger
    ]

    searchBackFrom: anInteger [
	<category: 'text searching'>

	^ textWidget text deindexOf: entry getText matchCase: matchCase getActive startingAt: anInteger
    ]

    keyPressed [
	<category: 'entry events'>

	| int |
	lastPosition := textWidget hasSelection 
					ifTrue: [ textWidget cursorPosition + 2 ]
					ifFalse: [ textWidget cursorPosition + 1 ].
	lastPosition > textWidget text size ifTrue: [ lastPosition := 1 ].
	int := self searchFrom: lastPosition.
	int ifNil: [ (int := self searchFrom: 1) ifNil: [ int := textWidget cursorPosition + 1 to: textWidget cursorPosition ] ].
	textWidget selectRange: int first - 1 bound: int last.
    ]

    previousPressed [
	<category: 'previous events'>

	| int |
	lastPosition := textWidget hasSelection 
					ifTrue: [ textWidget cursorPosition ]
					ifFalse: [ textWidget cursorPosition + 1 ].
	lastPosition = 0 ifTrue: [ lastPosition := textWidget text size ].
	int := self searchBackFrom: lastPosition.
	int ifNil: [ (int := self searchBackFrom: textWidget text size) ifNil: [ int := textWidget cursorPosition + 1 to: textWidget cursorPosition ] ].
	textWidget selectRange: int first - 1 bound: int last.
    ]
]

