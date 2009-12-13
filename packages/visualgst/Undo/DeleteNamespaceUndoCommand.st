UndoCommand subclass: DeleteNamespaceUndoCommand [

    |  namespace treeStore |

    DeleteNamespaceUndoCommand class >> delete: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    delete: aNamespace;
	    yourself
    ]

    delete: aNamespace [
	<category: 'initialize'>

	namespace := aNamespace
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a namespace'
    ]

    undo [
	<category: 'events'>

	namespace superspace insertSubspace: namespace
    ]

    redo [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name
    ]
]

