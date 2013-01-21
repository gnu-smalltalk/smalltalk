"=====================================================================
|
|   Weak collections
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2007,2008,2009 Free Software Foundation, Inc.
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



Dictionary subclass: WeakKeyDictionary [
    | keys |
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain Dictionary, but my keys are stored
in a weak array; I track which of them are garbage collected and, as
soon as I encounter one of them, I swiftly remove all the associations
for the garbage collected keys'>

    WeakKeyDictionary class >> postLoad [
	"Called after loading an object; must restore it to the state before
	 `preStore' was called.  Make it weak again"

	<category: 'hacks'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [(self primAt: i) makeEphemeron]]
    ]

    add: anAssociation [
	"Store value as associated to the given key."

	<category: 'accessing'>
	| assoc |
	assoc := anAssociation.
	((assoc isKindOf: HomedAssociation) and: [assoc environment == self]) 
	    ifFalse: 
		[assoc := HomedAssociation 
			    key: assoc key
			    value: assoc value
			    environment: self].
	assoc makeEphemeron.
	^super add: assoc
    ]

    at: key put: value [
	"Store value as associated to the given key."

	<category: 'accessing'>
	| assoc |
	assoc := HomedAssociation 
		    key: key
		    value: value
		    environment: self.
	assoc makeEphemeron.
	self add: assoc.
	^value
    ]
]
