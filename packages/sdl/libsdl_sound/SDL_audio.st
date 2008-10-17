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

Object subclass: #SdlAudio
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SdlAudioSpec
    declaration: #(
        (#freq #int)
        (#format #short)
        (#channels #int)
        (#silence #int)
        (#samples #short)
        (#padding #short)
        (#size #int)
        (#callback (#ptr #CObject))
        (#userData (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SdlAudioCvt
    declaration: #(
        (#needed #int)
        (#srcFormat #short)
        (#dstFormat #short)
        (#rateIncr #double)
        (#buf (#ptr #CObject))
        (#len #int)
        (#lenCvt #int)
        (#lenMult #int)
        (#lenRatio #double)
        (#filter0 (#ptr #CObject))
        (#filter1 (#ptr #CObject))
        (#filter2 (#ptr #CObject))
        (#filter3 (#ptr #CObject))
        (#filter4 (#ptr #CObject))
        (#filter5 (#ptr #CObject))
        (#filter6 (#ptr #CObject))
        (#filter7 (#ptr #CObject))
        (#filter8 (#ptr #CObject))
        (#filter9 (#ptr #CObject))
        (#filterIndex #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

!SdlAudio class methodsFor: 'Constants'!

audioU8
    ^16r0008!

audioS8
    ^16r8008!

audioU16LSB
    ^16r0010!

audioS16LSB
    ^16r8010!

audioU16MSB
    ^16r1010!

audioS16MSB
    ^16r9010!

audioU16
    ^16r0010!

audioS16
    ^16r8010!

audioU16Sys
    ^16r0010!

audioS16Sys
    ^16r8010!

sdlAudioStopped
    ^0!

sdlAudioPlaying
    ^0!

sdlAudioPaused
    ^1!

sdlMixMaxVolume
    ^128!

!SdlAudio class methodsFor: 'C call-outs'!

sdlAudioInit: aString0
    "I am normally used internally. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_AudioInit(const char *driver_name);"
    <cCall: 'SDL_AudioInit' returning: #int
        args: #( #string )>!

sdlAudioQuit
    "I am normally used internally. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_AudioQuit(void);"
    <cCall: 'SDL_AudioQuit' returning: #void
        args: #( )>!

sdlAudioDriverName: aString0 maxLen: anInt1
    "I fill the character buffer given to me with the name of the
    current audio driver. My C function call prototype:

    extern DECLSPEC char * SDLCALL SDL_AudioDriverName(char *namebuf, 
         int maxlen);"
    <cCall: 'SDL_AudioDriverName' returning: #string
        args: #( #string #int )>!

sdlOpenAudio: aCobject0 obtained: aCobject1
    "I open the audio device. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_OpenAudio(SDL_AudioSpec *desired, 
         SDL_AudioSpec *obtained);"
    <cCall: 'SDL_OpenAudio' returning: #int
        args: #( #cObject #cObject )>!

sdlGetAudioStatus
    "I answer with the current audio state. My C function call prototype:

     extern DECLSPEC SDL_audiostatus SDLCALL SDL_GetAudioStatus(void);"
    <cCall: 'SDL_GetAudioStatus' returning: #cObject 
        args: #( )>!

sdlPauseAudio: aInt0
    "I pause or unpause the audio callback processing. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDL_PauseAudio(int pause_on);"
    <cCall: 'SDL_PauseAudio' returning: #void
        args: #( #int )>!

sdlLoadWavRW: aCobject0 freeSrc: aInt1 spec: aCobject2 audioBuf: aCobjectPtr3 
    audioLen: aCobject4
    "I load a wave from the data source given to me. My C function call prototype:

    extern DECLSPEC SDL_AudioSpec * SDLCALL SDL_LoadWAV_RW(SDL_RWops *src, 
         int freesrc, SDL_AudioSpec *spec, Uint8 **audio_buf, Uint32 *audio_len);"
    <cCall: 'SDL_LoadWAV_RW' returning: #cObject 
        args: #( #cObject #int #cObject #cObjectPtr #cObject  )>!

sdlFreeWav: aCobject0
    "I free data previously allocated with SDL_LoadWAV_RW(). My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeWAV(Uint8 *audio_buf);"
    <cCall: 'SDL_FreeWAV' returning: #void 
        args: #( #cObject )>!

sdlBuildAudioCvt: aCobject0 srcFormat: aInt1 srcChannels: aChar2 srcRate: aInt3 
    dstFormat: aInt4 dstChannels: aChar5 dstRate: aInt6 
    "I initialize a CVT for converting a buffer of audio data from one
    format to the another. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_BuildAudioCVT(SDL_AudioCVT *cvt,
         Uint16 src_format, Uint8 src_channels, int src_rate,
         Uint16 dst_format, Uint8 dst_channels, int dst_rate);"
    <cCall: 'SDL_BuildAudioCVT' returning: #int 
        args: #( #cObject #int #char #int #int #char #int )>!

sdlConvertAudio: aCobject0
    "I convert a buffer of audio data in-place to the desired
    format. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_ConvertAudio(SDL_AudioCVT *cvt);"
    <cCall: 'SDL_ConvertAudio' returning: #int 
        args: #( #cObject )>!

sdlMixAudio: aCobject0 src: aCobject1 len: aUint2 volume: aInt3
    "I take two audio buffers of the playing audio format and mix
    them, performing addition, volume adjustment, and overflow
    clipping. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_MixAudio(Uint8 *dst, const Uint8 *src, 
         Uint32 len, int volume);"
    <cCall: 'SDL_MixAudio' returning: #void 
        args: #( #cObject #cObject #uInt #int )>!

sdlLockAudio
    "I lock audio access to protect a callback function. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDL_LockAudio(void);"
    <cCall: 'SDL_LockAudio' returning: #void 
        args: #( )>!

sdlUnlockAudio
    "I unlock audio access to protect a callback function. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDL_UnlockAudio(void);"
    <cCall: 'SDL_UnlockAudio' returning: #void 
        args: #( )>!

sdlCloseAudio
    "I shut down audio processing and close the audio device. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_CloseAudio(void);"
    <cCall: 'SDL_CloseAudio' returning: #void 
        args: #( )>! !
