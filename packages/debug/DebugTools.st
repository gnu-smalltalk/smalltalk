"======================================================================
|
|   Inferior process control
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2006, 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: Debugger [
    | debugProcess process breakpointContext stepSemaphore |
    
    <category: 'System-Debugging'>
    <comment: 'I provide debugging facilities for another inferior process.  I have
methods that allow the controlled process to proceed with varying
granularity.  In addition, I keep a cache mapping instruction
pointer bytecodes to line numbers.'>

    MethodLineMapCache := nil.

    Debugger class >> currentLineIn: aContext [
        <category: 'source code'>
        | lineMap method res |
        method := aContext method.
        MethodLineMapCache isNil
            ifTrue: [MethodLineMapCache := WeakKeyIdentityDictionary new].
        lineMap := MethodLineMapCache at: method
                    ifAbsentPut: [method sourceCodeMap].
        res := lineMap at: (aContext ip + 1).
        ^ res = 0
            ifTrue: [ self error: 'IP is not correct' ]
            ifFalse: [ res ]
    ]

    Debugger class >> on: aProcess [
	"Suspend aProcess and return a new Debugger that controls aProcess.
	 aProcess must not be the currently running process."

	<category: 'instance creation'>
	aProcess == Processor activeProcess 
	    ifTrue: [self error: 'cannot attach to current process'].
	aProcess suspend.
	^self new initializeFor: aProcess
    ]

    Debugger class >> debuggerClass [
	<category: 'disabling debugging'>
	^nil
    ]

    isActive [
	"Answer true if the inferior process is still running."

	<category: 'inferior process properties'>
	^process notNil and: [process suspendedContext notNil]
    ]

    process [
	"Answer the inferior process."

	<category: 'inferior process properties'>
	^process
    ]

    currentLine [
	"Return the line number in traced process."

	<category: 'inferior process properties'>
	self isActive ifFalse: [^''].
	^self suspendedContext currentLine
    ]

    suspendedContext [
	"Answer the suspended execution state of the inferior process."

	<category: 'inferior process properties'>
	^process suspendedContext
    ]

    stopInferior [
	"Suspend the inferior process and raise a DebuggerReentered notification
	 in the controlling process."

	<category: 'stepping commands'>
	self stopInferior: nil
    ]

    stopInferior: anObject [
	"Suspend the inferior process and raise a DebuggerReentered notification
	 in the controlling process with anObject as the exception's message."

	<category: 'stepping commands'>
	| exception |
	
	[
	[process suspend.
	debugProcess
	    queueInterrupt: 
		    [self disableBreakpointContext.
		    SystemExceptions.DebuggerReentered signal: anObject];
	    resume] 
		on: Exception
		do: 
		    [:ex | 
		    exception := ex.
		    process resume]] 
		forkAt: Processor unpreemptedPriority.

	"Pass the exception on in the calling process."
	exception isNil ifFalse: [exception signal]
    ]

    restart [
        <category: 'stepping commands'>

        self restart: self suspendedContext.
    ]

    restart: aContext [
        <category: 'stepping commands'>

        | context method newContext |

        context := self suspendedContext.

        [ context = aContext ] whileFalse: [ context := context parentContext ].

        context isBlock ifTrue: [ context outerContext isNil ifTrue: [ ^ self ].
                                  context := context outerContext ].

        method := context receiver class lookupSelector: context method selector.

        newContext := MethodContext new: method stackDepth.

        newContext parentContext: context parentContext.
        newContext ip: 0.
        newContext instVarAt: 4 put: -1 + method numArgs + method numTemps. " stack pointer "
        newContext instVarAt: 5 put: context receiver.                      " receiver "
        newContext instVarAt: 6 put: method.                                " method "
        newContext instVarAt: 7 put: (context instVarAt: 7).                " flags "

        1 to: method numArgs do: [ :i |
            newContext at: i put: (context at: i) ].

        process suspendedContext: newContext
    ]

    stepBytecode [
	"Run a single bytecode in the inferior process."

	<category: 'stepping commands'>
	debugProcess := Processor activeProcess.
	process singleStepWaitingOn: stepSemaphore.
	process suspend.
	debugProcess := nil
    ]

    step [
	"Run to the end of the current line in the inferior process or to the
	 next message send."

	<category: 'stepping commands'>
	| context line |
	context := self suspendedContext.
	line := self currentLine.
	
	[self stepBytecode.
	self suspendedContext == context and: [line = self currentLine]] 
		whileTrue
    ]

    slowNext [
	"Run to the end of the current line in the inferior process, skipping
	 over message sends."

	<category: 'stepping commands'>
	| context line |
	context := self suspendedContext.
	line := self currentLine.

	[self stepBytecode.
	(self suspendedContext notNil
	    and: [self suspendedContext parentContext == context])
		ifTrue: [self slowFinish: self suspendedContext].
	self suspendedContext == context and: [line = self currentLine]]
		whileTrue
    ]

    next [
	"Run to the end of the current line in the inferior process, skipping
	 over message sends."

	<category: 'stepping commands'>
	| context line |
	context := self suspendedContext.
	line := self currentLine.
	
	[self stepBytecode.
	(self suspendedContext notNil 
	    and: [self suspendedContext parentContext == context]) 
		ifTrue: [self finish: self suspendedContext].
	self suspendedContext == context and: [line = self currentLine]] 
		whileTrue
    ]

    finish [
	"Run to the next return."

	<category: 'stepping commands'>
	self finish: self suspendedContext
    ]

    finish: aContext [
	"Run up until aContext returns."

	<category: 'stepping commands'>
	"First, use the slow scheme for internal exception handling contexts.
	 These are more delicate and in general pretty small, so it is not
	 expensive."

	| proc cont context retVal |
	<debugging: true>
	aContext isInternalExceptionHandlingContext 
	    ifTrue: [^self slowFinish: aContext].
	[self suspendedContext isInternalExceptionHandlingContext] 
	    whileTrue: [self slowFinish: self suspendedContext].

	"Create a context that will restart the debugger and place it in the
	 chain.  We don't really use the continuation object directly but,
	 if we use the methods in Continuation, we are sure that contexts
	 are set up correctly."
	debugProcess := Processor activeProcess.
	retVal := Continuation currentDo: [:cc | cont := cc].
	Processor activeProcess == debugProcess 
	    ifTrue: 
		["Put our context below aContext and restart the debugged process."

		context := cont stack.
		context instVarAt: MethodContext instSize put: 2.
		context parentContext: aContext parentContext.
		aContext parentContext: context.
		
		[breakpointContext := aContext.
		debugProcess suspend.
		process resume] 
			forkAt: Processor unpreemptedPriority.

		"Finish the continuation context, which is at the `retVal' line
		 below."
		debugProcess := nil.
		self slowFinish: context]
	    ifFalse: 
		["We arrive here when we finish execution of aContext.  Put the
		 debugger process in control again."

		
		[breakpointContext := nil.
		process suspend.
		debugProcess resume] 
			forkAt: Processor unpreemptedPriority.
		^retVal]
    ]

    slowFinish [
	"Run in single-step mode up to the next return."

	<category: 'stepping commands'>
	self slowFinish: self suspendedContext
    ]

    slowFinish: aContext [
	"Run in single-step mode until aContext returns."

	<category: 'stepping commands'>
	| context newContext |
	context := self suspendedContext.
	
	[
	[self stepBytecode.
	self suspendedContext == context] whileTrue.
	newContext := self suspendedContext.
	newContext notNil and: 
		["no context? exit"

		"a send? go on"

		newContext parentContext == context or: 
			["aContext still in the chain? go on"

			self includes: aContext]]] 
		whileTrue
    ]

    continue [
	"Terminate the controlling process and continue execution of the
	 traced process."

	<category: 'stepping commands'>
	| theDebugProcess theProcess |
	theDebugProcess := Processor activeProcess.
	theProcess := process.
	
	[debugProcess := nil.
	process := nil.
	theDebugProcess terminate.
	theProcess resume] 
		forkAt: Processor unpreemptedPriority.

	"Just in case we get here."
	theDebugProcess primTerminate
    ]

    eval: aString [
        <category: 'evaluation'>

        | context selectorAndArguments stream method result |
        context := self suspendedContext.

        selectorAndArguments := Dictionary new.
        stream := WriteStream on: String new.

        (context isBlock and: [ context outerContext isNil not ]) ifTrue: [ self extractSelectorAndArgumentsFrom: context outerContext to: selectorAndArguments ].
        self extractSelectorAndArgumentsFrom: context to: selectorAndArguments.
        self buildSelectorAndArgs: selectorAndArguments to: stream.
        self buildCode: aString withArgs: selectorAndArguments keys to: stream.
        ^ (self compile: stream contents to: self receiver)
                    ifError: [ :fname :lineNo :errorString | stream contents printNl. (' error : ', errorString) displayNl ]
                    ifSucceed: [ :method | self perform: method selector to: self receiver with: (self extractArgsFrom: selectorAndArguments) ].
    ]

    extractArgsFrom: aDictionary [
        <category: 'private'>

        | array i |
        i := 1.
        array := Array new: aDictionary size.

        aDictionary keys do: [ :each |
            array at: i put: (aDictionary at: each).
            i := i + 1 ].

        ^ array
    ]

    extractSelectorAndArgumentsFrom: aContext to: aDictionary [
        <category: 'private'>

        | i |
        i := 1.

        aContext method arguments do: [ :each |
            aDictionary at: each put: (aContext at: i).
            i := i + 1 ].
        aContext method temporaries do: [ :each |
            aDictionary at: each put: (aContext at: i).
            i := i + 1 ]
    ]

    buildSelectorAndArgs: aDictionary to: aStream [
        <category: 'private'>

        | i |
        i := 1.
        aDictionary isEmpty ifTrue: [ ^ aStream nextPutAll: 'DoIt'; space ].
        aDictionary keys do: [ :each |
            aStream
                nextPutAll: 'arg_';
                nextPutAll: i asString;
                nextPutAll: ': ';
                nextPutAll: #xxx_;
                nextPutAll: each;
                space.
            i := i + 1 ].
    ]

    buildCode: aString withArgs: anArray to: aStream [
        <category: 'private'>

        aStream
            nextPutAll: '[';
            nl;
            nextPutAll: '| '.
        anArray do: [ :each |
            aStream
                nextPutAll: each;
                space ].
        aStream
            nextPutAll: '|';
            nl.
        anArray do: [ :each |
            aStream
                nextPutAll: each;
                nextPutAll: ' := ';
                nextPutAll: #xxx_;
                nextPutAll: each;
                nextPutAll: '.';
                nl ].
        aStream
            nextPutAll: ' ^ [ ';
            nl;
            nextPutAll: aString;
            nl;
            nextPutAll: ' ] value';
            nl;
            nextPutAll: ']'.
    ]

    compile: aString to: anObject [
        <category: 'private'>

        ^ Just value:
                    (anObject class
                        compile: aString
                        ifError: [ :fname :lineNo :errorString | ^ Nothing value: fname value: lineNo value: errorString ])
    ]

    perform: aSelector to: anObject with: anArray [
        <category: 'private'>

        | sem result |
        sem := Semaphore new.
        [ [ result := anObject perform: aSelector withArguments: anArray.
             sem signal ]
                receiver: nil;
                on: Exception do: [ :ex | [ sem signal ] fork.
                                          ex pass ] ]
            receiver: nil;
            fork.
        sem wait.
        anObject class removeSelector: aSelector ifAbsent: [].
        ^ result
    ]

    disableBreakpointContext [
	"Remove the context inserted set by #finish:."

	<category: 'private'>
	| theBreakpointContext |
	theBreakpointContext := breakpointContext.
	breakpointContext := nil.
	debugProcess := nil.
	theBreakpointContext isNil 
	    ifFalse: 
		[theBreakpointContext 
		    parentContext: theBreakpointContext parentContext parentContext]
    ]

    includes: aContext [
	"Answer whether aContext is still in the stack of the traced process."

	<category: 'private'>
	| context |
	context := self suspendedContext.
	
	[context isNil ifTrue: [^false].
	context == aContext ifTrue: [^true].
	context := context parentContext] 
		repeat
    ]

    initializeFor: aProcess [
	<category: 'private'>
	process := aProcess.
	stepSemaphore := Semaphore new
    ]

    receiver [
        <category: 'private'>
        ^ self suspendedContext receiver
    ]
]

