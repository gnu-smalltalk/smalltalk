"======================================================================
|
|   Dynamic Loader Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2005
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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


Namespace current: Kernel!

Stream subclass: #RoundRobinStream
       instanceVariableNames: 'stream first last'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
!

RoundRobinStream comment:
'This class implements a peculiar stream that optimizes the order
in which symbols are searched in dynamically linked libraries.
When using #next, the stream will restart from the first element
after returning nil once.  When you use #do:, the stream starts
from the *last* element that was either returned by #next or passed
to #do: in the previous iteration.

Since the #primDefineExternFunc: leaves the #do: in advance if it
succeeds in finding a symbol, the next time it will restart from
the library in which it found a symbol.  Usually symbols have a
very good locality (you find all the symbols in a library, or at
least symbols in the same #methodsFor: come from the same library):
so this avoids looking for symbols in the wrong library.'!

!RoundRobinStream class methodsFor: 'demo'!

test: s get: n
    n timesRepeat: [ s next print ].
    Transcript nl.
!

test: s leaveAfter: n
    | i |
    i := 0.
    s do: [ :each |
        each print.
        (i := i + 1) = n ifTrue: [ Transcript nl. ^nil ]
    ].
    Transcript nl.
!

testOn: anArray
    "RoundRobinStream testOn: #(1 2 3 4 5 6)"
    | s |
    s := RoundRobinStream on: anArray readStream.
    self test: s get: anArray size + 1.
    self test: s get: anArray size + 1.
    self test: s get: anArray size + 1 * 2.
    self test: s get: 2.
    self test: s leaveAfter: anArray size + 1.
    self test: s leaveAfter: anArray size + 1.
    self test: s leaveAfter: 1.
    self test: s leaveAfter: 1.
    self test: s leaveAfter: 2.
    self test: s leaveAfter: 2.
    self test: s leaveAfter: anArray size + 1.
    self test: s leaveAfter: anArray size + 1.
    Transcript nl!
! !

!RoundRobinStream class methodsFor: 'accessing'!

on: aStream
    ^self new stream: aStream! !

!RoundRobinStream methodsFor: 'accessing'!

stream
    ^stream!

stream: aStream
    stream := aStream! !

!RoundRobinStream methodsFor: 'basic'!

atEnd
    stream atEnd ifTrue: [
	stream reset.
	"If there is no established first, we started iterating from the
	 first element in the stream."
	first isNil ifTrue: [ ^true ].
    ].
    ^(last := stream peek) = first
!

next
    ^self atEnd
	ifTrue: [ SystemExceptions.EndOfStream signalOn: self ]
	ifFalse: [ stream next ]
!

do: aBlock
    "Iterate on all the items in the Stream.  If it is not the first iteration,
     and the last item was retrieved with #next or passed to a #do: block *that
     did a global return*, return from there."
    stream atEnd
	ifTrue: [
	   stream reset.
	   stream atEnd ifTrue: [ ^self ] ].

    "Establish the item at which we'll stop iterating.  Start from that one."
    last isNil ifTrue: [ last := stream next ].
    first := last.
    aBlock value: last.
    super do: aBlock.

    "Make sure we will not restart from the last item we passed to aBlock,
     because aBlock did not return."
    last := nil.
! !

Namespace current: Smalltalk!

Object subclass: #DLD
       instanceVariableNames: ''
       classVariableNames: 'LibraryList LibraryStream ModuleList'
       poolDictionaries: ''
       category: 'Language-C interface'
!

DLD comment: '...and Gandalf said:
``Many folk like to know beforehand what is to be set on the
table; but those who have laboured to prepare the feast like
to keep their secret; for wonder makes the words of praise
louder.''''

I am just an ancillary class used to reference some C functions.
Most of my actual functionality is used by redefinitions of methods
in CFunctionDescriptor.'!


!DLD class methodsFor: 'C call-outs'!

linkFile: aFileName
    <cCall: 'dldLink' returning: #cObject args: #(#string)>
!

library: libHandle getFunc: aFuncString
    <cCall: 'dldGetFunc' returning: #cObject args: #(#cObject #string)>
!

defineCFunc: aName as: aFuncAddr
    <cCall: 'defineCFunc' returning: #void args: #(#string #cObject)>
! !


!CFunctionDescriptor class methodsFor: 'testing'!

addressOf: function
    "Answer whether a function is registered (on the C side) with the
     given name or is dynamically loadable."

    | descriptor |
    descriptor := self
        for: function
        returning: #void                "dummy"
        withArgs: #().                  "dummy"

    ((descriptor address) address = 0 and: [ DLD defineExternFunc: function ])
	ifTrue: [
	    "Try again."
	    descriptor := self
	        for: function
	        returning: #void                "dummy"
	        withArgs: #().                  "dummy"
	].

    ^descriptor address
! !


!DLD class methodsFor: 'dynamic linking'!

defineExternFunc: aFuncName
    "This method calls #primDefineExternFunc: to try to link to a function with
     the given name, and answers whether the linkage was successful. You can
     redefine this method to restrict the ability to do dynamic linking."
    ^self primDefineExternFunc: aFuncName
!

primDefineExternFunc: aFuncName
    "This method tries to link to a function with the given name, and answers
     whether the linkage was successful. It should not be overridden."
    
    | couldNotLink |
    LibraryStream do: [ :lib || funcAddr |
	lib value notNil
	    ifTrue: [
	        funcAddr := self library: lib value getFunc: aFuncName.
	        funcAddr notNil ifTrue: [ 
		    self defineCFunc: aFuncName as: funcAddr.
		    ^true
	        ]
	    ]
    ].

    ^false
!

initialize
    "Private - Initialize the receiver's class variables"
    LibraryList := OrderedCollection new.
    LibraryStream := Kernel.RoundRobinStream on: LibraryList readStream.
    ModuleList := OrderedCollection new.
    ObjectMemory addDependent: DLD
!

update: aspect
    "Called on startup - Make DLD re-link and reset the addresses of
     all the externally defined functions"
    | notLoaded |
    aspect == #returnFromSnapshot ifFalse: [ ^self ].
    LibraryList do: [ :lib | lib value: (self linkFile: lib key) ].

    notLoaded := WriteStream on: Array new.

    ModuleList do: [ :each |
	(self linkFile: each) isNil ifTrue: [ notLoaded nextPut: each ]
    ].

    notLoaded := notLoaded contents.
    notLoaded isEmpty ifFalse: [
	SystemExceptions.CInterfaceError signal: 'modules ',
		    notLoaded printString, ' could not be loaded.'
    ]!

libraryList
    "Answer a copy of the search path of libraries to be used by DLD"
    ^LibraryList copy
!

moduleList
    "Answer a copy of the modules reloaded when the image is started"
    ^ModuleList copy
!

addLibrary: library
    "Add library to the search path of libraries to be used by DLD."
    (LibraryList anySatisfy: [ :anAssociation | anAssociation key = library ])
	ifFalse: [
	    LibraryList add: library -> (self linkFile: library).
	    LibraryStream := Kernel.RoundRobinStream on: LibraryList readStream ].
!

addModule: library
    "Add library to the list of modules to be loaded when the image is
     started.  The gst_initModule function in the library is called,
     but the library will not be put in the search path used whenever
     a C function is requested but not registered."

    (ModuleList includes: library) ifFalse: [
        (self linkFile: library) isNil
           ifTrue: [
		SystemExceptions.CInterfaceError
		    signal: 'requested module ', library, ' was not found' ]
           ifFalse: [ ModuleList add: library ]
    ]
! !

DLD initialize!

