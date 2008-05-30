"======================================================================
|
|   Blitting example using Cairo and SDL
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones.
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

SDL.SdlEventHandler subclass: BlitDemo [
    <import: SDL>

    winningDirectAccess [
        | color |
        SdlDisplay current critical: [
	    color := SdlDisplay current mapRed: 100 green: 200 blue: 255.
	    SdlDisplay current fillRect: (0@0 extent: SdlDisplay current extent) color: color].
        SdlDisplay current flip.
    ]

    run [
        SdlDisplay current: SdlGLDisplay new.
        SdlDisplay current eventSource handler: self; startEventLoop.
        Processor activeProcess terminateOnQuit.
        SdlDisplay current isGLDisplay ifFalse: [ self winningDirectAccess ].
        self blitStuff.
    ]

    randomColorComponent [
        ^ ((Random between: 0 and: 255) / 255) asFloat
    ]

    transparentFill: surface [
	"Just an example that would allow showing other OpenGL stuff behind
	 the Cairo graphics."
	surface withContextDo: [ :context |
            context
		operator: #source;
	        sourceRed: 0 green: 0 blue: 0 alpha: 0;
	        paint;
		operator: #over ].
    ]

    blitStuff [
        | maxw maxh x y w h startTime count surface frameRects |
        startTime := Time millisecondClock.
        surface := Cairo.CairoSdlSurface on: SdlDisplay current.
        count := 0.
        maxw := SdlDisplay current extent x.
        maxh := SdlDisplay current extent y.
	frameRects := SdlDisplay current isGLDisplay ifTrue: [1] ifFalse: [100].
        SdlDisplay current isGLDisplay ifTrue: [ self transparentFill: surface ].
        [
	    surface withContextDo: [ :context |
		frameRects timesRepeat: [
		    x := Random between: 0 and: maxw.
		    y := Random between: 0 and: maxh.
		    w := Random between: 0 and: maxw - x.
		    h := Random between: 0 and: maxh - y.
		    count := count + 1.
	            context
		        sourceRed: self randomColorComponent
		            green: self randomColorComponent
		            blue: self randomColorComponent;
		        fill: [ context rectangle: (x@y extent: w@h)]]].

	    count \\ 100 == 0 ifTrue: [
	        Transcript << count << ' frames, '
		  << (count / ((Time millisecondClock - startTime) / 1000.0))
		  << ' fps'; nl.
	        Processor yield ].
        ] repeat.
    ]

    handleQuit [
        (ObjectMemory snapshot: 'demo.im') ifFalse: [
	    "false -> not resuming"
	    Transcript << 'about to quit after snapshot'; nl.
	    ObjectMemory quit].
    ]
]

Eval [
    s := Semaphore new.
    [BlitDemo new run. s signal] fork.
    s wait
]
