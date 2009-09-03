UndoCommand subclass: DeleteTextCommand [
    | first start end string buffer |

    DeleteTextCommand class >> from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer [
	<category: 'instance creation'>

	^ (self new)
	    from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer;
	    yourself
    ]

    from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer [
	<category: 'initialize'>

	first := true.
	start := aStartOffset.
	end := anEndOffset.
	string := aString.
	buffer := aGtkTextBuffer
    ]

    isInsertCommand [
	<category: 'testing'>

	^ false
    ]

    isDeleteCommand [
	<category: 'testing'>

	^ true
    ]

    offset [
	<category: 'accessing'>

	^ start
    ]

    string [
	<category: 'accessing'>

	^ string
    ]

    string: aString [
	<category: 'accessing'>

	string := aString
    ]

    size [
	<category: 'accessing'>

	^ string size
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a string'
    ]

    undo [
	<category: 'events'>

	buffer insert: (buffer getIterAtOffset: end - self string size) text: self string len: self string size
    ]

    redo [
	<category: 'events'>

        first ifTrue: [ first:= false.
            ^ self ].
	buffer delete: (buffer getIterAtOffset: end - self string size) end: (buffer getIterAtOffset: end)
    ]
]

