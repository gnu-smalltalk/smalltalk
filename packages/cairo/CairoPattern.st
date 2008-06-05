"======================================================================
|
|   CairoPattern wrapper class for libcairo
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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


BlockClosure extend [
    maskOn: context [
	"Private - Used by Cairo to do double-dispatch on #mask:"

	<category: 'cairo double dispatch'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo mask: context pattern: pattern
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    on: context withSourceDo: paintBlock [
	"Private - Used by Cairo to do double-dispatch on #withSource:do:"

	<category: 'cairo double dispatch'>
	| pattern source |
	source := Cairo.Cairo getSource: context.
	Cairo.Cairo patternReference: source.
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo.Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    setSourceOn: context [
	"Private - Used by Cairo to do double-dispatch on #source:"

	<category: 'cairo double dispatch'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]
]

Object subclass: CairoPattern [
    | cachedPattern canonical |

    Patterns := nil.
    CairoPattern class >> initialize [
	"Initialize the dictionary of patterns that have a C
	 representation."

	<category: 'initialize'>
	Patterns := WeakKeyDictionary new.
	ObjectMemory addDependent: self.
    ]

    CairoPattern class >> update: aspect [
	"Clear the dictionary of patterns that have a C
	 representation."

	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    Patterns do: [ :each | each release ].
	    Patterns := WeakKeyDictionary new].
    ]

    cachedPattern [
	"Return the C representation of the pattern."

	<category: 'private-persistence'>
	cachedPattern isNil ifFalse: [ ^cachedPattern ].
	Patterns at: self put: self.
	self addToBeFinalized.
	canonical := self.
	^cachedPattern := self createCachedPattern
    ]

    pattern [
	"Return the C representation of the pattern, looking it up
	 in the Patterns class variable and associating it to the
	 receiver if none is found."

	<category: 'private-persistence'>
	canonical isNil
	    ifTrue: [ canonical := Patterns at: self ifAbsentPut: [ self ] ].

	^canonical cachedPattern
    ]

    createCachedPattern [
	"Private - Create the CObject representing the pattern."

	<category: 'C interface'>
	self subclassResponsibility.
    ]


    postCopy [
	"We reference the same canonical object, but the pattern lives
	 in the canonical object, not in this one."

	<category: 'private-persistence'>
	cachedPattern := nil.
    ]

    finalize [
	<category: 'private-persistence'>
	cachedPattern ifNotNil: [ :p |
	    cachedPattern := nil.
	    Cairo patternDestroy: p ].
    ]
	
    release [
	<category: 'private-persistence'>
	super release.
	canonical isNil ifTrue: [
	    canonical := Patterns at: self ifAbsent: [nil].
	    canonical isNil ifTrue: [ ^self ]].
	canonical == self
	    ifFalse: [ canonical release ]
	    ifTrue: [
		Patterns removeKey: self ifAbsent: [].
		self finalize.
		self removeToBeFinalized ].

	canonical := nil.
    ]

    maskOn: context [
	"Private - Used by Cairo to do double-dispatch on #mask:"

	<category: 'cairo double dispatch'>
	Cairo.Cairo mask: context pattern: self pattern
    ]

    setSourceOn: context [
	"Private - Used by Cairo to do double-dispatch on #source:"

	<category: 'cairo double dispatch'>
	Cairo setSource: context source: self pattern
    ]

    on: context withSourceDo: paintBlock [
	"Private - Used by Cairo to do double-dispatch on #withSource:do:"

	<category: 'cairo double dispatch'>
	| pattern source |
	source := Cairo getSource: context.
	Cairo patternReference: source.
	[
	    self setSourceOn: context.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	].
    ]
].

CairoPattern subclass: CairoPatternDecorator [
    | wrappedPattern |
    CairoPatternDecorator class >> on: aPattern [
	<category: 'instance creation'>
	^self new wrappedPattern: aPattern; yourself
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self wrappedPattern = anObject wrappedPattern ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self wrappedPattern hash
    ]

    wrappedPattern [
	<category: 'accessing'>
	^wrappedPattern
    ]

    wrappedPattern: aPattern [
	<category: 'private-accessing'>
	wrappedPattern := aPattern
    ]
]

CairoPatternDecorator subclass: ReflectedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendReflect.
	^result
    ]
]

CairoPatternDecorator subclass: RepeatedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendRepeat.
	^result
    ]
]

CairoPatternDecorator subclass: PaddedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendPad.
	^result
    ]
]

CairoPattern subclass: SurfacePattern [
    | surface |

    SurfacePattern class >> on: aSurface [
	<category: 'instance creation'>
	^self new surface: aSurface; yourself
    ]

    surface [
	<category: 'accessing'>
	^ surface
    ]

    surface: aCairoSurface [
	<category: 'private-accessing'>
	surface := aCairoSurface
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self surface = anObject surface ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self surface hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	^ Cairo patternCreateForSurface: surface cairoSurface
    ]
].

CairoPattern subclass: GradientPattern [
    | colorStops |

    GradientPattern class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    colorStops [
	<category: 'accessing'>
	^colorStops
    ]

    initialize [
	<category: 'initialize'>
	colorStops := OrderedCollection new.
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self colorStops = anObject colorStops ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self colorStops hash
    ]

    addStopAt: aNumber color: aColor [
	<category: 'accessing'>
	colorStops add: aNumber -> aColor.
    ]

    addStopAt: aNumber red: r green: g blue: b alpha: a [
	<category: 'accessing'>
	colorStops add: aNumber -> (Color r: r g: g blue: b a: a).
    ]

    initializeCachedPattern: p [
	<category: 'private'>
	| c |
	colorStops do: [ :stop |
	    c := stop value.
	    Cairo patternAddColorStopRgba: p
		  offset: stop key asCNumber
		  red: c red asCNumber
		  green: c green asCNumber
		  blue: c blue asCNumber
		  alpha: c alpha asCNumber ].
    ]
].

GradientPattern subclass: LinearGradient [
    | point0 point1 |

    LinearGradient class >> from: point0 to: point1 [
	<category: 'instance creation'>
	^ self new
	    from: point0 to: point1;
	    yourself
    ]

    from [
	<category: 'accessing'>
	^point0
    ]

    to [
	<category: 'accessing'>
	^point1
    ]

    from: aPoint0 to: aPoint1 [
	<category: 'private-accessing'>
	point0 := aPoint0.
	point1 := aPoint1.
    ]

    = anObject [
	<category: 'basic'>
	^super = anObject and: [
	    point0 = anObject from and: [
	    point1 = anObject to ]]
    ]

    hash [
	<category: 'basic'>
	^(super hash bitXor: point0 hash) bitXor: point1 hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	| p c |
	p := Cairo patternCreateLinear: point0 x asCNumber
		   y0: point0 y asCNumber
		   x1: point1 x asCNumber
		   y1: point1 y asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

GradientPattern subclass: RadialGradient [
    | point0 r0 point1 r1 |

    RadialGradient class >> from: point0 radius: r0 to: point1 radius: r1 [
	<category: 'instance creation'>
	^ self new
	    from: point0 radius: r0 to: point1 radius: r1;
	    yourself
    ]

    from [
	<category: 'accessing'>
	^point0
    ]

    fromRadius [
	<category: 'accessing'>
	^r0
    ]

    to [
	<category: 'accessing'>
	^point1
    ]

    toRadius [
	<category: 'accessing'>
	^r1
    ]

    from: aPoint0 radius: aR0 to: aPoint1 radius: aR1 [
	<category: 'private-accessing'>
	point0 := aPoint0.
	r0 := aR0.
	point1 := aPoint1.
	r1 := aR1.
    ]

    = anObject [
	<category: 'basic'>
	^super = anObject and: [
	    point0 = anObject from and: [
	    r0 = anObject fromRadius and: [
	    point1 = anObject to and: [
	    r1 = anObject toRadius ]]]]
    ]

    hash [
	<category: 'basic'>
	^(((super hash bitXor: point0 hash) bitXor: point1 hash)
	     bitXor: r0 hash) bitXor: r1 hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	| p c |
	p := Cairo patternCreateRadial: point0 x asCNumber
		   cy0: point0 y asCNumber
		   radius0: r0 asCNumber
		   cx1: point1 x asCNumber
		   cy1: point1 y asCNumber
		   radius1: r1 asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

CairoPattern subclass: Color [
    | red green blue alpha |

    Color >> new [
	<category: 'instance creation'>
	^self new r: 0 g: 0 b: 0 a: 1.
    ]

    Color class >> r: r g: g b: b [
	<category: 'instance creation'>
	^ self basicNew r: r g: g b: b a: 1.0.
    ]

    Color class >> r: r g: g b: b a: a [
	<category: 'instance creation'>
	^ self basicNew r: r g: g b: b a: a.
    ]

    Color class >> black [
	<category: 'instance creation'>
	^ self r: 0 g: 0 b: 0
    ]

    Color class >> white [
	<category: 'instance creation'>
	^ self r: 1 g: 1 b: 1
    ]

    Color class >> red [
	<category: 'instance creation'>
	^ self r: 1 g: 0 b: 0
    ]

    Color class >> green [
	<category: 'instance creation'>
	^ self r: 0 g: 1 b: 0
    ]

    Color class >> blue [
	<category: 'instance creation'>
	^ self r: 0 g: 0 b: 1
    ]

    Color class >> cyan [
	<category: 'instance creation'>
	^ self r: 0 g: 1 b: 1
    ]

    Color class >> magenta [
	<category: 'instance creation'>
	^ self r: 1 g: 0 b: 1
    ]

    Color class >> yellow [
	<category: 'instance creation'>
	^ self r: 1 g: 1 b: 0
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    red = anObject red and: [
	    green = anObject green and: [
	    blue = anObject blue and: [
	    alpha = anObject alpha]]]]
    ]

    hash [
	<category: 'basic'>
	^(red * 255) truncated +
	 ((green * 255) truncated * 256) +
	 ((blue * 255) truncated * 65536) +
	 ((alpha * 63) truncated * 16777216)
    ]
	 
    red [
	<category: 'accesing'>
	^red
    ]

    green [
	<category: 'accesing'>
	^green
    ]

    blue [
	<category: 'accesing'>
	^blue
    ]

    alpha [
	<category: 'accesing'>
	^alpha
    ]

    r: r g: g b: b a: a [
	<category: 'private-accesing'>
	red := r.
	green := g.
	blue := b.
	alpha := a.
    ]

    withRed: aNumber [
	<category: 'instance creation'>
	^ Color r: aNumber g: green b: blue a: alpha
    ]

    withGreen: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: aNumber b: blue a: alpha
    ]

    withBlue: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: green b: aNumber a: alpha
    ]

    withAlpha: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: green b: blue a: aNumber
    ]

    mix: aColor ratio: aScale [
	<category: 'mixing'>
	^Color r: ((red * aScale) + (aColor red * (1 - aScale)))
		g: ((green * aScale) + (aColor green * (1 - aScale)))
		b: ((blue * aScale) + (aColor blue * (1 - aScale)))
		a: ((alpha * aScale) + (aColor alpha * (1 - aScale)))
    ]

    * aScale [
	<category: 'mixing'>
	aScale isNumber ifTrue: [
	    ^ Color r: ((red * aScale) min: 1)
		    g: ((green * aScale) min: 1)
		    b: ((blue * aScale) min: 1)
		    a: alpha ].
	^ Color r: red * aScale red
		g: green * aScale green
		b: blue * aScale blue
		a: alpha * aScale alpha
    ]

    createCachedPattern [
	<category: 'C interface'>

	^ Cairo patternCreateRgba: red asCNumber
		green: green asCNumber
		blue: blue asCNumber
		alpha: alpha asCNumber.
    ]

    printOn: st [
	<category: 'printing'>

	st << 'Color r: ' << red << ' g: ' << green << ' b: ' << blue << ' a: ' << alpha.
    ]

    storeOn: st [
	<category: 'printing'>

	st << $(.
	self printOn: st.
	st << $)
    ]

    setSourceOn: context [
	"Private - Used by Cairo to do double-dispatch on #source:"

	<category: 'cairo double dispatch'>
	Cairo
	    setSourceRgba: context
	    red: red asCNumber
	    green: green asCNumber
	    blue: blue asCNumber
	    alpha: alpha asCNumber.
    ]
].

Eval [
    CairoPattern initialize
]
