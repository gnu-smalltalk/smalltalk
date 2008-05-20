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



CObject subclass: CFunctionDescriptor [
    | cFunctionName returnType argTypes |
    
    <shape: #inherit>
    <category: 'Language-C interface'>
    <comment: 'I am not part of the Smalltalk definition.  My instances contain information
about C functions that can be called from within Smalltalk, such as number
and type of parameters.  This information is used by the C callout mechanism
to perform the actual call-out to C routines.'>

    CFunctionDescriptor class >> mapType: aSymbol [
	"Private - Map a Smalltalk symbols representing a C type to an integer."

	<category: 'private - instance creation'>
	aSymbol isSymbol ifFalse: [
	    SystemExceptions.WrongClass signalOn: aSymbol mustBe: Symbol ].

	^(#(#char #uchar #short #ushort #long #ulong #float #double
	    #string #smalltalk #int #uint #longDouble #unknown #stringOut
	    #symbol #byteArray #byteArrayOut #boolean #void #variadic
	    #variadicSmalltalk #cObject #cObjectPtr #self #selfSmalltalk
	    #wchar #wstring #wstringOut #symbolOut)
		indexOf: aSymbol
		ifAbsent: [ self error: 'invalid C argument type ', aSymbol storeString ]) - 1
    ]

    CFunctionDescriptor class >> mapReturnType: aSymbolOrType [
	"We cannot use polymorphism here or we crash the VM..."

	<category: 'private - instance creation'>
	aSymbolOrType isSymbol ifTrue: [ ^self mapType: aSymbolOrType ].
	(aSymbolOrType isKindOf: Association) ifTrue: [ ^aSymbolOrType ].
	(aSymbolOrType isKindOf: CType) ifTrue: [ ^aSymbolOrType ].
        SystemExceptions.WrongClass signalOn: aSymbolOrType
            mustBe: #(#{Symbol} #{CType} #{Association})
    ]

    CFunctionDescriptor class >> for: funcNameOrAddress returning: returnTypeSymbol withArgs: argsArray [
	"Answer a CFunctionDescriptor with the given function name, return type
	 and arguments.  If funcNameOrAddress is a String, GNU Smalltalk will try
	 to relink it at the next startup.  If it is a CObject, the address will
	 be reset to nil upon image save (and it's the user's task to figure out
	 a why to reinitialize it!)"

	<category: 'instance creation'>
	| result args |
	result := funcNameOrAddress isString
	    ifTrue: [ self new name: funcNameOrAddress; yourself ]
	    ifFalse: [ funcNameOrAddress castTo: self type ].

	"As a side effect, this returns a nice error message."
	args := argsArray asArray collect: [ :each | self mapType: each ].
	result returnType: (self mapReturnType: returnTypeSymbol).
	result argTypes: args.
	^result
    ]

    CFunctionDescriptor class >> addressOf: function [
	"Answer the address (CObject) of the function which is registered (on
	 the C side) with the given name, or zero if no such a function is
	 registered."

	<category: 'testing'>
	<primitive: VMpr_CFuncDescriptor_addressOf>
	^CObject new
    ]

    CFunctionDescriptor class >> isFunction: function [
	"Answer whether a function is registered (on the C side) with the
	 given name."

	<category: 'testing'>
	^(self addressOf: function) address ~= 0
    ]

    name [
	"Answer the name of the function (on the C side) represented by the
	 receiver"

	<category: 'accessing'>
	^cFunctionName
    ]

    name: aString [
	"Set the name of the function (on the C side) represented by the
	 receiver"

	<category: 'accessing'>
	cFunctionName := aString
    ]

    argTypes: anArray [
	<category: 'private - instance creation'>
        argTypes := anArray
    ]

    returnType: anInteger [
	<category: 'private - instance creation'>
        returnType := anInteger
    ]

    isValid [
	"Answer whether the function represented by the receiver is actually
	 a registered one"

	<category: 'accessing'>
	| newAddress |
	self address = 0 ifFalse: [^true].
	newAddress := CFunctionDescriptor addressOf: self name.
	self address: newAddress address.
	^self address ~= 0
    ]

    printOn: aStream [
	"Print a representation of the receiver onto aStream"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $(.

	self name isNil ifFalse: [ aStream nextPutAll: self name ].
	self address = 0 ifFalse: [
	    self name isNil ifFalse: [ aStream nextPutAll: ' @ ' ].
	    aStream nextPutAll: (self address printStringRadix: 16)
	].

	aStream nextPut: $)
    ]

    asyncCall [
	"Perform the call-out for the function represented by the receiver.
	 The arguments (and the receiver if one of the arguments has type
	 #self or #selfSmalltalk) are taken from the parent context.
	 Asynchronous call-outs don't return a value, but if the
	 function calls back into Smalltalk the process that started the
	 call-out is not suspended."

	<category: 'calling'>
	<primitive: VMpr_CFuncDescriptor_asyncCall>
	^self isValid 
	    ifFalse: 
		[SystemExceptions.CInterfaceError signal: 'Invalid C call-out ' , self name]
	    ifTrue: [self asyncCallNoRetryFrom: thisContext parentContext]
    ]

    asyncCallNoRetryFrom: aContext [
	"Perform the call-out for the function represented by the receiver.
	 The arguments (and the receiver if one of the arguments has type
	 #self or #selfSmalltalk) are taken from the base of the stack of
	 aContext.  Asynchronous call-outs don't return a value, but if the
	 function calls back into Smalltalk the process that started the
	 call-out is not suspended.  Unlike #asyncCallFrom:, this method
	 does not attempt to find functions in shared objects."

	<category: 'calling'>
	<primitive: VMpr_CFuncDescriptor_asyncCall>
	self primitiveFailed
    ]

    callInto: aValueHolder [
	"Perform the call-out for the function represented by the receiver.  The
	 arguments (and the receiver if one of the arguments has type
	 #self or #selfSmalltalk) are taken from the parent context, and the
	 the result is stored into aValueHolder.  aValueHolder is also returned."

	<category: 'calling'>
	<primitive: VMpr_CFuncDescriptor_call>
	^self isValid 
	    ifFalse: 
		[SystemExceptions.CInterfaceError signal: 'Invalid C call-out ' , self name]
	    ifTrue: [self callNoRetryFrom: thisContext parentContext into: aValueHolder]
    ]

    callNoRetryFrom: aContext into: aValueHolder [
	"Perform the call-out for the function represented by the receiver.  The
	 arguments (and the receiver if one of the arguments has type
	 #self or #selfSmalltalk) are taken from the base of the stack of
	 aContext, and the result is stored into aValueHolder.  aValueHolder
	 is also returned.  Unlike #callFrom:into:, this method does not
	 attempt to find functions in shared objects."

	<category: 'calling'>
	<primitive: VMpr_CFuncDescriptor_call>
	self primitiveFailed
    ]
]



SystemDictionary extend [

    system: aString [
	<category: 'c call-outs'>
	<cCall: 'system' returning: #int args: #(#string)>
	
    ]

    getenv: aString [
	<category: 'c call-outs'>
	<cCall: 'getenv' returning: #string args: #(#string)>
	
    ]

    putenv: aString [
	<category: 'c call-outs'>
	<cCall: 'putenv' returning: #int args: #(#string)>
	
    ]

    getArgc [
	<category: 'c call-outs'>
	<cCall: 'getArgc' returning: #int args: #()>
	
    ]

    getArgv: index [
	<category: 'c call-outs'>
	<cCall: 'getArgv' returning: #string args: #(#int)>
	
    ]

]

