Object subclass: Command [

    | target |

    Command class >> execute [
	<category: 'instance creation'>

	^ self new
	    validAndExecute
    ]

    Command class >> target: anObject [
        <category: 'instance creation'>

	^ self new
	    target: anObject;
	    yourself
    ]

    Command class >> on: anObject [
	<category: 'instance creation'>
    
	^ (self target: anObject)
		    validAndExecute
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

	^ true
    ]

    validAndExecute [
	<category: 'command'>

        self valid ifFalse: [ ^ self ].
        ^ self
            execute;
            yourself
    ]
]

