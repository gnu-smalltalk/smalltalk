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



CCallable subclass: CFunctionDescriptor [
    | cFunctionName |
    
    <shape: #inherit>
    <category: 'Language-C interface'>
    <comment: 'I am not part of the Smalltalk definition.  My instances contain information
about C functions that can be called from within Smalltalk, such as number
and type of parameters.  This information is used by the C callout mechanism
to perform the actual call-out to C routines.'>

    CFunctionDescriptor class >> for: funcName returning: returnTypeSymbol withArgs: argsArray [
	"Answer a CFunctionDescriptor with the given function name, return type
	 and arguments.  funcName must be a String."

	<category: 'instance creation'>
	^(super for: nil returning: returnTypeSymbol withArgs: argsArray)
	    name: funcName;
	    yourself
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

    link [
	"Make the address of the function point to the registered address."

	<category: 'restoring'>
	self address: (CFunctionDescriptor addressOf: self name) address.
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
]



SystemDictionary extend [

    system: aString withArguments: args [
	<category: 'c call-outs'>
	^self system: aString % (args collect: [ :string | string withShellEscapes ])
	
    ]

    system: aString [
	<category: 'c call-outs'>
	<cCall: 'system' returning: #int args: #(#string)>
	
    ]

    getenv: aString [
	<category: 'c call-outs'>
	<cCall: 'getenv' returning: #string args: #(#string)>
	
    ]

    environ [
	<category: 'c call-outs'>
	<cCall: 'environ' returning: #{CString} args: #()>
	
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

