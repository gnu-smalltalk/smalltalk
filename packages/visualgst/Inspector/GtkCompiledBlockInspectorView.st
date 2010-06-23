GtkObjectInspectorView subclass: GtkCompiledBlockInspectorView [

    GtkCompiledBlockInspectorView class [ | fields | ]

    GtkCompiledBlockInspectorView class >> fields [
	<category: 'accessing'>

	^ fields ifNil: [ fields := Dictionary from: {'clean-ness flags'->#flags. 
					    'Number Of Arguments'->#arguments.
					    'Number Of Temporaries'->#temporaries.
					    'Number Of Literals'->#numLiterals.
					    'Needed Stack Slots'->#stack.
					    'Byte Codes'->#byte.
					    'Source Code'->#source} ]
    ]

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self class fields keys do: aBlock
    ]

    selectedValue: anObject [
	<category: 'events'>

        ^ (self class fields includesKey: anObject)
	    ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ self perform: (self class fields at: anObject) ]
    ]

    flags [
	<category: 'event'>

	^ self object flags
    ]

    arguments [
	<category: 'event'>

	^ self object numArgs 
    ]

    temporaries [
	<category: 'event'>

	^ self object numTemps
    ]

    numLiterals [
	<category: 'event'>

	^ self object numLiterals
    ]

    stack [
	<category: 'event'>

	^ self object stackDepth
    ]

    literals [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	1 to: self numLiterals do: [ :i | 
		self object bytecodeIndex: i with: stream. 
		stream tab. 
		stream print: (self object literalAt: i) ].
	^ stream contents
    ]

    byte [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	self object numBytecodes > 0 ifTrue: [ self object printByteCodesOn: stream ].
	^ stream contents
    ]

    source [
	<category: 'event'>

	^ self object methodSourceString
    ]
]

