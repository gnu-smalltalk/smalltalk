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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Object subclass: #DLD
       instanceVariableNames: ''
       classVariableNames: 'LibraryList ModuleList'
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
    
    LibraryList do: [ :lib || funcAddr |
	(lib value notNil or: [
	    lib value: (self linkFile: lib key).
	    lib value notNil ])

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
    ModuleList := OrderedCollection new.
    ObjectMemory addDependent: DLD
!

update: aspect
    "Called on startup - Make DLD re-link and reset the addresses of
     all the externally defined functions"
    | notLoaded |
    aspect == #returnFromSnapshot ifFalse: [ ^self ].
    LibraryList do: [ :each | each value: nil ].

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
       ifFalse: [ LibraryList add: library -> nil ]
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

