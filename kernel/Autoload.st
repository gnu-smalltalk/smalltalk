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



Namespace current: Kernel [

nil subclass: AutoloadClass [
    | superClass methodDictionary instanceSpec subClasses instanceVariables environment name fileName |
    
    <comment: 'I represent the metaclass of an autoloaded class before it is autoloaded.
Having a proxy for the metaclass as well allows one to send messages to
the metaclass (such as #methodsFor: to extend it with class-side methods)
and have the class autoloaded.'>
    <category: 'Examples-Useful tools'>

    name [
	"Answer the name of the class to be autoloaded"

	<category: 'accessing'>
	^name
    ]

    name: aSymbol [
	"Set to aSymbol the name of the class to be autoloaded"

	<category: 'accessing'>
	name := aSymbol
    ]

    environment [
	"Answer the namespace in which the class will be autoloaded"

	<category: 'accessing'>
	^environment
    ]

    environment: aNamespace [
	"Set to aNamespace the namespace in which the class will be autoloaded"

	<category: 'accessing'>
	environment := aNamespace
    ]

    fileName [
	"Answer the name of the file from which the class will be autoloaded"

	<category: 'accessing'>
	^fileName
    ]

    fileName: aString [
	"Set to aString the name of the file from which the class will be autoloaded"

	<category: 'accessing'>
	fileName := aString
    ]

    doesNotUnderstand: aMessage [
	"Load the class and resend the message to its metaclass."

	<category: 'accessing'>
	^aMessage reinvokeFor: self loadedMetaclass
    ]

    loadedMetaclass [
	"File-in the file and answer the metaclass for the new value of the
	 association which held the receiver"

	<category: 'accessing'>
	^self loadedClass class
    ]

    loadedClass [
	"File-in the file and answer the new value of the association which
	 held the receiver"

	<category: 'accessing'>
	| class file |
	self fileName isNil 
	    ifFalse: 
		[file := self fileName.
		self fileName: nil.
		self environment at: self name put: nil.
		FileStream fileIn: file].
	class := self environment at: self name ifAbsent: [nil].
	class isNil 
	    ifTrue: 
		[^Autoload error: 'Autoloaded file should have defined class "' , name 
			    , '" but didn''t'].
	^class
    ]
]

]



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

    Autoload class >> class: nameSymbol in: aNamespace from: fileNameString [
	"Make Smalltalk automatically load the class named nameSymbol
	 and residing in aNamespace from fileNameString when needed"

	<category: 'instance creation'>
	"Check if the file exists."

	| autoload behavior newClass |
	(FileDescriptor open: fileNameString mode: FileStream read) close.

	"Create the metaclass and its sole instance"
	behavior := Behavior new superclass: Autoload.

	"Turn the metaclass into an instance of AutoloadClass.  To do
	 this we create a `prototype' in the form of an array and then..."
	newClass := Array new: Kernel.AutoloadClass allInstVarNames size.
	1 to: behavior class instSize
	    do: [:i | newClass at: i put: (behavior instVarAt: i)].

	"... change its class magically."
	newClass changeClassTo: Kernel.AutoloadClass.

	"We can now initialize it."
	newClass
	    name: nameSymbol;
	    fileName: fileNameString;
	    environment: aNamespace.

	"Now create the instance.  We go through some hops because of
	 the very limited set of messages that these classes know
	 about."
	autoload := behavior new.
	behavior become: newClass.
	^aNamespace at: nameSymbol put: autoload
    ]

    class [
	"We need it to access the metaclass instance, because that's what
	 will load the file."

	<category: 'accessing'>
	<primitive: VMpr_Object_class>
	
    ]

    doesNotUnderstand: aMessage [
	"Load the class and resend the message to it"

	<category: 'accessing'>
	^aMessage reinvokeFor: self class loadedClass
    ]
]

