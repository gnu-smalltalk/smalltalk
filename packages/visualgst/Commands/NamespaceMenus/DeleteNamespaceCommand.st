NamespaceCommand subclass: DeleteNamespaceCommand [

    item [

	^ 'Delete a namespace'
    ]

    execute [
	<category: 'command'>

	| namespace |
        namespace := target state namespace.
        namespace subspaces isEmpty ifFalse: [ self error: 'Namespace has subspaces' ].
        (DeleteNamespaceUndoCommand delete: namespace) push
    ]
]

