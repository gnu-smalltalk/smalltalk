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

Object subclass: #SdlMixer
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Mixer'! !

CStruct subclass: #MixChunk
    declaration: #(
        (#allocated #int)
        (#aBuf (#ptr #CObject))
        (#aLen #uInt)
        (#volume #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Mixer'! !

!SdlMixer class methodsFor: 'Constants'!

sdlMixerMajorVersion
    ^1!

sdlMixerMinorVersion
    ^2!

sdlMixerPatchlevel
    ^6!

mixMajorVersion
    ^1!

mixMinorVersion
    ^2!

mixPatchlevel
    ^6!

mixChannels
    ^8!

mixDefaultFrequency
    ^22050!

mixDefaultChannels
    ^2!

mixMaxVolume
    ^128!

mixNoFading
    ^0!

mixFadingOut
    ^1!

mixFadingIn
    ^2!

musNone
    ^0!

musCmd
    ^1!

musWav
    ^2!

musMod
    ^3!

musMid
    ^4!

musOgg
    ^5!

musMp3
    ^6!

mixChannelPost
    ^-2!

mixEffectsMaxSpeed
    ^'MIX_EFFECTSMAXSPEED'!

!SdlMixer class methodsFor: 'C call-outs'!

mixLinkedVersion
    "I answer the version of the dynamically linked SDL_mixer
    library. My C function call prototype:

    extern DECLSPEC const SDL_version * SDLCALL Mix_Linked_Version(void);"
    <cCall: 'Mix_Linked_Version' returning: #cObject 
        args: #( )>!

mixOpenAudio: aInt0 format: aInt1 channels: aInt2 chunkSize: aInt3
    "I open the mixer. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_OpenAudio(int frequency, Uint16 format, int channels, int chunksize);"
    <cCall: 'Mix_OpenAudio' returning: #int 
        args: #( #int #int #int #int )>!

mixAllocateChannels: aInt0
    "I change the number of channels managed by the mixer. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_AllocateChannels(int numchans);"
    <cCall: 'Mix_AllocateChannels' returning: #int 
        args: #( #int )>!

mixQuerySpec: aCobject0 format: aCobject1 channels: aCobject2
    "I find out what the actual audio device parameters are. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_QuerySpec(int *frequency,Uint16 *format,int *channels);"
    <cCall: 'Mix_QuerySpec' returning: #int 
        args: #( #cObject #cObject #cObject )>!

mixLoadWavRW: aCobject0 freeSrc: aInt1
    "I load a wav file. My C function call prototype:

    extern DECLSPEC Mix_Chunk * SDLCALL Mix_LoadWAV_RW(SDL_RWops *src, int freesrc);"
    <cCall: 'Mix_LoadWAV_RW' returning: #cObject 
        args: #( #cObject #int )>!

mixLoadMus: aString0 
    "I load a music file. My C function call prototype:

    extern DECLSPEC Mix_Music * SDLCALL Mix_LoadMUS(const char *file);"
    <cCall: 'Mix_LoadMUS' returning: #cObject 
        args: #( #string  )>!

mixLoadMusRW: cObject0
    "I load a music file. My C function call prototype:

    extern DECLSPEC Mix_Music * SDLCALL Mix_LoadMUS_RW(SDL_RWops *rw);"
    <cCall: 'Mix_LoadMUS_RW' returning: #cObject 
        args: #( #cObject )>!

mixQuickLoadWav: aCobject0 
    "I load a wave file of the mixer format from a memory buffer. My C
    function call prototype:

    extern DECLSPEC Mix_Chunk * SDLCALL Mix_QuickLoad_WAV(Uint8 *mem);"
    <cCall: 'Mix_QuickLoad_WAV' returning: #cObject 
        args: #( #cObject  )>!

mixQuickLoadRaw: aCobject0 len: aUint1 
    "I load raw audio data of the mixer format from a memory
    buffer. My C function call prototype:

    extern DECLSPEC Mix_Chunk * SDLCALL Mix_QuickLoad_RAW(Uint8 *mem, Uint32 len);"
    <cCall: 'Mix_QuickLoad_RAW' returning: #cObject 
        args: #( #cObject #uInt  )>!

mixFreeChunk: aCobject0
    "I free a previously loaded audio chunk. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_FreeChunk(Mix_Chunk *chunk);"
    <cCall: 'Mix_FreeChunk' returning: #void 
        args: #( #cObject )>!

mixFreeMusic: aCobject0
    "I free a previously loaded audio chunk. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_FreeMusic(Mix_Music *music);"
    <cCall: 'Mix_FreeMusic' returning: #void 
        args: #( #cObject )>!

mixGetMusicType: aCobject0 
    "I answer the music format of a mixer music. My C function call prototype:

    extern DECLSPEC Mix_MusicType SDLCALL Mix_GetMusicType(const Mix_Music *music);"
    <cCall: 'Mix_GetMusicType' returning: #cObject 
        args: #( #cObject  )>!

mixSetPostMix: aCobject0 uData: aCobject1 stream: aCobject2 len: aInt3
    "I set a function that is called after all mixing is performed. My
    C function call prototype:

    extern DECLSPEC void SDLCALL Mix_SetPostMix(void (*mix_func) (void *udata, Uint8 *stream, int len), void *arg)"
    <cCall: 'Mix_SetPostMix' returning: #void 
        args: #( #cObject #cObject #cObject #int )>!

mixHookMusic: aCobject0 uData: aCobject1 stream: aCobject2 len: aInt2 arg: aCobject3
    "I add my own music player or additional mixer function. My C
    function call prototype:

    extern DECLSPEC void SDLCALL Mix_HookMusic(void (*mix_func) (void *udata, Uint8 *stream, int len), void *arg);"
    <cCall: 'Mix_HookMusic' returning: #void 
        args: #( #cObject #cObject #cObject #int #cObject )>!

mixHookMusicFinished: aCobject0
    "I add a callback to be called when the music has finished
    playing. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_HookMusicFinished(void (*music_finished)(void));"
    <cCall: 'Mix_HookMusicFinished' returning: #void 
        args: #( #cObject )>!

mixGetMusicHookData
    "I answer a pointer to the user data for the current music
    hook. My C function call prototype:

    extern DECLSPEC void * SDLCALL Mix_GetMusicHookData(void);"
    <cCall: 'Mix_GetMusicHookData' returning: #cObject 
        args: #( )>!

mixChannelFinished: aCobject0
    "I add a callback to be called when a channel has finished
    playing. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_ChannelFinished(void (*channel_finished)(int channel));"
    <cCall: 'Mix_ChannelFinished' returning: #void 
        args: #( #cObject )>!

mixRegisterEffect: aInt0 f: aCobject1 d: aInt2 arg: aCobject3
    "I register a special effect function. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_RegisterEffect(int chan, Mix_EffectFunc_t f, Mix_EffectDone_t d, void *arg);"
    <cCall: 'Mix_RegisterEffect' returning: #int 
        args: #( #int #cObject #int #cObject )>!

mixUnregisterEffect: aInt0 f: aCobject1
    "I stop an effect from processing in the middle of a chunk's
    playback. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_UnregisterEffect(int channel, Mix_EffectFunc_t f);"
    <cCall: 'Mix_UnregisterEffect' returning: #int 
        args: #( #int #cObject )>!

mixSetPanning: aInt0 left: aUchar1 right: aUchar2
    "I set the panning of a channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_SetPanning(int channel, Uint8 left, Uint8 right);"
    <cCall: 'Mix_SetPanning' returning: #int 
        args: #( #int #char #char )>!

mixSetPosition: aInt0 angle: aInt1 distance: aUchar
    "I set the position of a channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_SetPosition(int channel, Sint16 angle, Uint8 distance);"
    <cCall: 'Mix_SetPosition' returning: #int 
        args: #( #int #int #char )>!

mixSetDistance: aInt0 distance: aUchar
    "I set the distance of a channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_SetDistance(int channel, Uint8 distance);"
    <cCall: 'Mix_SetDistance' returning: #int 
        args: #( #int #char )>!

mixSetReverseStereo: aInt0 flip: aInt1
    "I reverse the stereo channels. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_SetReverseStereo(int channel, int flip);"
    <cCall: 'Mix_SetReverseStereo' returning: #int 
        args: #( #int #int )>!

mixReserveChannels: aInt0
    "I reserve channels for my own use. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_ReserveChannels(int num);"
    <cCall: 'Mix_ReserveChannels' returning: #int 
        args: #( #int )>!

mixGroupChannel: aInt0 tag: aInt1
    "I attach a tag to a channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_GroupChannel(int which, int tag);"
    <cCall: 'Mix_GroupChannel' returning: #int 
        args: #( #int #int )>!

mixGroupChannels: aInt0 to: aInt1 tag: aInt2
    "I assign several consecutive channels to a group. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_GroupChannels(int from, int to, int tag);"
    <cCall: 'Mix_GroupChannels' returning: #int 
        args: #( #int #int #int )>!

mixGroupAvailable: aInt0
    "I answer the first available channel in a group of channels. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_GroupAvailable(int tag);"
    <cCall: 'Mix_GroupAvailable' returning: #int 
        args: #( #int )>!

mixGroupCount: aInt0
    "I answer the number of channels in a group. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_GroupCount(int tag);"
    <cCall: 'Mix_GroupCount' returning: #int 
        args: #( #int )>!

mixGroupOldest: aInt0
    "I answer the oldest sample playing in a group of channels. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_GroupOldest(int tag);"
    <cCall: 'Mix_GroupOldest' returning: #int 
        args: #( #int )>!

mixGroupNewer: aInt0
    "I answer the most recent sample playing in a group of
    channels. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_GroupNewer(int tag);"
    <cCall: 'Mix_GroupNewer' returning: #int 
        args: #( #int )>!

mixPlayChannelTimed: int chunk: aCobject1 loops: aInt2 ticks: aInt3 
    "I play an audio chunk on a specific channel for upto the number
    of ms given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_PlayChannelTimed(int channel, Mix_Chunk *chunk, int loops, int ticks);"
    <cCall: 'Mix_PlayChannelTimed' returning: #int 
        args: #( #int #cObject #int #int )>!

mixPlayMusic: aCobject0 loops: aInt0
    "I play an audio chunk for the number of loops given to me. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_PlayMusic(Mix_Music *music, int loops);"
    <cCall: 'Mix_PlayMusic' returning: #int 
        args: #( #cObject #int )>!

mixFadeInMusic: aCobject0 loops: aInt1 loops: aInt2 ms: aInt3
    "I fade in music or a channel over the number milliseconds given
    to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_FadeInMusic(Mix_Music *music, int loops, int ms);"
    <cCall: 'Mix_FadeInMusic' returning: #int 
        args: #( #cObject #int #int #int )>!

mixFadeInMusicPos: aCobject0 loops: aInt1 ms: aInt2 position: aDouble3
    "I fade in music or a channel over the number milliseconds given
    to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_FadeInMusicPos(Mix_Music *music, int loops, int ms, double position);"
    <cCall: 'Mix_FadeInMusicPos' returning: #int 
        args: #( #cObject #int #int #double )>!

mixFadeInChannelTimed: aInt0 chunk: aCobject1 loops: aInt2 ms: aInt3 ticks: aInt4
    "I fade in music or a channel over the number milliseconds given
    to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_FadeInChannelTimed(int channel, Mix_Chunk *chunk, int loops, int ms, int ticks);"
    <cCall: 'Mix_FadeInChannelTimed' returning: #int 
        args: #( #int #cObject #int #int #int )>!

mixVolume: aInt0 volume: aInt1
    "I set the volume in the range of 0-128 for the channel
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_Volume(int channel, int volume);"
    <cCall: 'Mix_Volume' returning: #int 
        args: #( #int #int )>!

mixVolumeChunk: aCobject0 volume: aInt1
    "I set the volume in the range of 0-128 for the
    chunk given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_VolumeChunk(Mix_Chunk *chunk, int volume);"
    <cCall: 'Mix_VolumeChunk' returning: #int 
        args: #( #cObject #int )>!

mixVolumeMusic: aInt0
    "I set the volume in the range of 0-128 of a specific channel or
    chunk given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_VolumeMusic(int volume);"
    <cCall: 'Mix_VolumeMusic' returning: #int 
        args: #( #int )>!

mixHaltChannel: aInt0
    "I halt playing of a particular channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_HaltChannel(int channel);"
    <cCall: 'Mix_HaltChannel' returning: #int 
        args: #( #int )>!

mixHaltGroup: aInt0
    "I halt playing of a particular channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_HaltGroup(int tag);"
    <cCall: 'Mix_HaltGroup' returning: #int 
        args: #( #int )>!

mixHaltMusic
    "I halt playing of a particular channel. My C function call prototype:

    extern DECLSPEC int SDLCALL Mix_HaltMusic(void);"
    <cCall: 'Mix_HaltMusic' returning: #int 
        args: #( )>!

mixExpireChannel: aInt0 ticks: aInt1
    "I change the expiration delay for a the channel given to me. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_ExpireChannel(int channel, int ticks);"
    <cCall: 'Mix_ExpireChannel' returning: #int 
        args: #( #int #int )>!

mixFadeOutChannel: aInt0 ms: aInt1
    "I halt a channel, fading it out progressively over the number of
    milliseconds given to me until it's silent. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_FadeOutChannel(int which, int ms);"
    <cCall: 'Mix_FadeOutChannel' returning: #int 
        args: #( #int #int )>!

mixFadeOutGroup: aInt0 ms: aInt1
    "I halt a group of channels, fading them out progressively over
    the number of milliseconds given to me until they're silent. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_FadeOutGroup(int tag, int ms);"
    <cCall: 'Mix_FadeOutGroup' returning: #int 
        args: #( #int #int )>!

mixFadeOutMusic: aInt0
    "I halt a channel, fading it out progressively over the number of
    milliseconds given to me until it's silent. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_FadeOutMusic(int ms);"
    <cCall: 'Mix_FadeOutMusic' returning: #int 
        args: #( #int )>!

mixFadingMusic
    "I answer the fading status of a channel. My C function call
    prototype:

    extern DECLSPEC Mix_Fading SDLCALL Mix_FadingMusic(void);"
    <cCall: 'Mix_FadingMusic' returning: #cObject 
        args: #( )>!

mixFadingChannel: aInt0 
    "I answer the fading status of a group of channels. My C function
    call prototype:

    extern DECLSPEC Mix_Fading SDLCALL Mix_FadingChannel(int which);"
    <cCall: 'Mix_FadingChannel' returning: #cObject 
        args: #( #int  )>!

mixPause: aInt0
    "I pause the channel given to me. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_Pause(int channel);"
    <cCall: 'Mix_Pause' returning: #void 
        args: #( #int )>!

mixResume: aInt0
    "I resume the channels given to me. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_Resume(int channel);"
    <cCall: 'Mix_Resume' returning: #void 
        args: #( #int )>!

mixPaused: aInt0
    "I answer if the channel given to me is paused. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_Paused(int channel);"
    <cCall: 'Mix_Paused' returning: #int 
        args: #( #int )>!

mixPauseMusic
    "I pause the active channel. My C function call prototype:    

    extern DECLSPEC void SDLCALL Mix_PauseMusic(void);"
    <cCall: 'Mix_PauseMusic' returning: #void 
        args: #( )>!

mixResumeMusic
    "I resume the active channel. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_ResumeMusic(void);"
    <cCall: 'Mix_ResumeMusic' returning: #void 
        args: #( )>!

mixRewindMusic
    "I rewind the active channel. My C function call prototype:

    extern DECLSPEC void SDLCALL Mix_RewindMusic(void);"
    <cCall: 'Mix_RewindMusic' returning: #void 
        args: #( )>!

mixPausedMusic
    "I answer if the active channel is paused. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_PausedMusic(void);"
    <cCall: 'Mix_PausedMusic' returning: #int 
        args: #( )>!

mixSetMusicPosition: aDouble0
    "I set the set the current position in the music stream. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_SetMusicPosition(double position);"
    <cCall: 'Mix_SetMusicPosition' returning: #int 
        args: #( #double )>!

mixPlaying: aInt0
    "I check the status of a specific channel. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_Playing(int channel);"
    <cCall: 'Mix_Playing' returning: #int 
        args: #( #int )>!

mixPlayingMusic
    "I check the status of a specific channel. My C function call
    prototype:

    extern DECLSPEC int SDLCALL Mix_PlayingMusic(void);"
    <cCall: 'Mix_PlayingMusic' returning: #int 
        args: #( )>!

mixSetMusicCMD: aString0
    "I stop the music and set a external music playback command. My C
    function call prototype:

    extern DECLSPEC int SDLCALL Mix_SetMusicCMD(const char *command);"
    <cCall: 'Mix_SetMusicCMD' returning: #int 
        args: #( #string )>!

mixSetSynchroValue: aInt0
    "extern DECLSPEC int SDLCALL Mix_SetSynchroValue(int value);"
    <cCall: 'Mix_SetSynchroValue' returning: #int 
        args: #( #int )>!

mixGetSynchroValue
    "extern DECLSPEC int SDLCALL Mix_GetSynchroValue(void);"
    <cCall: 'Mix_GetSynchroValue' returning: #int 
        args: #( )>!

mixGetChunk: aInt0 
    "I answer the Mix_Chunk currently associated with a mixer
    channel. My C function call prototype:

    extern DECLSPEC Mix_Chunk * SDLCALL Mix_GetChunk(int channel);"
    <cCall: 'Mix_GetChunk' returning: #cObject 
        args: #( #int  )>!

mixCloseAudio
    "I close the mixer, halting all playing audio. My C function call
    prototype:

    extern DECLSPEC void SDLCALL Mix_CloseAudio(void);"
    <cCall: 'Mix_CloseAudio' returning: #void 
        args: #( )>! !
