"======================================================================
|
|   BlockClosure Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2007, 2008, 2009
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



Object subclass: BlockClosure [
    | outerContext block receiver |
    
    <category: 'Language-Implementation'>
    <comment: 'I am a factotum class.  My instances represent Smalltalk blocks, portions
of executeable code that have access to the environment that they were
declared in, take parameters, and can be passed around as objects to be
executed by methods outside the current class.
Block closures are sent a message to compute their value and create a new
execution context; this property can be used in the construction of
control flow methods.  They also provide some methods that are used in the
creation of Processes from blocks.'>

    BlockClosure class >> exceptionHandlerResetBlock [
	<category: 'private-instance creation'>
	^[:context | context at: context numArgs + 1 put: 0]
    ]

    BlockClosure class >> exceptionHandlerSearchBlock [
	<category: 'private-instance creation'>
	^
	[:context :signal | 
	| best bestGoodness goodness activeHandlers nested |
	bestGoodness := -1.
	activeHandlers := context at: context numArgs + 1.
	context at: context numArgs + 1 put: -1.
	nested := activeHandlers = -1.
	nested 
	    ifFalse: 
		[1 to: context numArgs - 1
		    by: 2
		    do: 
			[:i | 
			goodness := (context at: i) goodness: signal class.
			goodness > -1 
			    ifTrue: 
				[(activeHandlers bitAt: i) = 1 
				    ifTrue: 
					["Sorry, this handler is already active..."

					nested := true.
					goodness := -1]].
			goodness > bestGoodness 
			    ifTrue: 
				[best := i.
				bestGoodness := goodness]]].

	"Now instantiate the best handler we found"
	best isNil 
	    ifFalse: 
		[context at: context numArgs + 1 put: (activeHandlers setBit: best).
		signal 
		    onDoBlock: context receiver
		    handlerBlock: (context at: best + 1)
		    onDoContext: context
		    previousState: activeHandlers.
		#found]
	    ifTrue: 
		[context at: context numArgs + 1 put: activeHandlers.
		nested ifTrue: [#skip] ifFalse: [nil]]]
    ]

    BlockClosure class >> numArgs: args numTemps: temps bytecodes: bytecodes depth: depth literals: literalArray [
	"Answer a BlockClosure for a new CompiledBlock that is created using
	 the passed parameters.  To make it work, you must put the BlockClosure
	 into a CompiledMethod's literals."

	<category: 'instance creation'>
	^self block: (CompiledBlock 
		    numArgs: args
		    numTemps: temps
		    bytecodes: bytecodes
		    depth: depth
		    literals: literalArray)
    ]

    BlockClosure class >> block: aCompiledBlock receiver: anObject outerContext: aContext [
	"Answer a BlockClosure that activates the passed CompiledBlock
	 with the given receiver."

	<category: 'instance creation'>
	^(self new)
	    block: aCompiledBlock;
	    receiver: anObject;
	    outerContext: aContext;
	    yourself
    ]

    BlockClosure class >> block: aCompiledBlock receiver: anObject [
	"Answer a BlockClosure that activates the passed CompiledBlock
	 with the given receiver."

	<category: 'instance creation'>
	^(self new)
	    block: aCompiledBlock;
	    receiver: anObject;
	    yourself
    ]

    BlockClosure class >> block: aCompiledBlock [
	"Answer a BlockClosure that activates the passed CompiledBlock."

	<category: 'instance creation'>
	^(self new)
	    block: aCompiledBlock;
	    yourself
    ]

    BlockClosure class >> isImmediate [
	"Answer whether, if x is an instance of the receiver, x copy == x"

	<category: 'testing'>
	^true
    ]

    copy [
	<category: 'overriding'>
	^self	"We only have one instance"
    ]

    deepCopy [
	"Answer a shallow copy."
	<category: 'overriding'>
	^self shallowCopy	"it's about as deep as we need to get"
    ]

    asContext: parent [
	"Answer a context which will evaluate the receiver without effects on
	 the given context's stack (the return value won't be pushed), as
	 soon as it becomes the VM's thisContext.
	 parent can be nil - in which case reaching the end of the block will
	 probably crash Smalltalk.
	 Note that the block has no home, so it cannot contain returns."

	<category: 'private'>
	^BlockContext
	    fromClosure: [
	        | top |
	        top := parent isNil
		    ifTrue: [nil]
		    ifFalse: [
			parent sp == 0 
			    ifTrue: [parent receiver]
			    ifFalse: [parent at: parent sp]].
	        self value. top]
	    parent: parent.
    ]

    on: anException do: aBlock [
	"Evaluate the receiver; when anException is signaled, evaluate aBlock
	 passing a Signal describing the exception. Answer either the result of
	 evaluating the receiver or the parameter of a Signal>>#return:"

	<category: 'exception handling'>
	| active |
	<exceptionHandlerSearch: BlockClosure exceptionHandlerSearchBlock
	reset: BlockClosure exceptionHandlerResetBlock>
	active := 0.
	^self valueAndResumeOnUnwind
    ]

    on: e1 do: b1 on: e2 do: b2 [
	"Evaluate the receiver; when e1 or e2 are signaled, evaluate respectively
	 b1 or b2, passing a Signal describing the exception. Answer either the
	 result of evaluating the receiver or the argument of a Signal>>#return:"

	<category: 'exception handling'>
	| active |
	<exceptionHandlerSearch: BlockClosure exceptionHandlerSearchBlock
	reset: BlockClosure exceptionHandlerResetBlock>
	active := 0.
	^self valueAndResumeOnUnwind
    ]

    on: e1 do: b1 on: e2 do: b2 on: e3 do: b3 [
	"Evaluate the receiver; when e1, e2 or e3 are signaled, evaluate
	 respectively b1, b2 or b3, passing a Signal describing the exception.
	 Answer either the result of evaluating the receiver or the parameter of a
	 Signal>>#return:"

	<category: 'exception handling'>
	| active |
	<exceptionHandlerSearch: BlockClosure exceptionHandlerSearchBlock
	reset: BlockClosure exceptionHandlerResetBlock>
	active := 0.
	^self valueAndResumeOnUnwind
    ]

    on: e1 do: b1 on: e2 do: b2 on: e3 do: b3 on: e4 do: b4 [
	"Evaluate the receiver; when e1, e2, e3 or e4 are signaled, evaluate
	 respectively b1, b2, b3 or b4, passing a Signal describing the exception.
	 Answer either the result of evaluating the receiver or the parameter of a
	 Signal>>#return:"

	<category: 'exception handling'>
	| active |
	<exceptionHandlerSearch: BlockClosure exceptionHandlerSearchBlock
	reset: BlockClosure exceptionHandlerResetBlock>
	active := 0.
	^self valueAndResumeOnUnwind
    ]

    on: e1 do: b1 on: e2 do: b2 on: e3 do: b3 on: e4 do: b4 on: e5 do: b5 [
	"Evaluate the receiver; when e1, e2, e3, e4 or e5 are signaled, evaluate
	 respectively b1, b2, b3, b4 or b5, passing a Signal describing the exception.
	 Answer either the result of evaluating the receiver or the parameter of a
	 Signal>>#return:"

	<category: 'exception handling'>
	| active |
	<exceptionHandlerSearch: BlockClosure exceptionHandlerSearchBlock
	reset: BlockClosure exceptionHandlerResetBlock>
	active := 0.
	^self valueAndResumeOnUnwind
    ]

    ifError: aBlock [
	"Evaluate the receiver; when #error: is called, pass to aBlock the receiver
	 and the parameter, and answer the result of evaluating aBlock.  If another
	 exception is raised, it is passed to an outer handler; if no exception is
	 raised, the result of evaluating the receiver is returned."

	<category: 'exception handling'>
	^self on: Error do: [:sig | sig return: (aBlock cull: sig messageText)]
    ]

    ensure: aBlock [
	"Evaluate the receiver; when any exception is signaled exit returning the
	 result of evaluating aBlock; if no exception is raised, return the result
	 of evaluating aBlock when the receiver has ended"

	<category: 'unwind protection'>
	| result |
	result := self valueAndResumeOnUnwind.
	aBlock value.
	^result
    ]

    ifCurtailed: aBlock [
	"Evaluate the receiver; if its execution triggers an unwind which truncates
	 the execution of the block (`curtails' the block), evaluate aBlock.  The
	 three cases which can curtail the execution of the receiver are: a non-local
	 return in the receiver, a non-local return in a block evaluated by the
	 receiver which returns past the receiver itself, and an exception raised
	 and not resumed during the execution of the receiver."

	<category: 'unwind protection'>
	| curtailed |
	^
	[| result |
	curtailed := true.
	result := self value.
	curtailed := false.
	result] 
		ensure: [curtailed ifTrue: [aBlock value]]
    ]

    valueWithUnwind [
	"Evaluate the receiver. Any errors caused by the block will cause a
	 backtrace, but execution will continue in the method that sent
	 #valueWithUnwind, after that call. Example:
	 [ 1 / 0 ] valueWithUnwind.
	 'unwind works!' printNl.
	 
	 Important: this method is public, but it is intended to be used in
	 very special cases (as a rule of thumb, use it only when the
	 corresponding C code uses the _gst_prepare_execution_environment and
	 _gst_finish_execution_environment functions). You should usually
	 rely on #ensure: and #on:do:."

	<category: 'unwind protection'>
	thisContext mark.
	^self value
    ]

    repeat [
	"Evaluate the receiver 'forever' (actually until a return is executed
	 or the process is terminated)."

	"When the receiver is a block expression, repeat is optimized
	 by the compiler"

	<category: 'control structures'>
	[self value] repeat
    ]

    whileTrue: aBlock [
	"Evaluate the receiver. If it returns true, evaluate aBlock and restart"

	"When the receiver is a block expression, whileTrue: is optimized
	 by the compiler"

	<category: 'control structures'>
	[self value] whileTrue: [aBlock value].
	^nil
    ]

    whileFalse: aBlock [
	"Evaluate the receiver. If it returns false, evaluate aBlock and restart"

	"When the receiver is a block expression, whileFalse: is optimized
	 by the compiler"

	<category: 'control structures'>
	[self value] whileFalse: [aBlock value].
	^nil
    ]

    whileTrue [
	"Evaluate the receiver until it returns false"

	"When the receiver is a block expression, whileTrue is optimized
	 by the compiler"

	<category: 'control structures'>
	^[self value] whileTrue
    ]

    whileFalse [
	"Evaluate the receiver until it returns true"

	"When the receiver is a block expression, whileFalse is optimized
	 by the compiler"

	<category: 'control structures'>
	^[self value] whileFalse
    ]

    fork [
	"Create a new process executing the receiver and start it"

	<category: 'multiple process'>
	^Process 
	    on: self
	    at: Processor activePriority
	    suspend: false
    ]

    forkAt: priority [
	"Create a new process executing the receiver with given priority
	 and start it"

	<category: 'multiple process'>
	^Process 
	    on: self
	    at: priority
	    suspend: false
    ]

    newProcess [
	"Create a new process executing the receiver in suspended state.
	 The priority is the same as for the calling process. The receiver
	 must not contain returns"

	<category: 'multiple process'>
	^Process 
	    on: self
	    at: Processor activePriority
	    suspend: true
    ]

    newProcessWith: anArray [
	"Create a new process executing the receiver with the passed
	 arguments, and leave it in suspended state. The priority is
	 the same as for the calling process. The receiver must not
	 contain returns"

	<category: 'multiple process'>
	^Process 
	    on: [self valueWithArguments: anArray]
	    at: Processor activePriority
	    suspend: true
    ]

    forkWithoutPreemption [
	"Evaluate the receiver in a process that cannot be preempted.
	 If the receiver expect a parameter, pass the current process."

	<category: 'multiple process'>
	| creator |
	creator := Processor activeProcess.
	^Process 
	    on: [self cull: creator]
	    at: Processor unpreemptedPriority
	    suspend: false
    ]

    valueWithoutInterrupts [
	"Evaluate aBlock and delay all interrupts that are requested to the
	 active process during its execution to after aBlock returns."

	<category: 'multiple process'>
	^Processor activeProcess valueWithoutInterrupts: self
    ]

    valueWithoutPreemption [
	"Evaluate the receiver with external interrupts disabled.  This
	 effectively disables preemption as long as the block does not
	 explicitly yield control, wait on semaphores, and the like."

	<category: 'multiple process'>
	^
	[Processor disableInterrupts.
	self value] 
		ensure: [Processor enableInterrupts]
    ]

    hasMethodReturn [
	"Answer whether the block contains a method return"

	<category: 'testing'>
	^self method 
	    hasBytecode: 124
	    between: self initialIP
	    and: self finalIP
    ]

    fixTemps [
	"This should fix the values of the temporary variables used in the
	 block that are ordinarily shared with the method in which the block
	 is defined.  Not defined yet, but it is not harmful that it isn't.
	 Answer the receiver."

	<category: 'accessing'>
	^self
    ]

    block [
	"Answer the CompiledBlock which contains the receiver's bytecodes"

	<category: 'accessing'>
	^block
    ]

    block: aCompiledBlock [
	"Set the CompiledBlock which contains the receiver's bytecodes"

	<category: 'accessing'>
	block := aCompiledBlock
    ]

    finalIP [
	"Answer the last instruction that can be executed by the receiver"

	<category: 'accessing'>
	^self block size
    ]

    initialIP [
	"Answer the initial instruction pointer into the receiver."

	<category: 'accessing'>
	^1
    ]

    argumentCount [
	"Answer the number of arguments passed to the receiver"

	<category: 'accessing'>
	^block numArgs
    ]

    numArgs [
	"Answer the number of arguments passed to the receiver"

	<category: 'accessing'>
	^block numArgs
    ]

    numTemps [
	"Answer the number of temporary variables used by the receiver"

	<category: 'accessing'>
	^block numTemps
    ]

    stackDepth [
	"Answer the number of stack slots needed for the receiver"

	<category: 'accessing'>
	^block stackDepth
    ]

    method [
	"Answer the CompiledMethod in which the receiver lies"

	<category: 'accessing'>
	^block method
    ]

    receiver [
	"Answer the object that is used as `self' when executing the receiver
	 (if nil, it might mean that the receiver is not valid though...)"

	<category: 'accessing'>
	^receiver
    ]

    receiver: anObject [
	"Set the object that is used as `self' when executing the receiver"

	<category: 'accessing'>
	receiver := anObject
    ]

    outerContext [
	"Answer the method/block context which is the immediate outer of
	 the receiver"

	<category: 'accessing'>
	^outerContext
    ]

    outerContext: containingContext [
	"Set the method/block context which is the immediate outer of
	 the receiver"

	<category: 'accessing'>
	outerContext := containingContext
    ]

    value [
	"Evaluate the receiver passing no parameters"

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_value>
	SystemExceptions.WrongArgumentCount signal
    ]

    value: arg1 [
	"Evaluate the receiver passing arg1 as the only parameter"

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_value>
	SystemExceptions.WrongArgumentCount signal
    ]

    value: arg1 value: arg2 [
	"Evaluate the receiver passing arg1 and arg2 as the parameters"

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_value>
	SystemExceptions.WrongArgumentCount signal
    ]

    value: arg1 value: arg2 value: arg3 [
	"Evaluate the receiver passing arg1, arg2 and arg3 as the parameters"

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_value>
	SystemExceptions.WrongArgumentCount signal
    ]

    cull: arg1 [
	"Evaluate the receiver, passing arg1 as the only parameter if
	 the receiver has parameters."

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_cull>
	SystemExceptions.WrongArgumentCount signal
    ]

    cull: arg1 cull: arg2 [
	"Evaluate the receiver, passing arg1 and arg2 as parameters if
	 the receiver accepts them."

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_cull>
	SystemExceptions.WrongArgumentCount signal
    ]

    cull: arg1 cull: arg2 cull: arg3 [
	"Evaluate the receiver, passing arg1, arg2 and arg3 as parameters if
	 the receiver accepts them."

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_cull>
	SystemExceptions.WrongArgumentCount signal
    ]

    valueWithArguments: argumentsArray [
	"Evaluate the receiver passing argArray's elements as the parameters"

	<category: 'built ins'>
	<primitive: VMpr_BlockClosure_valueWithArguments>
	argumentsArray isArray 
	    ifFalse: [SystemExceptions.WrongClass signalOn: argumentsArray mustBe: Array].
	SystemExceptions.WrongArgumentCount signal
    ]

    valueAndResumeOnUnwind [
	"Private - For use by #ensure:"

	<category: 'private'>
	<primitive: VMpr_BlockClosure_valueAndResumeOnUnwind>
	SystemExceptions.WrongArgumentCount signal
    ]
]

