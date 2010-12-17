ClassHeaderSource subclass: ClassSource [
    
    sourceOf: aMethod [
	<category: 'accessing'>

        ^ (aMethod methodSourceString
                    ifNil: [ aMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
	    copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aMethod [
	<category: 'printing'>

	| lines |
	lines := (self sourceOf: aMethod) lines.
	1 to: lines size - 1 do: [ :i |
	    stream
		space: 4;
		nextPutAll: (lines at: i);
		nl ].
	stream
	    nextPutAll: lines last; 
	    nl; 
	    nl
    ]

    outputClassMethod: aMethod [
	<category: 'printing'>

        stream
            space: 4;
            nextPutAll: printClass name, ' class >> '.
	self outputMethod: aMethod
    ]

    outputMethodsFor: aClass [
	<category: 'printing'>

	aClass methodDictionary ifNotNil: [ 
	    (aClass methodDictionary asSortedCollection: [ :a :b | 
		    a methodCategory < b methodCategory ]) do: [ :each |
			each methodCategory 
			    ifNil: [ self outputMethod: each ]
			    ifNotNil: [ :aCategoryString |  aCategoryString first ~= $* ifTrue: [ self outputMethod: each ] ] ] ]
    ]

    outputMethods [
	<category: 'printing'>

	self 
	    outputMethodsFor: printClass class;
	    outputMethodsFor: printClass
    ]
]

