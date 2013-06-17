"======================================================================
|
| GtkCategoryWidgetTest class definition
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

TestCase subclass: GtkCategoryWidgetTest [

    | changed |

    categoryChanged [

	changed := true
    ]

    testModelBuilding [
	<category: 'testing'>

	| category |
	category := GtkCategoryWidget new.
	category
	    mainWidget: category buildTreeView;
	    initializeCategories;
	    classOrMeta: Object
    ]

    testState [
        <category: 'testing'>

	| category |
	category := GtkCategoryWidget new.
	category
	    mainWidget: category buildTreeView;
	    initializeCategories;
	    classOrMeta: Object.
        self assert: category state namespace == Smalltalk.
        self assert: category state classOrMeta == Object.
	category selectACategory: 'built ins'.
        self assert: category state namespace == Smalltalk.
        self assert: category state classOrMeta == Object
    ]

    testSelectionEvents [

        | category |
        category := GtkCategoryWidget new.
        category
            mainWidget: category buildTreeView;
            initializeCategories;
            classOrMeta: Object.
        self assert: category hasSelectedCategory not.
        self should: [ category selectedCategory ] raise: Error.
	category selectACategory: 'built ins'.
        self assert: category hasSelectedCategory.
        self assert: category selectedCategory = 'built ins'
    ]

    testConnectionEvents [

        | category |
        category := GtkCategoryWidget new.
        category
            mainWidget: category buildTreeView;
            initializeCategories;
	    whenSelectionChangedSend: #categoryChanged to: self;
            classOrMeta: Object;
	    selectACategory: 'built ins'.
        self assert: changed
    ]
]

