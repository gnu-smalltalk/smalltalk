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



Object subclass: ValueAdaptor [
    
    <category: 'Language-Data types'>
    <comment: 'My subclasses are used to access data from different objects with a consistent
protocol. However, I''m an abstract class.'>

    ValueAdaptor class >> new [
	"We don't know enough of subclasses to have a shared implementation of new"

	<category: 'creating instances'>
	self shouldNotImplement
    ]

    printOn: aStream [
	"Print a representation of the receiver"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $(;
	    print: self value;
	    nextPut: $)
    ]

    value: anObject [
	"Set the value of the receiver. Must be implemented by ValueAdaptor's
	 subclasses"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    value [
	"Retrive the value of the receiver. Must be implemented by ValueAdaptor's
	 subclasses"

	<category: 'accessing'>
	self subclassResponsibility
    ]
]
