"======================================================================
|
|   CairoSurface wrapper class for libcairo
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


CairoContextProvider subclass: CairoSurface [
    | surface |

    cairoSurface [
	"Return the CObject for the Cairo surface."

	<category: 'C interface'>
	surface isNil ifTrue: [ self rebuildSurface ].
	^surface
    ]

    update: aspect [
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifFalse: [
	    (SurfacePattern on: self) release ].
	self rebuildSurface.
	aspect == #returnFromSnapshot ifTrue: [
	    self changed: #returnFromSnapshot ].
    ]

    buildSurface [
	"Abstract method to actually create a Cairo surface.
	 Returns the CObject."

	<category: 'C interface'>
	self subclassResponsibility.
    ]

    extent [
	"Return the size of the surface"

	self subclassResponsibility
    ]

    rebuildSurface [
	<category: 'private-persistence'>
	surface := nil.
	surface := self buildSurface.
	self addToBeFinalized.
    ]

    finalize [
	<category: 'private-finalization'>
	self free
    ]

    free [
	<category: 'private-finalization'>
	surface ifNil: [ ^self ].
	Cairo surfaceDestroy: surface.
	surface := nil.
    ]

    release [
	<category: 'private-finalization'>
	self finalize.
	self removeToBeFinalized.
	super release
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  The context is invalidated after aBlock returns."

	<category: 'accessing'>
	| context |
	[ aBlock value: (context := CairoContext on: self) ] ensure: [ 
	    context isNil ifFalse: [ context release ] ]
    ]
]

CairoSurface subclass: CairoOffscreenSurface [
    | extent |

    CairoOffscreenSurface class >> extent: aPoint [
	"Create a new surface with the given size.  Right now it is
	 only possible to create 32-bit color surfaces.

	 The surface is blanked when the Smalltalk image is restarted."
	<category: 'instance creation'>
	^self new extent: aPoint
    ]

    extent [
	"Return the size of the surface"

	<category: 'accessing'>
	^extent
    ]

    extent: aPoint [ extent := aPoint ]
]

CairoOffscreenSurface subclass: CairoImageSurface [
    buildSurface [
	<category: 'C interface'>
	^Cairo imageSurfaceCreate: Cairo formatArgb32 width: extent x height: extent y
    ]

    data [
	<category: 'C interface'>
	^Cairo imageSurfaceGetData: self cairoSurface
    ]
]

CairoOffscreenSurface subclass: CairoFileSurface [
    | filename |

    CairoFileSurface class >> on: aFile with: aSurface [
	"Create a new surface that will save to aFile and whose
	 size and initial content is the same as aSurface's.
         For a subclass of CairoLoadableFileSurface, the
	 content is reset to the content of aFile when
	 the Smalltalk image is restarted.  Otherwise, it
         will be reset to transparent on image restart."

	<category: 'instance creation'>
	^(self extent: aSurface extent)
	    buildSurface;
	    paint: aSurface;
	    filename: aFile asString;
	    yourself
    ]

    CairoFileSurface class >> on: aFile extent: aPoint [
	"Create a new surface that will save to aFile, whose
	 size is aPoint.  The initial content is transparent
         except for subclasses of CairoLoadableFileSurface,
         where it is loaded from aFile.  For loadable surfaces
	 the content is also reset to the content of aFile when
	 the Smalltalk image is restarted, otherwise it will be
         transparent too."

	<category: 'instance creation'>
	^(self extent: aPoint)
	    filename: aFile asString;
	    buildSurface;
	    yourself
    ]

    paint: aSurface [
	"Private - Paint the contents of aSurface on this surface."

	<category: 'private'>
	super withContextDo: [ :context || pattern |
	    context source: (SurfacePattern on: aSurface); paint ]
    ]

    filename [
	"Answer the file from which the bits of the surface are loaded."

	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	"Answer the file to which the bits of the surface are saved."

	<category: 'accessing'>
	filename := aString.
    ]

    saveTo: aContext [
	"Save the contents of the surface to the file specified by
	 #filename."

	<category: 'private-file'>
	self subclassResponbsibility
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  After aBlock returns, the context is invalidated
	 and the content of the surface is saved to the file."

	<category: 'accessing'>
	super withContextDo: [ :ctx |
	    [ aBlock value: ctx ] ensure: [ self saveTo: ctx ] ]
    ]
]

CairoFileSurface subclass: CairoMultiPageSurface [
    saveTo: aContext [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'private-file'>
	Cairo showPage: aContext
    ]
]

CairoFileSurface subclass: CairoPdfSurface [
    buildSurface [
	<category: 'C interface'>
	^Cairo pdfSurfaceCreate: self filename width: extent x height: extent y
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  The extent can be modified just before calling
	 this.  After aBlock returns, the context is invalidated
	 and the content of the surface is saved to the file."

	<category: 'accessing'>
	^Cairo pdfSurfaceSetSize: self cairoSurface width: extent x height: extent y
    ]
].

CairoFileSurface subclass: CairoSvgSurface [
    buildSurface [
	<category: 'C interface'>
	^Cairo svgSurfaceCreate: self filename width: extent x height: extent y
    ]
].

CairoFileSurface subclass: CairoLoadableFileSurface [
    CairoFileSurface class >> on: aFile [
	"Create a new surface that will save to aFile, whose
	 size is aPoint and whose initial content is obtained
	 by loading aFile.  aFile is reloaded on every Smalltalk
	 image load."

	^self new filename: aFile asString
    ]

    buildBlankSurface [
	<category: 'C interface'>
	self subclassResponsibility
    ]

    buildSurface [
	"Try to read the surface from the file if it exists.  Otherwise,
	 create a blank surface whose size must have been given with
	 the superclass constructor method, #extent:."

	<category: 'file'>
	^(filename notNil and: [ filename asFile exists ])
	    ifTrue: [ self buildSurfaceFromFile ]
	    ifFalse: [ self buildBlankSurface ]
    ]

    buildSurfaceFromFile [
	"Load the contents of the surface to the file specified by
	 #filename."

	<category: 'file'>
	self subclassResponbsibility
    ]

    extent [
	"Return the size of the surface.  Requires the file to exist
	 if the size was not supplied at surface creation time."

	extent isNil ifTrue: [
	    self extent: ((Cairo imageSurfaceGetWidth: self cairoSurface) @
			  (Cairo imageSurfaceGetHeight: self cairoSurface)) ].
	^super extent
    ]
]

CairoLoadableFileSurface subclass: CairoPngSurface [
    buildBlankSurface [
	<category: 'C interface'>
	^Cairo imageSurfaceCreate: Cairo formatArgb32 width: extent x height: extent y
    ]

    buildSurfaceFromFile [
	"Try to read the surface from the file if it exists.  Otherwise,
	 create a blank surface whose size must have been given with
	 the superclass constructor method, #extent:."

	<category: 'file'>
	^Cairo imageSurfaceCreateFromPng: filename
    ]

    data [
	<category: 'C interface'>
	^Cairo imageSurfaceGetData: self cairoSurface
    ]

    save [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'file'>
	Cairo surfaceWriteToPng: self cairoSurface filename: filename
    ]

    saveTo: aContext [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'private-file'>
	self save
    ]
].

