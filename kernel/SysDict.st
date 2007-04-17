"======================================================================
|
|   SystemDictionary Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006
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



!SystemDictionary methodsFor: 'builtins'!

basicBacktrace
    "Prints the method invocation stack backtrace, as an aid to debugging"
    <primitive: VMpr_SystemDictionary_backtrace>
    self primitiveFailed
!

backtrace
    "Prints the method invocation stack backtrace, as an aid to debugging"
    <primitive: VMpr_SystemDictionary_backtrace>
    self primitiveFailed
!

getTraceFlag: anIndex
    "Private - Returns a boolean value which is one of the interpreter's
     tracing flags"
    <primitive: VMpr_SystemDictionary_getTraceFlag>
    self primitiveFailed
!

setTraceFlag: anIndex to: aBoolean
    "Private - Sets the value of one of the interpreter's tracing flags
    (indicated by 'anIndex') to the value aBoolean."
    <primitive: VMpr_SystemDictionary_setTraceFlag>
    self primitiveFailed
!

byteCodeCounter
    "Answer the number of bytecodes executed by the VM"
    <primitive: VMpr_SystemDictionary_byteCodeCounter>
!

debug
    "This methods provides a way to break in the VM code.  Set a breakpoint
     in _gst_debug and call this method near the point where you think
     the bug happens."
    <primitive: VMpr_SystemDictionary_debug>
!


"==========================================================================
 These are so useful throughout the loading of the kernel methods that I
 make an exception here and put in real methods instead of just primitives.
 "

executionTrace
    "Answer whether executed bytecodes are printed on stdout"
    ^self getTraceFlag: 1
!

executionTrace: aBoolean
    "Set whether executed bytecodes are printed on stdout"
    ^self setTraceFlag: 1 to: aBoolean
!

declarationTrace
    "Answer whether compiled bytecodes are printed on stdout"
    ^self getTraceFlag: 0
!

declarationTrace: aBoolean
    "Set whether compiled bytecodes are printed on stdout"
    ^self setTraceFlag: 0 to: aBoolean
!

verboseTrace
    "Answer whether execution tracing prints the object on the stack top"
    ^self getTraceFlag: 2
!

verboseTrace: aBoolean
    "Set whether execution tracing prints the object on the stack top"
    ^self setTraceFlag: 2 to: aBoolean
! !




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
!

hostSystem
    "Answer the triplet corresponding to the system for which GNU
     Smalltalk was built."
    ^CSymbols.HostSystem
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

imageLocal
    "Answer whether the kernel directory is a subdirectory of the image
     directory (non-local image) or not."
    ^(File pathFor: Directory kernel) ~= Directory image!

isSmalltalk
    ^true
! !


!SystemDictionary class methodsFor: 'initialization'!

initialize
    Smalltalk addSubspace: #Kernel.
    Smalltalk addFeature: #Kernel.
    KernelInitialized := true! !
