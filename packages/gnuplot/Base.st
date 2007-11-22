"======================================================================
|
|   GNUPlot bindings base classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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

"The GPSeriesParams class is Copyright (c) 2007 Igor Stasenko
 and licensed under the X11 license.

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the `Software'), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE."

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
	<category: 'instance creation'>
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
	plots size = 1 ifTrue: [
	    plots first displayOn: aStream.
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
		display: each; nl.
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


GPObject subclass: GPAxis [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plotted
axis.'>

    | name range logScale mirrorTics outwardTics ticRange ticSpacing
	ticSubdivision majorGrid minorGrid tics style label |

    name: aString [
	<category: 'private - initialization'>
	name := aString
    ]

    withName: aString [
	<category: 'private - initialization'>
	^name = aString
	    ifTrue: [ self ]
	    ifFalse: [ self copy name: aString ]
    ]

    from: a to: b [
        <category: 'accessing'>
        range := { a. b }
    ]

    from [
        <category: 'accessing'>
        ^range ifNotNil: [ :r | r first ]
    ]

    to [
        <category: 'accessing'>
        ^range ifNotNil: [ :r | r second ]
    ]

    ticAt: value put: string [
        <category: 'accessing'>
	tics ifNil: [ tics := OrderedCollection new ].
	tics add: value asGPExpression->string
    ]

    ticFrom: a to: b [
        <category: 'accessing'>
        ticRange := { a. b }
    ]

    ticFrom [
        <category: 'accessing'>
        ^ticRange ifNotNil: [ :r | r first ]
    ]

    ticTo [
        <category: 'accessing'>
        ^ticRange ifNotNil: [ :r | r second ]
    ]

    ticSpacing [
        <category: 'accessing'>
        ^ticSpacing
    ]

    ticSpacing: aNumber [
        <category: 'accessing'>
        ticSpacing := aNumber
    ]

    label [
        <category: 'accessing'>
        ^label
    ]

    label: aString [
        <category: 'accessing'>
        label := aString
    ]

    ticSubdivision [
        <category: 'accessing'>
        ^ticSubdivision
    ]

    ticSubdivision: aNumber [
        <category: 'accessing'>
        ticSubdivision := aNumber
    ]

    majorGrid [
        <category: 'accessing'>
        ^majorGrid
    ]

    majorGrid: aPlotParams [
        <category: 'accessing'>
        aPlotParams == true ifTrue: [ majorGrid := GPLineParams new. ^self ].
        aPlotParams == false ifTrue: [ majorGrid := nil. ^self ].
        majorGrid := aPlotParams
    ]

    minorGrid [
        <category: 'accessing'>
        ^minorGrid
    ]

    minorGrid: aPlotParams [
        <category: 'accessing'>
        aPlotParams == true ifTrue: [ minorGrid := GPLineParams new. ^self ].
        aPlotParams == false ifTrue: [ minorGrid := nil. ^self ].
        minorGrid := aPlotParams
    ]

    style [
        <category: 'accessing'>
        ^style
    ]

    style: aPlotParams [
        <category: 'accessing'>
        aPlotParams == true ifTrue: [ style := GPLineParams new. ^self ].
        aPlotParams == false ifTrue: [ style := nil. ^self ].
        style := aPlotParams
    ]

    logScale [
        <category: 'accessing'>
        ^logScale ifNil: [ logScale := false ]
    ]

    logScale: aBoolean [
        <category: 'accessing'>
        logScale := aBoolean
    ]

    mirrorTics [
        <category: 'accessing'>
        ^mirrorTics ifNil: [ mirrorTics := true ]
    ]

    mirrorTics: aBoolean [
        <category: 'accessing'>
        mirrorTics := aBoolean
    ]

    outwardTics [
        <category: 'accessing'>
        ^outwardTics ifNil: [ outwardTics := false ]
    ]

    outwardTics: aBoolean [
        <category: 'accessing'>
        outwardTics := aBoolean
    ]

    displayGridOn: aStream [
        <category: 'printing'>
	| majGrid |
        aStream
            nextPutAll: 'set grid '.
	minorGrid isNil ifFalse: [ aStream nextPut: $m ].
	aStream
            nextPutAll: name;
            nextPutAll: 'tics'.

	majGrid := (majorGrid isNil and: [ minorGrid notNil ])
	    ifTrue: [ minorGrid ]
	    ifFalse: [ majorGrid ].

	majGrid notNil
	    ifTrue: [
		majGrid isDefault
		    ifTrue: [ aStream nextPutAll: ' ls 0' ]
		    ifFalse: [ aStream display: majGrid ] ].

	minorGrid isNil ifTrue: [ ^self ].
	aStream nextPut: $,.
	minorGrid isDefault
	    ifTrue: [ aStream nextPutAll: ' ls 0' ]
	    ifFalse: [ aStream display: minorGrid ].
    ]

    displayRangeOn: aStream [
        <category: 'printing'>
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'range [';
            display: range first;
            nextPut: $:;
            display: range second;
            nextPut: $];
            nl
    ]

    displayTicsOn: aStream [
        <category: 'printing'>
	| spacing |
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'tics'.
	self mirrorTics ifFalse: [ aStream nextPutAll: ' nomirror' ].
	self outwardTics ifTrue: [ aStream nextPutAll: ' out' ].
	ticRange isNil
	    ifTrue: [
		ticSpacing isNil ifFalse: [ aStream space; display: ticSpacing ] ]
	    ifFalse: [
	        spacing :=
		    ticSpacing ifNil: [ (self ticTo - self ticFrom) / 4.0 ].
		aStream
		     space; display: self ticFrom;
		     nextPut: $,; display: spacing;
		     nextPut: $,; display: self ticTo ].
		    
        aStream nl
    ]

    displayUserTicsOn: aStream [
        <category: 'printing'>
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'tics add ('.
	tics
	    do: [ :each |
	        aStream
		    print: each value; 
		    space;
		    display: each key ]
	    separatedBy: [ aStream nextPut: $, ].
	aStream nextPut: $); nl
    ]

    displayOn: aStream [
        <category: 'printing'>
	| spacing |
        range isNil ifFalse: [
            self displayRangeOn: aStream ].
	(ticRange notNil or: [ ticSpacing notNil
		or: [ self mirrorTics not or: [ self outwardTics ]]])
	    ifTrue: [ self displayTicsOn: aStream ].
	tics notNil
	    ifTrue: [ self displayUserTicsOn: aStream ].
	(minorGrid notNil or: [ majorGrid notNil ])
	    ifTrue: [ self displayGridOn: aStream ].

	self label isNil ifFalse: [
            aStream
                nextPutAll: 'set ';
                nextPutAll: name;
                nextPutAll: 'label ';
		print: label;
                nl ].

	self logScale ifTrue: [
            aStream
                nextPutAll: 'set logscale ';
                nextPutAll: name;
                nl ].

	self style isNil ifFalse: [
            aStream
                nextPutAll: 'set ';
                nextPutAll: name;
                nextPutAll: 'zeroaxis';
                display: self style;
                nl ].

	self ticSubdivision isNil ifFalse: [
            aStream
                nextPutAll: 'set m';
                nextPutAll: name;
                nextPutAll: 'tics ';
                display: self ticSubdivision;
                nl ].
    ]
]

GPObject subclass: GPParams [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plot
element.'>

    | params |

    initialize [
	<category: 'initialize-release'>
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
		    space; display: val]
    ]
]

GPParams subclass: GPLineParams [
    lineColor [
	^params at: #linecolor ifAbsent: [ nil ]
    ]

    lineColor: aColorSpec [
	"aColorSpec has one of the following forms:
	 rgbcolor 'colorname'
	 rgbcolor '#RRGGBB'
	 rgbcolor variable
	 palette frac <val> # <val> runs from 0 to 1
	 palette cb <value> # <val> lies within cbrange
	 palette z
	 
	 'rgb variable' requires an additional column in the using specifier, and is only available in 3D plotting
	 mode (splot). The extra column is interpreted as a 24-bit packed RGB triple. These are most easily
	 specified in a data file as hexidecimal values (see above).
	 
	 Example:
	 rgb(r,g,b) = 65536 * int(r) + 256 * int(g) + int(b)
	 splot 'data' using 1:2:3:(rgb($1,$2,$3)) with points lc rgb variable
	 
	 The color palette is a linear gradient of colors that smoothly maps a single numerical value onto a
	 particular color. Two such mappings are always in effect. palette frac maps a fractional value between
	 0 and 1 onto the full range of the color palette. palette cb maps the range of the color axis onto the
	 same palette. See set cbrange. See also set colorbox. You can use either of these
	 to select a constant color from the current palette.
	 'palette z' maps the z value of each plot segment or plot element into the cbrange mapping of the
	 palette. This allows smoothly-varying color along a 3d line or surface. This option applies only to 3D
	 plots (splot).
	 "

	<category: 'styles'>
	"FIXME"
	params at: #linecolor
	    put: aColorSpec "(aColorSpec isColor 
		    ifTrue: ['rgbcolor ''' , aColorSpec asHTMLColor , '''']
		    ifFalse: [aColorSpec])"
    ]

    lineType [
	^params at: #linetype ifAbsent: [ nil ]
    ]

    lineType: aNumber [
	"If you wish to choose the line or point type for a single plot, <line type> and <point type> may be
	 specified. These are positive integer constants (or expressions) that specify the line type and point type
	 to be used for the plot."

	<category: 'styles'>
	params at: #linetype put: aNumber
    ]

    lineWidth [
	^params at: #linewidth ifAbsent: [ nil ]
    ]

    lineWidth: aParam [
	"You may also scale the line width and point size for a plot by using <line width> and <point size>,
	 which are specified relative to the default values for each terminal. The pointsize may also be altered
	 globally; see set pointsize for details. But note that both <point size> as set here and
	 as set by set pointsize multiply the default point size; their effects are not cumulative. That is, set
	 pointsize 2; plot x w p ps 3 will use points three times default size, not six."

	<category: 'styles'>
	params at: #linewidth put: aParam
    ]
]

GPLineParams subclass: GPSeriesParams [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plotted
function or data set.'>

    | x2 y2 title |
    
    y2 [
	<category: 'axes'>
	^y2 ifNil: [ false ]
    ]

    y2: aBoolean [
	<category: 'axes'>
	y2 := aBoolean
    ]

    x2 [
	<category: 'axes'>
	^x2 ifNil: [ false ]
    ]

    x2: aBoolean [
	<category: 'axes'>
	x2 := aBoolean
    ]

    notitle [
	"The line title and sample can be omitted from the key by using the keyword notitle"

	<category: 'title'>
	title := 'notitle'
    ]

    pointSize: aParam [
	"You may also scale the line width and point size for a plot by using <line width> and <point size>,
	 which are specified relative to the default values for each terminal. The pointsize may also be altered
	 globally — see set pointsize (p. 111) for details. But note that both <point size> as set here and
	 as set by set pointsize multiply the default point size — their effects are not cumulative. That is, set
	 pointsize 2; plot x w p ps 3 will use points three times default size, not six.
	 
	 It is also possible to specify pointsize variable either as part of a line style or for an individual plot.
	 In this case one extra column of input is required, i.e. 3 columns for a 2D plot and 4 columns for a 3D
	 splot. The size of each individual point is determined by multiplying the global pointsize by the value
	 read from the data file."

	<category: 'styles'>
	params at: #pointsize put: aParam
    ]

    pointType: aNumber [
	"If you wish to choose the line or point type for a single plot, <line type> and <point type> may be
	 specified. These are positive integer constants (or expressions) that specify the line type and point type
	 to be used for the plot."

	<category: 'styles'>
	params at: #pointtype put: aNumber
    ]

    axes [
	| axes |
	axes := 'axes x1y1' copy.
	self x2 ifTrue: [ axes at: 7 put: $2 ].
	self y2 ifTrue: [ axes at: 9 put: $2 ].
	^axes
    ]

    titleFor: aSeries [
	title notNil ifTrue: [ ^title ].
	^aSeries defaultTitle
	    ifNil: [ 'notitle' ]
	    ifNotNil: [ :defaultTitle | 'title ''%1''' % { defaultTitle } ]
    ]

    displayOn: aStream [
	self displayOn: aStream for: nil
    ]

    displayOn: aStream for: aSeries [
	"#axes #title #with comes first, then rest"

	<category: 'converting'>
	(self x2 or: [ self y2 ])
	    ifTrue: [ aStream space; nextPutAll: self axes ].
	(title notNil or: [ aSeries notNil ])
	    ifTrue: [ aStream space; nextPutAll: (self titleFor: aSeries) ].
	super displayOn: aStream
    ]

    title: aTitle [
	"A line title for each function and data set appears in the key, accompanied by a sample of the line and/or
	 symbol used to represent it.
	 
	 If key autotitles is set (which is the default) and neither title nor notitle are specified the line title is
	 the function name or the file name as it appears on the plot command. If it is a file name, any datafile
	 modifiers specified will be included in the default title.
	 "

	<category: 'title'>
	"Using printString, i.e. single quotes, to prevent backslash conversion"
	title := 'title ', aTitle printString
    ]
]

GPObject subclass: GPSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted function or data set.'>

    | params |
    GPSeries class [
	| defaultParams |
	defaultParamsClass [
	    ^GPSeriesParams
	]

	defaultParams [
            ^defaultParams ifNil: [ defaultParams := self defaultParamsClass new ]
	]
    ]

    defaultTitle [
	self subclassResponsibility
    ]

    params [
	^params ifNil: [ params := self class defaultParams copy ].
    ]

    printDataOn: aStream [
	<category: 'printing'>
    ]

    displayOn: aStream [
	<category: 'printing'>
	| theParameters |
	theParameters := params ifNil: [ self class defaultParams ].
	theParameters displayOn: aStream for: self
    ]

    displayPrologOn: aStream into: defs [
    ]
]

GPSeries subclass: GPFunctionSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted function.'>

    | expression range |
    GPFunctionSeries class >> on: expr [
	<category: 'instance creation'>
	^self new expression: expr
    ]

    defaultTitle [
	^String streamContents: [ :str | expression displayAsOperandOn: str ]
    ]

    expression [
	<category: 'accessing'>
	^expression
    ]

    expression: expr [
	<category: 'private - initialization'>
	expression := expr asGPExpression
    ]

    from: a to: b [
	<category: 'accessing'>
	range := { a. b }
    ]

    from [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r first ]
    ]

    to [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r second ]
    ]

    displayOn: aStream [
        <category: 'printing'>
	range isNil ifFalse: [
	    aStream
		nextPut: $[;
		display: range first;
		nextPut: $:;
		display: range second;
		nextPut: $];
		space ].
	expression displayOn: aStream.
	super displayOn: aStream
    ]

    displayPrologOn: aStream into: defs [
	expression displayPrologOn: aStream into: defs
    ]
]

GPSeriesParams subclass: GPDataSeriesParams [
    smooth: aSymbol [
	"aSymbol is any of #unique, #frequency, #csplines, #bezier, #sbezier"
	
	<category: 'styles'>
	params at: #smooth put: aSymbol asString
    ]
]

GPSeries subclass: GPDataSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted data set.'>

    | columns dataSource style ticColumns |
    GPDataSeries >> defaultParamsClass [
	^GPDataSeriesParams
    ]

    GPDataSeries class >> on: aDataSource [
	<category: 'instance creation'>
	^self new dataSource: aDataSource asGPDataSource
    ]

    columns [
	<category: 'accessing'>
	^columns
    ]

    columns: anArray [
	<category: 'private - initialization'>
	columns := anArray
    ]

    dataSource [
	<category: 'accessing'>
	^dataSource
    ]

    dataSource: aDataSource [
	<category: 'private - initialization'>
	dataSource := aDataSource
    ]

    defaultTitle [
	^dataSource defaultTitle
    ]

    style: aString [
	<category: 'private - initialization'>
	style := aString
    ]

    displayOn: aStream [
	dataSource displayOn: aStream.
	aStream nextPutAll: ' using '.
	columns
	    do: [ :each | each displayOn: aStream ]
	    separatedBy: [ aStream nextPut: $: ].

	"Add xticlabels etc. fake columns."
	ticColumns isNil ifFalse: [
	    ticColumns keysAndValuesDo: [ :k :v |
		aStream
		    nextPut: $:;
		    nextPutAll: k;
		    nextPut: $(;
		    display: v;
		    nextPut: $) ] ].

	aStream nextPutAll: ' with '; nextPutAll: style; space.
	super displayOn: aStream.
    ]

    printDataOn: aStream [
	dataSource printDataOn: aStream.
    ]

    displayPrologOn: aStream into: defs [
	columns do: [ :each | each displayPrologOn: aStream into: defs ]
    ]

    ticColumns [
	^ticColumns ifNil: [ ticColumns := LookupTable new ]
    ]

    xTicColumn [
	^self ticColumns at: 'xtic' ifAbsent: [ nil ]
    ]

    xTicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'xtic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'xtic' put: column ]
    ]

    x2TicColumn [
	^self ticColumns at: 'x2tic' ifAbsent: [ nil ]
    ]

    x2TicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'x2tic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'x2tic' put: column ]
    ]

    yTicColumn [
	^self ticColumns at: 'ytic' ifAbsent: [ nil ]
    ]

    yTicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'ytic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'ytic' put: column ]
    ]

    y2TicColumn [
	^self ticColumns at: 'y2tic' ifAbsent: [ nil ]
    ]

    y2TicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'y2tic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'y2tic' put: column ]
    ]

    "zTicColumn [
	^self ticColumns at: 'ztic' ifAbsent: [ nil ]
    ]

    zTicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'ztic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'ztic' put: column ]
    ]"
]


GPObject subclass: GPDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define the source of a plotted data set.'>

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

    | fileName |
    GPFileDataSource class >> on: aString [
	<category: 'instance creation'>
	^self new fileName: aString
    ]

    defaultTitle [
	^fileName
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
	data := OrderedCollection new
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

GPObject subclass: GPAbstractPlot [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a single ''plot'' command.'>

    | series params |
    GPAbstractPlot class >> defaultParamsClass [
	self subclassResponsibility
    ]

    params [
        <category: 'accessing'>
        ^params ifNil: [ params := self class defaultParamsClass new ].
    ]

    params: aGPPlotParams [
        <category: 'accessing'>
        params := aGPPlotParams.
    ]

    axes [
        <category: 'printing'>
	self subclassResponsibility
    ]

    add: aSeries [
        <category: 'building'>
        series isNil ifTrue: [ series := OrderedCollection new ].
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

    displayPrologOn: aStream into: defs [
        params isNil ifFalse: [ params displayOn: aStream ].
        series do: [:d | d displayPrologOn: aStream into: defs ].
    ]

    displayOn: aStream [
        <category: 'printing'>
	| defs |
	series isNil ifTrue: [ ^self ].
	defs := Set new.
        self displayPrologOn: aStream into: defs.
        self axes do: [ :d |
	    d isNil ifFalse: [ aStream display: d; nl ] ].
        aStream nextPutAll: 'plot '.
        series do: [:d | d displayOn: aStream]
            separatedBy: [aStream nextPutAll: ' , '].
        aStream nl.
        series do: [:d | d printDataOn: aStream]
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
