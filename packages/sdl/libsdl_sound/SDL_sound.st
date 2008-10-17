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

Object subclass: #SdlSound
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SoundAudioInfo
    declaration: #(
        (#format #short)
        (#channels #char)
        (#rate #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SoundDecoderInfo
    declaration: #(
        (#extensions (#ptr #CObject))
        (#description #string)
        (#author #string)
        (#url #string))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SoundSample
    declaration: #(
        (#opaque (#ptr #CObject))
        (#decoder (#ptr #CObject))
        (#desired (#array #byte 56))
        (#actual (#array #byte 56))
        (#buffer (#ptr #CObject))
        (#bufferSize #int)
        (#flags #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SoundVersion
    declaration: #(
        (#major #int)
        (#minor #int)
        (#patch #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

!SdlSound class methodsFor: 'Constants'!

soundVerMajor
    ^1!

soundVerMinor
    ^0!

soundVerPatch
    ^1!

soundSampleflagNone
    ^0!

soundSampleflagCanseek
    ^1!

soundSampleflagEOF
    ^1 << 29!

soundSampleflagError
    ^1 << 30!

soundSampleflagEAgain
    ^1 << 31!

!SdlSound class methodsFor: 'C call-outs'!

soundGetLinkedVersion: aCobject0 
    "I get the version of SDL_sound that is loaded against your
    program. My C function call prototype:

    SNDDECLSPEC void SDLCALL Sound_GetLinkedVersion(Sound_Version *ver);"
    <cCall: 'Sound_GetLinkedVersion' returning: #void 
        args: #( #cObject  )>!

soundInit
    "I initialize SDL sound. My C function call prototype:

    SNDDECLSPEC int SDLCALL Sound_Init(void);"
    <cCall: 'Sound_Init' returning: #int 
        args: #( )>!

soundQuit
    "I shutdown SDL_sound. My C function call prototype:

    SNDDECLSPEC int SDLCALL Sound_Quit(void);"
    <cCall: 'Sound_Quit' returning: #int 
        args: #( )>!

soundAvailableDecoders
    "I answer with a list of sound formats supported by this version
    of SDL_sound. My C function call prototype:

    SNDDECLSPEC const Sound_DecoderInfo ** SDLCALL Sound_AvailableDecoders(void);"
    <cCall: 'Sound_AvailableDecoders' returning: #cObjectPtr
        args: #( )>!

soundGetError
    "I answer the last SDL_sound error message as a string. My C
    function call prototype:

    SNDDECLSPEC const char * SDLCALL Sound_GetError(void);"
    <cCall: 'Sound_GetError' returning: #string 
        args: #( )>!

soundClearError
    "I clear the current error message. My C function call prototype:

    SNDDECLSPEC void SDLCALL Sound_ClearError(void);"
    <cCall: 'Sound_ClearError' returning: #void 
        args: #( )>!

soundNewSample: aCobject0 ext: aString1 desired: aCobject2 
    bufferSize: aCobject3 
    "I start decoding a new sound sample. My C function call prototype:

    SNDDECLSPEC Sound_Sample * SDLCALL Sound_NewSample(SDL_RWops *rw, 
         const char *ext, Sound_AudioInfo *desired, Uint32 bufferSize);"
    <cCall: 'Sound_NewSample' returning: #cObject 
        args: #( #cObject #string #cObject #uInt  )>!

soundNewSampleFromFile: aString0 desired: aCobject1 bufferSize: aCobject2 
    "I start decoding a new sound sample from a file on disk. My C
    function call prototype:

    SNDDECLSPEC Sound_Sample * SDLCALL Sound_NewSampleFromFile(const char *fname, 
         Sound_AudioInfo *desired, Uint32 bufferSize);"
    <cCall: 'Sound_NewSampleFromFile' returning: #cObject 
        args: #( #string #cObject #uInt  )>!

soundFreeSample: aCobject0 
    "I dispose of a Sound_Sample. My C function call prototype:

    SNDDECLSPEC void SDLCALL Sound_FreeSample(Sound_Sample *sample);"
    <cCall: 'Sound_FreeSample' returning: #void 
        args: #( #cObject  )>!

soundSetBufferSize: aCobject0 newSize: aCobject1 
    "I change the current buffer size for a sample. My C function call
    prototype:

    SNDDECLSPEC int SDLCALL Sound_SetBufferSize(Sound_Sample *sample, 
         Uint32 new_size);"
    <cCall: 'Sound_SetBufferSize' returning: #int 
        args: #( #cObject #cObject  )>!

soundDecode: aCobject0 
    "I decode more of the sound data in a Sound_Sample. My C function
    call prototype:

    SNDDECLSPEC Uint32 SDLCALL Sound_Decode(Sound_Sample *sample);"
    <cCall: 'Sound_Decode' returning: #uInt
        args: #( #cObject  )>!

soundDecodeAll: aCobject0 
    "I decode the remainder of the sound data in a Sound_Sample. My C
    function call prototype:

    SNDDECLSPEC Uint32 SDLCALL Sound_DecodeAll(Sound_Sample *sample);"
    <cCall: 'Sound_DecodeAll' returning: #uInt
        args: #( #cObject  )>!

soundRewind: aCobject0 
    "I rewind a sample to the start. My C function call prototype:

    SNDDECLSPEC int SDLCALL Sound_Rewind(Sound_Sample *sample);"
    <cCall: 'Sound_Rewind' returning: #int 
        args: #( #cObject  )>!

soundSeek: aCobject0 ms: aCobject1 
    "I seek to a different point in a sample. My C function call protocal:

    SNDDECLSPEC int SDLCALL Sound_Seek(Sound_Sample *sample, Uint32 ms);"
    <cCall: 'Sound_Seek' returning: #int 
        args: #( #cObject #uInt  )>! !
