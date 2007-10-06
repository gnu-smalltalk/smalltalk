"======================================================================
|
|   Smalltalk Tk-based GUI building blocks (canvas widget).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2004 Free Software Foundation, Inc.
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



BViewport subclass: BCanvas [
    | items boundingBox |
    
    <comment: '
I am an host for whatever geometric shape you want. If you want to do some
fancy graphics with Smalltalk, I''ll be happy to help. My friends derived
from BCanvasObject ask me all sort of things to do, so I am the real worker,
not they!

BCanvasObject: I am
BCanvas: No I am
BCanvasObject: No I am
BCanvas: No I am

well, you know, he always has something to object.'>
    <category: 'Graphics-Windows'>

    Initialized := nil.

    BCanvas class >> initializeOnStartup [
	<category: 'private'>
	Initialized := false
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    item: name at: option [
	<category: 'private - BCanvasObject protocol'>
	self 
	    tclEval: '%1 itemcget %2 -%3'
	    with: self connected
	    with: name
	    with: option
    ]

    item: name at: option put: value [
	<category: 'private - BCanvasObject protocol'>
	self 
	    tclEval: '%1 itemconfigure %2 -%3 %4'
	    with: self connected
	    with: name
	    with: option
	    with: value asTkString
    ]

    item: name bind: event to: aSymbol of: anObject parameters: params [
	<category: 'private - BCanvasObject protocol'>
	self 
	    bind: event
	    to: aSymbol
	    of: anObject
	    parameters: params
	    prefix: self connected , ' bind ' , name
    ]

    item: name points: pointsArray [
	<category: 'private - BCanvasObject protocol'>
	| stream |
	stream := WriteStream on: (String new: 50).
	stream
	    nextPutAll: self connected;
	    nextPutAll: ' coords ';
	    nextPutAll: name.
	pointsArray do: [:each | self extractCoordinatesFrom: each to: stream].
	self tclEval: stream contents
    ]

    itemCreate: item [
	<category: 'private - BCanvasObject protocol'>
	| stream name scrollRegion |
	stream := WriteStream on: (String new: 50).
	boundingBox := boundingBox isNil 
		    ifFalse: [boundingBox merge: item boundingBox]
		    ifTrue: [item boundingBox].
	stream
	    nextPutAll: self connected;
	    nextPutAll: ' create ';
	    nextPutAll: item itemType;
	    space.
	item points do: [:each | self extractCoordinatesFrom: each to: stream].
	item properties keysAndValuesDo: 
		[:key :value | 
		stream
		    nextPutAll: ' -';
		    nextPutAll: key;
		    space;
		    nextPutAll: value asTkString].
	self tclEval: stream contents.
	name := self tclResult.
	items at: name put: item.
	scrollRegion := boundingBox expandBy: self extraSpace.
	stream
	    reset;
	    nextPutAll: self connected;
	    nextPutAll: ' configure -scrollregion {';
	    print: scrollRegion left asInteger;
	    space;
	    print: scrollRegion top asInteger;
	    space;
	    print: scrollRegion right asInteger;
	    space;
	    print: scrollRegion bottom asInteger;
	    nextPut: $}.
	self tclEval: stream contents.
	^name
    ]

    lower: item [
	<category: 'private - BCanvasObject protocol'>
	self tclEval: self connected , ' lower ' , item
    ]

    raise: item [
	<category: 'private - BCanvasObject protocol'>
	self tclEval: self connected , ' raise ' , item
    ]

    remove: item [
	<category: 'private - BCanvasObject protocol'>
	(items removeKey: item) destroyed.
	self tclEval: self connected , ' delete ' , item
    ]

    show: item [
	<category: 'private - BCanvasObject protocol'>
	Initialized ifFalse: [self defineSeeProcedure].
	self 
	    tclEval: 'canvas_see %1 %2'
	    with: self connected
	    with: item
    ]

    addChild: child [
	"The widget identified by child has been added to the receiver.
	 This method is public not because you can call it, but because
	 it can be useful to override it, not forgetting the call to
	 either the superclass implementation or #basicAddChild:, to
	 perform some initialization on the children just added. Answer
	 the new child."

	<category: 'geometry management'>
	| name |
	self 
	    tclEval: self connected , ' create window 0 0 -window ' , child container.
	name := self tclResult.
	items at: name put: child.
	child properties at: #canvasItemId put: name.
	child properties at: #xyGeom put: Point new.
	^self basicAddChild: child
    ]

    child: child height: value [
	"Set the given child's height."

	<category: 'geometry management'>
	| id xy |
	id := child properties at: #canvasItemId.
	self item: id at: #height
    ]

    child: child heightOffset: value [
	"Offset the given child's height by value pixels."

	<category: 'geometry management'>
	self child: child height: (self heightChild: child) + value
    ]

    child: child width: value [
	"Set the given child's width."

	<category: 'geometry management'>
	| id xy |
	id := child properties at: #canvasItemId.
	self item: id at: #width
    ]

    child: child widthOffset: value [
	"Offset the given child's width by value pixels."

	<category: 'geometry management'>
	self child: child width: (self widthChild: child) + value
    ]

    child: child x: value [
	"Set the given child's top-left corner's x coordinate, in pixels
	 in the canvas' coordinate system."

	<category: 'geometry management'>
	| id xy |
	xy := child properties at: #xyGeom.
	xy x: value.
	id := child properties at: #canvasItemId.
	self item: id points: (Array with: xy)
    ]

    child: child xOffset: value [
	"Offset the given child's top-left x by value pixels."

	<category: 'geometry management'>
	self child: child x: (self xChild: child) + value
    ]

    child: child y: value [
	"Set the given child's top-left corner's y coordinate, in pixels
	 in the canvas' coordinate system."

	<category: 'geometry management'>
	| id xy |
	xy := child properties at: #xyGeom.
	xy y: value.
	id := child properties at: #canvasItemId.
	self item: id points: (Array with: xy)
    ]

    child: child yOffset: value [
	"Offset the given child's top-left y by value pixels."

	<category: 'geometry management'>
	self child: child y: (self yChild: child) + value
    ]

    heightChild: child [
	"Answer the given child's height in pixels."

	<category: 'geometry management'>
	^child heightAbsolute
    ]

    widthChild: child [
	"Answer the given child's width in pixels."

	<category: 'geometry management'>
	^child widthAbsolute
    ]

    xChild: child [
	"Answer the given child's top-left corner's x coordinate, in pixels
	 in the canvas' coordinate system."

	<category: 'geometry management'>
	^(child properties at: #xyGeom ifAbsentPut: [Point new]) x
    ]

    yChild: child [
	"Answer the given child's top-left corner's y coordinate, in pixels
	 in the canvas' coordinate system."

	<category: 'geometry management'>
	^(child properties at: #xyGeom ifAbsentPut: [Point new]) y
    ]

    create [
	<category: 'private'>
	self create: '-highlightthickness 0'.
	self tclEval: self connected , ' xview moveto 0'.
	self tclEval: self connected , ' yview moveto 0'
    ]

    defineSeeProcedure [
	<category: 'private'>
	Initialized := true.
	self 
	    tclEval: '
      ## "see" method alternative for canvas by Jeffrey Hobbs
      ## Aligns the named item as best it can in the middle of the screen
      ## Behavior depends on whether -scrollregion is set
      ##
      ## c    - a canvas widget
      ## item - a canvas tagOrId
      proc canvas_see {c item} {
	  set box [$c bbox $item]
	  if [string match {} $box] return
	  if [string match {} [$c cget -scrollreg]] {
	      ## People really should set -scrollregion you know...
	      foreach {x y x1 y1} $box {
		  set x [expr round(2.5*($x1+$x)/[winfo width $c])]
		  set y [expr round(2.5*($y1+$y)/[winfo height $c])]
	      }
	      $c xview moveto 0
	      $c yview moveto 0
	      $c xview scroll $x units
	      $c yview scroll $y units
	  } else {
	      ## If -scrollregion is set properly, use this
	      foreach {x y x1 y1} $box {top btm} [$c yview]  {left right} [$c xview] {p q xmax ymax} [$c cget -scrollreg] {
		  set xpos [expr (($x1+$x)/2.0)/$xmax - ($right-$left)/2.0]
		  set ypos [expr (($y1+$y)/2.0)/$ymax - ($btm-$top)/2.0]
	      }
	      $c xview moveto $xpos
	      $c yview moveto $ypos
	  }
      } '
    ]

    extractCoordinatesFrom: aPointOrArray to: stream [
	<category: 'private'>
	(aPointOrArray respondsTo: #do:) 
	    ifTrue: 
		[aPointOrArray do: 
			[:each | 
			stream
			    space;
			    print: each asInteger]]
	    ifFalse: 
		[stream
		    space;
		    print: aPointOrArray x asInteger;
		    space;
		    print: aPointOrArray y asInteger]
    ]

    initialize: parent [
	<category: 'private'>
	items := LookupTable new.
	super initialize: parent
    ]

    widgetType [
	<category: 'private'>
	^'canvas '
    ]

    at: aPoint [
	"Selects the topmost item in the canvas overlapping
	 the point given by aPoint."

	<category: 'widget protocol'>
	| item |
	self 
	    tclEval: '%1 find closest [%1 canvasx %2] [%1 canvasy %3]'
	    with: self connected
	    with: aPoint x printString
	    with: aPoint y printString.
	item := items at: self tclResult ifAbsent: [^nil].
	^(item boundingBox containsPoint: aPoint) ifTrue: [item] ifFalse: [nil]
    ]

    between: origin and: corner do: aBlock [
	"Evaluate aBlock for each item whose bounding box intersects the
	 rectangle between the two Points, origin and corner.  Pass the
	 item to the block."

	<category: 'widget protocol'>
	| r |
	r := Rectangle origin: origin corner: corner.
	items copy 
	    do: [:each | (each boundingBox intersects: r) ifTrue: [aBlock value: each]]
    ]

    boundingBox [
	"Answer the bounding box of all the items in the canvas"

	<category: 'widget protocol'>
	^boundingBox
    ]

    destroyed [
	"The widget has been destroyed.  Tell all of its items about this
	 fact."

	<category: 'widget protocol'>
	items 
	    do: [:each | (each isKindOf: BCanvasObject) ifTrue: [each destroyed]]
    ]

    do: aBlock [
	"Evaluate aBlock, passing each item to it."

	<category: 'widget protocol'>
	items do: aBlock
    ]

    empty [
	"Remove all the items from the canvas, leaving it empty"

	<category: 'widget protocol'>
	items copy do: [:each | each remove]
    ]

    extraSpace [
	"Answer the amount of space that is left as a border around the
	 canvas items."

	<category: 'widget protocol'>
	^self properties at: #extraSpace ifAbsentPut: [Point new]
    ]

    extraSpace: aPoint [
	"Set the amount of space that is left as a border around the
	 canvas items."

	<category: 'widget protocol'>
	self properties at: #extraSpace put: aPoint
    ]

    items [
	"Answer an Array containing all the items in the canvas"

	<category: 'widget protocol'>
	^items copy
    ]

    mapPoint: aPoint [
	"Given aPoint, a point expressed in window coordinates, answer the
	 corresponding canvas coordinates that are displayed at that location."

	<category: 'widget protocol'>
	| x stream |
	self 
	    tclEval: 'return "[%1 canvasx %2] [%1 canvasy %3]"'
	    with: aPoint x printString
	    with: aPoint y printString.
	stream := ReadStream on: self tclResult.
	x := (stream upTo: $ ) asInteger.
	^x @ stream upToEnd asInteger
    ]
]



BCanvas subclass: BScrolledCanvas [
    
    <comment: 'I am much similar to BCanvas, but I sport, in addition, two fancy scroll
bars. This is just a convenience, since it could be easily done when
creating the canvas...'>
    <category: 'Graphics-Windows'>

    create [
	"Create with both scrollbars"

	<category: 'private'>
	super create.
	self
	    horizontal: true;
	    vertical: true
    ]
]



BEventTarget subclass: BCanvasObject [
    | blox name properties |
    
    <comment: 'I am the ultimate ancestor of all items that you can put in a BCanvas.
I provide some general methods to my concrete offspring.'>
    <category: 'Graphics-Windows'>

    BCanvasObject class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    BCanvasObject class >> new: parentCanvas [
	"Answer a new instance of the receiver, displayed into the given
	 parentCanvas."

	<category: 'instance creation'>
	^(self basicNew)
	    blox: parentCanvas;
	    initializeWithProperties: IdentityDictionary new
    ]

    blox [
	"Answer the parent canvas of the receiver"

	<category: 'accessing'>
	^blox
    ]

    boundingBox [
	"Answer a Rectangle enclosing all of the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    color [
	"Answer the color to be used to fill this item's area."

	<category: 'accessing'>
	^self at: #fill
    ]

    color: color [
	"Set the color to be used to fill this item's area."

	<category: 'accessing'>
	^self at: #fill put: color
    ]

    copyInto: newCanvas [
	"Answer a new BCanvasObject identical to this but displayed
	 into another canvas, newCanvas.  The new instance is not
	 created at the time it is returned."

	<category: 'accessing'>
	^(self species basicNew)
	    blox: newCanvas;
	    initializeWithProperties: self properties copy;
	    points: self points;
	    postCopy;
	    yourself
    ]

    copyObject [
	"Answer a new BCanvasObject identical to this.  Unlike #copy,
	 which merely creates a new Smalltalk object with the same data
	 and referring to the same canvas item, the object created
	 with #copyObject is physically distinct from the original.
	 The new instance is not created at the time it is returned."

	<category: 'accessing'>
	^self copyInto: self blox
    ]

    createCopy [
	"Answer a new BCanvasObject identical to this.  Unlike #copy,
	 which merely creates a new Smalltalk object with the same data
	 and referring to the same canvas item, the object created
	 with #copyObject is physically distinct from the original.
	 The new instance has already been created at the time it is
	 returned."

	<category: 'accessing'>
	^(self copyObject)
	    create;
	    yourself
    ]

    createCopyInto: newCanvas [
	"Answer a new BCanvasObject identical to this but displayed
	 into another canvas, newCanvas.  The new instance has already
	 been created at the time it is returned."

	<category: 'accessing'>
	^(self copyInto: newCanvas)
	    create;
	    yourself
    ]

    deepCopy [
	"It does not make sense to make a copy, because it would
	 make data inconsistent across different objects; so answer
	 the receiver"

	<category: 'accessing'>
	^self
    ]

    grayOut [
	"Apply a 50% gray stippling pattern to the object"

	<category: 'accessing'>
	self at: #stipple put: 'gray50'
    ]

    shallowCopy [
	"It does not make sense to make a copy, because it would
	 make data inconsistent across different objects; so answer
	 the receiver"

	<category: 'accessing'>
	^self
    ]

    at: option [
	<category: 'private'>
	^self properties at: option
	    ifAbsentPut: 
		[self created ifFalse: [self error: 'option not set yet'].
		self blox item: self name at: option]
    ]

    at: option put: value [
	<category: 'private'>
	self created 
	    ifTrue: 
		[self blox 
		    item: self name
		    at: option
		    put: value].
	^self properties at: option put: value
    ]

    blox: canvas [
	<category: 'private'>
	blox := canvas
    ]

    destroyed [
	<category: 'private'>
	name := nil
    ]

    integerAt: option [
	<category: 'private'>
	^(self at: option) asInteger
    ]

    integerAt: option put: value [
	<category: 'private'>
	^self at: option put: value asInteger printString
    ]

    makePoint: pointOrArray [
	<category: 'private'>
	(pointOrArray respondsTo: #do:) ifFalse: [^pointOrArray].
	^(pointOrArray at: 1) @ (pointOrArray at: 2)
    ]

    name [
	"Answer the name given to the object"

	<category: 'private'>
	^name
    ]

    numberAt: option [
	<category: 'private'>
	^(self at: option) asNumber asFloat
    ]

    numberAt: option put: value [
	<category: 'private'>
	^self at: option put: value asFloat printString
    ]

    primBind: event to: aSymbol of: anObject parameters: params [
	<category: 'private'>
	^self blox 
	    item: self name
	    bind: event
	    to: aSymbol
	    of: anObject
	    parameters: params
    ]

    properties [
	<category: 'private'>
	^properties
    ]

    create [
	"If the object has not been created yet and has been initialized
	 correctly, insert it for real in the parent canvas"

	<category: 'widget protocol'>
	self created ifTrue: [self error: 'object already created'].
	self checkValidity 
	    ifFalse: [self error: 'please initialize the object correctly'].
	name := self blox itemCreate: self
    ]

    created [
	"Answer whether the object is just a placeholder or has already
	 been inserted for real in the parent canvas"

	<category: 'widget protocol'>
	^self name notNil
    ]

    lower [
	"Move the item to the lowest position in the display list.
	 Child widgets always obscure other item types, and the stacking
	 order of window items is determined by sending methods to the
	 widget object directly."

	<category: 'widget protocol'>
	self blox lower: self name
    ]

    raise [
	"Move the item to the highest position in the display list.
	 Child widgets always obscure other item types, and the stacking
	 order of window items is determined by sending methods to the
	 widget object directly."

	<category: 'widget protocol'>
	self blox raise: self name
    ]

    redraw [
	"Force the object to be displayed in the parent canvas, creating
	 it if it has not been inserted for real in the parent, and refresh
	 its position if it has changed."

	<category: 'widget protocol'>
	self created 
	    ifTrue: [self blox item: self name points: self points]
	    ifFalse: [self create]
    ]

    remove [
	"Remove the object from the canvas"

	<category: 'widget protocol'>
	self blox remove: self name
    ]

    show [
	"Ensure that the object is visible in the center of the canvas,
	 scrolling it if necessary."

	<category: 'widget protocol'>
	self blox show: self name
    ]

    checkValidity [
	<category: 'private - abstract'>
	^true
    ]

    initializeWithProperties: aDictionary [
	<category: 'private - abstract'>
	properties := aDictionary
    ]

    itemType [
	<category: 'private - abstract'>
	self subclassResponsibility
    ]

    points [
	<category: 'private - abstract'>
	self subclassResponsibility
    ]
]



BCanvasObject subclass: BBoundingBox [
    | points |
    
    <comment: 'I am the ultimate ancestor of all items that you can put in a BCanvas and
which are well defined by their bounding box - i.e. everything except
BPolylines and BSplines.'>
    <category: 'Graphics-Windows'>

    boundingBox [
	"Answer a Rectangle enclosing all of the receiver"

	<category: 'accessing'>
	^Rectangle origin: self origin corner: self corner
    ]

    center [
	"Answer the center point of the receiver"

	<category: 'accessing'>
	^(self origin + self corner) / 2
    ]

    center: center extent: extent [
	"Move the object so that it is centered around the center Point and
	 its size is given by the extent Point.  No changes take place
	 until you invoke the #create (if the object has not been inserted
	 in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	self origin: center - ((self makePoint: extent) / 2) extent: extent
    ]

    corner [
	"Answer the Point specifying the lower-right corner of the receiver"

	<category: 'accessing'>
	^self makePoint: (points at: 2)
    ]

    corner: pointOrArray [
	"Set the Point specifying the lower-right corner of the receiver;
	 pointOrArray can be a Point or a two-item Array.  No changes take place
	 until you invoke the #create (if the object has not been inserted
	 in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	points at: 2 put: pointOrArray
    ]

    extent [
	"Answer a Point specifying the size of the receiver"

	<category: 'accessing'>
	^self corner - self origin
    ]

    extent: pointOrArray [
	"Set the Point specifying the size of the receiver;
	 pointOrArray can be a Point or a two-item Array.  No changes take place
	 until you invoke the #create (if the object has not been inserted
	 in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	self corner: self origin + (self makePoint: pointOrArray)
    ]

    moveBy: pointOrArray [
	"Move the object by the amount indicated by pointOrArray: that is,
	 its whole bounding box is shifted by that amount.  No changes take place
	 until you invoke the #create (if the object has not been inserted
	 in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	| point |
	point := self makePoint: pointOrArray.
	self origin: self origin + point corner: self corner + point
    ]

    origin [
	"Answer the Point specifying the top-left corner of the receiver"

	<category: 'accessing'>
	^self makePoint: (points at: 1)
    ]

    origin: pointOrArray [
	"Set the Point specifying the top-left corner of the receiver;
	 pointOrArray can be a Point or a two-item Array.  No changes take place
	 until you invoke the #create (if the object has not been inserted
	 in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	points at: 1 put: pointOrArray
    ]

    origin: originPointOrArray corner: cornerPointOrArray [
	"Set the bounding box of the object, based on a Point specifying the
	 top-left corner of the receiver and another specifying the bottom-right
	 corner; the two parameters can both be Points or two-item Arrays.
	 No changes take place until you invoke the #create (if the object has
	 not been inserted in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	points
	    at: 1 put: originPointOrArray;
	    at: 2 put: cornerPointOrArray
    ]

    origin: originPointOrArray extent: extentPointOrArray [
	"Set the bounding box of the object, based on a Point specifying the
	 top-left corner of the receiver and another specifying its size;
	 the two parameters can both be Points or two-item Arrays.
	 No changes take place until you invoke the #create (if the object has
	 not been inserted in the canvas yet) or the #redraw method."

	<category: 'accessing'>
	points
	    at: 1 put: originPointOrArray;
	    at: 2 put: self origin + (self makePoint: extentPointOrArray)
    ]

    checkValidity [
	<category: 'private'>
	^self points allSatisfy: [:each | each notNil]
    ]

    initializeWithProperties: aDictionary [
	<category: 'private'>
	super initializeWithProperties: aDictionary.
	points := Array new: 2
    ]

    points [
	<category: 'private'>
	^points
    ]
]



BBoundingBox subclass: BLine [
    
    <comment: 'I only draw straight lines but I can do that very well, even without
a ruler...'>
    <category: 'Graphics-Windows'>

    cap [
	"Answer the way in which caps are to be drawn at the endpoints
	 of the line.  The answer may be #butt (the default), #projecting, or
	 #round)."

	<category: 'accessing'>
	^self at: #capstyle
    ]

    cap: aSymbol [
	"Set the way in which caps are to be drawn at the endpoints
	 of the line.  aSymbol may be #butt (the default), #projecting, or
	 #round)."

	<category: 'accessing'>
	self at: #capstyle put: aSymbol
    ]

    width [
	"Answer the width with which the line is drawn."

	<category: 'accessing'>
	^self integerAt: #width
    ]

    width: pixels [
	"Set the width with which the line is drawn."

	<category: 'accessing'>
	^self integerAt: #width put: pixels
    ]

    itemType [
	<category: 'private'>
	^'line'
    ]
]



BBoundingBox subclass: BRectangle [
    
    <comment: '
I only draw rectangles but I can do that very well.'>
    <category: 'Graphics-Windows'>

    outlineColor [
	"Answer the color with which the outline of the rectangle is drawn."

	<category: 'accessing'>
	^self at: #outline
    ]

    outlineColor: color [
	"Set the color with which the outline of the rectangle is drawn."

	<category: 'accessing'>
	^self at: #outline put: color
    ]

    width [
	"Answer the width with which the outline of the rectangle is drawn."

	<category: 'accessing'>
	^self integerAt: #width
    ]

    width: pixels [
	"Set the width with which the outline of the rectangle is drawn."

	<category: 'accessing'>
	^self integerAt: #width put: pixels
    ]

    itemType [
	<category: 'private'>
	^'rectangle'
    ]
]



BRectangle subclass: BOval [
    
    <comment: '
I can draw ovals (ok, if you''re a mathematic, they''re really ellipses),
or even circles.'>
    <category: 'Graphics-Windows'>

    itemType [
	<category: 'private'>
	^'oval'
    ]
]



BOval subclass: BArc [
    
    <comment: '
I can draw arcs, pie slices (don''t eat them!!), chords, and... nothing more.'>
    <category: 'Graphics-Windows'>

    endAngle [
	"Answer the ending of the angular range that is occupied by the arc,
	 expressed in degrees"

	<category: 'accessing'>
	^self startAngle + self sweepAngle
    ]

    endAngle: angle [
	"Set the ending of the angular range that is occupied by the arc,
	 expressed in degrees"

	<category: 'accessing'>
	^self sweepAngle: angle - self startAngle
    ]

    fillChord [
	"Specify that the arc will be filled by painting an area delimited
	 by the arc and the chord that joins the arc's endpoints."

	<category: 'accessing'>
	self at: #style put: 'chord'
    ]

    fillSlice [
	"Specify that the arc will be filled by painting an area delimited
	 by the arc and the two radii joins the center of the arc with
	 each of the endpoints (that is, that a pie slice will be drawn)."

	<category: 'accessing'>
	self at: #style put: 'pieslice'
    ]

    from [
	"Answer the starting point of the arc in cartesian coordinates"

	<category: 'accessing'>
	| startAngle |
	startAngle := self startAngle degreesToRadians.
	^self extent * (startAngle cos @ startAngle sin) / 2 + self center
    ]

    from: aPoint [
	"Set the starting point of the arc in cartesian coordinates"

	<category: 'accessing'>
	self 
	    startAngle: ((aPoint - self center) / self extent) arcTan radiansToDegrees
    ]

    from: start to: end [
	"Set the two starting points of the arc in cartesian coordinates"

	<category: 'accessing'>
	self
	    from: start;
	    to: end
    ]

    startAngle [
	"Answer the beginning of the angular range that is occupied by the arc,
	 expressed in degrees"

	<category: 'accessing'>
	^self integerAt: #start
    ]

    startAngle: angle [
	"Set the beginning of the angular range that is occupied by the arc,
	 expressed in degrees"

	<category: 'accessing'>
	self integerAt: #start put: angle
    ]

    sweepAngle [
	"Answer the size of the angular range that is occupied by the arc,
	 expressed in degrees"

	<category: 'accessing'>
	^self integerAt: #extent
    ]

    sweepAngle: angle [
	"Set the size of the angular range that is occupied by the arc,
	 expressed in degrees"

	<category: 'accessing'>
	self integerAt: #extent put: angle
    ]

    to [
	"Answer the ending point of the arc in cartesian coordinates"

	<category: 'accessing'>
	| endAngle |
	endAngle := self endAngle degreesToRadians.
	^self extent * (endAngle cos @ endAngle sin) / 2 + self center
    ]

    to: aPoint [
	"Set the ending point of the arc in cartesian coordinates"

	<category: 'accessing'>
	self 
	    endAngle: ((aPoint - self center) / self extent) arcTan radiansToDegrees
    ]

    initializeWithProperties: aDictionary [
	<category: 'private'>
	super initializeWithProperties: aDictionary.
	self properties at: #style ifAbsentPut: ['arc']
    ]

    itemType [
	<category: 'private'>
	^'arc'
    ]
]



BCanvasObject subclass: BPolyline [
    | closed points boundingBox |
    
    <comment: '
I can draw closed or open polylines, and even fill them!'>
    <category: 'Graphics-Windows'>

    boundingBox [
	<category: 'accessing'>
	^boundingBox
    ]

    cap [
	"Answer the way in which caps are to be drawn at the endpoints
	 of the line.
	 
	 This option is only available for open polylines.  If you want to
	 set it for a closed polylines, draw an open one on top of it."

	<category: 'accessing'>
	self closed == true 
	    ifTrue: [self error: 'can''t set cap style for closed polylines'].
	^self at: #capstyle
    ]

    cap: aSymbol [
	"Set the way in which caps are to be drawn at the endpoints
	 of the line.  aSymbol may be #butt (the default), #projecting, or
	 #round).
	 
	 This option is only available for open polylines.  If you want to
	 set it for a closed polylines, draw an open one on top of it."

	<category: 'accessing'>
	self closed == true 
	    ifTrue: [self error: 'can''t set cap style for closed polylines'].
	^self at: #capstyle put: aSymbol
    ]

    closed [
	"Answer whether the polyline is an open or a closed one."

	<category: 'accessing'>
	^closed
    ]

    closed: aBoolean [
	"Set whether the polyline is an open or a closed one.  This option
	 may be set only once."

	<category: 'accessing'>
	self closed isNil 
	    ifFalse: [self error: 'you can set the closed style only once'].
	closed := aBoolean
    ]

    join [
	"Answer the way in which joints are to be drawn at the vertices of the
	 line.
	 
	 This option is only available for open polylines.  If you want to
	 set it for a closed polylines, draw an open one on top of it."

	<category: 'accessing'>
	self closed == true 
	    ifTrue: [self error: 'can''t set join style for closed polylines'].
	^self at: #joinstyle
    ]

    join: aSymbol [
	"Answer the way in which joints are to be drawn at the vertices of the
	 line.  aSymbol can be #bevel, #miter (the default) or #round.
	 
	 This option is only available for open polylines.  If you want to
	 set it for a closed polylines, draw an open one on top of it."

	<category: 'accessing'>
	self closed == true 
	    ifTrue: [self error: 'can''t set join style for closed polylines'].
	^self at: #joinstyle put: aSymbol
    ]

    outlineColor [
	"Answer the color with which the outline of the polyline is drawn.
	 This option is only available for closed polylines."

	<category: 'accessing'>
	self closed == true 
	    ifFalse: [self error: 'outline color not defined for open polylines'].
	^self at: #outline
    ]

    outlineColor: color [
	"Set the color with which the outline of the polyline is drawn.
	 This option is only available for closed polylines."

	<category: 'accessing'>
	self closed == true 
	    ifFalse: [self error: 'outline color not defined for open polylines'].
	^self at: #outline put: color
    ]

    points [
	"Answer the points that are vertices of the polyline."

	<category: 'accessing'>
	^points
    ]

    points: arrayOfPointsOrArrays [
	"Set the points that are vertices of the polyline.  Each of the items
	 of arrayOfPointsOrArrays can be a Point or a two-element Array.
	 Note that no changes take place until you invoke the #create (if
	 the object has not been inserted in the canvas yet) or the #redraw
	 method."

	<category: 'accessing'>
	points := arrayOfPointsOrArrays collect: [:each | self makePoint: each].
	boundingBox := Rectangle origin: points anyOne copy
		    corner: points anyOne copy.
	points do: 
		[:each | 
		boundingBox
		    left: (boundingBox left min: each x);
		    top: (boundingBox top min: each y);
		    right: (boundingBox right max: each x);
		    bottom: (boundingBox bottom max: each y)]
    ]

    width [
	"Answer the width with which the polyline (or its outline
	 if it is a closed one) is drawn."

	<category: 'accessing'>
	^self integerAt: #width
    ]

    width: pixels [
	"Set the width with which the polyline (or its outline
	 if it is a closed one) is drawn."

	<category: 'accessing'>
	^self integerAt: #width put: pixels
    ]

    checkValidity [
	<category: 'private'>
	^points notNil
    ]

    itemType [
	<category: 'private'>
	self closed isNil ifTrue: [self closed: false].
	^self closed ifTrue: ['polygon'] ifFalse: ['line']
    ]
]



BPolyline subclass: BSpline [
    | smoothness |
    
    <comment: '
Unlike my father BPolyline, I am more smooth at doing my job.'>
    <category: 'Graphics-Windows'>

    smoothness [
	"Answer the degree of smoothness desired for curves.  Each spline
	 will be approximated with this number of line segments."

	<category: 'accessing'>
	^self integerAt: #splinesteps
    ]

    smoothness: anInteger [
	"Set the degree of smoothness desired for curves.  Each spline
	 will be approximated with this number of line segments."

	<category: 'accessing'>
	^self integerAt: #splinesteps put: anInteger
    ]

    initializeWithProperties: aDictionary [
	<category: 'private'>
	super initializeWithProperties: aDictionary.
	self at: #smooth put: '1'
    ]
]



BBoundingBox subclass: BEmbeddedText [
    | anchor |
    
    <comment: '
I can draw text in all sorts of colors, sizes and fonts.'>
    <category: 'Graphics-Windows'>

    font [
	"Answer the value of the font option for the canvas object.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	^self at: #font
    ]

    font: font [
	"Set the value of the font option for the canvas object.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	^self at: #font put: font
    ]

    justify [
	"Answer how to justify the text within its bounding region."

	<category: 'accessing'>
	^self at: #justify
    ]

    justify: aSymbol [
	"Sets how to justify the text within its bounding region.  Can be
	 #left, #right or #center (the default)."

	<category: 'accessing'>
	aSymbol == #left 
	    ifTrue: 
		[self at: #anchor put: 'w'.
		anchor := #leftCenter].
	aSymbol == #right 
	    ifTrue: 
		[self at: #anchor put: 'e'.
		anchor := #rightCenter].
	aSymbol == #center 
	    ifTrue: 
		[self at: #anchor put: 'center'.
		anchor := #center].
	self at: #justify put: aSymbol.
	self redraw.
	^aSymbol
    ]

    redraw [
	"Force the object to be displayed in the parent canvas, creating
	 it if it has not been inserted for real in the parent, and refresh
	 its position."

	<category: 'accessing'>
	self at: #width
	    put: (self corner x - self origin x) abs asInteger printString.
	super redraw
    ]

    text [
	"Answer the text that is printed by the object"

	<category: 'accessing'>
	^self at: #text
    ]

    text: aString [
	"Set the text that is printed by the object"

	<category: 'accessing'>
	^self at: #text put: aString
    ]

    itemType [
	<category: 'private'>
	^'text'
    ]

    points [
	"Answer a single point around which the text is positioned.  Vertically,
	 the text is centered on the point.  Horizontally, the point can give the
	 leftmost, rightmost or center coordinate depending on the setting of #justify."

	<category: 'private'>
	| anchorPoint |
	anchor isNil ifTrue: [anchor := #center].
	anchorPoint := self boundingBox perform: anchor.
	^Array with: anchorPoint
    ]

    postCopy [
	"Set the anchor variable"

	<category: 'private'>
	self justify: self justify
    ]
]



BBoundingBox subclass: BEmbeddedImage [
    | imageChanged data shared |
    
    <comment: 'I can draw a colorful image inside the canvas.'>
    <category: 'Graphics-Windows'>

    copyInto: aBlox [
	"Answer a new BCanvasObject identical to this but displayed
	 into another canvas, newCanvas.  The new instance is not
	 created at the time it is returned."

	<category: 'accessing'>
	shared value: shared + 1.
	^(super copyInto: aBlox)
	    refCount: shared sharedData: data;
	    yourself
    ]

    create [
	<category: 'private'>
	imageChanged := true.
	super create
    ]

    data [
	"Answer the data of the image.  The result will be a String containing
	 image data either as Base-64 encoded GIF data, as XPM data, or as PPM data."

	<category: 'accessing'>
	^data
    ]

    data: aString [
	"Set the data of the image.  aString may contain the data either
	 as Base-64 encoded GIF data, as XPM data, or as PPM data.  No changes
	 are visible until you toggle a redraw using the appropriate method."

	<category: 'accessing'>
	(shared isNil or: [shared value > 1]) 
	    ifTrue: 
		[self decRefCount.
		shared := ValueHolder with: 1.
		self blox tclEval: 'image create photo'.
		self at: #image put: self blox tclResult].
	data := aString.
	imageChanged := true
    ]

    redraw [
	"Force the object to be displayed in the parent canvas, creating
	 it if it has not been inserted for real in the parent, and refresh
	 its position and image data if it has changed."

	<category: 'accessing'>
	imageChanged ifTrue: [self drawImage].
	super redraw
    ]

    decRefCount [
	<category: 'private'>
	shared value: shared - 1.
	shared value = 0 
	    ifTrue: [self blox tclEval: 'image delete ' , (self at: #image)]
    ]

    destroyed [
	<category: 'private'>
	self decRefCount.
	super destroyed
    ]

    drawImage [
	<category: 'private'>
	shared isNil ifTrue: [^self].
	self blox tclEval: (self at: #image) , ' blank'.
	data isNil ifTrue: [^self].
	imageChanged := false.
	self blox 
	    tclEval: (self at: #image) , ' configure -data ' , data asTkImageString
    ]

    itemType [
	<category: 'private'>
	^'image'
    ]

    points [
	<category: 'private'>
	^Array with: self boundingBox center
    ]

    refCount: rc sharedData: dataString [
	<category: 'private'>
	data := dataString.
	shared := rc
    ]
]



"-------------------------- BCanvas class -----------------------------"



"-------------------------- BScrolledCanvas class -----------------------------"



"-------------------------- BCanvasObject class -----------------------------"



"-------------------------- BBoundingBox class -----------------------------"



"-------------------------- BLine class -----------------------------"



"-------------------------- BRectangle class -----------------------------"



"-------------------------- BOval class -----------------------------"



"-------------------------- BArc class -----------------------------"



"-------------------------- BPolyline class -----------------------------"



"-------------------------- BSpline class -----------------------------"



"-------------------------- BEmbeddedText class -----------------------------"



"-------------------------- BEmbeddedImage class -----------------------------"

