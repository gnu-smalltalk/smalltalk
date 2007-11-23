"======================================================================
|
|   GNUPlot bindings, graphical objects
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

GPElement subclass: GPGraphicalObject [
    <category: 'GNUPlot'>
    <comment: 'My instance represent a pictorial element that can be added
to a graph.'>

    displayOn: aStream [
	<category: 'printing'>
	self
            displayOn: aStream
            pointDisplay: [ :str :p |
                str
                    print: p x;
                    nextPut: $,;
                    print: p y ]
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
    ]

    addTo: aGPPlot [
        <category: 'private - double dispatch'>
        aGPPlot addObject: self
    ]
]


GPStyle subclass: GPLabelStyle [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to customize the appearance of a label
on a graph.'>

    | font rotate offset |

    font [
	<category: 'accessing'>
	^font
    ]

    font: aString [
	<category: 'accessing'>
	font := aString
    ]

    rotate [
	<category: 'accessing'>
	^rotate
    ]

    rotate: aNumber [
	<category: 'accessing'>
	rotate := aNumber
    ]

    offset [
	<category: 'accessing'>
	^offset
    ]

    offset: aPoint [
	<category: 'accessing'>
	offset := aPoint
    ]

    displayOn: aStream [
	<category: 'printing'>
	self font isNil ifFalse: [
	    aStream nextPutAll: ' font '; print: self font ].
	self rotate isNil ifFalse: [
	    aStream nextPutAll: ' rotate by '; print: self rotate ].
	self offset isNil ifFalse: [
	    aStream
		nextPutAll: ' offset ';
		print: self offset x;
		nextPut: $,
		print: self offset y ].
    ]
]

GPGraphicalObject subclass: GPLabel [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a label on a graph.'>

    | position align text |
    GPLabel class >> position: aPoint text: aString [
	<category: 'instance creation'>
	^self new
	    position: aPoint;
	    text: aString
    ]

    GPLabel class >> defaultStyleClass [
	<category: 'style'>
        ^GPLabelStyle
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	align := #left
    ]

    align [
	<category: 'accessing'>
	^align
    ]

    align: aSymbol [
	<category: 'accessing'>
	align := aSymbol
    ]

    position [
	<category: 'accessing'>
	^position
    ]

    position: aString [
	<category: 'accessing'>
	position := aString
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    text: aString [
	<category: 'accessing'>
	text := aString
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream
	    nextPutAll: 'set label ';
	    print: self text displayString;
	    nextPutAll: ' front at '.

	aBlock value: aStream value: self position.
	align isNil ifFalse: [ aStream space; nextPutAll: self align ].
	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]


GPGraphicalObject subclass: GPBoundingBox [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a rectangle drawn on a graph.'>

    | bbox |
    GPBoundingBox class >> origin: origin corner: corner [
	<category: 'instance creation'>
	^self new
	    boundingBox: (Rectangle origin: origin corner: corner)
    ]

    GPBoundingBox class >> origin: origin extent: extent [
	<category: 'instance creation'>
	^self new
	    boundingBox: (Rectangle origin: origin extent: extent)
    ]

    GPBoundingBox class >> left: l top: t right: r bottom: b [
	<category: 'instance creation'>
	^self new
	    boundingBox: (Rectangle left: l top: t right: r bottom: b)
    ]

    GPBoundingBox class >> boundingBox: aRectangle [
	<category: 'instance creation'>
	^self new
	    boundingBox: aRectangle
    ]

    boundingBox [
	<category: 'accessing'>
	^bbox
    ]

    boundingBox: aRectangle [
	<category: 'accessing'>
	bbox := aRectangle
    ]

    left [
	<category: 'accessing'>
	^bbox left
    ]

    top [
	<category: 'accessing'>
	^bbox top
    ]

    right [
	<category: 'accessing'>
	^bbox right
    ]

    bottom [
	<category: 'accessing'>
	^bbox bottom
    ]

    origin [
	<category: 'accessing'>
	^bbox origin
    ]

    corner [
	<category: 'accessing'>
	^bbox corner
    ]

    width [
	<category: 'accessing'>
	^bbox width
    ]

    height [
	<category: 'accessing'>
	^bbox height
    ]
]


GPStyle subclass: GPLineStyle [
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


GPBoundingBox subclass: GPLine [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define an arrow drawn on a graph.'>

    GPLine class >> defaultStyleClass [
	<category: 'style'>
        ^GPLineStyle
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream nextPutAll: 'set arrow from '.
	aBlock value: aStream value: self origin.
	aStream nextPutAll: ' to '.
	aBlock value: aStream value: self corner.
	aStream nextPutAll: ' front nohead'.

	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]


GPLineStyle subclass: GPRectangleStyle [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define the appearance of a rectangle
drawn on a graph.'>

    fillStyle [
        <category: 'styles'>
        ^params at: #fillstyle ifAbsent: [ #solid ]
    ]

    fillStyle: aString [
        <category: 'styles'>
        params at: #fillstyle put: aString
    ]
]

GPBoundingBox subclass: GPRectangle [
    GPRectangle class >> defaultStyleClass [
	<category: 'style'>
        ^GPRectangleStyle
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream nextPutAll: 'set object rect from '.
	aBlock value: aStream value: self origin.
	aStream nextPutAll: ' to '.
	aBlock value: aStream value: self corner.
	aStream nextPutAll: ' front'.

	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]


GPLineStyle subclass: GPArrowStyle [
    | head tail filled size thickness |

    initialize [
	<category: 'initialization'>
	super initialize.
	head := true.
	tail := false.
	filled := true.

	"This looks more or less like gnuplot's default arrow."
	size := (0.015 * 15 degreesToRadians cos)
		@ (0.015 * 15 degreesToRadians sin).
	thickness := 0.
    ]

    thickness [
	<category: 'accessing'>
	^thickness
    ]

    thickness: aNumber [
	<category: 'accessing'>
	"<1 gives an acute angle (concave head), =1 a right angle."
	thickness := aNumber
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	"The x size is parallel to the line, the y size
	 is perpendicular."
	<category: 'accessing'>
	size := aPoint
    ]

    head [
	<category: 'accessing'>
	^head
    ]

    head: aSymbol [
	<category: 'accessing'>
	head := aSymbol
    ]

    tail [
	<category: 'accessing'>
	^tail
    ]

    tail: aSymbol [
	<category: 'accessing'>
	tail := aSymbol
    ]

    filled [
	<category: 'accessing'>
	^filled
    ]

    filled: aSymbol [
	<category: 'accessing'>
	filled := aSymbol
    ]

    displayOn: aStream [
	<category: 'printing'>
	| heads angle backAngle length |
	heads := (#((' nohead' ' backhead') (' head') (' heads'))
		    at: (head ifTrue: [ 2 ] ifFalse: [ 1 ]))
		        at: (tail ifTrue: [ 2 ] ifFalse: [ 1 ]).

	aStream nextPutAll: heads.

	angle := size y arcTan: size x.
	length := size x / angle cos.
	angle := angle radiansToDegrees rounded.
	aStream
	   nextPutAll: ' size screen ';
	   print: length;
	   nextPut: $,;
	   print: angle.

	backAngle := thickness = 0
	    ifTrue: [ angle ]
	    ifFalse: [ (size y arcTan: size x * (1 - thickness))
				radiansToDegrees rounded ].

	backAngle > angle
	    ifTrue: [
		aStream
		    nextPut: $,;
		    print: backAngle;
		    nextPutAll: (filled ifTrue: [ ' filled' ] ifFalse: [ ' empty' ]) ]
	    ifFalse: [
		aStream nextPutAll: ' nofilled' ].

	super displayOn: aStream
    ]
]

GPBoundingBox subclass: GPArrow [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define an arrow drawn on a graph.'>

    GPArrow class >> defaultStyleClass [
	<category: 'style'>
        ^GPArrowStyle
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream nextPutAll: 'set arrow from '.
	aBlock value: aStream value: self origin.
	aStream nextPutAll: ' to '.
	aBlock value: aStream value: self corner.
	aStream nextPutAll: ' front'.

	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]

