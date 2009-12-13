UndoCommand subclass: RenameNamespaceUndoCommand [

    | namespace oldName newName |

    RenameNamespaceUndoCommand class >> rename: aNamespace as: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    rename: aNamespace as: aSymbol;
	    "precondition;"
	    yourself
    ]

    rename: aNamespace as: aSymbol [
	<category: 'initialize'>

	namespace := aNamespace.
	oldName := namespace name.
	newName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a namespace'
    ]

    precondition [
        <category: 'checking'>

        newName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'Namespace name can''t be the same has a namespace name'  ].
        namespace subspacesDo: [ :each | each name = newName ifTrue: [ ^ self preconditionFailed: 'Namespace name can''t be the same has a namespace name'  ] ].
	^ true
    ]

    undo [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name.
	namespace name: oldName.
	namespace superspace insertSubspace: namespace
    ]

    redo [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name.
        namespace name: newName.
        namespace superspace insertSubspace: namespace
    ]
]

