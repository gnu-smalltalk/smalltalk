"======================================================================
|
| FinderTest class definition
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

TestCase subclass: FinderTest [

    | namespace class imethod cmethod |

    selectANamespace: anObject [

	namespace := anObject
    ]

    selectAClass: anObject [

        class := anObject
    ]

    selectAnInstanceMethod: anObject [

	imethod := anObject
    ]

    selectAClassMethod: anObject [

	cmethod := anObject
    ]

    testAbstractFinder [
	<category: 'testing'>

	| finder |
	finder := AbstractFinder new.
	self should: [ finder updateBrowser: nil ] raise: Error.
	self should: [ finder element ] raise: Error
    ]

    testNamespaceFinder [
	<category: 'testing'>

        | finder |
        finder := NamespaceFinder on: Smalltalk.
	self assert: finder displayString = 'Smalltalk'.
        finder updateBrowser: self.
	self assert: namespace == Smalltalk.
	self assert: finder element == Smalltalk.
	finder namespace: Kernel.
	self assert: finder element == Kernel
    ]

    testClassFinder [
        <category: 'testing'>
    
        | finder |
        finder := ClassFinder on: Object.
        self assert: finder displayString = 'Object'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == Object.
        self assert: finder element == Object.
        finder class: String class.
        self assert: finder element == String class
    ]

    testMethodFinder [
        <category: 'testing'>

        | finder |
        finder := MethodFinder on: Object with: #at:.
        self assert: finder displayString = 'Object >> #at:'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == Object.
        self assert: imethod == #at:.
        self assert: finder element == #at:.

        finder := MethodFinder on: String class with: #new:.
        self assert: finder displayString = 'String class >> #new:'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == String.
        self assert: cmethod == #new:.
        self assert: finder element == #new:
    ]
]

