"======================================================================
|
| SysAddNamespace class definition
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

Command subclass: SysAddNamespaceCommand [
    | parentNamespace namespaceName newNamespace |

    SysAddNamespaceCommand class >> add: aSymbol to: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace;
	    yourself
    ]

    add: aSymbol to: aNamespace [
	<category: 'initialize'>

	parentNamespace := aNamespace.
	namespaceName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Add a namespace'
    ]

    valid [
        <category: 'checking'>

        namespaceName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name' ].
        parentNamespace subspacesDo: [ :each |
	    each name = namespaceName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name' ] ].
	(parentNamespace includesKey: namespaceName) ifTrue: [ ^ self preconditionFailed: 'parent namespace can''t be the same has a namespace name' ].
	newNamespace := Namespace gstNew: parentNamespace name: namespaceName asSymbol.
	^ true
    ]

    execute [
	<category: 'events'>

	parentNamespace insertSubspace: newNamespace
    ]
]

