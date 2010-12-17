ModifiedEvent subclass: ModifiedClassDefinitionEvent [

    anyChanges [
	<category: 'testing'>

	^ self isSuperclassModified or: [ self areInstVarsModified or: [ self areClassVarsModified or: [ self areSharedPoolsModified ] ] ]
    ]

    printOn: aStream [
	<category: 'printing'>

        super printOn: aStream.
        aStream
	   nextPutAll: ' Super: ';
	    print: self isSuperclassModified;
	    nextPutAll: ' InstVars: ';
	    print: self areInstVarsModified;
	    nextPutAll: ' ClassVars: ';
	    print: self areClassVarsModified;
	    nextPutAll: ' SharedPools: ';
	    print: self areSharedPoolsModified
    ]

    classVarNames [
	<category: 'accessing'>

	^ item classVarNames asSet
    ]

    instVarNames [
	<category: 'accessing'>

	^ item instVarNames asSet
    ]

    oldClassVarNames [
	<category: 'accessing'>

	^ oldItem classVarNames asSet
    ]

    oldInstVarNames [
	<category: 'accessing'>

	^ oldItem instVarNames asSet
    ]

    oldSharedPools [
	<category: 'accessing'>

	^ oldItem sharedPools
    ]

    oldSuperclass [
	<category: 'accessing'>

	^ oldItem superclass
    ]

    sharedPools [
	<category: 'accessing'>

	^ item sharedPools
    ]

    superclass [
	<category: 'accessing'>

	^ item superclass
    ]

    areClassVarsModified [
	<category: 'testing'>
    
	^ self classVarNames ~= self oldClassVarNames
    ]

    areInstVarsModified [
	<category: 'testing'>

	^ self instVarNames ~= self oldInstVarNames
    ]

    areSharedPoolsModified [
	<category: 'testing'>

	^ self sharedPools ~= self oldSharedPools
    ]

    isSuperclassModified [
	<category: 'testing'>

	^ item superclass ~~ oldItem superclass
    ]

    ModifiedClassDefinitionEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind
    ]

    ModifiedClassDefinitionEvent class >> classDefinitionChangedFrom: oldClass to: newClass [
	<category: 'instance creation'>

	| instance |
	instance := self item: newClass kind: self classKind.
	instance oldItem: oldClass.
	^ instance
    ]
]

