"======================================================================
|
| DeleteTextCommand class definition
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

UndoCommand subclass: DeleteTextCommand [
    | first start end string buffer |

    DeleteTextCommand class >> from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer [
	<category: 'instance creation'>

	^ (self new)
	    from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer;
	    yourself
    ]

    from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer [
	<category: 'initialize'>

	first := true.
	start := aStartOffset.
	end := anEndOffset.
	string := aString.
	buffer := aGtkTextBuffer
    ]

    isInsertCommand [
	<category: 'testing'>

	^ false
    ]

    isDeleteCommand [
	<category: 'testing'>

	^ true
    ]

    offset [
	<category: 'accessing'>

	^ start
    ]

    string [
	<category: 'accessing'>

	^ string
    ]

    string: aString [
	<category: 'accessing'>

	string := aString
    ]

    size [
	<category: 'accessing'>

	^ string size
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a string'
    ]

    undo [
	<category: 'events'>

	buffer insert: (buffer getIterAtOffset: end - self string size) text: self string len: self string size
    ]

    redo [
	<category: 'events'>

        first ifTrue: [ first:= false.
            ^ self ].
	buffer delete: (buffer getIterAtOffset: end - self string size) end: (buffer getIterAtOffset: end)
    ]
]

