"======================================================================
|
|   CFunctionDescriptor Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005,2008
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



CObject subclass: CCallable [
    | returnType argTypes |
    
    <shape: #inherit>
    <category: 'Language-C interface'>
    <comment: 'I am not part of the Smalltalk definition.  My instances contain information
about C functions that can be called from within Smalltalk, such as number
and type of parameters.  This information is used by the C callout mechanism
to perform the actual call-out to C routines.'>

    CCallable class >> typeMap [
	"Private - Return the map from Smalltalk symbols representing a C type,
	 to an integer."

	<category: 'private - accessing'>
	^##(| reverse dict |
	    reverse := #(#char #uChar #short #uShort #long #uLong #float #double
               #string #smalltalk #int #uInt #longDouble #unknown #stringOut
               #symbol #byteArray #byteArrayOut #boolean #void #variadic
               #variadicSmalltalk #cObject #cObjectPtr #self #selfSmalltalk
               #wchar #wstring #wstringOut #symbolOut #longLong #uLongLong).

           dict := LookupTable new.
           reverse keysAndValuesDo: [ :k :v |
		dict
		    at: v put: k - 1;
		    at: v asLowercase asSymbol put: k - 1 ].
	    dict)
    ]

    CCallable class >> mapType: aSymbolOrType [
	"Private - Map a Smalltalk symbols representing a C type to an integer."

	<category: 'private - instance creation'>
	^self typeMap
	    at: aSymbolOrType
	    ifAbsent: [
		(aSymbolOrType isKindOf: CType) ifTrue: [ ^aSymbolOrType ].
	        aSymbolOrType isSymbol ifFalse: [ ^CType from: aSymbolOrType].
		^self error: 'invalid C argument type ', aSymbolOrType storeString ]
    ]

    CCallable class >> for: aCObject returning: returnTypeSymbol withArgs: argsArray [
	"Answer a CFunctionDescriptor with the given address, return type
	 and arguments.  The address will be reset to NULL upon image save
	 (and it's the user's task to figure out a way to reinitialize it!)"

	<category: 'instance creation'>
	| result |
	result := aCObject isNil
	    ifTrue: [ self new ]
	    ifFalse: [ aCObject castTo: self type ].

	result returnType: returnTypeSymbol.
	result argTypes: argsArray.
	^result
    ]

    argTypes: anArray [
	<category: 'private - initialization'>
        argTypes := anArray asArray collect: [ :arg | self class mapType: arg ]
    ]

    returnType [
	<category: 'accessing'>
        returnType isInteger ifFalse: [ ^returnType ].
        ^self class typeMap at: returnType + 1 ifAbsent: [ returnType ]
    ]

    returnType: aSymbol [
	<category: 'private - initialization'>
        returnType := self class mapType: aSymbol
    ]

    link [
	"Rebuild the object after the image is restarted."

	<category: 'restoring'>
	self subclassResponsibility
    ]

    isValid [
	"Answer whether the object represents a valid function."

	<category: 'accessing'>
	self address = 0 ifFalse: [^true].
	self link.
	^self address ~= 0
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
