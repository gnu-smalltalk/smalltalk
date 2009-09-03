UndoCommand subclass: DeleteClassUndoCommand [

    |  class |

    DeleteClassUndoCommand class >> delete: aClass [
	<category: 'instance creation'>

	^ (self new)
	    delete: aClass;
	    precondition;
	    yourself
    ]

    delete: aClass [
	<category: 'initialize'>

	class := aClass.
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a class'
    ]

    precondition [
	<category: 'checking'>

        class subclasses isEmpty ifFalse: [ self error: 'class has subclasses' ].
    ]

    undo [
	<category: 'events'>

	class superclass ifNotNil: [ class superclass addSubclass: class ].
	class environment insertClass: class
    ]

    redo [
	<category: 'events'>

	class superclass ifNotNil: [ class superclass removeSubclass: class ].
	class environment removeClass: class name
    ]
]

