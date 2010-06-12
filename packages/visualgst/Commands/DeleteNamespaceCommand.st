NamespaceCommand subclass: DeleteNamespaceCommand [

    execute [
	<category: 'command'>

	| namespace |
        namespace := target selectedNamespace.
        namespace subspaces isEmpty ifFalse: [ self error: 'Namespace has subspaces' ].
        (DeleteNamespaceUndoCommand delete: namespace) push
    ]
]

