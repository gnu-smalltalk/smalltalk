Smalltalk.MethodDictionary extend [

    insertMethod: aCompiledMethod [
	<category: '*VisualGST'>

	self at: aCompiledMethod selector put: aCompiledMethod.
	VisualGST.SystemChangeNotifier root methodAdded: aCompiledMethod.
	^ aCompiledMethod
    ]

    removeMethod: aCompiledMethod [
        <category: '*VisualGST'>

        self removeKey: aCompiledMethod selector.
        VisualGST.SystemChangeNotifier root methodRemoved: aCompiledMethod.
        ^ aCompiledMethod
    ]
]

