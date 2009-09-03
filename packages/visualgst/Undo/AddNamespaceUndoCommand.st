UndoCommand subclass: AddNamespaceUndoCommand [
    | parentNamespace namespaceName newNamespace |

    AddNamespaceUndoCommand class >> add: aSymbol to: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace;
	    precondition;
	    yourself
    ]

    add: aSymbol to: aNamespace [
	<category: 'initialize'>

	parentNamespace := aNamespace.
	namespaceName := aSymbol.
	newNamespace := Namespace gstNew: parentNamespace name: namespaceName asSymbol
    ]

    description [
	<category: 'accessing'>

	^ 'Add a namespace'
    ]

    precondition [
        <category: 'checking'>

        newNamespace = #Smalltalk ifTrue: [ self error: 'class name can''t be the same has a namespace name'  ].
        Smalltalk subspacesDo: [ :each | each name = newNamespace ifTrue: [ self error: 'class name can''t be the same has a namespace name'  ] ].
    ]

    undo [
	<category: 'events'>

	parentNamespace removeSubspace: newNamespace name
    ]

    redo [
	<category: 'events'>

	parentNamespace insertSubspace: newNamespace
    ]
]

