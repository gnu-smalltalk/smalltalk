"======================================================================
|
| PragmasTest class definition
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

TestCase subclass: PragmasTest [

    testNamespaceExtend [
	<category: 'testing'>
   
	self assert: Smalltalk namespaceExtends isEmpty.
	self assert: Kernel namespaceExtends isEmpty.
	self assert: Kernel namespaceExtends ~~ Smalltalk namespaceExtends
    ]

    testPragma [
	<category: 'testing'>

	| behavior |
	behavior := Behavior new.
	Smalltalk addSubspace: #Foo.
	behavior superclass: Object.
	behavior compile: 'test [ <namespace: Foo classCategory: ''foo-bar'' category: ''xork''> ]'.
	self assert: (behavior>>#test) methodCategory = 'xork'.
	self assert: (((Smalltalk at: #Foo) namespaceExtends at: 'foo-bar') includes: (behavior>>#test)).
	behavior compile: 'test [ <namespace: Foo category: ''bar''> ]'.
	self assert: (behavior>>#test) methodCategory = 'bar'.
	self assert: (((Smalltalk at: #Foo) namespaceExtends at: '') includes: (behavior>>#test)).
	Smalltalk removeSubspace: #Foo
    ]
]

