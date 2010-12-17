Object subclass: SourceFormatter [
    | stream |

    SourceFormatter class >> for: aStream [
	<category: 'instance creation'>

	^ self new stream: aStream; yourself
    ]

    SourceFormatter class >> on: anObject [
	<category: 'instance creation'>

	^ self write: anObject on: (WriteStream on: String new)
    ]

    SourceFormatter class >> write: anObject on: aStream [
	<category: 'instance creation'>

	self subclassResponsibility
    ]

    stream [
	<category: 'accessing'>

	^ stream
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

	self subclassResponsibility
    ]

    parser [
	self subclassResponsibility
    ]

    source [
	^ stream contents
    ]
    
    close [
	self stream close
    ]
]
