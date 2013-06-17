"======================================================================
|
| ClassSource class definition
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

ClassHeaderSource subclass: ClassSource [
    
    sourceOf: aMethod [
	<category: 'accessing'>

        ^ (aMethod methodSourceString
                    ifNil: [ aMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
	    copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aMethod [
	<category: 'printing'>

	| lines |
	lines := (self sourceOf: aMethod) lines.
	1 to: lines size do: [ :i |
	    stream
		space: 4;
		nextPutAll: (lines at: i);
		nl ].
	stream nl
    ]

    outputMethodWithoutFirstTab: aMethod [
        <category: 'printing'>

        | lines |
        lines := (self sourceOf: aMethod) lines.
        stream 
	    nextPutAll: (lines at: 1);
	    nl.
        2 to: lines size do: [ :i |
            stream
                space: 4;
                nextPutAll: (lines at: i);
                nl ].
        stream nl
    ]

    outputClassMethod: aMethod [
	<category: 'printing'>

        stream
            space: 4;
            nextPutAll: printClass name, ' class >> '.
	self outputMethodWithoutFirstTab: aMethod
    ]

    outputMethodsWith: aOneArgBlock in: aClass [

        aClass methodDictionary ifNotNil: [
            (aClass methodDictionary asSortedCollection: [ :a :b |
                    a methodCategory < b methodCategory ]) do: [ :each |
                        each methodCategory
                            ifNil: [ aOneArgBlock value: each ]
                            ifNotNil: [ :aCategoryString |  aCategoryString first ~= $* ifTrue: [ aOneArgBlock value: each ] ] ] ]
    ]

    outputMethodsFor: aClass [
	<category: 'printing'>

	self outputMethodsWith: [ :each | each printNl. self outputMethod: each ] in: aClass
    ]

    outputClassMethodsFor: aClass [
        <category: 'printing'>

	self outputMethodsWith: [ :each | self outputClassMethod: each ] in: aClass
    ]

    outputMethods [
	<category: 'printing'>

	self 
	    outputClassMethodsFor: printClass class;
	    outputMethodsFor: printClass
    ]
]

