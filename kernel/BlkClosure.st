"======================================================================
|
|   BlockClosure Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Object subclass: #BlockClosure
       instanceVariableNames: 'outerContext block receiver'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

BlockClosure comment: 
'I am a factotum class.  My instances represent Smalltalk blocks, portions
of executeable code that have access to the environment that they were
declared in, take parameters, and can be passed around as objects to be
executed by methods outside the current class.
Block closures are sent a message to compute their value and create a new
execution context; this property can be used in the construction of
control flow methods.  They also provide some methods that are used in the
creation of Processes from blocks.'!



!BlockClosure class methodsFor: 'instance creation'!

numArgs: args numTemps: temps bytecodes: bytecodes depth: depth literals: literalArray
    "Answer a BlockClosure for a new CompiledBlock that is created using
     the passed parameters.  To make it work, you must put the BlockClosure
     into a CompiledMethod's literals."
    ^self block: (CompiledBlock
	numArgs: args numTemps: temps bytecodes: bytecodes depth: depth literals: literalArray)
!

block: aCompiledBlock
    "Answer a BlockClosure that activates the passed CompiledBlock."
    ^self new block: aCompiledBlock; yourself
! !


!BlockClosure class methodsFor: 'testing'!

isImmediate
    "Answer whether, if x is an instance of the receiver, x copy == x"
    ^true
! !



!BlockClosure methodsFor: 'overriding'!

shallowCopy
    ^self			"We only have one instance"
!

deepCopy
    ^self			"it's about as deep as we need to get"
! !


!BlockClosure methodsFor: 'private'!

asContext: parent
    "Answer a context which will evaluate the receiver without effects on
     the given context's stack (the return value won't be pushed), as
     soon as it becomes the VM's thisContext.
     parent can be nil - in which case reaching the end of the block will
     probably crash Smalltalk.
     Note that the block has no home, so it cannot contain returns."
    | top block |
    block := BlockContext fromClosure: self parent: parent.
    parent isNil ifFalse: [
	top := (parent sp == 0)
	    ifTrue: [ parent receiver ]
	    ifFalse: [ parent at: parent sp ].

	parent sp: parent sp - 1.
    ].
    ^block
! !
    


!BlockClosure methodsFor: 'exception handling'!

on: anException do: aBlock
    "Evaluate the receiver; when anException is signaled, evaluate aBlock
     passing a Signal describing the exception. Answer either the result of
     evaluating the receiver or the parameter of a Signal>>#return:"

    | active |
    active := 0.
    ^self value
!

on: e1 do: b1 on: e2 do: b2
    "Evaluate the receiver; when e1 or e2 are signaled, evaluate respectively
     b1 or b2, passing a Signal describing the exception. Answer either the
     result of evaluating the receiver or the argument of a Signal>>#return:"

    | active |
    active := 0.
    ^self value
!

on: e1 do: b1 on: e2 do: b2 on: e3 do: b3
    "Evaluate the receiver; when e1, e2 or e3 are signaled, evaluate
     respectively b1, b2 or b3, passing a Signal describing the exception.
     Answer either the result of evaluating the receiver or the parameter of a
     Signal>>#return:"

    | active |
    active := 0.
    ^self value
!

on: e1 do: b1 on: e2 do: b2 on: e3 do: b3 on: e4 do: b4
    "Evaluate the receiver; when e1, e2, e3 or e4 are signaled, evaluate
     respectively b1, b2, b3 or b4, passing a Signal describing the exception.
     Answer either the result of evaluating the receiver or the parameter of a
     Signal>>#return:"

    | active |
    active := 0.
    ^self value
!

on: e1 do: b1 on: e2 do: b2 on: e3 do: b3 on: e4 do: b4 on: e5 do: b5
    "Evaluate the receiver; when e1, e2, e3, e4 or e5 are signaled, evaluate
     respectively b1, b2, b3, b4 or b5, passing a Signal describing the exception.
     Answer either the result of evaluating the receiver or the parameter of a
     Signal>>#return:"

    | active |
    active := 0.
    ^self value
!

ifError: aBlock
    "Evaluate the receiver; when #error: is called, pass to aBlock the receiver
     and the parameter, and answer the result of evaluating aBlock.  If another
     exception is raised, it is passed to an outer handler; if no exception is
     raised, the result of evaluating the receiver is returned."

    ^self on: ExError do: [ :sig |
        sig return: (aBlock valueWithArguments: sig arguments)
    ]
! !



!BlockClosure methodsFor: 'unwind protection'!

ensure: aBlock
    "Evaluate the receiver; when any exception is signaled exit returning the
     result of evaluating aBlock; if no exception is raised, return the result
     of evaluating aBlock when the receiver has ended"

    | result |
    result := self valueAndResumeOnUnwind.
    aBlock value.
    ^result
!

ifCurtailed: aBlock
    "Evaluate the receiver; if its execution triggers an unwind which truncates
     the execution of the block (`curtails' the block), evaluate aBlock.  The
     three cases which can curtail the execution of the receiver are: a non-local
     return in the receiver, a non-local return in a block evaluated by the
     receiver which returns past the receiver itself, and an exception raised
     and not resumed during the execution of the receiver."

    | curtailed |
    ^[ | result |
	curtailed := true.
	result := self value.
	curtailed := false.
	result
    ] ensure: [
        curtailed ifTrue: [ aBlock value ].
    ]
!

valueWithUnwind
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

    thisContext mark.
    ^[ self value ] ensure: [ ContextPart removeLastUnwindPoint ]
! !


!BlockClosure methodsFor: 'control structures'!

repeat
    "Evaluate the receiver 'forever' (actually until a return is executed
    or the process is terminated)."

    "When the receiver is a block expression, repeat is optimized
     by the compiler"
    [ self value ] repeat
!


whileTrue: aBlock
    "Evaluate the receiver. If it returns true, evaluate aBlock and re-
     start"

    "When the receiver is a block expression, whileTrue: is optimized
     by the compiler"
    [ self value ] whileTrue: [ aBlock value ].
    ^nil
!

whileFalse: aBlock
    "Evaluate the receiver. If it returns false, evaluate aBlock and re-
     start"

    "When the receiver is a block expression, whileFalse: is optimized
     by the compiler"
    [ self value ] whileFalse: [ aBlock value ].
    ^nil
!

whileTrue
    "Evaluate the receiver until it returns false"

    "When the receiver is a block expression, whileTrue is optimized
     by the compiler"
    ^[ self value ] whileTrue
!

whileFalse
    "Evaluate the receiver until it returns true"

    "When the receiver is a block expression, whileFalse is optimized
     by the compiler"
    ^[ self value ] whileFalse
! !



!BlockClosure methodsFor: 'multiple process'!

fork
    "Create a new process executing the receiver and start it"
    ^Process
	on: self
	at: Processor activePriority
	suspend: false
!

forkAt: priority
    "Create a new process executing the receiver with given priority
     and start it"
    ^Process
	on: self
	at: priority
	suspend: false
!

newProcess
    "Create a new process executing the receiver in suspended state.
     The priority is the same as for the calling process. The receiver
     must not contain returns"
    ^Process
	on: self
	at: Processor activePriority
	suspend: true
!

newProcessWith: anArray
    "Create a new process executing the receiver with the passed
     arguments, and leave it in suspended state. The priority is
     the same as for the calling process. The receiver must not
     contain returns"
    ^Process
	on: [ self valueWithArguments: anArray ]
	at: Processor activePriority
	suspend: true
!

forkWithoutPreemption
    "Evaluate the receiver in a process that cannot be preempted.
     If the receiver expect a parameter, pass the current process
     (can be useful for queuing interrupts from within the
     uninterruptible process)."

    | closure args process result |
    closure := [ self valueWithArguments: args ].
    args := self numArgs = 0 ifTrue: [ #() ]
	ifFalse: [ { Processor activeProcess } ].

    ^Process
	on: closure
	at: Processor unpreemptedPriority
	suspend: false
!

valueWithoutInterrupts
    "Evaluate aBlock and delay all interrupts that are requested to the
     active process during its execution to after aBlock returns."
    ^Processor activeProcess
	valueWithoutInterrupts: self
!

valueWithoutPreemption
    "Evaluate the receiver with external interrupts disabled.  This
     effectively disables preemption as long as the block does not
     explicitly yield control, wait on semaphores, and the like."
    ^[ Processor disableInterrupts. self value ]
	ensure: [ Processor enableInterrupts ]
! !



!BlockClosure methodsFor: 'testing'!

hasMethodReturn
    "Answer whether the block contains a method return"
    ^self method
	hasBytecode: 124
	between: self initialIP
	and: self finalIP
!


!BlockClosure methodsFor: 'accessing'!

fixTemps
    "This should fix the values of the temporary variables used in the
    block that are ordinarily shared with the method in which the block
    is defined.  Not defined yet, but it is not harmful that it isn't.
    Answer the receiver."
    ^self
!

block
    "Answer the CompiledBlock which contains the receiver's bytecodes"
    ^block
!

block: aCompiledBlock
    "Set the CompiledBlock which contains the receiver's bytecodes"
    block := aCompiledBlock
!

finalIP
    "Answer the last instruction that can be executed by the receiver"
    ^self block size
!

initialIP
    "Answer the initial instruction pointer into the receiver."
    ^1
!

argumentCount
    "Answer the number of arguments passed to the receiver"
    ^block numArgs
!

numArgs
    "Answer the number of arguments passed to the receiver"
    ^block numArgs
!

numTemps
    "Answer the number of temporary variables used by the receiver"
    ^block numTemps
!

stackDepth
    "Answer the number of stack slots needed for the receiver"
    ^block stackDepth
!

method
    "Answer the CompiledMethod in which the receiver lies"
    ^block method
!

receiver
    "Answer the object that is used as `self' when executing the receiver
     (if nil, it might mean that the receiver is not valid though...)"
    ^receiver
!

receiver: anObject
    "Set the object that is used as `self' when executing the receiver"
    receiver := anObject
!

outerContext
    "Answer the method/block context which is the immediate outer of
     the receiver"
    ^outerContext
!

outerContext: containingContext
    "Set the method/block context which is the immediate outer of
     the receiver"
    outerContext := containingContext
! !
