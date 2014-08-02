"=====================================================================
|
|   Smalltalk built in methods.  These are read in by the system 
|   initially, to prepare the execution environment.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007
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


Behavior extend [
    methodsFor: aCategoryString [
        "Calling this method prepares the parser to receive methods
         to be compiled and installed in the receiver's method dictionary.
         The methods are put in the category identified by the parameter."
        <category: 'parsing'>
        <primitive: VMpr_Behavior_methodsFor>
    ]
]

Object extend [
    initialize [
        "Subclasses should redefine this method to perform initializations on
        instance creation"
    ]

    class [
        "Answer the class to which the receiver belongs"
        <primitive: VMpr_Object_class>
        <category: 'builtin'>
        self primitiveFailed 
    ]
]
        

Behavior extend [

    new [
        "Create a new instance of a class with no indexed instance variables"
        <primitive: VMpr_Behavior_newInitialize>
        <category: 'builtin'>
        self isFixed ifFalse: [ ^(self new: 0) ].
        ^self primitiveFailed
    ]

    new: numInstanceVariables [
        "Create a new instance of a class with indexed instance variables. The
        instance has numInstanceVariables indexed instance variables."
        <primitive: VMpr_Behavior_newColonInitialize>
        <category: 'builtin'>
        self isFixed ifTrue: [
            SystemExceptions.WrongMessageSent signalOn: #new: useInstead: #new
        ].
        numInstanceVariables isSmallInteger ifTrue: [ ^self primitiveFailed ].

        ^SystemExceptions.WrongClass signalOn: numInstanceVariables mustBe: SmallInteger
    ]


    basicNew [
        "Create a new instance of a class with no indexed instance variables;
         this method must not be overridden."
        <primitive: VMpr_Behavior_basicNew>
        <category: 'builtin'>
        self isFixed ifFalse: [ ^self basicNew: 0 ].
        ^self primitiveFailed
    ]
    
    basicNew: numInstanceVariables [
        "Create a new instance of a class with indexed instance variables. The
         instance has numInstanceVariables indexed instance variables;
         this method must not be overridden."
        <primitive: VMpr_Behavior_basicNewColon>
        <category: 'builtin'>
        self isFixed ifTrue: [
    	SystemExceptions.WrongMessageSent signalOn: #basicNew: useInstead: #basicNew
        ].
        numInstanceVariables isSmallInteger ifTrue: [ ^self primitiveFailed ].
    
        ^SystemExceptions.WrongClass signalOn: numInstanceVariables mustBe: SmallInteger
    ]
]
    

Dictionary extend [
    
    Dictionary class >> new [
        "Answer a new Dictionary. This method, actually, won't last long -
         until LookupTbl.st is loaded"
        <primitive: VMpr_Dictionary_new>
        <category: 'builtin'>
        ^self primitiveFailed
    ]
    
    at: key [
        "Answer the value associated with the given key in the receiver.
         This method, actually, won't last long - until LookupTbl.st is loaded"
        <primitive: VMpr_Dictionary_at>
        <category: 'builtin'>
        ^self primitiveFailed
    ]
]
    
    

Class extend [
    
    subclass: classNameString environment: aNamespace [
	<category: 'instance creation'>
        ^(aNamespace at: classNameString)
    ]
    
    category: aString [
        "Define a category for the receiver"
    
        category := aString
    ]
    
    comment: aString [
        "Define a comment for the receiver"
    
        comment := aString
    ]
]
    
ClassDescription extend [
    import: aString [
    ]
]
    
Behavior extend [
    instanceVariableNames: ivn [
    ]

    shape: aSymbol [
    ]
]

UndefinedObject extend [
    subclass: classNameString environment: aNamespace [
	<category: 'class polymorphism'>
        ^(aNamespace at: classNameString)
    ]
]
