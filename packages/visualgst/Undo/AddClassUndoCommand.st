UndoCommand subclass: AddClassUndoCommand [

    | first namespace newClassName parentClass newClass |

    AddClassUndoCommand class >> add: aSymbol to: aNamespace withSuperclass: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace withSuperclass: aClass;
	    precondition;
	    yourself
    ]

    add: aSymbol to: aNamespace withSuperclass: aClass [
	<category: 'initialize'>

	first := true.
	newClassName := aSymbol.
	namespace := aNamespace.
	parentClass := aClass
    ]

    description [
	<category: 'accessing'>

	^ 'Add a class'
    ]

    precondition [
	<category: 'checking'>

	newClassName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ].
	Smalltalk subspacesDo: [ :each | each name = newClassName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ] ].
	(namespace findIndexOrNil: newClassName) ifNotNil: [ ^ self preconditionFailed: 'class exist in the namespace' ].
	^ true
    ]

    undo [
	<category: 'events'>

	parentClass removeSubclass: newClass.
	namespace removeClass: newClass name
    ]

    redo [
	<category: 'events'>

	first 
	    ifTrue: [
		newClass := parentClass subclass: newClassName environment: namespace.
		namespace at: newClass name put: newClass.
		first := false ]
	    ifFalse: [ namespace insertClass: newClass ]
    ]
]

