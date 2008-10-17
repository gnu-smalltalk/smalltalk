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

Object subclass: #SdlImage
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Image'! !

!SdlImage class methodsFor: 'Constants'!

sdlImageMajorVersion
    ^1!

sdlImageMinorVersion
    ^2!

sdlImagePatchLevel
    ^4!

!SdlImage class methodsFor: 'C call-outs'!

imgLinkedVersion
    "I answer the version of the dynamically linked SDL_image
    library. My C function call prototype:

    extern DECLSPEC const SDL_version * SDLCALL IMG_Linked_Version(void);"
    <cCall: 'IMG_Linked_Version' returning: #cObject 
        args: #( )>!

imgLoadTypedRW: aCobject0 freeSrc: aInt1 type: aString2 
    "I load an image from an SDL data source. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadTyped_RW(SDL_RWops *src, int freesrc, char *type);"
    <cCall: 'IMG_LoadTyped_RW' returning: #cObject 
        args: #( #cObject #int #string  )>!

imgLoad: aString0 
    "I am a convienance method. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_Load(const char *file);"
    <cCall: 'IMG_Load' returning: #cObject 
        args: #( #string  )>!

imgLoadRW: aCobject0 freeSrc: aInt1 
    "I am a convienance method. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_Load_RW(SDL_RWops *src, int freesrc);"
    <cCall: 'IMG_Load_RW' returning: #cObject 
        args: #( #cObject #int  )>!

imgInvertAlpha: aInt0
    "I invert the alpha of a surface for use with OpenGL (now a
    NOP). My C function call prototype:

    extern DECLSPEC int SDLCALL IMG_InvertAlpha(int on);"
    <cCall: 'IMG_InvertAlpha' returning: #int 
        args: #( #int )>!

imgIsBMP: aCobject0
    "I answer if a seekable source is of type BMP. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isBMP(SDL_RWops *src);"
    <cCall: 'IMG_isBMP' returning: #int 
        args: #( #cObject )>!

imgIsPNM: aCobject0
    "I answer if a seekable source is of type PNM. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isPNM(SDL_RWops *src);"
    <cCall: 'IMG_isPNM' returning: #int 
        args: #( #cObject )>!

imgIsXPM: aCobject0
    "I answer if a seekable source is of type XPM. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isXPM(SDL_RWops *src);"
    <cCall: 'IMG_isXPM' returning: #int 
        args: #( #cObject )>!

imgIsXCF: aCobject0
    "I answer if a seekable source is of type XCF. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isXCF(SDL_RWops *src);"
    <cCall: 'IMG_isXCF' returning: #int 
        args: #( #cObject )>!

imgIsPCX: aCobject0
    "I answer if a seekable source is of type PCX. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isPCX(SDL_RWops *src);"
    <cCall: 'IMG_isPCX' returning: #int 
        args: #( #cObject )>!

imgIsGIF: aCobject0
    "I answer if a seekable source is of type GIF. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isGIF(SDL_RWops *src);"
    <cCall: 'IMG_isGIF' returning: #int 
        args: #( #cObject )>!

imgIsJPG: aCobject0
    "I answer if a seekable source is of type JPG. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isJPG(SDL_RWops *src);"
    <cCall: 'IMG_isJPG' returning: #int 
        args: #( #cObject )>!

imgIsTIF: aCobject0
    "I answer if a seekable source is of type TIF. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isTIF(SDL_RWops *src);"
    <cCall: 'IMG_isTIF' returning: #int 
        args: #( #cObject )>!

imgIsPNG: aCobject0
    "I answer if a seekable source is of type PNG. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isPNG(SDL_RWops *src);"
    <cCall: 'IMG_isPNG' returning: #int 
        args: #( #cObject )>!

imgIsLBM: aCobject0
    "I answer if a seekable source is of type LBM. My C function call
    prototype:

    extern DECLSPEC int SDLCALL IMG_isLBM(SDL_RWops *src);"
    <cCall: 'IMG_isLBM' returning: #int 
        args: #( #cObject )>!

imgLoadBMPRW: aCobject0 
    "I load a seekable source whose type is BMP. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadBMP_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadBMP_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadPNMRW: aCobject0 
    "I load a seekable source whose type is PNM. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadPNM_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadPNM_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadXPMRW: aCobject0 
    "I load a seekable source whose type is XPM. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadXPM_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadXPM_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadXCFRW: aCobject0 
    "I load a seekable source whose type is XCF. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadXCF_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadXCF_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadPCXRW: aCobject0 
    "I load a seekable source whose type is PCX. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadPCX_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadPCX_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadGIFRW: aCobject0 
    "I load a seekable source whose type is GIF. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadGIF_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadGIF_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadJPGRW: aCobject0 
    "I load a seekable source whose type is JPG. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadJPG_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadJPG_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadTIFRW: aCobject0 
    "I load a seekable source whose type is TIF. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadTIF_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadTIF_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadPNGRW: aCobject0 
    "I load a seekable source whose type is PNG. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadPNG_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadPNG_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadTGARW: aCobject0 
    "I load a seekable source whose type is TGA. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadTGA_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadTGA_RW' returning: #cObject 
        args: #( #cObject  )>!

imgLoadLBMRW: aCobject0 
    "I load a seekable source whose type is LBM. My C function call
    prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_LoadLBM_RW(SDL_RWops *src);"
    <cCall: 'IMG_LoadLBM_RW' returning: #cObject 
        args: #( #cObject  )>!

imgReadXPMFromArray: aCobject0 
    "I load an array whose source whose type is XPM. My C function
    call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL IMG_ReadXPMFromArray(char **xpm);"
    <cCall: 'IMG_ReadXPMFromArray' returning: #cObject 
        args: #( #cObjectPtr  )>! !
