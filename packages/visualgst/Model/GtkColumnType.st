"======================================================================
|
| GtkColumnType class definition
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

Object subclass: GtkColumnType [
    | visible title |

    GtkColumnType class >> kind [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    GtkColumnType class >> kindName [
        <category: 'accessing'>

        ^ self subclassResponsibility
    ]

    GtkColumnType class >> cellRenderer [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    GtkColumnType class >> new [
	<category: 'instance creation'>

	^ self error: 'should not call new'
    ]

    GtkColumnType class >> hidden [
        <category: 'instance creation'>

        ^ self basicNew
            initialize;
            yourself
    ]

    GtkColumnType class >> visible [
        <category: 'instance creation'>

        ^ self basicNew
            initialize;
	    visible: true;
            yourself
    ]

    GtkColumnType class >> title: aString [
	<category: 'instance creation'>

	^ self basicNew
	    title: aString;
	    visible: true;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	visible := false
    ]

    kind [
	<category: 'accessing'>

	^ self class kind
    ]

    kindName [
        <category: 'accessing'>

        ^ self class kindName
    ]

    cellRenderer [
        <category: 'accessing'>

        ^ self class cellRenderer
    ]

    visible: aBoolean [
	<category: 'accessing'>

	visible := aBoolean
    ]

    isVisible [
	<category: 'testing'>

	^ visible
    ]

    hasTitle [
	<category: 'testing'>

	^ title isNil not
    ]

    title: aString [
	<category: 'accessing'>

	title := aString
    ]

    title [
	<category: 'accessing'>

	^ title
    ]
]
