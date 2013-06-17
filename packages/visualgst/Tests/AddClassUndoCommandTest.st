"======================================================================
|
| AddClassUndoCommandTest class definition
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

TestCase subclass: AddClassUndoCommandTest [

    testAddClass [
	<category: 'testing'>

	| cmd |
	cmd := AddClassUndoCommand 
		    add: #Object to: Smalltalk classCategory: 'bar' withSuperclass: Object.
	self assert: cmd precondition not.
	cmd := AddClassUndoCommand 
		    add: #Foo to: Smalltalk classCategory: Object classCategory withSuperclass: Object.
	self assert: cmd precondition.
	cmd redo.
	self assert: (Smalltalk includesKey: #Foo).
	self assert: (Smalltalk at: #Foo) superclass == Object.
	self assert: (Smalltalk at: #Foo) classCategory == Object classCategory.

	cmd undo.
	self assert: (Smalltalk includesKey: #Foo) not.

	cmd redo.
	self assert: (Smalltalk includesKey: #Foo).
	self assert: (Smalltalk at: #Foo) superclass == Object.
	self assert: (Smalltalk at: #Foo) classCategory == Object classCategory.

	cmd undo
    ]
]

