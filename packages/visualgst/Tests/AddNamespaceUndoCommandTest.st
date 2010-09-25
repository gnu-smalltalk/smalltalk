TestCase subclass: AddNamespaceUndoCommandTest [

    testAddNamespace [
        <category: 'testing'>

        | cmd |
        cmd := AddNamespaceUndoCommand
                    add: #Kernel to: Smalltalk.
        self assert: cmd precondition not.

        cmd := AddNamespaceUndoCommand
                    add: #Object to: Smalltalk.
        self assert: cmd precondition not.

        cmd := AddNamespaceUndoCommand
                    add: #Foo to: Smalltalk.
        self assert: cmd precondition.

        cmd redo.
        self assert: (Smalltalk includesKey: #Foo).
        self assert: (Smalltalk at: #Foo) isNamespace.

        cmd undo.
        self assert: (Smalltalk includesKey: #Foo) not.

        cmd redo.
        self assert: (Smalltalk includesKey: #Foo).
        self assert: (Smalltalk at: #Foo) isNamespace.

        cmd undo
    ]
]

