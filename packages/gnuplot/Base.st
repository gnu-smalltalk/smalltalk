"======================================================================
|
|   GNUPlot bindings base classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

Object subclass: GPObject [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define aspects of a plot.'>

    GPObject class >> new [
	<category: 'instance creation'>
        ^super new initialize
    ]

    asString [
	<category: 'printing'>
	^self displayString
    ]

    initialize [
	<category: 'private - initialization'>
    ]

    displayOn: aStream [
	<category: 'printing'>
    ]

    printOn: aStream [
	<category: 'printing'>
	self class printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $)
    ]
]

GPObject subclass: GNUPlot [
    | plots terminal cols |
    
    <category: 'GNUPlot'>
    <comment: 'I am the main class to interact with GNU plot.
	See GNUPlotExamples for usage examples'>

    CommandPath := nil.

    GNUPlot class >> commandPath [
	<category: 'executing'>
	^CommandPath ifNil: [ self defaultCommandPath ]
    ]

    GNUPlot class >> commandPath: aString [
	<category: 'executing'>
	CommandPath := aString
    ]

    GNUPlot class >> defaultCommandPath [
	<category: 'executing'>
	^(Smalltalk hostSystem indexOfSubCollection: '-mingw' ifAbsent: [ 0 ]) > 0
	    ifTrue: [ 'pgnuplot.exe -' ]
	    ifFalse: [ 'gnuplot' ]
    ]

    GNUPlot class >> newPipe: dir [
	<category: 'executing'>
	^FileStream popen: self commandPath dir: dir
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	plots := OrderedCollection new
    ]

    output: aFileName [
	<category: 'accessing'>
	self terminal isInteractive ifTrue: [ self terminal: GPPngTerminal new ].
	self terminal output: aFileName
    ]

    execute [
	^self terminal display: self
    ]

    cols [
	^cols
    ]

    cols: anInteger [
	cols := anInteger
    ]

    add: aPlot [
	<category: 'accessing'>
	^plots add: aPlot
    ]
	
    plot [
	"Adding a plot command and returning GPPlot instance ready for accepting parameters"

	<category: 'accessing'>
	plots size > 1 ifTrue: [ self error: 'cannot use #plot in multiplot' ].
	plots size = 1 ifTrue: [ ^plots first ].
	^self add: GPPlot new
    ]

    multiplotLayout [
	| theCols theRows |
	<category: 'converting'>
	theCols := cols isNil ifTrue: [plots size sqrt ceiling] ifFalse: [cols].
	^theCols @ (plots size / theCols) ceiling
    ]

    displayOn: aStream [
	| layout row col thisRowCols |
	<category: 'converting'>
	plots size = 0 ifTrue: [ ^self ].

        aStream nextPutAll: 'reset'; nl.
	(plots size = 1 or: [ self terminal handlesMultiplot ]) ifTrue: [
	    plots do: [ :each | each displayOn: aStream ].
	    ^self ].

	layout := self multiplotLayout.
	aStream
	    nextPutAll: 'set size %1, %2' % {
		layout x asFloat / (layout x max: layout y).
		layout y asFloat / (layout x max: layout y) };
	    nl.

	row := col := 0.
	thisRowCols := layout x.
	aStream nextPutAll: 'set multiplot'; nl.
	plots keysAndValuesDo: 
	    [:i :each | 
            aStream
		nextPutAll: 'reset'; nl;
		nextPutAll: 'set size %1, %2' % { 1.0/layout x. 1.0/layout y } ; nl;
		nextPutAll: 'set origin %1, %2' % {
			(col + ((layout x - thisRowCols) / 2.0)) / layout x.
			(layout y - 1.0 - row) / layout y }; nl;
		display: each;
		nl.

	    col := col + 1.
	    col = layout x ifTrue: [
		col := 0.
		row := row + 1.
		thisRowCols := (i + layout x min: plots size) - i]].
	aStream nextPutAll: 'unset multiplot'; nl
    ]

    terminal [
	<category: 'accessing'>
	^terminal ifNil: [ terminal := GPInteractiveTerminal new ].
    ]

    terminal: aGPTerminal [
	<category: 'accessing'>
	terminal := aGPTerminal
    ]
]


GPObject subclass: GPStyle [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plot
element.'>

    | params |

    initialize [
	<category: 'initialize-release'>
	super initialize.
	params := Dictionary new
    ]

    isDefault [
	^params isEmpty
    ]

    displayOn: aStream [
	<category: 'printing'>
	params keysAndValuesDo: 
		[:key :val | 
		aStream
		    space; nextPutAll: key;
		    space.
		val isSymbol
		    ifTrue: [aStream nextPutAll: val]
		    ifFalse: [aStream print: val]]
    ]
]


GPObject subclass: GPDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define the source of a plotted data set.'>

    at: anObject [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    defaultTitle [
	self subclassResponsibility
    ]

    printDataOn: aStream [
	<category: 'printing'>
	"Do nothing by default"
    ]

    asGPDataSource [
	^self
    ]
]

GPDataSource subclass: GPFileDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances allow to use a file as the source of a plot.'>

    | fileName index |
    GPFileDataSource class >> on: aString [
	<category: 'instance creation'>
	^self new fileName: aString
    ]

    at: anInteger [
	<category: 'accessing'>
	index isNil ifFalse: [ self error: 'data set already chosen' ].
	^self copy index: anInteger - 1; yourself
    ]

    defaultTitle [
	^fileName
    ]

    index: anInteger [
	<category: 'private'>
	index := anInteger
    ]

    fileName [
	<category: 'accessing'>
	^fileName
    ]

    fileName: aString [
	<category: 'private - initialization'>
	fileName := aString
    ]

    displayOn: aStream [
	fileName printOn: aStream
	index isNil
	    ifFalse: [ aStream nextPutAll: ' index '; display: index ]
    ]
]

File extend [
    asGPDataSource [
	^GNUPlot.GPDataSource on: self name
    ]
]

GPDataSource subclass: GPSmalltalkDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances allow to use an object, typically a collection,
as the source of a plot.'>

    | data |
    GPSmalltalkDataSource class >> on: aCollection [
	<category: 'instance creation'>
	^self new
	    add: aCollection; yourself
    ]

    initialize [
	<category: 'private - initialization'>
	super initialize.
	data := OrderedCollection new
    ]

    at: anInteger [
	<category: 'accessing'>
	^self class on: (data at: anInteger)
    ]

    add: aCollection [
	<category: 'private - initialization'>
	data add: aCollection
    ]

    defaultTitle [
	^nil
    ]

    displayOn: aStream [
	'''-''' displayOn: aStream
    ]

    printData: anObject on: aStream level: n [
        anObject isNumber ifTrue: [anObject printOn: aStream. ^self].

        anObject isString ifTrue: [
	    aStream nextPut: $".
	    aStream display: (anObject copyReplaceAll: '"' with: '\"').
	    aStream nextPut: $".
	    ^self ].

	anObject
	    do: [:each |
		self printData: each on: aStream level: n + 1.
		n = 3 ifTrue: [ aStream space ] ifFalse: [ aStream nl ] ]
    ]

    printDataOn: aStream [
	self printData: data on: aStream level: 1.
        aStream nextPut: $e; nl.
    ]

    Object >> asGPDataSource [
	^GNUPlot.GPSmalltalkDataSource on: self
    ]
]


GPObject subclass: GPElement [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define an element of a drawing,
whose appearance can also be customized.'>

    | style |

    GPElement class [
	| defaultStyle |
	defaultStyleClass [
	    self subclassResponsibility
	]

	defaultStyle [
            ^defaultStyle ifNil: [ defaultStyle := self defaultStyleClass new ]
	]
    ]

    style [
        <category: 'accessing'>
        ^style ifNil: [ style := self class defaultStyle copy ].
    ]

    style: anObject [
        <category: 'accessing'>
        style := anObject.
    ]

    addTo: aGPPlot [
	<category: 'private - double dispatch'>
	self subclassResponsibility
    ]
]


GPElement subclass: GPContainer [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define objects that establish a
coordinate system.'>

    | objects |
    initialize [
	<category: 'private - initialization'>
	super initialize.
	objects := OrderedCollection new.
    ]

    addObject: anElement [
        <category: 'private - double dispatch'>
        ^objects add: anElement
    ]

    addSeries: aSeries [
        <category: 'private - double dispatch'>
        self shouldNotImplement
    ]

    add: aGPObject [
        <category: 'building'>
        ^aGPObject addTo: self
    ]

    xCoordinateSystem [
	<category: 'printing'>
	self subclassResponsibility
    ]

    yCoordinateSystem [
	<category: 'printing'>
	^''
    ]

    displayOn: aStream [
        <category: 'printing'>
        objects do: [:each |
	    each
		displayOn: aStream
		pointDisplay: [ :str :p |
		    str
			nextPutAll: self xCoordinateSystem;
			space;
			print: p x;
			nextPut: $,;
			nextPutAll: self yCoordinateSystem;
			space;
			print: p y ].
	    aStream nl]
    ]
]


GPContainer subclass: GPAbstractPlot [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a single ''plot'' command.'>

    | series |

    axes [
        <category: 'printing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'private - initialization'>
	super initialize.
	series := OrderedCollection new
    ]

    addSeries: aSeries [
        <category: 'private - double dispatch'>
        ^series add: aSeries
    ]

    function: exprBlock [
        <category: 'building'>
        self subclassResponsibility
    ]

    function: exprBlock with: aBlock [
        <category: 'building'>
        | series |
        series := self function: exprBlock.
        aBlock value: series.
        ^series
    ]

    displayPrologOn: aStream [
	<category: 'display'>
	| defs |
        style isNil ifFalse: [ style displayOn: aStream ].
        self axes do: [ :d | d isNil ifFalse: [ aStream display: d; nl ] ].

	defs := Set new.
        series do: [:d | d displayPrologOn: aStream into: defs ].
    ]

    groupedSeries [
	"Assign groups to series that do not have one, and return a
	 Dictionary of OrderedCollections, holding the series according
	 to their #group."
	<category: 'private'>

	| groupedSeries maxGroup |
	maxGroup := series inject: 0 into: [ :old :each |
	    each group = 0 ifTrue: [ each group: old + 1 ].
	    each group ].

	groupedSeries := LookupTable new.
	series do: [:d |
	    (groupedSeries
		at: (self newGroup: d group of: maxGroup)
		ifAbsentPut: [ OrderedCollection new ])
		    add: d ].

	^groupedSeries
    ]

    newGroup: anInteger of: maxGroup [
	<category: 'private - factory'>
	^GPSeriesGroup new
	    id: anInteger;
	    yourself
    ]

    displaySeriesOn: aStream [
        <category: 'printing'>
	| groupedSeries first |
	groupedSeries := self groupedSeries.
	first := true.
	groupedSeries
	    keysAndValuesDo: [:group :list |
	        list do: [:d |
		    first ifFalse: [aStream nextPutAll: ', '].
		    first := false.
		    d displayOn: aStream group: group]].

        aStream nl.
	groupedSeries do: [:list |
	    list do: [:d | d printDataOn: aStream]]
    ]

    displayOn: aStream [
        <category: 'printing'>
        self displayPrologOn: aStream.
	super displayOn: aStream.
        self displaySeriesOn: aStream.
    ]

    xCoordinateSystem [
	<category: 'printing'>
	^'screen'
    ]
]


GPObject subclass: GPTerminal [
    
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
(corresponding to the ''set terminal'' command).'>

    displayOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'set terminal ';
	    nextPutAll: self name;
	    nextPut: Character space.
	self printOptionsOn: aStream.
	aStream nl.
    ]

    printOptionsOn: aStream [
	<category: 'printing'>
    ]

    name [
	"Return a string identifying terminal type"

	<category: 'printing'>
	self subclassResponsibility
    ]

    display: aGNUPlot [
	<category: 'executing'>
	self subclassResponsibility
    ]

    display: aGNUPlot on: aStream [
	<category: 'executing'>
	^aStream
	    display: self; nl;
	    display: aGNUPlot;
	    yourself
    ]

    handlesMultiplot [
	<category: 'testing'>
	^false
    ]

    isInteractive [
	<category: 'testing'>
	self subclassResponsibility
    ]
]


GPTerminal subclass: GPInteractiveTerminal [
    
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that plots data on the display.'>

    display: aGNUPlot [
	<category: 'executing'>
	| pipe |
	pipe := GNUPlot newPipe: FileStream write.
	self display: aGNUPlot on: pipe.
	pipe close
    ]

    displayOn: aStream [
	<category: 'printing'>
	| options |
	options := String streamContents: [ :s | self printOptionsOn: s ].
	options isEmpty ifTrue: [ ^self ].
	aStream nextPutAll: 'set macros'; nl.
	super displayOn: aStream
    ]

    name [
	"Return a string identifying terminal type"

	<category: 'printing'>
	^'@GNUTERM'
    ]

    isInteractive [
	<category: 'testing'>
	^true
    ]
]


GPTerminal subclass: GPFileTerminal [
    
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a file.'>

    | output |

    output [
	<category: 'accessing'>
	^output
    ]

    output: aFileName [
	<category: 'accessing'>
	output := aFileName
    ]

    displayOn: aStream [
	<category: 'printing'>
	super displayOn: aStream.
	aStream
	    nextPutAll: 'set output ';
	    print: (self output ifNil: [ '-' ])
    ]

    display: aGNUPlot [
	<category: 'executing'>
	| pipe |
	pipe := GNUPlot newPipe: FileStream readWrite.
	self display: aGNUPlot on: pipe.
	^pipe shutdown; contents
    ]

    isInteractive [
	<category: 'testing'>
	^false
    ]
]
