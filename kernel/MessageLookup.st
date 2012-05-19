"======================================================================
|
|   MessageLookup Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2011 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



Message subclass: MessageLookup [
    | startingClass |
    
    <category: 'Language-Implementation'>
    <comment:
'I represent a message lookup: I contain the selector and arguments,
but also the starting class for the search.'>

    MessageLookup class >> selector: aSymbol argument: argumentObject startingClass: startingClass [
	"Create a new instance of the receiver"

	<category: 'creating instances'>
	^(super selector: aSymbol argument: argumentObject) startingClass: startingClass
    ]

    MessageLookup class >> selector: aSymbol arguments: anArray startingClass: startingClass [
	"Create a new instance of the receiver"

	<category: 'creating instances'>
	^(super selector: aSymbol arguments: anArray) startingClass: startingClass
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'basic'>
	super printOn: aStream.
	aStream
	    space; nextPut: $(;
	    print: startingClass;
	    space; nextPut: $)
    ]

    method [
	"Return the method that is the result of the lookup."

	<category: 'basic'>
        ^self startingClass lookupSelector: self selector
    ]

    retrySendTo: receiver [
	"Send the message to the given receiver, looking up the
         method starting at #startingClass."

	<category: 'basic'>
	^receiver perform: self method withArguments: self arguments
    ]

    startingClass: aClass [
	"Change the starting class for the lookup"

	<category: 'accessing'>
	startingClass := aClass
    ]

    startingClass [
	"Answer the starting class for the lookup"

	<category: 'accessing'>
	^startingClass
    ]
]

