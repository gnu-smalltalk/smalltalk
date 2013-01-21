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



ValueAdaptor subclass: NullValueHolder [
    
    <category: 'Language-Data types'>
    <comment: 'I pretend to store my value in a variable, but I don''t actually.
You can use the only instance of my class (returned by `ValueHolder null'')
if you''re not interested in a value that is returned as described in
ValueHolder''s comment.'>

    NullValueHolder class [
	| uniqueInstance |
	
    ]

    NullValueHolder class >> new [
	"Not used -- use `ValueHolder null' instead"

	<category: 'creating instances'>
	^self shouldNotImplement
    ]

    NullValueHolder class >> uniqueInstance [
	"Answer the sole instance of NullValueHolder"

	<category: 'creating instances'>
	^uniqueInstance isNil 
	    ifTrue: [uniqueInstance := self basicNew]
	    ifFalse: [uniqueInstance]
    ]

    value: anObject [
	"Set the value of the receiver. Do nothing, discard the value"

	<category: 'accessing'>
	
    ]

    value [
	"Retrive the value of the receiver. Always answer nil"

	<category: 'accessing'>
	^nil
    ]
]
