"======================================================================
|
|   CairoContext wrapper class for libcairo
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
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
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: CairoContextProvider [
    <comment: 'I provide the means to obtain a CairoContext.'>

    withContextDo: aBlock [
	<category: 'drawing'>
	self subclassResponsibility
    ]
]

CairoContextProvider subclass: CairoContext [
    | surface context depth |

    <comment: 'I provide the means to draw on a CairoSurface.'>

    CairoContext class >> context: aCObject [
	"Creates a new context pointing to the given C cairo_t pointer."

	<category: 'instance creation'>
	^ self new initializeContext: aCObject
    ]

    CairoContext class >> on: aCairoSurface [
	"Creates a new context with all graphics state parameters set
	 to default values and with target as a target surface."

	<category: 'instance creation'>
	^ self new initialize: aCairoSurface
    ]

    initializeContext: aCObject [
	<category: 'private'>
	context := aCObject.
	depth := 0.
	self addToBeFinalized
    ]

    initialize: aCairoSurface [
	<category: 'private'>
	surface := aCairoSurface.
	depth := 0.
	surface addDependent: self.
	self rebuildContext.
    ]

    rebuildContext [
	<category: 'private-persistence'>
	surface isNil ifFalse: [
	    context := Cairo create: surface cairoSurface.
	    self addToBeFinalized].
    ]

    update: aspect [
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    ^self rebuildContext].
    ]

    finalize [
	<category: 'private-persistence'>
	context ifNil: [ ^self ].
	Cairo destroy: context.
	context := nil.
	surface removeDependent: self.
	surface := nil.
    ]

    release [
	<category: 'private-persistence'>
	self finalize.
	self removeToBeFinalized.
	super release.
    ]

    restore [
	<category: 'drawing'>
	"Restore the context to a state saved by a preceding call to #save,
	 and removes that state from the stack of saved states."
	Cairo restore: context.
    ]

    save [
	"Make a copy of the current state and saves it on an internal
	 stack of saved states."

	<category: 'drawing'>
	Cairo save: context.
    ]

    withContextDo: aBlock [
	"Execute aBlock without modifying the current state.  Provided
	 for polymorphism with CairoSurface."

	<category: 'drawing-handy API'>
	Cairo save: context.
	^[aBlock value: self] ensure: [ Cairo restore: context ].
    ]
	
    saveWhile: aBlock [
	"Execute aBlock without modifying the current state."
	<category: 'drawing-handy API'>
	Cairo save: context.
	^ aBlock ensure: [ Cairo restore: context ].
    ]

    withSource: aPatternOrBlock do: paintBlock [
	<category: 'drawing-handy API'>
	"Execute paintBlock while the current source is set to aPatternOrBlock.
	 If aPatternOrBlock is a BlockClosure, the result of performing the
	 drawing commands in aPatternOrBlock is used as a pattern."
	aPatternOrBlock on: context withSourceDo: paintBlock
    ]

    source: aPatternOrBlock [
	"Set the source pattern to a CairoPattern or, if aPatternOrBlock is a
	 BlockClosure, to the result of performing the drawing commands in
	 aPatternOrBlock."

	<category: 'accessing'>
	aPatternOrBlock setSourceOn: context
    ]

    sourceRed: r green: g blue: b [
	"Set the source pattern to an opaque color."
	<category: 'accessing'>
	Cairo setSourceRgb: context red: r asCNumber green: g asCNumber blue: b asCNumber.
    ]

    sourceRed: r green: g blue: b alpha: a [
	"Set the source pattern to an opaque or translucent color."
	<category: 'accessing'>
	Cairo setSourceRgba: context red: r asCNumber green: g asCNumber blue: b asCNumber alpha: a asCNumber.
    ]

    closePath [
	"Add a line segment to the path from the current point to the
	 beginning of the current sub-path, and closes this sub-path.
	 Leaves the current point will be at the joined endpoint of
	 the sub-path.  When a closed sub-path is stroked, there are no
	 caps on the ends of the sub-path. Instead, there is a line join
	 connecting the final and initial segments of the sub-path. "
	<category: 'paths'>
	Cairo closePath: context.
    ]

    withClosedPath: aBlock do: opsBlock [
	"Using a path consisting of the path commands in aBlock, plus
	 a final #closePath, do the operations in opsBlock.  All of
	 them implicitly preserve the path, which is cleared after
	 opsBlock is evaluated."
	<category: 'paths-handy API'>
	self withPath: [ aBlock value. self closePath ] do: opsBlock
    ]

    addClosedSubPath: aBlock [
	<category: 'paths-handy API'>
	"Adds a new closed sub-path to the current path, described by
	 the path commands in aBlock.  The sub-path starts with no
	 current point set, which is useful when it starts with an arc."
	self newSubPath.
	aBlock value.
	self closePath
    ]

    addSubPath: aBlock [
	<category: 'paths-handy API'>
	"Adds a new sub-path to the current path, described by the path
	 commands in aBlock.  The sub-path starts with no current point
	 set, which is useful when it starts with an arc."
	self newSubPath.
	aBlock value
    ]

    withPath: aBlock do: opsBlock [
	"Using a path consisting of the path commands in aBlock, do
	 the operations in opsBlock.  All of them implicitly preserve
	 the path, which is cleared after opsBlock is evaluated."
	<category: 'paths-handy API'>

	"Cannot yet save a path and go back to it later."
	depth >= 1 ifTrue: [ self notYetImplemented ].
	depth := depth + 1.
	[aBlock value. opsBlock value] ensure: [
	    depth := depth - 1. self newPath]
    ]

    newSubPath [
	"Begin a new sub-path. Note that the existing path is not affected.
	 After this call there will be no current point."
	<category: 'paths'>
	Cairo newSubPath: context.
    ]

    newPath [
	"Clears the current path. After this call there will be no path and
	 no current point."

	<category: 'paths'>
	Cairo newPath: context.
    ]

    moveTo: aPoint [
	"Begin a new sub-path. After this call the current point will
	 be aPoint."

	<category: 'paths'>
	Cairo moveTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relMoveTo: aPoint [
	"Begin a new sub-path. After this call the current point will be
	 offset by aPoint."

	<category: 'paths'>
	Cairo relMoveTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    lineTo: aPoint [
	"Adds a line to the path from the current point to position aPoint
	in user-space coordinates."

	<category: 'paths'>
	Cairo lineTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relLineTo: aPoint [
	"Adds a line to the path from the current point to the point offset
	by aPoint in user-space coordinates."

	<category: 'paths'>
	Cairo relLineTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    curveTo: aPoint3 via: aPoint1 via: aPoint2 [
	"Adds a cubic Bezier spline to the path from the current point to
	 aPoint3 in user-space coordinates, using aPoint1 and aPoint2 as the
	 control points. After this call the current point will be aPoint3. 

	 If there is no current point before the call, the first control
	 point will be used as the starting point."
	<category: 'paths'>
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    curveVia: aPoint1 via: aPoint2 to: aPoint3 [
	"Adds a cubic Bezier spline to the path from the current point to
	 aPoint3 in user-space coordinates, using aPoint1 and aPoint2 as the
	 control points. After this call the current point will be aPoint3. 

	 If there is no current point before the call, the first control
	 point will be used as the starting point."
	<category: 'paths'>
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    arc: aPoint radius: r from: angle1 to: angle2 [
	"Adds a circular arc of the given radius to the current path. The
	arc is centered at aPoint, begins at angle1 and proceeds in
	the direction of increasing angles to end at angle2. If angle2
	is less than angle1 it will be progressively increased by 2*PI
	until it is greater than angle1.

	If there is a current point, an initial line segment will be
	added to the path to connect the current point to the beginning
	of the arc."
	<category: 'paths'>
	Cairo arc: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    arcNegative: aPoint radius: r from: angle1 to: angle2 [
	"Adds a circular arc of the given radius to the current path. The
	arc is centered at aPoint, begins at angle1 and proceeds in
	the direction of decreasing angles to end at angle2. If angle2
	is greater than angle1 it will be progressively decreased by 2*PI
	until it is less than angle1.

	If there is a current point, an initial line segment will be
	added to the path to connect the current point to the beginning
	of the arc."
	<category: 'paths'>
	Cairo arcNegative: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    rectangle: aRect [
	"Adds a closed sub-path rectangle with the given bounding box to the
	 current path."

	<category: 'paths'>
	Cairo rectangle: context
	      x: aRect left asCNumber y: aRect top asCNumber
	      width: aRect width asCNumber height: aRect height asCNumber.
    ]

    groupWhile: aBlock [
	"Set the source pattern to the result of drawing with the commands
	 in aBlock."

	<category: 'drawing-handy API'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    aBlock ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    clipPreserve [
	"Establish a new clip region by intersecting the current clip
	 region with the current path as it would be filled by #fill
	 and according to the current fill rule.  Preserves the path."
	<category: 'drawing'>
	Cairo clipPreserve: context
    ]

    clip [
	"Establish a new clip region by intersecting the current clip
	 region with the current path as it would be filled by #fill
	 and according to the current fill rule.  The current clip region
	 affects all drawing operations by effectively masking out any
	 changes to the surface that are outside the current clip region."
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo clipPreserve: context]
	    ifFalse: [Cairo clip: context]
    ]

    clip: aBlock [
	"Establish a new clip region by intersecting the current clip
	 region with the path obtained by drawing the path commands
	 in aBlock."
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self clip ]
    ]

    resetClip [
	"Reset the current clip region to its original, unrestricted state."
	<category: 'drawing'>
        Cairo resetClip: context.
    ]

    mask: aPatternOrBlock [
	"Paints the current source using the alpha channel of aPatternOrBlock
	 as a mask.  Opaque areas of the pattern are painted with the source,
	 transparent areas are not painted."
	<category: 'drawing'>
        aPatternOrBlock maskOn: context
    ]

    paint [
	"Paint the current source everywhere within the current clip region."

	<category: 'drawing'>
        Cairo paint: context.
    ]

    paintWith: aPatternOrBlock [
	"Paint the source given by aPatternOrBlock everywhere within the current
	 clip region."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self paint ]
    ]

    paintWithAlpha: a [
	"Paint the current source everywhere within the current clip region,
	 using a mask of constant alpha value."
	<category: 'drawing'>
        Cairo paintWithAlpha: context alpha: a asCNumber.
    ]

    paint: aPatternOrBlock withAlpha: a [
	"Paint the source given by aPatternOrBlock everywhere within the current
	 clip region, using a mask of constant alpha value."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self paintWithAlpha: a ]
    ]

    fillPreserve [
	"Fill the current path according to the current fill rule.  Each
	 sub-path is implicitly closed before being filled.  Leaves the
	 current path untouched."
	<category: 'drawing'>
	Cairo fillPreserve: context
    ]

    fill [
	"Fill the current path according to the current fill rule.  Each
	 sub-path is implicitly closed before being filled."
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo fillPreserve: context]
	    ifFalse: [Cairo fill: context]
    ]

    fill: aBlock [
	"Fill the path obtained by drawing the path commands in aBlock,
	 according to the current fill rule.  Each sub-path is implicitly
	 closed before being filled."
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self fill ]
    ]

    fill: pathBlock with: aPatternOrBlock [
	"Fill the path obtained by drawing the path commands in aBlock,
	 according to the current fill rule, using as the source the pattern
	 in aPatternOrBlock or the result of the drawing commands in it
	 (if it is a block).  Each sub-path is implicitly closed before
	 being filled."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self fill: pathBlock ]
    ]

    fillWith: aPatternOrBlock [
	"Fill the current path according to the current fill rule, using
	 as the source the pattern in aPatternOrBlock or the result of
	 the drawing commands in it (if it is a block).  Each sub-path
	 is implicitly closed before being filled."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self fill ]
    ]

    strokePreserve [
	"Stroke the current path according to the current line width,
	 line join, line cap, and dash settings, without clearing the
	 current path afterwards."
	<category: 'drawing'>
	Cairo strokePreserve: context
    ]

    stroke [
	"Stroke the current path according to the current line width,
	 line join, line cap, and dash settings."
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo strokePreserve: context]
	    ifFalse: [Cairo stroke: context]
    ]

    stroke: aBlock [
	"Stroke the path defined by the path commands in aBlock,
	 according to the current line width, line join, line cap,
	 and dash settings."
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self stroke ]
    ]

    stroke: pathBlock with: aPatternOrBlock [
	"Stroke the path defined by the path commands in aBlock,
	 according to the current line width, line join, line cap,
	 and dash settings.  aPatternOrBlock (or, if it is a block,
	 the result of the drawing commands in it) is used as the
	 source."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self stroke: pathBlock ]
    ]

    strokeWith: aPatternOrBlock [
	"Stroke the current path according to the current line width,
	 line join, line cap, and dash settings.  aPatternOrBlock (or,
	 if it is a block, the result of the drawing commands in it)
	 is used as the source."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self stroke ]
    ]

    identityMatrix [
	"Reset the current transformation matrix (CTM) by setting it
	 equal to the identity matrix. That is, the user-space and
	 device-space axes will be aligned and one user-space unit will
	 transform to one device-space unit."
	<category: 'transform'>
        Cairo identityMatrix: context.
    ]

    translateBy: aPoint [
	"Modifies the current transformation matrix (CTM) by translating
	 the user-space origin by (tx, ty)."
	<category: 'transform'>
	Cairo translate: context tx: aPoint x asCNumber ty: aPoint y asCNumber.
    ]

    scaleBy: aPoint [
	"Modifies the current transformation matrix (CTM) by scaling
	 the X and Y user-space axes by aPoint."
	<category: 'transform'>
	| p |
	p := aPoint asPoint.
        Cairo scale: context sx: p x asCNumber sy: p y asCNumber.
    ]

    rotateBy: rads [
	"Modifies the current transformation matrix (CTM) by rotating
	 the X and Y user-space axes by rads radians."
	<category: 'transform'>
        Cairo rotate: context angle: rads asCNumber.
    ]

    nullTransform [
	"Does nothing to the current transformation matrix (CTM)."
	<category: 'transform-handy API'>
    ]

    transformByMatrix: aTransform [
	"Private - Used for double dispatch."
	<category: 'transform'>
        Cairo transform: context matrix: aTransform matrix.
    ]

    transformBy: aTransform [
	"Modifies the current transformation matrix (CTM) by applying
	 the given Transform object."
	<category: 'transform'>
        aTransform accept: self
    ]

    CairoContext class >> lookupOperatorValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo operatorClear ifTrue: [ ^#clear ].
	anInteger == Cairo operatorSource ifTrue: [ ^#source ].
	anInteger == Cairo operatorOver ifTrue: [ ^#over ].
	anInteger == Cairo operatorIn ifTrue: [ ^#in ].
	anInteger == Cairo operatorOut ifTrue: [ ^#out ].
	anInteger == Cairo operatorAtop ifTrue: [ ^#atop ].
	anInteger == Cairo operatorDest ifTrue: [ ^#dest ].
	anInteger == Cairo operatorDestOver ifTrue: [ ^#destOver ].
	anInteger == Cairo operatorDestIn ifTrue: [ ^#destIn ].
	anInteger == Cairo operatorDestOut ifTrue: [ ^#destOut ].
	anInteger == Cairo operatorDestAtop ifTrue: [ ^#destAtop ].
	anInteger == Cairo operatorXor ifTrue: [ ^#xor ].
	anInteger == Cairo operatorAdd ifTrue: [ ^#add ].
	anInteger == Cairo operatorSaturate ifTrue: [ ^#saturate ].
	self error: 'Unsupported operator value ', anInteger
    ]

    CairoContext class >> lookupLineCapValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo lineCapSquare ifTrue: [ ^#square ].
	anInteger == Cairo lineCapRound ifTrue: [ ^#round ].
	anInteger == Cairo lineCapButt ifTrue: [ ^#butt ].
	self error: 'Unsupported line cap value ', anInteger
    ]

    CairoContext class >> lookupLineJoinValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo lineJoinBevel ifTrue: [ ^#bevel ].
	anInteger == Cairo lineJoinRound ifTrue: [ ^#round ].
	anInteger == Cairo lineJoinMiter ifTrue: [ ^#miter ].
	self error: 'Unsupported line join value ', anInteger
    ]

    CairoContext class >> lookupFillRuleValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo fillRuleEvenOdd ifTrue: [ ^#evenOdd ].
	anInteger == Cairo fillRuleWinding ifTrue: [ ^#winding ].
	self error: 'Unsupported fill rule value ', anInteger
    ]

    CairoContext class >> lookupSlantValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo fontSlantNormal ifTrue: [ ^#normal ].
	anInteger == Cairo fontSlantItalic ifTrue: [ ^#italic ].
	anInteger == Cairo fontSlantOblique ifTrue: [ ^#oblique ].
	self error: 'Unsupported slant value ', anInteger
    ]

    CairoContext class >> lookupOperator: anInteger [
	<category: 'private-accessing'>
	anInteger == #clear ifTrue: [ ^Cairo operatorClear ].
	anInteger == #source ifTrue: [ ^Cairo operatorSource ].
	anInteger == #over ifTrue: [ ^Cairo operatorOver ].
	anInteger == #in ifTrue: [ ^Cairo operatorIn ].
	anInteger == #out ifTrue: [ ^Cairo operatorOut ].
	anInteger == #atop ifTrue: [ ^Cairo operatorAtop ].
	anInteger == #dest ifTrue: [ ^Cairo operatorDest ].
	anInteger == #destOver ifTrue: [ ^Cairo operatorDestOver ].
	anInteger == #destIn ifTrue: [ ^Cairo operatorDestIn ].
	anInteger == #destOut ifTrue: [ ^Cairo operatorDestOut ].
	anInteger == #destAtop ifTrue: [ ^Cairo operatorDestAtop ].
	anInteger == #xor ifTrue: [ ^Cairo operatorXor ].
	anInteger == #add ifTrue: [ ^Cairo operatorAdd ].
	anInteger == #saturate ifTrue: [ ^Cairo operatorSaturate ].
	self error: 'Unsupported operator value ', anInteger
    ]

    CairoContext class >> lookupLineCap: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #square ifTrue: [ ^Cairo lineCapSquare ].
	aSymbol == #round ifTrue: [ ^Cairo lineCapRound ].
	aSymbol == #butt ifTrue: [ ^Cairo lineCapButt ].
	self error: 'Unsupported line cap symbol ', aSymbol
    ]

    CairoContext class >> lookupLineJoin: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #bevel ifTrue: [ ^Cairo lineJoinBevel ].
	aSymbol == #round ifTrue: [ ^Cairo lineJoinRound ].
	aSymbol == #miter ifTrue: [ ^Cairo lineJoinMiter ].
	self error: 'Unsupported line join symbol ', aSymbol
    ]

    CairoContext class >> lookupFillRule: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #evenOdd ifTrue: [ ^Cairo fillRuleEvenOdd ].
	aSymbol == #winding ifTrue: [ ^Cairo fillRuleWinding ].
	self error: 'Unsupported fill rule symbol ', aSymbol
    ]

    CairoContext class >> lookupSlant: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #normal ifTrue: [ ^Cairo fontSlantNormal ].
	aSymbol == #italic ifTrue: [ ^Cairo fontSlantItalic ].
	aSymbol == #oblique ifTrue: [ ^Cairo fontSlantOblique ].
	self error: 'Unsupported slant symbol ', aSymbol
    ]

    CairoContext class >> lookupWeight: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #normal ifTrue: [ ^Cairo fontWeightNormal ].
	aSymbol == #bold ifTrue: [ ^Cairo fontWeightBold ].
	self error: 'Unsupported weight symbol ', aSymbol
    ]

    selectFontFamily: aString slant: slantSymbol weight: weightSymbol [
	"Selects a family and style of font from a simplified description
	 as a family name, slant and weight. Cairo provides no operation
	 to list available family names on the system (the full Cairo API
	 for text is not yet supported), but the standard CSS2 generic
	 family names (serif, sans-serif, cursive, fantasy, monospace),
	 are likely to work as expected."
	<category: 'text'>
	Cairo selectFontFace: context
	      family: aString
	      slant: (self class lookupSlant: slantSymbol)
	      weight: (self class lookupWeight: weightSymbol).
    ]

    lineWidth [
	"Answer the current line width within the cairo context. The line
	 width value specifies the diameter of a pen that is circular in
	 user space."
	<category: 'accessing'>
	^Cairo getLineWidth: context.
    ]

    lineCap [
	"Answer the current line cap style within the cairo context."
	<category: 'accessing'>
	^self class lookupLineCapValue: (Cairo getLineCap: context).
    ]

    fillRule [
	"Answer the current fill rule style within the cairo context.
	 The fill rule is used to determine which regions are inside or
	 outside a complex (potentially self-intersecting) path."
	<category: 'accessing'>
	^self class lookupFillRuleValue: (Cairo getFillRule: context).
    ]

    lineJoin [
	"Answer how cairo will render the junction of two lines when stroking."
	<category: 'accessing'>
	^self class lookupLineJoinValue: (Cairo getLineJoin: context).
    ]

    operator [
	"Set how cairo will composite the destination, source and mask."
	<category: 'accessing'>
	^self class lookupOperatorValue: (Cairo getOperator: context).
    ]

    miterLimit [
	"Answer the miter limit of the cairo context, i.e. the ratio between
	 miter length and line width above which a #miter line join is
	 automatically converted to a bevel.  The limit angle, below which
	 the miter is converted by a bevel, is 2 * arcsin (1 / miterLimit)."
	<category: 'accessing'>
	^Cairo getMiterLimit: context.
    ]

    lineWidth: w [
	"Set the current line width within the cairo context. The line
	 width value specifies the diameter of a pen that is circular in
	 user space."
	<category: 'accessing'>
	Cairo setLineWidth: context width: w asCNumber.
    ]

    lineCap: aSymbol [
	"Set the current line cap style within the cairo context.  aSymbol
	 can be one of #square, #round, #butt."
	<category: 'accessing'>
	Cairo setLineCap: context lineCap: (self class lookupLineCap: aSymbol).
    ]

    fillRule: aSymbol [
	"Set the current fill rule style within the cairo context.  The
	 fill rule can be #winding or #evenOdd, and is used to determine
	 which regions are inside or outside a complex (potentially
	 self-intersecting) path."
	<category: 'accessing'>
	Cairo setFillRule: context fillRule: (self class lookupFillRule: aSymbol).
    ]

    lineJoin: aSymbol [
	"Set how cairo will render the junction of two lines when stroking.
	 aSymbol can be one of #miter, #round, #bevel."
	<category: 'accessing'>
	Cairo setLineJoin: context lineJoin: (self class lookupLineJoin: aSymbol).
    ]

    operator: aSymbol [
	"Set how cairo will composite the destination, source and mask."
	<category: 'accessing'>
	Cairo setOperator: context operator: (self class lookupOperator: aSymbol).
    ]

    miterLimit: aNumber [
	"Answer the miter limit of the cairo context, i.e. the ratio between
	 miter length and line width above which a #miter line join is
	 automatically converted to a bevel.  The miter limit can be computed
	 from a limit angle using the formula 1 / sin (angle / 2)."
	<category: 'accessing'>
	Cairo setMiterLimit: context miterLimit: aNumber asCNumber.
    ]

    fontSize: aNumber [
	"Sets the current font matrix to a scale by a factor
	of size, replacing any font matrix previously set. This results
	in an em-square of size by size user space units."
	<category: 'accessing'>
	Cairo setFontSize: context size: aNumber.
    ]

    showText: aString [
	"Generates and fills the shape from a string of UTF-8 characters,
	 rendered according to the current font face, size and slanting. "
	<category: 'drawing'>
	Cairo showText: context utf8: aString.
    ]

    textPath: aString [
	"Generates a set of closed paths from a string of UTF-8 characters,
	 rendered according to the current font face, size and slanting. "
	<category: 'paths'>
	Cairo textPath: context utf8: aString.
    ]

    textExtents: aString [
	"Gets the extents for a string of text. The extents describe a
	 user-space rectangle that encloses the inked portion of the text.
	 Whitespace characters do not directly contribute to the size of
	 the rectangle, except indirectly by changing the position
	 of subsequent non-whitespace characters.  Trailing whitespace,
	 in particular, affects the advance and not the extent."
	<category: 'text'>
	| ext |
	ext := CairoTextExtents gcNew.
	Cairo textExtents: context utf8: aString extents: ext.
	^TextExtents from: ext
    ]
].

Object subclass: TextExtents [

    <comment: 'I store the extents of a single glyph or a string of
glyphs in user-space coordinates.'>

    | bearing extent advance |

    bearing [
	"Return a Point giving the distance from the origin to the leftmost
	 part of the glyphs as drawn.  Coordinates are positive if the glyphs
	 lie entirely to the right of (resp. below) the origin."
	<category: 'accessing'>
	^bearing
    ]

    extent [
	"Return the width and height of the glyphs as drawn."
	<category: 'accessing'>
	^extent
    ]

    advance [
	"Return the distance to advance after drawing the glyphs.  The Y
	 component will typically be zero except for vertical text layout
	 as found in East-Asian languages."
	<category: 'accessing'>
	^advance
   ]

    TextExtents class >> from: aCairoTextExtents [
	<category: 'private-instance creation'>
	^ self new initializeFrom: aCairoTextExtents
    ]

    initializeFrom: aCairoTextExtents [
	<category: 'private'>
	bearing := aCairoTextExtents xBearing value @ aCairoTextExtents yBearing value.
	extent := aCairoTextExtents width value @ aCairoTextExtents height value.
	advance := aCairoTextExtents xAdvance value @ aCairoTextExtents yAdvance value.
    ]
].
