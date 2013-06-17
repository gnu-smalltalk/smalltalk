"======================================================================
|
| SysRenameClassCommand class definition
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

Command subclass: SysRenameClassCommand [

    | class newClassName oldClassName |

    SysRenameClassCommand class >> rename: aClass as: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    rename: aClass as: aSymbol;
	    "precondition;"
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

    execute [
        <category: 'checking'>

        newClassName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ].
        class environment subspacesDo: [ :each | each name = newClassName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ] ].
        (class environment findIndexOrNil: newClassName) ifNotNil: [ :class | ^ self preconditionFailed: 'class exist in the namespace' ].
	^ true
    ]


    valid [
	<category: 'events'>

	class environment removeClass: oldClassName.
	class setName: newClassName.
	class environment insertClass: class
    ]
]

