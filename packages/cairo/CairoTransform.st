"======================================================================
|
|   Compositional transformation classes using CairoMatrix
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

CStruct subclass: CairoMatrix [
    <declaration: #(
      (#xx #double)
      (#yx #double)
      (#xy #double)
      (#yy #double)
      (#x0 #double)
      (#y0 #double))>

    <category: 'Cairo-C interface'>

    initIdentity [
	<category: 'initialize'>
        Cairo matrixInitIdentity: self.
    ]

    withPoint: aPoint do: block [
	<category: 'using'>
	^block
	    value: self 
	    value: (CDouble gcValue: aPoint x)
	    value: (CDouble gcValue: aPoint y)
    ]

    copy [
	<category: 'copying'>
        | shiny |
        shiny := CairoMatrix gcNew.
        Cairo matrixInit: shiny 
	      xx: self xx value
	      yx: self yx value
	      xy: self xy value
	      yy: self yy value
	      x0: self x0 value
	      y0: self y0 value.
        ^ shiny
    ]
]


Object subclass: TransformVisitor [
    rotateBy: rads [
	"Visitor method for rotation by aPoint."

	<category: 'visiting'>
	self subclassResponsibility
    ]

    scaleBy: aPoint [
	"Visitor method for scaling by aPoint."

	<category: 'visiting'>
	self subclassResponsibility
    ]

    transformByMatrix: aMatrixTransform [
	"Visitor method for transforms by an arbitrary matrix."

	<category: 'visiting'>
	self subclassResponsibility
    ]

    translateBy: aPoint [
	"Visitor method for translations by aPoint."

	<category: 'visiting'>
	self subclassResponsibility
    ]

]

Object subclass: Transform [
    | matrix |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'A note on transforms: to be compositional, the most
straight-forward thing is to always use a transformation matrix.  However,
a lot of the time, we''ll be doing just one kind of transformation;
e.g., a scale, or a translation.  Further, we may only ever modify a
transformation in one way, like translating a translation.  For this
reason, we specialise for each of the translations and provide a generic
matrix implementation for composing heterogeneous transformations.'>

    Transform class >> new [
	"Return an instance of the receiver representing the identity
	 transform."

	<category: 'instance creation'>
	^ super new initialize
    ]

    Transform class >> identity [
        "Return the identity transform, that leaves its visitor
        unchanged."

	<category: 'instance creation'>
        ^ IdentityTransform instance
    ]

    Transform class >> sequence: transforms [
        "Return a compound transform, that transforms its visitor by
        each of the Transforms in transforms in first-to-last order."

	<category: 'instance creation'>
	transforms isEmpty ifTrue: [ ^self identity ].
        ^ transforms fold: [:acc :xform | xform after: acc]
    ]

    initialize [
	"Overridden by subclasses so that the resulting object represents
	 the identity transform."
	<category: 'initializing'>
    ]

    before: aTransform [
        "Return a new Transform that transforms transform by self
         first, then by aTransform."

	<category: 'composing'>
        ^ aTransform after: self.
    ]

    accept: aVisitor [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
        self subclassResponsibility
    ]

    after: transform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
        self subclassResponsibility
    ]

    about: aPoint [
	"Return the transformation described by the receiver, performed
	 about aPoint rather than about 0@0."

	<category: 'composing'>
        ^ ((Translation by: aPoint)
              before: self) before: (Translation by: aPoint * -1)
    ]

    translateBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
        ^ self asMatrixTransform translateBy: aPoint.
    ]

    scaleBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
        ^ self asMatrixTransform scaleBy: aPoint.
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
        ^ self asMatrixTransform rotateBy: rads.
    ]

    nullTransform [
	"Return the transformation described by the receiver, composed
	 with the identity transform."

	<category: 'composing'>
	^ self
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        self subclassResponsibility
    ]

    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        self subclassResponsibility
    ]

    asMatrixTransform [
	"Answer the receiver converted to a generic matrix-based
	 transformation."

	<category: 'converting'>
	self subclassResponsibility
    ]

    transformBounds: rect [
        "Transform the given bounds. Note this is distinct from
         transforming a rectangle, since bounds must be aligned with
         the axes."

	<category: 'applying'>
        | corners |
        corners := {self transformPoint: rect topLeft.
		    self transformPoint: rect topRight.
		    self transformPoint: rect bottomLeft.
		    self transformPoint: rect bottomRight}.
        ^ (corners fold: [ :left :right | left min: right ]) corner:
            (corners fold: [ :left :right | left max: right ])
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ self subclassResponsibility
    ]

    scale [
	"Return the scale factor applied by the receiver."

	<category: 'accessing'>
	^ (1@1)
     ]
    
    rotation [
	"Return the rotation applied by the receiver, in radians."

	<category: 'accessing'>
	^ 0
    ]

    translation [
	"Return the translation applied by the receiver."

	<category: 'accessing'>
	^ (0@0)
    ]
		      
    translateTo: aPoint [
	"Return a version of the receiver that translates 0@0 to aPoint."

	<category: 'composing'>
	^ self translateBy: (aPoint - self translation).
    ]
    
    scaleTo: sxsy [
	"Return a version of the receiver that scales the distance 1@1 to
	 sxsy."

	<category: 'composing'>
	^ self scaleBy: sxsy asPoint / self scale
    ]

    rotateTo: rads [
	"Return a version of the receiver that rotates by rads."

	<category: 'composing'>
	^ self rotateBy: (rads - self rotation)
    ]
]

Transform subclass: MatrixTransform [
    | matrix |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent transforms using a matrix, in the most generic way.'>
    asMatrixTransform [
	"Return the receiver, since it is already a MatrixTransform."

	<category: 'converting'>
	^self
    ]

    matrix [
	<category: 'private-accessing'>
	^ matrix
    ]

    postCopy [
	<category: 'private-copying'>
        matrix := matrix copy.
    ]

    copyOp: aBlock [
	<category: 'private-composing'>
	| newMatrix |
	newMatrix := self copy.
	aBlock value: newMatrix matrix.
	^newMatrix
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initialize'>
        matrix := CairoMatrix gcNew initIdentity.
    ]

    accept: aVisitor [
        "Sends #transformByMatrix:."

	<category: 'double dispatch'>
	^aVisitor transformByMatrix: self
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform asMatrixTransform
	    copyOp: [:n | Cairo matrixMultiply: n a: n b: self matrix]
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
	^ self copyOp: [:n | Cairo matrixRotate: n radians: rads]
    ]

    scaleBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
	| p |
	p := aPoint asPoint.
	^ self copyOp: [:n | Cairo matrixScale: n sx: p x sy: p y]
    ]

    translateBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
	^ self copyOp: [:n | Cairo matrixTranslate: n tx: aPoint x ty: aPoint y]
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^self matrix withPoint: aPoint do:
            [ :mtx :x :y |
                Cairo matrixTransformPoint: mtx x: x y: y.
                x value @ y value
            ]
    ]

    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^self matrix withPoint: aPoint do:
            [ :mtx :x :y |
                Cairo matrixTransformDistance: mtx dx: x dy: y.
                x value @ y value
            ]
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
	^ self copyOp: [:n | Cairo matrixInvert: n]
    ]

    scale [
	"Return the scale factor applied by the receiver."

	<category: 'accessing'>
	| pt1 pt2 |
	pt1 := self transformDistance: (1@0).
	pt2 := self transformDistance: (0@1).
	^ (pt1 dist: (0@0)) @ (pt2 dist: (0@0))
    ]

    rotation [
	"Return the rotation applied by the receiver, in radians."

	<category: 'accessing'>
	| pt1 pt2 |
	pt1 := self transformDistance: (1@0).
	pt2 := self transformDistance: (0@1).
	^ pt2 arcTan: pt1
    ]

    translation [
	"Return the translation applied by the receiver."

	<category: 'accessing'>
	^ self transformPoint: (0@0)
    ]
]

Transform subclass: AnalyticTransform [
    | matrix |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent transforms using its decomposition into scaling,
rotation and translation.  I am an abstract class.'>
    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^self asMatrixTransform transformPoint: aPoint
    ]

    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^(self transformPoint: aPoint) - self translation
    ]

    asMatrixTransform [
	"Return the transformation described by the receiver, converted
	 to a transformation matrix."

	<category: 'converting'>
        matrix isNil ifTrue: [matrix := self after: MatrixTransform new].
	^matrix
    ]

]

AnalyticTransform subclass: IdentityTransform [

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent the identity transform.'>
    IdentityTransform class [
        | instance |

        instance [
	    instance ifNil: [ instance := self new ].
	    ^instance
        ]
    ]

    accept: aVisitor [
        "Sends #nullTransform."

	<category: 'double dispatch'>
	^aVisitor nullTransform
    ]

    before: aTransform [
        "Return a new Transform that transforms transform by self
         first, then by aTransform."

	<category: 'composing'>
	^ aTransform
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform
    ]

    translateBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
	^ Translation by: aPoint
    ]

    scaleBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
	^ Scale by: aPoint
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
	^ Rotation by: rads
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
	^ aPoint
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
	^ self
    ]
]

AnalyticTransform subclass: Translation [
    | dxdy |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent translations analytically.'>
    Translation class >> by: aPoint [
	"Return an instance of the receiver representing translation by aPoint."
	<category: 'instance creation'>
        ^self basicNew
	    translation: aPoint;
	    yourself
    ]

    translation: aPoint [
	<category: 'private'>
        dxdy := aPoint.
    ]

    translateBy: point [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
        ^ Translation by: (dxdy + point).
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initializing'>
	dxdy := 0@0.
    ]

    accept: aVisitor [
        "Sends #translateBy:."

	<category: 'double dispatch'>
	aVisitor translateBy: dxdy.
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform translateBy: dxdy.
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint + dxdy
    ]
    
    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint
    ]

    transformBounds: rect [
        "Transform the given bounds. This is not distinct from
         transforming a rectangle in the case of translation."

	<category: 'applying'>
        ^ rect translateBy: dxdy
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ Translation by: dxdy * -1
    ]

    translation [
	"Return the translation applied by the receiver."

	<category: 'accessing'>
	^ dxdy
    ]
]

AnalyticTransform subclass: Scale [
    | sxsy |
    
    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent scaling analytically.'>
    Scale class >> by: aPoint [
	"Return an instance of the receiver representing scaling by aPoint."
	<category: 'instance creation'>
        ^self basicNew
	    factors: aPoint asPoint;
	    yourself
    ]

    factors: aPoint [
	<category: 'private'>
        sxsy := aPoint.
    ]

    scaleBy: factors [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
        ^ Scale by: (sxsy * factors)
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initializing'>
	sxsy := 1@1.
    ]

    accept: aVisitor [
        "Sends #scaleBy:."

	<category: 'double dispatch'>
	aVisitor scaleBy: sxsy.
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform scaleBy: sxsy.
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint * sxsy
    ]
    
    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint * sxsy
    ]
    
    transformBounds: rect [
        "Transform the given bounds. This is not distinct from
         transforming a rectangle in the case of scaling."

        ^ rect scaleBy: sxsy
    ]
    
    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ Scale by: (1/sxsy x) @ (1/sxsy y)
    ]

    scale [
	"Return the scale factor applied by the receiver."

	<category: 'accessing'>
	^ sxsy
    ]
]

AnalyticTransform subclass: Rotation [
    | radians |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent rotations analytically.'>
    Rotation class >> by: rads [
	"Return an instance of the receiver representing rotation by rads
	 radians."
	<category: 'instance creation'>
        ^self basicNew
	    radians: rads;
	    yourself
    ]

    radians: aDouble [
	<category: 'private'>
        radians := aDouble.
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
        ^ Rotation by: radians + rads.
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initializing'>
	radians := 0.
    ]

    accept: aVisitor [
        "Sends #rotateBy:."

	<category: 'double dispatch'>
	aVisitor rotateBy: radians.
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform rotateBy: radians.
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ Rotation by: -1 * radians
    ]

    rotation [
	"Return the rotation applied by the receiver, in radians."

	<category: 'accessing'>
	^ radians
    ]
]
