"======================================================================
|
|   CairoSdlSurface class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
| OpenGL support by Paolo Bonzini.
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


CairoSurface subclass: CairoSdlSurface [
    <category: 'LibSDL-Cairo'>
    <comment: 'I am a Cairo surface that can be used to write on
an SdlDisplay.  Do not forget to lock the display while using
the surface.'>

    | display data textureId size haveAppleClientStorage |

    CairoSdlSurface class >> on: aDisplay [
	<category: 'instance creation'>
	"Create a surface on the given SdlDisplay."
	^self new display: aDisplay
    ]

    display [
	"Return the SdlDisplay attached to this surface."
	<category: 'accessing'>
	^display
    ]

    display: aDisplay [
	<category: 'private-initialization'>
	self finalize.
	display := aDisplay.
	display addDependent: self.
    ]

    extent [
	^display extent
    ]

    buildSurface [
	<category: 'private'>
	| s pixels stride |
	s := display sdlSurface.
	size := s w value @ s h value.
	display isGLDisplay ifTrue: [ self glInit ].
	pixels := display isGLDisplay
	    ifTrue: [ data ]
	    ifFalse: [ s pixels value ].
	stride := display isGLDisplay
	    ifTrue: [ size x * 4 ]
	    ifFalse: [ s pitch value ].

	^ Cairo imageSurfaceCreateForData: pixels
		format: Cairo formatArgb32
		width: size x
		height: size y
		stride: stride.
    ]

    free [
	<category: 'private'>
	super free.
	data free.
    ]

    resize [
	display isGLDisplay ifTrue: [ self finalize; rebuildSurface ]
    ]

    format: const [
	^Memory bigEndian
	    ifTrue: [ const glUnsignedInt8888Rev ]
	    ifFalse: [ const glUnsignedByte ]
    ]

    glInit [
	| const extensions |
	const := display openGLInterface class.

	data := (CByteType arrayType: size x * size y * 4) new.
	textureId := (display openGLInterface glGenTextures: 1) first.
	extensions := display openGLInterface glGetString: const glExtensions.
	haveAppleClientStorage := extensions subStrings
	    includes: 'GL_APPLE_client_storage'.

	self glClear.

	display openGLInterface
	    glBindTexture: const glTextureRectangleArb to: textureId;
	    "glTextureRangeAPPLE: const glTextureRectangleArb
		size: size x * size y * 4
		data: data;"

	    glTexImage2D: const glTextureRectangleArb level: 0
		internalFormat: const glRgba8
		width: size x height: size y border: 0
		format: const glBgra type: (self format: const)
		pixels: data
    ]

    glClear [
	display openGLInterface
	    glClearColor: #[0 0 0 0];
	    glClear: display openGLInterface class glColorBufferBit
    ]

    glBlit [
	| const |
	const := display openGLInterface class.

	display openGLInterface
	    glPushClientAttrib: const glClientPixelStoreBit;
	    glPushAttrib: const glColorBufferBit + const glCurrentBit +
		const glDepthBufferBit + const glEnableBit +
		const glPolygonBit + const glTransformBit + const glViewportBit;

	    "Disable cool stuff"
	    glDisable: const glAlphaTest;
	    glDisable: const glClipPlane0;
	    glDisable: const glClipPlane1;
	    glDisable: const glClipPlane2;
	    glDisable: const glClipPlane3;
	    glDisable: const glClipPlane4;
	    glDisable: const glClipPlane5;
	    glDisable: const glColorLogicOp;
	    glDisable: const glColorTable;
	    glDisable: const glCullFace;
	    glDisable: const glDepthTest;
	    "glDisable: const glDither;"
	    glDisable: const glFog;
	    glDisable: const glLighting;
	    "glDisable: const glPolygonStipple;
	    glDisable: const glScissorTest;
	    glDisable: const glStencilTest;"

	    glViewport: 0 y: 0 width: size x height: size y;
	    glMatrixMode: const glModelview;
	    glPushMatrix;
	    glLoadIdentity;
	    glMatrixMode: const glProjection;
	    glPushMatrix;
	    glLoadIdentity;
	    glOrtho: 0.0 right: 1.0 bottom: 1.0 top: 0.0 near: -1.0 far: 1.0;
	
	    glBindTexture: const glTextureRectangleArb to: textureId;

	    "TODO: support PBOs, see http://www.songho.ca/opengl/gl_pbo.html"
	    glPixelStorei: const glUnpackClientStorageApple value: 1;
	    glTexParameteri: const glTextureRectangleArb
		property: const glTextureStorageHintApple
		value: const glStorageSharedApple;

	    glTexSubImage2D: const glTextureRectangleArb level: 0
		xoffset: 0 yoffset: 0
		width: size x height: size y
		format: const glBgra type: (self format: const)
		pixels: data;
	
	    glDisable: const glTexture3d;
	    glDisable: const glTextureCubeMap;
	    glEnable: const glTextureRectangleArb;
	    glEnable: const glBlend;
	    glBlendFunc: const glSrcAlpha dfactor: const glOneMinusSrcAlpha;

	    glTexEnvi: const glTextureEnv
		property: const glTextureEnvMode value: const glReplace;

	    glBegin: const glQuads;
	    glTexCoord2f: 0 y: 0;
	    glVertex2f: 0 y: 0;
	    glTexCoord2f: size x y: 0;
	    glVertex2f: 1 y: 0;
	    glTexCoord2f: size x y: size y;
	    glVertex2f: 1 y: 1;
	    glTexCoord2f: 0 y: size y;
	    glVertex2f: 0 y: 1;
	    glEnd;

	    glPopMatrix;
	    glMatrixMode: const glModelview;
	    glPopMatrix;
	    glPopAttrib;
	    glPopClientAttrib.

	display flip.
	self glClear.
	haveAppleClientStorage ifTrue: [ display openGLInterface glFinish ].
    ]

    withContextDo: aBlock [
	<category: 'accessing'>
	| s newSize |
	s := display sdlSurface.
	newSize := s w value @ s h value.
	newSize = size ifFalse: [ size := newSize. self resize ].
	display critical: [ super withContextDo: aBlock ].
	display isGLDisplay
	    ifTrue: [ self glBlit ]
	    ifFalse: [ display flip ]
    ]
].

