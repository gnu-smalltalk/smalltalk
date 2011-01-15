"======================================================================
|
|   Dynamic Loader Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2005,2008,2009
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



Namespace current: Kernel [

Stream subclass: RoundRobinStream [
    | stream first last |
    
    <category: 'Language-C interface'>
    <comment: 'This class implements a peculiar stream that optimizes the order
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
so this avoids looking for symbols in the wrong library.'>

    RoundRobinStream class >> test: s get: n [
	<category: 'demo'>
	n timesRepeat: [s next print].
	Transcript nl
    ]

    RoundRobinStream class >> test: s leaveAfter: n [
	<category: 'demo'>
	| i |
	i := 0.
	s do: 
		[:each | 
		each print.
		(i := i + 1) = n 
		    ifTrue: 
			[Transcript nl.
			^nil]].
	Transcript nl
    ]

    RoundRobinStream class >> testOn: anArray [
	"RoundRobinStream testOn: #(1 2 3 4 5 6)"

	<category: 'demo'>
	| s |
	s := RoundRobinStream on: anArray readStream.
	self test: s get: anArray size + 1.
	self test: s get: anArray size + 1.
	self test: s get: (anArray size + 1) * 2.
	self test: s get: 2.
	self test: s leaveAfter: anArray size + 1.
	self test: s leaveAfter: anArray size + 1.
	self test: s leaveAfter: 1.
	self test: s leaveAfter: 1.
	self test: s leaveAfter: 2.
	self test: s leaveAfter: 2.
	self test: s leaveAfter: anArray size + 1.
	self test: s leaveAfter: anArray size + 1.
	Transcript nl
    ]

    RoundRobinStream class >> on: aStream [
	<category: 'accessing'>
	^self new stream: aStream
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    atEnd [
	<category: 'basic'>
	stream atEnd 
	    ifTrue: 
		[stream reset.
		"If there is no established first, we started iterating from the
		 first element in the stream."
		first isNil ifTrue: [^true]].
	^(last := stream peek) == first
    ]

    next [
	<category: 'basic'>
	^self atEnd 
	    ifTrue: [SystemExceptions.EndOfStream signalOn: self]
	    ifFalse: [stream next]
    ]

    do: aBlock [
	"Iterate on all the items in the Stream.  If it is not the first iteration,
	 and the last item was retrieved with #next or passed to a #do: block *that
	 did a global return*, return from there."

	<category: 'basic'>
	stream atEnd 
	    ifTrue: 
		[stream reset.
		stream atEnd ifTrue: [^self]].

	"Establish the item at which we'll stop iterating.  Start from that one."
	last isNil ifTrue: [last := stream next].
	first := last.
	aBlock value: last.
	super do: aBlock.

	"Make sure we will not restart from the last item we passed to aBlock,
	 because aBlock did not return."
	last := nil
    ]
]

]



Object subclass: DLD [
    
    <category: 'Language-C interface'>
    <comment: '...and Gandalf said:
``Many folk like to know beforehand what is to be set on the
table; but those who have laboured to prepare the feast like
to keep their secret; for wonder makes the words of praise
louder.''''

I am just an ancillary class used to reference some C functions.
Most of my actual functionality is used by redefinitions of methods
in CFunctionDescriptor.'>

    DLD class [
	| libraryList libraryStream moduleList |
	
    ]

    DLD class >> linkFile: aFileName [
	"Private-used by addLibrary: and addModule:."
	<category: 'private-C call-outs'>
	<cCall: 'dldLink' returning: #cObject args: #(#string)>
	
    ]

    DLD class >> library: libHandle getFunc: aFuncString [
	"Private-used for library searches."
	<category: 'private-C call-outs'>
	<cCall: 'dldGetFunc' returning: #cObject args: #(#cObject #string)>
	
    ]

    DLD class >> defineCFunc: aName as: aFuncAddr [
	"Register aFuncAddr as the target for cCalls to aName."
	<category: 'C call-outs'>
	<cCall: 'defineCFunc' returning: #void args: #(#string #cObject)>
	
    ]

    DLD class >> defineExternFunc: aFuncName [
	"This method calls #primDefineExternFunc: to try to link to a function with
	 the given name, and answers whether the linkage was successful. You can
	 redefine this method to restrict the ability to do dynamic linking."

	<category: 'dynamic linking'>
	^self primDefineExternFunc: aFuncName
    ]

    DLD class >> primDefineExternFunc: aFuncName [
	"This method tries to link to a function with the given name, and answers
	 whether the linkage was successful. It should not be overridden."

	<category: 'dynamic linking'>
	| couldNotLink |
	libraryStream do: 
		[:lib | 
		| funcAddr |
		lib value notNil 
		    ifTrue: 
			[funcAddr := self library: lib value getFunc: aFuncName.
			funcAddr notNil 
			    ifTrue: 
				[self defineCFunc: aFuncName as: funcAddr.
				^true]]].
	^false
    ]

    DLD class >> initialize [
	"Private - Initialize the receiver's class variables"

	<category: 'dynamic linking'>
	libraryList := OrderedCollection new.
	libraryStream := Kernel.RoundRobinStream on: libraryList readStream.
	moduleList := OrderedCollection new.
    ]

    DLD class >> update: aspect [
	"Called on startup - Make DLD re-link and reset the addresses of
	 all the externally defined functions"

	<category: 'dynamic linking'>
	| notLoaded |
	aspect == #returnFromSnapshot ifFalse: [^self].
	libraryList := libraryList reject: [:lib | lib key isNil].
	libraryList do: [:lib | lib value: (self linkFile: lib key)].
	notLoaded := WriteStream on: Array new.
	moduleList 
	    do: [:each | (self linkFile: each) isNil ifTrue: [notLoaded nextPut: each]].
	notLoaded := notLoaded contents.
	notLoaded isEmpty 
	    ifFalse: 
		[SystemExceptions.CInterfaceError 
		    signal: 'modules ' , notLoaded printString , ' could not be loaded.']
    ]

    DLD class >> libraryList [
	"Answer a copy of the search path of libraries to be used by DLD"

	<category: 'dynamic linking'>
	^(libraryList select: [:each | each key notNil])
	    collect: [:each | each key]
    ]

    DLD class >> moduleList [
	"Answer a copy of the modules reloaded when the image is started"

	<category: 'dynamic linking'>
	^moduleList copy
    ]

    DLD class >> addLibrary: library [
	"Add library to the search path of libraries to be used by DLD."

	<category: 'dynamic linking'>
	(libraryList anySatisfy: [:anAssociation | anAssociation key = library]) 
	    ifFalse: 
		[libraryList add: library -> (self linkFile: library).
		libraryStream := Kernel.RoundRobinStream on: libraryList readStream]
    ]

    DLD class >> addLibraryHandle: libraryHandle [
	"This is called internally by gst_dlopen.  The library will
	 be open and put in the search path."

	<category: 'dynamic linking'>
	libraryList add: nil -> libraryHandle.
	libraryStream := Kernel.RoundRobinStream on: libraryList readStream
    ]

    DLD class >> addModule: library [
	"Add library to the list of modules to be loaded when the image is
	 started.  The gst_initModule function in the library is called,
	 but the library will not be put in the search path used whenever
	 a C function is requested but not registered."

	<category: 'dynamic linking'>
	(moduleList includes: library) 
	    ifFalse: 
		[(self linkFile: library) isNil 
		    ifTrue: 
			[SystemExceptions.CInterfaceError 
			    signal: 'requested module ' , library , ' was not found']
		    ifFalse: [moduleList add: library]]
    ]
]



CFunctionDescriptor class extend [

    addressOf: function [
	"Answer whether a function is registered (on the C side) with the
	 given name or is dynamically loadable."

	<category: 'testing'>
	<primitive: VMpr_CFuncDescriptor_addressOf>
	^(DLD defineExternFunc: function) 
	    ifTrue: [self addressOf: function] "Try again."
	    ifFalse: [CObject new]
    ]

]



Eval [
    DLD initialize
]

