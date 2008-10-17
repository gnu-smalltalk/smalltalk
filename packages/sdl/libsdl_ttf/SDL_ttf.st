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

Object subclass: #SdlTTF
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-TTF'! !

!SdlTTF class methodsFor: 'Constants'!

sdlTTFMajorVersion
    ^2!

sdlTTFMinorVersion
    ^0!

sdlTTFPatchlevel
    ^7!

ttfMajorVersion
    ^2!

ttfMinorVersion
    ^0!

ttfPatchlevel
    ^7!

unicodeBomNative
    ^16rFEFF!

unicodeBomSwapped
    ^16rFFFE!

ttfStyleNormal
    ^16r00!

ttfStyleBold
    ^16r01!

ttfStyleItalic
    ^16r02!

ttfStyleUnderline
    ^16r04!

!SdlTTF class methodsFor: 'C call-outs'!

ttfInit
    "I initialize the TTF engine. My C function call prototype:

    extern DECLSPEC int SDLCALL TTF_Init(void);"
    <cCall: 'TTF_Init' returning: #int 
        args: #( )>!

ttfOpenFont: aString0 ptSize: aInt1 
    "I open a font file and create a font of the specified point
    size. My C function call prototype:

    extern DECLSPEC TTF_Font * SDLCALL TTF_OpenFont(const char *file, int ptsize);"
    <cCall: 'TTF_OpenFont' returning: #cObject 
        args: #( #string #int  )>!

ttfGetFontStyle: aCobject0
    "I retrieve the font style. My C function call prototype:

    extern DECLSPEC int SDLCALL TTF_GetFontStyle(TTF_Font *font);"
    <cCall: 'TTF_GetFontStyle' returning: #int 
        args: #( #cObject )>!

ttfSetFontStyle: aCobject0 style: aInt1
    "I set the font style. My C function call prototype:

    extern DECLSPEC void TTF_SetFontStyle(TTF_Font *font, int style);"
    <cCall: 'TTF_SetFontStyle' returning: #void 
        args: #( #cObject #int )>!

ttfFontHeight: aCobject0
    "I retrieve the total height of the font. My C function call prototype:

    extern DECLSPEC int SDLCALL TTF_FontHeight(TTF_Font *font);"
    <cCall: 'TTF_FontHeight' returning: #int 
        args: #( #cObject )>!

ttfFontAscent: aCobject0
    "I retrieve the offset from the baseline to the top of the
    font. My C function call prototype:

    extern DECLSPEC int SDLCALL TTF_FontAscent(TTF_Font *font);"
    <cCall: 'TTF_FontAscent' returning: #int 
        args: #( #cObject )>!

ttfFontDescent: aCobject0
    "I get the offset from the baseline to the bottom of the font. My
    C call prototype:

    extern DECLSPEC int SDLCALL TTF_FontDescent(TTF_Font *font);"
    <cCall: 'TTF_FontDescent' returning: #int 
        args: #( #cObject )>!

ttfFontLineSkip: aCobject0
    "I answer the recommended spacing between lines of text for this
    font. My C function call prototype:

    extern DECLSPEC int SDLCALL TTF_FontLineSkip(TTF_Font *font);"
    <cCall: 'TTF_FontLineSkip' returning: #int 
        args: #( #cObject )>!

ttfGlyphMetrics: aCobject ch: aInt1 minX: aCobject2 maxX: aCobject3 minY: aCobject4 
    advance: aCobject5
    "I answer the dimensions of a glyph. My C function call prototype:

    extern DECLSPEC int SDLCALL TTF_GlyphMetrics(TTF_Font *font, Uint16 ch, 
         int *minx, int *maxx, int *miny, int *maxy, int *advance);"
    <cCall: 'TTF_GlyphMetrics' returning: #int 
        args: #( #cObject #int #cObject #cObject #cObject #cObject )>!

ttfSizeText: aCobject0 text: aString1 w: aCobject2 h: aCobject3
    "I answer the dimensions of a rendered string of text. My C
    function call prototype:

    extern DECLSPEC int SDLCALL TTF_SizeText(TTF_Font *font, const char *text, 
         int *w, int *h);"
    <cCall: 'TTF_SizeText' returning: #int 
        args: #( #cObject #string #cObject #cObject )>!

ttfSizeUTF8: aCobject0 text: aString1 w: aCobject2 h: aCobject3
    "I answer the dimensions of a rendered string of text. My C
    function call prototype:
    
    extern DECLSPEC int SDLCALL TTF_SizeUTF8(TTF_Font *font, const char *text, 
         int *w, int *h);"
    <cCall: 'TTF_SizeUTF8' returning: #int 
        args: #( #cObject #string #cObject #cObject )>!

ttfSizeUnicode: aCobject0 text: aCobject1 w: aCobject2 h: aCobject3
    "I answer the dimensions of a rendered string of text. My C
    function call prototype:

    extern DECLSPEC int SDLCALL TTF_SizeUNICODE(TTF_Font *font, const Uint16 *text, 
         int *w, int *h);"
    <cCall: 'TTF_SizeUNICODE' returning: #int 
        args: #( #cObject #cObject #cObject #cObject )>!

ttfRenderTextSolid: aCobject0 text: aString1 fg: aCobject2 
    "I create an 8-bit palettized surface and render the given text at
    fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderText_Solid(TTF_Font *font, 
         const char *text, SDL_Color fg);"
    <cCall: 'TTF_RenderText_Solid' returning: #cObject 
        args: #( #cObject #string #cObject  )>!

ttfRenderUTF8Solid: aCobject0 text: aString1 fg: aCobject2 
    "I create an 8-bit palettized surface and render the given text at
    fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Solid(TTF_Font *font, 
         const char *text, SDL_Color fg);"
    <cCall: 'TTF_RenderUTF8_Solid' returning: #cObject 
        args: #( #cObject #string #cObject  )>!

ttfRenderUnicodeSolid: aCobject0 text: aCobject1 fg: aCobject2 
    "I create an 8-bit palettized surface and render the given text at
    fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Solid(TTF_Font *font, 
         const Uint16 *text, SDL_Color fg);"
    <cCall: 'TTF_RenderUNICODE_Solid' returning: #cObject 
        args: #( #cObject #cObject #cObject  )>!

ttfRenderGlyphSolid: aCobject0 ch: aUint1 fg: aCobject2 
    "I create an 8-bit palettized surface and render the given glyph
    at fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderGlyph_Solid(TTF_Font *font, Uint16 ch, SDL_Color fg);"
    <cCall: 'TTF_RenderGlyph_Solid' returning: #cObject 
        args: #( #cObject #int #cObject  )>!

ttfRenderTextShaded: aCobject0 text: aString1 fg: aCobject2 bg: aCobject3 
    "I create an 8-bit palettized surface and render the given text
    at fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderText_Shaded(TTF_Font *font,
         const char *text, SDL_Color fg, SDL_Color bg);"
    <cCall: 'TTF_RenderText_Shaded' returning: #cObject 
        args: #( #cObject #string #cObject #cObject  )>!

ttfRenderUTF8Shaded: aCobject0 text: aString1 fg: aCobject2 bg: aCobject3 
    "I create an 8-bit palettized surface and render the given text
    at fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Shaded(TTF_Font *font,
         const char *text, SDL_Color fg, SDL_Color bg);"
    <cCall: 'TTF_RenderUTF8_Shaded' returning: #cObject 
        args: #( #cObject #string #cObject #cObject  )>!

ttfRenderUnicodeShaded: aCobject0 text: aCobject1 fg: aCobject2 bg: aCobject3 
    "I create an 8-bit palettized surface and render the given text
    at fast quality with the given font and color. My C function call
    prototype:
    
    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Shaded(TTF_Font *font,
         const Uint16 *text, SDL_Color fg, SDL_Color bg);"
    <cCall: 'TTF_RenderUNICODE_Shaded' returning: #cObject 
        args: #( #cObject #cObject #cObject #cObject  )>!

ttfRenderGlyphShaded: aCobject0 ch: aInt1 fg: aCobject2 bg: aCobject3 
    "I create an 8-bit palettized surface and render the given glyph
    at fast quality with the given font and color. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderGlyph_Shaded(TTF_Font *font,
         Uint16 ch, SDL_Color fg, SDL_Color bg);"
    <cCall: 'TTF_RenderGlyph_Shaded' returning: #cObject 
        args: #( #cObject #int #cObject #cObject  )>!

ttfRenderTextBlended: aCobject0 text: aString1 fg: aCobject2 
    "I create a 32-bit ARGB surface and render the given text at high
    quality, using alpha blending to dither the font with the given
    color. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderText_Blended(TTF_Font *font,
         const char *text, SDL_Color fg);"
    <cCall: 'TTF_RenderText_Blended' returning: #cObject 
        args: #( #cObject #string #cObject  )>!

ttfRenderUTF8Blended: aCobject0 text: aString1 fg: aCobject2 
    "I create a 32-bit ARGB surface and render the given text at high
    quality, using alpha blending to dither the font with the given
    color. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Blended(TTF_Font *font,
         const char *text, SDL_Color fg);"
    <cCall: 'TTF_RenderUTF8_Blended' returning: #cObject 
        args: #( #cObject #string #cObject  )>!

ttfRenderUnicodeBlended: aCobject0 text: aCobject1 fg: aCobject2 
    "I create a 32-bit ARGB surface and render the given text at high
    quality, using alpha blending to dither the font with the given
    color. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Blended(TTF_Font *font,
         const Uint16 *text, SDL_Color fg);"
    <cCall: 'TTF_RenderUNICODE_Blended' returning: #cObject 
        args: #( #cObject #cObject #cObject  )>!

ttfRenderGlyphBlended: aCobject0 ch: aInt1 fg: aCobject2 
    "I create a 32-bit ARGB surface and render the given glyph at high
    quality, using alpha blending to dither the font with the given
    color. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderGlyph_Blended(TTF_Font *font,
         Uint16 ch, SDL_Color fg);"
    <cCall: 'TTF_RenderGlyph_Blended' returning: #cObject 
        args: #( #cObject #int #cObject  )>!

ttfCloseFont: aCobject0
    "I close an opened font file. My C function call prototype:

    extern DECLSPEC void SDLCALL TTF_CloseFont(TTF_Font *font);"
    <cCall: 'TTF_CloseFont' returning: #void 
        args: #( #cObject )>!

ttfQuit
    "I shutdown the TTF engine. My C function call prototype:

    extern DECLSPEC void SDLCALL TTF_Quit(void);"
    <cCall: 'TTF_Quit' returning: #void 
        args: #( )>! !
