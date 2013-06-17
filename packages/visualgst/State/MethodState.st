"======================================================================
|
| MethodState class definition
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

BrowserState subclass: MethodState [

    printOn: aStream [
	<category: 'printing'>

	aStream print: state
    ]

    namespace [
        <category: 'accessing'>

        ^ self classOrMeta environment
    ]

    classOrMeta [
        <category: 'accessing'>

        ^ state methodClass
    ]

    selector [
        <category: 'accessing'>

        ^ state selector
    ]

    method [
        <category: 'accessing'>

        ^ state method
    ]

    category [
        <category: 'accessing'>

        ^ state methodCategory
    ]

    selectedCategory [
        <category: 'accessing'>

        ^ self category
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ true
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

        aGtkClassBrowserWidget source: (BrowserMethodSource on: self method).
    ]
]

