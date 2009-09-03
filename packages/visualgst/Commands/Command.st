Object subclass: Command [

    | target |

    Command class >> on: anObject [
	<category: 'instance creation'>
    
	^ (self new)
	    target: anObject;
	    execute;
	    yourself
    ]

    target: anObject [
	<category: 'accessing'>

	target := anObject
    ]

    execute [
	<category: 'command'>

	self subclassResponisibility 
    ]
]

