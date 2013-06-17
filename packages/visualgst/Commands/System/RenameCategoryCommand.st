"======================================================================
|
| SysRenameCategorycommand class definition
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

Command subclass: SysRenameCategoryCommand [

    | category class newCategory treeStore |

    SysRenameCategoryCommand class >> rename: aString in: aClass as: aNewName onModel: aGtkTreeStore [
	<category: 'instance creation'>

	^ (self new)
	    rename: aString in: aClass as: aNewName onModel: aGtkTreeStore;
	    "precondition;"
	    yourself
    ]

    rename: aString in: aClass as: aNewName onModel: aGtkTreeStore [
	<category: 'initialize'>

	category := aString.
	class := aClass.
	newCategory := aNewName.
	treeStore := aGtkTreeStore
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a category'
    ]

    valid [
        <category: 'checking'>

	newCategory = '*' ifTrue: [ ^ self preconditionFailed: 'Can''t create a * category' ].
        (treeStore hasCategory: newCategory asString) ifTrue: [ ^ self preconditionFailed: 'Category is present' ].
	^ true
    ]

    execute [
	<category: 'events'>

	class methodDictionary do: [ :each |
            each methodCategory = category
                ifTrue: [ each methodCategory: newCategory ] ].
	treeStore
	    removeCategory: category;
	    appendCategory: newCategory
    ]
]

