Object subclass: Command [

    Command class >> execute [
	<category: 'instance creation'>

	^ self new
	    executeIfValid
    ]

    Command class >> target: anObject [
        <category: 'instance creation'>

	^ self new
	    target: anObject;
	    yourself
    ]

    Command class >> executeOn: anObject [
	<category: 'instance creation'>
    
	^ (self on: anObject)
		    executeIfValid
    ]

    Command class >> on: aGtkBrowser [
        <category: 'instance creation'>

        ^ self new
	    target: aGtkBrowser;
            yourself
    ]

    | target |
    
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

    executeIfValid [
	<category: 'command'>

        self valid ifFalse: [ ^ self ].
        ^ self
            execute;
            yourself
    ]

    item [
        <category: 'accessing'>

	self subclassResponisibility 
    ]

    accel [
        <category: 'accessing'>

	^ nil
    ]

    buildMenuItem [
        <category: 'build'>

        ^ (GTK.GtkMenuItem newWithLabel: self item)
                show;
                connectSignal: 'activate' to: self selector: #executeIfValid;
                yourself
    ]

    setState: aGtkMenuItem [
        <category: 'build'>

	aGtkMenuItem setSensitive: self valid
    ]
]

