"======================================================================
|
| SysRenameNamespaceCommand class definition
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

Command subclass: SysRenameNamespaceCommand [

    | namespace oldName newName |

    SysRenameNamespaceCommand class >> rename: aNamespace as: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    rename: aNamespace as: aSymbol;
	    "precondition;"
	    yourself
    ]

    rename: aNamespace as: aSymbol [
	<category: 'initialize'>

	namespace := aNamespace.
	oldName := namespace name.
	newName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a namespace'
    ]

    execute [
        <category: 'checking'>

        newName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'Namespace name can''t be the same has a namespace name'  ].
        namespace subspacesDo: [ :each | each name = newName ifTrue: [ ^ self preconditionFailed: 'Namespace name can''t be the same has a namespace name'  ] ].
	^ true
    ]

    valid [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name.
        namespace name: newName.
        namespace superspace insertSubspace: namespace
    ]
]

