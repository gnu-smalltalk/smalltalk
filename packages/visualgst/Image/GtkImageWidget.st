"======================================================================
|
| GtkImageWidget class definition
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

GtkConcreteWidget subclass: GtkImageWidget [

    | imageTree image model searchEntry |


    initialize [
	<category: 'initialization'>

	self mainWidget: self buildMainWidget
    ]

    buildMainWidget [
        <category: 'user interface'>

        ^ GTK.GtkVPaned new
            add1: self buildFinderEntry;
            add2: self buildClassAndMethodList;
            yourself
    ]

    buildFinderEntry [
        <category: 'user interface'>

        searchEntry := GTK.GtkEntry new
			    connectSignal: 'activate' to: self selector: #searchValidate;
			    yourself.
        ^ (GTK.GtkHBox new: true spacing: 3)
            add: (GTK.GtkLabel new: 'Class or method :');
            add: searchEntry;
            yourself
    ]

    buildClassAndMethodList [
        <category: 'user interface'>

        imageTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Methods and Classes'}}).
        imageTree setSearchEntry: searchEntry.
        [ (model := GtkListModel on: imageTree getModel)
					item: (image := GtkImage new);
                                        contentsBlock: [ :each | {each displayString} ];
					refresh ] fork.
        ^ GTK.GtkScrolledWindow withChild: imageTree
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        imageTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    whenTextChangedSend: aSelector to: anObject [
	<category: 'events'>

        searchEntry connectSignal: 'activate' to: anObject selector: aSelector
    ]

    grabFocus [
	<category: 'focus events'>

	searchEntry grabFocus
    ]

    text [
	<category: 'accessing'>

	^ searchEntry getText
    ]

    searchValidate [
	<category: 'search entry events'>

	searchEntry getText isEmpty 
		    ifTrue: [ model item: image ]
		    ifFalse: [ model item: (image matchRegex: searchEntry getText) ].
	model refresh
    ]

    hasSelection [
	<category: 'accessing'>

	^ imageTree hasSelectedItem
    ]

    selection [
	<category: 'accessing'>

        self hasSelection ifFalse: [ ^ self error: 'Nothing is selected' ].
        ^ imageTree selection
    ]

    matchSelector: aSymbol [
	<category: 'matching'>

	^ image matchSelector: aSymbol
    ]
]

