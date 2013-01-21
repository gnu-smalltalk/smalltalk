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
    "Warning: instance variable indices appear below in #class:in:from:"
    | superClass methodDictionary instanceSpec subClasses instanceVariables environment name loader |
    
    <comment: 'I represent the metaclass of an autoloaded class before it is autoloaded.
Having a proxy for the metaclass as well allows one to send messages to
the metaclass (such as #methodsFor: to extend it with class-side methods)
and have the class autoloaded.'>
    <category: 'Examples-Useful tools'>

    AutoloadClass class >> class: nameSymbol in: aNamespace loader: anObject [
	| autoload behavior newClass |
	"Create the metaclass and its sole instance"
	behavior := Behavior new superclass: Autoload.

	"Turn the metaclass into an instance of AutoloadClass.  To do
	 this we create a `prototype' in the form of an array..."
	newClass := Array new: Kernel.AutoloadClass allInstVarNames size.
	1 to: behavior class instSize
	    do: [:i | newClass at: i put: (behavior instVarAt: i)].

	newClass
            at: 6 put: aNamespace;
            at: 7 put: nameSymbol;
            at: 8 put: anObject.

	"... and change its class magically after it is initialized."
	newClass changeClassTo: Kernel.AutoloadClass.

	"Now create the instance.  We go through some hops because of
	 the very limited set of messages that these classes know
	 about."
	autoload := behavior new.
	behavior become: newClass.
        ^autoload
    ]

    name [
	"Answer the name of the class to be autoloaded"

	<category: 'accessing'>
	^name
    ]

    environment [
	"Answer the namespace in which the class will be autoloaded"

	<category: 'accessing'>
	^environment
    ]

    doesNotUnderstand: aMessage [
	"Load the class and resend the message to its metaclass."

	<category: 'accessing'>
	^aMessage reinvokeFor: self loadedMetaclass_
    ]

    loadedMetaclass_ [
	"File-in the file and answer the metaclass for the new value of the
	 association which held the receiver"

	<category: 'accessing'>
	^self loadedClass_ class
    ]

    loadedClass_ [
	"File-in the file and answer the new value of the association which
	 held the receiver"

	<category: 'accessing'>
	| class saveLoader |
	loader isNil 
	    ifFalse: 
		[saveLoader := loader.
		loader := nil.
		environment at: name put: nil.
		saveLoader autoload].
	class := environment at: name ifAbsent: [nil].
	class isNil ifTrue: [
            ^Autoload error: '%1 should have defined class %2.%3 but didn''t'
                % {saveLoader. environment. name asString}].
	^class
    ]
]

]

