"======================================================================
|
| BrowserState class definition
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

Object subclass: BrowserState [
    | state |

    BrowserState class >> on: aBrowser with: aState [
	<category: 'instance creation'>

	^ self new
	    state: aState
    ]

    BrowserState class >> with: aState [
	<category: 'instance creation'>

	^ self new
	    state: aState
    ]

    state: aState [
	<category: 'initialize-release'>

	state := aState
    ]

    displayString [
        <category: 'printing'>

        ^ state displayString
    ]

    hasSelection [
	<category: 'testing'>

	^ ((self hasSelectedNamespace bitOr: self hasSelectedClass) bitOr: self hasSelectedCategory) bitOr: self hasSelectedMethod
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ false
    ]

    category [
        <category: 'accessing'>

        ^ nil
    ]

    method [
        <category: 'accessing'>

        ^ nil
    ]

    namespace [
        <category: 'accessing'>

        ^ nil
    ]

    classOrMeta [
        <category: 'accessing'>

        ^ nil
    ]

    classCategory [
        <category: 'accessing'>

        ^ ClassCategory extractClassCategory: self classOrMeta
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

    ]
]

