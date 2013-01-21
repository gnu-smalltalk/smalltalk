"======================================================================
|
|   ANSI exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



Namespace current: SystemExceptions [

Exception subclass: UnhandledException [

    | originalException |

    <category: 'Language-Exception'>
    <comment: 'I am raised when a backtrace is shown to terminate the
current process.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'an unhandled exception occurred in the current process'
    ]

    defaultAction [
	"Terminate the current process."

	<category: 'accessing'>
	| debugger debuggerClass context |
	Transcript flush.
	debugger := Processor activeDebugger.
	debugger isNil ifFalse: [^debugger stopInferior: self messageText ].
	debuggerClass := thisContext debuggerClass.
	debuggerClass isNil 
	    ifFalse: [^debuggerClass open: self originalException creator printString , ' error: ' , self messageText ].

	"Default behavior - print backtrace"
	RegressionTesting ifFalse: [self originalException creator basicPrint].
	Transcript
	    nextPutAll: ' error: ';
	    display: self messageText;
	    nl.
	RegressionTesting 
	    ifFalse: 
		[context := thisContext.
		[context isInternalExceptionHandlingContext] 
		    whileTrue: [context := context parentContext].
		context backtraceOn: Transcript].

	thisContext environment continue: nil
    ]

    instantiateDefaultHandler [
	"Private - Fill the receiver with information on its default handler."

	<category: 'private'>
        | signalingContext resumeContext |

	"This exception is kind of special, as we forcedly have to find
         a place to resume---even if the exception was not resumable!
         This typically will happens when the user steps out of the
         exception handling gobbledegook in the debugger."
        signalingContext := thisContext.
        [resumeContext := signalingContext parentContext.
        resumeContext isEnvironment not
            and: [resumeContext isInternalExceptionHandlingContext]]
                whileTrue: [signalingContext := resumeContext].

	self 
	    onDoBlock: nil
	    handlerBlock: [ :ex | ex defaultAction ]
	    onDoContext: signalingContext
	    previousState: nil
    ]

    originalException [
	"Answer the uncaught exception."

	<category: 'accessing'>
	^originalException
    ]

    originalException: anObject [
	"Set the uncaught exception to anObject."

	<category: 'accessing'>
	originalException := anObject
    ]
]

]
