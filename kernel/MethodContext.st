"======================================================================
|
|   MethodContext Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2007,2008
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



ContextPart subclass: MethodContext [
    | flags |
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'My instances represent an actively executing method.  They record various
bits of information about the execution environment, and contain the
execution stack.'>

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	self printOn: aStream line: self currentLineInFile
    ]

    printOn: aStream line: line [
	"Print a representation for the receiver on aStream, using the
	 given line number and printing aString before the method name."

	<category: 'private-printing'>
	self receiver class printOn: aStream in: Namespace current.
	self receiver class == self methodClass 
	    ifFalse: 
		[aStream nextPut: $(.
		self methodClass printOn: aStream in: Namespace current.
		aStream nextPut: $)].
	aStream
	    nextPutAll: '>>';
	    nextPutAll: self selector.
	self selector = #doesNotUnderstand: 
	    ifTrue: 
		[aStream
		    space;
		    print: (self at: 1) selector].

	aStream
	    nextPutAll: ' (';
	    display: self currentFileName;
	    nextPut: $:;
	    display: line;
	    nextPut: $).

	self isDisabled ifTrue: [aStream nextPutAll: ' <disabled>']
    ]

    isInternalExceptionHandlingContext [
	"Answer whether the receiver is a context that should be hidden to the user
	 when presenting a backtrace.  Such contexts are identified through the
	 #exceptionHandlingInternal: attribute: if there is such a context in
	 the backtrace, all those above it are marked as internal.
	 
	 That is, the attribute being set to true means that the context and all those
	 above it are to be hidden, while the attribute being set to false means
	 that the contexts above it must be hidden, but not the context itself."

	<category: 'debugging'>
	| attr |
	attr := self method attributeAt: #exceptionHandlingInternal:
		    ifAbsent: [nil].
	attr isNil ifFalse: [^attr arguments at: 1].
	self scanBacktraceForAttribute: #exceptionHandlingInternal:
	    do: [:ctx :attr | ^true].
	^false
    ]

    isDisabled [
	"Answers whether the receiver has actually ended execution and will
	 be skipped when doing a return.  BlockContexts are removed from the
	 chain whenever a non-local return is done, but MethodContexts need to
	 stay there in case there is a non-local return from the #ensure:
	 block."

	<category: 'accessing'>
	flags isInteger ifFalse: [^false].
	^flags == 1
    ]

    isUnwind [
	"Answers whether the context must continue execution even after a
	 non-local return (a return from the enclosing method of a block, or
	 a call to the #continue: method of ContextPart).  Such contexts are
	 created only by #ensure:."

	<category: 'accessing'>
	flags isInteger ifFalse: [^false].
	^(flags bitAnd: 2) == 2
    ]

    isEnvironment [
	"To create a valid execution environment for the interpreter even
	 before it starts, GST creates a fake context which invokes a special
	 ``termination'' method.  Such a context can be used as a marker for
	 the current execution environment.  Answer whether the receiver is
	 that kind of context."

	<category: 'accessing'>
	flags isInteger ifFalse: [^false].
	^(flags bitAnd: 4) == 4
    ]

    mark [
	"To create a valid execution environment for the interpreter even
	 before it starts, GST creates a fake context which invokes a special
	 ``termination'' method.  A similar context is created by
	 #valueWithUnwind, by using this method."

	<category: 'accessing'>
	flags := flags bitOr: 4
    ]

    sender [
	"Return the context from which the receiver was sent"

	<category: 'accessing'>
	^self parentContext
    ]

    home [
	"Answer the MethodContext to which the receiver refers
	 (i.e. the receiver itself)"

	<category: 'accessing'>
	^self
    ]

    isBlock [
	"Answer whether the receiver is a block context"

	<category: 'accessing'>
	^false
    ]
]

