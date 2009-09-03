Smalltalk.TestLogPolicy subclass: TestBacktraceLog [
    | logStatus hadSuccesses |

    initialize: aStream [
	<category: 'Initializing'>

	super initialize: aStream.
	hadSuccesses := false
    ]

    flush [
	<category: 'logging'>

	hadSuccesses := false
    ]

    logError: anException [
	<category: 'logging'>

	logStatus := anException
    ]

    logFailure: aFailure [
	<category: 'logging'>
	
	logStatus := thisContext.
    ]

    logSucces [
	<category: 'logging'>

	hadSuccesses := true
    ]

    logStatus [
	<category: 'logging'>

	^ logStatus
    ]
]

