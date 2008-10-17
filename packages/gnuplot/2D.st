"======================================================================
|
|   GNUPlot bindings, GPPlot and related classes 
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

GPAbstractPlot subclass: GPPlot [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a single ''plot'' command.'>

    | xAxis x2Axis yAxis y2Axis barWidth barGap |

    GPPlot class >> defaultStyleClass [
        ^GPPlotStyle 
    ]

    axes [
	<category: 'printing'>
	"Note we don't use the accessors!"
	^{ xAxis ifNotNil: [ :axis | axis withName: 'x' ].
	   x2Axis ifNotNil: [ :axis | axis withName: 'x2' ].
	   yAxis ifNotNil: [ :axis | axis withName: 'y' ].
	   y2Axis  ifNotNil: [ :axis | axis withName: 'y2' ] }
    ]

    xAxis [
	<category: 'accessing'>
	^xAxis ifNil: [ xAxis := GPAxis new name: 'x'; yourself ]
    ]

    xAxis: aGPAxis [
	<category: 'accessing'>
	xAxis := aGPAxis
    ]

    x2Axis [
	<category: 'accessing'>
	^x2Axis ifNil: [ x2Axis := GPAxis new name: 'x2'; yourself ]
    ]

    x2Axis: aGPAxis [
	<category: 'accessing'>
	x2Axis := aGPAxis
    ]

    yAxis [
	<category: 'accessing'>
	^yAxis ifNil: [ yAxis := GPAxis new name: 'y'; yourself ]
    ]

    yAxis: aGPAxis [
	<category: 'accessing'>
	yAxis := aGPAxis
    ]

    y2Axis [
	<category: 'accessing'>
	^y2Axis ifNil: [ y2Axis := GPAxis new name: 'y2'; yourself ]
    ]

    y2Axis: aGPAxis [
	<category: 'accessing'>
	y2Axis := aGPAxis
    ]

    barGap [
	<category: 'accessing'>
	^barGap
    ]

    barGap: anInteger [
	<category: 'accessing'>
	barGap := anInteger
    ]

    barWidth [
	<category: 'accessing'>
	barWidth isNil ifTrue: [ barWidth := 1 ].
	^barWidth
    ]

    barWidth: aNumber [
	<category: 'accessing'>
	barWidth := aNumber
    ]

    newGroup: anInteger of: maxGroup [
	<category: 'private'>
	| gap |
	gap := (self barGap ifNil: [ #(##(1/2) 1) at: maxGroup ifAbsent: [2] ])
	  - (1 - self barWidth).
	^(super newGroup: anInteger of: maxGroup)
	    barOffset: (2 * anInteger - 1 - maxGroup) / 2 / (maxGroup + gap);
	    barWidth: self barWidth / (maxGroup + gap);
	    yourself
    ]

    function: exprBlock [
	<category: 'building'>
	| expr |
	expr := exprBlock value: (GPVariableExpression on: $x).
        ^self add: (GPFunctionSeries on: expr)
    ]

    lrSteps: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'steps';
			yourself)
    ]

    lrSteps: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self lrSteps: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    ulSteps: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'fsteps';
			yourself)
    ]

    ulSteps: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self ulSteps: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    centerSteps: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'histeps';
			yourself)
    ]

    centerSteps: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self centerSteps: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    dots: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'dots';
			yourself)
    ]

    dots: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self dots: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    points: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'points';
			yourself)
    ]

    points: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self points: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    labels: aDataSourceOrArray [
	<category: 'building'>
	"For now, center is passed from here.  Later, GPTextSeries will have
	 its own params class."
	^self add: ((GPTextSeries on: aDataSourceOrArray)
			graphType: 'labels center';
			yourself)
    ]

    labels: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self labels: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    bubbles: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPBubbleSeries on: aDataSourceOrArray)
			graphType: 'points';
			yourself)
    ]

    bubbles: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self bubbles: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    impulses: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'impulses';
			yourself)
    ]

    impulses: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self impulses: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    vectors: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPVectorSeries on: aDataSourceOrArray)
			graphType: 'vectors';
			yourself)
    ]

    vectors: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self vectors: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    bars: aDataSourceOrArray [
	<category: 'building'>
	^self add: (GPBarSeries on: aDataSourceOrArray)
    ]

    bars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self bars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    boxes: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPBoxSeries on: aDataSourceOrArray)
			graphType: 'boxes';
			yourself)
    ]

    boxes: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self boxes: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    xyErrorBoxes: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYErrorSeries on: aDataSourceOrArray)
			graphType: 'boxxyerrorbars';
			yourself)
    ]

    xyErrorBoxes: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self xyErrorBoxes: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    errorBoxes: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPErrorBoxSeries on: aDataSourceOrArray)
			graphType: 'boxerrorbars';
			yourself)
    ]

    errorBoxes: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self errorBoxes: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    candleSticks: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPFinancialDataSeries on: aDataSourceOrArray)
			graphType: 'candlesticks';
			yourself)
    ]

    candleSticks: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self candleSticks: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    financeBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPFinancialDataSeries on: aDataSourceOrArray)
			graphType: 'financebars';
			yourself)
    ]

    financeBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self financeBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    lines: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'lines';
			yourself)
    ]

    lines: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self lines: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    xyErrorBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYErrorSeries on: aDataSourceOrArray)
			graphType: 'xyerrorbars';
			yourself)
    ]

    xyErrorBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self xyErrorBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    xErrorBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXErrorSeries on: aDataSourceOrArray)
			graphType: 'xerrorbars';
			yourself)
    ]

    xErrorBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self xErrorBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    errorBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPErrorSeries on: aDataSourceOrArray)
			graphType: 'errorbars';
			yourself)
    ]

    errorBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self errorBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    displaySeriesOn: aStream [
	<category: 'printing'>
        aStream nextPutAll: 'plot '.
        super displaySeriesOn: aStream
    ]
]

GPStyle subclass: GPPlotStyle [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define parameters for a ''plot'' command.'>

]

GPGroupSeries subclass: GPBarSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for an histogram.'>

    defaultColumns [
	^{ GPColumnRef column: 1 }
    ]

    data [
	^self columns first
    ]

    data: expr [
	self columns: { expr asGPExpression }
    ]

    displayOn: aStream group: aGroup [
        self dataSource displayOn: aStream.
        aStream nextPutAll: ' using '.
        self displayColumnsOn: aStream group: aGroup.
        self displayStyleOn: aStream group: aGroup.
	aGroup stackData: self data.
        self displayTicLabelsOn: aStream group: aGroup.
    ]

    displayColumnsOn: aStream group: aGroup [
	aStream nextPutAll: '($0'.
	aGroup barOffset < 0 ifFalse: [ aStream nextPut: $+ ].
	aStream print: aGroup barOffset asFloat.
	aStream nextPutAll: '):'.
	aGroup dataOffset isNil
	    ifTrue: [
		aStream display: self data.
		aStream nextPutAll: ':('.
		aStream display: aGroup barWidth asFloat.
		aStream nextPut: $) ]
	    ifFalse: [
		aStream display: aGroup dataOffset + (self data / 2).
		aStream nextPutAll: ':('.
		aStream display: (aGroup barWidth / 2) asFloat.
		aStream nextPutAll: '):'.
		aStream display: self data / 2 ].
    ]

    displayStyleOn: aStream group: aGroup [
	aGroup dataOffset isNil
	    ifTrue: [ aStream nextPutAll: ' with boxes' ]
	    ifFalse: [ aStream nextPutAll: ' with boxxyerrorbars' ].
	super displayStyleOn: aStream group: aGroup
    ]

    displayTicLabelsOn: aStream group: aGroup [
	ticColumns isNil ifFalse: [
	    aStream nextPutAll: ', '.
	    self dataSource displayOn: aStream.
	    aStream nextPutAll: ' using 0:'.
	    aStream display: aGroup dataOffset.
	    aStream nextPutAll: ':""'.
	    super displayTicLabelsOn: aStream group: aGroup.
	    aStream nextPutAll: ' notitle with labels'.
	]
    ]

    printDataOn: aStream [
	super printDataOn: aStream.
	ticColumns isNil ifFalse: [ super printDataOn: aStream ].
    ]
]

GPDataSeries subclass: GPXYSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values.'>

    defaultColumns [
	| c0 c1 c2 |
	c0 := GPColumnRef column: 0.
	c1 := GPColumnRef column: 1.
	(self ticColumns notNil and: [ self ticColumns includes: 2 ])
	    ifTrue: [ ^{ c0. c1 } ].

	c2 := GPColumnRef column: 2.
	^{ c2 ifValid: [ c1 ] ifNotValid: [ c0 ].
	   c2 ifValid: [ c2 ] ifNotValid: [ c1 ] }
    ]

    data: expr [
	self columns: { expr asGPExpression }
    ]

    x: xExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression  }
    ]
]

GPXYSeries subclass: GPBubbleSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y,size) values,
i.e. a bubble plot.'>

    GPBubbleSeries class >> defaultStyle [
	^defaultStyle ifNil: [ super defaultStyle pointType: 6; yourself ]
    ]

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr size: sizeExpr [
	self columns: { xExpr asGPExpression. yExpr asGPExpression.
			sizeExpr asGPExpression }
    ]

    displayOn: aStream [
	super displayOn: aStream.
	aStream nextPutAll: ' ps variable'
    ]
]

GPXYSeries subclass: GPTextSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y,text) values.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr text: textExpr [
	self columns: { xExpr asGPExpression. yExpr asGPExpression.
			textExpr asGPExpression }
    ]
]

GPXYSeries subclass: GPBoxSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
optionally specifying a box width.'>

    x: xExpr y: yExpr width: widthExpr [
	self columns: { xExpr asGPExpression. yExpr asGPExpression.
			widthExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPErrorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with a (vertical) error bar.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr error: errExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			errExpr asGPExpression }
    ]

    x: xExpr min: minExpr max: maxExpr [
	| y err min max |
	min := minExpr asGPExpression.
        max := maxExpr asGPExpression.
	y := (min + max) / 2.
	err := (max - min) / 2.
	self columns: { xExpr asGPExpression.  y. err }
    ]

    x: xExpr y: yExpr min: minExpr max: maxExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			minExpr asGPExpression.
			maxExpr asGPExpression }
    ]
]

GPErrorSeries subclass: GPErrorBoxSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with an adjustable width and a (vertical) error bar.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr error: errExpr width: widthExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			errExpr asGPExpression.
			widthExpr asGPExpression }
    ]

    x: xExpr min: minExpr max: maxExpr width: widthExpr [
	| y err min max |
	min := minExpr asGPExpression.
        max := maxExpr asGPExpression.
	y := (min + max) / 2.
	err := (max - min) / 2.
	self columns: { xExpr asGPExpression.  y. err.
			widthExpr asGPExpression }
    ]

    x: xExpr y: yExpr min: minExpr max: maxExpr width: widthExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			minExpr asGPExpression.
			maxExpr asGPExpression.
			widthExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPXErrorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with an horizontal error bar.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr error: errExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			errExpr asGPExpression }
    ]

    min: minExpr max: maxExpr y: yExpr [
	| x err min max |
	min := minExpr asGPExpression.
        max := maxExpr asGPExpression.
	x := (min + max) / 2.
	err := (max - min) / 2.
	self columns: { x. yExpr asGPExpression. err }
    ]

    x: xExpr min: minExpr max: maxExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			minExpr asGPExpression.
			maxExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPXYErrorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with 2D error bars.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3. GPColumnRef column: 4 }
    ]

    x: xExpr error: xErrExpr y: yExpr error: yErrExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			xErrExpr asGPExpression.
			yErrExpr asGPExpression }
    ]

    xMin: xMinExpr max: xMaxExpr yMin: yMinExpr max: yMaxExpr [
	| x y xErr yErr xMin yMin xMax yMax |
	xMin := xMinExpr asGPExpression.
        xMax := xMaxExpr asGPExpression.
	x := (xMin + xMax) / 2.
	xErr := (xMax - xMin) / 2.
	yMin := yMinExpr asGPExpression.
        yMax := yMaxExpr asGPExpression.
	y := (yMin + yMax) / 2.
	yErr := (yMax - yMin) / 2.
	self columns: { x. y. xErr. yErr }
    ]

    x: xExpr min: xMinExpr max: xMaxExpr y: yExpr min: yMinExpr max: yMaxExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			xMinExpr asGPExpression.
			xMaxExpr asGPExpression.
			yMinExpr asGPExpression.
			yMaxExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPVectorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for vector fields.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3. GPColumnRef column: 4 }
    ]

    x: xExpr dx: dxExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			dxExpr asGPExpression.
			0 asGPExpression }
    ]

    x: xExpr y: yExpr dx: dxExpr dy: dyExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			dxExpr asGPExpression.
			dyExpr asGPExpression }
    ]

    x: xExpr dx: dxExpr y: yExpr dy: dyExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			dxExpr asGPExpression.
			dyExpr asGPExpression }
    ]

    x1: x1Expr x2: x2Expr y: yExpr [
	| x1 |
	x1 := x1Expr asGPExpression.
	self columns: { x1.  yExpr asGPExpression.
			x2Expr asGPExpression - x1.
			0 asGPExpression }
    ]

    x: xExpr y: yExpr dy: dyExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			0 asGPExpression.
			dyExpr asGPExpression }
    ]

    x: xExpr y1: y1Expr y2: y2Expr [
	| y1 |
	y1 := y1Expr asGPExpression.
	self columns: { xExpr asGPExpression.  y1.
			0 asGPExpression.
			y2Expr asGPExpression - y1 }
    ]

    x1: x1Expr x2: x2Expr y1: y1Expr y2: y2Expr [
	| x1 y1 |
	x1 := x1Expr asGPExpression.
	y1 := y1Expr asGPExpression.
	self columns: { x1.  y1.
			x2Expr asGPExpression - x1.
			y2Expr asGPExpression - y1 }
    ]
]

GPDataSeries subclass: GPFinancialDataSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for
low/high/open/close values.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3. GPColumnRef column: 4.
	   GPColumnRef column: 5 }
    ]

    x: xExpr open: openExpr low: lowExpr high: highExpr close: closeExpr [
	self columns: { xExpr asGPExpression.
			openExpr asGPExpression.
			lowExpr asGPExpression.
			highExpr asGPExpression.
			closeExpr asGPExpression }
    ]

]

