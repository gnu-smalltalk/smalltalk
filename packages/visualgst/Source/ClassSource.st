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
	1 to: lines size do: [ :i |
	    stream
		space: 4;
		nextPutAll: (lines at: i);
		nl ].
	stream nl
    ]

    outputMethodWithoutFirstTab: aMethod [
        <category: 'printing'>

        | lines |
        lines := (self sourceOf: aMethod) lines.
        stream 
	    nextPutAll: (lines at: 1);
	    nl.
        2 to: lines size do: [ :i |
            stream
                space: 4;
                nextPutAll: (lines at: i);
                nl ].
        stream nl
    ]

    outputClassMethod: aMethod [
	<category: 'printing'>

        stream
            space: 4;
            nextPutAll: printClass name, ' class >> '.
	self outputMethodWithoutFirstTab: aMethod
    ]

    outputMethodsWith: aOneArgBlock in: aClass [

        aClass methodDictionary ifNotNil: [
            (aClass methodDictionary asSortedCollection: [ :a :b |
                    a methodCategory < b methodCategory ]) do: [ :each |
                        each methodCategory
                            ifNil: [ aOneArgBlock value: each ]
                            ifNotNil: [ :aCategoryString |  aCategoryString first ~= $* ifTrue: [ aOneArgBlock value: each ] ] ] ]
    ]

    outputMethodsFor: aClass [
	<category: 'printing'>

	self outputMethodsWith: [ :each | each printNl. self outputMethod: each ] in: aClass
    ]

    outputClassMethodsFor: aClass [
        <category: 'printing'>

	self outputMethodsWith: [ :each | self outputClassMethod: each ] in: aClass
    ]

    outputMethods [
	<category: 'printing'>

	self 
	    outputClassMethodsFor: printClass class;
	    outputMethodsFor: printClass
    ]
]

