"======================================================================
|
| GtkTreeModel class definition
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

Object subclass: GtkTreeModel [

    GtkTreeModel class >> on: aGtkTreeStore [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    gtkModel: aGtkTreeStore;
	    yourself
    ]

    | childrenBlock contentsBlock item model |

    initialize [
	<category: 'initialization'>

    ]

    gtkModel: aGtkTreeStore [
	<category: 'accessing'>

	model := aGtkTreeStore
    ]

    connectSignal: aString to: anObject selector: aSymbol [
	<category: 'events'>

	^ model connectSignal: aString to: anObject selector: aSymbol
    ]

    item: anObject [
	<category: 'accessing'>

	item := anObject
    ]

    item [
	<category: 'accessing'>

	^ item
    ]

    childrenBlock: aBlock [
	<category: 'accessing'>

	childrenBlock := aBlock
    ]

    childrenBlock [
	<category: 'accessing'>

	^ childrenBlock
    ]

    contentsBlock: aBlock [
	<category: 'accessing'>

	contentsBlock := aBlock
    ]

    contentsBlock [
	<category: 'accessing'>

	^ contentsBlock
    ]

    append: anObject [
        <category:' model'>

        self append: anObject with: nil
    ]

    append: anObject parent: aParentObject [
	<category:' model'>

	self append: anObject with: (self findIter: aParentObject)
    ]

    append: anItem with: aParentIter [
        <category:' model'>

        | iter |
        iter := model append: aParentIter item: ((self contentsBlock value: anItem) copyWith: anItem).
        (self childrenBlock value: anItem) do: [ :each | self append: each with: iter ]
    ]

    remove: anObject ifAbsent: aBlock [
	<category: 'model'>

        | iter |
        iter := self findIter: anObject ifAbsent: [ ^ aBlock value ].
        model remove: iter
    ]

    remove: anObject [
	<category: 'model'>

	self remove: anObject ifAbsent: [ self error: 'item not found' ]
    ]

    clear [
	<category: 'model'>

	model clear
    ]

    refresh [
	<category: 'model'>

	self clear.
	self item ifNil: [ ^ self ].
	(self childrenBlock value: self item) do: [ :each | self append: each with: nil ]
    ]

    hasItem: anObject [
        <category: 'item selection'>

        self findIter: anObject ifAbsent: [ ^ false ].
        ^ true
    ]

    findIter: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	model do: [ :elem :iter |
	    elem last = anObject ifTrue: [ ^ iter ] ].
	aBlock value
    ]

    findIter: anObject [
	<category: 'item selection'>

	^ self findIter: anObject ifAbsent: [ self error: 'Item not found' ]
    ]

    includes: anObject [
	self findIter: anObject ifAbsent: [ ^ false ].
	^ true
    ]
]

