"======================================================================
|
|   SystemDictionary Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

RootNamespace variableSubclass: #SystemDictionary
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Language-Implementation'
!

SystemDictionary comment: 
'I am a special namespace. I only have one instance, called "Smalltalk",
which is known to the Smalltalk interpreter.  I define
several methods that are "system" related, such as #quitPrimitive.
My instance also helps keep track of dependencies between objects.' !


">>> See also builtins.st for some non-primitive but highly useful
SystemDictionary method definitions."


!SystemDictionary methodsFor: 'basic'!

hash
    "Smalltalk usually contains a reference to itself, avoid infinite
     loops"
    ^self identityHash
!

halt
    "Interrupt interpreter"
    ContextPart unwind
! !


!SystemDictionary methodsFor: 'printing'!

printOn: aStream in: aNamespace
    "Store Smalltalk code compiling to the receiver"
    aStream nextPutAll: 'Smalltalk'.
!

nameIn: aNamespace
    ^'Smalltalk'
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver"
    aStream nextPutAll: 'Smalltalk'.
! !


!SystemDictionary methodsFor: 'miscellaneous'!

arguments
    "Return the command line arguments after the -a switch"
    self getArgc > 0 ifFalse: [ ^#() ].

    ^(1 to: self getArgc)
	collect: [ :i | self getArgv: i ]
!

backtrace
    "Print a backtrace on the Transcript."
    "This replaces the primitive in builtins.st"
    thisContext parentContext backtrace
! !


!SystemDictionary methodsFor: 'special accessing'!

hasFeatures: features
    " Returns true if the feature or features in 'features' is one of the 
      implementation dependent features present"

    (features isKindOf: String)
	ifTrue: [ ^Features includes: features asSymbol ]
	ifFalse: [
	    features do: [ :feature |
		(Features includes: feature asSymbol) ifTrue: [ ^true ]
	    ].
	    ^false
	]
!

addFeature: aFeature
    "Add the aFeature feature to the Features set"
    Features class == Set ifFalse: [ Features := Features asSet ].
    Features add: aFeature asSymbol.
!

removeFeature: aFeature
    "Remove the aFeature feature to the Features set"
    Features class == Set ifFalse: [ Features := Features asSet ].
    Features remove: aFeature ifAbsent: [ ]
!

version
    "Answer the current version of the GNU Smalltalk environment"
    ^Version
! !


!SystemDictionary methodsFor: 'testing'!

isSmalltalk
    ^true
! !
