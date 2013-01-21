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



ValueAdaptor subclass: ValueHolder [
    | value |
    
    <category: 'Language-Data types'>
    <comment: 'I store my value in a variable. For example, you can use me to pass
numbers by reference. Just instance me before calling a method and ask for
my value after that method. There are a lot of other creative uses for
my intances, though.'>

    ValueHolder class >> new [
	"Create a ValueHolder whose starting value is nil"

	<category: 'creating instances'>
	^self basicNew initialize
    ]

    ValueHolder class >> null [
	"Answer the sole instance of NullValueHolder"

	<category: 'creating instances'>
	^NullValueHolder uniqueInstance
    ]

    ValueHolder class >> with: anObject [
	"Create a ValueHolder whose starting value is anObject"

	<category: 'creating instances'>
	^self new value: anObject
    ]

    value: anObject [
	"Set the value of the receiver."

	<category: 'accessing'>
	value := anObject
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	^value
    ]

    initialize [
	"Private - set the initial value of the receiver"

	<category: 'initializing'>
	value := nil
    ]
]

