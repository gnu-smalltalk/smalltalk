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

Object subclass: #SdlCdrom
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SdlCdTrack
    declaration: #(
        (#id #uChar)
        (#type #uChar)
        (#unused #uShort)
        (#length #uInt)
        (#offset #uInt))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

CStruct subclass: #SdlCd
    declaration: #(
        (#id #int)
        (#status (#ptr #CObject))
        (#numTracks #int)
        (#curTrack #int)
        (#curFrame #int)
        (#track (#array #byte 9408)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Sound'! !

!SdlCdrom class methodsFor: 'Constants'!

sdlMaxTracks
    ^99!

sdlAudioTrack
    ^16r00!

sdlDataTrack
    ^16r04!

cdTrayEmpty
    ^0!

cdStopped
    ^1!

cdPlaying
    ^2!

cdPaused
    ^3!

cdError
    ^-1!

cdFps
    ^75!

!SdlCdrom class methodsFor: 'C call-outs'!

sdlCdNumDrives
    "I answer the number of CD-ROM drives on the system. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_CDNumDrives(void);"
    <cCall: 'SDL_CDNumDrives' returning: #int
        args: #( )>!

sdlCdName: aInt0
    "I answer a human-readable, system-dependent identifier for the
    CD-ROM.  My C function call prototype:

    extern DECLSPEC const char * SDLCALL SDL_CDName(int drive);"
    <cCall: 'SDL_CDName' returning: #string 
        args: #( #int )>!

sdlCdOpen: aInt0 
    " I Open a CD-ROM drive for access.  I answer a drive handle on
    success, or NULL if the drive was invalid or busy. My C function
    call prototype is:

    extern DECLSPEC SDL_CD * SDLCALL SDL_CDOpen(int drive);"
    <cCall: 'SDL_CDOpen' returning: #cObject 
        args: #( #int  )>!

sdlCdStatus: aCobject0 
    "I answer a human-readable, system-dependent identifier for the
    CD-ROM. My C function call prototype:

    extern DECLSPEC CDstatus SDLCALL SDL_CDStatus(SDL_CD *cdrom);"
    <cCall: 'SDL_CDStatus' returning: #cObject 
        args: #( #cObject  )>!

sdlCdPlayTracks: aCobject0 startTrack: aInt1 startFrame: aInt2 nTracks: aInt3 
    nFrames: aInt4
    "I play the given CD starting at 'start_track' and 'start_frame'
    for 'ntracks' tracks and 'nframes' frames. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_CDPlayTracks(SDL_CD *cdrom,
         int start_track, int start_frame, int ntracks, int nframes);"
    <cCall: 'SDL_CDPlayTracks' returning: #int 
        args: #( #cObject #int #int #int #int )>!

sdlCdPlay: aCobject0 start: aInt1 length: aInt2
    "I play the given CD starting at 'start' frame for 'length'
    frames. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CDPlay(SDL_CD *cdrom, 
         int start, int length);"
    <cCall: 'SDL_CDPlay' returning: #int 
        args: #( #cObject #int #int )>!

sdlCdPause: aCobject0
    "I pause the given CD. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CDPause(SDL_CD *cdrom);"
    <cCall: 'SDL_CDPause' returning: #int 
        args: #( #cObject )>!

sdlCdResume: aCobject0
    "I resume the given CD. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CDResume(SDL_CD *cdrom);"
    <cCall: 'SDL_CDResume' returning: #int 
        args: #( #cObject )>!

sdlCdStop: aObject0
    "I stop the given CD. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CDStop(SDL_CD *cdrom);"
    <cCall: 'SDL_CDStop' returning: #int 
        args: #( #cObject )>!

sdlCdEject
    "I eject the given CD. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CDEject(SDL_CD *cdrom);"
    <cCall: 'SDL_CDEject' returning: #int 
        args: #( #cObject )>!

sdlCdClose: aCobject0
    "I close the given CD. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_CDClose(SDL_CD *cdrom);"
    <cCall: 'SDL_CDClose' returning: #void 
        args: #( #cObject )>! !
