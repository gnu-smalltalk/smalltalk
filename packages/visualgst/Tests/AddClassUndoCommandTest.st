TestCase subclass: AddClassUndoCommandTest [

    testAddClass [
	<category: 'testing'>

	| cmd |
	cmd := AddClassUndoCommand 
		    add: #Object to: Smalltalk classCategory: 'bar' withSuperclass: Object.
	self assert: cmd precondition not.
	cmd := AddClassUndoCommand 
		    add: #Foo to: Smalltalk classCategory: Object classCategory withSuperclass: Object.
	self assert: cmd precondition.
	cmd redo.
	self assert: (Smalltalk includesKey: #Foo).
	self assert: (Smalltalk at: #Foo) superclass == Object.
	self assert: (Smalltalk at: #Foo) classCategory == Object classCategory.

	cmd undo.
	self assert: (Smalltalk includesKey: #Foo) not.

	cmd redo.
	self assert: (Smalltalk includesKey: #Foo).
	self assert: (Smalltalk at: #Foo) superclass == Object.
	self assert: (Smalltalk at: #Foo) classCategory == Object classCategory.

	cmd undo
    ]
]

