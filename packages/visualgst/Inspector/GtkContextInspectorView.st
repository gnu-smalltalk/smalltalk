"======================================================================
|
| GtkContextInspectorView class definition
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

GtkObjectInspectorView subclass: GtkContextInspectorView [

    | args temps |

    do: aBlock [
        <category: 'iterating'>

        args := IdentitySet new.
        temps := IdentitySet new.
        super do: aBlock.
        self object method arguments do: [ :each | aBlock value: (args add: each asString) ].
        self object method temporaries do: [ :each | aBlock value: (temps add: each asString) ].
    ]

    selectedValue: aString [
        <category: 'events'>

        ((args includes: aString) not and: [ (temps includes: aString) not ]) ifTrue: [ ^ super selectedValue: aString ].
        (args includes: aString) ifTrue: [ ^ self object at: (self object method arguments indexOf: aString asSymbol) ].
        ^ self object at: self object numArgs + (self object method temporaries indexOf: aString asSymbol).
    ]
]

