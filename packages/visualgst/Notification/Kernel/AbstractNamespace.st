Smalltalk.AbstractNamespace class extend [

    primNew: parent name: spaceName [
	"Private - Create a new namespace with the given name and parent, and
	add to the parent a key that references it."

	<category: 'instance creation'>
	| namespace |
	(parent at: spaceName ifAbsent: [ nil ]) isNamespace 
	    ifTrue: [ ^ parent at: spaceName asGlobalKey ].
	namespace := parent 
			at: spaceName asGlobalKey
			put: ((super new: 24)
				    setSuperspace: parent;
				    name: spaceName asSymbol;
				    yourself).
	VisualGST.SystemChangeNotifier root namespaceAdded: namespace.
	^ namespace
    ]

    gstNew: parent name: spaceName [
	<category: '*VisualGST'>

	^ (super new: 24)
		    setSuperspace: parent;
		    name: spaceName asSymbol;
		    yourself
    ]
]

Smalltalk.AbstractNamespace extend [

    removeSubspace: aSymbol [
	"Remove my subspace named aSymbol from the hierarchy."

	<category: 'namespace hierarchy'>
	| namespace spaceName |
	spaceName := aSymbol asGlobalKey.	"as with primNew:name:"
	namespace := self hereAt: spaceName.
	self subspaces remove: namespace
	    ifAbsent: 
	    [SystemExceptions.InvalidValue signalOn: aSymbol
		reason: 'aSymbol must name a subspace'].
	VisualGST.SystemChangeNotifier root namespaceRemoved: namespace.
	^ self removeKey: spaceName
    ]

    removeClass: aSymbol [

	<category: '*VisualGST'>
	| class className |
	className := aSymbol asGlobalKey.
	class := self hereAt: className.
	VisualGST.SystemChangeNotifier root classRemoved: class.
	^ self removeKey: className
    ]

    insertClass: aClass [

        <category: '*VisualGST'>
	self at: aClass name put: aClass.
        VisualGST.SystemChangeNotifier root classAdded: aClass.
    ]

    insertSubspace: aNamespace [
	"Insert an existing namespace"

	<category: '*VisualGST'>

        self
            at: aNamespace name asGlobalKey
            put: aNamespace.

	subspaces add: aNamespace.

	VisualGST.SystemChangeNotifier root namespaceAdded: aNamespace.
	^ aNamespace
    ]
]

