"======================================================================
|
|   BlockContext Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2008
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



ContextPart subclass: BlockContext [
    | outerContext |
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'My instances represent executing Smalltalk blocks, which are portions of
executeable code that have access to the environment that they were declared
in, take parameters, and result from BlockClosure objects created to be
executed by methods outside the current class.  Block contexts are
created by messages sent to compute a closure''s value.  They contain a stack
and also provide some methods that can be used in inspection or debugging.'>

    BlockContext class >> fromClosure: aBlockClosure parent: parentContext [
	"Private - Make a real block context from the given BlockClosure."

	<category: 'private'>
	| cloneTheContextAndFoolTheVM |
	cloneTheContextAndFoolTheVM := 
		[| ctx |
		ctx := thisContext parentContext copy.
		ctx parentContext: parentContext.
		"This value is returned by #fromClosure:parent:!"
		^ctx].

	"The returned context has its ip (or returnIP for the JIT) pointing
	 after the first line, so starting execution in that context has
	 the effect of evaluating the block.
	 Simply initializing the context's instance variable is not enough,
	 because even if we had a way to get the initial native-code IP,
	 the prolog code would need access to the inline cache data.  Such data
	 is most easily provided if the block's evaluation is started by sending
	 #value.  Effectively, we are returning a continuation."
	cloneTheContextAndFoolTheVM value.
	^aBlockClosure value
    ]

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	| home |
	(home := self home) isNil
	    ifTrue: [
		aStream
		    nextPutAll: 'optimized ';
		    display: self method;
		    nextPutAll: ' (';
		    display: self currentFileName;
		    nextPut: $:;
		    display: self currentLineInFile;
		    nextPut: $) ]
	    ifFalse: [
		aStream nextPutAll: '[] in '.
		home
		    printOn: aStream
		    line: self currentLineInFile]
    ]

    isInternalExceptionHandlingContext [
	"Answer whether the receiver is a context that should be hidden to the user
	 when presenting a backtrace.  Such contexts are never blocks, but check
	 the rest of the chain."

	<category: 'debugging'>
	^self parentContext notNil 
	    and: [self parentContext isInternalExceptionHandlingContext]
    ]

    caller [
	"Answer the context that called the receiver"

	<category: 'accessing'>
	^self parentContext
    ]

    isDisabled [
	"Answers false, because contexts that are skipped when doing a return
	 are always MethodContexts.  BlockContexts are removed from the chain
	 whenever a non-local return is done, while MethodContexts need to
	 stay there in case there is a non-local return from the #ensure:
	 block."

	<category: 'accessing'>
	^false
    ]

    isUnwind [
	"Answers whether the context must continue execution even after a
	 non-local return (a return from the enclosing method of a block, or
	 a call to the #continue: method of ContextPart).  Such contexts are
	 created only by #ensure: and are always MethodContexts."

	<category: 'accessing'>
	^false
    ]

    isEnvironment [
	"To create a valid execution environment for the interpreter even before
	 it starts, GST creates a fake context whose selector is nil and which
	 can be used as a marker for the current execution environment.  Answer
	 whether the receiver is that kind of context (always false, since
	 those contexts are always MethodContexts)."

	<category: 'accessing'>
	^false
    ]

    outerContext [
	"Answer the outer block/method context for the receiver"

	<category: 'accessing'>
	^outerContext
    ]

    nthOuterContext: n [
	"Answer the n-th outer block/method context for the receiver"

	<category: 'accessing'>
	| ctx |
	ctx := self.
	n timesRepeat: [ctx := ctx outerContext].
	^ctx
    ]

    isBlock [
	"Answer whether the receiver is a block context"

	<category: 'accessing'>
	^true
    ]

    home [
	"Answer the MethodContext to which the receiver refers, or
	 nil if it has been optimized away"

	<category: 'accessing'>
	^outerContext isNil ifTrue: [nil] ifFalse: [outerContext home]
    ]
]

