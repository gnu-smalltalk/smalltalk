"======================================================================
|
| AddClassUndoCommand class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

UndoCommand subclass: AddClassUndoCommand [

    | first namespace newClassName parentClass newClass classCategory |

    AddClassUndoCommand class >> add: aSymbol to: aNamespace classCategory: aCategory withSuperclass: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace classCategory: aCategory withSuperclass: aClass;
	    precondition;
	    yourself
    ]

    add: aSymbol to: aNamespace classCategory: aCategory withSuperclass: aClass [
	<category: 'initialize'>

	first := true.
	newClassName := aSymbol.
	namespace := aNamespace.
	classCategory := aCategory.
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
                newClass category: classCategory fullname.
		first := false ]
	    ifFalse: [ 
		parentClass addSubclass: newClass.
		namespace insertClass: newClass ]
    ]
]

