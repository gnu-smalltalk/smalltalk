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

Object subclass: #SdlCPUInfo
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlCPUInfo class methodsFor: 'C call-outs'!

sdlHasRDTSC
    <cCall: 'SDL_HasRDTSC' returning: #boolean
        args: #( )>!

sdlHasMMX
    <cCall: 'SDL_HasMMX' returning: #boolean
        args: #( )>!

sdlHasMMXExt
    <cCall: 'SDL_HasMMXExt' returning: #boolean
        args: #( )>!

sdlHas3DNow
    <cCall: 'SDL_Has3DNow' returning: #boolean
        args: #( )>!

sdlHas3DNowExt
    <cCall: 'SDL_Has3DNowExt' returning: #boolean
        args: #( )>!

sdlHasSSE
    <cCall: 'SDL_HasSSE' returning: #boolean
        args: #( )>!

sdlHasSSE2
    <cCall: 'SDL_HasSSE2' returning: #boolean
        args: #( )>!

sdlHasAltiVec
    <cCall: 'SDL_HasAltiVec' returning: #boolean
        args: #( )>! !
