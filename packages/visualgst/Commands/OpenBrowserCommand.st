"======================================================================
|
| OpenBrowserCommand class definition
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

Command subclass: OpenBrowserCommand [

    defaultDestination [
	<category: 'parsing'>

        ^ self namespace->nil
    ]

    namespace [
        ^ target state namespace ifNil: [ Smalltalk ]
    ]

    extractNamespaceAndClassFrom: aString [
	<category: 'parsing'>

	| node token start |
	[ node := STInST.RBParser parseExpression: aString ] on: Error do: [ ^ self defaultDestination ].
	node isVariable ifFalse: [ ^ self defaultDestination ].

        start := self namespace.
        (node name subStrings: $.) do: [ :each |
            start := start at: each asSymbol ifAbsent: [ ^ self checkDestination: start ] ].
        ^ self checkDestination: start
    ]

    checkDestination: anObject [
	<category: 'parsing'>

        anObject isClass ifTrue: [ ^ anObject environment -> anObject ].
        anObject isNamespace ifTrue: [ ^ anObject -> nil ].
        ^ self defaultDestination
    ]

    extractFromSelection [
	<category: 'parsing'>

	| result |
        target hasSelection
                ifTrue: [ result := self extractNamespaceAndClassFrom: target selectedText]
                ifFalse: [ result := self defaultDestination ].
	^ result
    ]

    selection [
	<category: 'accessing'>

        target isNil ifTrue: [^ self defaultDestination].

        ((target browserHasFocus not or: [ target sourceCodeWidgetHasFocus ])
            and: [target hasSelection])
                ifTrue: [ ^ self extractNamespaceAndClassFrom: target selectedText ].

	^ target state hasSelectedClass
                ifTrue: [ target state namespace -> target state classOrMeta asClass ]
                ifFalse: [ self defaultDestination ]
    ]
]

