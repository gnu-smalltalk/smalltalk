Object subclass: GtkContextModel [

    GtkContextModel class >> on: aContext [
	<category: 'instance creation'>

        ^ (self new)
	    context: aContext;
	    yourself
    ]

    | model context |

    context [
	<category: 'accessing'>

	^ context
    ]

    context: aContext [
	<category: 'accessing'>

	context := aContext.
	self refreshModel
    ]

    model [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    emptyModel [
	<category: 'accessing'>

	^ GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString}
    ]

    refreshModel [
	<category: 'events'>
    
	| ctxt stream |
	self context ifNil: [ ^ model := self emptyModel ].

	self model clear.
    
	ctxt := self context.
	[ ctxt isNil ] whileFalse: [
	    self append: ctxt printString.
	    ctxt := ctxt parentContext ].
    ]

    selectLastContext [
	<category: 'item selection'>

	^ self model lastIter
    ]

    selectFirstContext [
        <category: 'item selection'>

        ^ self model firstIter
    ]

    append: aString [
	<category: 'model builder'>
    
	self model appendItem: {aString}
    ]
]

