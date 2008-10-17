"======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
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


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlVideo
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlRect
    declaration: #(
        (#x #short)
        (#y #short)
        (#w #ushort)
        (#h #ushort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlColor
    declaration: #(
        (#r #char)
        (#g #char)
        (#b #char)
        (#unused #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlPalette
    declaration: #(
        (#ncolors #int)
        (#colors (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlPixelformat
    declaration: #(
        (#palette (#ptr #{SdlPalette}))
        (#bitsPerPixel #char)
        (#bytesPerPixel #char)
        (#rLoss #char)
        (#gLoss #char)
        (#bLoss #char)
        (#aLoss #char)
        (#rShift #char)
        (#gShift #char)
        (#bShift #char)
        (#aShift #char)
        (#rMask #uInt)
        (#gMask #uInt)
        (#bMask #uInt)
        (#aMask #uInt)
        (#colorKey #uInt)
        (#alpha #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlSurface
    declaration: #(
        (#flags #uInt)
        (#format (#ptr #{SdlPixelformat}))
        (#w #int)
        (#h #int)
        (#pitch #ushort)
        (#pixels (#ptr #CObject))
        (#offset #int)
        (#hwData (#ptr #CObject))
        (#clipRect #{SdlRect})
        (#unused1 #uInt)
        (#locked #uInt)
        (#map (#ptr #CObject))
        (#formatVersion #uInt)
        (#refCount #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !
CStruct subclass: #SdlVideoInfo
    declaration: #(
        (#hwAvailable #uInt)
        (#wmAvailable #uInt)
        (#unusedBits1 #uInt)
        (#unusedBits2 #uInt)
        (#blitHw #uInt)
        (#blitHwCc #uInt)
        (#blitHwA #uInt)
        (#blitSw #uInt)
        (#blitSwCc #uInt)
        (#blitSwA #uInt)
        (#blitFill #uInt)
        (#unusedBits3 #uInt)
        (#videoMem #uInt)
        (#vFmt (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlOverlay
    declaration: #(
        (#format #uInt)
        (#w #int)
        (#h #int)
        (#planes #int)
        (#pitches (#ptr #CObject))
        (#pixels (#ptr #CObject))
        (#hwFuncs (#ptr #CObject))
        (#hwData (#ptr #CObject))
        (#hwOverlay #uInt)
        (#unusedBits #uInt))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlVideo class methodsFor: 'Constants'!

sdlAlphaOpaque
    ^255!

sdlAlphaTransparent
    ^0!

sdlSwSurface
    ^16r00000000!

sdlHwSurface
    ^16r00000001!

sdlAsyncBlit
    ^16r00000004!

sdlAnyFormat
    ^16r10000000!

sdlHwPalette
    ^16r20000000!

sdlDoubleBuf
    ^16r40000000!

sdlFullScreen
    ^16r80000000!

sdlOpenGL
    ^16r00000002!

sdlOpenGLBlit
    ^16r0000000A!

sdlResizable
    ^16r00000010!

sdlNoFrame
    ^16r00000020!

sdlHwAccel
    ^16r00000100!

sdlSrcColorKey
    ^16r00001000!

sdlRleAccelOk
    ^16r00002000!

sdlRleAccel
    ^16r00004000!

sdlSrcAlpha
    ^16r00010000!

sdlPreAlloc
    ^16r01000000!

sdlYV12Overlay
    ^16r32315659!

sdlIYUVOverlay
    ^16r56555949!

sdlYUY2Overlay
    ^16r32595559!

sdlUYVYOverlay
    ^16r59565955!

sdlYVYUOverlay
    ^16r55595659!

sdlGLRedSize
    ^0!

sdlGLGreenSize
    ^1!

sdlGLBlueSize
    ^2!

sdlGLAlphaSize
    ^3!

sdlGLBufferSize
    ^4!

sdlGLDoublebuffer
    ^5!

sdlGLDepthSize
    ^6!

sdlGLStencilSize
    ^7!

sdlGLAccumRedSize
    ^8!

sdlGLAccumGreenSize
    ^9!

sdlGLAccumBlueSize
    ^10!

sdlGLAccumAlphaSize
    ^11!

sdlGLStereo
    ^12!

sdlGLMultiSampleBuffers
    ^13!

sdlGLMultiSampleSamples
    ^14!

sdlLogPal
    ^16r01!

sdlPhysPal
    ^16r02!

sdlGrabQuery
    ^-1!

sdlGrabOff
    ^0!

sdlGrabOn
    ^1!

sdlGrabFullscreen
    ^0!

!SdlVideo class methodsFor: 'C call-outs'!

sdlVideoInit: aString0 flags: aUint1
    "I initialize the video subsystem. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_VideoInit(const char *driver_name, 
         Uint32 flags);"
    <cCall: 'SDL_VideoInit' returning: #int 
        args: #( #string #uInt )>!

sdlVideoQuit
    "I shutdown the video subsystem. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_VideoQuit(void);"
    <cCall: 'SDL_VideoQuit' returning: #void 
        args: #( )>!

sdlVideoDriverName: aString0 maxLen: aInt1
    "I answer with the name of the video driver. My C function call
    prototype:

    extern DECLSPEC char * SDLCALL SDL_VideoDriverName(char *namebuf, 
         int maxlen);"
    <cCall: 'SDL_VideoDriverName' returning: #string 
        args: #( #string #int )>!

sdlGetVideoSurface
    "I answer a pointer to the current display surface. My C function
    call prototype:

     extern DECLSPEC SDL_Surface * SDLCALL SDL_GetVideoSurface(void);"
    <cCall: 'SDL_GetVideoSurface' returning: #{SdlSurface}
        args: #( )>!

sdlGetVideoInfo
    "I answer with a pointer to information about the video
    hardware. My C function call prototype:

    extern DECLSPEC const SDL_VideoInfo * SDLCALL SDL_GetVideoInfo(void);"
    <cCall: 'SDL_GetVideoInfo' returning: #{SdlVideoInfo}
        args: #( )>!

sdlVideoModeOk: aInt0 height: aInt1 bpp: aInt2 flags: aUint3
    "I answer whether or not a particular video mode is supported. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_VideoModeOK(int width, int height, 
         int bpp, Uint32 flags);"
    <cCall: 'SDL_VideoModeOK' returning: #int 
        args: #( #int #int #int #int )>!

sdlListModes: aCobject0 flags: aUint1
    "I return a pointer to an array of available screen dimensions for
    the given format and video flags, sorted largest to smallest. My C
    function call prototype:

    extern DECLSPEC SDL_Rect ** SDLCALL SDL_ListModes(SDL_PixelFormat *format, 
         Uint32 flags);"
    <cCall: 'SDL_ListModes' returning: #cObjectPtr
        args: #( #cObject #uInt  )>!

sdlSetVideoMode: aInt0 height: aInt1 bpp: aInt2 flags: aUint3 
    "I set up a video mode with the specified width, height and
    bits-per-pixel. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_SetVideoMode (int width, int height, 
         int bpp, Uint32 flags);"
    <cCall: 'SDL_SetVideoMode' returning: #{SdlSurface}
        args: #( #int #int #int #uInt  )>!

sdlUpdateRects: aCobject0 numRects: aInt1 rects: aCobject2
    "I update a list of rectangles. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_UpdateRects (SDL_Surface *screen, int numrects, 
         SDL_Rect *rects);"
    <cCall: 'SDL_UpdateRects' returning: #void 
        args: #( #cObject #int #cObject )>!

sdlUpdateRect: aCobject0 x: aInt1 y: aInt2 w: aInt3 h: aInt4
    "I update the entire screen. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_UpdateRect (SDL_Surface *screen, Sint32 x, 
         Sint32 y, Uint32 w, Uint32 h);"
    <cCall: 'SDL_UpdateRect' returning: #void 
        args: #( #cObject #int #int #int #int )>!

sdlFlip: aCobject0
    "I set up a flip and return on hardware that supports
    double-buffering, or perform a SDL_UpdateRect on hardware that
    doesn't. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_Flip(SDL_Surface *screen);"
    <cCall: 'SDL_Flip' returning: #int 
        args: #( #cObject )>!

sdlSetGamma: aFloat0 green: aFloat1 blue: aFloat2
    "I set the gamma correction for each of the color channels. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetGamma(float red, float green, float blue);"
    <cCall: 'SDL_SetGamma' returning: #int 
        args: #( #float #float #float )>!

sdlSetGammaRamp: aCobject0 green: aCobject1 blue: aCobject2
    "I set the gamma translation table for the red, green, and blue
    channels of the video hardware. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetGammaRamp(const Uint16 *red, 
         const Uint16 *green, const Uint16 *blue);"
    <cCall: 'SDL_SetGammaRamp' returning: #int 
        args: #( #cObject #cObject #cObject )>!

sdlGetGammaRamp: aCobject0 green: aCobject1 blue: aCobject2
    "I retrieve the current values of the gamma translation tables. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GetGammaRamp(Uint16 *red, 
         Uint16 *green, Uint16 *blue);"
    <cCall: 'SDL_GetGammaRamp' returning: #int 
        args: #( #cObject #cObject #cObject )>!

sdlSetColors: aCobject0 colors: aCobject1 firstColor: aInt2 nColors: aInt3
    "I set a portion of the colormap for the given 8-bit surface. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetColors(SDL_Surface *surface, 
         SDL_Color *colors, int firstcolor, int ncolors);"
    <cCall: 'SDL_SetColors' returning: #int 
        args: #( #cObject #cObject #int #int )>!

sdlSetPalette: aCobject0 flags: aInt1 colors: aCobject2 firstColor: aInt3 nColors: aInt4
    "I set a portion of the colormap for a given 8-bit surface. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetPalette(SDL_Surface *surface, 
         int flags, SDL_Color *colors, int firstcolor, int ncolors);"
    <cCall: 'SDL_SetPalette' returning: #int 
        args: #( #cObject #int #cObject #int #int )>!

sdlMapRGB: aCobject0 r: aChar1 g: aChar2 b: aChar3 
    "I map a RGB triple to an opaque pixel value for a given pixel
    format. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_MapRGB (SDL_PixelFormat *format, 
         Uint8 r, Uint8 g, Uint8 b);"
    <cCall: 'SDL_MapRGB' returning: #uInt
        args: #( #cObject #char #char #char  )>!

sdlMapRGBA: aCobject0 r: aChar1 g: aChar2 b: aChar3 a: aChar4 
    "I map a RGBA quadruple to a pixel value for a given pixel
    format. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_MapRGBA(SDL_PixelFormat *format, 
         Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'SDL_MapRGBA' returning: #uInt
        args: #( #cObject #char #char #char #char  )>!

sdlGetRGB: aUint0 fmt: aCobject1 r: aCobject2 g: aCobject3 b: aCobject4
    "I map a pixel value into the RGB components for a given pixel
    format. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GetRGB(Uint32 pixel, SDL_PixelFormat *fmt, 
         Uint8 *r, Uint8 *g, Uint8 *b);"
    <cCall: 'SDL_GetRGB' returning: #void 
        args: #( #uInt #cObject #cObject #cObject #cObject )>!

sdlGetRGBA: aUint0 fmt: aCobject1 r: aCobject2 g: aCobject3 b: aCobject4 a: aCobject5
    "I map a pixel value into the RGBA components for a given pixel
    format. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GetRGBA(Uint32 pixel, SDL_PixelFormat *fmt, 
         Uint8 *r, Uint8 *g, Uint8 *b, Uint8 *a);"
    <cCall: 'SDL_GetRGBA' returning: #void 
        args: #( #uInt #cObject #cObject #cObject #cObject #cObject )>!

sdlCreateRGBSurface: aUint0 width: aInt1 height: aInt2 depth: aInt3 rmask: aUint4 
        gmask: aUint5 bmask: aUint6 amask: aUint7
    "I allocate an RGB surface (must be called after
    SDL_SetVideoMode). My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_CreateRGBSurface (Uint32 flags, 
         int width, int height, int depth, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, 
         Uint32 Amask);"
    <cCall: 'SDL_CreateRGBSurface' returning: #{SdlSurface}
        args: #( #uInt #int #int #int #uInt #uInt #uInt #uInt  )>!

sdlCreateRGBSurfaceFrom: aCobject0 width: aInt1 height: aInt2 depth: aInt3 pitch: aInt4 
        rmask: aUint5 gmask: aUint6 bmask: aUint7 amask: aUint8 
    "I allocate an RGB surface. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_CreateRGBSurfaceFrom(void *pixels, 
         int width, int height, int depth, int pitch, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, 
         Uint32 Amask);"
    <cCall: 'SDL_CreateRGBSurfaceFrom' returning: #{SdlSurface}
        args: #( #cObject #int #int #int #int #uInt #uInt #uInt #uInt  )>!

sdlFreeSurface: aCobject0
    "I free an RGB surface. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeSurface(SDL_Surface *surface);"
    <cCall: 'SDL_FreeSurface' returning: #void 
        args: #( #cObject )>!

sdlLockSurface: aCobject0
    "I set up a surface for directly accessing the pixels. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_LockSurface(SDL_Surface *surface);"
    <cCall: 'SDL_LockSurface' returning: #int 
        args: #( #cObject )>!

sdlUnlockSurface: aCobject0
    "I release a surface that was locked for directly accessing
    pixels. My C function prototype:

    extern DECLSPEC void SDLCALL SDL_UnlockSurface(SDL_Surface *surface);"
    <cCall: 'SDL_UnlockSurface' returning: #void 
        args: #( #cObject )>!

sdlLoadBMPRW: aCobject0 freesrc: aInt1 
    "I load a surface from a seekable SDL data source. My C function
    call prototype:

     extern DECLSPEC SDL_Surface * SDLCALL SDL_LoadBMP_RW(SDL_RWops *src, 
         int freesrc);"
    <cCall: 'SDL_LoadBMP_RW' returning: #{SdlSurface}
        args: #( #cObject #int  )>!

sdlSaveBMPRW: aCobject0 dst: aCobject1 freeDst: aInt2
    "I save a surface to a seekable SDL data source. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_SaveBMP_RW (SDL_Surface *surface, 
         SDL_RWops *dst, int freedst);"
    <cCall: 'SDL_SaveBMP_RW' returning: #int 
        args: #( #cObject #cObject #int )>!

sdlSetColorKey: aObject0 flag: aUint1 key: aUint2
    "I set the color key (transparent pixel) in a blittable
    surface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetColorKey (SDL_Surface *surface, 
         Uint32 flag, Uint32 key);"
    <cCall: 'SDL_SetColorKey' returning: #int
        args: #( #cObject #int #int )>!

sdlSetAlpha: aCobject0 flag: aUint alpha: aUchar
    "I set the alpha value for the entire surface. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_SetAlpha(SDL_Surface *surface, 
         Uint32 flag, Uint8 alpha);"
    <cCall: 'SDL_SetAlpha' returning: #int 
        args: #( #cObject #uInt #char )>!

sdlSetClipRect: aCobject0 rect: aCobject1 
    "I set the clipping rectangle for the destination surface in a
    blit. My C function call prototype:

     extern DECLSPEC SDL_bool SDLCALL SDL_SetClipRect(SDL_Surface *surface, 
         const SDL_Rect *rect);"
    <cCall: 'SDL_SetClipRect' returning: #boolean
        args: #( #cObject #cObject  )>!

sdlGetClipRect: aCobject0 rect: aCobject1
    "I get the clipping rectangle for the destination surface in a
    blit. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GetClipRect(SDL_Surface *surface, 
         SDL_Rect *rect);"
    <cCall: 'SDL_GetClipRect' returning: #void 
        args: #(  #cObject #cObject )>!

sdlConvertSurface: aCobject0 fmt: aCobject1 flags: aUint2 
    "I create a new surface of the specified format, and then copy and
    map the given surface to it so the blit of the converted surface
    will be as fast as possible. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_ConvertSurface (SDL_Surface *src, 
         SDL_PixelFormat *fmt, Uint32 flags);"
    <cCall: 'SDL_ConvertSurface' returning: #{SdlSurface}
        args: #( #cObject #cObject #uInt  )>!

sdlUpperBlit: aCobject0 srcRect: aCobject1 dst: aCobject2 dstRect: aCobject3
    "I perform a fast blit from the source surface to the destination
    surface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_UpperBlit (SDL_Surface *src, SDL_Rect *srcrect, 
         SDL_Surface *dst, SDL_Rect *dstrect);"
    <cCall: 'SDL_UpperBlit' returning: #int 
        args: #( #cObject #cObject #cObject #cObject )>!

sdlLowerBlit: aCobject0 srcRect: aCobject1 dst: aCobject2 dstRect: aCobject3
    "I perform a fast blit from the source surface to the destination
    surface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_LowerBlit (SDL_Surface *src, SDL_Rect *srcrect, 
         SDL_Surface *dst, SDL_Rect *dstrect);"
    <cCall: 'SDL_LowerBlit' returning: #int 
        args: #( #cObject #cObject #cObject #cObject )>!

sdlFillRect: aCobject0 dstRect: aCobject1 color: aUint
    "extern DECLSPEC int SDLCALL SDL_FillRect (SDL_Surface *dst, 
         SDL_Rect *dstrect, Uint32 color);"
    <cCall: 'SDL_FillRect' returning: #int 
        args: #( #cObject #cObject #uInt )>!

sdlDisplayFormat: aCobject0 
    "I take a surface and copy it to a new surface of the pixel
    format and colors of the video framebuffer, suitable for fast
    blitting onto the display surface. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_DisplayFormat(SDL_Surface *surface);"
    <cCall: 'SDL_DisplayFormat' returning: #{SdlSurface}
        args: #( #cObject  )>!

sdlDisplayFormatAlpha: aCobject0 
    "I take a surface and copy it to a new surface of the pixel
    format and colors of the video framebuffer (if possible), suitable
    for fast alpha blitting onto the display surface. My C function
    call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_DisplayFormatAlpha(SDL_Surface *surface);"
    <cCall: 'SDL_DisplayFormatAlpha' returning: #{SdlSurface}
        args: #( #cObject  )>!

sdlCreateYUVOverlay: aInt0 height: aInt1 format: aUint2 display: aCobject3
    "I create a video output overlay. My C function call prototype:

    extern DECLSPEC SDL_Overlay * SDLCALL SDL_CreateYUVOverlay(int width, int height, 
         Uint32 format, SDL_Surface *display);"
    <cCall: 'SDL_CreateYUVOverlay' returning: #{SdlOverlay}
        args: #( #int #int #uInt #cObject  )>!

sdlLockYUVOverlay: cObject0
    "I lock an overlay for direct access. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_LockYUVOverlay(SDL_Overlay *overlay);"
    <cCall: 'SDL_LockYUVOverlay' returning: #int 
        args: #( #cObject )>!

sdlUnlockYUVOverlay: aCobject0
    "I unlock an overlay. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_UnlockYUVOverlay(SDL_Overlay *overlay);"
    <cCall: 'SDL_UnlockYUVOverlay' returning: #void 
        args: #( #cObject )>!

sdlDisplayYUVOverlay: aCobject0 dstRect: aCobject1
    "I blit a video overlay to the display surface. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_DisplayYUVOverlay(SDL_Overlay *overlay, 
         SDL_Rect *dstrect);"
    <cCall: 'SDL_DisplayYUVOverlay' returning: #int 
        args: #( #cObject #cObject )>!

sdlFreeYUVOverlay: aCobject0
    "I free a video overlay. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeYUVOverlay(SDL_Overlay *overlay);"
    <cCall: 'SDL_FreeYUVOverlay' returning: #void 
        args: #( #cObject )>!

sdlGLLoadLibrary: aString0
    "I dynamically load a GL driver. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GL_LoadLibrary(const char *path);"
    <cCall: 'SDL_GL_LoadLibrary' returning: #int 
        args: #( #string )>!

sdlGLGetProcAddress: aString0
    "I get the address of a GL function. My C function call prototype:

    extern DECLSPEC void * SDLCALL SDL_GL_GetProcAddress(const char* proc);"
    <cCall: 'SDL_GL_GetProcAddress' returning: #cObject 
        args: #( #string )>!

sdlGLSetAttributes: aCobject0 value: aInt1
    "I set an attribute of the OpenGL subsystem before
    intialization. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GL_SetAttribute(SDL_GLattr attr, int value);"
    <cCall: 'SDL_GL_SetAttribute' returning: #int 
        args: #( #cObject #int )>!

sdlGLGetAttributes: aCobject0 value: aCobject1
    "I get an attribute of the OpenGL subsystem from the windowing
    interface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GL_GetAttribute(SDL_GLattr attr, int* value);"
    <cCall: 'SDL_GL_GetAttribute' returning: #int 
       args: #( #cObject #cObject )>!

sdlGLSwapBuffers
    "I swap the OpenGL buffers, if double-buffering is supported. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_SwapBuffers(void);"
    <cCall: 'SDL_GL_SwapBuffers' returning: #void 
        args: #( )>!

sdlGLUpdateRects: aInt0 rects: aCobject1
    "I am a low-level private function. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_UpdateRects(int numrects, SDL_Rect* rects);"
    <cCall: 'SDL_GL_UpdateRects' returning: #void 
        args: #( #int #cObject )>!

sdlGLLock
    "I am a low-level private function. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_Lock(void);"
    <cCall: 'SDL_GL_Lock' returning: #void 
        args: #( )>!

sdlGLUnlock
    "I am a low-level private function. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_Unlock(void);"
    <cCall: 'SDL_GL_Unlock' returning: #void 
        args: #( )>!

sdlWMSetCaption: aString0 icon: aString2
    "I set the title and icon text of the display window. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_WM_SetCaption(const char *title, 
         const char *icon);"
    <cCall: 'SDL_WM_SetCaption' returning: #void 
        args: #( #string #string )>!

sdlWMGetCaption: aCobjectPtr0 icon: cObjectPtr1
    "I get the title and icon text of the display window. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_WM_GetCaption(char **title, 
         char **icon);"
    <cCall: 'SDL_WM_GetCaption' returning: #void 
        args: #( #cObjectPtr #cObjectPtr )>!

sdlWMSetIcon: aObject0 mask: aCobject1
    "I set the icon for the display window. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_WM_SetIcon(SDL_Surface *icon, 
         Uint8 *mask);"
    <cCall: 'SDL_WM_SetIcon' returning: #void 
        args: #( #cObject #cObject )>!

sdlWMIconifyWindow
    "I iconify a window. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WM_IconifyWindow(void);"
    <cCall: 'SDL_WM_IconifyWindow' returning: #int 
        args: #( )>!

sdlWMToggleFullScreen: aCobject0
    "I toggle the fullscreen mode without changing the contents of the
    screen. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WM_ToggleFullScreen(SDL_Surface *surface);"
    <cCall: 'SDL_WM_ToggleFullScreen' returning: #int 
        args: #( #cObject )>!

sdlWMGrabInput: aCobject0
    "I confine nearly all of the mouse and keyboard input to the
    application window. My C function call prototype:

    extern DECLSPEC SDL_GrabMode SDLCALL SDL_WM_GrabInput(SDL_GrabMode mode);"
    <cCall: 'SDL_WM_GrabInput' returning: #int
        args: #( #int  )>! !
