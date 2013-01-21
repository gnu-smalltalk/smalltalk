"======================================================================
|
|   ValueAdaptor hierarchy Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
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



PluggableAdaptor subclass: DelayedAdaptor [
    | value delayed |
    
    <category: 'Language-Data types'>
    <comment: 'I can be used where many expensive updates must be performed. My
instances buffer the last value that was set, and only actually set the
value when the #trigger message is sent. Apart from this, I''m equivalent
to PluggableAdaptor.'>

    trigger [
	"Really set the value of the receiver."

	<category: 'accessing'>
	delayed 
	    ifTrue: 
		[delayed := false.
		super value: value]
    ]

    value: anObject [
	"Set the value of the receiver - actually, the value is cached and
	 is not set until the #trigger method is sent."

	<category: 'accessing'>
	value := anObject.
	delayed := true
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	^delayed ifTrue: [value] ifFalse: [getBlock value]
    ]

    getBlock: get putBlock: put [
	<category: 'private'>
	delayed := false.
	^super getBlock: get putBlock: put
    ]
]

