Object subclass: Command [

    | target |

    Command class >> execute [
	<category: 'instance creation'>

        | cmd |
        cmd := self new.
        cmd valid ifFalse: [^cmd].
	^cmd execute; yourself
    ]

    Command class >> on: anObject [
	<category: 'instance creation'>
    
        | cmd |
        cmd := self new.
        cmd target: anObject.
        cmd valid ifFalse: [^cmd].
	^cmd execute; yourself
    ]

    target: anObject [
	<category: 'accessing'>

	target := anObject
    ]

    execute [
	<category: 'command'>

	self subclassResponisibility 
    ]

    valid [
	<category: 'command'>

	^true
    ]
]

