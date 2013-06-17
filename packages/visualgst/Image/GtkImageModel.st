"======================================================================
|
| GtkImage class definition
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

Object subclass: GtkImage [

    GtkImage class >> new [
	<category: 'instance creation'>

	^ self basicNew
		initialize;
		yourself
    ]

    | finderDic |

    initialize [
	<category: 'initialize-release'>

	finderDic := Dictionary new.
	self
	    registerNotifier;
            buildNamespaceModel;
            buildClassModel;
            buildMethodModel
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(GtkLauncher uniqueInstance systemChangeNotifier)
	    notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addNamespaceEvent:';
	    notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeNamespaceEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Added using: #'addClassEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeClassEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Added using: #'addMethodEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeMethodEvent:'
    ]

    buildNamespaceModel [
        <category: 'model builder'>

        self appendNamespace: Smalltalk
    ]

    appendNamespace: aNamespace [
        <category: 'model builder'>

	| namespace |
        finderDic at: aNamespace displayString ifAbsentPut: [ Dictionary new ].
	self at: aNamespace displayString addToFinder: (NamespaceFinder on: aNamespace).

        aNamespace subspacesDo: [ :each | self appendNamespace: each ].
	Processor activeProcess yield
    ]

    buildClassModel [
        <category: 'model builder'>

        | class string |
        Class allSubclassesDo: [ :each |
	    Processor activeProcess yield.
            string := each asClass name asString, ' '.
            finderDic at: string ifAbsentPut: [ Dictionary new ].
	    self at: string addToFinder: (ClassFinder on: each) ]
    ]

    buildMethodModel [
        <category: 'model builder'>

	| method |
        CompiledMethod allInstancesDo: [ :each | | selector |
	    Processor activeProcess yield.
            selector := each selector asString.
            finderDic at: selector ifAbsentPut: [ Dictionary new ].
	    self at: selector addToFinder: (MethodFinder on: each methodClass with: each selector) ]
    ]

    at: aSelector addToFinder: aFinderObject [
	<category: 'finder accessing'>

	(finderDic at: aSelector)
                at: aFinderObject displayString
                put: aFinderObject
    ]

    matchSelector: aSymbol [
	<category: 'item selection'>

        ^ finderDic at: aSymbol asString ifAbsent: [ self error: 'Element not found' ].
    ]

    matchRegex: aString [
	<category: 'item selection'>

	| result |
	result := Dictionary new.
	finderDic keysAndValuesDo: [ :key :value |
	    (key matchRegex: aString) ifTrue: [ result at: key put: value ] ].
	^ (self class new)
	    image: result;
	    registerNotifier;
	    yourself
    ]

    image: aDictionary [
	<category:'accessing'>

	finderDic := aDictionary
    ]

    do: aBlock [
	<category: 'model'>

	(finderDic keys asArray "sort: [ :a :b | a <= b ]") do: aBlock
    ]

    addNamespaceEvent: anEvent [
	<category: 'events'>

        finderDic at: anEvent item displayString ifAbsentPut: [ Dictionary new ].
	self at: anEvent item displayString addToFinder: (NamespaceFinder on: anEvent item).
    ]

    removeNamespaceEvent: anEvent [
	<category: 'events'>
    ]

    addClassEvent: anEvent [
	<category: 'events'>

	| string |
        string := ((anEvent item displayString) substrings: $.) last.
        finderDic at: string ifAbsentPut: [ Dictionary new ].
	self at: string addToFinder: (ClassFinder on: anEvent item) 
    ]

    removeClassEvent: anEvent [
	<category: 'events'>
    ]

    addMethodEvent: anEvent [
	<category: 'events'>
    ]

    removeMethodEvent: anEvent [
	<category: 'events'>
    ]
]
