"======================================================================
|
| GtkEntryDialog class definition
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

Object subclass: GtkEntryDialog [
    | dialog labelWidget entryWidget hasPressedOk buttons defaultButton |

    GtkEntryDialog class >> title: aTitle text: aDescription [
	<category: 'instance creation'>

	^ (self new)
	    title: aTitle text: aDescription;
	    yourself
    ]

    beOkCancel [
        buttons := #( ('Ok' #gtkResponseOk) ('Cancel' #gtkResponseCancel))
    ]

    beYesNo [
        buttons := #( ('Yes' #gtkResponseYes) ('No' #gtkResponseNo))
    ]

    title: aTitle text: aDescription [
	<category: 'initialization'>

	hasPressedOk := false.
	dialog := GTK.GtkDialog newWithButtons: aTitle parent: nil flags: 0 varargs: {nil}.
	self buildCentralWidget: aDescription on: dialog.
	"dialog showModalOnAnswer: [ :dlg :res |
		res = GTK.Gtk gtkResponseYes ifTrue: [ hasPressedOk := true ].
		dlg destroy ]"
    ]

    hasPressedOk: aBlock [
	<category: 'testing'>

        dialog showModalOnAnswer: [ :dlg :res |
                res = defaultButton ifTrue: [ aBlock value ].
                dlg destroy ]
    ]

    result [
	<category: 'accessing'>

	^ entryWidget getText
    ]

    buildCentralWidget: aString on: aGtkDialog [
	<category: 'user interface'>

	| hbox |
        buttons isNil ifTrue: [ self beOkCancel ].
        buttons do: [ :each |
	    aGtkDialog addButton: each first responseId: (GTK.Gtk perform: each second) ].

        defaultButton := GTK.Gtk perform: buttons first second.
        aGtkDialog setDefaultResponse: defaultButton.
	hbox := GTK.GtkHBox new: true spacing: 0.
	labelWidget := GTK.GtkLabel new: aString.
	entryWidget := GTK.GtkEntry new.
        entryWidget setActivatesDefault: true.
	hbox
	    add: labelWidget;
	    add: entryWidget;
	    showAll.
	aGtkDialog getVBox add: hbox
    ]
]

