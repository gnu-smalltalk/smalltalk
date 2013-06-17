"======================================================================
|
| GtkReplaceWidget class definition
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

GtkFindWidget subclass: GtkReplaceWidget [
    | replaceWidget replaceButton replaceAllButton |

    replaceEntry [
	<category: 'user interface'>

	^ replaceWidget := GTK.GtkEntry new
			    connectSignal: 'activate' to: self selector: #replacePressed;
			    yourself
    ]

    replaceButton [
        <category: 'user interface'>

	^ replaceButton := (GTK.GtkButton newWithLabel: 'Replace')
			    connectSignal: 'clicked' to: self selector: #replacePressed;
			    yourself
    ]

    replaceAllButton [
        <category: 'user interface'>

	^ replaceAllButton := (GTK.GtkButton newWithLabel: 'Replace All')
			    connectSignal: 'clicked' to: self selector: #replaceAllPressed;
			    yourself
    ]

    replaceBox [
        <category: 'user interface'>

	| hBox |
	^ (GTK.GtkHBox new: false spacing: 3)
            packStart: (GTK.GtkLabel new: 'Replace with:') expand: false fill: false padding: 2;
            packStart: self replaceEntry expand: false fill: false padding: 15;
	    packStart: self replaceButton expand: false fill: false padding: 15;
            packStart: self replaceAllButton expand: false fill: false padding: 15;
	    yourself
    ]

    buildWidget [
	<category: 'user interface'>

	^ super buildWidget
	    packStart: self replaceBox expand: false fill: false padding: 0;
	    yourself

    ]

    replacePressed [
	<category: 'replace events'>

	| i iter |
	self keyPressed.
	textWidget hasSelection ifFalse: [ ^ self ].
	i := textWidget iterOfSelectedText first getOffset.
	textWidget cut.
	iter := textWidget buffer getIterAtOffset: i.
	textWidget buffer insertInteractive: iter text: replaceWidget getText len: replaceWidget getText size defaultEditable: true
    ]

    replaceAllPressed [
        <category: 'replace events'>

	"matching doesn't work now"
	textWidget replace: entry getText by: replaceWidget getText
    ]
]

