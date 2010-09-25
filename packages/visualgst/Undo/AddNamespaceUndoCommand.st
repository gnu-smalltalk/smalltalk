UndoCommand subclass: AddNamespaceUndoCommand [
    | parentNamespace namespaceName newNamespace |

    AddNamespaceUndoCommand class >> add: aSymbol to: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace;
	    yourself
    ]

    add: aSymbol to: aNamespace [
	<category: 'initialize'>

	parentNamespace := aNamespace.
	namespaceName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Add a namespace'
    ]

    precondition [
        <category: 'checking'>

        namespaceName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name' ].
        parentNamespace subspacesDo: [ :each |
	    each name = namespaceName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name' ] ].
	(parentNamespace includesKey: namespaceName) ifTrue: [ ^ self preconditionFailed: 'parent namespace can''t be the same has a namespace name' ].
	newNamespace := Namespace gstNew: parentNamespace name: namespaceName asSymbol.
	^ true
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

