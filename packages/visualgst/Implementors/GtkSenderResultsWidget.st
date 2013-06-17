"======================================================================
|
| GtkSenderResultsWidget class definition
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

GtkImageResultsWidget subclass: GtkSenderResultsWidget [

    GtkSenderResultsWidget class [ | LiteralsAndSpecialSelectors | ]

    GtkSenderResultsWidget class >> literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^ LiteralsAndSpecialSelectors ifNil: [
            LiteralsAndSpecialSelectors := Dictionary new.
            [ CompiledMethod allInstancesDo: [ :each |
                each literalsAndSpecialSelectorsDo: [ :lit |
                    lit isSymbol
                        ifTrue: [ (LiteralsAndSpecialSelectors at: lit ifAbsentPut: [ OrderedCollection new ]) add: each ]
                        ifFalse: [  "lit isClass ifTrue: [ lit displayString printNl.
                                            (LiteralsAndSpecialSelectors at: lit displayString asSymbol ifAbsentPut: [ OrderedCollection new ]) add: each ]" ]
                                 ] ] ] fork.
            LiteralsAndSpecialSelectors ]
    ]

    buildTreeView [
        <category: 'user interface'>

	| widget |
	widget := super buildTreeView.
	model contentsBlock: [ :each | {each displayString} ].
	^ widget
    ]

    appendSenderResults: aDictionary [

	self
	    clear;
	    findInMethod: aDictionary values first element
    ]

    literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^  self class literalsAndSpecialSelectors
    ]

    findInMethod: anObject [
        <category: 'find'>

        (self literalsAndSpecialSelectors at: anObject displaySymbol ifAbsent: [ #() ] ) do: [ :each |
            model append: each ].
    ]

    selectedResult: aBrowser [

        | currentMethod |
	self hasSelectedResult ifFalse: [ ^ self ].
        currentMethod := self selectedResult.

        aBrowser
                selectANamespace: currentMethod methodClass environment;
                selectAClass: (currentMethod methodClass isClass ifTrue: [ currentMethod methodClass ] ifFalse: [ currentMethod methodClass instanceClass ]).
        currentMethod methodClass isClass
                ifTrue: [ aBrowser selectAnInstanceMethod: currentMethod selector ]
                ifFalse: [ aBrowser selectAClassMethod: currentMethod selector  ]
    ]
]

