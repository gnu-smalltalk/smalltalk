"======================================================================
|
|   File autoloading mechanism
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1991,1992,94,95,99,2000,2001,2002,2008
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



nil subclass: Autoload [
    
    <comment: 'I am not a part of the normal Smalltalk kernel class system.  I provide the
ability to do late ("on-demand") loading of class definitions.  Through me,
you can define any class to be loaded when any message is sent to
the class itself (such as to create an instance) or to its metaclass (such
as #methodsFor: to extend it with class-side methods).'>
    <category: 'Examples-Useful tools'>

    Autoload class >> class: nameSymbol from: fileNameString [
	"Make Smalltalk automatically load the class named nameSymbol
	 from fileNameString when needed"

	<category: 'instance creation'>
	^self 
	    class: nameSymbol
	    in: Namespace current
	    from: fileNameString
    ]

    Autoload class >> class: nameSymbol loader: anObject [
	"Make Smalltalk automatically load the class named nameSymbol.
	 When the class is needed, anObject will be sent #autoload.
	 By default, instances of FilePath and Package can be used."

	<category: 'instance creation'>
	^self 
	    class: nameSymbol
	    in: Namespace current
	    loader: anObject
    ]

    Autoload class >> class: nameSymbol in: aNamespace from: fileNameString [
	"Make Smalltalk automatically load the class named nameSymbol
	 and residing in aNamespace from fileNameString when needed"

	<category: 'instance creation'>
	| file |
	"Check if the file exists."
        file := fileNameString asFile.
	file withReadStreamDo: [ :rs | ].

	"Turn the metaclass into an instance of AutoloadClass.  To do
	 this we create a `prototype' in the form of an array and then..."
        ^self class: nameSymbol in: aNamespace loader: file
    ]

    Autoload class >> class: nameSymbol in: aNamespace loader: anObject [
	"Make Smalltalk automatically load the class named nameSymbol
	 and residing in aNamespace.  When the class is needed, anObject
         will be sent #autoload.  By default, instances of FilePath and
         Package can be used."

	<category: 'instance creation'>
	| autoload |
        autoload := Kernel.AutoloadClass class: nameSymbol in: aNamespace loader: anObject.
	^aNamespace at: nameSymbol put: autoload
    ]

    class [
	"We need it to access the metaclass instance, because that's what
	 will load the file."

	<category: 'accessing'>
	<primitive: VMPrimitives.VMpr_Object_class>
    ]

    doesNotUnderstand: aMessage [
	"Load the class and resend the message to it"

	<category: 'accessing'>
	^aMessage reinvokeFor: self class loadedClass_
    ]
]

