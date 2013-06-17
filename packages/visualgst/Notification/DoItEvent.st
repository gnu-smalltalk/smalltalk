"======================================================================
|
| DoItEvent class definition
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

AbstractEvent subclass: DoItEvent [
    | context |

    context [
	<category: 'accessing'>

	^ context
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'DoIt'
    ]

    isDoIt [
	<category: 'testing'>

	^ true
    ]

    context: aContext [
	<category: 'private-accessing'>

	context := aContext
    ]

    DoItEvent class >> changeKind [
	<category: 'accessing'>

	^ #DoIt
    ]

    DoItEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self expressionKind
    ]

    DoItEvent class >> expression: stringOrStream context: aContext [
	<category: 'instance creation'>

	| instance |
	instance := self item: stringOrStream kind: AbstractEvent expressionKind.
	instance context: aContext.
	^ instance
    ]
]

