"======================================================================
|
| GtkMethodWidgetTest class definition
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

TestCase subclass: GtkMethodWidgetTest [

    | changed |

    methodChanged [

	changed := true
    ]

    testModelBuilding [
	<category: 'testing'>

	| method |
	method := GtkMethodWidget new.
	method mainWidget: method buildTreeView.
	method class: Object withCategory: 'built ins'.
	self assert: method selectedCategory = 'built ins'
    ]

    testState [
        <category: 'testing'>

        | method |
        method := GtkMethodWidget new.
        method mainWidget: method buildTreeView.
        method class: Object withCategory: 'built ins'.
        self assert: method state namespace isNil.
        self assert: method state classOrMeta isNil.
        self assert: method state method isNil.
	method selectAMethod: #'at:'.
        self assert: method state namespace == Smalltalk.
        self assert: method state classOrMeta == Object.
        self assert: method state method == (Object>>#'at:').
    ]

    testSelectionEvents [

        | method |
        method := GtkMethodWidget new.
        method mainWidget: method buildTreeView.
        method class: Object withCategory: 'built ins'.
        self assert: method hasSelectedMethod not.
        self should: [ method selectedMethod ] raise: Error.
        self should: [ method sourceCode ] raise: Error.
	method selectAMethod: #'at:'.
        self assert: method hasSelectedMethod.
        self assert: method selectedMethod == (Object>>#'at:').
        self assert: method sourceCode = (Object>>#'at:') methodRecompilationSourceString.
    ]

    testConnectionEvents [

        | method |
        method := GtkMethodWidget new.
        method 
	    mainWidget: method buildTreeView;
	    whenSelectionChangedSend: #methodChanged to: self;
	    class: Object withCategory: 'built ins';
	    selectAMethod: #'at:'.
        self assert: changed
    ]
]

