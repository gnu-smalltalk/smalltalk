"======================================================================
|
| Extensions
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

AbstractNamespace class extend [
    Icon := nil.
    Categories := nil.

    categories [
        <category: '*VisualGST'>

        ^ Categories ifNil: [ Categories := WeakKeyIdentityDictionary new ]
    ]

    icon [
        <category: '*VisualGST'>

        ^ Icon ifNil: [ Icon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/namespace.gif') file displayString error: nil ]
    ]

    icon: aGdkPixbuf [
        <category: '*VisualGST'>

        Icon := aGdkPixbuf
    ]
]

AbstractNamespace extend [

    namespace [
	<category: 'accessing'>

	^ self
    ]

    category [
	<category: 'accessing'>

	^ VisualGST.ClassCategory basicNew
    ]

    categories [
	<category: 'accessing'>

        ^ self class categories at: self
            ifAbsentPut: [ VisualGST.ClassCategory for: self ]
    ]

    icon [
        <category: '*VisualGST'>

        ^ self class icon
    ]

    isCategory [
	<category: 'testing'>

	^ false
    ]
]

