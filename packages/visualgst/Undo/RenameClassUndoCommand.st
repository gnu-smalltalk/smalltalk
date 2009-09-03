UndoCommand subclass: RenameClassUndoCommand [

    | class newClassName oldClassName |

    RenameClassUndoCommand class >> rename: aClass as: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    rename: aClass as: aSymbol;
	    precondition;
	    yourself
    ]

    rename: aClass as: aSymbol [
	<category: 'initialize'>

	class := aClass.
	oldClassName := class name.
	newClassName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a class'
    ]

    precondition [
        <category: 'checking'>

        newClassName = #Smalltalk ifTrue: [ self error: 'class name can''t be the same has a namespace name'  ].
        Smalltalk subspacesDo: [ :each | each name = newClassName ifTrue: [ self error: 'class name can''t be the same has a namespace name'  ] ].
        (class environment findIndexOrNil: newClassName) ifNotNil: [ :class | self error: 'class exist in the namespace' ]
    ]

    undo [
	<category: 'events'>
	
        class environment removeClass: newClassName.
        class setName: oldClassName.
	class environment insertClass: class
    ]

    redo [
	<category: 'events'>

        class environment removeClass: oldClassName.
	class setName: newClassName.
	class environment insertClass: class
    ]
]

