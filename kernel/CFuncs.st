"======================================================================
|
|   CFunctionDescriptor Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005
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


Object variableSubclass: #CFunctionDescriptor
       instanceVariableNames: 'cFunction cFunctionName returnType numFixedArgs'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
!

CFunctionDescriptor comment: 
'I am not part of the Smalltalk definition.  My instances contain information
about C functions that can be called from within Smalltalk, such as number
and type of parameters.  This information is used by the C callout mechanism
to perform the actual call-out to C routines.' !



!CFunctionDescriptor class methodsFor: 'testing'!

addressOf: function
    "Answer the address (CObject) of the function which is registered (on
     the C side) with the given name, or zero if no such a function is
     registered."
    | descriptor |
    descriptor := self
	for: function
    	returning: #void		"dummy"
	withArgs: #().			"dummy"

    ^descriptor address
!

isFunction: function
    "Answer whether a function is registered (on the C side) with the
     given name."

    ^(self addressOf: function) address ~= 0
! !


!CFunctionDescriptor methodsFor: 'accessing'!

address
    "Answer the address (CObject) of the function represented by
     the receiver"
    ^cFunction
!

address: aCObject
    "Set to aCObject the address of the function represented by
     the receiver"
    cFunction := aCObject
!

name
    "Answer the name of the function (on the C side) represented by the
    receiver"
    ^cFunctionName
!

isValid
    "Answer whether the function represented by the receiver is actually
    a registered one"
    | newAddress |
    cFunction address = 0 ifFalse: [ ^true ].

    newAddress := CFunctionDescriptor addressOf: self name.
    ^newAddress address ~= 0
	ifTrue: [ self address: newAddress ];
	yourself
! !


!CFunctionDescriptor methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver onto aStream"
    aStream
	print: self class;
	nextPut: $(;
	nextPutAll: self name;
	nextPutAll: ' @ ';
	nextPutAll: (self address address printStringRadix: 16);
	nextPut: $)
! !


!CFunctionDescriptor methodsFor: 'calling'!

asyncCallFrom: aContext
    "Perform the call-out for the function represented by the receiver.
     The arguments (and the receiver if one of the arguments has type
     #self or #selfSmalltalk) are taken from the base of the stack of
     aContext.  Asynchronous call-outs don't return a value, but if the
     function calls back into Smalltalk the process that started the
     call-out is not suspended."
    <primitive: VMpr_CFuncDescriptor_asyncCall>

    ^self isValid
        ifFalse: [
	    SystemExceptions.CInterfaceError signal: 'Invalid C call-out ', self name
	]
	ifTrue: [
	    self asyncCallNoRetryFrom: aContext
        ]
!

asyncCallNoRetryFrom: aContext
    "Perform the call-out for the function represented by the receiver.
     The arguments (and the receiver if one of the arguments has type
     #self or #selfSmalltalk) are taken from the base of the stack of
     aContext.  Asynchronous call-outs don't return a value, but if the
     function calls back into Smalltalk the process that started the
     call-out is not suspended.  Unlike #asyncCallFrom:, this method
     does not attempt to find functions in shared objects."
    <primitive: VMpr_CFuncDescriptor_asyncCall>
    self primitiveFailed
!

callFrom: aContext into: aValueHolder
    "Perform the call-out for the function represented by the receiver.  The
     arguments (and the receiver if one of the arguments has type
     #self or #selfSmalltalk) are taken from the base of the stack of
     aContext, and the result is stored into aValueHolder.  aValueHolder
     is also returned."
    <primitive: VMpr_CFuncDescriptor_call>

    ^self isValid
        ifFalse: [
	    SystemExceptions.CInterfaceError signal: 'Invalid C call-out ', self name
	]
	ifTrue: [
	    self callNoRetryFrom: aContext into: aValueHolder
        ]
!

callNoRetryFrom: aContext into: aValueHolder
    "Perform the call-out for the function represented by the receiver.  The
     arguments (and the receiver if one of the arguments has type
     #self or #selfSmalltalk) are taken from the base of the stack of
     aContext, and the result is stored into aValueHolder.  aValueHolder
     is also returned.  Unlike #callFrom:into:, this method does not
     attempt to find functions in shared objects."
    <primitive: VMpr_CFuncDescriptor_call>
    self primitiveFailed
! !

"A couple of simple, but useful callout functions, as examples."

!SystemDictionary methodsFor: 'c call-outs'!

system: aString
    <cCall: 'system' returning: #int args: #(#string)>!

getenv: aString
    <cCall: 'getenv' returning: #string args: #(#string)>!

putenv: aString
    <cCall: 'putenv' returning: #int args: #(#string)>!

getArgc
    <cCall: 'getArgc' returning: #int args: #()>!

getArgv: index
    <cCall: 'getArgv' returning: #string args: #(#int)>! !
