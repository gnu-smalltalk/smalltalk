WAFileLibrary subclass: WAFileLibraryDemo [
    
    <comment: nil>
    <category: 'Seaside-Examples-Misc'>

    mainCss [
	<category: 'accessing'>
	^'/* Pier

   Copyright (c) 2003-2006 Lukas Renggli
   Copyright (c) 2005-2006 Software Composition Group, University of Berne
*/

* {
	margin: 0px;
	padding: 0px;
}

body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	color: #111111;
	margin: 10px;
}

img {
	border: none;
}

td,
th {
	text-align: left;
	vertical-align: top;
}

a {
	text-decoration: none;
	color: #092565;
}

a:hover {
	text-decoration: underline;
}

.broken {
    color: #aa0000;
}

.protected {
    color: #aaaaaa;
}'
    ]

    mainJpg [
	<category: 'accessing'>
	^#(255 216 255 224 0 16 74 70 73 70 0 1 1 1 0 72 0 72 0 0 255 225 0 22 69 120 105 102 0 0 77 77 0 42 0 0 0 8 0 0 0 0 0 0 255 219 0 67 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 255 219 0 67 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 255 192 0 17 8 0 4 2 152 3 1 34 0 2 17 1 3 17 1 255 196 0 24 0 1 0 3 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 9 10 255 196 0 38 16 0 2 3 0 1 1 8 3 1 0 0 0 0 0 0 0 0 1 17 81 145 7 2 6 8 9 40 49 54 116 195 65 103 129 183 255 196 0 20 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 196 0 20 17 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 218 0 12 3 1 0 2 17 3 17 0 63 0 235 191 191 103 181 250 190 7 87 216 85 254 17 73 62 9 229 249 83 230 63 181 191 230 188 74 0 26 177 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 94 137 47 225 32 0 0 0 0 0 132 253 84 145 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 132 42 88 128 1 10 150 33 10 150 32 0 66 165 136 66 165 136 0 16 169 98 16 169 98 0 4 42 88 140 168 241 117 73 112 55 16 66 75 204 143 100 255 0 31 173 121 108 0 44 254 226 126 215 233 248 29 63 88 0 15 255 217) 
	    asByteArray
    ]
]



WAComponent subclass: WACounter [
    | count |
    
    <comment: 'A WACounter is component that displays a number. Additionally it has two links that allow the user to increase or decrease this number by 1. 

The lesson to learn here is how the Seaside callback mechanism is used, how anchors can be used to trigger actions.

Instance Variables
	count:		<Integer>

count
	- the number to display, default 0
'>
    <category: 'Seaside-Examples-Misc'>

    WACounter class >> canBeRoot [
	<category: 'testing'>
	^true
    ]

    WACounter class >> description [
	<category: 'accessing'>
	^'A very simple Seaside application'
    ]

    WACounter class >> entryPointName [
	<category: 'accessing'>
	^'examples/counter'
    ]

    WACounter class >> example [
	<category: 'examples'>
	^self new
    ]

    WACounter class >> initialize [
	<category: 'initialization'>
	self registerAsApplication: self entryPointName
    ]

    count [
	<category: 'accessing'>
	^count
    ]

    count: anInteger [
	<category: 'accessing'>
	count := anInteger
    ]

    decrease [
	<category: 'actions'>
	count := count - 1
    ]

    increase [
	<category: 'actions'>
	count := count + 1
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self count: 0
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html heading: count.
	(html anchor)
	    callback: [self increase];
	    with: '++'.
	html space.
	(html anchor)
	    callback: [self decrease];
	    with: '--'
    ]

    states [
	<category: 'accessing'>
	^Array with: self
    ]
]



WAComponent subclass: WAExampleBrowser [
    | class selector component hasAnswer answer |
    
    <comment: 'I browse all the examples available in the system ie all the results of class methods beginning with #example... 

point your browser to localhost:xxx/seaside/examples

If you want to see these examples

/seaside/config app:
- add a new application named "examples"
- choose WAExampleBrowser as the root component
'>
    <category: 'Seaside-Examples-Misc'>

    WAExampleBrowser class >> canBeRoot [
	<category: 'testing'>
	^true
    ]

    WAExampleBrowser class >> description [
	<category: 'accessing'>
	^'Browse through Seaside examples'
    ]

    WAExampleBrowser class >> initialize [
	<category: 'class initialization'>
	self registerAsApplication: 'examples/examplebrowser'
    ]

    allClasses [
	<category: 'helper'>
	^(WAComponent allSubclasses select: 
		[:each | 
		each class selectors 
		    anySatisfy: [:sel | sel startsWith: self selectorPrefix]]) 
	    asSortedCollection: [:a :b | a name < b name]
    ]

    allSelectors [
	<category: 'helper'>
	^(class class selectors 
	    select: [:each | each startsWith: self selectorPrefix]) asSortedCollection
    ]

    children [
	<category: 'accessing'>
	^Array with: component
    ]

    class: aClass [
	<category: 'accessing'>
	class := aClass.
	self selector: self allSelectors first
    ]

    component: aComponent [
	<category: 'accessing'>
	component := aComponent.
	hasAnswer := false.
	answer := nil.
	component onAnswer: 
		[:value | 
		hasAnswer := true.
		answer := value]
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	self class: self allClasses first
    ]

    renderChooserOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'chooser';
	    with: 
		    [html form: 
			    [(html select)
				beSubmitOnChange;
				list: self allClasses;
				selected: class;
				callback: [:value | self class: value]].
		    self allSelectors size > 1 
			ifTrue: 
			    [html form: 
				    [(html select)
					beSubmitOnChange;
					list: self allSelectors;
					selected: selector;
					callback: [:value | self selector: value]]]]
    ]

    renderComponentOn: html [
	<category: 'rendering'>
	(html heading)
	    level4;
	    with: component class headerForExampleBrowser.
	(html div)
	    class: 'component';
	    with: component.
	hasAnswer 
	    ifTrue: 
		[(html div)
		    class: 'answer';
		    with: answer printString]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderChooserOn: html.
	self renderComponentOn: html
    ]

    selector: aSymbol [
	<category: 'accessing'>
	selector := aSymbol.
	self component: (class perform: selector)
    ]

    selectorPrefix [
	<category: 'helper'>
	^'example'
    ]

    style [
	<category: 'accessing'>
	^'.chooser {
	background-color: #eee;
	padding: 5px;
}
.chooser form,
.chooser form div {
	display: inline;
}
.chooser form select {
	margin-right: 5px;
}
.component {
	padding: 5px;
}
.answer {
	background-color: #eee;
	padding: 5px;
}'
    ]
]



WAComponent subclass: WAMultiCounter [
    | counters |
    
    <comment: 'A WAMultiCounter is a component that consits of several instances of WACounter. Be sure to understand WACounter.

The lesson to learn here is how Seaside components can be composed of other components.

Instance Variables
	counters:		<Collection<WACounter>>

counters
	- a Collection of components (instances of WACounter) 
'>
    <category: 'Seaside-Examples-Misc'>

    WAMultiCounter class >> canBeRoot [
	<category: 'testing'>
	^true
    ]

    WAMultiCounter class >> description [
	<category: 'accessing'>
	^'Multiple Seaside components on one page'
    ]

    WAMultiCounter class >> initialize [
	<category: 'initialization'>
	self registerAsApplication: 'examples/multicounter'
    ]

    children [
	<category: 'accessing'>
	^counters
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	counters := (1 to: 5) collect: [:each | WACounter new]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	counters do: [:each | html render: each] separatedBy: [html horizontalRule]
    ]
]



Eval [
    WACounter initialize.
    WAExampleBrowser initialize.
    WAMultiCounter initialize
]

