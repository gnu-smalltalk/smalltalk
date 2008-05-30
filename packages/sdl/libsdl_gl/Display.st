"======================================================================
|
|   SdlGLDisplay wrapper class for libsdl
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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


SdlDisplay subclass: SdlGLDisplay [
    flags [
	"Private - Return the SDL_SetVideoMode flags."

	<vategory: 'private'>
	^super flags bitOr: SdlVideo sdlOpenGL
    ]

    critical: aBlock [
	"Execute aBlock while the surface is locked.  This is a no-op
	 for OpenGL, it just evaluates aBlock.  In the future we might
	 consider using a mutex for OpenGL operations."

	<category: 'drawing-direct'>
	^aBlock value
    ]

    flip [
	"Move the contents of the surface to the screen.  OpenGL surfaces
	 are always double-buffered."

	<category: 'drawing-SDL'>
	SdlVideo sdlGLSwapBuffers
    ]

    isGLDisplay [
	"Return true if this is an OpenGL display and graphics should be
	 performed using OpenGL calls."

	<category: 'testing'>
	^true
    ]

    openGLInterface [
        <category: 'context'>
        ^self sdlSurface ifNotNil: [ OpenGL.OpenGLInterface current ]
    ]

    updateRectangle: aRect [
	"Move the contents of the given rectangle from the surface to the
	 screen.  OpenGL actually always flips the entire surface."

	<category: 'drawing-SDL'>
	self flip
    ]

    updateRectangles: upTo rects: sdlrects [
	"Private - Move the contents of the given SdlRect objects from the
	 surface to the screen.  OpenGL actually always flips the entire
	 surface."

	<category: 'drawing-SDL'>
	self flip
    ]
]
