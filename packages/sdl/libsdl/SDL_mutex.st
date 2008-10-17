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

Object subclass: #SdlMutex
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlMutex class methodsFor: 'Constants'!

sdlMutexTimedOut
    ^1!

sdlMutexMaxWait
    ^-1!

!SdlMutex class methodsFor: 'C call-outs'!

sdlCreateMutex
    "I create a mutex, initialized unlocked. My C function call
    prototype:

    extern DECLSPEC SDL_mutex * SDLCALL SDL_CreateMutex(void);"
    <cCall: 'SDL_CreateMutex' returning: #cObject 
        args: #( )>!

sdlMutexP: aCobject0
    "I Lock the mutex given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_mutexP(SDL_mutex *mutex);"
    <cCall: 'SDL_mutexP' returning: #int 
        args: #( #cObject )>!

sdlMutexV: aCobject0
    "I unlock the mutex given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_mutexV(SDL_mutex *mutex);"
    <cCall: 'SDL_mutexV' returning: #int  
        args: #( #cObject )>!

sdlDestroyMutex: aCobject0
    "I destroy the mutex given to me. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_DestroyMutex(SDL_mutex *mutex);"
    <cCall: 'SDL_DestroyMutex' returning: #void 
        args: #( #cObject )>!

sdlCreateSemaphore: aUint
    "I create a semaphore, initialized with value. My C function call
    prototype:

    extern DECLSPEC SDL_sem * SDLCALL SDL_CreateSemaphore(Uint32 initial_value);"
    <cCall: 'SDL_CreateSemaphore' returning: #cObject 
        args: #( #uInt  )>!

sdlDestroySemaphore: aCobject0
    "I destroy the semaphore given to me. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_DestroySemaphore(SDL_sem *sem);"
    <cCall: 'SDL_DestroySemaphore' returning: #void 
        args: #( #cObject )>!

sdlSemWait: aCobject0
    "I suspend the calling thread until the semaphore given to me has
    a positive count. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SemWait(SDL_sem *sem);"
    <cCall: 'SDL_SemWait' returning: #int 
        args: #( #cObject )>!

sdlSemTryWait: aCobject0
    "I answer whether or the the semaphore given to me has a positive
    count. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SemTryWait(SDL_sem *sem);"
    <cCall: 'SDL_SemTryWait' returning: #int 
        args: #( #cObject )>!

sdlSemWaitTimeout: aCobject0 ms: aUint
    "I suspend the calling thread until the semaphore given to me has
    a positive count or the timeout given to me occurs. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_SemWaitTimeout(SDL_sem *sem, Uint32 ms);"
    <cCall: 'SDL_SemWaitTimeout' returning: #int 
        args: #( #cObject #uInt )>!

sdlSemPost: aCobject0
    "I atomically increase the count of the semaphore given to me. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SemPost(SDL_sem *sem);"
    <cCall: 'SDL_SemPost' returning: #int 
        args: #( #cObject )>!

sdlSemValue: aCobject0 
    "I answer the current count of the semaphore given to me. My C
    function call prototype:

     extern DECLSPEC Uint32 SDLCALL SDL_SemValue(SDL_sem *sem);"
    <cCall: 'SDL_SemValue' returning: #uInt 
        args: #( #cObject  )>!

sdlCreateCond
    "I create a condition variable. My C function call prototype:

    extern DECLSPEC SDL_cond * SDLCALL SDL_CreateCond(void);"
    <cCall: 'SDL_CreateCond' returning: #cObject 
        args: #( )>!

sdlDestroyCond: aCobject0
    "I destroy a condition variable. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_DestroyCond(SDL_cond *cond);"
    <cCall: 'SDL_DestroyCond' returning: #void 
        args: #( #cObject )>!

sdlCondSignal: aCobject0
    "I restart the thread that is waiting on the condition variable
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondSignal(SDL_cond *cond);"
    <cCall: 'SDL_CondSignal' returning: #int 
        args: #( #cObject )>!

sdlCondBroadcast: aCobject0
    "I restart all threads that are waiting on the condition variable
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondBroadcast(SDL_cond *cond);"
    <cCall: 'SDL_CondBroadcast' returning: #int 
        args: #( #cObject )>!

sdlCondWait: aCobject0 mutex: aCobject1
    "I wait on the condition variable given to me, unlocking the mutex
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondWait(SDL_cond *cond, SDL_mutex *mut);"
    <cCall: 'SDL_CondWait' returning: #int 
        args: #( #cObject #cObject )>!

sdlCondWaitTimeOut: aCobject0 mutex: aCobject1 ms: aUint
    "I wait up to the number of ms given to me on the condition
    variable given to me, unlocking the mutex given to me. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondWaitTimeout(SDL_cond *cond, 
         SDL_mutex *mutex, Uint32 ms);"
    <cCall: 'SDL_CondWaitTimeout' returning: #int 
        args: #( #cObject #cObject #uInt )>! !
