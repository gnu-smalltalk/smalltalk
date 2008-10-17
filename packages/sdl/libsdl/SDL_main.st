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

Object subclass: #SdlMain
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlMain class methodsFor: 'SdlMain'!

"For Windows"
sdlMain: aInt0 argv: aVariadic
    "extern C_LINKAGE int SDL_main(int argc, char *argv[]);"
    <cCall: ' SDL_main' returning: #int 
        args: #(#int #variadic )>!

sdlSetModuleHandle: aCobject0
    "extern DECLSPEC void SDLCALL SDL_SetModuleHandle(void *hInst);"
    <cCall: 'SDL_SetModuleHandle' returning: #void 
        args: #(#cObject )>!

"For Macs"
sdlInitQuickDraw: aCobject0
    "extern DECLSPEC void SDLCALL SDL_InitQuickDraw(struct QDGlobals *the_qd);"
    <cCall: 'SDL_InitQuickDraw' returning: #void 
        args: #(#cObject )>! !
