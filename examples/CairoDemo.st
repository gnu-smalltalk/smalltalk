"======================================================================
|
|   Blitting example using Cairo and SDL
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


PackageLoader fileInPackage: #CairoSDL.
PackageLoader fileInPackage: #'LibSDL_GL'.

SDL.SdlEventHandler subclass: CairoDemo [
    | context surface |

    <import: SDL>
    <import: Cairo>

    context [ ^context ]

    samples [
        ^#(#arc #arcNegative #clip #curveRectangle #curveTo #gradient
	   #fillStroke #fillRule #png)
    ]

    arcNegative [
        | ang1 ang2 |
	ang1 := 45 degreesToRadians.
	ang2 := 180 degreesToRadians.
        context
	    lineWidth: 10;
	    stroke: [ context arcNegative: 128@128 radius: 100 from: ang1 to: ang2 ];

	    paint: [
	       context
	       	    lineWidth: 6;
		    sourceRed: 1 green: 0.2 blue: 0.2 alpha: 1.0;
		    fill: [ context arc: 128@128 radius: 10 from: 0 to: Float pi * 2 ];
		    stroke: [
		        context
			   arc: 128@128 radius: 100 from: ang1 to: ang1;
			   lineTo: 128@128;
			   arc: 128@128 radius: 100 from: ang2 to: ang2;
			   lineTo: 128@128 ]]
		withAlpha: 0.64
    ]

    arc [
        | ang1 ang2 |
	ang1 := 45 degreesToRadians.
	ang2 := 180 degreesToRadians.
        context
	    lineWidth: 10;
	    stroke: [ context arc: 128@128 radius: 100 from: ang1 to: ang2 ];

	    sourceRed: 1 green: 0.2 blue: 0.2 alpha: 0.6;
	    lineWidth: 6;
	    fill: [ context arc: 128@128 radius: 10 from: 0 to: Float pi * 2 ];
	    stroke: [
	        context
		   arc: 128@128 radius: 100 from: ang1 to: ang1;
		   lineTo: 128@128;
		   arc: 128@128 radius: 100 from: ang2 to: ang2;
		   lineTo: 128@128 ]
    ]

    clip [
        context
	    clip: [ context arc: 128@128 radius: 77 from: 0 to: Float pi * 2 ];
	    fill: [ context rectangle: (0@0 extent: 256@256) ];
	    lineWidth: 10;
	    stroke: [
	        context
		    moveTo: 0@0;
		    lineTo: 256@256;
		    moveTo: 256@0;
		    lineTo: 0@256 ]
	        with: Color green
    ]
    
    curveRectangle [
	| x0 x1 y0 y1 mx0 mx1 my0 my1 |
	x0 := y0 := 25.6.
	x1 := y1 := 256 - x0.
	mx0 := x0 + 52.4.
	mx1 := x1 - 52.4.
	my0 := y0 + 52.4.
	my1 := y1 - 52.4.
	context
	    withClosedPath: [
		context
		    moveTo: x0@my0;
		    curveTo: mx0@y0 via: x0@y0 via: mx0@y0;
		    lineTo: mx1@y0;
		    curveTo: x1@my0 via: x1@y0 via: x1@my0;
		    lineTo: x1@my1;
		    curveTo: mx1@y1 via: x1@y1 via: mx1@y1;
		    lineTo: mx0@y1;
		    curveTo: x0@my1 via: x0@y1 via: x0@my1 ]
	    do: [
		context
		    fillWith: (Color r: 0.5 g: 0.5 b: 1);
		    lineWidth: 10;
		    strokeWith: (Color r: 0.5 g: 0 b: 0 a: 0.5) ]
    ]
    
    curveTo [
        | p0 p1 p2 p3 |
	p0 := 25.6@128.
	p1 := 102.4@230.4.
	p2 := 153.6@25.6.
	p3 := 230.4@128.
        context
	    lineWidth: 10;
	    stroke: [ context moveTo: p0; curveTo: p3 via: p1 via: p2 ];

	    lineWidth: 6;
	    stroke: [ context moveTo: p0; lineTo: p1; moveTo: p2; lineTo: p3 ]
	        with: (Color r: 1 g: 0.2 b: 0.2 a: 0.6)
    ]
    
    fillStroke [
	context withPath: [
	    context
		addClosedSubPath: [
		    context
		        moveTo: 128@25.6;
		        lineTo: 230.4@230.4;
		        relLineTo: -102.4@0;
		        curveVia: 51.2@230.4 via: 51.2@128 to: 128@128 ];
		addClosedSubPath: [
		    context
			moveTo: 64.0@25.6;
			relLineTo: 51.2@51.2;
			relLineTo: -51.2@51.2;
			relLineTo: -51.2 @ -51.2 ]]
	    do: [
		context
		    lineWidth: 10;
		    fillWith: Color blue;
		    strokeWith: Color black ]
    ]

    png [
	| png scale translate surf |
	(File exists: 'demo.png') ifFalse: [ ^self ].
	png := CairoPngSurface on: 'demo.png'.
	scale := 256.0 / (png extent x max: png extent y).
	translate := 128@128 - (png extent / 2 * scale).
	context
	    translateBy: translate;
	    scaleBy: scale;
	    paintWith: (surf := SurfacePattern on: png).

	surf release.
	png release
    ]
	
    fillRule [
	| path |
	path := [
	    context rectangle: (12@12 extent: 232@70).
	    context addSubPath: [
		context arc: 64@64 radius: 40 from: 0 to: 2 * Float pi ].
	    context addSubPath: [
		context arcNegative: 192@64 radius: 40 from: 0 to: -2 * Float pi ]].

	context lineWidth: 6.

	context
	    withPath: path
	    do: [
		context
		    fillRule: #evenOdd;
		    fillWith: Color green * 0.7;
		    strokeWith: Color black ].

	context
	    translateBy: 0@128;
	    withPath: path
	    do: [
		context
		    fillRule: #winding;
		    fillWith: Color blue * 0.9;
		    strokeWith: Color black ].
    ]

    gradient [
        | linear radial |
	linear := LinearGradient from: 0@0 to: 0@256.
	linear addStopAt: 0 color: Color white.
	linear addStopAt: 1 color: Color black.
	
	radial := RadialGradient from: 115.2@102.4 radius: 25.6
	    to: 102.4@102.4 radius: 128.
	radial addStopAt: 0 color: Color white.
	radial addStopAt: 1 color: Color black.

	context
	    fill: [ context rectangle: (0@0 extent: 256@256) ]
		with: linear;
	    fill: [ context arc: 128@128 radius: 77 from: 0 to: Float pi * 2]
		with: radial.
    ]

    cols [
	^self samples size sqrt ceiling.
    ]

    rows [
	^(self samples size / self cols) ceiling.
    ]

    displaySize [
	| defSize cols rows |
	defSize := SdlDisplay defaultSize.
	cols := self cols.
	rows := self rows.

	^defSize x * rows / cols > defSize y
	     ifTrue: [ ^(cols@rows) * (defSize y / rows) ]
	     ifFalse: [ ^(cols@rows) * (defSize x / cols) ]
    ]

    clippingRectangle: index [
        | cols rows col row size |
	cols := self cols.
	rows := self rows.
	col := (index - 1) \\ cols.
	row := (index - 1) // cols.
	size := SdlDisplay current extent / (cols @ rows).
	^size * (col @ row) extent: size
    ]

    run [
    	SdlDisplay defaultFormat
	    resizable: true;
	    extent: self displaySize.

        "SdlDisplay current: SdlGLDisplay new."
        SdlDisplay current eventSource handler: self; startEventLoop.
        Processor activeProcess terminateOnQuit.
        surface := CairoSdlSurface on: SdlDisplay current.
	self draw.
	(CairoPngSurface on: 'demo.png' with: surface) save.
    ]
    
    handleResize: size [
	super handleResize: size.
	self draw
    ]

    draw [
	surface withContextDo: [ :ctx |
	    context := ctx.
	    context paintWith: Color white.
	    self samples keysAndValuesDo: [ :index :sel |
	        self draw: sel inside: (self clippingRectangle: index) ] ].
    ]
    
    draw: sel inside: rect [
        | size |
	size := rect width min: rect height.
	context saveWhile: [
	    context
	        resetClip;
	        withPath: [ context rectangle: rect ] do: [ context clip ];
	        translateBy: rect origin + ((rect extent - size) / 2);
	        scaleBy: size / 256.
		
	    self perform: sel ]
    ]
]

Eval [
    s := Semaphore new.
    [CairoDemo new run. s signal] fork.
    s wait
]
