"======================================================================
|
| HighScores class definition
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

Object subclass: HighScores [

    | highScores maxScores |

    HighScores class >> newSized: anInteger [
	<category: 'instance creation'>

	^ self new
	    maxScores: anInteger;
	    yourself
    ]

    highScores [
	<category: 'accessing'>

	^ highScores ifNil: [ highScores := OrderedCollection new ]
    ]

    maxScores: anInteger [
	<category: 'accessing'>

	maxScores := anInteger
    ]

    addScore: aScore [
	<category: 'updating'>

	| pos |
	pos := 0.
	self highScores doWithIndex: [ :each :index |
	    each < index ifTrue: [ pos := index ] ].
	pos = 0 ifTrue: [ ^ self ].
	self highScores add: aScore after: pos.
	self highScores size > self maxScores ifTrue: [ self highScores removeLast ]
    ]
]

