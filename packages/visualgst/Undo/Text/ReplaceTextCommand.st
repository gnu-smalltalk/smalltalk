UndoCommand subclass: ReplaceTextCommand [
    | search replace oldText buffer |

    ReplaceTextCommand class >> replace: aSearchString by: aReplaceString on: aGtkTextBuffer [
	<category: 'instance creation'>

	^ (self new)
	    replace: aSearchString by: aReplaceString on: aGtkTextBuffer;
	    yourself
    ]

    replace: aSearchString by: aReplaceString on: aGtkTextBuffer [
	<category: 'initialize'>

	search := aSearchString.
	replace := aReplaceString.
	oldText := aGtkTextBuffer text.
	buffer := aGtkTextBuffer
    ]

    isInsertCommand [
	<category: 'testing'>

	^ false
    ]

    isDeleteCommand [
	<category: 'testing'>

	^ false 
    ]

    description [
	<category: 'accessing'>

	^ 'Replace all the occurences of a string by an other'
    ]

    undo [
	<category: 'events'>

	buffer setText: oldText
    ]

    redo [
	<category: 'events'>

	buffer setText: (oldText copyReplaceAll: search with: replace)
    ]
]

