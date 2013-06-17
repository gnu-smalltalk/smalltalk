"======================================================================
|
| MethodSource class definition
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

SourceFormatter subclass: MethodSource [
    | printMethod |

    MethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    printMethod: {aCompiledMethod};
	    output;
            yourself
    ]

    MethodSource class >> writeMethods: aCollection on: aStream [
        <category: 'instance creation'>

	(self for: aStream)
            printMethod: aCollection;
	    output;
            yourself
    ]

    printMethod: aCollection [
	<category: 'accessing'>

	printMethod := aCollection
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    header [
        <category: 'accessing'>

	^ printMethod methodSourceString 
    ]

    methodSourceFor: aCompiledMethod [
        <category: 'accessing'>

        ^ (aCompiledMethod methodSourceString
                    ifNil: [ printMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
            copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aString [
        <category: 'printing'>

        | lines |
        lines := aString lines.
        1 to: lines size - 1 do: [ :i |
            stream
                space: 4;
                nextPutAll: (lines at: i);
                nl ].
        stream 
            nextPutAll: lines last;
            nl  
    ]

    output [
	<category: 'accessing'>

        stream
            nextPutAll: printMethod first methodClass displayString;
            nextPutAll: ' extend [';
            nl.

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

	stream
            nextPutAll: ']';
            nl.
    ]

    outputWithoutClassHeader [
        <category: 'accessing'>

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

        stream nl. 
    ]

    parser [
        ^ STInST.RBBracketedMethodParser
    ]
]

