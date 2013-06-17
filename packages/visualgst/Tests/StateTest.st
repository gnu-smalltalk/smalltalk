"======================================================================
|
| StateTest class definition
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

TestCase subclass: StateTest [

    testNamespaceState [
	<category: 'testing'>

	| st |
	st := NamespaceState on: self with: Kernel.
	self assert: st hasSelectedNamespace.
	self assert: st hasSelectedClass not.
	self assert: st hasSelectedCategory not.
	self assert: st hasSelectedMethod not.
	self assert: st namespace == Kernel.
	self assert: st classOrMeta isNil.
	self assert: st category isNil.
	self assert: st method isNil
    ]

    testClassState [
        <category: 'testing'>

        | st |
        st := ClassState on: self with: Object.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory not.
        self assert: st hasSelectedMethod not.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category isNil.
        self assert: st method isNil
    ]

    testCategoryState [
        <category: 'testing'>

        | st |
        st := CategoryState on: self with: Object->'foo'.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory.
        self assert: st hasSelectedMethod not.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category = 'foo'.
        self assert: st method isNil
    ]

    testMethodState [
        <category: 'testing'>

        | st |
        st := MethodState on: self with: Object>>#at:.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory.
        self assert: st hasSelectedMethod.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category = 'built ins'.
        self assert: st method == (Object>>#at:)
    ]

    testBrowserState [
	<category: 'testing'>

	| st |
	st := BrowserState on: self with: 123.
        self assert: st hasSelectedNamespace not.
        self assert: st hasSelectedClass not.
        self assert: st hasSelectedCategory not.
        self assert: st hasSelectedMethod not.
        self assert: st namespace isNil.
        self assert: st classOrMeta isNil.
        self assert: st category isNil.
        self assert: st method isNil
    ]
]

