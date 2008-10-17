"======================================================================
|
|   GNUPlot bindings style classes
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

"The GPSeriesStyle class is Copyright (c) 2007 Igor Stasenko
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

GPRectangleStyle subclass: GPSeriesStyle [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plotted
function or data set.'>

    | x2 y2 title |
    
    initialize [
	<category: 'initialization'>
	super initialize.
	x2 := y2 := false
    ]

    y2 [
	<category: 'axes'>
	^y2
    ]

    y2: aBoolean [
	<category: 'axes'>
	y2 := aBoolean
    ]

    x2 [
	<category: 'axes'>
	^x2
    ]

    x2: aBoolean [
	<category: 'axes'>
	x2 := aBoolean
    ]

    fillStyle [
        <category: 'styles'>
        ^params at: #fillstyle ifAbsent: [ #empty ]
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
	    ifNotNil: [ :defaultTitle | 'title ', defaultTitle printString ]
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

Object subclass: GPSeriesGroup [
    <category: 'GNUPlot'>
    <comment: 'I am used internally to track the series that have already
been plotted in a group.'>

    | id barWidth barOffset dataOffset |
    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [ self id = anObject id ]
    ]

    hash [
	<category: 'basic'>
	^id hash
    ]

    id [
	<category: 'accessing'>
	id isNil ifTrue: [ id := 0 ].
	^id
    ]

    id: anInteger [
	<category: 'accessing'>
	id := anInteger
    ]

    barWidth [
	<category: 'accessing'>
	barWidth isNil ifTrue: [ barWidth := 0.5 ].
	^barWidth
    ]

    barWidth: aNumber [
	<category: 'accessing'>
	barWidth := aNumber
    ]

    barOffset [
	<category: 'accessing'>
	barOffset isNil ifTrue: [ barOffset := 0 ].
	^barOffset
    ]

    barOffset: aNumber [
	<category: 'accessing'>
	barOffset := aNumber
    ]

    dataOffset [
	<category: 'accessing'>
	^dataOffset
    ]

    stackData: aColumn [
	<category: 'accessing'>
	dataOffset := dataOffset isNil
	    ifTrue: [ aColumn ]
	    ifFalse: [ dataOffset + aColumn ]
    ]
]

GPContainer subclass: GPSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted function or data set.'>

    GPSeries class >> defaultStyleClass [
	^GPSeriesStyle
    ]

    addTo: aGPPlot [
	<category: 'private - double dispatch'>
	aGPPlot addSeries: self
    ]

    defaultTitle [
	<category: 'dwim'>
	self subclassResponsibility
    ]

    group [
	<category: 'accessing'>
	^0
    ]

    group: anInteger [
	<category: 'accessing'>
	"Do nothing.  Grouping would not affect the way most data
	 series are drawn."
    ]

    printDataOn: aStream [
	<category: 'printing'>
    ]

    displayOn: aStream [
	<category: 'printing'>
	| group |
	group := GPSeriesGroup new id: self group; yourself.
	self displayOn: aStream group: group.
    ]

    displayOn: aStream group: aGroup [
	<category: 'printing'>
	self displayStyleOn: aStream group: aGroup
    ]

    displayStyleOn: aStream group: aGroup [
	| theParameters |
	theParameters := style ifNil: [ self class defaultStyle ].
	theParameters displayOn: aStream for: self
    ]

    displayPrologOn: aStream into: defs [
	super displayOn: aStream.
    ]

    xCoordinateSystem [
	<category: 'printing'>
	^self style x2 ifTrue: [ 'second' ] ifFalse: [ '' ]
    ]

    yCoordinateSystem [
	<category: 'printing'>
	self style y2 == self style x2 ifTrue: [ ^'' ].
	^self style y2 ifTrue: [ 'second' ] ifFalse: [ 'first']
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

    displayOn: aStream group: aGroup [
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
	super displayOn: aStream group: aGroup
    ]

    displayPrologOn: aStream into: defs [
	super displayPrologOn: aStream into: defs.
	expression displayPrologOn: aStream into: defs
    ]
]


GPSeriesStyle subclass: GPDataSeriesStyle [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the processing of
a data set before plotting, or its appearance.'>

    smooth: aSymbol [
	"aSymbol is any of #unique, #frequency, #csplines, #bezier, #sbezier"
	
	<category: 'styles'>
	params at: #smooth put: aSymbol asString
    ]
]

GPSeries subclass: GPDataSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted data set.'>

    | columns dataSource graphType ticColumns |
    GPDataSeries class >> defaultStyleClass [
	^GPDataSeriesStyle
    ]

    GPDataSeries class >> on: aDataSource [
	<category: 'instance creation'>
	^self new dataSource: aDataSource asGPDataSource
    ]

    columns [
	<category: 'accessing'>
	columns ifNil: [ ^self defaultColumns ].
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

    defaultColumns [
	self subclassResponsibility
    ]

    defaultTitle [
	^dataSource defaultTitle
    ]

    graphType: aString [
	<category: 'private - initialization'>
	graphType := aString
    ]

    displayOn: aStream group: aGroup [
	self dataSource displayOn: aStream.
	aStream nextPutAll: ' using '.
	self displayColumnsOn: aStream group: aGroup.
	self displayTicLabelsOn: aStream group: aGroup.
	super displayOn: aStream group: aGroup.
    ]

    displayStyleOn: aStream group: aGroup [
	graphType isNil ifFalse: [
	    aStream nextPutAll: ' with '; nextPutAll: graphType; space ].
        super displayStyleOn: aStream group: aGroup
    ]

    displayColumnsOn: aStream group: aGroup [
	self columns
	    do: [ :each | each displayOn: aStream ]
	    separatedBy: [ aStream nextPut: $: ].
    ]

    displayTicLabelsOn: aStream group: aGroup [
	"Add xticlabels etc. fake columns."
	ticColumns isNil ifFalse: [
	    ticColumns keysAndValuesDo: [ :k :v |
		aStream
		    nextPut: $:;
		    nextPutAll: k;
		    nextPut: $(;
		    display: v;
		    nextPut: $) ] ].
    ]

    printDataOn: aStream [
	dataSource printDataOn: aStream.
    ]

    displayPrologOn: aStream into: defs [
	super displayPrologOn: aStream into: defs.
	columns isNil ifTrue: [ ^self ].
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

GPDataSeries subclass: GPGroupSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define plotted data sets when
more series can be grouped together (e.g. in stacked bars).'>

    | group |
    group [
	<category: 'accessing'>
	group isNil ifTrue: [ group := 0 ].
	^group
    ]

    group: anInteger [
	<category: 'accessing'>
	group := anInteger.
    ]
]


GPObject subclass: GPAxis [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plotted
axis.'>

    | name range logScale mirrorTics outwardTics ticRange ticSpacing ticFormat
      ticSubdivision majorGrid minorGrid tics style label labelStyle |

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

    from: a [
	<category: 'accessing'>
	range := { a. self to }
    ]

    to [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r second ]
    ]

    to: b [
	<category: 'accessing'>
	range := { self from. b }
    ]

    ticAt: value put: string [
        <category: 'accessing'>
	tics isNil ifTrue: [ tics := OrderedCollection new ].
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

    labelStyle [
        <category: 'accessing'>
        ^labelStyle
    ]

    labelStyle: aString [
        <category: 'accessing'>
        labelStyle := aString
    ]

    ticFormat [
        <category: 'accessing'>
        ^ticFormat
    ]

    ticFormat: aBoolean [
        <category: 'accessing'>
        ticFormat := aBoolean
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

    majorGrid: aLineStyle [
        <category: 'accessing'>
        aLineStyle == true ifTrue: [ majorGrid := GPLineStyle new. ^self ].
        aLineStyle == false ifTrue: [ majorGrid := nil. ^self ].
        majorGrid := aLineStyle
    ]

    minorGrid [
        <category: 'accessing'>
        ^minorGrid
    ]

    minorGrid: aLineStyle [
        <category: 'accessing'>
        aLineStyle == true ifTrue: [ minorGrid := GPLineStyle new. ^self ].
        aLineStyle == false ifTrue: [ minorGrid := nil. ^self ].
        minorGrid := aLineStyle
    ]

    style [
        <category: 'accessing'>
        ^style
    ]

    style: aLineStyle [
        <category: 'accessing'>
        aLineStyle == true ifTrue: [ style := GPLineStyle new. ^self ].
        aLineStyle == false ifTrue: [ style := nil. ^self ].
        style := aLineStyle
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	logScale := false.
	mirrorTics := true.
	outwardTics := false.
    ]

    logScale [
        <category: 'accessing'>
        ^logScale
    ]

    logScale: aBoolean [
        <category: 'accessing'>
        logScale := aBoolean
    ]

    mirrorTics [
        <category: 'accessing'>
        ^mirrorTics
    ]

    mirrorTics: aBoolean [
        <category: 'accessing'>
        mirrorTics := aBoolean
    ]

    outwardTics [
        <category: 'accessing'>
        ^outwardTics
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
            display: (range first ifNil: [ '*' ]);
            nextPut: $:;
            display: (range second ifNil: [ '*' ]);
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
	self displayTicRangeOn: aStream.
        aStream nl
    ]

    displayTicRangeOn: aStream [
        <category: 'printing'>
	| spacing |
	ticRange isNil
	    ifTrue: [
		(ticSpacing isNil and: [ ticSpacing > 0 ])
		    ifFalse: [ aStream space; display: ticSpacing ] ]
	    ifFalse: [
	        spacing := ticSpacing.
		spacing = 0 ifTrue: [ spacing := self ticTo - self ticFrom ].
		spacing isNil ifTrue: [ spacing := (self ticTo - self ticFrom) / 4.0 ].
		aStream
		     space; display: self ticFrom;
		     nextPut: $,; display: spacing;
		     nextPut: $,; display: self ticTo ].
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
		    print: each value displayString; 
		    space;
		    display: each key ]
	    separatedBy: [ aStream nextPut: $, ].
	aStream nextPut: $); nl
    ]

    displayLabelOn: aStream [
        <category: 'printing'>
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'label ';
	    print: label displayString.

	self labelStyle isNil ifFalse: [
	    aStream display: self labelStyle ].
	aStream nl
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
	label notNil
	    ifTrue: [ self displayLabelOn: aStream ].

	self ticFormat isNil ifFalse: [
            aStream
                nextPutAll: 'set format ';
                nextPutAll: name;
                space;
                print: self ticFormat;
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
